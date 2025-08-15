import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tags_controller.dart';
import '../../data/models/tag.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TagsController controller = Get.find<TagsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Метки и категории'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTagDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: controller.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Поиск меток',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Category filter
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: controller.filteredCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(controller.getCategoryFilterDisplayName()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.setCategoryFilter(value);
                    }
                  },
                )),
              ],
            ),
          ),
          
          // Tags list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refresh,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.filteredTags.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Метки не найдены',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Попробуйте изменить поиск или фильтр',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.filteredTags.length,
                itemBuilder: (context, index) {
                  final tag = controller.filteredTags[index];
                  return _buildTagTile(context, tag, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTagTile(BuildContext context, Tag tag, TagsController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(tag.color),
          child: Icon(
            _getIconData(tag.icon),
            color: Colors.white,
          ),
        ),
        title: Text(tag.name),
        subtitle: Text(controller.getCategoryDisplayName(tag.category)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tag.isDefault)
              const Chip(
                label: Text('Системная'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white, fontSize: 12),
              ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleTagAction(context, tag, controller, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Редактировать'),
                    ],
                  ),
                ),
                if (!tag.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Удалить', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _showTagDetails(context, tag, controller),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'priority_high':
        return Icons.priority_high;
      case 'entertainment':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      default:
        return Icons.label;
    }
  }

  void _handleTagAction(BuildContext context, Tag tag, TagsController controller, String action) {
    switch (action) {
      case 'edit':
        _showEditTagDialog(context, tag, controller);
        break;
      case 'delete':
        _showDeleteTagDialog(context, tag, controller);
        break;
    }
  }

  void _showTagDetails(BuildContext context, Tag tag, TagsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Категория', controller.getCategoryDisplayName(tag.category)),
            _buildDetailRow('Цвет', tag.color),
            _buildDetailRow('Иконка', tag.icon),
            _buildDetailRow('Создана', '${tag.createdAt.day}.${tag.createdAt.month}.${tag.createdAt.year}'),
            if (tag.isDefault)
              const Chip(
                label: Text('Системная метка'),
                backgroundColor: Colors.blue,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context, TagsController controller) {
    final nameController = TextEditingController();
    final iconController = TextEditingController();
    final colorController = TextEditingController();
    String selectedCategory = 'personal';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить метку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название метки',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: controller.availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(controller.getCategoryDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Иконка (например: home, car)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'Цвет (например: #4CAF50)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final tag = Tag(
                  name: nameController.text,
                  icon: iconController.text.isNotEmpty ? iconController.text : 'label',
                  color: colorController.text.isNotEmpty ? colorController.text : '#757575',
                  category: selectedCategory,
                  createdAt: DateTime.now(),
                );
                
                final success = await controller.addTag(tag);
                if (success) {
                  Navigator.of(context).pop();
                  Get.snackbar(
                    'Успешно',
                    'Метка добавлена',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag, TagsController controller) {
    final nameController = TextEditingController(text: tag.name);
    final iconController = TextEditingController(text: tag.icon);
    final colorController = TextEditingController(text: tag.color);
    String selectedCategory = tag.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать метку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название метки',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Категория',
                border: OutlineInputBorder(),
              ),
              items: controller.availableCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(controller.getCategoryDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Иконка',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'Цвет',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final updatedTag = tag.copyWith(
                  name: nameController.text,
                  icon: iconController.text,
                  color: colorController.text,
                  category: selectedCategory,
                );
                
                                 // Note: We need the tag ID for update, but we don't have it in the UI
                 // This is a simplified version - in a real app, you'd need to track the ID
                 Navigator.of(context).pop();
                 Get.snackbar(
                   'Информация',
                   'Функция редактирования требует доработки',
                   snackPosition: SnackPosition.BOTTOM,
                 );
                 // TODO: Implement proper tag update with ID tracking
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTagDialog(BuildContext context, Tag tag, TagsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить метку'),
        content: Text('Вы уверены, что хотите удалить метку "${tag.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Note: We need the tag ID for deletion, but we don't have it in the UI
              // This is a simplified version - in a real app, you'd need to track the ID
              Get.snackbar(
                'Информация',
                'Функция удаления требует доработки',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
