import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gerenciador_filmes_app/models/movie_model.dart';
import 'package:gerenciador_filmes_app/services/database_helper.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie; // Se nulo, é um novo filme. Senão, é edição.

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  late TextEditingController _imageUrlController;
  late TextEditingController _titleController;
  late TextEditingController _genreController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  late TextEditingController _yearController;

  String? _selectedAgeRating;
  double _currentScore = 3.0; // Pontuação inicial

  final List<String> _ageRatingOptions = [
    'Livre', '10', '12', '14', '16', '18'
  ];

  @override
  void initState() {
    super.initState();
    _imageUrlController = TextEditingController(text: widget.movie?.imageUrl ?? '');
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _durationController = TextEditingController(text: widget.movie?.duration ?? '');
    _descriptionController = TextEditingController(text: widget.movie?.description ?? '');
    _yearController = TextEditingController(text: widget.movie?.year.toString() ?? '');
    _selectedAgeRating = widget.movie?.ageRating ?? _ageRatingOptions[0]; // Padrão 'Livre'
    _currentScore = widget.movie?.score ?? 3.0;
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final movie = Movie(
        id: widget.movie?.id, // Mantém o ID se estiver editando
        imageUrl: _imageUrlController.text,
        title: _titleController.text,
        genre: _genreController.text,
        ageRating: _selectedAgeRating!,
        duration: _durationController.text,
        score: _currentScore,
        description: _descriptionController.text,
        year: int.tryParse(_yearController.text) ?? DateTime.now().year,
      );

      try {
        if (widget.movie == null) {
          // Novo filme
          await _dbHelper.insert(movie);
        } else {
          // Editar filme
          await _dbHelper.update(movie);
        }
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filme salvo com sucesso!'), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true); // Retorna true para indicar sucesso e recarregar a lista
        }
      } catch (e) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar filme: $e'), backgroundColor: Colors.red),
            );
        }
      }
    } else {
       if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Por favor, corrija os erros no formulário.'), backgroundColor: Colors.orange),
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Cadastrar Filme' : 'Editar Filme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _titleController,
                labelText: 'Título',
                icon: Icons.movie,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Título é obrigatório.' : null,
              ),
              _buildTextFormField(
                controller: _imageUrlController,
                labelText: 'URL da Imagem (Poster)',
                icon: Icons.link,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'URL da imagem é obrigatória.';
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) return 'URL inválida.';
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _genreController,
                labelText: 'Gênero',
                icon: Icons.theater_comedy,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Gênero é obrigatório.' : null,
              ),
              _buildDropdownFormField(),
              _buildTextFormField(
                controller: _durationController,
                labelText: 'Duração (ex: 120 min)',
                icon: Icons.access_time,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Duração é obrigatória.' : null,
              ),
              _buildTextFormField(
                controller: _yearController,
                labelText: 'Ano de Lançamento',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ano é obrigatório.';
                  final year = int.tryParse(value);
                  if (year == null || year < 1800 || year > DateTime.now().year + 5) {
                    return 'Ano inválido.';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: 'Descrição',
                icon: Icons.notes,
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 16),
              Text('Pontuação (0-5):', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Center(
                child: RatingBar.builder(
                  initialRating: _currentScore,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _currentScore = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: Text(widget.movie == null ? 'Cadastrar Filme' : 'Salvar Alterações'),
                onPressed: _saveMovie,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int? maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Faixa Etária',
          prefixIcon: const Icon(Icons.policy_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: _selectedAgeRating,
        items: _ageRatingOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value == 'Livre' ? 'Livre para todos os públicos' : '$value anos'),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedAgeRating = newValue;
          });
        },
        validator: (value) =>
            value == null ? 'Faixa etária é obrigatória.' : null,
      ),
    );
  }
}