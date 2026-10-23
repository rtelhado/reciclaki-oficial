import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key, this.inicial});
  final LatLng? inicial;
  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage> {
  LatLng? selecionado;
  @override
  void initState() {
    super.initState();
    selecionado = widget.inicial;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Localização do ponto')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Aproxime o mapa e toque no local exato do ponto de coleta.',
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O endereço do marcador é consultado no OpenStreetMap ao confirmar. © OpenStreetMap contributors',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: selecionado ?? const LatLng(-21.13056, -42.36639),
              initialZoom: 14,
              onTap: (_, local) => setState(() => selecionado = local),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'br.com.reciclaki.app',
              ),
              if (selecionado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selecionado!,
                      width: 52,
                      height: 52,
                      child: const Icon(
                        Icons.location_pin,
                        size: 52,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: selecionado == null
                    ? null
                    : () => Navigator.pop(context, selecionado),
                icon: const Icon(Icons.check),
                label: const Text('Confirmar localização'),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
