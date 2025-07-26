import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reco_test/screens/home/favourites/favouries_screen.dart';
import '../cart/cart_screen.dart';
import '../layout/layout_screen.dart';
import '../profile/profile_screen.dart';
import 'home_states.dart';

class HomeShopCubit extends Cubit<HomeShopStates> {
  HomeShopCubit() : super(HomeShopInitialState());

  static HomeShopCubit get(BuildContext context) =>
      BlocProvider.of<HomeShopCubit>(context);

  int currentIndex = 0;
  int selectedCategoryIndex = 0;
  double deliveryFee = 5.0;

  final List<Widget> bottomScreens = [
    LayoutScreen(),
    const FavouriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(HomeShopSuccessState('Index changed to $index'));
  }

  void resetIndex() {
    currentIndex = 0;
    emit(HomeShopSuccessState('Index reset to 0'));
  }

  void changeBottomNav(int index) {
    if (currentIndex != index) {
      currentIndex = index;
      emit(ShopChangeBottomNavState());
    }
  }

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> favoriteItems = [];

  void addToCart(Map<String, dynamic> item) {
    final existingIndex = cartItems.indexWhere((cartItem) => cartItem['name'] == item['name']);
    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] = (cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      cartItems.add({...item, 'quantity': 1});
    }
    emit(CartUpdatedState());
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index]['quantity'] = newQuantity;
    } else {
      cartItems.removeAt(index);
    }
    emit(CartUpdatedState());
  }

  void toggleFavorite(Map<String, dynamic> item) {
    final existingIndex = favoriteItems.indexWhere((favItem) => favItem['name'] == item['name']);
    if (existingIndex >= 0) {
      favoriteItems.removeAt(existingIndex);
    } else {
      favoriteItems.add(item);
    }
    emit(FavoritesUpdatedState());
  }

  bool isFavorite(Map<String, dynamic> item) {
    return favoriteItems.any((favItem) => favItem['name'] == item['name']);
  }

  double get subtotal {
    return cartItems.fold(0.0, (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)));
  }

  double get total => subtotal + deliveryFee;
}

