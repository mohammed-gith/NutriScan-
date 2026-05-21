import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/product_model.dart';
import '../services/open_food_facts_service.dart';
import '../services/product_storage_service.dart';
import 'product_result_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController(
    text: '737628064502',
  );
  final OpenFoodFactsService _service = OpenFoodFactsService();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasScannedBarcode = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(BarcodeCapture capture) {
    if (_hasScannedBarcode || _isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final scannedCode = barcodes.first.rawValue;
    if (scannedCode == null || scannedCode.isEmpty) return;

    setState(() {
      _hasScannedBarcode = true;
      _barcodeController.text = scannedCode;
    });

    _searchProduct();
  }

  Future<void> _searchProduct() async {
    final barcode = _barcodeController.text.trim();

    if (barcode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a barcode.';
        _hasScannedBarcode = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ProductModel? product =
          await _service.fetchProductByBarcode(barcode);

      if (!mounted) return;

      if (product == null) {
        setState(() {
          _errorMessage = 'Product not found in Open Food Facts.';
          _hasScannedBarcode = false;
        });
        return;
      }

      ProductStorageService.addToHistory(product);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductResultScreen(product: product),
        ),
      );

      if (mounted) {
        setState(() {
          _hasScannedBarcode = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _hasScannedBarcode = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031F13),
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: const Color(0xFF031F13),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF24C676),
                        width: 2,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: _scannerController,
                          onDetect: _handleBarcodeDetection,
                        ),
                        const Center(
                          child: SizedBox(
                            width: 190,
                            height: 110,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFF24C676),
                                    width: 3,
                                  ),
                                  bottom: BorderSide(
                                    color: Color(0xFF24C676),
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 36,
                          right: 36,
                          top: 128,
                          child: Divider(
                            color: Color(0xFF24C676),
                            thickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Text(
                'Point your camera at a food barcode.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can also type a barcode manually for testing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFBDE8CE)),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _barcodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Barcode',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 14),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFFFC1C1)),
                ),
                const SizedBox(height: 14),
              ],
              FilledButton.icon(
                onPressed: _isLoading ? null : _searchProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Searching...' : 'Find Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
