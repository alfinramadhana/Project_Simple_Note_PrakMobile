import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:pertemuan9/extensions/format_date.dart';
import 'package:pertemuan9/utils/app_routes.dart';

import '../db/database_service.dart';
import '../models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseService dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Simple Note',
          style: TextStyle(fontSize: 25),
        ),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.boxName).listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('Tidak ada catatan'),
            );
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final note = box.getAt(index);
                return NoteCard(
                  note: note,
                  databaseService: dbService,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).pushNamed('add-note');
        },
        child: const Icon(Icons.note_add_rounded),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.databaseService,
  });

  final Note note;
  final DatabaseService databaseService;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.key.toString()),
      onDismissed: (_) {
        databaseService.deleteNote(note).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Catatan berhasil dihapus'),
          ));
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey[300],
        ),
        child: ListTile(
          onTap: () {
            GoRouter.of(context).pushNamed(
              AppRoutes.editNote,
              extra: note,
            );
          },
          title: Text(
            note.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(note.desc),
          trailing: Text('Dibuat pada:\n ${note.createdAt.formatDate()}'),
        ),
      ),
    );
  }
}
