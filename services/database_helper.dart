import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gerenciador_filmes_app/models/movie_model.dart';

class DatabaseHelper {
  static const _databaseName = "MovieDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'movies';

  static const columnId = 'id';
  static const columnImageUrl = 'imageUrl';
  static const columnTitle = 'title';
  static const columnGenre = 'genre';
  static const columnAgeRating = 'ageRating';
  static const columnDuration = 'duration';
  static const columnScore = 'score';
  static const columnDescription = 'description';
  static const columnYear = 'year';

  // Torna esta uma classe singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Só tem uma referência de banco de dados em todo o aplicativo
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Abre o banco de dados e o cria se ele não existir
  _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Código SQL para criar a tabela do banco de dados
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnImageUrl TEXT NOT NULL,
            $columnTitle TEXT NOT NULL,
            $columnGenre TEXT NOT NULL,
            $columnAgeRating TEXT NOT NULL,
            $columnDuration TEXT NOT NULL,
            $columnScore REAL NOT NULL,
            $columnDescription TEXT NOT NULL,
            $columnYear INTEGER NOT NULL
          )
          ''');
  }

  // Métodos Helper

  // Insere uma linha no banco de dados. Retorna o id da linha inserida.
  Future<int> insert(Movie movie) async {
    Database db = await instance.database;
    return await db.insert(table, movie.toMap());
  }

  // Todas as linhas são retornadas como uma lista de mapas, onde cada mapa é
  // uma lista de valores de chave.
  Future<List<Movie>> getAllMovies() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return Movie.fromMap(maps[i]);
    });
  }
  
  // Retorna um filme pelo ID
  Future<Movie?> getMovieById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Movie.fromMap(maps.first);
    }
    return null;
  }


  // Atualiza uma linha no banco de dados. Retorna o número de linhas afetadas.
  Future<int> update(Movie movie) async {
    Database db = await instance.database;
    return await db.update(table, movie.toMap(),
        where: '$columnId = ?', whereArgs: [movie.id]);
  }

  // Exclui uma linha do banco de dados. Retorna o número de linhas afetadas.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Busca filmes (exemplo simples por título)
  Future<List<Movie>> searchMovies(String query) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      table,
      where: "$columnTitle LIKE ?",
      whereArgs: ['%$query%'], // Busca por parte do título
    );

    if (maps.isEmpty) {
      return [];
    }
    return List.generate(maps.length, (i) {
      return Movie.fromMap(maps[i]);
    });
  }
}