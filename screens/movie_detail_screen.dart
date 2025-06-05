import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gerenciador_filmes_app/models/movie_model.dart';
import 'package:gerenciador_filmes_app/screens/movie_form_screen.dart';
import 'package:gerenciador_filmes_app/services/database_helper.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _currentMovie;

  @override
  void initState() {
    super.initState();
    _currentMovie = widget.movie;
  }

  void _navigateToEditForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieFormScreen(movie: _currentMovie),
      ),
    );

    // Se o formulário de edição retornou 'true', recarrega os dados do filme
    if (result == true) {
      _loadMovieData();
    }
  }
  
  Future<void> _loadMovieData() async {
    // Recarrega o filme do banco de dados para garantir que os dados estejam atualizados
    // Isso é útil se a edição ocorrer e quisermos refletir imediatamente aqui.
    if (_currentMovie.id != null) {
      final updatedMovie = await DatabaseHelper.instance.getMovieById(_currentMovie.id!);
      if (updatedMovie != null && mounted) {
        setState(() {
          _currentMovie = updatedMovie;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentMovie.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Filme',
            onPressed: _navigateToEditForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Hero( // Animação de transição da imagem
                tag: 'moviePoster${_currentMovie.id}', // Tag única, pode usar o ID do filme
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _currentMovie.imageUrl.isNotEmpty
                      ? Image.network(
                          _currentMovie.imageUrl,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[300],
                              alignment: Alignment.center,
                              child: const Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 60),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 60),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _currentMovie.title,
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingBarIndicator(
                  rating: _currentMovie.score,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 24.0,
                ),
                const SizedBox(width: 8),
                Text('(${_currentMovie.score.toStringAsFixed(1)}/5.0)', style: textTheme.titleSmall)
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.category_outlined, 'Gênero:', _currentMovie.genre, textTheme),
            _buildDetailRow(Icons.timer_outlined, 'Duração:', _currentMovie.duration, textTheme),
            _buildDetailRow(Icons.calendar_today_outlined, 'Ano:', _currentMovie.year.toString(), textTheme),
            _buildDetailRow(Icons.policy_outlined, 'Faixa Etária:', _currentMovie.ageRating, textTheme),
            const SizedBox(height: 16),
            Text(
              'Descrição:',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _currentMovie.description,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.0, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(
            '$label ',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}