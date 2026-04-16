import 'package:flutter/material.dart';
import 'package:nbox/components/category_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nbox'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
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
                  CategoryTab(label: '新剧'),
                  CategoryTab(label: '都市情感'),
                  CategoryTab(label: '更多', showArrow: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 内容网格
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 2/3,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return ContentItem(
                  title: [
                    '义起风云枭雄路',
                    '重回80：从小渔民到水产大王',
                    '出狱后，我举世无双',
                    '流年深深深几许',
                    '女神老婆赖上我',
                    '万里江山入我怀',
                  ][index],
                  imageUrl: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster&image_size=square',
                  episode: [
                    '逆袭 61集',
                    '逆袭 61集',
                    '逆袭 69集',
                    '虐恋 70集',
                    '马甲 60集',
                    '穿越 74集',
                  ][index],
                  views: [
                    '1085万',
                    '1635万',
                    '970万',
                    '199万',
                    '304万',
                    '274万',
                  ][index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool showArrow;

  const CategoryTab({
    super.key,
    required this.label,
    this.isActive = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
          if (showArrow) const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}

class ContentItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String episode;
  final String views;

  const ContentItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.episode,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2/3,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        views,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
