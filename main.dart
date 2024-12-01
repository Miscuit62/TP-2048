import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'game_settings_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(My2048Game());
}

class My2048Game extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu du 2048',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GameScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[400]!, Colors.orange[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_4x4,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenue dans le jeu 2048',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  List<int> grid = List.filled(16, 0);
  int moveCount = 0;
  int goalValue = 2048;
  int gridSize = 4;
  int bestScore = 0;
  String colorPalette = 'Default';
  bool randomStart = false;
  bool reverseSum = false;
  String sumMode = 'Classique';

  bool continuePlaying = false;

  final Map<String, Map<String, Color>> palettes = {
    'Default': {
      '0': Colors.grey,
      '2': Colors.orange[100]!,
      '4': Colors.orange[200]!,
      '8': Colors.orange[300]!,
      '16': Colors.orange[400]!,
      '32': Colors.orange[500]!,
      '64': Colors.orange[600]!,
      '128': Colors.orange[700]!,
      '256': Colors.orange[800]!,
      '512': Colors.orange[900]!,
      '1024': Colors.red[400]!,
      '2048': Colors.red[700]!,
      '4096': Colors.purple[400]!,
      '8192': Colors.purple[700]!,
    },
    'Blue': {
      '0': Colors.grey,
      '2': Colors.blue[100]!,
      '4': Colors.blue[200]!,
      '8': Colors.blue[300]!,
      '16': Colors.blue[400]!,
      '32': Colors.blue[500]!,
      '64': Colors.blue[600]!,
      '128': Colors.blue[700]!,
      '256': Colors.blue[800]!,
      '512': Colors.blue[900]!,
      '1024': Colors.indigo[400]!,
      '2048': Colors.indigo[700]!,
      '4096': Colors.green[400]!,
      '8192': Colors.green[700]!,
    },
    'Green': {
      '0': Colors.grey,
      '2': Colors.green[100]!,
      '4': Colors.green[200]!,
      '8': Colors.green[300]!,
      '16': Colors.green[400]!,
      '32': Colors.green[500]!,
      '64': Colors.green[600]!,
      '128': Colors.green[700]!,
      '256': Colors.green[800]!,
      '512': Colors.green[900]!,
      '1024': Colors.teal[400]!,
      '2048': Colors.teal[700]!,
      '4096': Colors.yellow[400]!,
      '8192': Colors.yellow[700]!,
    },
  };

  List<int> goalOptions = [256, 512, 1024, 2048, 4096, 8192];

  List<int> previousGrid = [];
  int previousMoveCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    colorPalette = 'Default';
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      grid = List.filled(gridSize * gridSize, 0);
      moveCount = 0;
      if (randomStart) {
        _fillRandomGrid();
      } else {
        _addRandomTile();
        _addRandomTile();
      }
    });
  }

  void _fillRandomGrid() {
    Random rand = Random();
    int numberOfTiles = rand.nextInt(6) + 5;
    List<int> possibleValues = [2, 4, 8, 16, 32, 64, 128];
    int maxValue = goalValue ~/ 2;
    possibleValues = possibleValues.where((value) => value <= maxValue).toList();

    List<int> emptyIndices = List.generate(16, (index) => index);

    for (int i = 0; i < numberOfTiles; i++) {
      if (emptyIndices.isEmpty) break;
      int randomIndex = emptyIndices.removeAt(rand.nextInt(emptyIndices.length));
      int randomValue = possibleValues[rand.nextInt(possibleValues.length)];
      grid[randomIndex] = randomValue;
    }
  }

  void _addRandomTile() {
    List<int> emptyTiles = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == 0) emptyTiles.add(i);
    }

    if (emptyTiles.isNotEmpty) {
      int randomIndex = emptyTiles[Random().nextInt(emptyTiles.length)];
      grid[randomIndex] = Random().nextBool() ? 2 : 4;
    }
  }

  void _moveTiles(String direction) {
    setState(() {
      previousGrid = List.from(grid);
      previousMoveCount = moveCount;

      bool moved = false;

      if (reverseSum) {
        if (direction == 'up') moved = _moveDown();
        if (direction == 'down') moved = _moveUp();
        if (direction == 'left') moved = _moveRight();
        if (direction == 'right') moved = _moveLeft();
      } else {
        if (direction == 'up') moved = _moveUp();
        if (direction == 'down') moved = _moveDown();
        if (direction == 'left') moved = _moveLeft();
        if (direction == 'right') moved = _moveRight();
      }

      if (moved) {
        _addRandomTile();
        moveCount++;

        int currentScore = _calculateCurrentScore();
        if (currentScore > bestScore) {
          bestScore = currentScore;
          _saveBestScore();
        }

        if (_checkWin()) {
          _showWinDialog();
        } else if (!_movesAvailable()) {
          _showEndDialog('Plus de mouvements disponibles. Vous avez perdu.');
        }
      }
    });
  }

  void _undoMove() {
    if (previousGrid.isNotEmpty) {
      setState(() {
        grid = List.from(previousGrid);
        moveCount = previousMoveCount;
        previousGrid = [];
        previousMoveCount = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun mouvement à annuler.')),
      );
    }
  }


  bool _checkWin() {
    return grid.contains(goalValue) && !continuePlaying;
  }

  bool _movesAvailable() {
    if (grid.contains(0)) return true;

    for (int i = 0; i < grid.length; i++) {
      int current = grid[i];
      if (i % gridSize != gridSize - 1 && current == grid[i + 1]) return true;
      if (i < grid.length - gridSize && current == grid[i + gridSize]) return true;
    }
    return false;
  }

  void _showEndDialog(String message) {
    _updateBestScore();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Jeu Terminé'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: Text('Recommencer'),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Règles du jeu'),
          content: SingleChildScrollView(
            child: Text(
              '''Règles de base :
- La grille accepte les puissances de 2 (2, 4, ..., 8192).
- Déplacez les tuiles avec les mouvements (haut, bas, gauche, droite).
- Combinez les tuiles adjacentes identiques pour les fusionner.

Options disponibles :
1. Objectif :
   - Choisissez votre objectif (256, 512, 1024, 2048, 4096, ou 8192).

2. Choix des couleurs :
   - Personnalisez les couleurs de la grille en sélectionnant l'une des palettes disponibles.
   
3. Taille de la grille :
   - Vous pouvez choisir entre une grille 4x4 ou 8x8.

4. Grille aléatoire :
   - Activez cette option pour démarrer avec une grille aléatoire.

5. Inverser les sommes :
   - Inversez les directions des fusions en activant cette option.
   
6. Mode de fusion :
   - Classique : Les tuiles identiques se combinent en une seule tuile.
   - Fusion Multiple : Permet de fusionner 4 tuiles identiques adjacentes en une seule tuile avec une valeur égale à la somme des 4 tuiles.
   - Double Fusion : Les tuiles identiques se combinent pour doubler leur fusion habituelle.

Astuce :
- Essayez de garder les tuiles les plus grandes dans un coin pour optimiser vos chances de réussite.''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  bool _moveUp() => _mergeRows(columns: true, reverse: false);
  bool _moveDown() => _mergeRows(columns: true, reverse: true);
  bool _moveLeft() => _mergeRows(columns: false, reverse: false);
  bool _moveRight() => _mergeRows(columns: false, reverse: true);

  bool _mergeRows({required bool columns, required bool reverse}) {
    bool moved = false;

    for (int i = 0; i < gridSize; i++) {
      List<int> line = [];
      for (int j = 0; j < gridSize; j++) {
        line.add(columns ? grid[j * gridSize + i] : grid[i * gridSize + j]);
      }
      if (reverse) line = line.reversed.toList();
      moved |= _merge(line);
      if (reverse) line = line.reversed.toList();
      for (int j = 0; j < gridSize; j++) {
        if (columns) {
          grid[j * gridSize + i] = line[j];
        } else {
          grid[i * gridSize + j] = line[j];
        }
      }
    }
    return moved;
  }

  bool _merge(List<int> line) {
    bool moved = false;
    List<int> newLine = line.where((value) => value != 0).toList();

    if (sumMode == 'Classique') {
      for (int i = 0; i < newLine.length - 1; i++) {
        if (newLine[i] == newLine[i + 1]) {
          newLine[i] *= 2;
          newLine[i + 1] = 0;
          moved = true;
        }
      }
    } else if (sumMode == 'Fusion Multiple') {
      for (int i = 0; i < newLine.length - 3; i++) {
        if (newLine[i] == newLine[i + 1] &&
            newLine[i + 1] == newLine[i + 2] &&
            newLine[i + 2] == newLine[i + 3]) {
          newLine[i] = newLine[i] * 4;
          newLine[i + 1] = 0;
          newLine[i + 2] = 0;
          newLine[i + 3] = 0;
          moved = true;
        }
      }
    } else if (sumMode == 'Double Fusion') {
      for (int i = 0; i < newLine.length - 1; i++) {
        if (newLine[i] == newLine[i + 1]) {
          newLine[i] = newLine[i] * 2 * 2;
          newLine[i + 1] = 0;
          moved = true;
        }
      }
    }

    newLine = newLine.where((value) => value != 0).toList();

    while (newLine.length < line.length) {
      newLine.add(0);
    }

    if (!listEquals(line, newLine)) moved = true;

    for (int i = 0; i < line.length; i++) {
      line[i] = newLine[i];
    }

    return moved;
  }

  void _showWinDialog() {
    _updateBestScore();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Félicitations !'),
        content: Text('Vous avez atteint $goalValue !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNewGame();
            },
            child: Text('Recommencer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
  }

  Future<void> _updateBestScore() async {
    if (moveCount > bestScore) {
      setState(() {
        bestScore = moveCount;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('bestScore', bestScore);
    }
  }

  int _calculateCurrentScore() {
    return grid.reduce((sum, tile) => sum + tile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeu du 2048'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.rule),
            onPressed: _showRulesDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GameSettingsScreen(
                    gridSize: gridSize,
                    sumMode: sumMode,
                    goalValue: goalValue,
                    randomStart: randomStart,
                    reverseSum: reverseSum,
                    colorPalette: colorPalette,
                    onSettingsChanged: (
                        newGridSize,
                        newSumMode,
                        newGoalValue,
                        newRandomStart,
                        newReverseSum,
                        newColorPalette,
                        ) {
                      setState(() {
                        gridSize = newGridSize;
                        sumMode = newSumMode;
                        goalValue = newGoalValue;
                        randomStart = newRandomStart;
                        reverseSum = newReverseSum;
                        colorPalette = newColorPalette;
                        _startNewGame();
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 30,
            child: FloatingActionButton(
              onPressed: _undoMove,
              backgroundColor: Colors.orange[100],
              child: Icon(Icons.undo, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              onPressed: _startNewGame,
              backgroundColor: Colors.orange[100],
              child: Icon(Icons.replay, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (event is KeyDownEvent) {
            switch (event.physicalKey) {
              case PhysicalKeyboardKey.arrowUp:
                _moveTiles('up');
                break;
              case PhysicalKeyboardKey.arrowDown:
                _moveTiles('down');
                break;
              case PhysicalKeyboardKey.arrowLeft:
                _moveTiles('left');
                break;
              case PhysicalKeyboardKey.arrowRight:
                _moveTiles('right');
                break;
              default:
                break;
            }
          }
          return KeyEventResult.handled;
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre de coups : $moveCount',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    Text(
                      'Score actuel : ${_calculateCurrentScore()}',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    Text(
                      'Meilleur score : $bestScore',
                      style: TextStyle(fontSize: 20, color: Colors.orange[200]),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dy < 0) {
                        _moveTiles('up');
                      } else if (details.velocity.pixelsPerSecond.dy > 0) {
                        _moveTiles('down');
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx > 0) {
                        _moveTiles('right');
                      } else if (details.velocity.pixelsPerSecond.dx < 0) {
                        _moveTiles('left');
                      }
                    },
                    child: CustomPaint(
                      painter: GridPainter(
                        grid,
                        palettes[colorPalette] ?? palettes['Default']!,
                        gridSize,
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final List<int> grid;
  final Map<String, Color> colorPalette;
  final int gridSize;

  GridPainter(this.grid, this.colorPalette, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    double tileSize = size.width / gridSize;
    Paint paint = Paint();

    for (int i = 0; i < grid.length; i++) {
      int row = i ~/ gridSize;
      int col = i % gridSize;
      Rect rect = Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize);

      paint.color = colorPalette[grid[i].toString()] ?? Colors.grey;
      canvas.drawRect(rect, paint);

      if (grid[i] != 0) {
        TextSpan span = TextSpan(
          text: '${grid[i]}',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(
            rect.left + (tileSize - tp.width) / 2,
            rect.top + (tileSize - tp.height) / 2,
          ),
        );
      }
    }

    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i <= gridSize; i++) {
      double pos = i * tileSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), linePaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


