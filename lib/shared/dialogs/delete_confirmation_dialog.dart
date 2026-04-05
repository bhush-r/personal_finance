import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Iconsax.trash,
          color: Colors.red.shade400,
          size: 28,
        ),
      ),
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              itemName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade500,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  static Future<bool?> show(
      BuildContext context, {
        required String title,
        required String message,
        required String itemName,
        required VoidCallback onConfirm,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        message: message,
        itemName: itemName,
        onConfirm: onConfirm,
      ),
    );
  }
}

// Helper function for easier usage
void showDeleteConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  required String itemName,
  required VoidCallback onConfirm,
}) {
  DeleteConfirmationDialog.show(
    context,
    title: title,
    message: message,
    itemName: itemName,
    onConfirm: onConfirm,
  );
}