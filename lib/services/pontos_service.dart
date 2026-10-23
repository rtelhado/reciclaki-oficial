import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ponto_coleta.dart';

class PontosService {
  static CollectionReference<Map<String, dynamic>> get colecao =>
      FirebaseFirestore.instance.collection('pontos_coleta');

  static String novoId() => colecao.doc().id;

  static Future<void> salvar(PontoColeta ponto) =>
      FirebaseFirestore.instance.runTransaction((tx) async {
        final ref = colecao.doc(ponto.id);
        final existente = await tx.get(ref);
        tx.set(ref, {
          ...ponto.toMap(),
          'criadoEm':
              existente.data()?['criadoEm'] ?? FieldValue.serverTimestamp(),
        });
      });

  static Stream<List<PontoColeta>> observar() => colecao.snapshots().map((
    snapshot,
  ) {
    final pontos = snapshot.docs
        .map((d) => PontoColeta.fromMap(d.id, d.data()))
        .toList();
    pontos.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return pontos;
  });
}
