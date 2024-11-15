// import 'dart:math';
// import 'ImportAll.dart';
//
// class OcrDocScanner extends StatefulWidget {
//   const OcrDocScanner({super.key});
//
//   @override
//   State<OcrDocScanner> createState() => _OcrDocScannerState();
// }
//
// class _OcrDocScannerState extends State<OcrDocScanner> {
//   File? selectedMedia;
//   String extractedText = "";
//   List<wordpoint> wordpoints = [];
//   Map<int, List<String>> pointwiseWord = {};
//
//   DocumentScanner? _documentScanner;
//   DocumentScanningResult? _result;
//
//   void dispose() {
//     _documentScanner?.close();
//     super.dispose();
//   }
//
//   void startScan(DocumentFormat format) async {
//     try {
//       _result = null;
//       setState(() {});
//       _documentScanner?.close();
//       _documentScanner = DocumentScanner(
//         options: DocumentScannerOptions(
//           documentFormat: format,
//           mode: ScannerMode.full,
//           isGalleryImport: true,
//           pageLimit: 1,
//         ),
//       );
//       _result = await _documentScanner?.scanDocument();
//       print('result: $_result');
//       setState(() {
//         selectedMedia = File(_result!.images.first);
//       });
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Scanner'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.image,
//                       size: 50,
//                     ),
//                     SizedBox(width: 8),
//                     ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor:
//                             WidgetStateProperty.all<Color>(Colors.black),
//                         shape: WidgetStateProperty.all(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       onPressed: () => startScan(DocumentFormat.jpeg),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         child: const Text(
//                           'Scan Image',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_result?.images.isNotEmpty == true) ...[
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         top: 16, bottom: 8, right: 8, left: 8),
//                     child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text('Scanned Image:')),
//                   ),
//                   SizedBox(
//                       height: 400,
//                       child: Image.file(File(_result!.images.first))),
//                   Text('Extracted Text'),
//                   SizedBox(height: 10),
//                   _extractTextView(),
//                   SizedBox(height: 30),
//                   Text('Word corner points'),
//                   SizedBox(height: 10),
//                   _buildWordPointList(),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _extractTextView() {
//     if (selectedMedia == null) {
//       return const Center(
//         child: Text(""),
//       );
//     }
//     return Column(
//       children: [
//         FutureBuilder<List<dynamic>?>(
//           future: _extractPoint(selectedMedia!),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             }
//             if (!snapshot.hasData || snapshot.data == null) {
//               return const Text('No data found.');
//             }
//             String extractedText = snapshot.data![0] as String;
//             return Text(
//               extractedText,
//               style: const TextStyle(fontSize: 20),
//             );
//           },
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             Clipboard.setData(ClipboardData(text: extractedText));
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Text copied to clipboard!')),
//             );
//           },
//           child: const Text('Copy extracted text'),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWordPointList() {
//     if (selectedMedia == null) {
//       return const Center(
//         child: Text(""),
//       );
//     }
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FutureBuilder<List<dynamic>?>(
//             future: _extractPoint(selectedMedia!),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               }
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//               if (!snapshot.hasData || snapshot.data == null) {
//                 return const Text('No data found.');
//               }
//
//               List<wordpoint> wordPoints = snapshot.data![1] as List<wordpoint>;
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ...wordPoints.map((point) {
//                     return Text(
//                       '${point.word}: TL=${point.cornerPoints[0]},  TR=${point.cornerPoints[1]}, BR=${point.cornerPoints[2]}, BL=${point.cornerPoints[3]}\n\n',
//                       style: TextStyle(fontSize: 17),
//                     );
//                   }).toList(),
//                 ],
//               );
//             },
//           ),
//         ]);
//   }
//
//   Future<List<dynamic>?> _extractPoint(File file) async {
//     try {
//       // print("check: "+pointwiseWord[0]!.first);
//       pointwiseWord.clear();
//
//       List<dynamic> list = [];
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );
//       final InputImage inputImage = InputImage.fromFile(file);
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);
//       String text = recognizedText.text;
//
//       List<wordpoint> allword = [];
//
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           for (TextElement element in line.elements) {
//             final current = element.text;
//             final List<Point<int>> cornerPoints = element.cornerPoints;
//             if (cornerPoints.isNotEmpty) {
//               pointwiseWord.putIfAbsent(cornerPoints[0].y, () => []);
//               pointwiseWord[cornerPoints[0].y]!.add(current);
//
//               // pointwiseWord[cornerPoints[0].y]?.add(current);
//               allword.add(wordpoint(current, cornerPoints));
//             }
//           }
//         }
//       }
//       //
//       for (var entry in pointwiseWord.entries) {
//         print('Key: ${entry.key}, Value: ${entry.value}');
//       }
//
//       // print("check: " + pointwiseWord[0]!.first);
//
//       textRecognizer.close();
//       list.add(text);
//       list.add(allword);
//       return list;
//     } on Exception catch (e) {
//       // TODO
//     }
//   }
//
//   void linefind() {}
// }
//
// class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
//   @override
//   (int, int)? get data => (2, 3);
//
//   @override
//   String get name => '2x3 (customized)';
// }
//
// class wordpoint {
//   final String word;
//   final List<Point<int>> cornerPoints;
//
//   wordpoint(this.word, this.cornerPoints);
// }

// import 'dart:math';
// import 'ImportAll.dart';
//
// class OcrDocScanner extends StatefulWidget {
//   const OcrDocScanner({super.key});
//
//   @override
//   State<OcrDocScanner> createState() => _OcrDocScannerState();
// }
//
// class _OcrDocScannerState extends State<OcrDocScanner> {
//   File? selectedMedia;
//   String extractedText = "";
//   List<wordpoint> wordpoints = [];
//   Map<int, List<String>> pointwiseWord = {};
//
//   DocumentScanner? _documentScanner;
//   DocumentScanningResult? _result;
//
//   void dispose() {
//     _documentScanner?.close();
//     super.dispose();
//   }
//
//   void startScan(DocumentFormat format) async {
//     try {
//       _result = null;
//       setState(() {});
//       _documentScanner?.close();
//       _documentScanner = DocumentScanner(
//         options: DocumentScannerOptions(
//           documentFormat: format,
//           mode: ScannerMode.full,
//           isGalleryImport: true,
//           pageLimit: 1,
//         ),
//       );
//       _result = await _documentScanner?.scanDocument();
//       print('result: $_result');
//       setState(() {
//         selectedMedia = File(_result!.images.first);
//       });
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Scanner'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.image,
//                       size: 50,
//                     ),
//                     SizedBox(width: 8),
//                     ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor:
//                             WidgetStateProperty.all<Color>(Colors.black),
//                         shape: WidgetStateProperty.all(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                       onPressed: () => startScan(DocumentFormat.jpeg),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                         child: const Text(
//                           'Scan Image',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_result?.images.isNotEmpty == true) ...[
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         top: 16, bottom: 8, right: 8, left: 8),
//                     child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text('Scanned Image:')),
//                   ),
//                   SizedBox(
//                       height: 400,
//                       child: Image.file(File(_result!.images.first))),
//                   Text('Extracted Text'),
//                   SizedBox(height: 10),
//                   _extractTextView(),
//                   SizedBox(height: 30),
//                   Text('Word corner points'),
//                   SizedBox(height: 10),
//                   _buildWordPointList(),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _extractTextView() {
//     if (selectedMedia == null) {
//       return const Center(
//         child: Text(""),
//       );
//     }
//     return Column(
//       children: [
//         FutureBuilder<List<dynamic>?>(
//           future: _extractPoint(selectedMedia!),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const CircularProgressIndicator();
//             }
//
//             if (snapshot.hasError) {
//               return Text('Error: ${snapshot.error}');
//             }
//             if (!snapshot.hasData || snapshot.data == null) {
//               return const Text('No data found.');
//             }
//             String extractedText = snapshot.data![0] as String;
//             return Text(
//               extractedText,
//               style: const TextStyle(fontSize: 20),
//             );
//           },
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             Clipboard.setData(ClipboardData(text: extractedText));
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Text copied to clipboard!')),
//             );
//           },
//           child: const Text('Copy extracted text'),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWordPointList() {
//     if (selectedMedia == null) {
//       return const Center(
//         child: Text(""),
//       );
//     }
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           FutureBuilder<List<dynamic>?>(
//             future: _extractPoint(selectedMedia!),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               }
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               }
//               if (!snapshot.hasData || snapshot.data == null) {
//                 return const Text('No data found.');
//               }
//
//               List<wordpoint> wordPoints = snapshot.data![1] as List<wordpoint>;
//
//               // Group words by their top-left corner Y coordinate
//               Map<int, List<String>> groupedWords = {};
//               for (var point in wordPoints) {
//                 int yCoordinate = point.cornerPoints[0].y;
//                 if (!groupedWords.containsKey(yCoordinate)) {
//                   groupedWords[yCoordinate] = [];
//                 }
//                 groupedWords[yCoordinate]!.add(point.word);
//               }
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ...groupedWords.entries.map((entry) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Y=${entry.key}: ${entry.value.join(", ")}',
//                           style: TextStyle(fontSize: 17),
//                         ),
//                         const SizedBox(height: 10),
//                       ],
//                     );
//                   }).toList(),
//                 ],
//               );
//             },
//           ),
//         ]);
//   }
//
//   Future<List<dynamic>?> _extractPoint(File file) async {
//     try {
//       pointwiseWord.clear();
//
//       List<dynamic> list = [];
//       final textRecognizer = TextRecognizer(
//         script: TextRecognitionScript.latin,
//       );
//       final InputImage inputImage = InputImage.fromFile(file);
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);
//       String text = recognizedText.text;
//
//       List<wordpoint> allword = [];
//
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           for (TextElement element in line.elements) {
//             final current = element.text;
//             final List<Point<int>> cornerPoints = element.cornerPoints;
//             if (cornerPoints.isNotEmpty) {
//               pointwiseWord.putIfAbsent(cornerPoints[0].y, () => []);
//               pointwiseWord[cornerPoints[0].y]!.add(current);
//
//               allword.add(wordpoint(current, cornerPoints));
//             }
//           }
//         }
//       }
//
//       textRecognizer.close();
//       list.add(text);
//       list.add(allword);
//       return list;
//     } on Exception catch (e) {
//       // Handle exception
//     }
//   }
//
//   void linefind() {}
// }
//
// class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
//   @override
//   (int, int)? get data => (2, 3);
//
//   @override
//   String get name => '2x3 (customized)';
// }
//
// class wordpoint {
//   final String word;
//   final List<Point<int>> cornerPoints;
//
//   wordpoint(this.word, this.cornerPoints);
// }


import 'dart:math';
import 'ImportAll.dart';

class OcrDocScanner extends StatefulWidget {
  const OcrDocScanner({super.key});

  @override
  State<OcrDocScanner> createState() => _OcrDocScannerState();
}

class _OcrDocScannerState extends State<OcrDocScanner> {
  File? selectedMedia;
  String extractedText = "";
  List<wordpoint> wordpoints = [];
  Map<int, List<String>> pointwiseWord = {};

  DocumentScanner? _documentScanner;
  DocumentScanningResult? _result;

  void dispose() {
    _documentScanner?.close();
    super.dispose();
  }

  void startScan(DocumentFormat format) async {
    try {
      _result = null;
      setState(() {});
      _documentScanner?.close();
      _documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: format,
          mode: ScannerMode.full,
          isGalleryImport: true,
          pageLimit: 1,
        ),
      );
      _result = await _documentScanner?.scanDocument();
      print('result: $_result');
      setState(() {
        selectedMedia = File(_result!.images.first);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Scanner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 50,
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.black),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      onPressed: () => startScan(DocumentFormat.jpeg),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Text(
                          'Scan Image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_result?.images.isNotEmpty == true) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16, bottom: 8, right: 8, left: 8),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Scanned Image:')),
                  ),
                  SizedBox(
                      height: 400,
                      child: Image.file(File(_result!.images.first))),
                  Text('Extracted Text'),
                  SizedBox(height: 10),
                  _extractTextView(),
                  SizedBox(height: 30),
                  Text('Word corner points'),
                  SizedBox(height: 10),
                  _buildWordPointList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _extractTextView() {
    if (selectedMedia == null) {
      return const Center(
        child: Text(""),
      );
    }
    return Column(
      children: [
        FutureBuilder<List<dynamic>?>(
          future: _extractPoint(selectedMedia!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No data found.');
            }
            String extractedText = snapshot.data![0] as String;
            return Text(
              extractedText,
              style: const TextStyle(fontSize: 20),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: extractedText));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Text copied to clipboard!')),
            );
          },
          child: const Text('Copy extracted text'),
        ),
      ],
    );
  }

  Widget _buildWordPointList() {
    if (selectedMedia == null) {
      return const Center(
        child: Text(""),
      );
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<List<dynamic>?>(
            future: _extractPoint(selectedMedia!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return const Text('No data found.');
              }

              List<wordpoint> wordPoints = snapshot.data![1] as List<wordpoint>;

              // Group words by their top-left corner Y coordinate with a tolerance of ±3
              Map<int, List<String>> groupedWords = {};
              for (var point in wordPoints) {
                int yCoordinate = point.cornerPoints[0].y;

                // Find the correct group for this Y coordinate within the tolerance
                int foundKey = -1;
                for (var key in groupedWords.keys) {
                  if ((yCoordinate >= key - 6) && (yCoordinate <= key + 6)) {
                    foundKey = key;
                    break;
                  }
                }

                // If a matching key was found, add the word to that group
                if (foundKey != -1) {
                  groupedWords[foundKey]!.add(point.word);
                } else {
                  // Otherwise, create a new group
                  groupedWords[yCoordinate] = [point.word];
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...groupedWords.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Y=${entry.key}: ${entry.value.join(", ")}',
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ]);
  }

  Future<List<dynamic>?> _extractPoint(File file) async {
    try {
      pointwiseWord.clear();

      List<dynamic> list = [];
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final InputImage inputImage = InputImage.fromFile(file);
      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);
      String text = recognizedText.text;

      List<wordpoint> allword = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            final current = element.text;
            final List<Point<int>> cornerPoints = element.cornerPoints;
            if (cornerPoints.isNotEmpty) {
              pointwiseWord.putIfAbsent(cornerPoints[0].y, () => []);
              pointwiseWord[cornerPoints[0].y]!.add(current);

              allword.add(wordpoint(current, cornerPoints));
            }
          }
        }
      }

      textRecognizer.close();
      list.add(text);
      list.add(allword);
      return list;
    } on Exception catch (e) {
      // Handle exception
    }
  }

  void linefind() {}
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class wordpoint {
  final String word;
  final List<Point<int>> cornerPoints;

  wordpoint(this.word, this.cornerPoints);
}