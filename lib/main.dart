import 'package:fotosfera/features/job_evaluation/presentation/pages/image_detail_page.dart' as detail;
import 'package:fotosfera/features/job_evaluation/presentation/pages/images_list_page.dart' as list;
import 'package:fotosfera/features/job_evaluation/presentation/blocs/images_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fotosfera/di/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// All initialization is done INSIDE runZonedGuarded
void main() {
  runZonedGuarded(() async {
    /// 1) Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();

    /// 2) Firebase
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    /// 3) Easy Localization
    await EasyLocalization.ensureInitialized();

    /// 4) Initialize GetIt
    await initDependencies();

    /// 5) Finally, run the app
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ru')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MyApp(),
      ),
    );
  }, (error, stackTrace) {
    /// Catch any unhandled errors
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Our GoRouter config
  final _router = GoRouter(
    initialLocation: '/images',
    routes: [
      GoRoute(
        path: '/images',
        builder: (context, state) => const list.ImagesListPage(), // ✅ Use prefix 'list'
      ),
      GoRoute(
        path: '/detail/:imageId',
        builder: (context, state) {
          final imageId = state.pathParameters['imageId']!;
          return detail.ImageDetailPage(imageId: imageId); // ✅ Use prefix 'detail'
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImagesBloc>(
      create: (_) {
        final bloc = getIt<ImagesBloc>();
        bloc.add(LoadImages());
        return bloc;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        routerConfig: _router,
        title: 'Fotosfera',
      ),
    );
  }
}