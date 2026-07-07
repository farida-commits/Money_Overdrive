import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RateAppDialog extends StatefulWidget {
  const RateAppDialog({super.key});

  static Future<int?> show(BuildContext context) {
    return showCupertinoDialog<int>(
      context: context,
      builder: (_) => const RateAppDialog(),
    );
  }

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  int _rating = 4;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: Image.asset(
                'assets/images/ikon.jpg',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Text(
            'Rate the app',
            style: TextStyle(
              fontFamily: '.SF Pro Text',
              fontWeight: FontWeight.w600,
              fontSize: 17,
              letterSpacing: 14 * 0.02,
            ),
          ),
        ],
      ),
      content: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Tap a star to rate. You can also leave a comment',
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.08,
            ),
            ),
          const SizedBox(height: 12),
          Container(
            height: 0.9,
            width: double.infinity,
            color: Color(0xff3C3C435C),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child:
                    Icon(
                      filled ? CupertinoIcons.star_fill : CupertinoIcons.star,
                      color: CupertinoColors.systemBlue,
                      size: 26,
                    ),
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.41,
          ),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(_rating),
          child: const Text(
            'Submit',
            style: TextStyle(
              color: Color(0xFF007AFF),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
        ),
      ],
    );
  }
}