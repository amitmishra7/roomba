import 'dart:math';

import 'package:flutter/material.dart';

class Roomba extends StatefulWidget {
  const Roomba({super.key});

  @override
  State<Roomba> createState() => _RoombaState();
}

class _RoombaState extends State<Roomba> {
  var dirtyTiles = [];
  var origin = 0;
  var currentIndex = 0;
  var battery = 1000;
  var score = 0;
  var logs = [];
  var path = [];
  Map<int, List<int>> route = {};
  bool isLast = false;

  @override
  void initState() {
    super.initState();
    reset();
  }

  generateUniqueRandomNumbers(int min, int max, int count) {
    if (count > max - min + 1) {
      throw ArgumentError("Count must be less than or equal to max - min + 1");
    }

    Set<int> uniqueNumbers = <int>{};
    Random random = Random();

    while (uniqueNumbers.length < count) {
      var uniqueNo = min + random.nextInt(max - min + 1);
      uniqueNumbers.add(uniqueNo);
      dirtyTiles.add(uniqueNo);
    }
  }

  makePaths() {
    if (dirtyTiles.isEmpty && !isLast) {
      dirtyTiles.add(origin);
      isLast = true;
    }
    for (int i = 0; i < dirtyTiles.length; i++) {
      var tempPath = <int>[];
      tempPath.add(currentIndex);
      var element = dirtyTiles[i];
      var difference;

      if (element < currentIndex) {
        //move up or left
        difference = currentIndex - element;
        var quotient = difference ~/ 8;
        var remainder = difference % 8;
        if (quotient > 0) {
          for (int i = 0; i < quotient; i++) {
            tempPath.add(tempPath.last - 8);
          }
          checkIfSameLineOrMoveUp(remainder, element, tempPath);
        } else {
          checkIfSameLineOrMoveUp(remainder, element, tempPath);
        }
      } else {
        //move down or right
        difference = element - currentIndex;
        var quotient = difference ~/ 8;
        var remainder = difference % 8;
        if (quotient > 0) {
          for (int i = 0; i < quotient; i++) {
            tempPath.add(tempPath.last + 8);
          }
          checkIfSameLineOrMoveDown(remainder, element, tempPath);
        } else {
          // check if index is in same line or next line
          checkIfSameLineOrMoveDown(remainder, element, tempPath);
        }
      }
      route[dirtyTiles[i]] = tempPath;
    }
    var distance = route[route.keys.first]!.length;
    var index = route.keys.first;
    route.forEach((key, value) {
      if (value.isEmpty || value.length < distance) {
        distance = value.length;
        index = key;
      }
    });
    var array = route[index];
    var initialBattery = battery;
    if (distance == 0) {
      path.add(index);
      currentIndex = index;
      logs.add('Clean $index directly');
    } else {
      for (int i = 0; i < distance; i++) {
        path.add(array![i]);
        currentIndex = array[i];
        if (i > 0) {
          battery = battery - 10;
          score = score - 1;
        }
      }
      logs.add(
          'Clean $index using path $array with initial battery $initialBattery and current battery $battery with ${distance - 1} steps');
    }
    route.remove(index);
    dirtyTiles.remove(index);
    if (!isLast) {
      score = score + 10;
    }
    setState(() {});
  }

  void checkIfSameLineOrMoveUp(int remainder, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var currentLine = [];
    int quotient = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      currentLine.add((quotient * 8) + i);
    }
    if (currentLine.contains(element)) {
      // move on same line
      if (remainder > 0) {
        for (int i = 0; i < remainder; i++) {
          tempPath.add(tempPath.last - 1);
        }
      }
    } else {
      // move up
      var tempElement = tempPath.last - 8;
      tempPath.add(tempElement);
      for (int i = 0; i < element - tempElement; i++) {
        tempPath.add(tempElement + i + 1);
      }
    }
  }

  void checkIfSameLineOrMoveDown(int remainder, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var currentLine = [];
    int quotient = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      currentLine.add((quotient * 8) + i);
    }
    if (currentLine.contains(element)) {
      // move on same line
      if (remainder > 0) {
        for (int i = 0; i < remainder; i++) {
          tempPath.add(tempPath.last + 1);
        }
      }
    } else {
      // move down
      var tempElement = tempPath.last + 8;
      tempPath.add(tempElement);
      for (int i = 0; i < tempElement - element; i++) {
        tempPath.add(tempElement - i - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        bool isMobile = constraints.maxWidth < 600;
        var width = isMobile ? constraints.maxWidth - 40 : constraints.maxHeight - 40 - 200;

        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildDetails('SCORE', score, Colors.greenAccent),
                    buildDetails('ORIGIN', origin, Colors.amber),
                    buildDetails('BATTERY', battery, Colors.redAccent),
                    buildDetails('CURRENT', currentIndex, Colors.lightBlueAccent),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (!isLast) {
                              makePaths();
                            } else {
                              gameOverPopup(context);
                            }
                          },
                          child: const Text('NEXT POSITION')),
                      if (logs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                reset();
                              },
                              child: const Text('RESET')),
                        ),
                    ],
                  ),
                ),
                if (!isMobile) buildWeb(width),
                if (isMobile) buildMobile(width),
              ],
            ),
          ),
        );
      },
    );
  }

  reset() {
    setState(() {
      dirtyTiles.clear();
      origin = 56;
      currentIndex = 56;
      battery = 1000;
      score = 0;
      logs.clear();
      path.clear();
      route = {};
      isLast = false;
      generateUniqueRandomNumbers(0, 64, 18);
      dirtyTiles.sort();
    });
  }

  buildWeb(width) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width,
            height: width,
            child: buildGrid(),
          ),
          Expanded(
            child: buildLogs(),
          ),
        ],
      ),
    );
  }

  buildMobile(width) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: width,
            height: width,
            child: buildGrid(),
          ),
          Expanded(
            child: buildLogs(),
          ),
        ],
      ),
    );
  }

  buildGrid() {
    return GridView.builder(
      itemCount: 64,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 8),
      padding: const EdgeInsets.all(8),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration: BoxDecoration(
            color: path.contains(index)
                ? Colors.greenAccent
                : dirtyTiles.contains(index)
                    ? Colors.yellow
                    : Colors.lightBlueAccent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '$index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (index == currentIndex)
                const Center(
                  child: Icon(
                    Icons.mouse,
                    color: Colors.white,
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  buildDetails(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '$value',
            style: TextStyle(fontSize: 24, color: color),
          ),
        ],
      ),
    );
  }

  buildLogs() {
    return ListView.separated(
        itemBuilder: (context, index) => Text(logs[index]),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: logs.length);
  }

  gameOverPopup(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your score is $score and battery is $battery.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                reset();
              },
            ),
          ],
        );
      },
    );
  }
}
