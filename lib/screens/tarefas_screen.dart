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
    try {
      final lista = await _dbHelper.listarTarefas();
      if (mounted) {
        setState(() {
          _tarefas = lista;
        });
      }
    } catch (e, stack) {
      debugPrint('Erro ao carregar tarefas: $e\n$stack');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // Desafio Avançado: Busca Local via SQL (LIKE)
  Future<void> _executarBusca(String termo) async {
    setState(() => _carregando = true);
    try {
      final lista = termo.trim().isEmpty
          ? await _dbHelper.listarTarefas()
          : await _dbHelper.buscarTarefas(termo.trim());
      if (mounted) {
        setState(() {
          _tarefas = lista;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar tarefas: $e');
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  // Desafio Básico: Contador de Concluídas
  String _contadorTexto() {
    final total = _tarefas.length;
    final concluidas = _tarefas.where((t) => t.concluida).length;
    return '$concluidas/$total concluídas';
  }

  void _abrirFormulario({TarefaModel? tarefa}) {
    final tituloController = TextEditingController(text: tarefa?.titulo ?? '');
    final descController = TextEditingController(text: tarefa?.descricao ?? '');

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
            const SizedBox(height: 12),
            TextField(
              controller: tituloController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final titulo = tituloController.text.trim();
                if (titulo.isEmpty) return;

                if (tarefa == null) {
                  await _dbHelper.criarTarefa(
                    TarefaModel(
                      titulo: titulo,
                      descricao: descController.text.trim(),
                    ),
                  );
                } else {
                  await _dbHelper.atualizarTarefa(
                    TarefaModel(
                      id: tarefa.id,
                      titulo: titulo,
                      descricao: descController.text.trim(),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas SQLite'),
        centerTitle: true,
        // Desafio Básico: Contador de Concluídas visível com bom contraste
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _contadorTexto(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        actions: [
          // Desafio Avançado: Botão para abrir/fechar campo de busca
          IconButton(
            icon: Icon(_buscando ? Icons.close : Icons.search),
            tooltip: _buscando ? 'Fechar busca' : 'Buscar',
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
          // Desafio Avançado: Campo de busca local via SQL (LIKE)
          if (_buscando)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _buscaController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por título ou descrição...',
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
                    ? Center(
                        child: Text(
                          _buscando
                              ? 'Nenhuma tarefa encontrada para esta busca.'
                              : 'Nenhuma tarefa cadastrada.',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      )
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
