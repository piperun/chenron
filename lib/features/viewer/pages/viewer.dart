import "package:chenron/features/viewer/state/viewer_state.dart";
import "package:chenron/features/viewer/ui/viewer_content.dart";
import "package:flutter/material.dart";
import "package:chenron/features/viewer/ui/viewer_header.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:signals/signals_flutter.dart";

enum ViewLayout { list, grid }

class Viewer extends HookWidget {
  const Viewer({super.key});

  @override
  Widget build(BuildContext context) {
    final presenter = viewerViewModelSignal.value;

    useEffect(() {
      presenter.init();
      return null;
    }, []);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Watch((context) {
                return const ViewerHeader();
              }),
              const SizedBox(height: 8),
              const Expanded(
                child: ViewerContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
