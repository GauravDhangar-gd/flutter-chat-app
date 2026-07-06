import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/firestore_service.dart';
import 'dart:io';
import 'dart:async';
import '../services/media_service.dart';
import '../widgets/image_message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/audio_message.dart';
import 'search_screen.dart';
import '../services/wallpaper_service.dart';
import 'forward_screen.dart';
import '../widgets/video_message.dart';
import '../services/call_service.dart';
import 'video_call_screen.dart';
import 'calling_screen.dart';
import 'voice_call_screen.dart';



class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({
    super.key,
    required this.user,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isUploadingImage = false;
  bool showEmoji = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  MessageModel? replyingMessage;  
  String? highlightedMessageId;
  final GlobalKey listKey = GlobalKey();
  final FocusNode focusNode = FocusNode();
  String? recordedPath;
  Duration recordingDuration = Duration.zero;
  Timer? recordingTimer;
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  bool isRecording = false;
  String? audioPath;

  final ChatService chatService = ChatService();

  final FirestoreService firestoreService = FirestoreService();

  final ImageService imageService = ImageService();

  final WallpaperService wallpaperService = WallpaperService();

  String? wallpaperPath;

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final currentUser =
      FirebaseAuth.instance.currentUser!;

  void toggleEmojiKeyboard() {
  if (showEmoji) {
    focusNode.requestFocus();
  } else {
    focusNode.unfocus();
  }

  setState(() {
    showEmoji = !showEmoji;
  });
}

void highlightMessage(String id) {
  setState(() {
    highlightedMessageId = id;
  });

  Future.delayed(
    const Duration(seconds: 2),
    () {
      if (!mounted) return;

      setState(() {
        highlightedMessageId = null;
      });
    },
  );
}

Future<void> pickVideo() async {
  final video =
      await imageService.pickVideoFromGallery();

  if (video == null) return;

  setState(() {
    isUploadingImage = true;
  });

  final url =
      await imageService.uploadVideo(video);

  setState(() {
    isUploadingImage = false;
  });

  if (url == null) return;

  await chatService.sendVideo(
    widget.user.uid,
    url,
  );
}

Future<void> sendMessage() async {
  String text = messageController.text.trim();

  if (text.isEmpty) return;

  await chatService.sendMessage(
    widget.user.uid,
    text,
    replyMessage: replyingMessage?.message ?? "",
    replySender: replyingMessage?.senderId ?? "",
    isReply: replyingMessage != null,
  );

  messageController.clear();

  setState(() {
    replyingMessage = null;
  });

  Future.delayed(
    const Duration(milliseconds: 200),
    () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    },
  );
}

  Future<void> loadWallpaper() async {
    wallpaperPath =
        await wallpaperService.getWallpaper();

    if (mounted) {
      setState(() {});
    }
  }

  void onTyping(String value) async {
    if (value.isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;

        await chatService.setTypingStatus(
          widget.user.uid,
          true,
        );
      }

      _typingTimer?.cancel();

      _typingTimer = Timer(
        const Duration(seconds: 2),
        () async {
          _isTyping = false;

          await chatService.setTypingStatus(
            widget.user.uid,
            false,
          );
        },
      );
    } else {
      _typingTimer?.cancel();

      _isTyping = false;

      await chatService.setTypingStatus(
        widget.user.uid,
        false,
      );
    }
  }

  Widget reactionButton(String emoji) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, emoji);
      },
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
Future<void> changeWallpaper() async {
  final image = await imageService.pickFromGallery();

  if (image == null) return;

  await wallpaperService.saveWallpaper(image.path);

  setState(() {
    wallpaperPath = image.path;
  });
}

  Future<void> pickGalleryImage() async {
    File? image = await imageService.pickFromGallery();

    if (image == null) return;

    await uploadAndSend(image);
  }

  Future<void> pickCameraImage() async {
    File? image = await imageService.pickFromCamera();

    if (image == null) return;

    await uploadAndSend(image);
  }

  Future<void> uploadAndSend(File image) async {
    setState(() {
      isUploadingImage = true;
    });

    final imageUrl =
        await imageService.uploadImage(image);

    setState(() {
      isUploadingImage = false;
    });

    if (imageUrl == null) return;

    await chatService.sendImage(
      widget.user.uid,
      imageUrl,
    );
  }

  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();

      recordedPath =
          "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a";

      await recorder.start(
        const RecordConfig(),
        path: recordedPath!,
      );

      setState(() {
        isRecording = true;
        recordingDuration = Duration.zero;
      });

      recordingTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          setState(() {
            recordingDuration += const Duration(seconds: 1);
          });
        },
      );
    }
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();

    setState(() {
      isRecording = false;
    });

    if (path == null) return;

    final url = await imageService.uploadAudio(
      File(path),
    );

    if (url == null) return;

    await chatService.sendVoiceMessage(
      widget.user.uid,
      url,
    );
  }

  @override
  void initState() {
    super.initState();
    loadWallpaper();

    chatService.markMessagesAsRead(
      widget.user.uid,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 1,
        title: StreamBuilder<UserModel>(
          stream: firestoreService.getUser(widget.user.uid),
          builder: (context, snapshot) {
            UserModel user =
                snapshot.data ?? widget.user;

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                  
                      StreamBuilder<bool>(
                        stream: chatService.getTypingStatus(
                          widget.user.uid,
                        ),
                        builder: (context, typingSnapshot) {
                          final typing =
                              typingSnapshot.data ?? false;
                  
                          return Text(
                            typing
                                ? "typing..."
                                : user.isOnline
                                    ? "🟢 Online"
                                    : user.lastSeen == null
                                        ? "Offline"
                                        : "Last seen ${DateFormat('dd MMM, hh:mm a').format(user.lastSeen!)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: () async {
            final channel =
                "${currentUser.uid}_${widget.user.uid}_voice";

            await CallService().startCall(
              callerId: currentUser.uid,
              receiverId: widget.user.uid,
              channelName: channel,
              isVideo: false,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoiceCallScreen(
                  channelName: channel,
                  receiverId: widget.user.uid,
                ),
              ),
            );
          },
        ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () async {
              final channel =
                  "${currentUser.uid}_${widget.user.uid}";

              await CallService().startCall(
                callerId: currentUser.uid,
                receiverId: widget.user.uid,
                channelName: channel,
                isVideo: true,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallingScreen(
                    callerId: currentUser.uid,
                    receiverId: widget.user.uid,
                    channelName: channel,
                  ),
                ),
              );
            },
          ),


          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "search") {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(
                      user: widget.user,
                    ),
                  ),
                );

                if (result != null && result is MessageModel) {

                  final stream = await chatService
                      .getMessages(widget.user.uid)
                      .first;

                  final index = stream.indexWhere(
                    (m) => m.id == result.id,
                  );

                  if (index != -1) {

                    scrollController.animateTo(
                      index * 100,
                      duration: const Duration(
                        milliseconds: 500,
                      ),
                      curve: Curves.easeInOut,
                    );

                    highlightMessage(result.id);
                  }
                }
              }
              if (value == "wallpaper") {
                await changeWallpaper();
              }

              if (value == "remove_wallpaper") {
                await wallpaperService.removeWallpaper();

                setState(() {
                  wallpaperPath = null;
                });
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "search",
                child: Text("Search"),
              ),
              PopupMenuItem(
                value: "wallpaper",
                child: Text("Change Wallpaper"),
              ),
              PopupMenuItem(
                value: "remove_wallpaper",
                child: Text("Remove Wallpaper"),
              ),
            ],
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          image: wallpaperPath != null
              ? DecorationImage(
                  image: FileImage(File(wallpaperPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Column(
          children: [
              if (isUploadingImage)
                const LinearProgressIndicator(),

          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatService.getMessages(
                widget.user.uid,
              ),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child:
                        Text("Say Hi 👋"),
                  );
                }

                List<MessageModel> messages =
                    snapshot.data!;

                WidgetsBinding.instance
                    .addPostFrameCallback((_) {
                  if (scrollController
                      .hasClients) {
                    scrollController.animateTo(
                      scrollController
                          .position
                          .maxScrollExtent,
                      duration:
                          const Duration(
                              milliseconds:
                                  300),
                      curve:
                          Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller:
                      scrollController,
                  itemCount:
                      messages.length,
                  itemBuilder:
                      (context, index) {
                    MessageModel message =
                        messages[index];

                    bool isMe =
                        message.senderId ==
                            currentUser.uid;

                    return GestureDetector(
                      onLongPress: () async {
                        final action = await showModalBottomSheet<String>(
                          context: context,
                          builder: (_) {
                            return SafeArea(
                              child: Wrap(
                                children: [

                                  // Reaction Row
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [

                                        reactionButton("❤️"),

                                        reactionButton("😂"),

                                        reactionButton("👍"),

                                        reactionButton("😮"),

                                        reactionButton("😢"),

                                      ],
                                    ),
                                  ),

                                  const Divider(),

                                  ListTile(
                                    leading: const Icon(Icons.reply),
                                    title: const Text("Reply"),
                                    onTap: () {
                                      Navigator.pop(context, "reply");
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.forward),
                                    title: const Text("Forward"),
                                    onTap: () {
                                      Navigator.pop(context, "forward");
                                    },
                                  ),
                                ListTile(
                                  leading: const Icon(Icons.emoji_emotions),
                                  title: const Text("React"),
                                  onTap: () {
                                    Navigator.pop(context, "react");
                                  },
                                ),

                                  ListTile(
                                    leading: const Icon(Icons.delete_outline),
                                    title: const Text("Delete for Me"),
                                    onTap: () {
                                      Navigator.pop(context, "delete_me");
                                    },
                                  ),

                                  if (message.senderId == currentUser.uid)
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text(
                                        "Delete for Everyone",
                                      ),
                                      onTap: () {
                                        Navigator.pop(
                                          context,
                                          "delete_everyone",
                                        );
                                      },
                                    ),

                                  ListTile(
                                    leading: const Icon(Icons.close),
                                    title: const Text("Cancel"),
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        switch (action) {
                          case "❤️":
                          case "😂":
                          case "👍":
                          case "😮":
                          case "😢":
                            await chatService.reactToMessage(
                              widget.user.uid,
                              message.id,
                              action!,
                            );
                            break;

                          case "reply":
                            setState(() {
                              replyingMessage = message;
                            });
                            break;

                            case "forward":
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForwardScreen(
                                    message: message,
                                  ),
                                ),
                              );
                              break;

                          case "delete_me":
                            await chatService.deleteForMe(
                              widget.user.uid,
                              message.id,
                            );
                            break;

                          case "delete_everyone":
                            await chatService.deleteForEveryone(
                              widget.user.uid,
                              message.id,
                            );
                            break;
                        }
                      },
                    child: Align(
                      alignment: isMe
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets
                                .all(8),

                        padding:
                            const EdgeInsets
                                .all(12),

                        decoration:
                            BoxDecoration(
                              color: message.id == highlightedMessageId
                                  ? Colors.yellow.shade300
                                  : isMe
                                    ? Colors.green.withOpacity(0.90)
                                    : Colors.white.withOpacity(0.90),

                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft:
                                Radius.circular(isMe ? 18 : 0),
                            bottomRight:
                                Radius.circular(isMe ? 0 : 18),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (message.isForwarded)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.forward,
                                    size: 14,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Forwarded",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: isMe
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),

                            if (message.isForwarded)
                              const SizedBox(height: 6),
                                  message.deletedForEveryone
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.block,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "This message was deleted",
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        )

                                      : message.messageType == "image"

                                          ? ImageMessage(
                                              imageUrl: message.imageUrl,
                                            )

                                          : message.messageType == "audio"

                                              ? AudioMessage(
                                                  audioUrl: message.audioUrl,
                                                )


                                              : message.messageType == "video"

                                                  ? VideoMessage(
                                                      videoUrl: message.videoUrl,
                                                    )

                                                  : Text(
                                                      message.message,
                                                      style: TextStyle(
                                                        color: isMe
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16,
                                                      ),
                                                    ),

                            const SizedBox(height: 5),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                Text(
                                  DateFormat('hh:mm a')
                                      .format(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: message.messageType == "image"
                                        ? Colors.transparent
                                        : isMe
                                            ? const Color.fromARGB(255, 230, 236, 230)
                                            : const Color.fromARGB(255, 36, 34, 34),
                                  ),
                                ),

                                if (isMe)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      message.status == "read"
                                          ? Icons.done_all
                                          : Icons.done,
                                      size: 16,
                                      color: message.status == "read"
                                          ? Colors.blue
                                          : Colors.white70,
                                    ),
                                  ),
                              ],
                            ),
                            if (message.reaction.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      message.reaction,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  if (replyingMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.reply,
                            color: Colors.green,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replyingMessage!.senderId == currentUser.uid
                                      ? "Replying to yourself"
                                      : "Replying to ${widget.user.name}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  replyingMessage!.messageType == "image"
                                      ? "📷 Photo"
                                      : replyingMessage!.message,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                replyingMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: toggleEmojiKeyboard,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.videocam,
                        ),
                        onPressed: pickVideo,
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo),
                        onPressed: pickGalleryImage,
                      ),

                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: pickCameraImage,
                      ),

                      Expanded(
                        child: TextField(
                          controller: messageController,
                          focusNode: focusNode,
                          onChanged: onTyping,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMessage(),

                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 28,
                        child: messageController.text.trim().isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: sendMessage,
                              )
                            : GestureDetector(
                                onLongPressStart: (_) {
                                  startRecording();
                                },
                                onLongPressEnd: (_) {
                                  stopRecording();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    isRecording
                                        ? Icons.mic
                                        : Icons.mic_none,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showEmoji)
          SizedBox(
            height: 280,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                messageController.text += emoji.emoji;
              },
              config: const Config(
                height: 280,
                checkPlatformCompatibility: true,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
  @override
  void dispose() {
    _typingTimer?.cancel();

    chatService.setTypingStatus(
      widget.user.uid,
      false,
    );

    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();

    super.dispose();
  }
}