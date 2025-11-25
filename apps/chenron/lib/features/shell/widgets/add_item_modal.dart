import "package:flutter/material.dart";
import "package:chenron/features/create/folder/pages/create_folder.dart";
import "package:chenron/features/create/link/pages/create_link.dart";

enum ItemType {
  link,
  folder,
  document,
}

/// A modal that allows users to select an item type.
///
/// When used standalone, shows type selector and form.
/// When used with callback, just shows type selector and calls callback.
class AddItemModal extends StatefulWidget {
  final ValueChanged<ItemType>? onTypeSelected;

  const AddItemModal({
    super.key,
    this.onTypeSelected,
  });

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  ItemType? _selectedType;

  void _onTypeSelected(ItemType type) {
    // If callback provided, call it and close modal
    if (widget.onTypeSelected != null) {
      widget.onTypeSelected!(type);
      Navigator.pop(context);
      return;
    }

    // Otherwise, show form in modal (legacy behavior)
    setState(() => _selectedType = type);
  }

  void _onBack() {
    setState(() => _selectedType = null);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 700;
    final isMediumScreen = screenSize.width >= 700 && screenSize.width < 1200;

    // Responsive sizing based on screen width
    double modalWidth;
    double modalHeight;

    if (isSmallScreen) {
      // Small screens: use most of the screen
      modalWidth = screenSize.width * 0.95;
      modalHeight = _selectedType == null
          ? screenSize.height * 0.6
          : screenSize.height * 0.9;
    } else if (isMediumScreen) {
      // Medium screens: balanced sizing
      modalWidth = _selectedType == null ? 500.0 : 700.0;
      modalHeight = _selectedType == null ? 480.0 : screenSize.height * 0.85;
    } else {
      // Large screens: generous sizing
      modalWidth = _selectedType == null ? 500.0 : 900.0;
      modalHeight = _selectedType == null ? 480.0 : screenSize.height * 0.85;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: modalWidth,
        height: modalHeight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _selectedType == null
              ? _TypeSelectorView(
                  key: const ValueKey("selector"),
                  onTypeSelected: _onTypeSelected,
                )
              : _FormWrapperView(
                  key: ValueKey(_selectedType),
                  type: _selectedType!,
                  onBack: _onBack,
                ),
        ),
      ),
    );
  }
}

/// Type selector view - shows cards for Link, Folder, Document
class _TypeSelectorView extends StatelessWidget {
  final ValueChanged<ItemType> onTypeSelected;

  const _TypeSelectorView({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create New",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose what you'd like to add",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Type cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              _TypeCard(
                icon: Icons.link,
                title: "Link",
                subtitle: "Add a link or bookmark",
                onTap: () => onTypeSelected(ItemType.link),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                icon: Icons.folder_outlined,
                title: "Folder",
                subtitle: "Create a new folder",
                onTap: () => onTypeSelected(ItemType.folder),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                icon: Icons.description_outlined,
                title: "Document",
                subtitle: "Upload a document",
                onTap: () => onTypeSelected(ItemType.document),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Footer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ),
      ],
    );
  }
}

/// Individual type card
class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper for the actual form pages
class _FormWrapperView extends StatefulWidget {
  final ItemType type;
  final VoidCallback onBack;

  const _FormWrapperView({
    super.key,
    required this.type,
    required this.onBack,
  });

  @override
  State<_FormWrapperView> createState() => _FormWrapperViewState();
}

class _FormWrapperViewState extends State<_FormWrapperView> {
  VoidCallback? _saveCallback;
  bool _isValid = false;

  void _setSaveCallback(VoidCallback callback) {
    _saveCallback = callback;
  }

  void _setValidationState(bool isValid) {
    setState(() {
      _isValid = isValid;
    });
  }

  void _handleSave() {
    if (_isValid) {
      _saveCallback?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back button and actions
        _FormHeader(
          title: _getTitle(),
          onBack: widget.onBack,
          onSave: _handleSave,
          onCancel: () => Navigator.pop(context),
          isSaveEnabled: _isValid,
        ),

        // Form content - takes remaining space
        Expanded(
          child: ClipRect(
            child: _FormContent(
              type: widget.type,
              onSaveCallbackReady: _setSaveCallback,
              onValidationChanged: _setValidationState,
            ),
          ),
        ),
      ],
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case ItemType.link:
        return "Add Link";
      case ItemType.folder:
        return "Create Folder";
      case ItemType.document:
        return "Add Document";
    }
  }
}

class _FormContent extends StatelessWidget {
  final ItemType type;
  final ValueChanged<VoidCallback> onSaveCallbackReady;
  final ValueChanged<bool> onValidationChanged;

  const _FormContent({
    required this.type,
    required this.onSaveCallbackReady,
    required this.onValidationChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ItemType.link:
        return CreateLinkPage(
          hideAppBar: true,
          onSaveCallbackReady: onSaveCallbackReady,
          onValidationChanged: onValidationChanged,
        );
      case ItemType.folder:
        return CreateFolderPage(
          hideAppBar: true,
          onSaveCallbackReady: onSaveCallbackReady,
          onValidationChanged: onValidationChanged,
        );
      case ItemType.document:
        return const _DocumentPlaceholder();
    }
  }
}

/// Header for form views with back button and action buttons
class _FormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaveEnabled;

  const _FormHeader({
    required this.title,
    required this.onBack,
    required this.onSave,
    required this.onCancel,
    required this.isSaveEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            tooltip: "Back to type selector",
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Action buttons
          TextButton(
            onPressed: onCancel,
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: isSaveEnabled ? onSave : null,
            icon: const Icon(Icons.save, size: 18),
            label: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for document form
class _DocumentPlaceholder extends StatelessWidget {
  const _DocumentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 64),
          SizedBox(height: 16),
          Text(
            "Document creation coming soon!",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

