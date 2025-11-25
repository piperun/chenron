import "package:flutter/material.dart";

class ExpandableField extends StatefulWidget {
  final String description;

  const ExpandableField({super.key, required this.description});

  @override
  State<ExpandableField> createState() => _ExpandableFieldState();
}

class _ExpandableFieldState extends State<ExpandableField> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final maxWidth = constraints.maxWidth;
        final textStyle = Theme.of(context).textTheme.bodyMedium;
        final textSpan = TextSpan(text: widget.description, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: 2,
        );
        textPainter.layout(maxWidth: maxWidth);

        final isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AnimatedCrossFade(
                  firstChild: Text(
                    widget.description,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                  secondChild: Text(widget.description),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (!_expanded && isTextOverflowing)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.5),
                              Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.7),
                            ],
                            stops: const [
                              0.0,
                              0.5,
                              1.0
                            ]),
                      ),
                    ),
                  ),
              ],
            ),
            if (isTextOverflowing)
              Center(
                child: IconButton(
                  icon: Icon(_expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

