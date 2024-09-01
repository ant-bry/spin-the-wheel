import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_spin_the_wheel/model/fortune_item.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key, required this.title});
  final String title;

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage> {
  StreamController<int> selected = StreamController<int>();
  int selectedIndex = 0;
  FortuneItemModel? result;
  List<FortuneItemModel> items = [];
  bool isSpinning = false;

  @override
  void initState() {
    selected = StreamController<int>.broadcast();
    super.initState();
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: IgnorePointer(
        ignoring: isSpinning,
        child: SingleChildScrollView(
          child: Column(
            children: [
              items.length > 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width / 1,
                              child: Visibility(
                                child: GestureDetector(
                                  onTap: () {
                                    int randomInt =
                                        Random().nextInt(items.length);

                                    selected.addStream(
                                      Stream.value(randomInt),
                                    );
                                    setState(() {
                                      isSpinning = true;
                                    });
                                  },
                                  child: FortuneWheel(
                                    selected: selected.stream,
                                    items: items
                                        .map((e) => FortuneItem(
                                            child: Text(
                                              e.numericalValue.toString(),
                                            ),
                                            style: FortuneItemStyle(
                                              color: e.colorValue,
                                            )))
                                        .toList(),
                                    animateFirst: false,
                                    // rotationCount: rotationCount,
                                    onFling: () {
                                      int randomInt =
                                          Random().nextInt(items.length);
                                      selected.addStream(
                                        Stream.value(randomInt),
                                      );
                                    },
                                    onFocusItemChanged: (value) {
                                      selectedIndex = value;
                                    },
                                    onAnimationEnd: () {
                                      setState(() {
                                        result = items[selectedIndex];
                                        showSelectedItemDialog(
                                            context, items[selectedIndex]);
                                        setState(() {
                                          isSpinning = false;
                                        });
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Selected: '),
                                Icon(
                                  Icons.circle,
                                  color: result != null
                                      ? result!.colorValue
                                      : Colors.transparent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '${result != null ? result!.numericalValue : ''}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          Text(
                            'Please add at least 2 items.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: items[index].colorValue,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: items[index].colorValue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                              '${items[index].numericalValue.toString()} '),
                                        ],
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (items[index] == result) {
                                              result = null;
                                            }
                                            items.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: IgnorePointer(
        ignoring: isSpinning,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                addItem(context);
              },
              tooltip: 'Add Item',
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  items.shuffle();
                });
              },
              tooltip: 'Shuffle',
              child: const Icon(Icons.shuffle),
            ),
          ],
        ),
      ),
    );
  }

  void addItem(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    int? numericalValue;
    Color? colorValue;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Form(
            key: formKey,
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Add Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        maxLength: 5,
                        decoration: const InputDecoration(
                          label: Text('Enter numerical value'),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          numericalValue = int.tryParse(value);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter numerical value';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pick a color ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlockPicker(
                        pickerColor: colorValue ?? Colors.white,
                        onColorChanged: (color) {
                          colorValue = color;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: OutlinedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            if (colorValue == null) {
                              pickAColorValidationDialog(context);
                            }
                            if (formKey.currentState!.validate()) {
                              if (numericalValue != null &&
                                  colorValue != null) {
                                setState(() {
                                  // fortuneItems.add(FortuneItem(child: Text(text!)));
                                  items = [
                                    ...items,
                                    FortuneItemModel(
                                      numericalValue: numericalValue!,
                                      colorValue: colorValue!,
                                    ),
                                  ];
                                });

                                Navigator.pop(context);
                              }
                            }
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<dynamic> pickAColorValidationDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Oops! Please pick a color.',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> showSelectedItemDialog(
      BuildContext context, FortuneItemModel result) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Result'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              size: 36,
              color: result.colorValue,
            ),
            const SizedBox(width: 8),
            Text(
              '${result.numericalValue}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
