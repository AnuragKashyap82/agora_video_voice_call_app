import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_services.dart';
import 'home_page.dart';

class SignUpScree extends StatefulWidget {
  const SignUpScree({super.key});

  @override
  State<SignUpScree> createState() => _SignUpScreeState();
}

class _SignUpScreeState extends State<SignUpScree> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "Enter your email"
                ),

              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Enter your password"
                ),

              ),
              SizedBox(
                height: 26,
              ),
              GestureDetector(
                onTap: ()async{
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  User? user = await _authService.signUpWithEmailPassword(email, password);
                  if (user != null) {
                    // Navigate to home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Signup failed')),
                    );
                  }
                },
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(199),
                      color: Colors.blue
                  ),
                  child: Center(child: Text("Signup")),
                ),
              )
            ],
          ),
        ),

      ),
    );
  }
}
