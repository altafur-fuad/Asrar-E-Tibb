// lib/reminder/create_schedule_page.dart
import 'package:flutter/material.dart';
import '../data/data_provider.dart';
import '../models/medicine_model.dart';

class CreateSchedulePage extends StatefulWidget {
  const CreateSchedulePage({super.key});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<String?> _showMedicinePickerDialog() {
    String searchQuery = '';
    final medicinesFuture = DataProvider.loadMedicines();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Search medicine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Brand / generic / manufacturer...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (v) =>
                            setState(() => searchQuery = v.trim()),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<Medicine>>(
                    future: medicinesFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final meds = snap.data ?? [];
                      final filtered = searchQuery.isEmpty
                          ? meds
                          : meds.where((m) {
                              final q = searchQuery.toLowerCase();
                              return m.brandName.toLowerCase().contains(q) ||
                                  m.generic.toLowerCase().contains(q) ||
                                  m.manufacturer.toLowerCase().contains(q);
                            }).toList();
                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('No results for "$searchQuery".'),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final med = filtered[i];
                          return ListTile(
                            title: Text(
                              med.brandName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${med.generic} • ${med.strength}\n${med.manufacturer}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () =>
                                Navigator.of(context).pop(med.brandName),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final dose = _doseCtrl.text.trim();
    final time = _selectedTime != null ? _selectedTime!.format(context) : '';
    if (name.isEmpty || dose.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick a time')),
      );
      return;
    }
    Navigator.of(
      context,
    ).pop({'medicine_name': name, 'dose': dose, 'time': time});
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _selectedTime == null
        ? 'Pick Time'
        : 'Time: ${_selectedTime!.format(context)}';
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              readOnly: true,
              onTap: () async {
                final sel = await _showMedicinePickerDialog();
                if (sel != null && sel.isNotEmpty) _nameCtrl.text = sel;
              },
              decoration: const InputDecoration(
                labelText: 'Medicine (tap to search)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _doseCtrl,
              decoration: const InputDecoration(
                labelText: 'Dose e.g. 1 tablet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    child: Text(timeText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
