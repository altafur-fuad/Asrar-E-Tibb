// lib/notepad/notepad_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';
import 'note_editor_page.dart';

class NotepadPage extends StatefulWidget {
  const NotepadPage({super.key});

  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  bool showNotes = true;
  String? _userId;
  Stream<List<Map<String, dynamic>>>? _notesStream;
  Stream<List<Map<String, dynamic>>>? _todosStream;

  @override
  void initState() {
    super.initState();
    final u = Supabase.instance.client.auth.currentUser;
    _userId = u?.id;
    if (_userId != null) {
      _notesStream = SupabaseService.notesStream(_userId!);
      _todosStream = SupabaseService.todosStream(_userId!);
    }
  }

  Future<void> _openNewNote() async {
    if (_userId == null) return;
    final res = await Navigator.push<Map<String, String>?>(
      context,
      MaterialPageRoute(builder: (_) => const NoteEditorPage()),
    );
    if (res != null && res['content'] != null) {
      await SupabaseService.createNote(
        userId: _userId!,
        title: res['title'] ?? '',
        content: res['content']!,
      );
    }
  }

  Future<void> _editNote(Map<String, dynamic> note) async {
    if (_userId == null) return;
    final res = await Navigator.push<Map<String, String>?>(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorPage(initial: note)),
    );
    if (res != null) {
      await SupabaseService.updateNote(
        noteId: note['id'].toString(),
        userId: _userId!,
        title: res['title'],
        content: res['content'],
      );
    }
  }

  Future<void> _deleteNote(Map<String, dynamic> note) async {
    if (_userId == null) return;
    await SupabaseService.deleteNote(note['id'].toString(), _userId!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note deleted')));
  }

  Future<void> _addTodo() async {
    if (_userId == null) return;
    final textController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Task'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (ok == true && textController.text.trim().isNotEmpty) {
      await SupabaseService.createTodo(
        userId: _userId!,
        text: textController.text.trim(),
      );
    }
  }

  Future<void> _toggleTodo(Map<String, dynamic> todo, bool done) async {
    if (_userId == null) return;
    await SupabaseService.toggleTodoDone(
      todoId: todo['id'].toString(),
      userId: _userId!,
      done: done,
    );
  }

  Future<void> _deleteTodo(Map<String, dynamic> todo) async {
    if (_userId == null) return;
    await SupabaseService.deleteTodo(todo['id'].toString(), _userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notepad'),
        actions: [
          IconButton(
            icon: Icon(
              showNotes ? Icons.checklist_rounded : Icons.article_rounded,
            ),
            onPressed: () => setState(() => showNotes = !showNotes),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: FloatingActionButton(
          onPressed: showNotes ? _openNewNote : _addTodo,
          child: Icon(showNotes ? Icons.note_add : Icons.add_task),
        ),
      ),

      body: _userId == null
          ? const Center(child: Text('Please login to use notes and tasks'))
          : showNotes
          ? StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notesStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snap.data ?? [];
                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      'No notes yet\nTap + to create one',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, idx) {
                    final n = notes[idx];
                    return GestureDetector(
                      onTap: () => _editNote(n),
                      child: Dismissible(
                        key: Key(n['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _deleteNote(n),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  n['content'] ?? '',
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _todosStream,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snap.data ?? [];
                if (todos.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks yet\nTap + to add',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: todos.length,
                  itemBuilder: (context, idx) {
                    final t = todos[idx];
                    return Dismissible(
                      key: Key(t['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteTodo(t),
                      child: Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: t['done'] == true,
                            onChanged: (v) => _toggleTodo(t, v ?? false),
                          ),
                          title: Text(t['text'] ?? ''),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
