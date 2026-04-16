import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 接口配置
            SettingSection(
              title: '接口配置',
              items: [
                SettingItem(
                  icon: Icons.link,
                  title: '影视接口',
                  subtitle: '管理影视接口链接和线路名称',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.music_note,
                  title: '音乐音源',
                  subtitle: '管理音乐音源文件和在线音源',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.book,
                  title: '小说书源',
                  subtitle: '管理小说阅读书源',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 播放设置
            SettingSection(
              title: '播放设置',
              items: [
                SettingItem(
                  icon: Icons.play_arrow,
                  title: '默认播放器',
                  subtitle: '选择默认播放器',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.speed,
                  title: '播放速度',
                  subtitle: '设置默认播放速度',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.refresh,
                  title: '自动换源',
                  subtitle: '播放失败时自动切换数据源',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 备份设置
            SettingSection(
              title: '备份设置',
              items: [
                SettingItem(
                  icon: Icons.cloud_upload,
                  title: 'WebDAV备份',
                  subtitle: '备份影视接口、音乐音源、小说书源和个人设置',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.download,
                  title: '恢复备份',
                  subtitle: '从WebDAV恢复备份',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 关于
            SettingSection(
              title: '关于',
              items: [
                SettingItem(
                  icon: Icons.info,
                  title: '版本信息',
                  subtitle: 'v1.0.0',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.help,
                  title: '帮助与反馈',
                  subtitle: '查看帮助文档和提交反馈',
                  onTap: () {},
                ),
                SettingItem(
                  icon: Icons.share,
                  title: '分享应用',
                  subtitle: '分享应用给好友',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingSection extends StatelessWidget {
  final String title;
  final List<SettingItem> items;

  const SettingSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF333333)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
