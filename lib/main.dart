import 'package:flutter/material.dart';

void main() {
  runApp(const ReciclakiApp());
}

// ----------------------------------------------------
// APLICATIVO
// ----------------------------------------------------

class ReciclakiApp extends StatelessWidget {
  const ReciclakiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Reciclaki',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),

      home: const TelaInicial(),
    );
  }
}

// ----------------------------------------------------
// TELA INICIAL --
// ----------------------------------------------------

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {

  // O número 2 representa o botão INÍCIO
  // no menu inferior.
  int paginaSelecionada = 2;

  // --------------------------------------------------
  // FUNÇÃO TEMPORÁRIA DOS BOTÕES
  // --------------------------------------------------

  void abrirTela(String nomeDaTela) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Abrir tela: $nomeDaTela',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Cor de fundo da tela
      backgroundColor: const Color(0xFFF4F8E8),

      // ------------------------------------------------
      // CORPO DA TELA
      // ------------------------------------------------

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),

            child: Column(

              children: [

                const SizedBox(height: 10),

                // ======================================
                // TOPO
                // ======================================

                linhaSuperior(),

                const SizedBox(height: 10),

                // ======================================
                // LOGO
                // ======================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),

                  child: Image.asset(
                    'assets/images/logo_reciclaki.jpg',

                    height: 150,

                    fit: BoxFit.contain,
                  ),
                ),

                // ======================================
                // FRASE ABAIXO DA LOGO
                // ======================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(

                    color: const Color(0xFF176A38),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'RECICLE AQUI, FAÇA A DIFERENÇA!',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ======================================
                // PRIMEIRA LINHA
                // ======================================

                Row(
                  children: [

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'CADASTRO\nDO USUÁRIO',
                        icone: Icons.person,
                        cor: Color(0xFF78B82A),

                        aoClicar: () {
                          abrirTela(
                            'Cadastro do Usuário',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'MAPA DE\nPONTOS DE COLETA',
                        icone: Icons.map,
                        cor: Color(0xFF1599D4),

                        aoClicar: () {
                          abrirTela(
                            'Mapa de Pontos de Coleta',
                          );
                        },
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                // ======================================
                // SEGUNDA LINHA
                // ======================================

                Row(
                  children: [

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'CADASTRO DE\nPONTO PARCEIRO',
                        icone: Icons.handshake,
                        cor: Color(0xFFF39A18),

                        aoClicar: () {
                          abrirTela(
                            'Cadastro de Ponto Parceiro',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'VÍDEOS\nSOBRE RECICLAGEM',
                        icone: Icons.smart_display,
                        cor: Color(0xFF7E4DA7),

                        aoClicar: () {
                          abrirTela(
                            'Vídeos sobre Reciclagem',
                          );
                        },
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                // ======================================
                // TERCEIRA LINHA
                // ======================================

                Row(
                  children: [

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'MONTE SEU\nAVATAR',
                        icone: Icons.face,
                        cor: Color(0xFF149B78),

                        aoClicar: () {
                          abrirTela(
                            'Monte seu Avatar',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'SAIBA MAIS\nSOBRE RECICLAGEM',
                        icone: Icons.menu_book,
                        cor: Color(0xFFE84F3C),

                        aoClicar: () {
                          abrirTela(
                            'Saiba Mais',
                          );
                        },
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 10),

                // ======================================
                // QUARTA LINHA
                // ======================================

                Row(
                  children: [

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'DESCARTE E\nGANHE PONTOS',
                        icone: Icons.emoji_events,
                        cor: Color(0xFFE9AB16),

                        aoClicar: () {
                          abrirTela(
                            'Descarte e Ganhe Pontos',
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: MenuReciclaki(
                        titulo: 'RECOMPENSAS\nE TROCAS',
                        icone: Icons.card_giftcard,
                        cor: Color(0xFF39A94B),

                        aoClicar: () {
                          abrirTela(
                            'Recompensas e Trocas',
                          );
                        },
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 15),

                // ======================================
                // VOCÊ NO JOGO
                // ======================================

                Container(

                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 14,
                  ),

                  decoration: BoxDecoration(

                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0576B7),
                        Color(0xFF0D97C8),
                      ],
                    ),

                    borderRadius: BorderRadius.circular(17),

                    boxShadow: const [

                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),

                    ],
                  ),

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      const Icon(
                        Icons.sports_esports,
                        color: Colors.white,
                        size: 38,
                      ),

                      const SizedBox(width: 12),

                      Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(
                            'VOCÊ NO JOGO',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Transforme sua cidade peça por peça!',

                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.9),

                              fontSize: 11,
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),

      // ------------------------------------------------
      // MENU INFERIOR
      // ------------------------------------------------

      bottomNavigationBar: Container(

        decoration: const BoxDecoration(

          boxShadow: [

            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
            ),

          ],
        ),

        child: NavigationBar(

          selectedIndex: paginaSelecionada,

          backgroundColor:
              const Color(0xFF075B36),

          indicatorColor:
              const Color(0xFF88C52F),

          height: 70,

          labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,

          onDestinationSelected: (indice) {

            setState(() {
              paginaSelecionada = indice;
            });

            if (indice != 2) {

              final nomes = [

                'Desafios',
                'Conquistas',
                'Início',
                'Recompensas',
                'Ranking',

              ];

              abrirTela(nomes[indice]);
            }
          },

          destinations: const [

            NavigationDestination(

              icon: Icon(
                Icons.emoji_events_outlined,
                color: Colors.white,
              ),

              selectedIcon: Icon(
                Icons.emoji_events,
                color: Colors.white,
              ),

              label: 'Desafios',
            ),

            NavigationDestination(

              icon: Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
              ),

              selectedIcon: Icon(
                Icons.workspace_premium,
                color: Colors.white,
              ),

              label: 'Conquistas',
            ),

            NavigationDestination(

              icon: Icon(
                Icons.home_outlined,
                color: Colors.white,
              ),

              selectedIcon: Icon(
                Icons.home,
                color: Colors.white,
              ),

              label: 'Início',
            ),

            NavigationDestination(

              icon: Icon(
                Icons.card_giftcard_outlined,
                color: Colors.white,
              ),

              selectedIcon: Icon(
                Icons.card_giftcard,
                color: Colors.white,
              ),

              label: 'Prêmios',
            ),

            NavigationDestination(

              icon: Icon(
                Icons.leaderboard_outlined,
                color: Colors.white,
              ),

              selectedIcon: Icon(
                Icons.leaderboard,
                color: Colors.white,
              ),

              label: 'Ranking',
            ),

          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // PARTE SUPERIOR
  // ----------------------------------------------------

  Widget linhaSuperior() {

    return Row(

      children: [

        // FOTO / AVATAR

        Container(

          width: 55,
          height: 55,

          decoration: BoxDecoration(

            color: const Color(0xFF7DBB32),

            shape: BoxShape.circle,

            border: Border.all(
              color: Colors.white,
              width: 3,
            ),

            boxShadow: const [

              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
              ),

            ],
          ),

          child: const Icon(
            Icons.person,
            size: 36,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 7),

        // NÍVEL

        Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              decoration: BoxDecoration(

                color: const Color(0xFF075B36),

                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: const Text(
                'NÍVEL 7',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              '1250 / 2000',

              style: TextStyle(
                color: Color(0xFF075B36),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const Spacer(),

        // PONTOS

        Container(

          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius:
                BorderRadius.circular(20),

            boxShadow: const [

              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
              ),

            ],
          ),

          child: const Row(

            children: [

              Icon(
                Icons.eco,
                color: Color(0xFF77A927),
                size: 27,
              ),

              SizedBox(width: 5),

              Column(

                children: [

                  Text(
                    '850',

                    style: TextStyle(
                      color: Color(0xFF075B36),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'PONTOS',

                    style: TextStyle(
                      color: Color(0xFF075B36),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),

            ],
          ),
        ),

      ],
    );
  }
}

// ----------------------------------------------------
// BOTÃO / CARD DO MENU
// ----------------------------------------------------

class MenuReciclaki extends StatelessWidget {

  final String titulo;

  final IconData icone;

  final Color cor;

  final VoidCallback aoClicar;

  const MenuReciclaki({
    super.key,
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.aoClicar,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      onTap: aoClicar,

      borderRadius: BorderRadius.circular(18),

      child: Container(

        height: 145,

        decoration: BoxDecoration(

          color: cor,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: Colors.white,
            width: 3,
          ),

          boxShadow: const [

            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),

          ],
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // CÍRCULO DO ÍCONE

            Container(

              width: 67,
              height: 67,

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(17),

                boxShadow: const [

                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),

                ],
              ),

              child: Icon(
                icone,
                size: 43,
                color: cor,
              ),
            ),

            const SizedBox(height: 10),

            // TEXTO

            Text(
              titulo,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(

                color: Colors.white,

                fontSize: 12,

                fontWeight:
                    FontWeight.bold,

                height: 1.1,

                shadows: [

                  Shadow(
                    color: Colors.black38,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}