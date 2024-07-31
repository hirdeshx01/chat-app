import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firbase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  String _enteredEmail = '';
  String _enteredPassword = '';
  File? _selectedImage;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    } else if (!_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add an image. Click circular avatar."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } else {
      _form.currentState!.save();
    }

    try {
      if (_isLogin) {
        await _firbase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredentials = await _firbase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatar_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        storageRef.getDownloadURL();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? 'Authentication failed!',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLogin)
              Image.asset(
                'assets/images/chat.png',
                width: 200,
                height: 200,
              ),
            Form(
                key: _form,
                child: Column(
                  children: [
                    if (!_isLogin)
                      UserImagePicker(
                        onPickImage: (pickedImage) {
                          _selectedImage = pickedImage;
                        },
                      ),
                    const SizedBox(height: 50),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _enteredEmail = newValue!,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        prefixIcon: const Icon(Icons.password),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length <= 6) {
                          return 'Password must be 6 characters long';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _enteredPassword = newValue!,
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                _submit();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.maxFinite, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin ? 'Create an account' : 'Already have an account',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
