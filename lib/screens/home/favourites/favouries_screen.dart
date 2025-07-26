import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../components/componets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';
import '../search/search_screen.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
    with TickerProviderStateMixin {
  late AnimationController _emptyStateController;
  late Animation<double> _emptyStateAnimation;

  @override
  void initState() {
    super.initState();
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _emptyStateAnimation = CurvedAnimation(
      parent: _emptyStateController,
      curve: Curves.elasticOut,
    );
    _emptyStateController.forward();
  }

  @override
  void dispose() {
    _emptyStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = HomeShopCubit.get(context);
    final screenSize = MediaQuery.of(context).size;

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
      body: BlocBuilder<HomeShopCubit, HomeShopStates>(
        builder: (context, state) {
          if (cubit.favoriteItems.isEmpty) {
            return ScaleTransition(
              scale: _emptyStateAnimation,
              child: _buildEmptyFavoritesState(screenSize),
            );
          }

          return AnimatedList(
            key: GlobalKey<AnimatedListState>(),
            initialItemCount: cubit.favoriteItems.length,
            padding: EdgeInsets.all(screenSize.width * 0.03),
            itemBuilder: (context, index, animation) {
              final item = cubit.favoriteItems[index];
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                child: FadeTransition(
                  opacity: animation,
                  child: _buildFavoriteItem(
                    context,
                    cubit,
                    item,
                    index,
                    screenSize,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    HomeShopCubit cubit,
    Map<String, dynamic> item,
    int index,
    Size screenSize,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          cubit.addToCart(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} added to cart'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.03),
          child: Row(
            children: [
              Hero(
                tag: 'fav-${item['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item['image'] ?? 'assets/home/food.png',
                    width: screenSize.width * 0.25,
                    height: screenSize.width * 0.25,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Text(
                      '\$${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => cubit.toggleFavorite(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyFavoritesState(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart icon to add favorites',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
