import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  Future<void> sendReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);
      await Future.delayed(const Duration(seconds: 2));
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("کد بازیابی به شماره شما ارسال شد")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(8));

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            // فرم
            final formContent = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "گذرواژه خود را فراموش کرده اید؟ 🔒",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "شماره همراه را برای ارسال کد وارد کنید",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 250,
                    child: TextFormField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 11,
                      textAlign: TextAlign.center,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "شماره موبایل الزامی است";
                        }
                        if (val.length != 11 || !val.startsWith("09")) {
                          return "شماره باید 11 رقم و با 09 شروع شود";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "شماره موبایل",
                        border: OutlineInputBorder(borderRadius: borderRadius),
                        counterText: "",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: loading ? null : sendReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: const RoundedRectangleBorder(
                        borderRadius: borderRadius,
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("ارسال کد به شماره همراه"),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    "< بازگشت به صفحه ورود",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            );

            // هدر بالای صفحه
            final header = Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "سامانه احراز هویت یکپارچه",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Image.asset("assets/pictures/logo.png", height: 60),
                ],
              ),
            );

            final svgImage = SvgPicture.asset(
              "assets/pictures/login-v2.svg",
              width: isWide ? 380 : 250,
            );

            return Column(
              children: [
                header,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Center(
                      child: isWide
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 95),
                                formContent,
                                const SizedBox(width: 85),
                                svgImage,
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                formContent,
                                const SizedBox(height: 40),
                                svgImage,
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
