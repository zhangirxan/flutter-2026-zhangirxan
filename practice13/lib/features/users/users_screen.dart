import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../settings/settings_model.dart';
import '../settings/settings_screen.dart';
import '../../core/widgets/generic_error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/not_found_view.dart';
import '../../core/widgets/offline_view.dart';
import '../../core/widgets/server_error_view.dart';
import '../profile/profile_screen.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_list.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  void _open(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle),
            onPressed: () => _open(context, const ProfileScreen()),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      body: const _Body(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New user',
        onPressed: () => _open(context, const NewUserScreen()),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    final city = context.watch<SettingsModel>().city;
    if (m.loading) return const LoadingView();
    // no default: ApiException is sealed, so a missing case won't compile
    return switch (m.error) {
      null => Column(
        children: [
          if (m.fromCache) OfflineBanner(onRetry: m.load),
          Expanded(
            child: RefreshIndicator(
              onRefresh: m.load,
              child: UserList([
                for (final u in m.items)
                  if (city == null || u.address.city == city) u,
              ]),
            ),
          ),
        ],
      ),
      NoConnectionException() => OfflineView(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const NotFoundView(),
      ServerException(:final status) => ServerErrorView(
        status,
        onRetry: m.load,
      ),
      BadResponseException() => const GenericErrorView(),
    };
  }
}
