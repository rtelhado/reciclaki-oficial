class PontoColeta {
  final String id;
  final String ownerUid;
  final String nome;
  final String cnpj;
  final String email;
  final String telefone;
  final String endereco;
  final String numero;
  final String bairro;
  final String horario;
  final String observacoes;
  final List<String> materiais;
  final double latitude;
  final double longitude;

  const PontoColeta({
    required this.id,
    required this.ownerUid,
    required this.nome,
    required this.cnpj,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.numero,
    required this.bairro,
    required this.horario,
    required this.observacoes,
    required this.materiais,
    required this.latitude,
    required this.longitude,
  });

  factory PontoColeta.fromMap(String id, Map<String, dynamic> d) => PontoColeta(
    id: id,
    ownerUid: d['ownerUid'] as String,
    nome: d['nome'] as String,
    cnpj: d['cnpj'] as String,
    email: d['email'] as String,
    telefone: d['telefone'] as String,
    endereco: d['endereco'] as String,
    numero: d['numero'] as String,
    bairro: d['bairro'] as String,
    horario: d['horario'] as String,
    observacoes: d['observacoes'] as String,
    materiais: List<String>.from(d['materiais'] as List),
    latitude: (d['latitude'] as num).toDouble(),
    longitude: (d['longitude'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'ownerUid': ownerUid,
    'nome': nome,
    'cnpj': cnpj,
    'email': email,
    'telefone': telefone,
    'endereco': endereco,
    'numero': numero,
    'bairro': bairro,
    'horario': horario,
    'observacoes': observacoes,
    'materiais': materiais,
    'latitude': latitude,
    'longitude': longitude,
  };

  String get enderecoCompleto => '$endereco, $numero — $bairro';
}
