abstract class HomeShopStates {}

class HomeShopInitialState extends HomeShopStates {}

class HomeShopLoadingState extends HomeShopStates {}

class HomeShopSuccessState extends HomeShopStates {
  final String message;

  HomeShopSuccessState(this.message);
}

class HomeShopErrorState extends HomeShopStates {
  final String error;

  HomeShopErrorState(this.error);
}

class ShopChangeBottomNavState extends HomeShopStates {}

class ShopCategoryChangedState extends HomeShopStates {
  final int selectedIndex;

  ShopCategoryChangedState(this.selectedIndex);
}