import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final DateTime date;
  final bool isSender;
  final bool isRead;
  final String repliedText;
  final String userName;

  const ChatBubble({
    required this.message,
    required this.date,
    required this.isSender,
    required this.isRead,
    required this.repliedText,
    required this.userName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('hh:mm a').format(date);
    final isReplying = repliedText.isNotEmpty;
    final Color senderColor = Color(0xFFDCF8C6);
    final Color receiverColor = Color(0xFFE5E5E5);
    final Color textColor = Colors.black;
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: isSender ? senderColor : receiverColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: isSender ? Radius.circular(12) : Radius.circular(0),
              bottomRight: isSender ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isReplying) ...[
                Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isSender ? Colors.green : Colors.grey,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Text(
                          repliedText,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
              Text(
                message,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedTime,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (isSender)
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: isRead
                          ? Colors.blueAccent
                          : textColor.withOpacity(0.6),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
