import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../service/thesaurus_extra.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController(); final passCtrl = TextEditingController();
  bool loading = false, showPass = false;
  String? error;

  // تابع ورود
  Future<void> login() async {
    setState(() {
      error = null;
    });

    if (userCtrl.text.isEmpty && passCtrl.text.isEmpty) {
      setState(() => error = 'شناسه کاربری اجباری است!\n' 'گذرواژه اجباری است!');
      return;
    } else if (userCtrl.text.isEmpty) {
      setState(() => error = 'شناسه کاربری اجباری است!');
      return;
    } else if (passCtrl.text.isEmpty) {
      setState(() => error = 'گذرواژه اجباری است!');
      return;
    }
    setState(() => loading = true);

    try {
      final success = await ThesaurusExtra.login(userCtrl.text, passCtrl.text);

      if (success) {
        if (!mounted) return;
        // بعد از ورود موفق برو به صفحه‌ی اصلی _ موقت
        context.go('/home');
      } else {
        setState(() => error = 'شناسه کاربری یا رمز عبور نادرست است');
      }
    } catch (_) {
      setState(() => error = 'خطا در اتصال به سرور');
    } finally {
      setState(() => loading = false);
    }
  }

  InputDecoration fieldDeco(String label, [Widget? icon]) => InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
        border: const OutlineInputBorder(),
        suffixIcon: icon,
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w > 400 ? 350.0 : w * 0.85;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/pictures/login_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(color: Colors.black.withOpacity(0.3)),
        Column(children: [
          Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 238, 238, 238),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text: 'به ', style: TextStyle(color: Color.fromARGB(255, 49, 113, 51))),
                  TextSpan(
                      text: 'پایگاه مدیریت اطلاعات علوم اسلامی ', style: TextStyle(color: Color.fromARGB(255, 182, 44, 34))),
                  TextSpan(
                      text: 'خوش آمدید', style: TextStyle(color: Color.fromARGB(255, 64, 148, 67))),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: cardWidth,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0)
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                        controller: userCtrl,
                        textAlign: TextAlign.center,
                        decoration: fieldDeco('شناسه کاربری'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        textAlign: TextAlign.center,
                        obscureText: !showPass,
                        decoration: fieldDeco(
                            'گذرواژه',
                            IconButton(
                                icon: Icon(showPass
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(() => showPass = !showPass))),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 63, 127, 236),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: loading ? null : login,
                          child: loading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)
                              : const Text('ورود',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ]),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    child: Container(
                      color: Colors.black,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('ثبت‌نام کنید',
                                style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () => context.go('/forgot'),
                            child: const Text('گذرواژه را فراموش کردید؟',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color:
                const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton(
              onPressed: () => context.go('/usage_guide'),
              child: const Text(
                'راهنمای استفاده از سامانه',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ]),
      ]),)
    );
  }
}

class WebPage extends StatelessWidget {
  final String url;
  const WebPage({super.key, required this.url});
  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
    return Scaffold(
      appBar: AppBar(title: const Text('ورود به سامانه')),
      body: WebViewWidget(controller: controller),
    );
  }
}