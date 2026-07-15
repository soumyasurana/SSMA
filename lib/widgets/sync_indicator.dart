import 'package:flutter/material.dart';
import 'package:ssma/sync/sync_initializer.dart';
import 'package:ssma/sync/sync_status.dart';
import 'package:ssma/main.dart'; // To access syncInitializer
import 'package:ssma/screens/sync_settings_screen_v2.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (syncInitializer == null) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: syncInitializer!.statusNotifier,
      builder: (context, _) {
        final status = syncInitializer!.statusNotifier.status;

        IconData icon;
        Color color;

        switch (status) {
          case SyncStatus.idle:
            icon = Icons.cloud_done;
            color = Colors.green;
            break;
          case SyncStatus.syncing:
            icon = Icons.sync;
            color = Colors.blue;
            break;
          case SyncStatus.offline:
            icon = Icons.cloud_off;
            color = Colors.grey;
            break;
          case SyncStatus.error:
            icon = Icons.error;
            color = Colors.red;
            break;
        }

        return IconButton(
          icon: Icon(icon, color: color),
          tooltip: 'Sync Status: \${status.name}',
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