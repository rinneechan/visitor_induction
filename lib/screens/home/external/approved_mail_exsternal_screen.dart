import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart'; // Import API service

class ApprovedMailExsternalScreen extends StatefulWidget {
  final String idrequest;

  const ApprovedMailExsternalScreen({
    Key? key,
    required this.idrequest,
  }) : super(key: key);

  @override
  _ApprovedMailExsternalScreenState createState() =>
      _ApprovedMailExsternalScreenState();
}

class _ApprovedMailExsternalScreenState
    extends State<ApprovedMailExsternalScreen> {
  bool isLoading = false;
  String approvalMessage = '';

  @override
  void initState() {
    super.initState();
    _initApproval();
  }

  Future<void> _initApproval() async {
    try {
      int requestId = int.tryParse(widget.idrequest) ?? -1;
      if (requestId == -1) {
        throw const FormatException("Invalid request ID");
      }
      await _sendApprovalRequest(requestId);
    } catch (e) {
      debugPrint('Error parsing ID: $e');
      setState(() {
        approvalMessage = 'Invalid ID request.';
      });
    }
  }

  Future<void> _sendApprovalRequest(int idrequest) async {
    setState(() {
      isLoading = true;
      approvalMessage = 'Processing...';
    });

    try {
      final responseMessage =
          await ApiService().sendApprovalexsternalRequest(idrequest);

      setState(() {
        approvalMessage = responseMessage;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        approvalMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double bodyWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Container(
                width: bodyWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: approvalMessage.contains('successfully')
                        ? Colors.green
                        : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      approvalMessage.contains('successfully')
                          ? Icons.check_circle
                          : Icons.error,
                      color: approvalMessage.contains('successfully')
                          ? Colors.green
                          : Colors.red,
                      size: 60.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      approvalMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: approvalMessage.contains('successfully')
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (approvalMessage.contains('successfully')) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'You can safely close this page.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
