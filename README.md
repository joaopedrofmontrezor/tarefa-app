# 📋 Aula 13 — Persistência de Dados Relacionais com SQLite (`sqflite`)

**Disciplina:** Programação para Dispositivos Móveis I  
**Professor:** Diego Menegassi  
**Semestre:** 2026/2  

---

## 📖 Visão Geral do Projeto

Este projeto consiste em um **Gerenciador de Tarefas / Anotações** desenvolvido em **Flutter**, utilizando o motor relacional **SQLite** por meio do pacote `sqflite` (e suporte FFI via `sqflite_common_ffi` para execução em Desktop).

O aplicativo implementa o ciclo completo de operações **CRUD** com persistência offline, arquitetura desacoplada via padrão **Singleton** e interface reativa atualizada via `ListView.builder`.

---

## 🎯 Funcionalidades Implementadas

### 🔄 Operações CRUD

| Operação CRUD | Método `sqflite` | Comando SQL Correspondente | Ação no Aplicativo |
| :--- | :--- | :--- | :--- |
| **Create (Inserir)** | `db.insert()` | `INSERT INTO tarefas VALUES (...)` | Salva nova tarefa a partir do formulário modal (`ModalBottomSheet`). |
| **Read (Consultar)** | `db.query()` | `SELECT * FROM tarefas ORDER BY id DESC` | Carrega e exibe a lista ordenada de tarefas. |
| **Update (Atualizar)** | `db.update()` | `UPDATE tarefas SET ... WHERE id = ?` | Alterna status de conclusão via checkbox ou edita dados no modal. |
| **Delete (Excluir)** | `db.delete()` | `DELETE FROM tarefas WHERE id = ?` | Remove a tarefa do banco através do botão de lixeira. |

---

### 🏆 Desafios Práticos Implementados

Além do roteiro base, o projeto implementa os seguintes desafios:

1. **Contador de Concluídas (Nível Básico):**
   - Exibição dinâmica no `AppBar` indicando o progresso das tarefas no formato `X/Y concluídas`.
2. **Busca Local via SQL LIKE (Nível Avançado):**
   - Campo de pesquisa interativo que executa consultas SQL filtradas em tempo real com a cláusula `WHERE titulo LIKE ? OR descricao LIKE ?`.

---

## 🏗️ Arquitetura e Padrões de Projeto

- **Singleton Pattern (`DatabaseHelper`):** Garante uma única instância aberta da conexão com o banco SQLite em todo o ciclo de vida do app.
- **Data Transfer Object (`TarefaModel`):** Métodos de serialização e desserialização:
  - `toMap()`: Converte a entidade Dart em `Map<String, dynamic>` para inserção/atualização no banco.
  - `fromMap()`: Converte registros retornados pelo SQLite em instâncias tipadas de `TarefaModel`.
- **Interface Reativa:** Sincronização automática entre o banco de dados e a interface utilizando `StatefulWidget`, `setState()` e `ListView.builder`.
- **Suporte Multiplataforma (Desktop Windows & Mobile):** Configuração com `sqflite_common_ffi` no `main.dart`, permitindo executar tanto em emuladores Android quanto nativamente no Windows Desktop.

---

## 📂 Estrutura de Pastas

```text
lib/
├── database/
│   └── database_helper.dart  # Conexão SQLite (Singleton) e métodos CRUD/Busca
├── models/
│   └── tarefa_model.dart     # Modelo de dados com toMap() e fromMap()
├── screens/
│   └── tarefas_screen.dart   # Tela principal, listagem, formulários e busca
└── main.dart                 # Inicialização do app, FFI e configuração de tema
```

---

## 📦 Dependências Utilizadas

Configuradas no arquivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.4.5
  path: ^1.9.1
  sqflite_common_ffi: ^2.4.5
  sqlite3_flutter_libs: ^0.6.0+eol
  cupertino_icons: ^1.0.8
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- **Flutter SDK** instalado (versão 3.x ou superior)
- Dispositivo Android (ou emulador) configurado **ou** ambiente desktop Windows habilitado (`flutter config --enable-windows-desktop`)

### Passos:

1. **Clone o repositório ou acesse a pasta do projeto:**
   ```bash
   cd aula13_sqlite
   ```

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute a aplicação:**
   - No Windows Desktop:
     ```bash
     flutter run -d windows
     ```
   - No Android (emulador ou dispositivo físico conectado):
     ```bash
     flutter run -d android
     ```
