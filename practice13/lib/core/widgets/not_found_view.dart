import 'package:flutter/material.dart';

import 'message_view.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) =>
      const MessageView(icon: Icons.search_off, text: 'Nothing found');
}
