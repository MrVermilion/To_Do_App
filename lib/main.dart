import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const TarefaApp());
}

class TarefaApp extends StatelessWidget {
  const TarefaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TelaTarefa(), // Mantém a tela de tarefas como a tela inicial
      debugShowCheckedModeBanner: false,
    );
  }
}

class FontManager {
  static const String shadowsIntoLightRegular = 'ShadowsIntoLight-Regular';
  static const String quicksandvariablefontwght = 'quicksandvariablefontwght';
  static const String amaticscbold = 'amaticscbold';
  static const String amaticscregular = 'amaticscregular';
}

class TelaTarefa extends StatefulWidget {
  const TelaTarefa({Key? key}) : super(key: key);

  @override
  State<TelaTarefa> createState() => _TelaTarefaState();
}

class _TelaTarefaState extends State<TelaTarefa> {
  final TextEditingController _tarefaController = TextEditingController();
  List<String> _tarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _salvarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('tarefas', _tarefas);
  }

  void _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tarefas = prefs.getStringList('tarefas') ?? [];
    });
  }

  void _adicionarTarefa() {
    setState(() {
      String novaTarefa = _tarefaController.text;
      if (novaTarefa.isNotEmpty) {
        _tarefas.add(novaTarefa);
        _tarefaController.clear();
        _salvarTarefas();
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
      _salvarTarefas();
    });
  }

  Widget _buildTarefasList() {
    return Column(
      children: [
        TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(2022),
          lastDay: DateTime(2025),
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: TextStyle(color: Color(0xFF1B1B18)),
            todayDecoration: BoxDecoration(
              color: Color(0xFF746262),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                      color: Color(0xFF1B1B18),
                      fontSize: 20.0,
                      fontFamily: FontManager.amaticscregular,
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
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LISTA DE TAREFAS',
          style: TextStyle(
            color: Color(0xFF1B1B18),
            fontSize: 55.0,
            fontFamily: FontManager.amaticscbold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFECECE4),
        toolbarHeight: 150.0,
      ),
      body: _buildTarefasList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
