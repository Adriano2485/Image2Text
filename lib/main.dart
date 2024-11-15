import 'ImportAll.dart';
import 'OCR_Doc_Scanner.dart';

void main() {
  runApp(MyApp());
  // runApp(CloudVision());
  // runApp(EntityExtractionExample());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
      // home: OcrDocScanner(),
      // home: EntityExtractionExample(),
      // home: EntityExtractionView(),
      // home: DocumentScannerView(),
    );
  }
}
