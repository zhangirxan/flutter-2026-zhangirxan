import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/widgets/generic_error_view.dart';
import '../../../core/widgets/not_found_view.dart';
import '../../../core/widgets/offline_view.dart';
import '../../../core/widgets/server_error_view.dart';

// one view per kind of error. no default: ApiException is sealed,
// so forgetting a case does not compile
class UsersErrorView extends StatelessWidget {
  const UsersErrorView(this.error, {super.key, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (error) {
      NoConnectionException() => OfflineView(onRetry: onRetry),
      NotFoundException() || UnauthorizedException() => const NotFoundView(),
      ServerException(:final status) => ServerErrorView(
        status,
        onRetry: onRetry,
      ),
      BadResponseException() => const GenericErrorView(),
    };
  }
}
