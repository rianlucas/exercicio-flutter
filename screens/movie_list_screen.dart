import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gerenciador_filmes_app/models/movie_model.dart';
import 'package:gerenciador_filmes_app/services/database_helper.dart';
import 'package:gerenciador_filmes_app/screens/movie_form_screen.dart';
import 'package:gerenciador_filmes_app/screens/movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> _moviesFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Nomes dos integrantes do grupo
  final List<String> _groupMembers = [
    "Nome Completo Integrante 1",
    "Nome Completo Integrante 2",
    // Adicione mais integrantes conforme necessário
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _moviesFuture = _dbHelper.getAllMovies();
      } else {
        _moviesFuture = _dbHelper.searchMovies(_searchQuery);
      }
    });
  }

  void _navigateToForm({Movie? movie}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieFormScreen(movie: movie),
      ),
    );

    // Se o formulário retornou 'true' (indicando que algo foi salvo), recarrega a lista
    if (result == true) {
      _loadMovies();
    }
  }

  void _navigateToDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  void _deleteMovie(int id) async {
    await _dbHelper.delete(id);
    _loadMovies(); // Recarrega a lista após deletar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Filme deletado com sucesso!'),
            backgroundColor: Colors.green),
      );
    }
  }

  void _showGroupInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Integrantes do Grupo'),
          content: SingleChildScrollView(
            child: ListBody(
              children:
                  _groupMembers.map((member) => Text(member)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Filmes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGroupInfo,
            tooltip: 'Info do Grupo',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar filmes por título',
                hintText: 'Digite o título do filme...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadMovies();
                      },
                    )
                  : null,
              ),
              onChanged: (value) {
                 setState(() {
                   _searchQuery = value;
                 });
                 // Opcional: debounce para não buscar a cada letra digitada
                 _loadMovies();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum filme cadastrado ainda.'));
                }

                final movies = snapshot.data!;

                return ListView.builder(
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return Dismissible(
                      key: Key(movie.id.toString()), // Chave única para o widget
                      direction: DismissDirection.startToEnd, // Arrastar da esquerda para direita
                      onDismissed: (direction) {
                        _deleteMovie(movie.id!);
                      },
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Deletar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        elevation: 3,
                        child: ListTile(
                          leading: SizedBox(
                            width: 60, // Largura da imagem
                            height: 90, // Altura da imagem
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: movie.imageUrl.isNotEmpty
                                  ? Image.network(
                                      movie.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 30),
                                        );
                                      },
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                  : Container( // Placeholder se não houver URL
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 30),
                                    ),
                            )
                          ),
                          title: Text(movie.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${movie.genre} - ${movie.duration}'),
                              Text('Ano: ${movie.year} - Faixa: ${movie.ageRating}'),
                              RatingBarIndicator(
                                rating: movie.score,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 18.0,
                                direction: Axis.horizontal,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _navigateToDetail(movie),
                          trailing: IconButton( // Botão para editar
                            icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                            onPressed: () => _navigateToForm(movie: movie),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'Adicionar Filme',
        child: const Icon(Icons.add),
      ),
    );
  }
}