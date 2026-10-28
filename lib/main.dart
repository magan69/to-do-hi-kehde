import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String id;
  String title;
  bool isDone;
  String priority;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'priority': priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
      priority: json['priority'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? false;
    });
  }

  Future<void> toggleTheme() async {
    setState(() {
      isDark = !isDark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(isDark: isDark, onToggleTheme: toggleTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final text = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', text);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString('tasks');
    if (text != null) {
      final list = jsonDecode(text) as List;
      setState(() {
        tasks = list.map((item) => Task.fromJson(item)).toList();
      });
    }
  }

  void toggleDone(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });
    saveTasks();
  }

  void deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
    saveTasks();
  }

  Color priorityColor(String priority) {
    if (priority == 'High') return Colors.red;
    if (priority == 'Medium') return Colors.orange;
    return Colors.green;
  }

  void showTaskDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final formKey = GlobalKey<FormState>();
    String priority = task?.priority ?? 'Medium';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(task == null ? 'Add Task' : 'Edit Task'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['Low', 'Medium', 'High']
                          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          priority = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    setState(() {
                      if (task == null) {
                        tasks.add(Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          priority: priority,
                        ));
                      } else {
                        task.title = titleController.text.trim();
                        task.priority = priority;
                      }
                    });
                    saveTasks();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((t) => t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks  ($doneCount/${tasks.length} done)'),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => toggleDone(task),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: priorityColor(task.priority),
                        ),
                        const SizedBox(width: 6),
                        Text('${task.priority} priority'),
                      ],
                    ),
                    onTap: () => showTaskDialog(task: task),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteTask(task),
                    ),
                  ),
                );
              },
            ),
    );
  }
}