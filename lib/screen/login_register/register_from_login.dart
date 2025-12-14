import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widget/result_cards/library/library_detail_header.dart';
import '../../service/apis.dart';
import 'login_screen.dart';
import 'register_fields.dart';

class RegisterFromLogin extends StatefulWidget {
  const RegisterFromLogin({super.key});

  @override
  State<RegisterFromLogin> createState() => _RegisterFromLoginState();
}

class _RegisterFromLoginState extends State<RegisterFromLogin> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repeatPasswordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? accountType;
  String? selectedProvince;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    _emailCtrl.dispose();
    _birthDateCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordCtrl.text != _repeatPasswordCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("رمز عبور و تکرار آن یکسان نیست")),
        );
        return;
      }

      final body = {
        "name": _nameCtrl.text,
        "phone": _phoneCtrl.text,
        "password": _passwordCtrl.text,
        "email": _emailCtrl.text,
        "birthDate": _birthDateCtrl.text,
        "nationalId": _nationalIdCtrl.text,
        "address": _addressCtrl.text,
        "province": selectedProvince ?? "",
        "accountType": accountType ?? "",
      };

      try {
        final response = await http.post(
          Uri.parse(ApiUrls.register),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ثبت‌نام با موفقیت انجام شد")),
          );
          // هدایت به صفحه لاگین
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("خطا در ثبت‌نام: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطا در اتصال به سرور: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لطفا فیلدهای ستاره‌دار را تکمیل کنید")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        "لطفا تمام فیلد های ستاره دار را تکمیل نمائید، "
                        "دقت کنید پست الکترونیکی شما بعنوان نام کاربری شما قرار میگیرد",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    RegisterFields(
                      formKey: _formKey,
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      passwordCtrl: _passwordCtrl,
                      repeatPasswordCtrl: _repeatPasswordCtrl,
                      emailCtrl: _emailCtrl,
                      birthDateCtrl: _birthDateCtrl,
                      nationalIdCtrl: _nationalIdCtrl,
                      addressCtrl: _addressCtrl,
                      accountType: accountType,
                      onAccountTypeChanged: (val) => setState(() => accountType = val),
                      selectedProvince: selectedProvince,
                      onProvinceChanged: (val) => setState(() => selectedProvince = val),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: _registerUser,
                        child: const Text("ثبت اطلاعات"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),)
    );
  }
}