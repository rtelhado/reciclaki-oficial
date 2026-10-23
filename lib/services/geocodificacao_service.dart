import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class EnderecoGeocodificado {
  const EnderecoGeocodificado({
    required this.endereco,
    required this.numero,
    required this.bairro,
  });

  final String endereco;
  final String numero;
  final String bairro;

  factory EnderecoGeocodificado.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    if (address is! Map<String, dynamic>) {
      throw const FormatException('O serviço não retornou dados de endereço.');
    }

    String? valor(List<String> chaves) {
      for (final chave in chaves) {
        final item = address[chave];
        if (item is String && item.trim().isNotEmpty) return item.trim();
      }
      return null;
    }

    final nomeRua = valor([
      'road',
      'pedestrian',
      'residential',
      'footway',
      'path',
    ]);
    final endereco = nomeRua ?? json['display_name'] as String?;
    final bairro = valor([
      'neighbourhood',
      'suburb',
      'city_district',
      'borough',
      'town',
      'village',
      'city',
      'municipality',
      'county',
      'state_district',
    ]);

    if (endereco == null || endereco.trim().isEmpty || bairro == null) {
      throw const FormatException(
        'Não foi possível identificar o endereço e o bairro deste ponto.',
      );
    }

    return EnderecoGeocodificado(
      endereco: endereco.trim().substring(
        0,
        endereco.trim().length > 200 ? 200 : endereco.trim().length,
      ),
      numero: valor(['house_number']) ?? 's/n',
      bairro: bairro.length > 100 ? bairro.substring(0, 100) : bairro,
    );
  }
}

class GeocodificacaoService {
  GeocodificacaoService._();

  static DateTime? _ultimaConsulta;

  static Future<EnderecoGeocodificado> enderecoDe(LatLng ponto) async {
    final ultima = _ultimaConsulta;
    if (ultima != null) {
      final decorrido = DateTime.now().difference(ultima);
      if (decorrido < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - decorrido);
      }
    }
    _ultimaConsulta = DateTime.now();

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': ponto.latitude.toString(),
      'lon': ponto.longitude.toString(),
      'zoom': '18',
      'addressdetails': '1',
    });
    final resposta = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Accept-Language': 'pt-BR,pt;q=0.9',
            'User-Agent': 'ReciclaKi/1.0 (mapa de pontos de coleta)',
          },
        )
        .timeout(const Duration(seconds: 12));

    if (resposta.statusCode != 200) {
      throw FormatException(
        'O serviço de endereços respondeu com HTTP ${resposta.statusCode}.',
      );
    }

    final json = jsonDecode(utf8.decode(resposta.bodyBytes));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Resposta de endereço inválida.');
    }
    return EnderecoGeocodificado.fromJson(json);
  }
}
