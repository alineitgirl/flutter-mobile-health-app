import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ai_food_scanner.dart';

enum ScanMode { barcode, aiFood }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  ScanMode _scanMode = ScanMode.barcode;

  bool _isScanning = true;
  bool _isTorchOn = false;
  bool _isLoading = false;
  bool _showProductDetail = false;
  String? _lastScannedCode;
  Map<String, dynamic>? _productData;
  String? _errorMessage;

  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: -130, end: 130).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _switchMode(ScanMode mode) async {
    if (_scanMode == mode) return;
    setState(() {
      _scanMode = mode;
      _isScanning = true;
      _productData = null;
      _errorMessage = null;
    });

    if (mode == ScanMode.aiFood) {
      await _cameraController.stop();
      _lineController.stop();
    } else {
      _lineController.repeat(reverse: true);
      await _cameraController.start();
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
      _lastScannedCode = code;
      _errorMessage = null;
      _productData = null;
    });
    _lineController.stop();
    await _cameraController.stop();
    await _fetchProduct(code);
  }

  Future<void> _fetchProduct(String barcode) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1) {
          setState(() {
            _productData = data['product'] as Map<String, dynamic>;
            _isLoading = false;
          });
          return;
        }
      }
      setState(() { _productData = null; _isLoading = false; });
    } catch (_) {
      setState(() {
        _errorMessage = 'Ошибка загрузки. Проверьте интернет.';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetScanner() async {
    setState(() {
      _isScanning = true;
      _isLoading = false;
      _lastScannedCode = null;
      _productData = null;
      _errorMessage = null;
      _showProductDetail = false;
    });
    _lineController.repeat(reverse: true);
    await _cameraController.start();
  }

  void _toggleTorch() {
    _cameraController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  String get _productName {
    if (_productData == null) return 'Неизвестный продукт';
    return (_productData!['product_name_ru'] as String?)
                ?.trim()
                .isNotEmpty ==
            true
        ? _productData!['product_name_ru'] as String
        : (_productData!['product_name'] as String?) ?? 'Без названия';
  }

  String get _brandName => (_productData?['brands'] as String?) ?? '';
  String? get _imageUrl =>
      _productData?['image_front_small_url'] as String?;

  String _nutriment(String key) {
    final val = _productData?['nutriments']?['${key}_100g'];
    if (val == null) return '—';
    final n = (val as num).toDouble();
    return n == n.truncate()
        ? '${n.toInt()} г'
        : '${n.toStringAsFixed(1)} г';
  }

  String get _calories {
    final val = _productData?['nutriments']?['energy-kcal_100g'];
    if (val == null) return '—';
    return '${(val as num).toInt()} ккал/100г';
  }

  String get _caloriesShort {
    final val = _productData?['nutriments']?['energy-kcal_100g'];
    if (val == null) return '—';
    return '${(val as num).toInt()} ккал';
  }

  String get _ingredientsText =>
      (_productData?['ingredients_text_ru'] as String?) ??
      (_productData?['ingredients_text'] as String?) ??
      '';

  String get _nutriScore =>
      (_productData?['nutriscore_grade'] as String?)?.toUpperCase() ?? '';

  Color get _nutriScoreColor {
    switch (_nutriScore) {
      case 'A': return const Color(0xFF1B8A42);
      case 'B': return const Color(0xFF56AA1C);
      case 'C': return const Color(0xFFEFAC00);
      case 'D': return const Color(0xFFE07420);
      case 'E': return const Color(0xFFDA1C22);
      default:  return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: (_isScanning || _scanMode == ScanMode.aiFood)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                if (_scanMode == ScanMode.barcode)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: _toggleTorch,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isTorchOn
                              ? Colors.yellow.withAlpha(60)
                              : Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isTorchOn
                              ? Icons.flash_on
                              : Icons.flash_on_outlined,
                          color: _isTorchOn ? Colors.yellow : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
      body: Stack(
        children: [
          if (_scanMode == ScanMode.barcode) ...[
            if (_isScanning)
              _buildBarcodeView()
            else if (_isLoading)
              _buildLoadingView()
            else
              _buildResultsView(),
          ] else
            AiFoodScanner(
              onSwitchMode: () => _switchMode(ScanMode.barcode),
            ),

          if (_showProductDetail) _buildProductDetailModal(),
        ],
      ),
    );
  }

  Widget _buildBarcodeView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: _onBarcodeDetected,
          errorBuilder: (context, error) => Center(
            child: Text(
              _cameraErrorMessage(error),
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        _buildScannerOverlay(),

        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              children: [
                ..._buildCorners(),
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _lineAnimation.value),
                    child: Center(
                      child: Container(
                        height: 2.5,
                        width: 250,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Colors.transparent,
                            Colors.cyanAccent,
                            Colors.transparent,
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.cyan.withAlpha(100),
                                blurRadius: 8)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 160,
          left: 0, right: 0,
          child: Column(children: [
            const Text('Наведите на штрих-код',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('EAN-8, EAN-13, QR',
                style:
                    TextStyle(color: Colors.white.withAlpha(160), fontSize: 13),
                textAlign: TextAlign.center),
          ]),
        ),

        Positioned(
          bottom: 48,
          left: 24, right: 24,
          child: _buildModeToggle(),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF2E7D32), strokeWidth: 3),
            const SizedBox(height: 24),
            Text('Ищем продукт...',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withAlpha(180))),
            const SizedBox(height: 8),
            Text(_lastScannedCode ?? '',
                style: TextStyle(
                    fontSize: 13, color: Colors.black.withAlpha(100))),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final notFound = _productData == null;
    final hasError = _errorMessage != null;

    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: GestureDetector(
              onTap: _resetScanner,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 18),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: hasError
                          ? Colors.red.withAlpha(25)
                          : notFound
                              ? Colors.orange.withAlpha(25)
                              : const Color(0xFF81C784).withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      hasError
                          ? Icons.wifi_off_rounded
                          : notFound
                              ? Icons.search_off_rounded
                              : Icons.check_rounded,
                      color: hasError
                          ? Colors.red
                          : notFound
                              ? Colors.orange
                              : const Color(0xFF81C784),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasError
                        ? 'Ошибка загрузки'
                        : notFound
                            ? 'Продукт не найден'
                            : 'Штрихкод распознан',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.5),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 12),
                    Text(_errorMessage!,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withAlpha(128)),
                        textAlign: TextAlign.center),
                  ],
                  if (notFound && !hasError) ...[
                    const SizedBox(height: 8),
                    Text('Код: ${_lastScannedCode ?? '—'}',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withAlpha(100))),
                    const SizedBox(height: 12),
                    Text(
                      'Продукт не найден в базе Open Food Facts',
                      style: TextStyle(
                          fontSize: 14, color: Colors.black.withAlpha(128)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),

                  if (!notFound && !hasError)
                    GestureDetector(
                      onTap: () => setState(() => _showProductDetail = true),
                      child: _ProductCard(
                        productName: _productName,
                        brandName: _brandName,
                        imageUrl: _imageUrl,
                        lastScannedCode: _lastScannedCode,
                        nutriScore: _nutriScore,
                        nutriScoreColor: _nutriScoreColor,
                        calories: _calories,
                        proteins: _nutriment('proteins'),
                        fat: _nutriment('fat'),
                        carbohydrates: _nutriment('carbohydrates'),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                if (!notFound && !hasError) ...[
                  _ActionButton(
                    label: 'Добавить в избранное',
                    color: const Color(0xFF2E7D32),
                    textColor: Colors.white,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                ],
                _ActionButton(
                  label: 'Сканировать ещё',
                  color: Colors.grey.shade200,
                  textColor: Colors.black,
                  onTap: _resetScanner,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailModal() {
    return GestureDetector(
      onTap: () => setState(() => _showProductDetail = false),
      child: Container(
        color: Colors.black.withAlpha(120),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Подробно о продукте',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showProductDetail = false),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _ProductDetailContent(
                        productName: _productName,
                        brandName: _brandName,
                        imageUrl: _imageUrl,
                        lastScannedCode: _lastScannedCode,
                        nutriScore: _nutriScore,
                        nutriScoreColor: _nutriScoreColor,
                        caloriesShort: _caloriesShort,
                        proteins: _nutriment('proteins'),
                        fat: _nutriment('fat'),
                        carbohydrates: _nutriment('carbohydrates'),
                        ingredientsText: _ingredientsText,
                        onFavorite: () =>
                            setState(() => _showProductDetail = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildModeToggle() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Штрихкод',
            icon: Icons.qr_code_scanner,
            active: _scanMode == ScanMode.barcode,
            activeColor: Colors.cyanAccent,
            onTap: () => _switchMode(ScanMode.barcode),
          ),
          _ModeButton(
            label: 'AI еда',
            icon: Icons.auto_awesome,
            active: _scanMode == ScanMode.aiFood,
            activeColor: Colors.orangeAccent,
            onTap: () => _switchMode(ScanMode.aiFood),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(builder: (context, constraints) {
      const holeW = 280.0, holeH = 280.0;
      final cx = (constraints.maxWidth - holeW) / 2;
      final cy = (constraints.maxHeight - holeH) / 2;
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _OverlayPainter(
            holeRect: Rect.fromLTWH(cx, cy, holeW, holeH)),
      );
    });
  }

  List<Widget> _buildCorners() {
    const len = 28.0, thick = 3.0;
    const color = Colors.cyanAccent;
    return [
      Positioned(top: 0, left: 0,   child: _Corner(len: len, thick: thick, color: color, top: true,  left: true)),
      Positioned(top: 0, right: 0,  child: _Corner(len: len, thick: thick, color: color, top: true,  left: false)),
      Positioned(bottom: 0, left: 0,  child: _Corner(len: len, thick: thick, color: color, top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _Corner(len: len, thick: thick, color: color, top: false, left: false)),
    ];
  }

  String _cameraErrorMessage(MobileScannerException error) {
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      return 'Нет доступа к камере.\nРазрешите в настройках.';
    }
    return 'Не удалось запустить камеру.';
  }
}


class _ProductCard extends StatelessWidget {
  final String productName, brandName;
  final String? imageUrl, lastScannedCode;
  final String nutriScore, calories, proteins, fat, carbohydrates;
  final Color nutriScoreColor;

  const _ProductCard({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.lastScannedCode,
    required this.nutriScore,
    required this.nutriScoreColor,
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbohydrates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null
                    ? Image.network(imageUrl!,
                        width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ProductIcon())
                    : _ProductIcon(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (brandName.isNotEmpty)
                      Text(brandName,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withAlpha(128))),
                    Text('Код: ${lastScannedCode ?? '—'}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withAlpha(90))),
                  ],
                ),
              ),
              if (nutriScore.isNotEmpty)
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: nutriScoreColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(nutriScore,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow('Калории', calories, Icons.local_fire_department_outlined),
          const SizedBox(height: 12),
          _InfoRow('Белки', proteins, Icons.fitness_center_outlined),
          const SizedBox(height: 12),
          _InfoRow('Жиры', fat, Icons.opacity_outlined),
          const SizedBox(height: 12),
          _InfoRow('Углеводы', carbohydrates, Icons.grain_outlined),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Подробнее →',
                  style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final String productName, brandName;
  final String? imageUrl, lastScannedCode;
  final String nutriScore, caloriesShort, proteins, fat, carbohydrates,
      ingredientsText;
  final Color nutriScoreColor;
  final VoidCallback onFavorite;

  const _ProductDetailContent({
    required this.productName,
    required this.brandName,
    required this.imageUrl,
    required this.lastScannedCode,
    required this.nutriScore,
    required this.nutriScoreColor,
    required this.caloriesShort,
    required this.proteins,
    required this.fat,
    required this.carbohydrates,
    required this.ingredientsText,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl != null
                ? Image.network(imageUrl!,
                    width: 64, height: 64, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ProductIcon(size: 64))
                : _ProductIcon(size: 64),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                if (brandName.isNotEmpty)
                  Text(brandName,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withAlpha(140))),
                Text('Код: ${lastScannedCode ?? '—'}',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black.withAlpha(100))),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 24),

        if (nutriScore.isNotEmpty) ...[
          Text('Nutri-Score',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withAlpha(160))),
          const SizedBox(height: 10),
          Row(
            children: ['A', 'B', 'C', 'D', 'E'].map((g) {
              final colors = {
                'A': const Color(0xFF1B8A42),
                'B': const Color(0xFF56AA1C),
                'C': const Color(0xFFEFAC00),
                'D': const Color(0xFFE07420),
                'E': const Color(0xFFDA1C22),
              };
              final isActive = g == nutriScore;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: g == 'E' ? 0 : 4),
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors[g]
                        : colors[g]!.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(g,
                        style: TextStyle(
                            color: isActive ? Colors.white : colors[g],
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w500,
                            fontSize: 15)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        Text('Пищевая ценность (на 100г)',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black.withAlpha(160))),
        const SizedBox(height: 12),
        _DetailInfoRow('Калории', caloriesShort,
            Icons.local_fire_department_outlined),
        const SizedBox(height: 8),
        _DetailInfoRow('Белки', proteins, Icons.fitness_center_outlined),
        const SizedBox(height: 8),
        _DetailInfoRow('Жиры', fat, Icons.opacity_outlined),
        const SizedBox(height: 8),
        _DetailInfoRow('Углеводы', carbohydrates, Icons.grain_outlined),

        if (ingredientsText.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Состав',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withAlpha(160))),
          const SizedBox(height: 8),
          Text(ingredientsText,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withAlpha(180),
                  height: 1.5)),
        ],
        const SizedBox(height: 28),
        _ActionButton(
          label: 'Добавить в избранное',
          color: const Color(0xFF2E7D32),
          textColor: Colors.white,
          onTap: onFavorite,
        ),
      ],
    );
  }
}


class _ProductIcon extends StatelessWidget {
  final double size;
  const _ProductIcon({this.size = 56});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        color: Colors.grey.shade100,
        child: Icon(Icons.image_not_supported_outlined,
            color: Colors.grey.shade400, size: size * 0.45),
      );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: Colors.black.withAlpha(128)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withAlpha(128))),
          ]),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
        ],
      );
}

class _DetailInfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _DetailInfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ]),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32))),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color, textColor;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label,
      required this.color,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3)),
          ),
        ),
      );
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _ModeButton(
      {required this.label,
      required this.icon,
      required this.active,
      required this.activeColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: active ? activeColor.withAlpha(30) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: active
                  ? Border.all(color: activeColor.withAlpha(120))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18,
                    color: active
                        ? activeColor
                        : Colors.white.withAlpha(160)),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: active
                            ? activeColor
                            : Colors.white.withAlpha(160))),
              ],
            ),
          ),
        ),
      );
}


class _OverlayPainter extends CustomPainter {
  final Rect holeRect;
  _OverlayPainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(140);
    final full = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(
          RRect.fromRectAndRadius(holeRect, const Radius.circular(20)));
    canvas.drawPath(
        Path.combine(PathOperation.difference, full, hole), paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.holeRect != holeRect;
}

class _Corner extends StatelessWidget {
  final double len, thick;
  final Color color;
  final bool top, left;
  const _Corner(
      {required this.len,
      required this.thick,
      required this.color,
      required this.top,
      required this.left});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: len,
      height: len,
      child: CustomPaint(
          painter: _CornerPainter(thick, color, top, left)));
}

class _CornerPainter extends CustomPainter {
  final double thick;
  final Color color;
  final bool top, left;
  _CornerPainter(this.thick, this.color, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final dx = left ? 0.0 : size.width;
    final dy = top ? 0.0 : size.height;
    canvas.drawLine(Offset(dx, dy),
        Offset(dx + (left ? size.width : -size.width), dy), p);
    canvas.drawLine(Offset(dx, dy),
        Offset(dx, dy + (top ? size.height : -size.height)), p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}