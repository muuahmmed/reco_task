import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reco_test/screens/home/cubit/home_cubit.dart';
import 'package:reco_test/screens/login/cubit/login_cubit.dart';
import 'package:reco_test/screens/onboarding/onboarding.dart';
import 'package:reco_test/screens/sign_up/cubit/sign_up_cubit.dart';
import 'package:reco_test/screens/splash/splash_screen.dart';
import 'package:reco_test/services/auth/auth_repo.dart';
import 'package:reco_test/services/firebase/firebase_service.dart';
import 'package:reco_test/services/firebase/firestore_service.dart';
import 'cache/cache_helper.dart';
import 'firebase_options.dart';
import 'observer/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();

  // Initialize services
  final firebaseAuthService = FirebaseAuthService();
  final databaseService = FirestoreService();
  final authRepo = AuthRepoImpl(
    databaseService: databaseService,
    firebaseAuthService: firebaseAuthService,
  );

  // Register services with get_it if you're using it
  getIt.registerSingleton<AuthRepo>(authRepo);
  getIt.registerSingleton<DatabaseService>(databaseService);
  getIt.registerSingleton<FirebaseAuthService>(firebaseAuthService);

  runApp(MyApp(
    databaseService: databaseService,
    firebaseAuthService: firebaseAuthService,
  ));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  final FirebaseAuthService firebaseAuthService;

  const MyApp({
    super.key,
    required this.databaseService,
    required this.firebaseAuthService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeShopCubit(
          databaseService: databaseService,
          firebaseAuthService: firebaseAuthService,
        )),
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