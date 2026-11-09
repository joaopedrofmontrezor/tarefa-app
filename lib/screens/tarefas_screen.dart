import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/tarefa_model.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _dbHelper = DatabaseHelper.instance;
  List<TarefaModel> _tarefas = [];
  bool _carregando = true;
  bool _buscando = false;
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTarefas() async {
    setState(() => _carregando = true);
    final lista = await _dbHelper.listarTarefas();
    setState(() {
      _tarefas = lista;
      _carregando = false;
    });
  }

  
  Future<void> _executarBusca(String termo) async {
    setState(() => _carregando = true);
    final lista = termo.isEmpty
        ? await _dbHelper.listarTarefas()
        : await _dbHelper.buscarTarefas(termo);
    setState(() {
      _tarefas = lista;
      _carregando = false;
    });
  }

 
  String _contadorTexto() {
    final total = _tarefas.length;
    final concluidas = _tarefas.where((t) => t.concluida).length;
    return '$concluidas/$total concluídas';
  }

  void _abrirFormulario({TarefaModel? tarefa}) {
    final tituloController =
        TextEditingController(text: tarefa?.titulo ?? '');
    final descController =
        TextEditingController(text: tarefa?.descricao ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (tituloController.text.isEmpty) return;
                if (tarefa == null) {
                  await _dbHelper.criarTarefa(
                    TarefaModel(
                      titulo: tituloController.text,
                      descricao: descController.text,
                    ),
                  );
                } else {
                  await _dbHelper.atualizarTarefa(
                    TarefaModel(
                      id: tarefa.id,
                      titulo: tituloController.text,
                      descricao: descController.text,
                      concluida: tarefa.concluida,
                    ),
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _carregarTarefas();
              },
              child: Text(tarefa == null ? 'Salvar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas SQLite'),
        centerTitle: true,
       
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _contadorTexto(),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
        actions: [
          
          IconButton(
            icon: Icon(_buscando ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _buscando = !_buscando;
                if (!_buscando) {
                  _buscaController.clear();
                  _carregarTarefas();
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
        
          if (_buscando)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _buscaController,
                decoration: InputDecoration(
                  hintText: 'Buscar tarefas...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _buscaController.clear();
                      _carregarTarefas();
                    },
                  ),
                ),
                onChanged: (valor) => _executarBusca(valor),
              ),
            ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _tarefas.isEmpty
                    ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
                    : ListView.builder(
                        itemCount: _tarefas.length,
                        itemBuilder: (ctx, index) {
                          final t = _tarefas[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: t.concluida,
                                onChanged: (val) async {
                                  await _dbHelper.atualizarTarefa(
                                    TarefaModel(
                                      id: t.id,
                                      titulo: t.titulo,
                                      descricao: t.descricao,
                                      concluida: val ?? false,
                                    ),
                                  );
                                  _carregarTarefas();
                                },
                              ),
                              title: Text(
                                t.titulo,
                                style: TextStyle(
                                  decoration: t.concluida
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text(t.descricao),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await _dbHelper.deletarTarefa(t.id!);
                                  _carregarTarefas();
                                },
                              ),
                              onTap: () => _abrirFormulario(tarefa: t),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
