import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  DateTime? dueDate;
  String? notes;
  String category;
  bool isCompleted;

  Task({
    required this.title,
    this.dueDate,
    this.isCompleted = false,
    this.notes,
    required this.category,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFB6C7A7), // Soft green
        scaffoldBackgroundColor: const Color(0xFFB6C7A7), // Soft green
        cardColor: const Color(0xFFFDF6E3), // Off-white
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDF6E3),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF6D7B6D)),
          titleTextStyle: TextStyle(
            color: Color(0xFF6D7B6D),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFEFA7A7), // Soft pink
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFDF6E3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> todoList = [];
  final TextEditingController _controller = TextEditingController();
  DateTime? selectedDate;
  int updateIndex = -1;
  String selectedEmoji = '🍀';
  final List<String> emojiOptions = ['😅', '😎', '🐱', '🌟', '🎉', '🦄', '🍀', '💡', '🔥', '😊'];
  String? tempNotes;
  List<String> categories = ['Work', 'Personal', 'Shopping', 'Study', 'Other'];
  String selectedCategory = 'Work';
  String filterCategory = 'All';

  final Map<String, Color> categoryColors = {
    'Work': const Color(0xFFECE0EE),
    'Personal': const Color(0xFFCFCEE5),
    'Shopping': const Color(0xFFF4B0A8),
    'Study': const Color(0xFFF5D6E0),
    'Other': const Color(0xFFABDADA),
    // Add more default colors as needed
  };

  void addTask(String title, {String? notes, String? category}) {
    if (title.trim().isEmpty) return;
    setState(() {
      todoList.add(Task(
        title: title.trim(),
        dueDate: selectedDate,
        isCompleted: false,
        notes: notes,
        category: category ?? selectedCategory,
      ));
      clearInputs();
    });
  }

  void updateTask(String title, int index, {String? notes, String? category}) {
    if (title.trim().isEmpty) return;
    setState(() {
      todoList[index] = Task(
        title: title.trim(),
        dueDate: selectedDate,
        isCompleted: todoList[index].isCompleted,
        notes: notes,
        category: category ?? selectedCategory,
      );
      updateIndex = -1;
      clearInputs();
    });
  }

  void deleteTask(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  void clearInputs() {
    _controller.clear();
    selectedDate = null;
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void showTaskModal({bool isEdit = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        TextEditingController tempController = TextEditingController(text: _controller.text);
        TextEditingController notesController = TextEditingController(text: tempNotes ?? '');
        String modalCategory = isEdit && updateIndex != -1 ? todoList[updateIndex].category : selectedCategory;
        TextEditingController newCategoryController = TextEditingController();
        bool showNewCategoryField = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Task' : 'Add New Task',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tempController,
                      decoration: const InputDecoration(
                        hintText: 'Enter task title',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Notes (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        DateTime now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).inputDecorationTheme.fillColor,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedDate == null
                                    ? 'Set Due Date'
                                    : DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null ? Colors.grey[700] : Colors.black87,
                                ),
                              ),
                            ),
                            if (selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setModalState(() => selectedDate = null),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Category:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: modalCategory,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                          items: [
                            ...categories.map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            )),
                            const DropdownMenuItem(
                              value: '__add_new__',
                              child: Text('+ Add New', style: TextStyle(fontStyle: FontStyle.italic)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == '__add_new__') {
                              setModalState(() {
                                showNewCategoryField = true;
                              });
                            } else if (val != null) {
                              setModalState(() {
                                modalCategory = val;
                                showNewCategoryField = false;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (showNewCategoryField)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: newCategoryController,
                                decoration: const InputDecoration(hintText: 'New category'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () {
                                if (newCategoryController.text.trim().isNotEmpty) {
                                  setModalState(() {
                                    categories.add(newCategoryController.text.trim());
                                    modalCategory = newCategoryController.text.trim();
                                    showNewCategoryField = false;
                                  });
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFA7A7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.text = tempController.text;
                            tempNotes = notesController.text;
                            selectedCategory = modalCategory;
                          });
                          if (isEdit && updateIndex != -1) {
                            updateTask(_controller.text, updateIndex, notes: notesController.text, category: modalCategory);
                          } else {
                            addTask(_controller.text, notes: notesController.text, category: modalCategory);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(isEdit ? 'Update Task' : 'Add Task', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = todoList.where((t) => t.isCompleted).length;
    List<Task> filteredTasks = todoList.where((task) {
      if (filterCategory == 'All') {
        return true;
      } else {
        return task.category == filterCategory;
      }
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 2,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tasks: ${todoList.length}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Completed: $completedCount',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      child: _HoverableEmojiAvatar(
                        emoji: selectedEmoji,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: emojiOptions.map((emoji) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => selectedEmoji = emoji);
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: selectedEmoji == emoji ? const Color(0xFFEFA7A7) : Colors.grey[200],
                                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category Filter Chips
            SizedBox(
              height: 40, // Height for chips row
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 4), // Padding for first chip
                  GestureDetector(
                    onTap: () => setState(() => filterCategory = 'All'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: filterCategory == 'All' ? Theme.of(context).primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: filterCategory == 'All' ? Colors.white : Colors.black87,
                          fontWeight: filterCategory == 'All' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _HoverableCategoryChip(
                        label: category,
                        isSelected: filterCategory == category,
                        onTap: () => setState(() => filterCategory = category),
                      ),
                    );
                  }).toList(),
                  const SizedBox(width: 4), // Padding for last chip
                ],
              ),
            ),
            const SizedBox(height: 10), // Adjusted spacing
            // Task List
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(child: Text('No tasks found for this category.'))
                  : ListView.separated(
                      itemCount: filteredTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 1,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Checkbox(
                              value: task.isCompleted,
                              shape: const CircleBorder(),
                              activeColor: categoryColors[task.category] ?? Theme.of(context).primaryColor,
                              onChanged: (val) {
                                setState(() {
                                  // Find the original task in todoList to update completion status
                                  int originalIndex = todoList.indexOf(task);
                                  if (originalIndex != -1) {
                                    todoList[originalIndex].isCompleted = val ?? false;
                                  }
                                });
                              },
                            ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      color: task.isCompleted ? Colors.grey : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: categoryColors[task.category] ?? Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      task.category,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: (task.dueDate != null || (task.notes != null && task.notes!.isNotEmpty))
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (task.dueDate != null)
                                        Text("Due: "+DateFormat('dd MMM yyyy').format(task.dueDate!)),
                                      if (task.notes != null && task.notes!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            task.notes!,
                                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                          ),
                                        ),
                                    ],
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFFB6C7A7)),
                                  onPressed: () {
                                    setState(() {
                                      _controller.text = task.title;
                                      selectedDate = task.dueDate;
                                      tempNotes = task.notes; // Load notes for editing
                                      selectedCategory = task.category; // Load category for editing
                                      updateIndex = todoList.indexOf(task); // Find index in original list
                                    });
                                    showTaskModal(isEdit: true);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFEFA7A7)),
                                  onPressed: () {
                                     // Find the original task in todoList to delete
                                    int originalIndex = todoList.indexOf(task);
                                    if (originalIndex != -1) {
                                       deleteTask(originalIndex);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          clearInputs();
          showTaskModal();
        },
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HoverableEmojiAvatar extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;
  const _HoverableEmojiAvatar({required this.emoji, required this.onTap});

  @override
  State<_HoverableEmojiAvatar> createState() => _HoverableEmojiAvatarState();
}

class _HoverableEmojiAvatarState extends State<_HoverableEmojiAvatar> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.12 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 255, 211, 211),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            width: 64,
            height: 64,
            alignment: Alignment.center,
            child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
          ),
        ),
      ),
    );
  }
}

class _HoverableCategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HoverableCategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HoverableCategoryChip> createState() => _HoverableCategoryChipState();
}

class _HoverableCategoryChipState extends State<_HoverableCategoryChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    Color categoryColor = (context.findAncestorStateOfType<_HomeScreenState>()?.categoryColors ?? {})[widget.label] ?? Colors.grey[200]!;
    Color bgColor = widget.isSelected ? categoryColor : Colors.grey[200]!;
    Color textColor = widget.isSelected ? (categoryColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white) : Colors.black87;
    FontWeight fontWeight = widget.isSelected ? FontWeight.bold : FontWeight.normal;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering ? bgColor.withOpacity(0.8) : bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}
