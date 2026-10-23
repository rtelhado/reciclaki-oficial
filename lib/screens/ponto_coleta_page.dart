import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../models/ponto_coleta.dart';
import '../services/auth_service.dart';
import '../services/geocodificacao_service.dart';
import '../services/pontos_service.dart';
import '../rotas.dart';
import 'localizacao_page.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_inferior.dart';

class CadastroPontoColeta extends StatefulWidget {
  const CadastroPontoColeta({super.key});
  @override
  State<CadastroPontoColeta> createState() => _CadastroPontoColetaState();
}

class _CadastroPontoColetaState extends State<CadastroPontoColeta> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cnpjController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final observacoesController = TextEditingController();
  LatLng? _localizacao;
  String? _pontoId;
  bool _buscandoEndereco = false;
  final Set<String> materiaisSelecionados = {};
  final List<String> materiais = [
    'Papel',
    'Plástico',
    'Metal',
    'Vidro',
    'Eletrônicos',
  ];
  final Map<String, bool> diasSelecionados = {
    'Segunda-feira': false,
    'Terça-feira': false,
    'Quarta-feira': false,
    'Quinta-feira': false,
    'Sexta-feira': false,
    'Sábado': false,
    'Domingo': false,
  };
  final Map<String, TimeOfDay?> horarioAbertura = {};
  final Map<String, TimeOfDay?> horarioFechamento = {};
  bool cadastrando = false;

  @override
  void dispose() {
    nomeController.dispose();
    cnpjController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  // ============================================================
  // E-MAIL
  // ============================================================
  bool _emailValido(String valor) {
    final email = valor.trim();
    if (email.isEmpty || email.contains(' ')) {
      return false;
    }
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(email);
  }

  bool validarCNPJ(String valor) {
    final cnpj = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (cnpj.length != 14) {
      return false;
    }
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
      return false;
    }
    final numeros = cnpj.split('').map(int.parse).toList();
    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += numeros[i] * peso;
      peso--;
      if (peso == 1) {
        peso = 9;
      }
    }
    final resto = soma % 11;
    final primeiroDigito = resto < 2 ? 0 : 11 - resto;
    if (numeros[12] != primeiroDigito) {
      return false;
    }
    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += numeros[i] * peso;
      peso--;
      if (peso == 1) {
        peso = 9;
      }
    }
    final restoSegundo = soma % 11;
    final segundoDigito = restoSegundo < 2 ? 0 : 11 - restoSegundo;
    return numeros[13] == segundoDigito;
  }

  // ============================================================
  // CONSULTA DO CNPJ
  // ATENÇÃO: ainda é uma simulação.
  // ============================================================
  bool validarTelefone(String valor) {
    final telefone = valor.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefone.length != 10 && telefone.length != 11) {
      return false;
    }
    final ddd = int.tryParse(telefone.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return false;
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(telefone)) {
      return false;
    }
    return true;
  }

  // ============================================================
  // SELECIONAR HORÁRIO
  // ============================================================
  Future<TimeOfDay?> selecionarHorario(TimeOfDay horarioInicial) async {
    return showTimePicker(
      context: context,
      initialTime: horarioInicial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          child: child!,
        );
      },
    );
  }

  // ============================================================
  // CONFIGURAR DIAS E HORÁRIOS
  // ============================================================
  Future<void> abrirConfiguracaoHorarios() async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Horário de funcionamento',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: diasSelecionados.keys.map((dia) {
                      final selecionado = diasSelecionados[dia] ?? false;
                      return Column(
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: Colors.green,
                            title: Text(dia),
                            value: selecionado,
                            onChanged: (valor) {
                              setDialogState(() {
                                diasSelecionados[dia] = valor ?? false;
                                if (valor ?? false) {
                                  horarioAbertura.putIfAbsent(
                                    dia,
                                    () => const TimeOfDay(hour: 8, minute: 0),
                                  );
                                  horarioFechamento.putIfAbsent(
                                    dia,
                                    () => const TimeOfDay(hour: 18, minute: 0),
                                  );
                                } else {
                                  horarioAbertura.remove(dia);
                                  horarioFechamento.remove(dia);
                                }
                              });
                            },
                          ),
                          if (selecionado)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final horario = await selecionarHorario(
                                          horarioAbertura[dia] ??
                                              const TimeOfDay(
                                                hour: 8,
                                                minute: 0,
                                              ),
                                        );
                                        if (horario != null) {
                                          setDialogState(() {
                                            horarioAbertura[dia] = horario;
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Abre\n'
                                        '${horarioAbertura[dia]?.format(context) ?? '08:00'}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        final horario = await selecionarHorario(
                                          horarioFechamento[dia] ??
                                              const TimeOfDay(
                                                hour: 18,
                                                minute: 0,
                                              ),
                                        );
                                        if (horario != null) {
                                          setDialogState(() {
                                            horarioFechamento[dia] = horario;
                                          });
                                        }
                                      },
                                      child: Text(
                                        'Fecha\n'
                                        '${horarioFechamento[dia]?.format(context) ?? '18:00'}',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() {});
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // VALIDAR HORÁRIOS
  // ============================================================
  bool validarHorarios() {
    if (!diasSelecionados.containsValue(true)) {
      return false;
    }
    for (final dia in diasSelecionados.keys) {
      if (diasSelecionados[dia] == true) {
        if (horarioAbertura[dia] == null || horarioFechamento[dia] == null) {
          return false;
        }
      }
    }
    return true;
  }

  bool horarioValido(String dia) {
    final abertura = horarioAbertura[dia];
    final fechamento = horarioFechamento[dia];
    if (abertura == null || fechamento == null) {
      return false;
    }
    final minutosAbertura = abertura.hour * 60 + abertura.minute;
    final minutosFechamento = fechamento.hour * 60 + fechamento.minute;
    return minutosFechamento > minutosAbertura;
  }

  // ============================================================
  // CADASTRAR PONTO DE COLETA
  // ============================================================
  Future<void> salvarCadastro() async {
    if (cadastrando) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifique os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (materiaisSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um material aceito.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!validarHorarios()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure pelo menos um dia e seus horários.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    for (final dia in diasSelecionados.keys) {
      if (diasSelecionados[dia] == true && !horarioValido(dia)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('O fechamento deve ser depois da abertura em $dia.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    if (!validarCNPJ(cnpjController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O CNPJ informado é inválido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_localizacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marque a localização do ponto no mapa.')),
      );
      return;
    }
    final usuario = AuthService.auth.currentUser;
    if (usuario == null) return;
    setState(() => cadastrando = true);
    _pontoId ??= PontosService.novoId();
    final horarios = diasSelecionados.keys
        .where((d) => diasSelecionados[d] == true)
        .map((d) {
          String hora(TimeOfDay t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
          return '$d: ${hora(horarioAbertura[d]!)} às ${hora(horarioFechamento[d]!)}';
        })
        .join('; ');
    try {
      await PontosService.salvar(
        PontoColeta(
          id: _pontoId!,
          ownerUid: usuario.uid,
          nome: nomeController.text.trim(),
          cnpj: cnpjController.text.replaceAll(RegExp(r'\D'), ''),
          email: emailController.text.trim(),
          telefone: telefoneController.text.trim(),
          endereco: enderecoController.text.trim(),
          numero: numeroController.text.trim(),
          bairro: bairroController.text.trim(),
          horario: horarios,
          observacoes: observacoesController.text.trim(),
          materiais: materiaisSelecionados.toList(),
          latitude: _localizacao!.latitude,
          longitude: _localizacao!.longitude,
        ),
      ).timeout(const Duration(seconds: 20));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ponto salvo! Ele já está disponível no mapa.'),
        ),
      );
      Navigator.pushReplacementNamed(context, Rotas.mapa);
    } on TimeoutException {
      if (!mounted) return;
      // O SDK pode ainda estar sincronizando. Não enviar outra cópia.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 10),
          content: Text(
            'A confirmação está demorando. Confira sua conexão e o mapa antes de cadastrar novamente.',
          ),
        ),
      );
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AuthService.mensagemErro(erro))));
      }
    } finally {
      if (mounted) setState(() => cadastrando = false);
    }
  }

  Future<void> _selecionarLocalizacao() async {
    if (_buscandoEndereco) return;
    final resultado = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => LocalizacaoPage(inicial: _localizacao)),
    );
    if (resultado == null || !mounted) return;
    setState(() => _localizacao = resultado);
    if (enderecoController.text.trim().isNotEmpty) return;

    setState(() => _buscandoEndereco = true);
    try {
      final endereco = await GeocodificacaoService.enderecoDe(resultado);
      if (!mounted) return;
      setState(() {
        if (enderecoController.text.trim().isEmpty) {
          enderecoController.text = endereco.endereco;
        }
        if (numeroController.text.trim().isEmpty) {
          numeroController.text = endereco.numero;
        }
        if (bairroController.text.trim().isEmpty) {
          bairroController.text = endereco.bairro;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço preenchido pelo mapa.')),
      );
    } catch (erro, stackTrace) {
      debugPrint('Reverse geocoding failed: $erro\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A localização foi marcada, mas não foi possível obter o endereço. Preencha-o manualmente ou tente marcar novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _buscandoEndereco = false);
    }
  }

  // ============================================================
  // CAMPO DE TEXTO
  // ============================================================
  Widget campoTexto({
    required String label,
    required TextEditingController controller,
    bool obrigatorio = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      maxLength: controller == observacoesController
          ? 1000
          : controller == enderecoController
          ? 200
          : controller == emailController
          ? 254
          : controller == bairroController
          ? 100
          : controller == numeroController
          ? 20
          : controller == nomeController
          ? 150
          : null,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontSize: 15),
      decoration: InputDecoration(
        label: obrigatorio
            ? RichText(
                text: TextSpan(
                  text: label,
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                  children: const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : Text(label, style: const TextStyle(color: Colors.black87)),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: Color(0xFF08A94F)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF08A94F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  // ============================================================
  // TÍTULOS DAS SEÇÕES
  // ============================================================
  Widget tituloSecao(String texto, {bool obrigatorio = false}) {
    return RichText(
      text: TextSpan(
        text: texto,
        style: const TextStyle(
          color: Color(0xFF087B39),
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        children: obrigatorio
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  // ============================================================
  // TELA
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ponto de coleta')),
      bottomNavigationBar: const MenuInferior(indice: 1),
      backgroundColor: const Color(0xFFB8E8F8),
      body: Stack(
        children: [
          // FUNDO ORIGINAL DO RECICLAKI
          Positioned.fill(
            child: Image.asset(
              'assets/pontos/fundo_reciclaki.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
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
                );
              },
            ),
          ),
          // LEVE CAMADA PARA MELHORAR O CONTRASTE DO FUNDO
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.10)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // CARTÃO COM EFEITO DE VIDRO, COMO NAS TELAS DE LOGIN E CADASTRO
                      color: Colors.white.withValues(alpha: 0.48),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.13),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CABEÇALHO ORIGINAL
                                Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/pontos/reciclagem.png',
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Cadastrar ponto de coleta',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF123D35),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Cadastre as informações do seu '
                                        'ponto de coleta.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // DADOS DA EMPRESA
                                tituloSecao('Dados da empresa'),
                                const SizedBox(height: 7),
                                const Text(
                                  '* Campos obrigatórios',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                campoTexto(
                                  label: 'Nome da empresa',
                                  controller: nomeController,
                                  obrigatorio: true,
                                  prefixIcon: Icons.person,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite o nome da empresa';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Digite pelo menos 2 caracteres';
                                    }
                                    if (!RegExp(
                                      r'^[A-Za-zÀ-ÿ\s]+$',
                                    ).hasMatch(value.trim())) {
                                      return 'Digite somente letras';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                campoTexto(
                                  label: 'CNPJ',
                                  controller: cnpjController,
                                  obrigatorio: true,
                                  prefixIcon: Icons.business,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(14),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite o CNPJ';
                                    }
                                    if (!validarCNPJ(value)) {
                                      return 'Digite um CNPJ válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                campoTexto(
                                  label: 'E-mail empresarial',
                                  controller: emailController,
                                  obrigatorio: true,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite o e-mail';
                                    }
                                    if (!_emailValido(value)) {
                                      return 'Digite um e-mail válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                campoTexto(
                                  label: 'Telefone',
                                  controller: telefoneController,
                                  obrigatorio: true,
                                  prefixIcon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite o telefone';
                                    }
                                    if (!validarTelefone(value)) {
                                      return 'Digite um telefone válido';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),
                                // LOCALIZAÇÃO
                                tituloSecao('Localização'),
                                const SizedBox(height: 14),
                                campoTexto(
                                  label: 'Endereço',
                                  controller: enderecoController,
                                  obrigatorio: true,
                                  prefixIcon: Icons.location_on_outlined,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Digite o endereço';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 13),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: campoTexto(
                                        label: 'Número',
                                        controller: numeroController,
                                        obrigatorio: true,
                                        keyboardType: TextInputType.text,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Digite o número';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 3,
                                      child: campoTexto(
                                        label: 'Bairro',
                                        controller: bairroController,
                                        obrigatorio: true,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Digite o bairro';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                // MATERIAIS
                                tituloSecao(
                                  'Materiais aceitos',
                                  obrigatorio: true,
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'Selecione os materiais que o ponto recebe.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: materiais.map((material) {
                                    final selecionado = materiaisSelecionados
                                        .contains(material);
                                    return FilterChip(
                                      label: Text(material),
                                      selected: selecionado,
                                      showCheckmark: true,
                                      selectedColor: Colors.green.shade100,
                                      checkmarkColor: Colors.green,
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: selecionado
                                            ? Colors.green
                                            : Colors.grey.shade400,
                                      ),
                                      onSelected: (valor) {
                                        setState(() {
                                          if (valor) {
                                            materiaisSelecionados.add(material);
                                          } else {
                                            materiaisSelecionados.remove(
                                              material,
                                            );
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 28),
                                // HORÁRIOS
                                tituloSecao(
                                  'Horário de funcionamento',
                                  obrigatorio: true,
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'Escolha os dias e os horários '
                                  'de funcionamento.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: abrirConfiguracaoHorarios,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade400,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Color(0xFF08A94F),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              validarHorarios()
                                                  ? 'Horários configurados'
                                                  : 'Toque para configurar',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 17,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...diasSelecionados.keys
                                    .where(
                                      (dia) => diasSelecionados[dia] == true,
                                    )
                                    .map(
                                      (dia) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: ListTile(
                                          dense: true,
                                          leading: const Icon(
                                            Icons.calendar_today,
                                            color: Colors.green,
                                          ),
                                          title: Text(dia),
                                          subtitle: Text(
                                            '${horarioAbertura[dia]?.format(context) ?? '--:--'}'
                                            ' - '
                                            '${horarioFechamento[dia]?.format(context) ?? '--:--'}',
                                          ),
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: 28),
                                // OBSERVAÇÕES
                                tituloSecao('Observações'),
                                const SizedBox(height: 13),
                                OutlinedButton.icon(
                                  onPressed: cadastrando || _buscandoEndereco
                                      ? null
                                      : _selecionarLocalizacao,
                                  icon: _buscandoEndereco
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(
                                          _localizacao == null
                                              ? Icons.add_location_alt
                                              : Icons.location_on,
                                        ),
                                  label: Text(
                                    _buscandoEndereco
                                        ? 'Buscando endereço...'
                                        : _localizacao == null
                                        ? 'Marcar localização no mapa'
                                        : 'Localização marcada — alterar',
                                  ),
                                ),
                                const SizedBox(height: 13),
                                const Text(
                                  'Ao confirmar o marcador, suas coordenadas serão consultadas no OpenStreetMap para preencher o endereço.',
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 13),
                                const Text(
                                  'Os dados deste ponto de coleta ficarão visíveis para os usuários do aplicativo.',
                                ),
                                const SizedBox(height: 13),
                                campoTexto(
                                  label: 'Informações adicionais',
                                  controller: observacoesController,
                                  prefixIcon: Icons.description_outlined,
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 28),
                                // BOTÃO CADASTRAR
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton.icon(
                                    onPressed: cadastrando
                                        ? null
                                        : salvarCadastro,
                                    icon: cadastrando
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_circle_outline,
                                          ),
                                    label: Text(
                                      cadastrando
                                          ? 'Salvando...'
                                          : 'Cadastrar ponto de coleta',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF08A94F),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.grey.shade500,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ), // Column
                          ), // Form
                        ), // Padding
                      ), // BackdropFilter
                    ), // ClipRRect
                  ), // Container
                ), // ConstrainedBox
              ), // Center
            ), // SingleChildScrollView
          ), // SafeArea
        ],
      ),
    );
  }
}
