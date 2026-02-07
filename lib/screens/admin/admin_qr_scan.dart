import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'user_details.dart';

class AdminQRScanScreen extends StatefulWidget {
  const AdminQRScanScreen({super.key});

  @override
  State<AdminQRScanScreen> createState() => _AdminQRScanScreenState();
}

class _AdminQRScanScreenState extends State<AdminQRScanScreen> {
  bool _isDisposed = false;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isDisposed) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        // Pause camera to prevent multiple scans
        _controller.stop();
        
        // Navigate to User Details
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: code)
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Member QR"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  default: // Handle auto or unavailable
                     return const Icon(Icons.flash_off, color: Colors.grey);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                  default:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          Center(
             child: Container(
               width: 250,
               height: 250,
               decoration: BoxDecoration(
                 border: Border.all(color: Colors.yellow, width: 4),
                 borderRadius: BorderRadius.circular(12),
                 boxShadow: const [
                   BoxShadow(color: Colors.black26, blurRadius: 10)
                 ]
               ),
             ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              "Align QR Code within the frame",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)]
              ),
            ),
          )
        ],
      ),
    );
  }
}
