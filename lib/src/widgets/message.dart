import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';

import 'file_message.dart';
import 'image_message.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'text_message.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages, delivery time and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.dateLocale,
    required this.message,
    required this.messageWidth,
    this.onMessageLongPress,
    this.onMessageTap,
    this.onPreviewDataFetched,
    required this.previousMessageSameAuthor,
    required this.shouldRenderTime,
    this.usersUidMap,
    this.isGroupChat = false,
    this.deviceTimeOffset = 0,
  }) : super(key: key);

  final Map<String, String>? usersUidMap;
  final bool isGroupChat;
  final int deviceTimeOffset;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown.
  final String? dateLocale;

  /// Any message type
  final types.Message message;

  /// Maximum message width
  final int messageWidth;

  /// Called when user makes a long press on any message
  final void Function(types.Message)? onMessageLongPress;

  /// Called when user taps on any message
  final void Function(types.Message)? onMessageTap;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Whether previous message was sent by the same person. Used for
  /// different spacing for sent and received messages.
  final bool previousMessageSameAuthor;

  /// Whether delivery time should be rendered. It is not rendered for
  /// received messages and when sent messages have small difference in
  /// delivery time.
  final bool shouldRenderTime;

  Widget _buildMessage() {
    String? name;

    if (usersUidMap != null) {
      final key = message.authorId;
      name = usersUidMap![key] ?? 'You';
    }

    switch (message.type) {
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(color: Colors.red[200]),
                ),
              )
            else
              Container(),
            FileMessage(
              message: fileMessage,
            ),
          ],
        );
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  style: TextStyle(color: Colors.red[200]),
                ),
              )
            else
              const SizedBox(height: 0, width: 0),
            ImageMessage(
              message: imageMessage,
              messageWidth: messageWidth,
            ),
          ],
        );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 2),
                child: Text(
                  name,
                  style: TextStyle(color: Colors.red[200]),
                ),
              )
            else
              const SizedBox(),
            TextMessage(
              message: textMessage,
              onPreviewDataFetched: onPreviewDataFetched,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildStatus(BuildContext context) {
    switch (message.status) {
      case types.Status.delivered:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.deliveredIcon!,
                color: InheritedChatTheme.of(context).theme.primaryColor,
              )
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.read:
        return InheritedChatTheme.of(context).theme.readIcon != null
            ? Image.asset(
                InheritedChatTheme.of(context).theme.readIcon!,
                color: InheritedChatTheme.of(context).theme.primaryColor,
              )
            : Image.asset(
                'assets/icon-read.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'flutter_chat_ui',
              );
      case types.Status.sending:
        return SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
            backgroundColor: Colors.transparent,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              InheritedChatTheme.of(context).theme.primaryColor,
            ),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildTime(bool currentUserIsAuthor, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(
            right: currentUserIsAuthor ? 8 : 16,
          ),
          child: Text(
            deviceTimeOffset.isNegative
                ? DateFormat.jm(dateLocale).format(
                    DateTime.fromMillisecondsSinceEpoch(
                      message.timestamp! * 1000,
                    ).add(Duration(milliseconds: deviceTimeOffset)),
                  )
                : DateFormat.jm(dateLocale).format(
                    DateTime.fromMillisecondsSinceEpoch(
                      message.timestamp! * 1000,
                    ).subtract(Duration(milliseconds: deviceTimeOffset)),
                  ),
            style: InheritedChatTheme.of(context).theme.caption.copyWith(
                  color: InheritedChatTheme.of(context).theme.captionColor,
                ),
          ),
        ),
        if (currentUserIsAuthor) _buildStatus(context)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(
          _user.id == message.authorId ? _messageBorderRadius : 0),
      bottomRight: Radius.circular(
          _user.id == message.authorId ? 0 : _messageBorderRadius),
      topLeft: Radius.circular(_messageBorderRadius),
      topRight: Radius.circular(_messageBorderRadius),
    );
    final _currentUserIsAuthor = _user.id == message.authorId;

    return Container(
      alignment: _user.id == message.authorId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: EdgeInsets.only(
        bottom: previousMessageSameAuthor ? 8 : 16,
        left: 24,
        right: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: messageWidth.toDouble(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onLongPress: () => onMessageLongPress?.call(message),
              onTap: () => onMessageTap?.call(message),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: _borderRadius,
                  color: !_currentUserIsAuthor ||
                          message.type == types.MessageType.image
                      ? InheritedChatTheme.of(context).theme.secondaryColor
                      : InheritedChatTheme.of(context).theme.primaryColor,
                ),
                child: ClipRRect(
                  borderRadius: _borderRadius,
                  child: _buildMessage(),
                ),
              ),
            ),
            if (shouldRenderTime)
              Container(
                margin: const EdgeInsets.only(
                  top: 8,
                ),
                child: _buildTime(_currentUserIsAuthor, context),
              )
          ],
        ),
      ),
    );
  }
}
