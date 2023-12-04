import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> data = [];
  DateTime currentTime = DateTime.now();
  String backendIP = 'http://192.168.100.26:3000'; // IP padrão do backend

  @override
  void initState() {
    super.initState();
    // Inicia o Timer para chamar a função fetchData a cada 3 segundos
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$backendIP/registro/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        // Adiciona um novo ponto de dados ao gráfico com o tempo atual
        currentTime = DateTime.now();
        data.add({
          'data': currentTime,
          'celsius': responseData['registros'].last['celsius'],
          'umidade': responseData['registros'].last['umidade'],
        });
      });
    } else {
      throw Exception('Erro ao carregar dados da API');
    }
  }

  void _openSettingsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen(backendIP)),
    );

    if (result != null) {
      setState(() {
        backendIP = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Monitoramento da Estufa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40.0,
          ),
          maxLines: 1,
        ),
        centerTitle: true,
        actions: [
          // Adiciona um botão de configurações na barra de aplicativos
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettingsScreen,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Parte de cima (informações atuais)
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Informações Atuais',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                SizedBox(height: 20),
                Text('Temperatura: ${data.isNotEmpty ? data.last['celsius'] : '-'}°C',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text('Umidade: ${data.isNotEmpty ? data.last['umidade'] : '-'}%',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text('Data: ${data.isNotEmpty ? data.last['data'].toString() : '-'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Parte de baixo (gráfico de linha)
          if (data.isNotEmpty)
            Container(
              height: 300,
              padding: EdgeInsets.all(16.0),
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                series: <ChartSeries>[
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: data,
                    xValueMapper: (Map<String, dynamic> data, _) => data['data'],
                    yValueMapper: (Map<String, dynamic> data, _) => data['celsius'],
                    name: 'Temperatura (°C)',
                    color: Colors.red,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  LineSeries<Map<String, dynamic>, DateTime>(
                    dataSource: data,
                    xValueMapper: (Map<String, dynamic> data, _) => data['data'],
                    yValueMapper: (Map<String, dynamic> data, _) => data['umidade'],
                    name: 'Umidade (%)',
                    color: Colors.blue,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                title: ChartTitle(
                  text: 'Histórico',
                  textStyle: TextStyle(
                    color: Colors.black, // Cor da fonte
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String initialIP;

  SettingsScreen(this.initialIP);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController ipController;
  late String currentIP;

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController(text: widget.initialIP);
    currentIP = widget.initialIP;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IP do Backend:'),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                hintText: 'Informe o IP do backend',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retorna o novo IP para a tela principal
                Navigator.pop(context, ipController.text);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}