import 'package:flutter/material.dart';

/// The loading → empty → list pattern every list screen shares.
class AsyncList extends StatelessWidget {
  const AsyncList({
    super.key,
    required this.loading,
    required this.emptyMessage,
    required this.children,
    this.emptyIcon = Icons.inbox_outlined,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 88),
  });

  final bool loading;
  final String emptyMessage;
  final IconData emptyIcon;
  final List<Widget> children;
  // Bottom padding leaves room so a floating action button never covers the
  // last item.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (children.isEmpty) return EmptyState(icon: emptyIcon, message: emptyMessage);
    return ListView(padding: padding, children: children);
  }
}

/// A centered icon and message for "nothing here yet".
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Scrollable so it never overflows when squeezed (e.g. under a calendar).
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

/// A small heading between groups of list items.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}
