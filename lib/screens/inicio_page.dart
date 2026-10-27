import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../rotas.dart';
import '../widgets/menu_inferior.dart';
import '../services/auth_service.dart';
import '../widgets/avatar_reciclagem.dart';

class MenuReciclaki extends StatelessWidget {
  const MenuReciclaki({super.key});

  static const List<_OpcaoMenu> _opcoes = [
    _OpcaoMenu(
      titulo: 'Mapa de pontos de coleta',
      imagem: 'assets/renan/mapa_pontos_coleta.png',
      cor: Color(0xFF2E9D50),
    ),
    _OpcaoMenu(
      titulo: 'Cadastro de ponto parceiro',
      imagem: 'assets/renan/ponto_parceiro.png',
      cor: Color(0xFF3C9D9B),
    ),
    _OpcaoMenu(
      titulo: 'Vídeos explicativos',
      imagem: 'assets/renan/videos_claquete.png',
      cor: Color(0xFF75A843),
    ),
    _OpcaoMenu(
      titulo: 'Saiba mais sobre reciclagem',
      imagem: 'assets/renan/livro_reciclagem.png',
      cor: Color(0xFF39865B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReciclaKi'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.sair();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                Rotas.login,
                (_) => false,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const MenuInferior(indice: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/renan/fundo_reciclagem.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: _UsuarioBanner(
                        aoTocar: () =>
                            Navigator.pushNamed(context, Rotas.perfil),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LOGOTIPO
                    Image.asset(
                      'assets/renan/reciclagem.png',
                      width: 105,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.recycling,
                          size: 85,
                          color: Color(0xFF218838),
                        );
                      },
                    ),

                    // NOME COM CONTORNO VERDE
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Reciclaki',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = const Color(0xFF176B35),
                          ),
                        ),
                        const Text(
                          'Reciclaki',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD84D),
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(2, 3),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // FAIXA VERDE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF07552C),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF36A852),
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'RECICLE AQUI, FAÇA A DIFERENÇA!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // QUEBRA-CABEÇA ÚNICO: 2 PEÇAS EM CIMA
                    // E 2 PEÇAS EMBAIXO
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final largura = (constraints.maxWidth - 20) / 2;

                        final altura = largura * 0.92;

                        return SizedBox(
                          width: largura * 2,
                          height: altura * 2,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // PEÇA SUPERIOR ESQUERDA
                              Positioned(
                                left: 0,
                                top: 0,
                                width: largura,
                                height: altura,
                                child: _PecaMenu(
                                  opcao: _opcoes[0],
                                  topo: 0,
                                  direita: 1,
                                  baixo: 1,
                                  esquerda: 0,
                                  aoTocar: () {
                                    _abrirPagina(context, _opcoes[0]);
                                  },
                                ),
                              ),

                              // PEÇA SUPERIOR DIREITA
                              Positioned(
                                left: largura,
                                top: 0,
                                width: largura,
                                height: altura,
                                child: _PecaMenu(
                                  opcao: _opcoes[1],
                                  topo: 0,
                                  direita: 0,
                                  baixo: -1,
                                  esquerda: -1,
                                  aoTocar: () {
                                    _abrirPagina(context, _opcoes[1]);
                                  },
                                ),
                              ),

                              // PEÇA INFERIOR ESQUERDA
                              Positioned(
                                left: 0,
                                top: altura,
                                width: largura,
                                height: altura,
                                child: _PecaMenu(
                                  opcao: _opcoes[2],
                                  topo: -1,
                                  direita: -1,
                                  baixo: 0,
                                  esquerda: 0,
                                  aoTocar: () {
                                    _abrirPagina(context, _opcoes[2]);
                                  },
                                ),
                              ),

                              // PEÇA INFERIOR DIREITA
                              Positioned(
                                left: largura,
                                top: altura,
                                width: largura,
                                height: altura,
                                child: _PecaMenu(
                                  opcao: _opcoes[3],
                                  topo: 1,
                                  direita: 0,
                                  baixo: 0,
                                  esquerda: 1,
                                  aoTocar: () {
                                    _abrirPagina(context, _opcoes[3]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    // RODAPÉ
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF2E9D50),
                          width: 1.2,
                        ),
                      ),
                      child: const Text(
                        'Reciclar é cuidar do nosso futuro.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14532D),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _abrirPagina(BuildContext context, _OpcaoMenu opcao) {
    final destinos = [Rotas.mapa, Rotas.pontos, Rotas.videos, Rotas.quiz];
    Navigator.pushNamed(context, destinos[_opcoes.indexOf(opcao)]);
  }
}

class _UsuarioBanner extends StatefulWidget {
  const _UsuarioBanner({required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  State<_UsuarioBanner> createState() => _UsuarioBannerState();
}

class _UsuarioBannerState extends State<_UsuarioBanner> {
  late final Future<Map<String, dynamic>?> _perfil;

  @override
  void initState() {
    super.initState();
    final usuario = AuthService.auth.currentUser;
    _perfil = usuario == null
        ? Future<Map<String, dynamic>?>.value(null)
        : FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .get()
              .then((documento) => documento.data());
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.auth.currentUser;
    return FutureBuilder<Map<String, dynamic>?>(
      future: _perfil,
      builder: (context, snapshot) {
        final perfil = snapshot.data;
        final nomePerfil = perfil?['nome'];
        final nome = nomePerfil is String && nomePerfil.trim().isNotEmpty
            ? nomePerfil.trim()
            : usuario?.displayName?.trim().isNotEmpty == true
            ? usuario!.displayName!.trim()
            : 'Usuário';
        final avatarId = perfil?['avatarId'] as String?;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.aoTocar,
            borderRadius: BorderRadius.circular(35),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              height: 56,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF07552C),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: const Color(0xFF36A852), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _fotoOuAvatar(usuario?.photoURL, avatarId),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fotoOuAvatar(String? fotoUrl, String? avatarId) {
    final fallback = AvatarReciclagem(id: avatarId, size: 40);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6D9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF45B957), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: fotoUrl == null || fotoUrl.isEmpty
          ? fallback
          : Image.network(
              fotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : fallback,
            ),
    );
  }
}

class _OpcaoMenu {
  final String titulo;
  final String imagem;
  final Color cor;

  const _OpcaoMenu({
    required this.titulo,
    required this.imagem,
    required this.cor,
  });
}

class _PecaMenu extends StatelessWidget {
  final _OpcaoMenu opcao;
  final int topo;
  final int direita;
  final int baixo;
  final int esquerda;
  final VoidCallback aoTocar;

  const _PecaMenu({
    required this.opcao,
    required this.topo,
    required this.direita,
    required this.baixo,
    required this.esquerda,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: aoTocar,
      child: CustomPaint(
        painter: _PintorPeca(
          cor: opcao.cor,
          topo: topo,
          direita: direita,
          baixo: baixo,
          esquerda: esquerda,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Image.asset(
                  opcao.imagem,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 55,
                      color: Colors.white,
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    opcao.titulo,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PintorPeca extends CustomPainter {
  final Color cor;

  // 0 = borda reta
  // 1 = saliência para fora
  // -1 = reentrância para dentro
  final int topo;
  final int direita;
  final int baixo;
  final int esquerda;

  const _PintorPeca({
    required this.cor,
    required this.topo,
    required this.direita,
    required this.baixo,
    required this.esquerda,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const profundidade = 12.0;
    const raio = 13.0;

    final caminho = Path()..moveTo(raio, 0);

    // TOPO: da esquerda para a direita
    _desenharBorda(
      caminho,
      Offset(0, 0),
      Offset(size.width, 0),
      topo,
      profundidade,
    );

    // CANTO SUPERIOR DIREITO
    caminho.lineTo(size.width, raio);

    caminho.quadraticBezierTo(size.width, 0, size.width - raio, 0);

    // A borda direita precisa continuar de cima para baixo.
    // Reconstrói a borda usando um percurso contínuo.
    final forma = _criarForma(size, profundidade, raio);

    final tinta = Paint()
      ..color = cor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawShadow(forma, Colors.black.withValues(alpha: 0.18), 4, true);

    canvas.drawPath(forma, tinta);

    final contorno = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;

    canvas.drawPath(forma, contorno);
  }

  Path _criarForma(Size size, double profundidade, double raio) {
    final path = Path();

    // Começa no canto superior esquerdo.
    path.moveTo(0, 0);

    // Borda superior: esquerda para direita.
    _desenharBorda(
      path,
      Offset(0, 0),
      Offset(size.width, 0),
      topo,
      profundidade,
    );

    // Borda direita: cima para baixo.
    _desenharBorda(
      path,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      direita,
      profundidade,
    );

    // Borda inferior: direita para esquerda.
    _desenharBorda(
      path,
      Offset(size.width, size.height),
      Offset(0, size.height),
      baixo,
      profundidade,
    );

    // Borda esquerda: baixo para cima.
    _desenharBorda(
      path,
      Offset(0, size.height),
      Offset(0, 0),
      esquerda,
      profundidade,
    );

    path.close();
    return path;
  }

  void _desenharBorda(
    Path path,
    Offset inicio,
    Offset fim,
    int tipo,
    double profundidade,
  ) {
    final dx = fim.dx - inicio.dx;
    final dy = fim.dy - inicio.dy;
    final comprimento = (dx * dx + dy * dy) == 0
        ? 1.0
        : math.sqrt(dx * dx + dy * dy);

    final tx = dx / comprimento;
    final ty = dy / comprimento;

    // Normal externa para um caminho percorrido no sentido horário.
    final nx = -ty;
    final ny = tx;

    Offset ponto(double distancia, double fora) {
      return Offset(
        inicio.dx + tx * distancia + nx * fora,
        inicio.dy + ty * distancia + ny * fora,
      );
    }

    if (tipo == 0 || comprimento < 50) {
      path.lineTo(fim.dx, fim.dy);
      return;
    }

    final inicioEncaixe = comprimento * 0.35;
    final fimEncaixe = comprimento * 0.65;
    final larguraEncaixe = fimEncaixe - inicioEncaixe;
    final sinal = tipo > 0 ? 1.0 : -1.0;
    final altura = profundidade * sinal;

    path.lineTo(inicio.dx + tx * inicioEncaixe, inicio.dy + ty * inicioEncaixe);

    path.cubicTo(
      ponto(inicioEncaixe + larguraEncaixe * 0.10, 0).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.10, 0).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.08, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.08, altura).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.28, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.28, altura).dy,
    );

    path.cubicTo(
      ponto(inicioEncaixe + larguraEncaixe * 0.36, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.36, altura).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.36, altura * 1.45).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.36, altura * 1.45).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.50, altura * 1.45).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.50, altura * 1.45).dy,
    );

    path.cubicTo(
      ponto(inicioEncaixe + larguraEncaixe * 0.64, altura * 1.45).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.64, altura * 1.45).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.64, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.64, altura).dy,
      ponto(inicioEncaixe + larguraEncaixe * 0.72, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.72, altura).dy,
    );

    path.cubicTo(
      ponto(inicioEncaixe + larguraEncaixe * 0.92, altura).dx,
      ponto(inicioEncaixe + larguraEncaixe * 0.92, altura).dy,
      ponto(fimEncaixe - larguraEncaixe * 0.10, 0).dx,
      ponto(fimEncaixe - larguraEncaixe * 0.10, 0).dy,
      ponto(fimEncaixe, 0).dx,
      ponto(fimEncaixe, 0).dy,
    );

    path.lineTo(fim.dx, fim.dy);
  }

  @override
  bool shouldRepaint(covariant _PintorPeca oldDelegate) {
    return oldDelegate.cor != cor ||
        oldDelegate.topo != topo ||
        oldDelegate.direita != direita ||
        oldDelegate.baixo != baixo ||
        oldDelegate.esquerda != esquerda;
  }
}
