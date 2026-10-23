import '../rotas.dart';
import '../services/auth_service.dart';
import '../widgets/avatar_reciclagem.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _verde = Color(0xFF08A94F);
const Color _verdeEscuro = Color(0xFF087B39);

class CriarContaPage extends StatefulWidget {
  const CriarContaPage({super.key});

  @override
  State<CriarContaPage> createState() => _CriarContaPageState();
}

class _CriarContaPageState extends State<CriarContaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  bool _mostrarSenha = false;
  bool _mostrarConfirmacao = false;
  bool _aceitouTermos = false;
  bool _carregando = false;
  String? _avatarId;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  InputDecoration _decoracao(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _verde),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.94),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD5E6D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _verde, width: 2),
      ),
    );
  }

  Widget _seletorAvatar() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Escolha seu avatar',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: _verdeEscuro,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Avatares inspirados na reciclagem e no cuidado com o planeta.',
      ),
      const SizedBox(height: 12),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final avatar in AvatarReciclagem.opcoes)
            Semantics(
              button: true,
              selected: _avatarId == avatar.id,
              label: 'Avatar ${avatar.nome}',
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => setState(() => _avatarId = avatar.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 104,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _avatarId == avatar.id
                        ? const Color(0xFFE2F4E6)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _avatarId == avatar.id
                          ? _verde
                          : const Color(0xFFD5E6D9),
                      width: _avatarId == avatar.id ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AvatarReciclagem(id: avatar.id, size: 72),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              avatar.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (_avatarId == avatar.id)
                            const Padding(
                              padding: EdgeInsets.only(left: 3),
                              child: Icon(
                                Icons.check_circle,
                                color: _verde,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime(hoje.year - 18, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Selecione sua data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (data != null && mounted) {
      setState(() {
        _dataNascimentoController.text =
            '${data.day.toString().padLeft(2, '0')}/'
            '${data.month.toString().padLeft(2, '0')}/'
            '${data.year}';
      });
    }
  }

  String? _validarEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Digite seu e-mail.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Digite um e-mail válido.';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    final telefone = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (telefone.isEmpty) return 'Digite seu telefone.';
    if (telefone.length < 10 || telefone.length > 11) {
      return 'Digite um telefone válido com DDD.';
    }
    return null;
  }

  Future<void> _criarConta() async {
    if (_carregando) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_avatarId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha um avatar para sua conta.')),
      );
      return;
    }
    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confirme o uso dos dados para criar sua conta.'),
        ),
      );
      return;
    }
    setState(() => _carregando = true);
    try {
      final perfilSalvo = await AuthService.cadastrar(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: _senhaController.text,
        telefone: _telefoneController.text,
        nascimento: _dataNascimentoController.text,
        avatarId: _avatarId!,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, Rotas.inicio, (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            perfilSalvo
                ? 'Conta criada com sucesso! Bem-vindo ao ReciclaKi.'
                : 'Conta criada. O perfil não foi salvo por completo; você poderá completá-lo em Minha conta.',
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
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _FundoCadastro(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.48),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.82),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                'assets/daniel/images/reciclaki_logo.png',
                                width: 62,
                                height: 62,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.recycling,
                                      size: 62,
                                      color: _verde,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Criar conta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _verdeEscuro,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Crie sua conta para encontrar e cadastrar pontos de coleta.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              _seletorAvatar(),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nomeController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: _decoracao(
                                  'Nome completo',
                                  Icons.person_outline,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Digite seu nome completo.';
                                  }
                                  if (value.trim().length < 3) {
                                    return 'Digite um nome válido.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _decoracao(
                                  'E-mail',
                                  Icons.email_outlined,
                                ),
                                validator: _validarEmail,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _telefoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                decoration: _decoracao(
                                  'Telefone com DDD',
                                  Icons.phone_outlined,
                                ),
                                validator: _validarTelefone,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _dataNascimentoController,
                                readOnly: true,
                                onTap: _selecionarData,
                                decoration:
                                    _decoracao(
                                      'Data de nascimento',
                                      Icons.calendar_month_outlined,
                                    ).copyWith(
                                      suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                        color: _verde,
                                      ),
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Selecione sua data de nascimento.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _senhaController,
                                obscureText: !_mostrarSenha,
                                textInputAction: TextInputAction.next,
                                decoration:
                                    _decoracao(
                                      'Senha',
                                      Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        tooltip: _mostrarSenha
                                            ? 'Ocultar senha'
                                            : 'Mostrar senha',
                                        icon: Icon(
                                          _mostrarSenha
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _mostrarSenha = !_mostrarSenha,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Crie uma senha.';
                                  }
                                  if (value.length < 6) {
                                    return 'Use pelo menos 6 caracteres.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmarSenhaController,
                                obscureText: !_mostrarConfirmacao,
                                textInputAction: TextInputAction.done,
                                decoration:
                                    _decoracao(
                                      'Confirmar senha',
                                      Icons.lock_reset_outlined,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        tooltip: _mostrarConfirmacao
                                            ? 'Ocultar senha'
                                            : 'Mostrar senha',
                                        icon: Icon(
                                          _mostrarConfirmacao
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _mostrarConfirmacao =
                                              !_mostrarConfirmacao,
                                        ),
                                      ),
                                    ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirme sua senha.';
                                  }
                                  if (value != _senhaController.text) {
                                    return 'As senhas não são iguais.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: Colors.transparent,
                                child: CheckboxListTile(
                                  value: _aceitouTermos,
                                  onChanged: (value) => setState(
                                    () => _aceitouTermos = value ?? false,
                                  ),
                                  activeColor: _verde,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Concordo com o uso dos dados informados para manter minha conta no ReciclaKi. Meu perfil será acessível somente por mim.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _carregando ? null : _criarConta,
                                  icon: const Icon(Icons.person_add),
                                  label: const Text(
                                    'Criar minha conta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _verde,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Já tenho uma conta — voltar ao login',
                                  style: TextStyle(
                                    color: _verdeEscuro,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FundoCadastro extends StatelessWidget {
  final Widget child;

  const _FundoCadastro({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/daniel/images/reciclaki_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB9F0F8),
                      Color(0xFFDDF8FA),
                      Color(0xFF8ED7E5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              );
            },
          ),
          Container(color: Colors.white.withValues(alpha: 0.10)),
          child,
        ],
      ),
    );
  }
}
