import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ponto_coleta.dart';
import '../services/pontos_service.dart';
import '../services/auth_service.dart';
import '../widgets/menu_inferior.dart';
import '../rotas.dart';

// Tela da Gabriela: mapa, filtros e cartões conectados ao Firestore.
class TelaMapaColeta extends StatefulWidget {
  const TelaMapaColeta({super.key});
  @override
  State<TelaMapaColeta> createState() => _TelaMapaColetaState();
}

class _TelaMapaColetaState extends State<TelaMapaColeta> {
  static const verde = Color(0xFF075B36);
  final _mapController = MapController();
  late Stream<List<PontoColeta>> _stream;
  String? _bairro;
  String? _material;
  String? _selecionadoId;
  Position? _localizacaoUsuario;
  String? _erroLocalizacao;
  bool _obtendoLocalizacao = false;
  bool _mapaPronto = false;

  @override
  void initState() {
    super.initState();
    _stream = PontosService.observar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _obterLocalizacao();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _obterLocalizacao({bool centralizar = false}) async {
    if (_obtendoLocalizacao) return;
    setState(() {
      _obtendoLocalizacao = true;
      _erroLocalizacao = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }
      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.unableToDetermine) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.deniedForever) {
        throw StateError(
          'Permita a localização nas configurações do aparelho ou navegador.',
        );
      }
      if (permissao == LocationPermission.denied) {
        throw StateError(
          'Permita o acesso à localização para mostrar sua posição no mapa.',
        );
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() => _localizacaoUsuario = posicao);
      if (centralizar && _mapaPronto) {
        _mapController.move(LatLng(posicao.latitude, posicao.longitude), 15);
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        setState(
          () => _erroLocalizacao =
              'Ative o serviço de localização para mostrar sua posição.',
        );
      }
    } on TimeoutException {
      if (mounted) {
        setState(
          () => _erroLocalizacao =
              'Não foi possível obter sua localização. Tente novamente.',
        );
      }
    } on PermissionDefinitionsNotFoundException catch (erro, stackTrace) {
      debugPrint(
        'Location permission configuration is missing: $erro\n$stackTrace',
      );
      if (mounted) {
        setState(
          () => _erroLocalizacao =
              'A permissão de localização não está configurada para esta plataforma.',
        );
      }
    } catch (erro, stackTrace) {
      debugPrint('Could not get current location: $erro\n$stackTrace');
      if (mounted) {
        setState(
          () => _erroLocalizacao = erro is StateError
              ? erro.message
              : 'Não foi possível obter sua localização. Confira a permissão e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _obtendoLocalizacao = false);
    }
  }

  Future<void> _filtrarBairro() async {
    final controller = TextEditingController(text: _bairro);
    final valor = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buscar por bairro'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome do bairro'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ''),
            child: const Text('Limpar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.dispose();
    if (!mounted || valor == null) return;
    setState(() {
      _bairro = valor.trim().isEmpty ? null : valor.trim();
      _selecionadoId = null;
    });
  }

  Future<void> _filtrarMaterial(List<PontoColeta> pontos) async {
    final materiais = pontos.expand((p) => p.materiais).toSet().toList()
      ..sort();
    final valor = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Todos os materiais'),
              onTap: () => Navigator.pop(ctx, ''),
            ),
            for (final material in materiais)
              ListTile(
                leading: const Icon(Icons.recycling),
                title: Text(material),
                onTap: () => Navigator.pop(ctx, material),
              ),
          ],
        ),
      ),
    );
    if (!mounted || valor == null) return;
    setState(() {
      _material = valor.isEmpty ? null : valor;
      _selecionadoId = null;
    });
  }

  Future<void> _abrirRota(PontoColeta ponto) async {
    final url = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${ponto.latitude},${ponto.longitude}',
    });
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication) &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir a rota.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o aplicativo de mapas.'),
          ),
        );
      }
    }
  }

  void _detalhes(PontoColeta ponto) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ponto.nome, style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text(ponto.enderecoCompleto),
              const SizedBox(height: 12),
              Text('Materiais: ${ponto.materiais.join(', ')}'),
              const SizedBox(height: 12),
              Text('Funcionamento: ${ponto.horario}'),
              const SizedBox(height: 12),
              SelectableText(
                'Telefone: ${ponto.telefone}\nE-mail: ${ponto.email}',
              ),
              if (ponto.observacoes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(ponto.observacoes),
                ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _abrirRota(ponto),
                icon: const Icon(Icons.directions),
                label: const Text('Traçar rota no Google Maps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F8E8),
    appBar: AppBar(
      title: const Text('Pontos de Coleta'),
      centerTitle: true,
      backgroundColor: verde,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: 'Cadastrar ponto',
          icon: const Icon(Icons.add_location_alt),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, Rotas.pontos),
        ),
      ],
    ),
    bottomNavigationBar: const MenuInferior(indice: 2),
    body: StreamBuilder<List<PontoColeta>>(
      stream: _stream,
      builder: (context, snapshot) {
        final todos = snapshot.data ?? <PontoColeta>[];
        final filtrados = todos
            .where(
              (p) =>
                  (_bairro == null ||
                      p.bairro.toLowerCase().contains(
                        _bairro!.toLowerCase(),
                      )) &&
                  (_material == null || p.materiais.contains(_material)),
            )
            .toList();
        final selecionados = filtrados.where((p) => p.id == _selecionadoId);
        final selecionado = selecionados.isEmpty ? null : selecionados.first;
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.location_city, size: 18),
                      label: Text(_bairro ?? 'Bairro'),
                      onPressed: _filtrarBairro,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.recycling, size: 18),
                      label: Text(_material ?? 'Material'),
                      onPressed: () => _filtrarMaterial(todos),
                    ),
                    if (_bairro != null || _material != null)
                      ActionChip(
                        avatar: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpar'),
                        onPressed: () => setState(() {
                          _bairro = null;
                          _material = null;
                          _selecionadoId = null;
                        }),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: filtrados.isEmpty
                                ? const LatLng(-21.13056, -42.36639)
                                : LatLng(
                                    filtrados.first.latitude,
                                    filtrados.first.longitude,
                                  ),
                            initialZoom: 14,
                            onMapReady: () => _mapaPronto = true,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'br.com.reciclaki.app',
                            ),
                            MarkerLayer(
                              markers: [
                                for (final ponto in filtrados)
                                  Marker(
                                    point: LatLng(
                                      ponto.latitude,
                                      ponto.longitude,
                                    ),
                                    width: 48,
                                    height: 48,
                                    child: IconButton(
                                      tooltip: ponto.nome,
                                      icon: Icon(
                                        Icons.location_pin,
                                        color: ponto.id == _selecionadoId
                                            ? Colors.orange.shade800
                                            : verde,
                                        size: 40,
                                      ),
                                      onPressed: () => setState(
                                        () => _selecionadoId = ponto.id,
                                      ),
                                    ),
                                  ),
                                if (_localizacaoUsuario != null)
                                  Marker(
                                    point: LatLng(
                                      _localizacaoUsuario!.latitude,
                                      _localizacaoUsuario!.longitude,
                                    ),
                                    width: 42,
                                    height: 42,
                                    child: const Tooltip(
                                      message: 'Sua localização',
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.my_location,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            RichAttributionWidget(
                              attributions: [
                                TextSourceAttribution(
                                  '© OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${filtrados.length} ponto(s) de coleta • dados cadastrados pelos usuários',
                              style: const TextStyle(
                                color: verde,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        if (snapshot.hasError)
                          Positioned(
                            top: 58,
                            left: 10,
                            right: 10,
                            child: Card(
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.cloud_off,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AuthService.mensagemErro(
                                          snapshot.error!,
                                        ),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => setState(
                                        () =>
                                            _stream = PontosService.observar(),
                                      ),
                                      child: const Text('Tentar'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_erroLocalizacao != null)
                          Positioned(
                            left: 10,
                            right: 66,
                            bottom: 10,
                            child: Card(
                              color: Colors.white.withValues(alpha: 0.96),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _erroLocalizacao!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: FloatingActionButton.small(
                            heroTag: 'localizar-usuario',
                            tooltip: 'Mostrar minha localização',
                            onPressed: _obtendoLocalizacao
                                ? null
                                : () => _obterLocalizacao(centralizar: true),
                            child: _obtendoLocalizacao
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location),
                          ),
                        ),
                        if (!snapshot.hasData && !snapshot.hasError)
                          const Positioned(
                            top: 62,
                            right: 10,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (todos.isEmpty && !snapshot.hasError)
                          Center(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Ainda não há pontos cadastrados.',
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pushReplacementNamed(
                                            context,
                                            Rotas.pontos,
                                          ),
                                      child: const Text(
                                        'Cadastrar o primeiro ponto',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (selecionado != null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: verde),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selecionado.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: verde,
                          ),
                        ),
                        Text(selecionado.enderecoCompleto),
                        Text(selecionado.materiais.join(' • ')),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => _detalhes(selecionado),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Ver detalhes e rota'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtrados.isNotEmpty)
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.horizontal,
                    itemCount: filtrados.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final ponto = filtrados[index];
                      return ActionChip(
                        label: Text(ponto.nome),
                        avatar: const Icon(Icons.place, size: 18),
                        onPressed: () {
                          setState(() => _selecionadoId = ponto.id);
                          _mapController.move(
                            LatLng(ponto.latitude, ponto.longitude),
                            16,
                          );
                        },
                      );
                    },
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum ponto encontrado. Altere os filtros ou cadastre um ponto.',
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
