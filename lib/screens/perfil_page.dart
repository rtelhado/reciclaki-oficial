import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/avatar_reciclagem.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});
  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _carregando = true;
  bool _salvando = false;
  String? _falha;
  String _avatarId = AvatarReciclagem.padraoId;
  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _falha = null;
    });
    try {
      final u = AuthService.auth.currentUser!;
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(u.uid)
          .get()
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      final dados = doc.data();
      _nome.text = dados?['nome'] as String? ?? u.displayName ?? '';
      _telefone.text = dados?['telefone'] as String? ?? '';
      final avatarId = dados?['avatarId'] as String?;
      if (AvatarReciclagem.opcoes.any((avatar) => avatar.id == avatarId)) {
        _avatarId = avatarId!;
      }
    } catch (erro) {
      if (mounted) _falha = AuthService.mensagemErro(erro);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final u = AuthService.auth.currentUser!;
      final ref = FirebaseFirestore.instance.collection('usuarios').doc(u.uid);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final doc = await tx.get(ref);
        tx.set(ref, {
          'nome': _nome.text.trim(),
          'email': u.email!,
          'telefone': _telefone.text.trim(),
          'nascimento': doc.data()?['nascimento'] ?? '',
          'avatarId': _avatarId,
          'criadoEm': doc.data()?['criadoEm'] ?? FieldValue.serverTimestamp(),
        });
      });
      await u.updateDisplayName(_nome.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil salvo.')));
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AuthService.mensagemErro(erro))));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Minha conta')),
    body: _carregando
        ? const Center(child: CircularProgressIndicator())
        : _falha != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_falha!),
                FilledButton(
                  onPressed: _carregar,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      AvatarReciclagem(id: _avatarId, size: 104),
                      Text(AuthService.auth.currentUser?.email ?? ''),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nome,
                        maxLength: 150,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (v) => (v?.trim().length ?? 0) < 3
                            ? 'Informe seu nome.'
                            : null,
                      ),
                      TextFormField(
                        controller: _telefone,
                        maxLength: 11,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone com DDD (somente números)',
                        ),
                        validator: (v) =>
                            !RegExp(r'^\d{10,11}$').hasMatch(v ?? '')
                            ? 'Informe 10 ou 11 dígitos.'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _salvando ? null : _salvar,
                        child: Text(
                          _salvando ? 'Salvando...' : 'Salvar perfil',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}
