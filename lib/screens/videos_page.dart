import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/menu_inferior.dart';

class VideoItem {
  final int id;
  final String titulo;
  final String descricao;
  final String youtubeId;
  final String youtubeUrl;

  const VideoItem({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.youtubeId,
    required this.youtubeUrl,
  });
}

// ============================================================
// TELA PRINCIPAL
// ============================================================

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});

  static const String fraseEducativa =
      '🌱 Pequenas atitudes transformam o planeta e a sua vida: '
      'recicle seu lixo!';

  // ==========================================================
  // LISTA DE VÍDEOS
  // ==========================================================

  static const List<VideoItem> videos = [
    VideoItem(
      id: 1,
      titulo: 'Como Separar o Lixo',
      descricao:
          'Aprenda as cores das lixeiras e o descarte correto '
          'de forma divertida.',
      youtubeId: 'ahQCQMhzIA4',
      youtubeUrl: 'https://www.youtube.com/watch?v=ahQCQMhzIA4',
    ),
    VideoItem(
      id: 2,
      titulo: 'A Turminha da Reciclagem',
      descricao:
          'Descubra os 3Rs: Reduzir, Reutilizar e Reciclar '
          'com a turminha.',
      youtubeId: 'er4CuSBqC5A',
      youtubeUrl: 'https://www.youtube.com/watch?v=er4CuSBqC5A',
    ),
    VideoItem(
      id: 3,
      titulo: 'Dicas Sobre Reciclagem',
      descricao:
          'Aprenda com músicas e historinhas sobre como '
          'cuidar da natureza.',
      youtubeId: 'Aui4cjxwvWc',
      youtubeUrl: 'https://www.youtube.com/watch?v=Aui4cjxwvWc',
    ),
  ];

  // ==========================================================
  // ABRIR VÍDEO NO YOUTUBE
  // ==========================================================

  Future<void> _abrirVideo(BuildContext context, VideoItem video) async {
    final Uri url = Uri.parse(video.youtubeUrl);

    try {
      final bool abriu = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!abriu && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao abrir vídeo: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro ao tentar abrir o vídeo.'),
          ),
        );
      }
    }
  }

  // ==========================================================
  // CONSTRUÇÃO DA TELA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MenuInferior(indice: 3),
      extendBodyBehindAppBar: true,

      // ------------------------------------------------------
      // BARRA SUPERIOR
      // ------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.93),
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 3,
        centerTitle: true,

        title: Image.asset(
          'assets/rodrigo/logo_reciclaki.jpg',
          height: 44,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'RECICLAKI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 21,
                color: Color(0xFF1B5E20),
              ),
            );
          },
        ),
      ),

      // ------------------------------------------------------
      // CORPO DA TELA
      // ------------------------------------------------------
      body: Stack(
        children: [
          // -----------------------------------------------
          // IMAGEM DE FUNDO
          // -----------------------------------------------
          Positioned.fill(
            child: Image.asset(
              'assets/rodrigo/fundo_reciclaki.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF81D4FA), Color(0xFFE8F5E9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Imagem de fundo não encontrada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // -----------------------------------------------
          // CAMADA DE TRANSPARÊNCIA
          // -----------------------------------------------
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.18)),
          ),

          // -----------------------------------------------
          // CONTEÚDO PRINCIPAL
          // -----------------------------------------------
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 750),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  children: [
                    // Cabeçalho educativo.
                    _buildHeader(),

                    const SizedBox(height: 18),

                    // Lista de vídeos com rolagem.
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final VideoItem video = videos[index];

                          return _buildVideoCard(context, video);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CABEÇALHO EDUCATIVO
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎬 VÍDEOS EDUCATIVOS 🌎',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1B5E20),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            fraseEducativa,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF455A64),
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Categorias educativas.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildMiniCategory('♻️', 'Reciclar'),
              _buildMiniCategory('🌱', 'Cuidar'),
              _buildMiniCategory('🌎', 'Preservar'),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORIAS
  // ==========================================================

  Widget _buildMiniCategory(String emoji, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),

          const SizedBox(width: 5),

          Text(
            texto,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARTÃO DOS VÍDEOS
  // ==========================================================

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------
            // MINIATURA DO VÍDEO
            // -----------------------------------------------
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Imagem da miniatura.
                  Image.network(
                    'https://img.youtube.com/vi/'
                    '${video.youtubeId}/hqdefault.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        color: const Color(0xFFE8F5E9),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 65,
                              color: Color(0xFF4CAF50),
                            ),

                            SizedBox(height: 8),

                            Text(
                              'Vídeo educativo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // -----------------------------------------
                  // SOMBRA SOBRE A MINIATURA
                  // -----------------------------------------
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),

                  // -----------------------------------------
                  // BOTÃO DE REPRODUÇÃO
                  // -----------------------------------------
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _abrirVideo(context, video),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  ),

                  // -----------------------------------------
                  // IDENTIFICAÇÃO DO VÍDEO
                  // -----------------------------------------
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'VÍDEO ${video.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // -----------------------------------------------
            // TÍTULO DO VÍDEO
            // -----------------------------------------------
            Text(
              '${video.id}. ${video.titulo}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B5E20),
                fontSize: 19,
              ),
            ),

            const SizedBox(height: 7),

            // -----------------------------------------------
            // DESCRIÇÃO DO VÍDEO
            // -----------------------------------------------
            Text(
              video.descricao,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF455A64),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            // -----------------------------------------------
            // BOTÃO PARA ASSISTIR
            // -----------------------------------------------
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _abrirVideo(context, video),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Assistir vídeo'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
