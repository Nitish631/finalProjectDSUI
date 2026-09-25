import "package:flutter/material.dart";
import "package:medicom/data/database.dart";
import "package:medicom/screens/admin_home_screen.dart";
import "package:medicom/services/api_document_services.dart";
import "package:medicom/data/constant.dart" as constant;

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final adminDatabase = AdminDatabase();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool loading = false;
  String? passwordError;
  String? confirmPasswordError;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isValidPassword(String password) {
    return RegExp(
  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$',
).hasMatch(password);
  }

  Future<void> changePassword() async {
    if (loading) {
      return;
    }

    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      passwordError = null;
      confirmPasswordError = null;
    });

    if (password.isEmpty) {
      setState(() {
        passwordError = "Please enter your new password";
      });
      return;
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        confirmPasswordError = "Please confirm your password";
      });
      return;
    }
    if (!isValidPassword(password)) {
      setState(() {
        passwordError =
            "8+ chars, uppercase, lowercase, number & special character";
      });
      return;
    }
    if (password != confirmPassword) {
      setState(() {
        confirmPasswordError = "Passwords do not match";
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final message = await ApiService.changePassword(
        email: widget.email,
        otp: widget.otp,
        password: password,
      );

      if (!mounted) {
        return;
      }

      if (message != "Password changed successfully") {
        setState(() {
          passwordError = message;
        });
      } else {
        await adminDatabase.saveCredentials(
          email: widget.email,
          password: password,
        );

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminHomeScreen(email: widget.email, password: password),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        passwordError = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: constant.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),

              const Text(
                "Change Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Create a new password for your account.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "New Password",
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: constant.backgroundColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: constant.backgroundColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,

                  errorText: passwordError,
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: constant.backgroundColor,
                      width: 2,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                onChanged: (_) {
                  if (passwordError != null) {
                    setState(() {
                      passwordError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  changePassword();
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Confirm Password",
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: constant.backgroundColor,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: constant.backgroundColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,

                  errorText: confirmPasswordError,
                  errorStyle: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: constant.backgroundColor,
                      width: 2,
                    ),
                  ),

                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                onChanged: (_) {
                  if (confirmPasswordError != null) {
                    setState(() {
                      confirmPasswordError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: constant.buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
