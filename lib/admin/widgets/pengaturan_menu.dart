import 'package:flutter/material.dart';

class PengaturanMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const PengaturanMenu({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth < 500 ? 26 : 40;
    double fontSize = screenWidth < 500 ? 16 : 20;
    double arrowSize = screenWidth < 500 ? 16 : 20;
    double paddingV = screenWidth < 500 ? 10 : 14;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingV),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: iconSize),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: arrowSize,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
