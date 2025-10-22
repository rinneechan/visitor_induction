import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddMultipleChoiceScreen extends StatefulWidget {
  const AddMultipleChoiceScreen({Key? key}) : super(key: key);

  @override
  State<AddMultipleChoiceScreen> createState() =>
      _AddMultipleChoiceScreenState();
}

class _AddMultipleChoiceScreenState extends State<AddMultipleChoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController questionController = TextEditingController();
  final TextEditingController rightAnswerController = TextEditingController();
  final TextEditingController wrongAnswer1Controller = TextEditingController();
  final TextEditingController wrongAnswer2Controller = TextEditingController();
  final TextEditingController wrongAnswer3Controller = TextEditingController();
  final TextEditingController explanationController = TextEditingController();

  @override
  void dispose() {
    questionController.dispose();
    rightAnswerController.dispose();
    wrongAnswer1Controller.dispose();
    wrongAnswer2Controller.dispose();
    wrongAnswer3Controller.dispose();
    explanationController.dispose();
    super.dispose();
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

  void _saveAndGoBack(BuildContext context) {
    // TODO: Simpan data ke backend/local
    context.go('/cms/multiplechoice'); // langsung balik clean
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF07840B),
        elevation: 0,
        title: const Text(
          "Add Multiple Choice",
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
                  "Question Details", "Fill in your Question and Answers"),
              _buildSectionHeader("Question", "Enter your Question"),
              _buildInputCard("Enter your question...", questionController,
                  multiline: true),
              const SizedBox(height: 20),
              _buildSectionHeader("Right Answer", "Enter your Right Answer"),
              _buildInputCard("Enter Right Answer", rightAnswerController),
              const SizedBox(height: 20),
              _buildSectionHeader(
                  "Wrong Answers", "Enter your Wrong Answer options"),
              _buildInputCard("Enter Wrong Answer 1", wrongAnswer1Controller),
              _buildInputCard("Enter Wrong Answer 2", wrongAnswer2Controller),
              _buildInputCard("Enter Wrong Answer 3", wrongAnswer3Controller),
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
              onPressed: () {
                context.go('/cms/multiplechoice'); // langsung balik
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.grey[700]!; // hover → abu-abu tua
                  }
                  return Colors.grey[400]!; // default → abu-abu muda
                }),
                shape: WidgetStateProperty.all(const CircleBorder()),
                padding: WidgetStateProperty.all(const EdgeInsets.all(14)),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Add Question Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveAndGoBack(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.hovered)) {
                      return const Color(0xFF056309); // hover → hijau lebih tua
                    }
                    return const Color(0xFF07840B); // default → hijau visitor induction
                  }),
                  foregroundColor:
                      WidgetStateProperty.all(Colors.white), // teks putih
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                child: const Text(
                  "Add Question",
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
