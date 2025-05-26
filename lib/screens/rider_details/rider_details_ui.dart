import 'dart:io';
import 'package:eqcart_rider/screens/rider_details/rider_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/colors.dart';

class RiderDetailsUI extends StatelessWidget {
  final RiderDetailsController controller;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController vehicleNoController;
  final Function() onPickLicense;
  final Function() onSubmit;

  const RiderDetailsUI({
    super.key,
    required this.controller,
    required this.formKey,
    required this.phoneController,
    required this.vehicleNoController,
    required this.onPickLicense,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rider Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.secondaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildProfileSection(),
                      const SizedBox(height: 32),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildVehicleField(),
                      const SizedBox(height: 20),
                      _buildLicenseSection(context),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
              controller.profileUrl != null
                  ? NetworkImage(controller.profileUrl!)
                  : null,
          child:
              controller.profileUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
        ),
        const SizedBox(height: 16),
        Text(
          controller.username ?? 'No username',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.email ?? 'No email',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        prefixText: '+91 ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter phone number';
        }
        if (value.trim().length != 10) {
          return 'Enter valid 10-digit number';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Only numbers allowed';
        }
        return null;
      },
    );
  }

  Widget _buildVehicleField() {
    return TextFormField(
      controller: vehicleNoController,
      decoration: InputDecoration(
        labelText: 'Vehicle Number',
        hintText: 'e.g. MH12AB1234',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter vehicle number';
        }
        if (!RegExp(
          r'^[A-Z]{2}[0-9]{1,2}[A-Z]{0,2}[0-9]{4}$',
          caseSensitive: false,
        ).hasMatch(value.trim())) {
          return 'Enter valid vehicle number';
        }
        return null;
      },
    );
  }

  Widget _buildLicenseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driving License',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.licenseImage != null)
          Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  image: DecorationImage(
                    image: FileImage(controller.licenseImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      controller.isLicenseValid
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.isLicenseValid
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          controller.isLicenseValid
                              ? Colors.green
                              : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isLicenseValid
                          ? 'License validated'
                          : (controller.licenseValidationError ??
                              'Validating...'),
                      style: TextStyle(
                        color:
                            controller.isLicenseValid
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPickLicense,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file),
                SizedBox(width: 8),
                Text('Upload License'),
              ],
            ),
          ),
        ),
        if (controller.licenseImage == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Upload a clear photo of your driving license',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'SUBMIT DETAILS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
