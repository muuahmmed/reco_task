import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reco_test/screens/home/favourites/favouries_screen.dart';
import '../../../cache/cache_helper.dart';
import '../../../models/user_model.dart';
import '../../../services/firebase/firebase_service.dart';
import '../../../services/firebase/firestore_service.dart';
import '../cart/cart_screen.dart';
import '../layout/layout_screen.dart';
import '../profile/profile_screen.dart';
import 'home_states.dart';

class HomeShopCubit extends Cubit<HomeShopStates> {
  HomeShopCubit({
    required this.databaseService,
    required this.firebaseAuthService,
  }) : super(HomeShopInitialState()) {
    _initialize();
  }

  static HomeShopCubit get(BuildContext context) =>
      BlocProvider.of<HomeShopCubit>(context);

  int currentIndex = 0;
  int selectedCategoryIndex = 0;
  double deliveryFee = 5.0;
  UserModel? user;
  final DatabaseService databaseService;
  final FirebaseAuthService firebaseAuthService;

  final List<Widget> bottomScreens = [
    LayoutScreen(),
    const FavouriteScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> favoriteItems = [];

  Future<void> _initialize() async {
    await _loadUserData();
    await _loadCachedData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = firebaseAuthService.currentUser;
      if (currentUser != null) {
        final userData = await databaseService.getData(
          path: 'users/${currentUser.uid}',
        );
        if (userData != null) {
          user = UserModel.fromMap(userData);
          emit(HomeShopSuccessState('User data loaded'));
        }
      }
    } catch (e) {
      emit(HomeShopErrorState('Failed to load user data: ${e.toString()}'));
    }
  }

  Future<void> _loadCachedData() async {
    try {
      // Load cart items from cache
      final cachedCart = CacheHelper.getData(key: 'cartItems');
      if (cachedCart != null && cachedCart is String) {
        cartItems = List<Map<String, dynamic>>.from(jsonDecode(cachedCart));
      }

      // Load favorites from cache
      final cachedFavorites = CacheHelper.getData(key: 'favoriteItems');
      if (cachedFavorites != null && cachedFavorites is String) {
        favoriteItems = List<Map<String, dynamic>>.from(
          jsonDecode(cachedFavorites),
        );
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _saveDataToCache() async {
    try {
      await CacheHelper.saveData(
        key: 'cartItems',
        value: jsonEncode(cartItems),
      );
      await CacheHelper.saveData(
        key: 'favoriteItems',
        value: jsonEncode(favoriteItems),
      );
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

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

  void addToCart(Map<String, dynamic> item) {
    final existingIndex = cartItems.indexWhere(
      (cartItem) => cartItem['name'] == item['name'],
    );
    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] =
          (cartItems[existingIndex]['quantity'] ?? 1) + 1;
    } else {
      cartItems.add({...item, 'quantity': 1});
    }
    _saveDataToCache();
    emit(CartUpdatedState());
  }

  void updateCartItemQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      cartItems[index]['quantity'] = newQuantity;
    } else {
      cartItems.removeAt(index);
    }
    _saveDataToCache();
    emit(CartUpdatedState());
  }

  void toggleFavorite(Map<String, dynamic> item) {
    final existingIndex = favoriteItems.indexWhere(
      (favItem) => favItem['name'] == item['name'],
    );
    if (existingIndex >= 0) {
      favoriteItems.removeAt(existingIndex);
    } else {
      favoriteItems.add(item);
    }
    _saveDataToCache();
    emit(FavoritesUpdatedState());
  }

  bool isFavorite(Map<String, dynamic> item) {
    return favoriteItems.any((favItem) => favItem['name'] == item['name']);
  }

  double get subtotal {
    return cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * (item['quantity'] ?? 1)),
    );
  }

  double get total => subtotal + deliveryFee;

  Future<void> clearCart() async {
    cartItems.clear();
    await _saveDataToCache();
    emit(CartUpdatedState());
  }

  Future<void> clearFavorites() async {
    favoriteItems.clear();
    await _saveDataToCache();
    emit(FavoritesUpdatedState());
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    try {
      user = updatedUser;
      await databaseService.addData(
        path: 'users/${user!.uId}',
        data: user!.toMap(),
      );
      emit(HomeShopSuccessState('User data updated'));
    } catch (e) {
      emit(HomeShopErrorState('Failed to update user data: ${e.toString()}'));
    }
  }
}
