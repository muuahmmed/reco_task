import 'package:dynamic_height_list_view/dynamic_height_view.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Sample categories data
    final categories = [
      {'name': 'Food', 'icon': Icons.fastfood, 'color': Colors.orange},
      {
        'name': 'Groceries',
        'icon': Icons.shopping_basket,
        'color': Colors.green,
      },
      {
        'name': 'Electronics',
        'icon': Icons.electrical_services,
        'color': Colors.blue,
      },
      {'name': 'Fashion', 'icon': Icons.shopping_bag, 'color': Colors.purple},
      {'name': 'Health', 'icon': Icons.medical_services, 'color': Colors.red},
      {'name': 'Home', 'icon': Icons.home, 'color': Colors.brown},
      {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.teal},
      {'name': 'Books', 'icon': Icons.menu_book, 'color': Colors.indigo},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: DynamicHeightGridView(
          crossAxisCount: isPortrait ? 2 : 4,
          crossAxisSpacing: screenSize.width * 0.03,
          mainAxisSpacing: screenSize.width * 0.03,

          itemCount: categories.length,
          builder: (context, index) {
            final category = categories[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  // Handle category tap
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: screenSize.width * 0.12,
                      color: category['color'] as Color,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
