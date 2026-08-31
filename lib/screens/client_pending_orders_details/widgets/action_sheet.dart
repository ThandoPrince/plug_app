import 'package:flutter/material.dart';

/// The bottom-sheet chrome (drag handle, title, spacing) shared by every
/// long-press / "more actions" menu — introduced by
/// ScheduledShipmentsScreen's shipment actions sheet. Pass a list of
/// [ActionTile]s (or any widgets) and it handles the rest.
Future<void> showActionsSheet({
  required BuildContext context,
  required String title,
  required List<Widget> tiles,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      );
    },
  );
}