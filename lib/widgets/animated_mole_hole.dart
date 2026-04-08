import 'package:flutter/material.dart';

/// A single hole in the game grid with polished mole/bomb pop-up animations.
///
/// Replaces the old AnimatedPositioned approach with spring-bounce entrance,
/// fast duck-down exit, and a subtle idle wobble while the mole is visible.
class AnimatedMoleHole extends StatefulWidget {
  final bool isMoleActive;
  final bool hasBomb;
  final int gridColumns;
  final VoidCallback onTap;
  final String moleImagePath;
  final bool isOriginalMole;

  const AnimatedMoleHole({
    super.key,
    required this.isMoleActive,
    required this.hasBomb,
    required this.gridColumns,
    required this.onTap,
    required this.moleImagePath,
    required this.isOriginalMole,
  });

  @override
  State<AnimatedMoleHole> createState() => _AnimatedMoleHoleState();
}

class _AnimatedMoleHoleState extends State<AnimatedMoleHole>
    with TickerProviderStateMixin {
  // ── Animation controllers ────────────────────────────────────
  late AnimationController _popController;
  late AnimationController _wobbleController;
  late CurvedAnimation _popCurve;

  bool _isShowing = false;

  // ── Grid-dependent sizing (same logic as old game_screen helpers) ──
  double get _moleSize {
    if (widget.gridColumns == 3) return 170.0;
    if (widget.gridColumns == 4) return 130.0;
    return 100.0;
  }

  double get _visibleTop {
    if (widget.gridColumns == 3) return -25.0;
    if (widget.gridColumns == 4) return -25.0;
    return -15.0;
  }

  double get _bombSize {
    if (widget.gridColumns == 3) return 70.0;
    if (widget.gridColumns == 4) return 55.0;
    return 45.0;
  }

  double get _bombVisibleTop {
    if (widget.gridColumns == 3) return -1.0;
    if (widget.gridColumns == 4) return -1.0;
    return -5.0;
  }

  double get _skinOffset {
    if (widget.gridColumns == 3) return 20.0;
    if (widget.gridColumns == 4) return 15.0;
    return 12.0;
  }

  /// How far down (in pixels) the mole is pushed when fully hidden.
  static const double _hiddenYOffset = 160.0;

  // ── Lifecycle ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),   // pop-up duration
      reverseDuration: const Duration(milliseconds: 200), // duck-down duration
    );

    _popCurve = CurvedAnimation(
      parent: _popController,
      curve: Curves.easeOutBack,   // bouncy overshoot on entrance
      reverseCurve: Curves.easeIn, // fast smooth exit
    );

    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isMoleActive) {
      _showMole();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMoleHole oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isMoleActive && !_isShowing) {
      _showMole();
    } else if (!widget.isMoleActive && _isShowing) {
      _hideMole();
    }
  }

  void _showMole() {
    _isShowing = true;
    _wobbleController.value = 0.5;
    _popController.forward(from: 0.0).then((_) {
      if (mounted && _isShowing) {
        _wobbleController.repeat(reverse: true);
      }
    });
  }

  void _hideMole() {
    _isShowing = false;
    _wobbleController.stop();
    _popController.reverse();
  }

  @override
  void dispose() {
    _popCurve.dispose();
    _popController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isMoleActive ? widget.onTap : null,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          // Hole background
          Image.asset(
            'assets/images/HOLE.png',
            fit: BoxFit.contain,
          ),

          // Animated mole / bomb
          AnimatedBuilder(
            animation: Listenable.merge([_popCurve, _wobbleController]),
            builder: (context, _) {
              final double popVal = _popCurve.value;
              final double wobbleVal = _wobbleController.value; // 0 → 1

              // ── Y translation: hidden → visible ──
              final double yOffset = (1.0 - popVal) * _hiddenYOffset;

              // ── Idle wobble (only while fully popped up) ──
              final bool idling =
                  _isShowing && _popController.status == AnimationStatus.completed;
              final double wobbleRotation =
                  idling ? (wobbleVal - 0.5) * 0.06 : 0.0; // ±1.7°
              final double wobbleY =
                  idling ? (wobbleVal - 0.5) * 4.0 : 0.0;  // ±2 px

              // ── Scale: small → full (easeOutBack already overshoots) ──
              final double scale = (0.7 + popVal * 0.3).clamp(0.0, 1.15);

              // ── Resolve image path & size ──
              final double size;
              final double topPos;
              final String imagePath;

              if (widget.hasBomb) {
                size = _bombSize;
                topPos = _bombVisibleTop;
                imagePath = 'assets/images/bomb.png';
              } else {
                size = widget.isOriginalMole ? _moleSize : _moleSize * 0.60;
                topPos = widget.isOriginalMole
                    ? _visibleTop
                    : _visibleTop + _skinOffset;
                imagePath = widget.moleImagePath;
              }

              return Positioned(
                top: topPos,
                child: Transform.translate(
                  offset: Offset(0, yOffset + wobbleY),
                  child: Transform.rotate(
                    angle: wobbleRotation,
                    child: Transform.scale(
                      scale: scale,
                      child: Image.asset(
                        imagePath,
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
