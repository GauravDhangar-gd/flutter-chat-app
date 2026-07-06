import 'package:flutter/material.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 5,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder:
                  (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) {
                return const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 80,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}