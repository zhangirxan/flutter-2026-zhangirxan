import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/loading_view.dart';
import '../settings/settings_model.dart';
import 'new_user_screen.dart';
import 'users_model.dart';
import 'widgets/city_filter_bar.dart';
import 'widgets/empty_users_view.dart';
import 'widgets/offline_banner.dart';
import 'widgets/user_list.dart';
import 'widgets/users_error_view.dart';
import 'widgets/users_header.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UsersHeader(),
      body: const _Body(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New user',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
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
    final settings = context.watch<SettingsModel>();
    final city = settings.city;

    if (m.loading) return const LoadingView();
    final error = m.error;
    if (error != null) return UsersErrorView(error, onRetry: m.load);

    final shown = [
      for (final u in m.items)
        if (city == null || u.address.city == city) u,
    ];
    return Column(
      children: [
        if (m.fromCache) OfflineBanner(onRetry: m.load),
        if (city != null)
          CityFilterBar(city: city, onClear: () => settings.setCity(null)),
        Expanded(
          child: RefreshIndicator(
            onRefresh: m.load,
            child: shown.isEmpty ? const EmptyUsersView() : UserList(shown),
          ),
        ),
      ],
    );
  }
}
