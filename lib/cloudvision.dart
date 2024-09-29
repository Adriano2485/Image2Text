// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'ImportAll.dart';

//
// class CloudVision extends StatefulWidget {
//   @override
//   _CloudVisionState createState() => _CloudVisionState();
// }
//
// class _CloudVisionState extends State<CloudVision> {
//   File? _image;
//   final picker = ImagePicker();
//   String _extractedText = '';
//   String YOUR_API_KEY='88af2e9b4a36417050f65cf4b93ffc464edd3533';
//
//   Future pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     setState(() {
//       if (pickedFile != null) {
//         _image = File(pickedFile.path);
//       } else {
//         print('No image selected.');
//       }
//     });
//   }
//
//   Future extractTextFromImage() async {
//     if (_image == null) return;
//
//     final bytes = _image!.readAsBytesSync();
//     String base64Image = base64Encode(bytes);
//
//     final apiUrl =
//         'https://vision.googleapis.com/v1/images:annotate?key=$YOUR_API_KEY';
//
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'requests': [
//           {
//             'image': {'content': base64Image},
//             'features': [
//               {'type': 'TEXT_DETECTION', 'maxResults': 1}
//             ]
//           }
//         ]
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       setState(() {
//         _extractedText = jsonResponse['responses'][0]['fullTextAnnotation']
//                 ['text'] ??
//             'No text found';
//       });
//     } else {
//       print('Error: ${response.body}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Text Recognition App'),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _image == null ? Text('No image selected.') : Image.file(_image!),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: pickImage,
//                 child: Text('Pick Image'),
//               ),
//               ElevatedButton(
//                 onPressed: extractTextFromImage,
//                 child: Text('Extract Text'),
//               ),
//               SizedBox(height: 20),
//               Text(_extractedText),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
// import 'package:image_picker/image_picker.dart';

// class EntityExtractionExample extends StatefulWidget {
//   @override
//   _EntityExtractionExampleState createState() =>
//       _EntityExtractionExampleState();
// }
//
// class _EntityExtractionExampleState extends State<EntityExtractionExample> {
//   final ImagePicker _picker = ImagePicker();
//   final TextRecognizer _textRecognizer = TextRecognizer();
//   final EntityExtractor _entityExtractor =
//       EntityExtractor(language: EntityExtractorLanguage.english);
//
//   String _recognizedText = '';
//   List<EntityAnnotation> _entities = [];
//
//   Future<void> _pickImageAndExtractEntities() async {
//     // Pick an image from the gallery
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image == null) return;
//
//     // Process the image to extract text
//     final inputImage = InputImage.fromFilePath(image.path);
//     final recognizedText = await _textRecognizer.processImage(inputImage);
//
//     setState(() {
//       _recognizedText = recognizedText.text;
//     });
//
//     // Extract entities from recognized text
//     final entities = await _entityExtractor.annotateText(_recognizedText);
//     setState(() {
//       _entities = entities;
//     });
//   }
//
//   @override
//   void dispose() {
//     _textRecognizer.close();
//     _entityExtractor.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Entity Extraction Example')),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: _pickImageAndExtractEntities,
//                 child: Text('Pick Image and Extract Entities'),
//               ),
//               SizedBox(height: 20),
//               Text('Recognized Text: $_recognizedText'),
//               SizedBox(height: 20),
//               Text('Extracted Entities:'),
//               for (var entity in _entities) Text(entity.text),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class EntityExtractionView extends StatefulWidget {
  @override
  State<EntityExtractionView> createState() => _EntityExtractionViewState();
}

class _EntityExtractionViewState extends State<EntityExtractionView> {
  final _controller = TextEditingController();
  final _modelManager = EntityExtractorModelManager();
  final _entityExtractor =
      EntityExtractor(language: EntityExtractorLanguage.english);
  var _entities = <EntityAnnotation>[];
  final _language = EntityExtractorLanguage.english;

  @override
  void dispose() {
    _entityExtractor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entity Extractor'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Center(child: Text('Enter text (English)')),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        border: Border.all(
                      width: 2,
                    )),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(border: InputBorder.none),
                      maxLines: null,
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton(
                      onPressed: _extractEntities,
                      child: Text('Extract Entities'))
                ]),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: _downloadModel,
                        child: Text('Download Model')),
                    ElevatedButton(
                        onPressed: _deleteModel, child: Text('Delete Model')),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: _isModelDownloaded,
                          child: Text('Check download'))
                    ]),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: const Text('Result', style: TextStyle(fontSize: 20)),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _entities.length,
                  itemBuilder: (context, index) => ExpansionTile(
                      title: Text(_entities[index].text),
                      children: _entities[index]
                          .entities
                          .map((e) => Text(e.toString()))
                          .toList()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadModel() async {
    Toast().show(
        'Downloading model...',
        _modelManager
            .downloadModel(_language.name)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _deleteModel() async {
    Toast().show(
        'Deleting model...',
        _modelManager
            .deleteModel(_language.name)
            .then((value) => value ? 'success' : 'failed'),
        context,
        this);
  }

  Future<void> _isModelDownloaded() async {
    Toast().show(
        'Checking if model is downloaded...',
        _modelManager
            .isModelDownloaded(_language.name)
            .then((value) => value ? 'downloaded' : 'not downloaded'),
        context,
        this);
  }

  Future<void> _extractEntities() async {
    FocusScope.of(context).unfocus();
    final result = await _entityExtractor.annotateText(_controller.text);
    setState(() {
      _entities = result;
    });
  }
}
