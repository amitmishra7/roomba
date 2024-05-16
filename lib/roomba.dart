import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Roomba extends StatefulWidget {
  const Roomba({super.key});

  @override
  State<Roomba> createState() => _RoombaState();
}

class _RoombaState extends State<Roomba> {
  var dirty = [];
  var origin = 56;
  var current = 56;
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

    Set<int> uniqueNumbers = Set<int>();
    Random random = Random();

    while (uniqueNumbers.length < count) {
      var uniqueNo = min + random.nextInt(max - min + 1);
      uniqueNumbers.add(uniqueNo);
      dirty.add(uniqueNo);
    }
  }

  makePaths() {
    if (dirty.isEmpty && !isLast) {
      dirty.add(origin);
      isLast = true;
    }
    for (int i = 0; i < dirty.length; i++) {
      var tempPath = <int>[];
      tempPath.add(current);
      var element = dirty[i];
      var diff;

      if (element < current) {
        //move up or left
        diff = current - element;
        var q = diff ~/ 8;
        var r = diff % 8;
        if (q > 0) {
          for (int i = 0; i < q; i++) {
            tempPath.add(tempPath.last - 8);
          }
          checkIfSameLineOrMoveUp(r, element, tempPath);
        } else {
          checkIfSameLineOrMoveUp(r, element, tempPath);
        }
      } else {
        //move down or right
        diff = element - current;
        var q = diff ~/ 8;
        var r = diff % 8;
        if (q > 0) {
          for (int i = 0; i < q; i++) {
            tempPath.add(tempPath.last + 8);
          }
          checkIfSameLineOrMoveDown(r, element, tempPath);
        } else {
          // check if number is in same line or next line
          checkIfSameLineOrMoveDown(r, element, tempPath);
        }
      }
      route[dirty[i]] = tempPath;
    }
    var distance = route[route.keys.first]!.length;
    var number = route.keys.first;
    route.forEach((key, value) {
      if (value.isEmpty || value.length < distance) {
        distance = value.length;
        number = key;
      }
    });
    var array = route[number];
    var initialBattery = battery;
    if (distance == 0) {
      path.add(number);
      current = number;
      logs.add('Clean $number directly');
    } else {
      for (int i = 0; i < distance; i++) {
        path.add(array![i]);
        current = array[i];
        if (i > 0) {
          battery = battery - 10;
          score = score - 1;
        }
      }
      logs.add(
          'Clean $number using path $array with initial battery $initialBattery and current battery $battery with ${distance - 1} steps');
    }
    route.remove(number);
    dirty.remove(number);
    if (!isLast) {
      score = score + 10;
    }
    setState(() {});
  }

  void checkIfSameLineOrMoveUp(int r, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var array = [];
    int q = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      array.add((q * 8) + i);
    }
    if (array.contains(element)) {
      // move on same line
      if (r > 0) {
        for (int i = 0; i < r; i++) {
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

  void checkIfSameLineOrMoveDown(int r, int element, List<int> tempPath) {
    // check if number is in same line or previous line
    var array = [];
    int q = tempPath.last ~/ 8;
    for (int i = 0; i < 8; i++) {
      array.add((q * 8) + i);
    }
    if (array.contains(element)) {
      // move on same line
      if (r > 0) {
        for (int i = 0; i < r; i++) {
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
                    buildDetails('CURRENT', current, Colors.lightBlueAccent),
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
      dirty.clear();
      origin = 56;
      current = 56;
      battery = 1000;
      score = 0;
      logs.clear();
      path.clear();
      route = {};
      isLast = false;
      generateUniqueRandomNumbers(0, 64, 18);
      dirty.sort();
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
                : dirty.contains(index)
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (index == current)
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
          title: Text('Game Over'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your score is $score and battery is $battery.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
