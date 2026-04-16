import 'package:flutter/material.dart';
import 'package:nbox/components/category_tab.dart';

class NovelPage extends StatelessWidget {
  const NovelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小说'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 分类标签
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  CategoryTab(label: '推荐', isActive: true),
                  CategoryTab(label: '热门'),
                  CategoryTab(label: '新书'),
                  CategoryTab(label: '更多', showArrow: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 小说列表
            Column(
              children: [
                NovelItem(
                  title: '斗破苍穹',
                  author: '天蚕土豆',
                  imageUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20martial%20arts&image_size=portrait_4_3',
                  description: '这里是天才云集的世界，这里是斗气的天下！',
                  tags: ['玄幻', '热血', '冒险'],
                ),
                const SizedBox(height: 16),
                NovelItem(
                  title: '庆余年',
                  author: '猫腻',
                  imageUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20historical&image_size=portrait_4_3',
                  description: '一个普通青年穿越到古代的故事',
                  tags: ['穿越', '历史', '权谋'],
                ),
                const SizedBox(height: 16),
                NovelItem(
                  title: '三体',
                  author: '刘慈欣',
                  imageUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20science%20fiction&image_size=portrait_4_3',
                  description: '地球文明与三体文明的碰撞',
                  tags: ['科幻', '硬科幻', '宇宙'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NovelItem extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final List<String> tags;

  const NovelItem({
    super.key,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
