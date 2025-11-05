import 'package:flutter/material.dart';
import 'package:she_vi/services/api_service.dart'; // Import the API service
//import 'package:hive/hive.dart';

class ApprovedMailScreen extends StatefulWidget {
  final String idrequest;

  const ApprovedMailScreen({
    Key? key,
    required this.idrequest,
  }) : super(key: key);

  @override
  _ApprovedMailScreenState createState() => _ApprovedMailScreenState();
}

class _ApprovedMailScreenState extends State<ApprovedMailScreen> {
  bool isLoading = false;
  String approvalMessage = '';

  @override
  void initState() {
    super.initState();
    // Call API method when the screen is loaded
    //_sendApprovalRequest(int.parse(widget.idrequest));  // Ensure idrequest is an int
    try {
      int requestId = int.tryParse(widget.idrequest) ?? -1;
      if (requestId == -1) {
        throw FormatException("Invalid request ID: ${widget.idrequest}");
      }
      _sendApprovalRequest(requestId);
    } catch (e) {
      debugPrint('Error parsing ID: $e');
      setState(() {
        approvalMessage = 'Invalid ID request.';
      });
    }
  }

  // Function to send the approval request
  Future<void> _sendApprovalRequest(int idrequest) async {
    setState(() {
      isLoading = true;
      approvalMessage =
          'Processing...'; // Indicate the request is being processed
    });

    try {
      String responseMessage =
          await ApiService().sendApprovalRequest(idrequest);
      setState(() {
        approvalMessage = responseMessage; // Use message from API
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        approvalMessage = e.toString(); // Display error message
        isLoading = false;
      });
    }
  }

  // This is to handle back navigation logic
  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double bodyWidth =
        MediaQuery.of(context).size.width * 0.5; // 90% dari lebar layar
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Approval Request'),
      // ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading indicator while processing
            : Container(
                width: bodyWidth,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
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
                      size: 50.0,
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 10),
                    if (approvalMessage.contains('successfully'))
                      Text(
                        'You can safely close this page.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                  ],
                )),
      ),
    );
  }
}
