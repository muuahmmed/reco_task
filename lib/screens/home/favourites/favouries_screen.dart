import 'package:flutter/material.dart';
import '../../../components/componets.dart';
import '../search/search_screen.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final cubit = HomeShopCubit.get(context);
    // final theme = Theme.of(context);
    // final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => navigateTo(context, const SearchScreen()),
          ),
        ],
      ),
      body: Column(),
    );
  }
}
