import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/menu_inferior.dart';

class TelaMapaColeta extends StatefulWidget {
  const TelaMapaColeta({super.key});
  @override
  State<TelaMapaColeta> createState() => _TelaMapaColetaState();
}

class _TelaMapaColetaState extends State<TelaMapaColeta> {
  // Filtro ativo (0 = Bairro, 1 = Material, 2 = Mais perto)
  int filtroAtivo = 0;
  // Texto digitado no filtro de Bairro
  String? bairroFiltro;
  // Material escolhido no filtro de Material
  String? materialFiltro;
  // Controla se o filtro "Mais perto" está ativo
  bool ordenarPorDistancia = false;
  // Ponto de coleta selecionado
  PontoColeta? pontoSelecionado;
  // Lista completa de pontos de coleta
  final List<PontoColeta> pontos = const [
    PontoColeta(
      id: 1,
      nome: 'EcoPonto Centro',
      endereco: 'Rua das Flores, 120',
      bairro: 'Centro',
      materiais: ['Papel', 'Plástico', 'Vidro'],
      distanciaKm: 0.8,
      horario: 'Seg a Sáb - 08h às 18h',
      latitude: -21.13056,
      longitude: -42.36639,
      cor: Color(0xFF78B82A),
    ),
    PontoColeta(
      id: 2,
      nome: 'Coleta Seletiva Jardim',
      endereco: 'Av. das Palmeiras, 45',
      bairro: 'Jardim',
      materiais: ['Plástico', 'Metal'],
      distanciaKm: 1.5,
      horario: 'Seg a Sex - 09h às 17h',
      latitude: -21.12790,
      longitude: -42.36290,
      cor: Color(0xFF1599D4),
    ),
    PontoColeta(
      id: 3,
      nome: 'Ponto Verde Universitário',
      endereco: 'Rua do Saber, 300',
      bairro: 'Universitário',
      materiais: ['Papel', 'Vidro', 'Eletrônicos'],
      distanciaKm: 2.2,
      horario: 'Todos os dias - 07h às 20h',
      latitude: -21.13400,
      longitude: -42.36900,
      cor: Color(0xFFF39A18),
    ),
    PontoColeta(
      id: 4,
      nome: 'Ecoponto Vila Nova',
      endereco: 'Rua da Esperança, 88',
      bairro: 'Vila Nova',
      materiais: ['Óleo de Cozinha', 'Pilhas e Baterias'],
      distanciaKm: 3.1,
      horario: 'Seg a Sáb - 08h às 16h',
      latitude: -21.12550,
      longitude: -42.36800,
      cor: Color(0xFF7E4DA7),
    ),
    PontoColeta(
      id: 5,
      nome: 'EcoPonto Jardim Botânico',
      endereco: 'Rua das Acácias, 210',
      bairro: 'Jardim',
      materiais: ['Papel', 'Plástico', 'Metal', 'Vidro'],
      distanciaKm: 1.2,
      horario: 'Seg a Sáb - 08h às 18h',
      latitude: -21.13650,
      longitude: -42.36200,
      cor: Color(0xFF39A94B),
    ),
    PontoColeta(
      id: 6,
      nome: 'Ponto Verde Centro',
      endereco: 'Praça Central, 10',
      bairro: 'Centro',
      materiais: ['Eletrônicos', 'Pilhas e Baterias'],
      distanciaKm: 0.5,
      horario: 'Todos os dias - 08h às 20h',
      latitude: -21.13300,
      longitude: -42.37100,
      cor: Color(0xFFE84F3C),
    ),
  ];
  // Lista completa de materiais recicláveis disponíveis para filtro
  final List<String> materiaisDisponiveis = const [
    'Papel',
    'Plástico',
    'Vidro',
    'Metal',
    'Eletrônicos',
    'Pilhas e Baterias',
    'Óleo de Cozinha',
    'Orgânico',
    'Isopor',
    'Lâmpadas',
    'Medicamentos',
    'Têxteis',
    'Madeira',
    'Borracha',
    'Entulho',
  ];
  // --------------------------------------------------
  // LISTA FILTRADA (usada no mapa E no cartão)
  // --------------------------------------------------
  List<PontoColeta> get pontosFiltrados {
    List<PontoColeta> resultado = List.from(pontos);
    if (bairroFiltro != null && bairroFiltro!.trim().isNotEmpty) {
      final termo = bairroFiltro!.trim().toLowerCase();
      resultado = resultado
          .where((p) => p.bairro.toLowerCase().contains(termo))
          .toList();
    }
    if (materialFiltro != null) {
      resultado = resultado
          .where((p) => p.materiais.contains(materialFiltro))
          .toList();
    }
    if (ordenarPorDistancia) {
      resultado.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
    }
    return resultado;
  }

  void abrirTela(String nomeDaTela) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrir tela: $nomeDaTela'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void selecionarPonto(PontoColeta ponto) {
    setState(() {
      pontoSelecionado = ponto;
    });
  }

  // --------------------------------------------------
  // AÇÃO DOS BOTÕES DE FILTRO
  // --------------------------------------------------
  Future<void> _acaoFiltro(int indice) async {
    setState(() {
      filtroAtivo = indice;
    });
    if (indice == 0) {
      await _abrirDialogoBairro();
    } else if (indice == 1) {
      await _abrirListaMateriais();
    } else if (indice == 2) {
      setState(() {
        ordenarPorDistancia = true;
        bairroFiltro = null;
        materialFiltro = null;
        if (pontoSelecionado != null &&
            !pontosFiltrados.any((p) => p.id == pontoSelecionado!.id)) {
          pontoSelecionado = null;
        }
      });
    }
  }

  // Future<void> _abrirDialogoBairro() async {
  //     debugPrint('>>> entrou no _abrirDialogoBairro');
  //     debugPrint('>>> context: $context');
  //     debugPrint('>>> Navigator: ${Navigator.maybeOf(context)}');
  //     debugPrint('>>> mounted: $mounted');
  //   final controller = TextEditingController(text: bairroFiltro ?? '');
  //   final resultado = await showDialog<String>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(18),
  //         ),
  //         title: const Text(
  //           'Buscar por Bairro',
  //           style: TextStyle(
  //             color: Color(0xFF075B36),
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         content: TextField(
  //           controller: controller,
  //           autofocus: true,
  //           decoration: InputDecoration(
  //             hintText: 'Ex.: Centro, Jardim...',
  //             prefixIcon: const Icon(
  //               Icons.location_city,
  //               color: Color(0xFF075B36),
  //             ),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               borderSide: const BorderSide(
  //                 color: Color(0xFF075B36),
  //                 width: 2,
  //               ),
  //             ),
  //           ),
  //           onSubmitted: (valor) => Navigator.pop(context, valor),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context, ''),
  //             child: const Text(
  //               'LIMPAR',
  //               style: TextStyle(color: Colors.black54),
  //             ),
  //           ),
  //           ElevatedButton(
  //             onPressed: () => Navigator.pop(context, controller.text),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF075B36),
  //               foregroundColor: Colors.white,
  //             ),
  //             child: const Text('BUSCAR'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   if (resultado != null) {
  //     setState(() {
  //       bairroFiltro =
  //           resultado.trim().isEmpty ? null : resultado.trim();
  //       materialFiltro = null;
  //       ordenarPorDistancia = false;
  //       if (bairroFiltro == null) {
  //         filtroAtivo = 0;
  //       }
  //       if (pontoSelecionado != null &&
  //           !pontosFiltrados.any((p) => p.id == pontoSelecionado!.id)) {
  //         pontoSelecionado = null;
  //       }
  //     });
  //   }
  // }
  Future<void> _abrirDialogoBairro() async {
    final controller = TextEditingController(text: bairroFiltro ?? '');
    final resultado = await showDialog<String>(
      context: context,
      useRootNavigator: true, // <-- ESSA LINHA
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Buscar por Bairro',
            style: TextStyle(
              color: Color(0xFF075B36),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ex.: Centro, Jardim...',
              prefixIcon: const Icon(
                Icons.location_city,
                color: Color(0xFF075B36),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (valor) => Navigator.pop(context, valor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('LIMPAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075B36),
                foregroundColor: Colors.white,
              ),
              child: const Text('BUSCAR'),
            ),
          ],
        );
      },
    );
    if (resultado != null) {
      setState(() {
        bairroFiltro = resultado.trim().isEmpty ? null : resultado.trim();
        materialFiltro = null;
        ordenarPorDistancia = false;
        if (bairroFiltro == null) filtroAtivo = 0;
        if (pontoSelecionado != null &&
            !pontosFiltrados.any((p) => p.id == pontoSelecionado!.id)) {
          pontoSelecionado = null;
        }
      });
    }
  }

  Future<void> _abrirListaMateriais() async {
    final escolhido = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Escolha um Material',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF075B36),
                    ),
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: materiaisDisponiveis.length,
                    itemBuilder: (context, index) {
                      final material = materiaisDisponiveis[index];
                      final selecionado = material == materialFiltro;
                      return ListTile(
                        leading: Icon(
                          Icons.recycling,
                          color: selecionado
                              ? const Color(0xFF075B36)
                              : Colors.black45,
                        ),
                        title: Text(
                          material,
                          style: TextStyle(
                            fontWeight: selecionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selecionado
                                ? const Color(0xFF075B36)
                                : Colors.black87,
                          ),
                        ),
                        trailing: selecionado
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF075B36),
                              )
                            : null,
                        onTap: () => Navigator.pop(context, material),
                      );
                    },
                  ),
                ),
                const Divider(),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, '__LIMPAR__'),
                  icon: const Icon(Icons.clear, color: Colors.black54),
                  label: const Text(
                    'LIMPAR FILTRO',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (escolhido != null) {
      setState(() {
        if (escolhido == '__LIMPAR__') {
          materialFiltro = null;
          filtroAtivo = 0;
        } else {
          materialFiltro = escolhido;
          bairroFiltro = null;
          ordenarPorDistancia = false;
        }
        if (pontoSelecionado != null &&
            !pontosFiltrados.any((p) => p.id == pontoSelecionado!.id)) {
          pontoSelecionado = null;
        }
      });
    }
  }
  // --------------------------------------------------
  // TAMANHO DO MARCADOR
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final filtrados = pontosFiltrados;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8E8),
      // ------------------------------------------------
      // APP BAR
      // ------------------------------------------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF075B36),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pontos de Coleta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ======================================
            // OPÇÕES DE BUSCA
            // ======================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  _botaoFiltro(
                    indice: 0,
                    icone: Icons.location_city,
                    texto: 'Bairro',
                  ),
                  const SizedBox(width: 8),
                  _botaoFiltro(
                    indice: 1,
                    icone: Icons.recycling,
                    texto: 'Material',
                  ),
                  const SizedBox(width: 8),
                  _botaoFiltro(
                    indice: 2,
                    icone: Icons.my_location,
                    texto: 'Distância demo',
                  ),
                ],
              ),
            ),
            // Chip do filtro ativo
            if (bairroFiltro != null ||
                materialFiltro != null ||
                ordenarPorDistancia)
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 14, bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt,
                      size: 16,
                      color: Color(0xFF075B36),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bairroFiltro != null
                            ? 'Bairro: $bairroFiltro'
                            : materialFiltro != null
                            ? 'Material: $materialFiltro'
                            : 'Ordenado por distâncias de exemplo',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF075B36),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${filtrados.length} resultado(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          bairroFiltro = null;
                          materialFiltro = null;
                          ordenarPorDistancia = false;
                          filtroAtivo = 0;
                          pontoSelecionado = null;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF075B36),
                      ),
                    ),
                  ],
                ),
              ),
            // ======================================
            // MAPA REAL DE MURIAÉ (OPENSTREETMAP)
            // ======================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(-21.13056, -42.36639),
                          initialZoom: 14,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.reciclaki',
                          ),
                          MarkerLayer(
                            markers: [
                              for (final ponto in filtrados)
                                Marker(
                                  point: LatLng(
                                    ponto.latitude,
                                    ponto.longitude,
                                  ),
                                  width: 46,
                                  height: 46,
                                  child: _marcador(ponto),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.map,
                                    size: 16,
                                    color: Color(0xFF075B36),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Muriaé, MG • mapa real',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF075B36),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Marcadores de exemplo: locais e coordenadas ainda não confirmados.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (filtrados.isEmpty)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 40,
                                  color: Color(0xFF075B36),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Nenhum ponto encontrado\\npara este filtro.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF075B36),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ======================================
            // CARTÃO INFERIOR DINÂMICO
            // ======================================
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: pontoSelecionado == null
                  ? _cartaoInstrucao(filtrados.length)
                  : _cartaoPonto(pontoSelecionado!),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      // ------------------------------------------------
      // MENU INFERIOR
      // ------------------------------------------------
      bottomNavigationBar: const MenuInferior(indice: 2),
    );
  }

  // ------------------------------------------------
  // BOTÃO DE FILTRO
  // ------------------------------------------------
  Widget _botaoFiltro({
    required int indice,
    required IconData icone,
    required String texto,
  }) {
    final ativo = filtroAtivo == indice;
    return Expanded(
      child: GestureDetector(
        // ***** PONTO-CHAVE: chama a ação que abre o diálogo/lista *****
        // onTap: () => _acaoFiltro(indice),
        onTap: () {
          debugPrint('CLICOU no filtro $indice');
          _acaoFiltro(indice);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? const Color(0xFF075B36) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF075B36), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icone,
                color: ativo ? Colors.white : const Color(0xFF075B36),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ativo ? Colors.white : const Color(0xFF075B36),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // MARCADOR DO MAPA
  // ------------------------------------------------
  Widget _marcador(PontoColeta ponto) {
    final selecionado = pontoSelecionado?.id == ponto.id;
    return GestureDetector(
      onTap: () => selecionarPonto(ponto),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selecionado ? 46 : 38,
        height: selecionado ? 46 : 38,
        decoration: BoxDecoration(
          color: ponto.cor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: selecionado ? 4 : 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: selecionado ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.recycling,
          color: Colors.white,
          size: selecionado ? 24 : 20,
        ),
      ),
    );
  }

  // ------------------------------------------------
  // CARTÃO DE INSTRUÇÃO
  // ------------------------------------------------
  Widget _cartaoInstrucao(int total) {
    return Container(
      key: const ValueKey('instrucao'),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.touch_app,
              color: Color(0xFF075B36),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == 0
                  ? 'Nenhum ponto corresponde ao filtro atual. Toque no X acima para limpar.'
                  : 'Toque em um marcador no mapa para ver os detalhes do ponto de coleta.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF075B36),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // CARTÃO DO PONTO SELECIONADO
  // ------------------------------------------------
  Widget _cartaoPonto(PontoColeta ponto) {
    return Container(
      key: ValueKey(ponto.id),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ponto.cor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ponto.cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.recycling, color: ponto.cor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ponto.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF075B36),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ponto.endereco} - ${ponto.bairro}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoItem(
                icone: Icons.category,
                texto: ponto.materiais.join(', '),
              ),
              const SizedBox(width: 10),
              _infoItem(
                icone: Icons.directions_walk,
                texto: ponto.distanciaFormatada,
              ),
            ],
          ),
          const SizedBox(height: 6),
          _infoItem(icone: Icons.access_time, texto: ponto.horario),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                abrirTela('Detalhes: ${ponto.nome}');
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text(
                'VER DETALHES',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ponto.cor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem({required IconData icone, required String texto}) {
    return Expanded(
      child: Row(
        children: [
          Icon(icone, size: 15, color: const Color(0xFF075B36)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF075B36),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// MODELO DE PONTO DE COLETA
// ----------------------------------------------------
class PontoColeta {
  final int id;
  final String nome;
  final String endereco;
  final String bairro;
  final List<String> materiais;
  final double distanciaKm;
  final String horario;
  final double latitude;
  final double longitude;
  final Color cor;
  const PontoColeta({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.bairro,
    required this.materiais,
    required this.distanciaKm,
    required this.horario,
    required this.latitude,
    required this.longitude,
    required this.cor,
  });
  String get distanciaFormatada {
    if (distanciaKm < 1) {
      return '${(distanciaKm * 1000).round()} m';
    }
    return '${distanciaKm.toStringAsFixed(1)} km';
  }
}
