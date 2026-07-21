import 'package:flutter/cupertino.dart';

Widget buildIosPillButton({
  required String text,
  required VoidCallback onTap,
  Color backgroundColor = CupertinoColors.systemFill,
  Color textColor = CupertinoColors.white,
  IconData? icon,
  bool isDestructive = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDestructive ? CupertinoColors.destructiveRed : backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    ),
  );
}
