import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuExsternalScreen extends StatefulWidget {
  final String idrequest;

  const MenuExsternalScreen({Key? key, required this.idrequest})
      : super(key: key);

  @override
  State<MenuExsternalScreen> createState() => _MenuExsternalScreenState();
}

class _MenuExsternalScreenState extends State<MenuExsternalScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nanti bisa panggil API di sini menggunakan widget.idrequest
    // contoh: _loadData(widget.idrequest);
  }

  @override
  Widget build(BuildContext context) {
    double bodyWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visitor Induction',
          style: TextStyle(
            color: Color(0xFF343434),
            fontFamily: 'Hanken Grotesk',
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            height: 1.0,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF343434)), // Ikon reload
            onPressed: () {
              //_loadData(); // Panggil ulang data
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: bodyWidth,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business_center,
                    size: 60, color: Colors.greenAccent),
                const SizedBox(height: 20),
                Text(
                  "Induction Request ID: ${widget.idrequest}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Approve via Email feature not implemented")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Approve via Email'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("View Details feature coming soon")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('View Request Details'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Reject feature not implemented")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Reject Request'),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
