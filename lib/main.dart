import 'package:flutter/material.dart';
import 'package:stockfish/stockfish.dart';
import 'package:dartchess/dartchess.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final stockfish = Stockfish();
  final setup = Setup.parseFen('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
  var pos;
  List<String> moves = [];

  Future<String> containsP() async {
    await for (final event in stockfish.stdout) {
      if (event.contains('bestmove')) {
        return event;
      }
    }
    return "";
  }

  Future<String> getCompMove() async {
    print(stockfish.state.value);
    String strMove = "";
    stockfish.stdin = 'position fen ${pos.fen}';
    stockfish.stdin = 'go movetime 1000';
    strMove = await containsP();
    print(strMove);
    return strMove.split(" ")[1];
  }

  void setMove() async {
    String strMove = await getCompMove();
    Move? move = Move.fromUci(strMove);
    setState(() {
      pos = pos.play(move);
      moves.add(strMove);
    });
    print(move);
    print(pos.fen);
  }

  @override
  void initState() {
    pos = Chess.fromSetup(setup);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${pos.fen}',
            ),
            for(var move in moves)
              Text(move)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: setMove,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
