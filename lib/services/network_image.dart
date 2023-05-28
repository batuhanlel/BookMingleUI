import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class CustomNetWorkImage extends StatefulWidget {
  final String imageUrl;
  const CustomNetWorkImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<CustomNetWorkImage> createState() => _CustomNetWorkImageState();
}

class _CustomNetWorkImageState extends State<CustomNetWorkImage> {
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = fetchImage();
  }

  Future<Uint8List> fetchImage() async {
    final response = await http.get(
      Uri.parse(widget.imageUrl),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36',
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          );
        }
      },
    );
  }
}