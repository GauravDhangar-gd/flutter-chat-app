import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
 State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final StorageService storageService = StorageService();
  final ImagePicker picker = ImagePicker();

  UserModel? user;

  bool loading = true;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await firestoreService.getCurrentUser();

    if (!mounted) return;

    setState(() {
      user = data;
      loading = false;
    });
  }

  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (file == null) return;
    
    setState(() {
      uploading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final imageUrl = await storageService.uploadProfileImage(
        File(file.path),
      );

      await firestoreService.updateProfilePhoto(
        uid:uid,
        photoUrl: imageUrl,
      );

      await loadUser();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    if (mounted) {
      setState(() {
        uploading = false;
      });
    }
    
  }
  Future<void> removePhoto() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await firestoreService.removeProfilePhoto(uid);

    await loadUser();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile photo removed"),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: uploading ? null : pickImage,
              child: Stack(
                
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.blue,
                    backgroundImage: user!.photoUrl.isNotEmpty
                        ? NetworkImage(user!.photoUrl)
                        : null,
                    child: user!.photoUrl.isEmpty
                        ? Text(
                            user!.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 42,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (uploading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color.fromARGB(120, 0, 0, 0),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: PopupMenuButton<String>(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                      onSelected: (value) {
                        if (value == "change") {
                          pickImage();
                        } else if (value == "remove") {
                          removePhoto();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "change",
                          child: Text("Change Photo"),
                        ),
                        if (user!.photoUrl.isNotEmpty)
                          const PopupMenuItem(
                            value: "remove",
                            child: Text("Remove Photo"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user!.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              user!.phoneNumber,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Name"),
                subtitle: Text(user!.name),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone Number"),
                subtitle: Text(user!.phoneNumber),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(
                  user!.isOnline
                      ? Icons.circle
                      : Icons.circle_outlined,
                  color:
                      user!.isOnline ? Colors.green : Colors.grey,
                ),
                title: const Text("Status"),
                subtitle: Text(
                  user!.isOnline
                      ? "Online"
                      : "Offline",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}