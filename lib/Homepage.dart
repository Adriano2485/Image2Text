import 'dart:math';
import 'ImportAll.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedMedia;
  final ImagePicker _picker = ImagePicker();
  String extractedText = "";
  List<wordpoint> wordpoints = [];

  void initState() {
    super.initState();
    getLostData();
  }

  Future<void> getLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      File? croppedFile = await _cropImage(File(response.file!.path));
      if (croppedFile != null) {
        setState(() {
          selectedMedia = croppedFile;
        });
        final text = await _extractText(croppedFile);
        setState(() {
          extractedText = text ?? "";
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPicker(context);
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
        shape: CircleBorder(),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Picture'),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        File? croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null) {
          setState(() {
            selectedMedia = croppedFile;
          });
          final text = await _extractText(croppedFile);
          setState(() {
            extractedText = text ?? "";
          });
        }
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPresetCustom(),
            ],
          ),
        ],
      );
      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } on Exception catch (e) {
      // TODO
    }
  }

  Widget _buildUI() {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF757F9A),
            Color(0xFFD7DDE8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Text Recognizer',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playwrite',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Captured Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playwrite',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                _imageView(),
                SizedBox(height: 30),
                Text(
                  'Extracted Text',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playwrite',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                _extractTextView(),
                SizedBox(height: 30),
                Text(
                  'Word corner points',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Playwrite',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                _buildWordPointList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageView() {
    if (selectedMedia == null) {
      return const Center(
        child: Text("Pick an image for text recognition."),
      );
    }
    return Center(
      child: Image.file(
        selectedMedia!,
        width: (MediaQuery.sizeOf(context).width * 2) / 3,
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...wordPoints.map((point) {
                    return Text(
                      '${point.word}: TL=${point.cornerPoints[0]},  TR=${point.cornerPoints[1]}, BR=${point.cornerPoints[2]}, BL=${point.cornerPoints[3]}\n\n',
                      style: TextStyle(fontSize: 17),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ]);
  }

  Future<String?> _extractText(File file) async {
    try {
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final InputImage inputImage = InputImage.fromFile(file);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      String text = recognizedText.text;
      textRecognizer.close();
      return text;
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<List<dynamic>?> _extractPoint(File file) async {
    try {
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
              allword.add(wordpoint(current, cornerPoints));
            }
          }
        }
      }
      textRecognizer.close();
      list.add(text);
      list.add(allword);

      find_difference(allword);
      return list;
    } on Exception catch (e) {
      // TODO
    }
  }

  void find_difference(List<wordpoint> wordpoints) {
    int  mx_y = 0;
    for (wordpoint word in wordpoints) {
      for (wordpoint anotherword in wordpoints) {
        int toplefty =
            (word.cornerPoints[0].y - anotherword.cornerPoints[0].y).abs();
        mx_y = max(mx_y, toplefty);
      }
    }
    print('max_y: $mx_y');
  }
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
