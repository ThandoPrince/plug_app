import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClientLogin(),
    );
  }
}

class ClientLogin extends StatefulWidget {
  const ClientLogin({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<ClientLogin> {
  bool isLogin = true;

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        shadowColor: Colors.lightBlueAccent,
        title: Center(
          child: const Text(
            'Plug',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  isLogin ? 'Welcome Back' : 'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  isLogin
                      ? 'Fill out the information below in order to access your account.'
                      : 'Let’s get started by filling out the form below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 30),
                // Email field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Password field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.visibility_off),
                  ),
                ),
                if (!isLogin) ...[
                  SizedBox(height: 16),
                  // Confirm Password field (for sign up only)
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(Icons.visibility_off),
                    ),
                  ),
                ],
                SizedBox(height: 20),
                // Button
                ElevatedButton(
                  onPressed: () {

                    context.go("/entryPoint");

                  },
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isLogin ? 'Sign In' : 'Get Started',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                if (isLogin) ...[
                  TextButton(
                    onPressed: () {
                      // Forgot password logic
                    },
                    child: Text('Forgot Password?'),
                  ),
                ],
                SizedBox(height: 20),
                // Toggle between forms
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: toggleForm,
                      child: Text(
                        isLogin ? 'Create Account' : 'Back to Log In',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}