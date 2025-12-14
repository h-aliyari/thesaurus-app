import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UsageGuideScreen extends StatelessWidget {
  const UsageGuideScreen({super.key});

  Future<void> openPdf() async {
    final url = Uri.parse('https://my.dte.ir/sso-help.pdf');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(8));

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 هدر
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/pictures/logo.png", height: 60),
                  const SizedBox(width: 12),
                  const Text(
                    "سامانه احراز هویت یکپارچه",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),                  
                ],
              ),
            ),

            // محتوای اصلی
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "راهنمای سامانه",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: 300,
                      height: 180,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Text("ویدیو"),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: openPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                        ),
                        child: const Text("کتابچه راهنمای سامانه"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}