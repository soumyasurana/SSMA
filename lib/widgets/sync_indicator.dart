import 'package:flutter/material.dart';
import 'package:ssma/sync/v2/sync_initializer_v2.dart';
import 'package:ssma/sync/v2/services/sync_manager.dart' show SyncStatusV2;
import 'package:ssma/screens/sync_settings_screen_v2.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (syncV2 == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: syncV2!.statusNotifier,
      builder: (context, _) {
        final status = syncV2!.statusNotifier.status;

        IconData icon;
        Color color;

        switch (status) {
          case SyncStatusV2.idle:
            icon = Icons.cloud_done;
            color = Colors.green;
            break;
          case SyncStatusV2.syncing:
            icon = Icons.sync;
            color = Colors.blue;
            break;
          case SyncStatusV2.offline:
            icon = Icons.cloud_off;
            color = Colors.grey;
            break;
          case SyncStatusV2.error:
            icon = Icons.error;
            color = Colors.red;
            break;
        }

        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: 'Sync Status: ${status.name}',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SyncSettingsScreenV2()),
            );
          },
        );
      },
    );
  }
}