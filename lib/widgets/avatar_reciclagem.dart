import 'package:flutter/material.dart';

class AvatarOpcao {
  const AvatarOpcao({
    required this.id,
    required this.nome,
    required this.feminino,
    required this.fundo,
    required this.cabelo,
    required this.camisa,
    required this.pele,
  });

  final String id;
  final String nome;
  final bool feminino;
  final Color fundo;
  final Color cabelo;
  final Color camisa;
  final Color pele;
}

class AvatarReciclagem extends StatelessWidget {
  const AvatarReciclagem({super.key, required this.id, this.size = 88});

  final String? id;
  final double size;

  static const opcoes = <AvatarOpcao>[
    AvatarOpcao(
      id: 'luna',
      nome: 'Luna',
      feminino: true,
      fundo: Color(0xFFDDF3D5),
      cabelo: Color(0xFF38251F),
      camisa: Color(0xFF36A96B),
      pele: Color(0xFFE9B28A),
    ),
    AvatarOpcao(
      id: 'bia',
      nome: 'Bia',
      feminino: true,
      fundo: Color(0xFFFFE9C7),
      cabelo: Color(0xFF713C25),
      camisa: Color(0xFFE18B43),
      pele: Color(0xFF8F5034),
    ),
    AvatarOpcao(
      id: 'flora',
      nome: 'Flora',
      feminino: true,
      fundo: Color(0xFFDDF1F2),
      cabelo: Color(0xFF3A3028),
      camisa: Color(0xFF438D9A),
      pele: Color(0xFFF1C6A3),
    ),
    AvatarOpcao(
      id: 'caio',
      nome: 'Caio',
      feminino: false,
      fundo: Color(0xFFE3EAFB),
      cabelo: Color(0xFF30251F),
      camisa: Color(0xFF5578C8),
      pele: Color(0xFFB86D49),
    ),
    AvatarOpcao(
      id: 'pedro',
      nome: 'Pedro',
      feminino: false,
      fundo: Color(0xFFF8E3D7),
      cabelo: Color(0xFF68442C),
      camisa: Color(0xFFB85C48),
      pele: Color(0xFFF0C39E),
    ),
    AvatarOpcao(
      id: 'leo',
      nome: 'Leo',
      feminino: false,
      fundo: Color(0xFFE8EFD2),
      cabelo: Color(0xFF292D28),
      camisa: Color(0xFF64833C),
      pele: Color(0xFF75462F),
    ),
  ];

  static const padraoId = 'flora';

  static AvatarOpcao opcao(String? id) => opcoes.firstWhere(
    (opcao) => opcao.id == id,
    orElse: () => opcoes.firstWhere((opcao) => opcao.id == padraoId),
  );

  @override
  Widget build(BuildContext context) {
    final avatar = opcao(id);
    return Semantics(
      label: 'Avatar ${avatar.nome}, tema de reciclagem',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _AvatarPainter(avatar)),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.avatar);

  final AvatarOpcao avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas
      ..save()
      ..scale(scale);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 100, 100)));

    final fundo = Paint()..color = avatar.fundo;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), fundo);

    final decoracao = Paint()..color = Colors.white.withValues(alpha: 0.42);
    canvas
      ..drawCircle(const Offset(16, 21), 10, decoracao)
      ..drawCircle(const Offset(82, 28), 13, decoracao);

    final folha = Paint()..color = const Color(0xFF78B957);
    canvas
      ..save()
      ..translate(15, 66)
      ..rotate(-0.7)
      ..drawOval(const Rect.fromLTWH(-3, -10, 12, 22), folha)
      ..restore();

    final roupa = Paint()..color = avatar.camisa;
    final corpo = Path()
      ..moveTo(18, 100)
      ..lineTo(23, 78)
      ..quadraticBezierTo(28, 67, 39, 65)
      ..lineTo(61, 65)
      ..quadraticBezierTo(73, 67, 78, 78)
      ..lineTo(83, 100)
      ..close();
    canvas.drawPath(corpo, roupa);

    if (avatar.feminino) {
      final cabelo = Paint()..color = avatar.cabelo;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(27, 19, 46, 53),
          const Radius.circular(22),
        ),
        cabelo,
      );
    }

    final pele = Paint()..color = avatar.pele;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(31, 24, 38, 43),
          const Radius.circular(18),
        ),
        pele,
      )
      ..drawCircle(const Offset(30, 44), 5, pele)
      ..drawCircle(const Offset(70, 44), 5, pele);

    final cabelo = Paint()..color = avatar.cabelo;
    final topo = Path()
      ..moveTo(29, 38)
      ..quadraticBezierTo(27, 17, 48, 17)
      ..quadraticBezierTo(70, 16, 72, 37)
      ..lineTo(66, 33)
      ..quadraticBezierTo(56, 28, 47, 32)
      ..quadraticBezierTo(39, 35, 29, 38)
      ..close();
    canvas.drawPath(topo, cabelo);

    if (!avatar.feminino) {
      canvas.drawOval(const Rect.fromLTWH(29, 42, 42, 28), cabelo);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 51, 40, 18),
          const Radius.circular(9),
        ),
        pele,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(30, 46, 40, 14),
          const Radius.circular(8),
        ),
        cabelo,
      );
      canvas.drawCircle(
        const Offset(50, 58),
        1.6,
        Paint()..color = avatar.pele,
      );
    } else {
      final cabeloLateral = Path()
        ..moveTo(30, 31)
        ..quadraticBezierTo(22, 44, 29, 61)
        ..lineTo(35, 56)
        ..lineTo(36, 35)
        ..close();
      canvas
        ..drawPath(cabeloLateral, cabelo)
        ..save()
        ..translate(100, 0)
        ..scale(-1, 1)
        ..drawPath(cabeloLateral, cabelo)
        ..restore();
    }

    final olho = Paint()
      ..color = const Color(0xFF35251F)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(const Offset(42, 46), 1.8, olho)
      ..drawCircle(const Offset(58, 46), 1.8, olho)
      ..drawLine(
        const Offset(42, 69),
        const Offset(58, 69),
        Paint()
          ..color = avatar.fundo
          ..strokeWidth = 3,
      );
    canvas.drawArc(
      const Rect.fromLTWH(43, 49, 14, 9),
      0.2,
      2.7,
      false,
      olho..style = PaintingStyle.stroke,
    );

    final badge = Paint()..color = const Color(0xFFFFFFFF);
    canvas
      ..drawCircle(const Offset(75, 76), 12, badge)
      ..save()
      ..translate(75, 76)
      ..rotate(-0.55)
      ..drawOval(
        const Rect.fromLTWH(-5, -7, 10, 14),
        Paint()..color = const Color(0xFF2E9D50),
      )
      ..drawLine(
        const Offset(-1, 5),
        const Offset(2, -2),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      )
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(_AvatarPainter oldDelegate) =>
      oldDelegate.avatar.id != avatar.id;
}
