import 'dart:convert';
import 'dart:typed_data';

import 'package:cr_admin/Features/authentication/controllers/signup_controller/sign_up_controller.dart';
import 'package:cr_admin/Features/authentication/screens/login/login_screen.dart';
import 'package:cr_admin/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final List<String> _classCodes = ['3A', '3B', '3C', '3D', '3E', '3F'];
  String? _selectedClassCode;
  bool _isPasswordVisible = false;
  final ImagePicker _picker = ImagePicker();
  final SignUpController _controller = Get.put(SignUpController());
  XFile? _pickedImageFile;
  Uint8List? _image;
  XFile? _file;
  String? _imageString; // Declaration for image string variable

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      _image = await _file?.readAsBytes(); // Read the image as bytes
      _imageString =
          base64Encode(_image!); // Encode the image bytes to base64 string
      return _image;
    }
    print('No Image Selected');
  }

  selectImage(SignUpController controller) async {
    Uint8List? image = await pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      controller.imageBinary.value = image;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final controller = Get.put(SignUpController());
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffB81736),
                  Color(0xff281537),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Create Your\nAccount',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Image.asset(
                            "assets/sign-up.gif",
                            fit: BoxFit.contain,
                            width: 300, // Adjust the width to control the GIF size
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.signUpFormKey,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            _image != null
                                ? CircleAvatar(
                                    radius: 0.12 * screenWidth, // Adjusted for responsiveness
                                    backgroundImage: MemoryImage(_image!),
                                  )
                                : CircleAvatar(
                                    radius: 0.12 * screenWidth, // Adjusted for responsiveness
                                    backgroundImage: const NetworkImage(
                                      "https://media.istockphoto.com/id/1316420668/vector/user-icon-human-person-symbol-social-profile-icon-avatar-login-sign-web-user-symbol.jpg?s=612x612&w=0&k=20&c=AhqW2ssX8EeI2IYFm6-ASQ7rfeBWfrFFV4E87SaFhJE=",
                                    ),
                                  ),
                            Positioned(
                              bottom: -0.015 * screenWidth, // Adjusted for responsiveness
                              left: 0.145 * screenWidth, // Adjusted for responsiveness
                              child: IconButton(
                                onPressed: () {
                                  selectImage(_controller);
                                },
                                icon: Icon(Icons.add_a_photo),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'Enter FullName';
                            return null;
                          },
                          controller: controller.firstName,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Full Name',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'Enter User Name (*Must Be Unique)';
                            return null;
                          },
                          controller: controller.userName,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'UserName',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Email';
                            }
                            // No specific pattern validation, allowing any email format
                            return null;
                          },
                          controller: controller.email,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Email',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'Enter Id Number';
                            return null;
                          },
                          controller: controller.studentId,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.check,
                              color: Colors.grey,
                            ),
                            label: Text(
                              'Id Number',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) return 'Enter Password';
                            return null;
                          },
                          controller: controller.password,
                          obscureText: !_isPasswordVisible, // Toggle password visibility
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            label: const Text(
                              'Password',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            label: Text(
                              'Class Code',
                              style: TextStyle(
                                color: Color(0xffB81736),
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ),
                          value: _selectedClassCode,
                          items: _classCodes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              controller.selectedSection.value = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 70),
                        InkWell(
                          onTap: () {
                            controller.signUp();
                          },
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xffB81736),
                                  Color(0xff281537),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () {
                                Get.to(LoginScreen());
                              },
                              child: const Text('Log In'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
