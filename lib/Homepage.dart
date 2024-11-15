import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'ImportAll.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedMedia;
  final ImagePicker _picker = ImagePicker();
  String extractedText = "";

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
    }
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
      // Handle exceptions if necessary
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
      // Handle exceptions if necessary
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
        FutureBuilder<String?>(
          future: _extractText(selectedMedia!),
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
            return Text(
              snapshot.data!,
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

  // Future<String?> _extractText(File file) async {
  //   try {
  //     final String apiUrl =
  //         'https://app.nanonets.com/api/v2/OCR/Model/{model_id}/LabelFile/'; // Update with your model ID
  //     var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
  //
  //     request.headers['Authorization'] = 'Basic ' +
  //         base64Encode(utf8.encode(
  //             'YOUR_API_KEY:')); // Replace YOUR_API_KEY with your actual API key
  //
  //     request.files.add(await http.MultipartFile.fromPath('file', file.path));
  //
  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       var responseBody = await response.stream.bytesToString();
  //       var jsonResponse = json.decode(responseBody);
  //       String extractedText =
  //           jsonResponse['ocr_text']; // Adjust this key based on API response
  //       return extractedText;
  //     } else {
  //       return 'Error: Failed to fetch OCR data';
  //     }
  //   } catch (e) {
  //     return 'Error: Failed to extract text';
  //   }
  // }

  // Future<String?> extractTextFromImage(File file) async {
  //   final String apiKey = 'e4aaceda-860b-11ef-9931-96a6f528b3cb'; // Replace with your API key
  //   final String url = 'https://app.nanonets.com/api/v2/OCR/FullText';
  //
  //   var request = http.MultipartRequest('POST', Uri.parse(url));
  //   request.headers.addAll(
  //       {'Authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:'))});
  //
  //   // Add the image file to the request
  //   request.files.add(await http.MultipartFile.fromPath('file', file.path,
  //       contentType: MediaType('application', 'pdf')));
  //
  //   var response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     var responseData = await http.Response.fromStream(response);
  //     var data = json.decode(responseData.body);
  //     return data['results']?[0]['text']; // Adjust based on response structure
  //   } else {
  //     print('Error: ${response.statusCode}');
  //     return null;
  //   }
  // }
  Future<String?> extractTextFromImage(File file) async {
    final String apiKey = 'e4aaceda-860b-11ef-9931-96a6f528b3cb'; // Replace with your API key
    final String url = 'https://app.nanonets.com/api/v2/OCR/FullText';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(
        {'Authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:'))});

    // Ensure you're using the correct content type for the image
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = json.decode(responseData.body);
      return data['results']?[0]['text']; // Adjust based on response structure
    } else {
      var responseData = await http.Response.fromStream(response);
      print(
          'Error: ${response.statusCode} - ${responseData.body}'); // Log error details
      return null;
    }
  }

  Future<String?> _extractText(File file) async {
    try {
      return await extractTextFromImage(file);
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
