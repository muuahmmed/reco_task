import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reco_test/screens/home/cubit/home_cubit.dart';
import 'package:reco_test/screens/login/cubit/login_cubit.dart';
import 'package:reco_test/screens/onboarding/onboarding.dart';
import 'package:reco_test/screens/sign_up/cubit/sign_up_cubit.dart';
import 'package:reco_test/screens/splash/splash_screen.dart';
import 'package:reco_test/services/auth/auth_repo.dart';
import 'cache/cache_helper.dart';
import 'firebase_options.dart';
import 'observer/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeShopCubit()),
        BlocProvider(create: (context) => ShopLoginCubit(getIt<AuthRepo>())),
        BlocProvider(create: (context) => RegisterCubit(getIt<AuthRepo>())),
      ],
      child: MaterialApp(
        home: const LogoScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
