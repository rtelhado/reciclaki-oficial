import 'package:flutter/material.dart';
import '../rotas.dart';

class MenuInferior extends StatelessWidget {
  const MenuInferior({super.key, required this.indice});
  final int indice;
  static const destinos = [
    Rotas.inicio,
    Rotas.pontos,
    Rotas.mapa,
    Rotas.videos,
  ];

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: indice,
    onDestinationSelected: (novo) {
      if (novo == indice) return;
      Navigator.popUntil(
        context,
        (rota) => rota.settings.name == Rotas.inicio || rota.isFirst,
      );
      if (novo != 0) Navigator.pushNamed(context, destinos[novo]);
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
      NavigationDestination(
        icon: Icon(Icons.add_location_alt_outlined),
        label: 'Cadastrar',
      ),
      NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
      NavigationDestination(
        icon: Icon(Icons.video_library_outlined),
        label: 'Vídeos',
      ),
    ],
  );
}
