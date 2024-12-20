import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../api/api_service.dart';
import '../models/user_model.dart';
import 'First_Login.dart';

class LoginResponseModel {
  final bool newLogin;
  final String message;

  LoginResponseModel({
    required this.newLogin,
    required this.message,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      newLogin: json['new_login'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int animationDuration = 1800;
  bool _rememberMe = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Unfocus to hide the keyboard
    FocusScope.of(context).unfocus();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both fields.');
      return;
    }

    try {
      final response = await _apiService.login(username, password);

      if (response.containsKey('new_login') && response['new_login'] == true) {
        final loginResponse = LoginResponseModel.fromJson(response);

        // Navigate to FirstLoginPage if newLogin is true
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FirstLoginPage(username: username),
          ),
        );
      } else {
        final user = UserModel.fromJson(response);

        // Navigate to the main page or dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (error) {
      _showSnackBar('Login failed: ${error.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Colors.grey.shade800,
                Colors.grey.shade800,
                Colors.grey.shade900,
                Colors.grey.shade900,
                Colors.grey.shade400
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 80),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: animationDuration),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: Duration(milliseconds: animationDuration + 300),
                      child: const Text(
                        "Welcome Back",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 60),
                        FadeInUp(
                          duration: Duration(milliseconds: animationDuration + 400),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade500,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    decoration: const InputDecoration(
                                      hintText: "User Name",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: "Password",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: Duration(milliseconds: animationDuration + 500),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                checkColor: Colors.black,
                              ),
                              const Text(
                                "Remember Me",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: Duration(milliseconds: animationDuration + 600),
                          child: MaterialButton(
                            onPressed: _handleLogin,
                            height: 50,
                            color: Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
