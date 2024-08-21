import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kkunlmnwicamfviyqcvz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtrdW5sbW53aWNhbWZ2aXlxY3Z6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjQwMTY2OTEsImV4cCI6MjAzOTU5MjY5MX0.-PhaVR9hKcAbBi4XYzMYbf-MtMQrmgoB0Lt1QUcZgX8',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FisioPro - Agendamentos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String? _nome;
  String? _data;
  String? _hora;
  String? _nomeinfo;
  String? _datainfo;
  String? _horainfo;
  final _agendamentosStream =
      Supabase.instance.client.from('agendamentos').stream(primaryKey: ['id']).eq('concluido', 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _agendamentosStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final agendamentos = snapshot.data!;
            return ListView.builder(
                itemCount: agendamentos.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.edit_calendar),
                      title: Text('${agendamentos[index]['nome']}'),
                      subtitle: Text(
                          '${agendamentos[index]['data']} ${agendamentos[index]['hora']}'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: ((context) {
                            return SimpleDialog(
                              title: const Text('Agendamento'),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: TextEditingController(
                                            text:
                                                '${agendamentos[index]['nome']}'),
                                        decoration: const InputDecoration(
                                          hintText: 'Nome',
                                        ),
                                        onSaved: (valuenome) {
                                          _nomeinfo = valuenome;
                                        },
                                      ),
                                      TextFormField(
                                        controller: TextEditingController(
                                            text:
                                                '${agendamentos[index]['data']}'),
                                        decoration: const InputDecoration(
                                          hintText: 'Data do Agendamento',
                                        ),
                                        onSaved: (valuedata) {
                                          _datainfo = valuedata;
                                        },
                                      ),
                                      TextFormField(
                                        controller: TextEditingController(
                                            text:
                                                '${agendamentos[index]['hora']}'),
                                        decoration: const InputDecoration(
                                          hintText: 'Hora do Agendamento',
                                        ),
                                        onSaved: (valuehora) {
                                          _horainfo = valuehora;
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.delete_outline_sharp),
                                                SizedBox(width: 0),
                                                Text('Excluir') ,
                                              ],
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _formKey.currentState!.save();

                                                await Supabase.instance.client
                                                    .from('agendamentos')
                                                    .delete()
                                                    /*
                                                    .eq('nome', agendamentos[index]['nome'])
                                                    .eq('hora', agendamentos[index]['hora']);
                                                    */
                                                    .eq('id', agendamentos[index]['id']);
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.save_outlined),
                                                SizedBox(width: 0),
                                                Text('Salvar'),
                                              ],
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _formKey.currentState!.save();

                                                await Supabase.instance.client
                                                    .from('agendamentos')
                                                    .update({
                                                      'nome': _nomeinfo,
                                                      'data': _datainfo,
                                                      'hora': _horainfo,
                                                    })
                                                    .eq('id', agendamentos[index]['id']);
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Row(
                                              children: [
                                                Icon(Icons.done),
                                                SizedBox(width: 0),
                                                Text('Concluir'),
                                              ],
                                            ),
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _formKey.currentState!.save();

                                                await Supabase.instance.client
                                                    .from('agendamentos')
                                                    .update({
                                                      'concluido': 1,
                                                    })
                                                    .eq('id', agendamentos[index]['id']);
                                              }
                                              setState(() {
                                                agendamentos.removeAt(index);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: ((context) {
              return SimpleDialog(
                title: const Text('Agendar Consulta'),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Nome',
                          ),
                          onSaved: (valuenome) {
                            _nome = valuenome;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Data do Agendamento',
                          ),
                          onSaved: (valuedata) {
                            _data = valuedata;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Hora do Agendamento',
                          ),
                          onSaved: (valuehora) {
                            _hora = valuehora;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                fixedSize: const Size(100, 50),
                              ),
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                                fixedSize: const Size(100, 50),
                              ),
                              child: const Text('Agendar'),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  await Supabase.instance.client
                                      .from('agendamentos')
                                      .insert({
                                    'nome': _nome,
                                    'data': _data,
                                    'hora': _hora,
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
