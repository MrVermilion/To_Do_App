import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';

class FontManager {
  static const String shadowsIntoLightRegular = 'ShadowsIntoLight-Regular';
  static const String quicksandvariablefontwght = 'quicksandvariablefontwght';
  static const String amaticscbold = 'amaticscbold';
  static const String amaticscregular = 'amaticscregular';
}

void main() {
  initializeDateFormatting('pt_BR', null);
  runApp(const TarefaApp());
}

class TarefaApp extends StatelessWidget {
  const TarefaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TelaTarefa(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TelaTarefa extends StatefulWidget {
  const TelaTarefa({Key? key}) : super(key: key);

  @override
  State<TelaTarefa> createState() => _TelaTarefaState();
}

class _TelaTarefaState extends State<TelaTarefa> {
  final TextEditingController _tarefaController = TextEditingController();
  List<bool> _tarefasConcluidas = [];
  List<String> _tarefas = [];
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  Future<void> _salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tarefas', _tarefas);
    await prefs.setString('tarefasConcluidas', jsonEncode(_tarefasConcluidas));
  }

  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tarefas = prefs.getStringList('tarefas') ?? [];
      final tarefasConcluidasString =
          prefs.getString('tarefasConcluidas') ?? '[]';
      _tarefasConcluidas =
          (jsonDecode(tarefasConcluidasString) as List<dynamic>).cast<bool>();

      if (_tarefasConcluidas.length != _tarefas.length) {
        while (_tarefasConcluidas.length < _tarefas.length) {
          _tarefasConcluidas.add(false);
        }
        _salvarTarefas();
      }
    });
  }

  void _adicionarTarefa() {
    setState(() {
      String novaTarefa = _tarefaController.text;
      if (novaTarefa.isNotEmpty) {
        _tarefas.add(novaTarefa);
        if (_tarefasConcluidas.length < _tarefas.length) {
          _tarefasConcluidas.add(false);
        }
        _tarefaController.clear();
        _salvarTarefas();

        // Exibir mensagem "Tarefa adicionada"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa adicionada'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _editarTarefa(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
          content: TextField(
            controller: TextEditingController(text: _tarefas[index]),
            decoration: const InputDecoration(labelText: 'Tarefa'),
            onChanged: (valor) {
              setState(() {
                _tarefas[index] = valor;
              });
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                _salvarTarefas();
                Navigator.pop(context);

                // Exibir mensagem "Tarefa Editada"
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tarefa editada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  void _removerTarefa(int index) {
    setState(() {
      _tarefas.removeAt(index);
      _tarefasConcluidas.removeAt(index);
      _salvarTarefas();

      // Exibir mensagem "Tarefa Excluída"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa excluída'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _concluirTarefa(int index) {
    setState(() {
      String tarefaConcluida = _tarefas.removeAt(index);
      bool concluida = _tarefasConcluidas.removeAt(index);
      _tarefas.add(tarefaConcluida);
      _tarefasConcluidas
          .add(!concluida); // Alterar para o novo estado de conclusão
      _salvarTarefas();

      // Exibir mensagem "Tarefa Concluída" somente se a tarefa não estiver concluída
      if (!concluida) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parabéns, Tarefa Concluída'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildTarefasList() {
    return ListView(
      children: [
        Container(
          color: const Color(0xFFDCDACE),
          child: TableCalendar(
            firstDay: DateTime.utc(2022),
            lastDay: DateTime.utc(2025),
            focusedDay: _selectedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.black),
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(color: Colors.white),
              markersMaxCount: 1,
              markersAlignment: Alignment.bottomCenter,
            ),
            locale: 'pt_BR',
            calendarFormat:
                CalendarFormat.week, // Alteração para mostrar apenas a semana
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 200.0,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tarefas.length,
            itemBuilder: (context, index) {
              return _buildTarefaItem(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTarefaItem(int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey<int>(_tarefas.hashCode),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 9.0),
        decoration: BoxDecoration(
          color: const Color(0xFFDCDACE),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF746262),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(-3, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _editarTarefa(index),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _tarefas[index],
                      style: const TextStyle(
                        fontFamily: FontManager.amaticscbold,
                        color: Color(0xFF1B1B18),
                        fontSize: 35.0,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 30),
                    onPressed: () => _editarTarefa(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 30),
                    onPressed: () => _removerTarefa(index),
                  ),
                  InkWell(
                    onTap: () => _concluirTarefa(index),
                    child: Icon(
                      _tarefasConcluidas[index]
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: _tarefasConcluidas[index]
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 180.0,
      height: 47.0,
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  controller: _tarefaController,
                  decoration: const InputDecoration(labelText: 'Tarefa'),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Adicionar'),
                    onPressed: () {
                      _adicionarTarefa();
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        },
        backgroundColor: const Color(0xFFDCDACE),
        child: const Icon(Icons.add, size: 30.0),
      ),
    );
  }

  Widget _buildSelectDayButton() {
    return FloatingActionButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDay,
          firstDate: DateTime(2022),
          lastDate: DateTime(2025),
        );

        if (selectedDate != null) {
          setState(() {
            _selectedDay = selectedDate;
          });
        }
      },
      backgroundColor: const Color(0xFFDCDACE),
      child: const Icon(Icons.calendar_today),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'LISTA DE TAREFAS',
              style: TextStyle(
                color: Color(0xFF1B1B18),
                fontFamily: FontManager.amaticscbold,
                fontSize: 60.0,
              ),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFDCDACE),
            toolbarHeight: 150.0,
            pinned: true, // Mantém a AppBar fixa no topo enquanto rola
          ),
          SliverFillRemaining(
            child: _buildTarefasList(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildFloatingActionButton(),
          const SizedBox(height: 16.0),
          _buildSelectDayButton(),
        ],
      ),
      backgroundColor: const Color(0xFFDCDACE),
    );
  }
}
