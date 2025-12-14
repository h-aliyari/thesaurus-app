import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shamsi_date/shamsi_date.dart';
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../service/apis.dart';

class RegisterFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, phoneCtrl, passwordCtrl,
      repeatPasswordCtrl, emailCtrl, birthDateCtrl, nationalIdCtrl, addressCtrl;
  final String? accountType, selectedProvince;
  final Function(String?) onAccountTypeChanged, onProvinceChanged;

  const RegisterFields({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.repeatPasswordCtrl,
    required this.emailCtrl,
    required this.birthDateCtrl,
    required this.nationalIdCtrl,
    required this.addressCtrl,
    required this.accountType,
    required this.onAccountTypeChanged,
    required this.selectedProvince,
    required this.onProvinceChanged,
  });

  @override
  State<RegisterFields> createState() => _RegisterFieldsState();
}

class _RegisterFieldsState extends State<RegisterFields> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 7,
            children: [
              _field(widget.emailCtrl, "پست الکترونیک*", required: true,
                  type: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty
                      ? "این فیلد الزامی است"
                      : !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)
                          ? "ایمیل معتبر وارد کنید"
                          : null),
              _field(widget.nameCtrl, "نام*", required: true,
                  validator: (v) => v == null || v.isEmpty
                      ? "این فیلد الزامی است"
                      : v.length < 3
                          ? "نام باید حداقل 3 کاراکتر باشد"
                          : null),
              _field(widget.nationalIdCtrl, "کد ملی",
                  type: TextInputType.number,
                  input: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => (v != null && v.isNotEmpty && v.length != 10)
                      ? "کد ملی باید 10 رقم باشد"
                      : null),
              _field(widget.phoneCtrl, "تلفن*", required: true,
                  type: TextInputType.phone,
                  input: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty
                      ? "این فیلد الزامی است"
                      : v.length < 9
                          ? "شماره تلفن باید حداقل 9 رقم باشد"
                          : null),
              _field(widget.repeatPasswordCtrl, "تکرار رمزعبور*", required: true,
                  obscure: true,
                  validator: (v) => v == null || v.isEmpty
                      ? "این فیلد الزامی است"
                      : v.length < 6
                          ? "رمز عبور باید حداقل 6 کاراکتر باشد"
                          : null),
              _field(widget.passwordCtrl, "رمزعبور*", required: true,
                  obscure: true,
                  validator: (v) => v == null || v.isEmpty
                      ? "این فیلد الزامی است"
                      : v.length < 6
                          ? "رمز عبور باید حداقل 6 کاراکتر باشد"
                          : null),
              _field(null, "حوزه های مورد علاقه"),
              _birthDateField(),
              _provinceField(),
              _field(widget.addressCtrl, "نشانی"),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              const Text(":نوع حساب کاربری", style: TextStyle(fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: "حقیقی",
                    groupValue: widget.accountType,
                    onChanged: widget.onAccountTypeChanged,
                  ),
                  const Text("حقیقی"),
                  const SizedBox(width: 30),
                  Radio<String>(
                    value: "حقوقی",
                    groupValue: widget.accountType,
                    onChanged: widget.onAccountTypeChanged,
                  ),
                  const Text("حقوقی"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController? c, String label,
      {bool required = false,
      bool obscure = false,
      TextInputType type = TextInputType.text,
      List<TextInputFormatter>? input,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      textAlign: TextAlign.right,
      keyboardType: type,
      inputFormatters: input,
      validator: validator ??
          (required ? (v) => (v == null || v.isEmpty) ? "این فیلد الزامی است" : null : null),
      decoration: _decoration(label, required: required),
    );
  }

  Widget _birthDateField() {
    return TextFormField(
      controller: widget.birthDateCtrl,
      textAlign: TextAlign.right,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          final j = Jalali.fromDateTime(date);
          widget.birthDateCtrl.text = "${j.year}/${j.month}/${j.day}";
        }
      },
      decoration: _decoration("تاریخ تولد"),
    );
  }

  Widget _provinceField() {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(ApiUrls.cities)),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _field(TextEditingController(), "استان");
        }
        if (snap.hasError || !snap.hasData || snap.data!.statusCode != 200) {
          return _field(widget.addressCtrl, "استان");
        }

        final json = jsonDecode(snap.data!.body);
        final List<dynamic> data = json['data'] ?? [];
        final List<String> provinceList =
            data.map((e) => e['title'] as String).toList();

        if (provinceList.isEmpty) {
          return _field(widget.addressCtrl, "استان");
        }

        final String? value = provinceList.contains(widget.selectedProvince)
            ? widget.selectedProvince
            : null;

        return DropdownButtonFormField2<String>(
          value: value,
          items: provinceList
              .map((p) => DropdownMenuItem(
                    value: p,
                    child: SizedBox(
                      width: 150,
                      child: Center(
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: widget.onProvinceChanged,
          decoration: _decoration("استان"),
          dropdownStyleData: const DropdownStyleData(
            width: 170,
          ),
          buttonStyleData: const ButtonStyleData(
            width: double.infinity,
          ),
        );
      },
    );
  }

  InputDecoration _decoration(String label, {bool required = false}) {
    return InputDecoration(
      label: RichText(
        text: TextSpan(
          text: label.replaceAll("*", ""),
          style: const TextStyle(color: Colors.black),
          children: required
              ? const [TextSpan(text: " *", style: TextStyle(color: Colors.red))]
              : [],
        ),
      ),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}