import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarefa_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tarefas_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE tarefas ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'titulo TEXT NOT NULL, '
      'descricao TEXT NOT NULL, '
      'concluida INTEGER NOT NULL'
      ')',
    );
  }

  Future<int> criarTarefa(TarefaModel tarefa) async {
    final db = await instance.database;
    return await db.insert('tarefas', tarefa.toMap());
  }

 
  Future<List<TarefaModel>> listarTarefas() async {
    final db = await instance.database;
    final result = await db.query('tarefas', orderBy: 'id DESC');
    return result.map((map) => TarefaModel.fromMap(map)).toList();
  }

  Future<int> atualizarTarefa(TarefaModel tarefa) async {
    final db = await instance.database;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }


  Future<int> deletarTarefa(int id) async {
    final db = await instance.database;
    return await db.delete('tarefas', where: 'id = ?', whereArgs: [id]);
  }

  
  Future<List<TarefaModel>> buscarTarefas(String termo) async {
    final db = await instance.database;
    final result = await db.query(
      'tarefas',
      where: 'titulo LIKE ? OR descricao LIKE ?',
      whereArgs: ['%$termo%', '%$termo%'],
      orderBy: 'id DESC',
    );
    return result.map((map) => TarefaModel.fromMap(map)).toList();
  }
}

