import 'package:flutter/material.dart';
import 'dart:math';

class CaptchaWidget extends StatefulWidget {
  final Function(bool) onCaptchaVerified;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final bool initialVerifiedState;

  const CaptchaWidget({
    Key? key,
    required this.onCaptchaVerified,
    this.primaryColor = const Color(0xFF4AC959),
    this.backgroundColor = const Color(0xFF212121),
    this.textColor = Colors.white,
    this.initialVerifiedState = false,
  }) : super(key: key);

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  final TextEditingController _captchaController = TextEditingController();
  String _captchaText = '';
  late bool _isVerified;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _isVerified = widget.initialVerifiedState;
    _generateCaptcha();
  }


  @override
  void dispose() {
    _captchaController.dispose();
    super.dispose();
  }

  void _generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _captchaText = String.fromCharCodes(
      Iterable.generate(
          5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    setState(() {
      _isVerified = false;
      _errorMessage = '';
      _captchaController.clear();
    });
    widget.onCaptchaVerified(false);
  }

  void _verifyCaptcha() {
    final userInput = _captchaController.text.toUpperCase().trim();
    if (userInput == _captchaText) {
      setState(() {
        _isVerified = true;
        _errorMessage = '';
      });
      widget.onCaptchaVerified(true);
    } else {
      setState(() {
        _isVerified = false;
        _errorMessage = 'Incorrect captcha. Please try again.';
      });
      widget.onCaptchaVerified(false);
      _generateCaptcha();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isVerified ? widget.primaryColor : Colors.grey[600]!,
          width: _isVerified ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Security Verification',
            style: TextStyle(
              color: widget.textColor,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Captcha display
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: CustomPaint(
                    size: const Size(double.infinity, 40),
                    painter: CaptchaPainter(_captchaText),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _generateCaptcha,
                icon: Icon(
                  Icons.refresh,
                  color: widget.primaryColor,
                  size: isSmallScreen ? 20 : 24,
                ),
                tooltip: 'Generate new captcha',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Input field
          TextField(
            controller: _captchaController,
            style: TextStyle(
              color: widget.textColor,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter captcha code',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isSmallScreen ? 12 : 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: true,
              fillColor: Colors.grey[850]!.withOpacity(0.5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              suffixIcon: _isVerified
                  ? Icon(Icons.check_circle, color: widget.primaryColor)
                  : null,
            ),
            onSubmitted: (_) => _verifyCaptcha(),
            textCapitalization: TextCapitalization.characters,
          ),

          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _captchaController.text.isNotEmpty && !_isVerified
                  ? _verifyCaptcha
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isVerified ? widget.primaryColor : Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isVerified ? 'Verified ✓' : 'Verify Captcha',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaptchaPainter extends CustomPainter {
  final String text;

  CaptchaPainter(this.text);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    // Draw background noise lines
    final noisePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        noisePaint,
      );
    }

    // Draw noise dots
    final dotPaint = Paint()..color = Colors.grey[500]!;
    for (int i = 0; i < 50; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width,
            random.nextDouble() * size.height),
        1.0, // Fixed: Changed from 1 (int) to 1.0 (double)
        dotPaint,
      );
    }

    // Draw captcha text
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final charWidth = size.width / text.length;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final colors = [
        Colors.black,
        Colors.blue[800]!,
        Colors.red[800]!,
        Colors.green[800]!
      ];
      final color = colors[random.nextInt(colors.length)];

      textPainter.text = TextSpan(
        text: char,
        style: TextStyle(
          color: color,
          fontSize:
              20 + random.nextInt(6).toDouble(), // Fixed: Added .toDouble()
          fontWeight: FontWeight.bold,
          fontFamily: random.nextBool() ? 'monospace' : null,
        ),
      );

      textPainter.layout();

      final xOffset = i * charWidth + (charWidth - textPainter.width) / 2;
      final yOffset = (size.height - textPainter.height) / 2 +
          (random.nextDouble() - 0.5) * 8;

      canvas.save();
      canvas.translate(
          xOffset + textPainter.width / 2, yOffset + textPainter.height / 2);
      canvas.rotate((random.nextDouble() - 0.5) * 0.3);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);

      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
