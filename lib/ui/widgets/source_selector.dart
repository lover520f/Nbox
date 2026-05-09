import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/config_service.dart';
import '../../core/models/video_source.dart';

class SourceSelector extends StatelessWidget {
  const SourceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigService>(
      builder: (context, configService, child) {
        final sources = configService.sources.where((s) => s.isEnabled).toList();
        if (sources.isEmpty) {
          return const SizedBox.shrink();
        }

        return PopupMenuButton<VideoSource>(
          icon: const Icon(Icons.source),
          tooltip: '选择数据源',
          onSelected: (source) {
            configService.setActiveSource(source);
          },
          itemBuilder: (context) {
            return sources.map((source) {
              final isActive = source.key == configService.activeSource?.key;
              return PopupMenuItem<VideoSource>(
                value: source,
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isActive ? Theme.of(context).primaryColor : null,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            source.name ?? '未知',
                            style: TextStyle(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (source.api != null)
                            Text(
                              source.api!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }
}
