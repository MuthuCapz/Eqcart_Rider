import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RiderDetailsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? username;
  String? email;
  String? profileUrl;
  File? licenseImage;
  bool isLoading = false;
  bool isLicenseValid = false;
  String? licenseValidationError;

  Future<void> loadUserProfile() async {
    try {
      final query =
          await _firestore
              .collection('riders')
              .where('email', isEqualTo: user?.email)
              .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        username = doc['username'] ?? '';
        profileUrl = doc['profile'] ?? '';
        email = doc['email'] ?? user?.email ?? '';
      }
    } catch (e) {
      throw Exception('Error loading profile: ${e.toString()}');
    }
  }

  void setupRealtimeListener(void Function() updateState) {
    _firestore
        .collection('riders')
        .where('email', isEqualTo: user?.email)
        .snapshots()
        .listen((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            final doc = querySnapshot.docs.first;
            username = doc['username'] ?? '';
            profileUrl = doc['profile'] ?? '';
            email = doc['email'] ?? user?.email ?? '';
            updateState();
          }
        });
  }

  Future<void> validateLicenseImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      final text = recognizedText.text.replaceAll('\n', ' ').toUpperCase();

      final patterns = [
        r'[A-Z]{2}[0-9]{2}[0-9]{11}',
        r'[A-Z]{2}-[0-9]{2}[0-9]{11}',
        r'[A-Z]{2}\s[0-9]{2}[0-9]{11}',
        r'[A-Z]{2}[0-9]{2}\s[0-9]{11}',
        r'DL[0-9-]{13,15}',
      ];

      isLicenseValid = patterns.any(
        (pattern) => RegExp(pattern).hasMatch(text),
      );
      licenseValidationError = isLicenseValid ? null : 'Invalid license format';
    } catch (e) {
      isLicenseValid = false;
      licenseValidationError = 'Error validating license';
    }
  }

  Future<String> uploadLicenseImage() async {
    if (licenseImage == null) throw Exception('No license image selected');

    final ref = FirebaseStorage.instance.ref().child(
      'rider_licenses/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile(licenseImage!);
    return await ref.getDownloadURL();
  }

  Future<void> checkApprovalStatus(Function(bool) onStatusChange) async {
    final doc = await _firestore.collection('riders_info').doc(user!.uid).get();
    if (doc.exists) {
      final status = doc['approval_status'] ?? 'pending';
      onStatusChange(status == 'approved');
    }
  }

  Future<void> submitDetails({
    required String phone,
    required String vehicleNo,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final licenseUrl = await uploadLicenseImage();

      await _firestore.collection('riders_info').doc(user!.uid).set({
        'userId': user!.uid,
        'name': username,
        'email': email,
        'phone': phone,
        'vehicle_no': vehicleNo.trim().toUpperCase(),
        'license_url': licenseUrl,
        'license_validated': isLicenseValid,
        'profile_picture': profileUrl,
        'approval_status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      onSuccess();
    } catch (e) {
      onError('Error submitting details: ${e.toString()}');
    }
  }
}
