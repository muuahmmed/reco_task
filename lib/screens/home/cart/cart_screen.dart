import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = HomeShopCubit.get(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final screenSize = MediaQuery.of(context).size;

    // Sample cart items
    final cartItems = [
      {
        'name': 'Pizza Margherita',
        'price': 12.99,
        'quantity': 2,
        'image': 'assets/food/pizza.png'
      },
      {
        'name': 'Fresh Salad',
        'price': 8.50,
        'quantity': 1,
        'image': 'assets/food/salad.png'
      },
      {
        'name': 'Chocolate Cake',
        'price': 6.75,
        'quantity': 1,
        'image': 'assets/food/cake.png'
      },
    ];

    final subtotal = cartItems.fold(
        0.0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));
    final total = subtotal + cubit.deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: BlocBuilder<HomeShopCubit, HomeShopStates>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(screenSize.width * 0.03),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenSize.width * 0.03),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item['image'] as String,
                                width: screenSize.width * 0.2,
                                height: screenSize.width * 0.2,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
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
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    // Decrease quantity
                                  },
                                ),
                                Text(
                                  item['quantity'].toString(),
                                  style: TextStyle(
                                    fontSize: screenSize.width * 0.045,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    // Increase quantity
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    _buildPriceRow(
                      context,
                      'Subtotal',
                      '\$${subtotal.toStringAsFixed(2)}',
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    _buildPriceRow(
                      context,
                      'Delivery Fee',
                      '\$${cubit.deliveryFee.toStringAsFixed(2)}',
                    ),
                    Divider(height: screenSize.height * 0.03),
                    _buildPriceRow(
                      context,
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Proceed to checkout
                        },
                        child: Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: screenSize.width * 0.045,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceRow(
      BuildContext context, String label, String value, {bool isTotal = false}) {
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
            color: isTotal ? Theme.of(context).colorScheme.primary : Colors.black,
          ),
        ),
      ],
    );
  }
}