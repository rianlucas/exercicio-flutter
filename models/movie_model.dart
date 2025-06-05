class Movie {
  int? id; // Pode ser nulo se o filme ainda não foi salvo no DB
  String imageUrl;
  String title;
  String genre;
  String ageRating; // Ex: "Livre", "10", "12", "14", "16", "18"
  String duration; // Ex: "120 min"
  double score; // 0.0 a 5.0
  String description;
  int year; // Ex: 2023

  Movie({
    this.id,
    required this.imageUrl,
    required this.title,
    required this.genre,
    required this.ageRating,
    required this.duration,
    required this.score,
    required this.description,
    required this.year,
  });

  // Converte um objeto Movie em um Map. As chaves devem corresponder
  // aos nomes das colunas no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'genre': genre,
      'ageRating': ageRating,
      'duration': duration,
      'score': score,
      'description': description,
      'year': year,
    };
  }

  // Converte um Map em um objeto Movie
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int?,
      imageUrl: map['imageUrl'] as String,
      title: map['title'] as String,
      genre: map['genre'] as String,
      ageRating: map['ageRating'] as String,
      duration: map['duration'] as String,
      score: map['score'] as double,
      description: map['description'] as String,
      year: map['year'] as int,
    );
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, year: $year}';
  }
}