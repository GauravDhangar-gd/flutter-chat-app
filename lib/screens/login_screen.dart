import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final AuthService auth = AuthService();
  final FirestoreService firestore = FirestoreService();

  bool isLoading = false;
  bool otpSent = false;

  //==========================
  // SEND OTP
  //==========================

  Future<void> sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      await auth.sendOTP(
        phoneNumber: phoneController.text.trim(),

        codeSent: (id) {
          if (!mounted) return;

          setState(() {
            otpSent = true;
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP Sent Successfully")),
          );
        },

        verificationFailed: (error) {
          if (!mounted) return;

          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? "Verification Failed")),
          );
        },

        verificationCompleted: (credential) async {
          final user = credential.user;

          if (user == null) return;

          final exists = await firestore.userExists(user.uid);

          if (!mounted) return;

          if (exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileSetupScreen(
                  uid: user.uid,
                  phoneNumber: phoneController.text.trim(),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //==========================
  // VERIFY OTP
  //==========================

  Future<void> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid OTP")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      User? user = await auth.verifyOTP(smsCode: otpController.text.trim());

      if (user == null) {
        throw Exception("Login Failed");
      }

      final exists = await firestore.userExists(user.uid);

      if (!mounted) return;

      if (exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(
              uid: user.uid,
              phoneNumber: phoneController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  //==========================
  // RESEND OTP
  //==========================

  Future<void> resendOtp() async {
    try {
      await auth.resendOTP(
        phoneNumber: phoneController.text.trim(),

        codeSent: (id) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("OTP Resent")));
        },

        verificationFailed: (error) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.message ?? "Failed")));
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //==========================
  // CHANGE NUMBER
  //==========================

  void changeNumber() {
    setState(() {
      otpSent = false;
      otpController.clear();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),

              const Icon(Icons.chat, size: 90, color: Colors.blue),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),

              // Phone Number
              TextFormField(
                controller: phoneController,
                enabled: !otpSent,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "+919876543210",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter phone number";
                  }

                  final phoneRegex = RegExp(r'^\+[1-9]\d{8,14}$');

                  if (!phoneRegex.hasMatch(value.trim())) {
                    return "Enter a valid phone number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (otpSent)
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: "OTP",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sms),
                  ),
                  validator: (value) {
                    if (!otpSent) return null;

                    if (value == null || value.trim().isEmpty) {
                      return "Enter OTP";
                    }

                    if (value.trim().length != 6) {
                      return "OTP should contain 6 digits";
                    }

                    return null;
                  },
                ),

              if (otpSent)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: resendOtp,
                    child: const Text("Resend OTP"),
                  ),
                ),

              if (otpSent)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: changeNumber,
                    child: const Text("Change Number"),
                  ),
                ),

              const SizedBox(height: 25),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (otpSent) {
                            if (_formKey.currentState!.validate()) {
                              verifyOtp();
                            }
                          } else {
                            sendOtp();
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          otpSent ? "Verify OTP" : "Send OTP",
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
