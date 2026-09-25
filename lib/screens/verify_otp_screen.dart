import "package:flutter/material.dart";
import "package:medicom/services/api_document_services.dart";
import "package:medicom/data/constant.dart" as constant;
import "change_password_screen.dart";

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() =>
      _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController otpController =
      TextEditingController();

  bool loading = false;
  String? otpError;

  Future<void> verifyOtp() async {
    if (loading) {
      return;
    }

    final otp = otpController.text.trim();

    setState(() {
      otpError = null;
    });

    if (otp.isEmpty) {
      setState(() {
        otpError = "Please enter the OTP";
      });
      return;
    }

    if (otp.length != 6) {
      setState(() {
        otpError = "OTP must be 6 digits";
      });
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final message = await ApiService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) {
        return;
      }

      if (message != "OTP verified successfully") {
        setState(() {
          otpError = message;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(
              email: widget.email,
              otp: otp,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        otpError = e.toString().replaceFirst(
          "Exception: ",
          "",
        );
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
    otpController.dispose();
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
                "Verify OTP",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Enter the 6-digit OTP sent to ${widget.email}.",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofocus: true,
                maxLength: 6,
                onFieldSubmitted: (_) {
                  verifyOtp();
                },
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: "6-digit OTP",
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    letterSpacing: 0,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: constant.backgroundColor,
                  ),
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,

                  errorText: otpError,
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
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 1,
                    ),
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
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),

                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (otpError != null) {
                    setState(() {
                      otpError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : verifyOtp,
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
                          "Verify OTP",
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