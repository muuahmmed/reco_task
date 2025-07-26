import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: cubit.cartItems.isEmpty
                ? null
                : () => _showClearCartDialog(context, cubit),
          ),
        ],
      ),
      body: BlocBuilder<HomeShopCubit, HomeShopStates>(
        builder: (context, state) {
          if (cubit.cartItems.isEmpty) {
            return ScaleTransition(
              scale: _emptyStateAnimation,
              child: _buildEmptyCartState(context, primaryColor, screenSize),
            );
          }

          return Column(
            children: [
              Expanded(
                child: AnimatedList(
                  key: GlobalKey<AnimatedListState>(),
                  initialItemCount: cubit.cartItems.length,
                  padding: EdgeInsets.all(screenSize.width * 0.04),
                  itemBuilder: (context, index, animation) {
                    final item = cubit.cartItems[index];
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                      child: FadeTransition(
                        opacity: animation,
                        child: _buildCartItem(
                          context,
                          cubit,
                          item,
                          index,
                          screenSize,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(context, cubit, primaryColor, screenSize),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    HomeShopCubit cubit,
    Map<String, dynamic> item,
    int index,
    Size screenSize,
  ) {
    return Dismissible(
      key: Key(item['id'] ?? item['name']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final removedItem = item;
        cubit.updateCartItemQuantity(index, 0);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${removedItem['name']} removed'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () => cubit.addToCart(removedItem),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Row(
            children: [
              Hero(
                tag: 'cart-${item['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    item['image'] ?? 'assets/home/food.png',
                    width: screenSize.width * 0.2,
                    height: screenSize.width * 0.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: screenSize.width * 0.04),
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
                    SizedBox(height: 4),
                    Text(
                      '\$${(item['price'] as double).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total: \$${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8900FE),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: () {
                      cubit.updateCartItemQuantity(
                        index,
                        (item['quantity'] ?? 1) - 1,
                      );
                    },
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (item['quantity'] ?? 1).toString(),
                      style: TextStyle(fontSize: screenSize.width * 0.04),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {
                      cubit.updateCartItemQuantity(
                        index,
                        (item['quantity'] ?? 1) + 1,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCartState(
    BuildContext context,
    Color primaryColor,
    Size screenSize,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            'Add some delicious items to get started!',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.restaurant_menu, color: Colors.white),
            label: const Text('Browse Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    HomeShopCubit cubit,
    Color primaryColor,
    Size screenSize,
  ) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            context,
            'Subtotal',
            '\$${cubit.subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: 8),
          _buildPriceRow(
            context,
            'Delivery Fee',
            '\$${cubit.deliveryFee.toStringAsFixed(2)}',
          ),
          Divider(height: 24, thickness: 1),
          _buildPriceRow(
            context,
            'Total',
            '\$${cubit.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: () => _showOrderConfirmation(context, cubit),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: screenSize.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, HomeShopCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutBack,
        ),
        child: AlertDialog(
          title: const Text('Clear Cart'),
          content: const Text(
            'Are you sure you want to remove all items from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cubit.cartItems.clear();
                cubit.emit(CartUpdatedState());
                Navigator.pop(context);
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderConfirmation(BuildContext context, HomeShopCubit cubit) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: AlertDialog(
            title: const Text('Order Confirmation'),
            content: Text(
              'Your order total is \$${cubit.total.toStringAsFixed(2)}\n\nProceed to payment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Order placed successfully!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  cubit.cartItems.clear();
                  cubit.emit(CartUpdatedState());
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenSize.width * 0.04,
            color: Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenSize.width * 0.045,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF8900FE) : Colors.black,
          ),
        ),
      ],
    );
  }
}
