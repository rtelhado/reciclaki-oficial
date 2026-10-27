import 'dart:math';

import 'package:flutter/material.dart';

import '../data/quiz_perguntas.dart';
import '../models/pergunta_quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  static const quantidadePerguntas = 10;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _random = Random();
  late List<PerguntaQuiz> _perguntas;
  late List<String> _opcoes;
  int _indice = 0;
  int _acertos = 0;
  String? _selecionada;
  bool _finalizada = false;

  PerguntaQuiz get _perguntaAtual => _perguntas[_indice];
  bool get _respondeu => _selecionada != null;

  @override
  void initState() {
    super.initState();
    _iniciarRodada();
  }

  void _iniciarRodada() {
    _perguntas = List<PerguntaQuiz>.of(bancoPerguntas)..shuffle(_random);
    _perguntas = _perguntas.take(QuizPage.quantidadePerguntas).toList();
    _indice = 0;
    _acertos = 0;
    _selecionada = null;
    _finalizada = false;
    _embaralharOpcoes();
  }

  void _embaralharOpcoes() {
    _opcoes = List<String>.of(_perguntaAtual.opcoes)..shuffle(_random);
  }

  void _responder(String resposta) {
    if (_respondeu) return;
    setState(() {
      _selecionada = resposta;
      if (resposta == _perguntaAtual.correta) _acertos++;
    });
  }

  void _avancar() {
    if (_indice == _perguntas.length - 1) {
      setState(() => _finalizada = true);
      return;
    }
    setState(() {
      _indice++;
      _selecionada = null;
      _embaralharOpcoes();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quiz de reciclagem'),
      backgroundColor: const Color(0xFFF7FAF5),
      foregroundColor: const Color(0xFF123D35),
      elevation: 0,
    ),
    body: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/renan/fundo_reciclagem.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF64C8F0),
                  Color(0xFFB8E8F8),
                  Color(0xFF70C78A),
                ],
              ),
            ),
          ),
        ),
        ColoredBox(color: Colors.white.withValues(alpha: 0.10)),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _finalizada
                    ? _buildResultado(context)
                    : _buildPergunta(context),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPergunta(BuildContext context) {
    final pergunta = _perguntaAtual;
    return _cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: Color(0xFF087B39)),
              const SizedBox(width: 8),
              Text(
                'Pergunta ${_indice + 1} de ${_perguntas.length}',
                style: const TextStyle(
                  color: Color(0xFF14532D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_indice + 1) / _perguntas.length,
              minHeight: 8,
              color: const Color(0xFF2E9D50),
              backgroundColor: const Color(0xFFDCEBDD),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            pergunta.texto,
            style: const TextStyle(
              fontSize: 22,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123D35),
            ),
          ),
          const SizedBox(height: 20),
          for (final opcao in _opcoes) _buildOpcao(opcao, pergunta),
          if (_respondeu) ...[
            const SizedBox(height: 8),
            Text(
              _selecionada == pergunta.correta
                  ? 'Você acertou!'
                  : 'A resposta correta é: ${pergunta.correta}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selecionada == pergunta.correta
                    ? const Color(0xFF087B39)
                    : const Color(0xFFB3261E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _avancar,
              icon: Icon(
                _indice == _perguntas.length - 1
                    ? Icons.emoji_events_outlined
                    : Icons.arrow_forward,
              ),
              label: Text(
                _indice == _perguntas.length - 1
                    ? 'Ver resultado'
                    : 'Próxima pergunta',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF087B39),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpcao(String opcao, PerguntaQuiz pergunta) {
    final selecionada = opcao == _selecionada;
    final correta = opcao == pergunta.correta;
    final cor = !_respondeu
        ? const Color(0xFFEAF5E9)
        : correta
        ? const Color(0xFFC8E6C9)
        : selecionada
        ? const Color(0xFFFFDAD6)
        : const Color(0xFFF4F4F4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _respondeu ? null : () => _responder(opcao),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.centerLeft,
            backgroundColor: cor,
            foregroundColor: const Color(0xFF123D35),
            disabledForegroundColor: const Color(0xFF123D35),
            side: BorderSide(
              color: _respondeu && correta
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFB9DCC1),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            textStyle: const TextStyle(fontSize: 15, height: 1.3),
          ),
          child: Text(opcao),
        ),
      ),
    );
  }

  Widget _buildResultado(BuildContext context) {
    final porcentagem = (_acertos * 100 / _perguntas.length).round();
    return _cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 76,
            color: Color(0xFFE5A900),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fim do quiz!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF123D35),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Você acertou $_acertos de ${_perguntas.length} perguntas.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, color: Color(0xFF37474F)),
          ),
          const SizedBox(height: 8),
          Text(
            'Pontuação: $porcentagem%',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 25,
              color: Color(0xFF087B39),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Saiba mais sobre reciclagem',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123D35),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Separe os resíduos conforme as regras da sua cidade. '
            'Reduza o consumo, reutilize objetos e encaminhe pilhas, '
            'baterias e eletrônicos para pontos de coleta adequados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => setState(_iniciarRodada),
            icon: const Icon(Icons.refresh),
            label: const Text('Jogar novamente'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF087B39),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_outlined),
            label: const Text('Voltar ao início'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF087B39),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartao({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFB9DCC1), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    padding: const EdgeInsets.all(22),
    child: child,
  );
}
