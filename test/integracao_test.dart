import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reciclaki_integrado/screens/login_page.dart';
import 'package:reciclaki_integrado/screens/cadastro_page.dart';
import 'package:reciclaki_integrado/screens/ponto_coleta_page.dart';
import 'package:reciclaki_integrado/rotas.dart';
import 'package:reciclaki_integrado/services/geocodificacao_service.dart';
import 'package:reciclaki_integrado/widgets/avatar_reciclagem.dart';

void main() {
  testWidgets('Login abre cadastro e permite voltar', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        routes: {Rotas.cadastro: (_) => const CriarContaPage()},
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Realizar cadastro'));
    await tester.pumpAndSettle();
    expect(find.byType(CriarContaPage), findsOneWidget);
    final voltar = find.text('Já tenho uma conta — voltar ao login');
    await tester.ensureVisible(voltar);
    await tester.tap(voltar);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login valida campos obrigatórios antes de autenticar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Digite seu e-mail.'), findsOneWidget);
    expect(find.text('Digite sua senha.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Avatares oferecem três opções femininas e três masculinas', () {
    expect(AvatarReciclagem.opcoes, hasLength(6));
    expect(
      AvatarReciclagem.opcoes.where((avatar) => avatar.feminino),
      hasLength(3),
    );
    expect(
      AvatarReciclagem.opcoes.where((avatar) => !avatar.feminino),
      hasLength(3),
    );
  });

  test('Parser do Nominatim extrai rua, número e bairro', () {
    final endereco = EnderecoGeocodificado.fromJson({
      'address': {
        'road': 'Rua das Flores',
        'house_number': '42',
        'suburb': 'Centro',
      },
    });

    expect(endereco.endereco, 'Rua das Flores');
    expect(endereco.numero, '42');
    expect(endereco.bairro, 'Centro');
  });

  testWidgets('Horário padrão dos dias selecionados é 08:00–18:00', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        home: const CadastroPontoColeta(),
      ),
    );
    await tester.pumpAndSettle();

    final configurar = find.text('Toque para configurar');
    await tester.ensureVisible(configurar);
    await tester.tap(configurar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Segunda-feira'));
    await tester.pumpAndSettle();

    expect(find.text('Abre\n08:00'), findsOneWidget);
    expect(find.text('Fecha\n18:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cadastro apresenta seis avatares selecionáveis', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CriarContaPage()));
    await tester.pumpAndSettle();

    for (final nome in ['Luna', 'Bia', 'Flora', 'Caio', 'Pedro', 'Leo']) {
      expect(find.text(nome), findsOneWidget);
    }

    final caio = find.text('Caio');
    await tester.ensureVisible(caio);
    await tester.tap(caio);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
