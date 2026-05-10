import 'package:flutter/material.dart';

/// An animated floating text widget that shows score earned and combo milestones.
/// It floats upward and fades out over ~800ms.
class FloatingScoreText extends StatefulWidget {
  final int scoreEarned;
  final int comboCount;
  final int multiplier;
  final Offset position;
  final VoidCallback onComplete;

  const FloatingScoreText({
    super.key,
    required this.scoreEarned,
    required this.comboCount,
    required this.multiplier,
    required this.position,
    required this.onComplete,
  });

  @override
  State<FloatingScoreText> createState() => _FloatingScoreTextState();
}

class _FloatingScoreTextState extends State<FloatingScoreText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _moveAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1.0)),
    );

    _moveAnim = Tween<double>(begin: 0.0, end: -80.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
// build method
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 40,
          top: widget.position.dy + _moveAnim.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _fadeAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Score text
                      Text(
                        '+${widget.scoreEarned}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.multiplier >= 3 ? 28 : 22,
                          fontWeight: FontWeight.w900,
                          color: _getScoreColor(),
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: _getScoreColor().withOpacity(0.6),
                              offset: const Offset(0, 2),
                            ),
                            const Shadow(
                              blurRadius: 4,
                              color: Colors.black54,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      // Combo milestone text
                      if (widget.comboCount >= 5)
                        Text(
                          _getComboText(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _getComboColor(),
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: _getComboColor().withOpacity(0.5),
                                offset: const Offset(0, 1),
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
        );
      },
    );
  }
// color method
  Color _getScoreColor() {
    if (widget.multiplier >= 4) return const Color(0xFFFF4444); // Red hot
    if (widget.multiplier >= 3) return const Color(0xFFFF8800); // Orange fire
    if (widget.multiplier >= 2) return const Color(0xFFFFD700); // Gold
    return Colors.white;
  }
// combo color method
  Color _getComboColor() {
    if (widget.comboCount >= 15) return const Color(0xFFFF4444);
    if (widget.comboCount >= 10) return const Color(0xFFFF8800);
    return const Color(0xFFFFD700);
  }
// combo text method
  String _getComboText() {
    if (widget.comboCount >= 15) return '🔥 ON FIRE!';
    if (widget.comboCount >= 10) return '⚡ UNSTOPPABLE!';
    if (widget.comboCount >= 5) return 'COMBO x${widget.comboCount}!';
    return '';
  }
}
