import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'services/grpc_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GrpcClient().init();
  runApp(const TaxiApp());
}

class TaxiApp extends StatelessWidget {
  const TaxiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}