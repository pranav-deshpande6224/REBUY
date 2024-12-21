import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/Providers/message_reply_provider.dart';

class MessageReplyPreview extends ConsumerWidget {
  final String recieverName;
  const MessageReplyPreview({required this.recieverName, super.key});

  void cancelReply(WidgetRef ref) {
    ref.read(messageReplyProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageReply = ref.watch(messageReplyProvider);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: const Border(top: BorderSide(width: 0.5)),
        color: Platform.isAndroid
            ? Colors.grey[200]
            : Platform.isIOS
                ? CupertinoColors.systemGrey5
                : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  messageReply!.isMe ? 'Me' : recieverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => cancelReply(ref),
                child: Icon(
                  Platform.isAndroid
                      ? Icons.close_outlined
                      : CupertinoIcons.clear_circled,
                  size: 20,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            messageReply.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
