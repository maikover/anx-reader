import 'package:cubebook/l10n/generated/L10n.dart';
import 'package:flutter/material.dart';

class StatisticsTips extends StatelessWidget {
  const StatisticsTips({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyleBig = TextStyle(
      fontSize: compact ? 14 : 20,
      fontWeight: FontWeight.bold,
    );
    final TextStyle textStyle = TextStyle(
      fontSize: compact ? 12 : 15,
    );

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '(｡╯︵╰｡) ',
              style: TextStyle(
                fontSize: compact ? 30 : 50,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: compact ? 10 : 50),
            Text(
              L10n.of(context).statisticsTips_1,
              style: textStyleBig,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? 6 : 10),
            Text(
              L10n.of(context).statisticsTips_2,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
