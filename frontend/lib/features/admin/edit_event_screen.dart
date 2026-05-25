import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_events_ai/services/api_service.dart';
import 'package:campus_events_ai/providers/events_provider.dart';
import 'package:campus_events_ai/core/constants.dart';
import 'package:campus_events_ai/models/event_model.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final int eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locNameController = TextEditingController();
  final _locAddrController = TextEditingController();
  final _orgController = TextEditingController();
  final _capacityController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = AppConstants.eventCategories.first;
  DateTime _startDate = DateTime.now();
  DateTime _startTime = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _endTime = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoading = true;
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/api/events/${widget.eventId}');
      final event = EventModel.fromJson(response.data);
      _event = event;
      _titleController.text = event.title;
      _descController.text = event.description;
      _locNameController.text = event.locationName;
      _locAddrController.text = event.locationAddress ?? '';
      _orgController.text = event.organizerName;
      _capacityController.text = event.capacity.toString();
      _tagsController.text = event.tags ?? '';
      _imageUrlController.text = event.imageUrl ?? '';
      _selectedCategory = event.category;

      final start = DateTime.parse(event.startDateTime);
      _startDate = start;
      _startTime = start;
      final end = DateTime.parse(event.endDateTime);
      _endDate = end;
      _endTime = end;

      setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors du chargement')),
        );
        context.pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locNameController.dispose();
    _locAddrController.dispose();
    _orgController.dispose();
    _capacityController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final initialTime = isStart ? _startTime : _endTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );
    if (time == null) return;

    if (isStart) {
      _startDate = date;
      _startTime = DateTime(0, 0, 0, time.hour, time.minute);
    } else {
      _endDate = date;
      _endTime = DateTime(0, 0, 0, time.hour, time.minute);
    }
    setState(() {});
  }

  String _formatDateTime(DateTime date, DateTime time) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final startDateTime = DateTime(
      _startDate.year, _startDate.month, _startDate.day,
      _startTime.hour, _startTime.minute,
    );
    final endDateTime = DateTime(
      _endDate.year, _endDate.month, _endDate.day,
      _endTime.hour, _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final api = ref.read(apiServiceProvider);
      await api.put('/api/events/${widget.eventId}', data: {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'start_date_time': startDateTime.toIso8601String(),
        'end_date_time': endDateTime.toIso8601String(),
        'location_name': _locNameController.text.trim(),
        'location_address': _locAddrController.text.trim().isEmpty ? null : _locAddrController.text.trim(),
        'organizer_name': _orgController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'tags': _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      });

      if (mounted) {
        ref.read(eventsProvider.notifier).loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement modifié avec succès')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet événement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final api = ref.read(apiServiceProvider);
      await api.delete('/api/events/${widget.eventId}');
      if (mounted) {
        ref.read(eventsProvider.notifier).loadEvents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Événement supprimé')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier l\'événement')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'événement'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: theme.colorScheme.error),
            onPressed: _deleteEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre *', prefixIcon: Icon(Icons.title)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Titre requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Description requise' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie *', prefixIcon: Icon(Icons.category)),
                items: AppConstants.eventCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDateTime(true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure de début *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDateTime(_startDate, _startTime)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickDateTime(false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date et heure de fin *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDateTime(_endDate, _endTime)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locNameController,
                decoration: const InputDecoration(labelText: 'Lieu *', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Lieu requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locAddrController,
                decoration: const InputDecoration(labelText: 'Adresse du lieu', prefixIcon: Icon(Icons.map)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orgController,
                decoration: const InputDecoration(labelText: 'Organisateur *', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.trim().isEmpty ? 'Organisateur requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacité *', prefixIcon: Icon(Icons.people)),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Capacité requise';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Capacité doit être positive';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags (séparés par des virgules)', prefixIcon: Icon(Icons.label)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image', prefixIcon: Icon(Icons.image)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Enregistrer les modifications'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
