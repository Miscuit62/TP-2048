import 'package:flutter/material.dart';

class GameSettingsScreen extends StatefulWidget {
  final int gridSize;
  final String sumMode;
  final int goalValue;
  final bool randomStart;
  final bool reverseSum;
  final String colorPalette;
  final Function(int, String, int, bool, bool, String) onSettingsChanged;

  GameSettingsScreen({
    required this.gridSize,
    required this.sumMode,
    required this.goalValue,
    required this.randomStart,
    required this.reverseSum,
    required this.colorPalette,
    required this.onSettingsChanged,
  });

  @override
  _GameSettingsScreenState createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  late int selectedGridSize;
  late String selectedSumMode;
  late int selectedGoalValue;
  late bool randomStart;
  late bool reverseSum;
  late String selectedColorPalette;

  @override
  void initState() {
    super.initState();
    selectedGridSize = widget.gridSize;
    selectedSumMode = widget.sumMode;
    selectedGoalValue = widget.goalValue;
    randomStart = widget.randomStart;
    reverseSum = widget.reverseSum;
    selectedColorPalette = widget.colorPalette;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres du Jeu'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Objectif',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  DropdownButton<int>(
                    value: selectedGoalValue,
                    dropdownColor: Colors.grey[800],
                    items: [256, 512, 1024, 2048, 4096, 8192].map((goal) {
                      return DropdownMenuItem<int>(
                        value: goal,
                        child: Text(
                          'Objectif : $goal',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGoalValue = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choix des couleurs',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  DropdownButton<String>(
                    value: selectedColorPalette,
                    dropdownColor: Colors.grey[800],
                    items: ['Default', 'Blue', 'Green']
                        .map((palette) => DropdownMenuItem<String>(
                      value: palette,
                      child: Text(
                        'Palette : $palette',
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedColorPalette = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taille de la grille',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  DropdownButton<int>(
                    value: selectedGridSize,
                    dropdownColor: Colors.grey[800],
                    items: [4, 8].map((size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text(
                          'Grille ${size}x${size}',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGridSize = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Grille aléatoire',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: randomStart,
                    onChanged: (value) {
                      setState(() {
                        randomStart = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text(
                      'Inverser les sommes',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: reverseSum,
                    onChanged: (value) {
                      setState(() {
                        reverseSum = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode de fusion',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  DropdownButton<String>(
                    value: selectedSumMode,
                    dropdownColor: Colors.grey[800],
                    items: ['Classique', 'Fusion Multiple', 'Double Fusion']
                        .map((mode) => DropdownMenuItem<String>(
                      value: mode,
                      child: Text(
                        mode,
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSumMode = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onSettingsChanged(
                    selectedGridSize,
                    selectedSumMode,
                    selectedGoalValue,
                    randomStart,
                    reverseSum,
                    selectedColorPalette,
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Enregistrer et Retourner'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
