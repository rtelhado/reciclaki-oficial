import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'rotas.dart';
import 'screens/login_page.dart';
import 'screens/cadastro_page.dart';
import 'screens/inicio_page.dart';
import 'screens/ponto_coleta_page.dart';
import 'screens/mapa_firestore_page.dart';
import 'screens/videos_page.dart';
import 'screens/perfil_page.dart';
import 'widgets/acesso_protegido.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? falha;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (const bool.fromEnvironment('USE_FIREBASE_EMULATORS')) {
      const host = String.fromEnvironment(
        'FIREBASE_EMULATOR_HOST',
        defaultValue: '127.0.0.1',
      );
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error\n$stackTrace');
    falha =
        'Não foi possível iniciar a conexão. Reabra o aplicativo ou confira a configuração do Firebase.';
  }
  runApp(ReciclaKiApp(falhaInicial: falha));
}

class ReciclaKiApp extends StatelessWidget {
  const ReciclaKiApp({super.key, this.falhaInicial});
  final String? falhaInicial;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ReciclaKi',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF08A94F)),
      useMaterial3: true,
    ),
    home: falhaInicial != null
        ? Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(falhaInicial!, textAlign: TextAlign.center),
              ),
            ),
          )
        : const AcessoProtegido(child: MenuReciclaki()),
    routes: {
      Rotas.login: (_) => const LoginPage(),
      Rotas.cadastro: (_) => const CriarContaPage(),
      Rotas.inicio: (_) => const AcessoProtegido(child: MenuReciclaki()),
      Rotas.pontos: (_) => const AcessoProtegido(child: CadastroPontoColeta()),
      Rotas.mapa: (_) => const AcessoProtegido(child: TelaMapaColeta()),
      Rotas.videos: (_) => const AcessoProtegido(child: VideosPage()),
      Rotas.perfil: (_) => const AcessoProtegido(child: PerfilPage()),
    },
  );
}
