import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String gender = "Male";
  String? userEmail;
  String? imageBase64;

  File? _selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userEmail)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        fNameController.text = data["firstName"] ?? "";
        lNameController.text = data["lastName"] ?? "";
        dobController.text = data["dob"] ?? "";
        mobileController.text = data["mobile"] ?? "";
        gender = data["gender"] ?? "Male";
        imageBase64 = data["imageBase64"];
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = DateTime.now();

    if (dobController.text.isNotEmpty) {
      try {
        initialDate = DateFormat("dd/MM/yyyy").parse(dobController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dobController.text = DateFormat("dd/MM/yyyy").format(picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked =
    await _picker.pickImage(source: source, imageQuality: 50);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<String> convertToBase64(File imageFile) async {
    List<int> bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> saveProfile() async {
    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() => isLoading = true);

      userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) throw Exception("User not logged in");

      String finalImage = imageBase64 ?? "";

      if (_selectedImage != null) {
        finalImage = await convertToBase64(_selectedImage!);
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userEmail)
          .set({
        "firstName": fNameController.text.trim(),
        "lastName": lNameController.text.trim(),
        "dob": dobController.text.trim(),
        "email": userEmail,
        "mobile": mobileController.text.trim(),
        "gender": gender,
        "imageBase64": finalImage,
      }, SetOptions(merge: true));

      setState(() {
        imageBase64 = finalImage;
        _selectedImage = null;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  Widget _formField({
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    bool isNumber = false,
    IconData? icon,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
        isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: gender,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (value) {
            setState(() {
              gender = value!;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (imageBase64 != null && imageBase64!.isNotEmpty) {
      imageProvider = MemoryImage(base64Decode(imageBase64!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _formField(
                    hint: "First Name",
                    controller: fNameController,
                    validator: (value) =>
                    value!.isEmpty ? "Enter first name" : null,
                  ),
                  _formField(
                    hint: "Last Name",
                    controller: lNameController,
                    validator: (value) =>
                    value!.isEmpty ? "Enter last name" : null,
                  ),
                  _formField(
                    hint: "Date of Birth",
                    controller: dobController,
                    readOnly: true,
                    icon: Icons.calendar_today,
                    onTap: _selectDate,
                    validator: (value) =>
                    value!.isEmpty ? "Select DOB" : null,
                  ),
                  _formField(
                    hint: "Phone Number",
                    controller: mobileController,
                    isNumber: true,
                    icon: Icons.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter phone number";
                      } else if (value.length != 10) {
                        return "Enter valid 10-digit number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  _dropdownField(),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Save & Continue",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}