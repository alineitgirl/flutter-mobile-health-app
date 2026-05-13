import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class FoodLabel {
  final String name;
  final double confidence;
  const FoodLabel(this.name, this.confidence);
}

const _translations = {
  'Food': 'Еда', 'Fruit': 'Фрукт', 'Vegetable': 'Овощ',
  'Meat': 'Мясо', 'Fish': 'Рыба', 'Bread': 'Хлеб',
  'Cheese': 'Сыр', 'Pizza': 'Пицца', 'Burger': 'Бургер',
  'Salad': 'Салат', 'Soup': 'Суп', 'Cake': 'Торт',
  'Cookie': 'Печенье', 'Drink': 'Напиток', 'Juice': 'Сок',
  'Milk': 'Молоко', 'Egg': 'Яйцо', 'Rice': 'Рис',
  'Pasta': 'Паста', 'Chicken': 'Курица', 'Beef': 'Говядина',
  'Pork': 'Свинина', 'Apple': 'Яблоко', 'Banana': 'Банан',
  'Orange': 'Апельсин', 'Tomato': 'Томат', 'Potato': 'Картофель',
  'Broccoli': 'Брокколи', 'Chocolate': 'Шоколад', 'Coffee': 'Кофе',
  'Tea': 'Чай', 'Yogurt': 'Йогурт', 'Snack': 'Снэк',
  'Nut': 'Орехи', 'Berry': 'Ягоды', 'Mushroom': 'Грибы',
};

const _foodKeywords = [
  'food', 'fruit', 'vegetable', 'meat', 'fish', 'bread', 'cheese',
  'pizza', 'burger', 'salad', 'soup', 'cake', 'cookie', 'drink',
  'juice', 'milk', 'egg', 'rice', 'pasta', 'chicken', 'beef',
  'pork', 'apple', 'banana', 'orange', 'tomato', 'potato',
  'broccoli', 'berry', 'mushroom', 'chocolate', 'coffee', 'tea',
  'yogurt', 'snack', 'nut',
];


class AiFoodScanner extends StatefulWidget {
  final VoidCallback onSwitchMode;

  const AiFoodScanner({super.key, required this.onSwitchMode});

  @override
  State<AiFoodScanner> createState() => _AiFoodScannerState();
}

class _AiFoodScannerState extends State<AiFoodScanner> {
  CameraController? _camera;
  bool _cameraReady = false;

  late final ImageLabeler _labeler;

  bool _analyzing = false;
  List<FoodLabel> _labels = [];
  String? _capturePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.55),
    );
    _initCamera();
  }

  @override
  void dispose() {
    _camera?.dispose();
    _labeler.close();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _camera = CameraController(back, ResolutionPreset.high,
          enableAudio: false);
      await _camera!.initialize();

      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Не удалось запустить камеру');
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_camera == null || !_cameraReady || _analyzing) return;

    setState(() {
      _analyzing = true;
      _labels = [];
      _capturePath = null;
      _error = null;
    });

    try {
      final xFile = await _camera!.takePicture();
      setState(() => _capturePath = xFile.path);

      final inputImage = InputImage.fromFilePath(xFile.path);
      final rawLabels = await _labeler.processImage(inputImage);

      var foodLabels = rawLabels
          .where((l) => _foodKeywords
              .any((kw) => l.label.toLowerCase().contains(kw)))
          .map((l) => FoodLabel(l.label, l.confidence))
          .take(5)
          .toList();

      if (foodLabels.isEmpty) {
        foodLabels = rawLabels
            .take(5)
            .map((l) => FoodLabel(l.label, l.confidence))
            .toList();
      }

      setState(() {
        _labels = foodLabels;
        _analyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка анализа изображения';
        _analyzing = false;
      });
    }
  }

  void _reset() => setState(() {
        _labels = [];
        _capturePath = null;
        _error = null;
      });

  String _translate(String label) =>
      _translations[label] ?? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: !_cameraReady
              ? const ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                )
              : _capturePath != null
                  ? Image.file(File(_capturePath!), fit: BoxFit.cover)
                  : CameraPreview(_camera!),
        ),

        if (_analyzing)
          Container(color: Colors.black.withAlpha(100)),

        Positioned(
          top: 80,
          left: 0, right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(130),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      color: Colors.orangeAccent, size: 16),
                  SizedBox(width: 6),
                  Text('AI-распознавание еды',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),

        if (_capturePath == null && !_analyzing)
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.orangeAccent.withAlpha(200), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

        if (_analyzing)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                    color: Colors.orangeAccent, strokeWidth: 2.5),
                SizedBox(height: 16),
                Text('Анализируем...',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),

        if (_labels.isNotEmpty)
          Positioned(
            bottom: 130,
            left: 16, right: 16,
            child: _ResultsPanel(
              labels: _labels,
              translateLabel: _translate,
              onReset: _reset,
            ),
          ),

        if (_error != null && !_analyzing)
          Positioned(
            bottom: 130,
            left: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ),
                GestureDetector(
                  onTap: _reset,
                  child: const Icon(Icons.refresh,
                      color: Colors.white, size: 20),
                ),
              ]),
            ),
          ),

        if (_labels.isEmpty && _error == null && !_analyzing && _cameraReady)
          Positioned(
            bottom: 130,
            left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureAndAnalyze,
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.orangeAccent, width: 3),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orangeAccent.withAlpha(80),
                          blurRadius: 20,
                          spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 32),
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 48,
          left: 24, right: 24,
          child: _ModeToggleBar(onSwitchToBarcode: widget.onSwitchMode),
        ),
      ],
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  final List<FoodLabel> labels;
  final String Function(String) translateLabel;
  final VoidCallback onReset;

  const _ResultsPanel({
    required this.labels,
    required this.translateLabel,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withAlpha(80)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.auto_awesome,
                color: Colors.orangeAccent, size: 18),
            const SizedBox(width: 8),
            const Text('Распознано',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: onReset,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Снова',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ...labels.map((label) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        translateLabel(label.name),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(label.confidence * 100).toInt()}%',
                            style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: label.confidence,
                              backgroundColor:
                                  Colors.white.withAlpha(30),
                              valueColor: const AlwaysStoppedAnimation(
                                  Colors.orangeAccent),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ModeToggleBar extends StatelessWidget {
  final VoidCallback onSwitchToBarcode;
  const _ModeToggleBar({required this.onSwitchToBarcode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onSwitchToBarcode,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        size: 18, color: Colors.white.withAlpha(160)),
                    const SizedBox(width: 6),
                    Text('Штрихкод',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(160))),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.orangeAccent.withAlpha(120)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome,
                      size: 18, color: Colors.orangeAccent),
                  SizedBox(width: 6),
                  Text('AI еда',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.orangeAccent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}