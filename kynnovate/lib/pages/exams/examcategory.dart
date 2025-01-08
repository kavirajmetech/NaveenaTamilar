import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';

class ExamCategory extends StatefulWidget {
  final String category;

  ExamCategory({required this.category});

  @override
  State<ExamCategory> createState() => _ExamCategoryState();
}

class _ExamCategoryState extends State<ExamCategory> {
  late String formattedDate;
  late String formattedDay;
  late String formattedMonth;
  String? _localPdfPath;
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    final previousDay = DateTime.now().subtract(Duration(days: 3));
    formattedDate = DateFormat('dd-MM-yyyy').format(previousDay);
    formattedDay = DateFormat('dd').format(previousDay);
    formattedMonth = DateFormat('MMMM').format(previousDay);
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      bool pdfFound = false;
      print((widget.category == 'CA'
              ? "https://www.nextias.com/ca/current-affairs/$formattedDay-01-2025"
              : 'https://www.nextias.com/ca/headlines-of-the-day/$formattedDay-01-2025/headlines-of-the-day-$formattedDay-1-2025') +
          widget.category);

      final response = await http.get(Uri.parse(widget.category == 'CA'
          ? "https://www.nextias.com/ca/current-affairs/$formattedDay-01-2025"
          : 'https://www.nextias.com/ca/headlines-of-the-day/$formattedDay-01-2025/headlines-of-the-day-$formattedDay-1-2025'));

      if (response.statusCode == 200) {
        final document = html.parse(response.body);
        dom.Element? downloadButton = document.querySelector(
            widget.category == 'CA'
                ? "a.btn-outline-light"
                : 'a.wp-block-button__link.wp-element-button');
        if (downloadButton != null) {
          String? pdfUrl = downloadButton.attributes['href'];
          if (pdfUrl != null) {
            print('PDF URL: $pdfUrl');

            final pdfResponse = await http.get(Uri.parse(pdfUrl));
            if (pdfResponse.statusCode == 200) {
              final directory = await getTemporaryDirectory();
              final pdfFile = File('${directory.path}/temp.pdf');
              await pdfFile.writeAsBytes(pdfResponse.bodyBytes);

              setState(() {
                _localPdfPath = pdfFile.path;
              });

              print('PDF downloaded successfully: ${pdfFile.path}');
              pdfFound = true;
            } else {
              print('Failed to download PDF from $pdfUrl');
            }
          }
        }
      } else {
        print('Failed to load page with format:');
      }

      if (!pdfFound) {
        throw Exception('No valid PDF found.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category} Questions",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 179, 152, 225),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 152, 122, 204),
              const Color.fromARGB(255, 238, 154, 182)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _localPdfPath == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : PDFView(
                filePath: _localPdfPath!,
              ),
      ),
    );
  }
}
