import 'package:flutter/material.dart';

import 'message_view.dart';

// bad JSON: retrying won't help, it's a bug on our side
class GenericErrorView extends StatelessWidget {
  const GenericErrorView({super.key});

  @override
  Widget build(BuildContext context) =>
      const MessageView(icon: Icons.bug_report, text: 'Something went wrong');
}
