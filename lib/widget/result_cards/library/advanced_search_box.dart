import 'package:flutter/material.dart';

class AdvancedSearchBox extends StatefulWidget {
  final String initialTitle;
  final String initialPublisher;
  final String initialAuthor;
  final String initialSubject;
  final String initialType;

  final void Function({
    required String title,
    required String publisher,
    required String author,
    required String subject,
    required String type,
  }) onSearch;

  const AdvancedSearchBox({
    super.key,
    this.initialTitle = "",
    this.initialPublisher = "",
    this.initialAuthor = "",
    this.initialSubject = "",
    this.initialType = "",
    required this.onSearch,
  });

  @override
  State<AdvancedSearchBox> createState() => _AdvancedSearchBoxState();
}

class _AdvancedSearchBoxState extends State<AdvancedSearchBox> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // لیست انواع
  final Map<String, String> _typeMap = {
    "": "0",
    "کتاب": "1",
    "مقاله": "2",
    "مجله": "3",
    "پایان نامه ارشد": "4",
    "پایان نامه دکتری": "5",
  };

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _publisherController.text = widget.initialPublisher;
    _authorController.text = widget.initialAuthor;
    _subjectController.text = widget.initialSubject;
    _selectedType = widget.initialType.isNotEmpty ? widget.initialType : "";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Colors.grey.shade800, Colors.black]
                    : [const Color.fromARGB(124, 162, 167, 178), Colors.white],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search,
                      size: 30,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color.fromARGB(136, 62, 62, 62)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "جستجوی پیشرفته",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? cs.primary
                            : const Color.fromARGB(221, 36, 150, 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // فیلدها
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildField("عنوان", controller: _titleController),
                const SizedBox(height: 12),
                _buildField("انتشارات", controller: _publisherController),
                const SizedBox(height: 12),
                _buildField("نویسنده", controller: _authorController),
                const SizedBox(height: 12),
                _buildField("موضوع", controller: _subjectController),
                const SizedBox(height: 12),
                _buildDropdownField("نوع"),
                const SizedBox(height: 20),

                // دکمه جستجو
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    onPressed: () {
                      final typeCode = _typeMap[_selectedType ?? ""] ?? "0";

                      debugPrint('AdvancedSearchBox -> '
                          'title=${_titleController.text}, '
                          'publisher=${_publisherController.text}, '
                          'author=${_authorController.text}, '
                          'subject=${_subjectController.text}, '
                          'type=$typeCode');

                      widget.onSearch(
                        title: _titleController.text.trim(),
                        publisher: _publisherController.text.trim(),
                        author: _authorController.text.trim(),
                        subject: _subjectController.text.trim(),
                        type: typeCode,
                      );
                    },
                    child: const Text("جستجو"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedType!.isEmpty ? null : _selectedType,
          items: _typeMap.keys.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type.isEmpty ? "همه" : type, textAlign: TextAlign.right),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value ?? "";
            });
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
          ),
        ),
      ],
    );
  }
}
