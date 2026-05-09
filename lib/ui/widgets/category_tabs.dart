import 'package:flutter/material.dart';
import '../../core/models/video_source.dart';

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final Function(String?) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildTab(context, '首页', '', selectedId == null || selectedId!.isEmpty);
          }
          final category = categories[index - 1];
          return _buildTab(
            context,
            category.typeName ?? '未知',
            category.typeId ?? '',
            selectedId == category.typeId,
          );
        },
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, String id, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => onCategorySelected(id.isEmpty ? null : id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.white54),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
