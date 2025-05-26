import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'approval_screen/pending_approval_screen.dart';
import 'rider_details_controller.dart';
import 'rider_details_ui.dart';
import '../main/main_page.dart';

class RiderDetailsPage extends StatefulWidget {
  const RiderDetailsPage({super.key});

  @override
  State<RiderDetailsPage> createState() => _RiderDetailsPageState();
}

class _RiderDetailsPageState extends State<RiderDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _controller = RiderDetailsController();

  @override
  void initState() {
    super.initState();
    _controller.user = FirebaseAuth.instance.currentUser;
    _loadUserProfile();
    _setupRealtimeListener();
  }

  Future<void> _loadUserProfile() async {
    try {
      await _controller.loadUserProfile();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _setupRealtimeListener() {
    _controller.setupRealtimeListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _pickLicenseImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _controller.licenseImage = File(picked.path);
          _controller.isLicenseValid = false;
          _controller.licenseValidationError = null;
        });
        await _controller.validateLicenseImage(_controller.licenseImage!);
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix all errors before submitting'),
        ),
      );
      return;
    }

    if (_controller.licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your license')),
      );
      return;
    }

    if (!_controller.isLicenseValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a valid license image')),
      );
      return;
    }

    setState(() => _controller.isLoading = true);

    await _controller.submitDetails(
      phone: _phoneController.text.trim(),
      vehicleNo: _vehicleNoController.text.trim(),
      onSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PendingApprovalScreen()),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      },
    );

    setState(() => _controller.isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return RiderDetailsUI(
      controller: _controller,
      formKey: _formKey,
      phoneController: _phoneController,
      vehicleNoController: _vehicleNoController,
      onPickLicense: _pickLicenseImage,
      onSubmit: _submitDetails,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _vehicleNoController.dispose();
    super.dispose();
  }
}
