import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  // ── Контроллер камеры ─────────────────────────────────────────────────────
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  // ── Состояние ─────────────────────────────────────────────────────────────
  bool _isScanning = true;
  bool _isTorchOn = false;
  bool _isLoading = false;
  bool _showProductDetail = false;
  String? _lastScannedCode;
  Map<String, dynamic>? _productData;
  String? _errorMessage;

  // ── Анимация сканирующей линии ────────────────────────────────────────────
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

  // ── Обработка обнаруженного штрих-кода ───────────────────────────────────
  void _onBarcodeDetected(BarcodeCapture capture) async {
    // Если уже обрабатываем — игнорируем
    if (!_isScanning || _isLoading) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;
    if (code == null || code.isEmpty) return;

    // Останавливаем сканирование
    setState(() {
      _isScanning = false;
      _isLoading = true;
      _lastScannedCode = code;
      _errorMessage = null;
      _productData = null;
    });
    _lineController.stop();
    await _cameraController.stop();

    // Запрашиваем данные о продукте
    await _fetchProduct(code);
  }

  // ── Запрос к Open Food Facts ──────────────────────────────────────────────
  Future<void> _fetchProduct(String barcode) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

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
      // Продукт не найден — показываем экран с заглушкой
      setState(() {
        _productData = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки. Проверьте интернет-соединение.';
        _isLoading = false;
      });
    }
  }

  // ── Вернуться к сканированию ──────────────────────────────────────────────
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

  // ── Переключить фонарик ───────────────────────────────────────────────────
  void _toggleTorch() {
    _cameraController.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  // ── Геттеры данных из Open Food Facts ────────────────────────────────────
  String get _productName {
    if (_productData == null) return 'Неизвестный продукт';
    return (_productData!['product_name_ru'] as String?)?.trim().isNotEmpty == true
        ? _productData!['product_name_ru'] as String
        : (_productData!['product_name'] as String?) ?? 'Без названия';
  }

  String get _brandName {
    return (_productData?['brands'] as String?) ?? '';
  }

  String? get _imageUrl => _productData?['image_front_small_url'] as String?;

  String _nutriment(String key) {
    final val = _productData?['nutriments']?['${key}_100g'];
    if (val == null) return '—';
    final num = (val).toDouble();
    return num == num.truncate() ? '${num.toInt()} г' : '${num.toStringAsFixed(1)} г';
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

  String get _ingredients {
    return (_productData?['ingredients_text_ru'] as String?) ??
        (_productData?['ingredients_text'] as String?) ??
        '';
  }

  String get _nutriScore {
    return (_productData?['nutriscore_grade'] as String?)?.toUpperCase() ?? '';
  }

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

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isScanning
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
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
          // Основной контент
          if (_isScanning)
            _buildScannerView()
          else if (_isLoading)
            _buildLoadingView()
          else
            _buildResultsView(),

          // Модальное окно с деталями
          if (_showProductDetail) _buildProductDetailModal(),
        ],
      ),
    );
  }

  // ── Экран камеры ──────────────────────────────────────────────────────────
  Widget _buildScannerView() {
    return Stack(
      children: [
        // Реальная камера
        MobileScanner(
          controller: _cameraController,
          onDetect: _onBarcodeDetected,
          errorBuilder: (context, error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _cameraErrorMessage(error),
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),

        // Тёмный оверлей (кроме зоны сканирования)
        _buildScannerOverlay(),

        // Рамка сканирования
        Center(
          child: SizedBox(
            width: 280,
            height: 350,
            child: Stack(
              children: [
                // Угловые уголки
                ..._buildCorners(),

                // Анимированная линия сканирования
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, _) {
                    return Transform.translate(
                      offset: Offset(0, _lineAnimation.value),
                      child: Center(
                        child: Container(
                          height: 2.5,
                          width: 250,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.cyanAccent,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withAlpha(100),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Подсказка
        Positioned(
          bottom: 140,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                'Наведите на штрих-код',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Поддерживаются EAN-8, EAN-13, QR',
                style: TextStyle(
                  color: Colors.white.withAlpha(160),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Тёмный оверлей с вырезом
  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const holeW = 280.0;
        const holeH = 350.0;
        final cx = (constraints.maxWidth - holeW) / 2;
        final cy = (constraints.maxHeight - holeH) / 2;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _OverlayPainter(
            holeRect: Rect.fromLTWH(cx, cy, holeW, holeH),
          ),
        );
      },
    );
  }

  // Угловые уголки рамки
  List<Widget> _buildCorners() {
    const len = 28.0;
    const thick = 3.0;
    const color = Colors.cyanAccent;

    return [
      // Левый верх
      const Positioned(top: 0, left: 0, child: _Corner(len: len, thick: thick, color: color, top: true, left: true)),
      // Правый верх
      const Positioned(top: 0, right: 0, child: _Corner(len: len, thick: thick, color: color, top: true, left: false)),
      // Левый низ
      const Positioned(bottom: 0, left: 0, child: _Corner(len: len, thick: thick, color: color, top: false, left: true)),
      // Правый низ
      const Positioned(bottom: 0, right: 0, child: _Corner(len: len, thick: thick, color: color, top: false, left: false)),
    ];
  }

  String _cameraErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Нет доступа к камере.\nРазрешите в настройках.';
      default:
        return 'Не удалось запустить камеру.\n${error.errorDetails?.message ?? ''}';
    }
  }

  // ── Экран загрузки ────────────────────────────────────────────────────────
  Widget _buildLoadingView() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF2E7D32),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Ищем продукт...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withAlpha(180),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _lastScannedCode ?? '',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Экран результатов ─────────────────────────────────────────────────────
  Widget _buildResultsView() {
    final notFound = _productData == null;
    final hasError = _errorMessage != null;

    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _resetScanner,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox.shrink(),
              ],
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

                  // Иконка статуса
                  Container(
                    width: 60,
                    height: 60,
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
                      letterSpacing: -0.5,
                    ),
                  ),

                  if (hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withAlpha(128),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  if (notFound && !hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Код: ${_lastScannedCode ?? '—'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withAlpha(100),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Этот продукт пока не добавлен в базу данных Open Food Facts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withAlpha(128),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Карточка продукта (только если найден)
                  if (!notFound && !hasError)
                    GestureDetector(
                      onTap: () => setState(() => _showProductDetail = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Фото продукта или заглушка
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _imageUrl != null
                                      ? Image.network(
                                          _imageUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _productIcon(),
                                        )
                                      : _productIcon(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _productName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (_brandName.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _brandName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors.black.withAlpha(128),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        'Код: ${_lastScannedCode ?? '—'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors.black.withAlpha(90),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Nutri-Score badge
                                if (_nutriScore.isNotEmpty)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _nutriScoreColor,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _nutriScore,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow('Калории', _calories,
                                Icons.local_fire_department_outlined),
                            const SizedBox(height: 12),
                            _buildInfoRow('Белки', _nutriment('proteins'),
                                Icons.fitness_center_outlined),
                            const SizedBox(height: 12),
                            _buildInfoRow('Жиры', _nutriment('fat'),
                                Icons.opacity_outlined),
                            const SizedBox(height: 12),
                            _buildInfoRow('Углеводы',
                                _nutriment('carbohydrates'),
                                Icons.grain_outlined),
                            const SizedBox(height: 12),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Подробнее →',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Кнопки действий
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                if (!notFound && !hasError) ...[
                  GestureDetector(
                    onTap: () {
                      // TODO: добавить в избранное
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Добавить в избранное',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                GestureDetector(
                  onTap: _resetScanner,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Сканировать ещё',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Модальное окно с деталями ─────────────────────────────────────────────
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
                      offset: const Offset(0, 8),
                    ),
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
                          const Text(
                            'Подробно о продукте',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.4,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showProductDetail = false),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.black, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Шапка продукта
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: _imageUrl != null
                                    ? Image.network(
                                        _imageUrl!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _productIcon(size: 64),
                                      )
                                    : _productIcon(size: 64),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _productName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    if (_brandName.isNotEmpty)
                                      Text(
                                        _brandName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black.withAlpha(140),
                                        ),
                                      ),
                                    Text(
                                      'Код: ${_lastScannedCode ?? '—'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withAlpha(100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Nutri-Score
                          if (_nutriScore.isNotEmpty) ...[
                            Text(
                              'Nutri-Score',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withAlpha(160),
                              ),
                            ),
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
                                final isActive = g == _nutriScore;
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: g == 'E' ? 0 : 4),
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? colors[g]
                                          : colors[g]!.withAlpha(40),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        g,
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.white
                                              : colors[g],
                                          fontWeight: isActive
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Пищевая ценность
                          Text(
                            'Пищевая ценность (на 100г)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withAlpha(160),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailedInfoRow('Калории', _caloriesShort,
                              Icons.local_fire_department_outlined),
                          const SizedBox(height: 8),
                          _buildDetailedInfoRow('Белки',
                              _nutriment('proteins'),
                              Icons.fitness_center_outlined),
                          const SizedBox(height: 8),
                          _buildDetailedInfoRow('Жиры', _nutriment('fat'),
                              Icons.opacity_outlined),
                          const SizedBox(height: 8),
                          _buildDetailedInfoRow('Углеводы',
                              _nutriment('carbohydrates'),
                              Icons.grain_outlined),

                          // Состав
                          if (_ingredients.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Состав',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withAlpha(160),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _ingredients,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black.withAlpha(180),
                                height: 1.5,
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showProductDetail = false),
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'Добавить в избранное',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  // ── Вспомогательные виджеты ───────────────────────────────────────────────
  Widget _productIcon({double size = 56}) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey.shade100,
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.grey.shade400, size: size * 0.45),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black.withAlpha(128)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black.withAlpha(128),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedInfoRow(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Тёмный оверлей с прозрачным вырезом для камеры ───────────────────────────
class _OverlayPainter extends CustomPainter {
  final Rect holeRect;
  _OverlayPainter({required this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withAlpha(140);
    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(20)));
    final combined =
        Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.holeRect != holeRect;
}

// ── Угловые уголки рамки ──────────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final double len;
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  const _Corner({
    required this.len,
    required this.thick,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(painter: _CornerPainter(thick, color, top, left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  _CornerPainter(this.thick, this.color, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dx = left ? 0.0 : size.width;
    final dy = top ? 0.0 : size.height;
    final hDir = left ? size.width : -size.width;
    final vDir = top ? size.height : -size.height;

    canvas.drawLine(Offset(dx, dy), Offset(dx + hDir, dy), paint);
    canvas.drawLine(Offset(dx, dy), Offset(dx, dy + vDir), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}