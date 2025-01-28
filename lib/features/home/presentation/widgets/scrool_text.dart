import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity;
  final Duration pauseDuration; // Duración de la pausa

  const ScrollingText({
    Key? key,
    required this.text,
    this.style,
    this.velocity = 50.0, // Velocidad del desplazamiento
    this.pauseDuration =
        const Duration(seconds: 3), // Pausa inicial y posterior
  }) : super(key: key);

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ScrollController _scrollController;
  double _textWidth = 0.0;
  double _containerWidth = 0.0;
  bool isPaused = true;
  bool needsScrolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 10000),
      vsync: this,
    )
      ..addListener(_scroll)
      ..repeat(); // Repite la animación
    _scrollController = ScrollController();

    // Pausa inicial
    Future.delayed(widget.pauseDuration, () {
      if (mounted) {
        setState(() {
          isPaused =
              false; // Inicia el desplazamiento después de la pausa inicial
        });
      }
    });
  }

  void _scroll() {
    if (isPaused || !needsScrolling) return;

    if (_scrollController.hasClients &&
        _scrollController.offset < _textWidth - _containerWidth) {
      // Mover el texto mientras no llegue al final
      _scrollController
          .jumpTo(_scrollController.offset + widget.velocity / 100);
    } else {
      // Una vez que termina de desplazarse, volver al inicio antes de pausar
      _scrollBackToStart();
    }
  }

  void _scrollBackToStart() async {
    setState(() {
      isPaused = true; // Pausar durante el regreso
    });

    // Volver al inicio suavemente
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    // Esperar a que termine de volver al inicio antes de pausar
    await Future.delayed(Duration(milliseconds: 500));

    // Pausar en la posición inicial
    await Future.delayed(widget.pauseDuration);

    if (mounted) {
      setState(() {
        isPaused = false; // Reanudar después de la pausa
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;

        // Verificar si el texto necesita desplazarse
        needsScrolling = _textWidth > _containerWidth;

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              MeasureSize(
                onChange: (size) => setState(() => _textWidth = size.width),
                child: Text(
                  widget.text,
                  style: widget.style ??
                      TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                ),
              ),
              if (needsScrolling)
                SizedBox(width: _containerWidth), // Espacio para el efecto loop
            ],
          ),
        );
      },
    );
  }
}

class MeasureSize extends StatefulWidget {
  final Widget child;
  final Function(Size size) onChange;

  const MeasureSize({
    Key? key,
    required this.child,
    required this.onChange,
  }) : super(key: key);

  @override
  _MeasureSizeState createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) {
        widget.onChange(size);
      }
    });
    return widget.child;
  }
}
