import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTrueFalseScreen extends StatefulWidget {
  const AddTrueFalseScreen({Key? key}) : super(key: key);

  @override
  State<AddTrueFalseScreen> createState() => _AddTrueFalseScreenState();
}

class _AddTrueFalseScreenState extends State<AddTrueFalseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController questionController = TextEditingController();
  final TextEditingController explanationController = TextEditingController();
  String? correctAnswer; // nullable for validation

  @override
  void dispose() {
    questionController.dispose();
    explanationController.dispose();
    super.dispose();
  }

  Future<void> _showSaveConfirmationDialog() async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Confirm",
          style: TextStyle(fontFamily: 'Hanken Grotesk'),
        ),
        content: const Text(
          "Have you entered everything correctly?",
          style: TextStyle(fontFamily: 'Hanken Grotesk'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "No",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                color: Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
            ),
            child: const Text(
              "Yes, Save",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      // TODO: Save to backend/local
      context.go('/cms/truefalse');
    }
  }

  Future<void> _showBackConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Are you sure?",
          style: TextStyle(fontFamily: 'Hanken Grotesk'),
        ),
        content: const Text(
          "If you go back now, your input will be lost.",
          style: TextStyle(fontFamily: 'Hanken Grotesk'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                color: Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF07840B),
            ),
            child: const Text(
              "Yes, Go Back",
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      context.go('/cms/truefalse');
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller,
      {bool multiline = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextFormField(
          controller: controller,
          maxLines: multiline ? 3 : 1,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "$label cannot be empty";
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
            hintStyle: const TextStyle(
              fontFamily: 'Hanken Grotesk',
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioCard() {
    return FormField<String>(
      validator: (val) {
        if (correctAnswer == null) {
          return "Please select the correct answer";
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: "True",
                      groupValue: correctAnswer,
                      onChanged: (val) {
                        setState(() {
                          correctAnswer = val;
                          state.didChange(val);
                        });
                      },
                      title: const Text(
                        "True",
                        style: TextStyle(fontFamily: 'Hanken Grotesk'),
                      ),
                      activeColor: const Color(0xFF07840B),
                    ),
                    RadioListTile<String>(
                      value: "False",
                      groupValue: correctAnswer,
                      onChanged: (val) {
                        setState(() {
                          correctAnswer = val;
                          state.didChange(val);
                        });
                      },
                      title: const Text(
                        "False",
                        style: TextStyle(fontFamily: 'Hanken Grotesk'),
                      ),
                      activeColor: const Color(0xFF07840B),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: const Text(
          "Add True/False Question",
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader(
                  "Question Details", "Fill in your Question and the Answer"),
              _buildSectionHeader("Question", "Enter your Question"),
              _buildInputCard("Enter your question...", questionController,
                  multiline: true),

              const SizedBox(height: 20),

              _buildSectionHeader("Answer", "Choose the correct answer"),
              _buildRadioCard(),

              const SizedBox(height: 20),

              _buildSectionHeader(
                  "Explanation", "Enter a brief explanation (optional)"),
              _buildInputCard(
                  "Enter the brief explanation...", explanationController,
                  multiline: true),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            // Back Button
            ElevatedButton(
              onPressed: () => _showBackConfirmationDialog(),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => states.contains(MaterialState.hovered)
                      ? Colors.grey[700]! // hover abu-abu tua
                      : Colors.grey[400]!, // default abu-abu muda
                ),
                shape: MaterialStateProperty.all(const CircleBorder()),
                padding: MaterialStateProperty.all(const EdgeInsets.all(14)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),

            // Save Question Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _showSaveConfirmationDialog();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => states.contains(MaterialState.hovered)
                        ? const Color(0xFF056309) // hover hijau lebih tua
                        : const Color(0xFF07840B), // default hijau induction
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                child: const Text(
                  "Save Question",
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
