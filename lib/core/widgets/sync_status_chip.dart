import 'package:flutter/material.dart';

import '../utils/app_context.dart';

/// Small line under a header that says when the data on screen comes from
/// the device cache (offline) or has changes still waiting to upload.
/// Shows nothing when everything is in sync.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({
    super.key,
    required this.isFromCache,
    required this.hasPendingWrites,
  });

  final bool isFromCache;
  final bool hasPendingWrites;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final c = context.c;

    final (IconData, String)? status = isFromCache
        ? (Icons.cloud_off_rounded, s.syncOffline)
        : hasPendingWrites
        ? (Icons.cloud_upload_outlined, s.syncPending)
        : null;
    if (status == null) return const SizedBox.shrink();
    final (icon, label) = status;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: context.font(fontSize: 12, color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
