import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Hyperlink extends StatelessWidget {
  final String label;
  final String url;
  final Color color;

  Hyperlink(this.label, this.url, {this.color = Colors.amber});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Text(
        label,
        style: TextStyle(
          color: color,
        ),
      ),
      onTap: () async {
        await _launchUrl(url);
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
