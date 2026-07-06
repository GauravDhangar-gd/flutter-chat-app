import 'package:flutter/material.dart';

import '../screens/image_view_screen.dart';

class ImageMessage extends StatelessWidget {
  final String imageUrl;

  const ImageMessage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewScreen(
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 220,
            fit: BoxFit.cover,
            loadingBuilder:
                (context, child, progress) {
              if (progress == null) return child;

              return SizedBox(
                width: 220,
                height: 220,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
            errorBuilder:
                (context, error, stackTrace) {
              return Container(
                width: 220,
                height: 220,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}