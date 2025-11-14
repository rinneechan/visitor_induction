// lib/screens/induction_test/mobile_pdf_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class MobilePdfViewer extends StatefulWidget {
  final String documentUrl; // Path lokal file PDF
  final VoidCallback onFinishedReading;

  const MobilePdfViewer({
    Key? key,
    required this.documentUrl, // Harus berupa path lokal (misalnya dari getTemporaryDirectory)
    required this.onFinishedReading,
  }) : super(key: key);

  @override
  State<MobilePdfViewer> createState() => _MobilePdfViewerState();
}

class _MobilePdfViewerState extends State<MobilePdfViewer> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lihat PDF'),
        actions: [
          // Tambahkan tombol untuk menandai bahwa PDF telah dibaca
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: widget.onFinishedReading, // Panggil callback ketika selesai membaca
          ),
        ],
      ),
      body: Stack(
        children: [
          // Tampilkan error jika terjadi
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat PDF: $_error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                  ),
                ],
              ),
            )
          else
            // Tampilkan PDF View
            PDFView(
              filePath: widget.documentUrl, // Gunakan path lokal file PDF
              // Callback saat halaman berubah (opsional, bisa digunakan untuk tracking)
              onPageChanged: (int? page, int? pagesCount) {
                // Contoh: print('Sedang di halaman: $page dari $pagesCount');
              },
              // Callback saat PDF View siap ditampilkan
              onViewCreated: (PDFViewController pdfViewController) {
                setState(() {
                  _isLoading = false; // Hentikan loading indicator
                });
              },
              // Callback jika terjadi error saat loading PDF
              onError: (dynamic error) {
                setState(() {
                  _isLoading = false;
                  _error = error.toString(); // Simpan pesan error
                });
              },
              // Callback jika terjadi error saat mencoba menampilkan halaman tertentu
              onPageError: (int? page, dynamic error) {
                setState(() {
                  _isLoading = false;
                  _error = 'Error di halaman $page: ${error.toString()}';
                });
              },
              // --- Opsi Tampilan (Gunakan parameter langsung di PDFView) ---
              fitEachPage: false, // true = halaman menyesuaikan lebar layar, false = seperti default
              autoSpacing: true, // Jarak otomatis antar halaman
              pageFling: true,   // Animasi fling saat swipe
              swipeHorizontal: false, // false = scroll vertikal, true = scroll horizontal
              nightMode: false, // Mode malam (hitam teks putih)
              // backgroundColor: Colors.grey, // Warna latar belakang PDF
              // textSelectionEnabled: true, // Aktifkan pilihan teks (jika perlu)
              // antialiasing: true, // Antialiasing (jika perlu)
              // enableDoubleTap: true, // Aktifkan zoom dengan double tap
              // defaultPage: 0, // Halaman default saat pertama kali dibuka
              // pageSnap: true, // Snap ke halaman saat scroll
              // onViewCreated tidak diulang di sini karena sudah di atas
            ),
          // Tampilkan loading indicator saat PDF sedang dimuat
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}