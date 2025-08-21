import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocket_tasks/provider/task_provider.dart';
import 'package:pocket_tasks/provider/theme_provider.dart';
import 'package:pocket_tasks/screen/progress_ring.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _addController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _errorText;

  @override
  void dispose() {
    _addController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pocket-Tasks"),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.fromARGB(255, 90, 72, 191),
                Color(0xFF00008B),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    const ProgressRing(size: 60),
                    const SizedBox(width: 20),
                    const Text(
                      "PocketTasks",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Add Task Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _addController,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        decoration: InputDecoration(
                          hintText: "Add Task",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF00008B),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF00008B),
                              width: 2,
                            ),
                          ),
                          errorText: _errorText,
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = _addController.text.trim();
                        if (text.isEmpty) {
                          setState(() {
                            _errorText = "Task title cannot be empty";
                          });
                          return;
                        }
                        setState(() {
                          _errorText = null;
                        });
                        context.read<TaskProvider>().addTask(text);
                        _addController.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(222, 63, 63, 221),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Add",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel(); 
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      context.read<TaskProvider>().setQuery(value);
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF00008B),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF00008B),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    chip(
                      label: "All",
                      isSelected: taskProvider.filter == TaskFilter.all,
                      onTap: () => taskProvider.setFilter(TaskFilter.all),
                    ),
                    chip(
                      label: "Active",
                      isSelected: taskProvider.filter == TaskFilter.active,
                      onTap: () => taskProvider.setFilter(TaskFilter.active),
                    ),
                    chip(
                      label: "Done",
                      isSelected: taskProvider.filter == TaskFilter.done,
                      onTap: () => taskProvider.setFilter(TaskFilter.done),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Task List

                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  height: height * 0.558,
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: ValueKey(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          final removedTask = task;
                          final removedIndex = index;
                          context.read<TaskProvider>().deleteTask(task.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Deleted '${removedTask.title}'"),
                              action: SnackBarAction(
                                label: "Undo",
                                onPressed: () {
                                  context
                                      .read<TaskProvider>()
                                      .insertAt(removedTask, removedIndex);
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          onTap: () {
                            context.read<TaskProvider>().toggleTask(task.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(task.done
                                    ? "Marked '${task.title}' as active"
                                    : "Marked '${task.title}' as done"),
                                action: SnackBarAction(
                                  label: "Undo",
                                  onPressed: () {
                                    context
                                        .read<TaskProvider>()
                                        .toggleTask(task.id);
                                  },
                                ),
                              ),
                            );
                          },
                          leading: Icon(
                            task.done
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color:
                                task.done ? Colors.greenAccent : Colors.white70,
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.white,
                              decoration:
                                  task.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget chip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00008B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check, color: Colors.white, size: 16),
          ]
        ],
      ),
    ),
  );
}
