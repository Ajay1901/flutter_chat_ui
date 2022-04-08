import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents text message widget with optional link preview
class GroupExitMessageWidget extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class
  const GroupExitMessageWidget(
      {Key? key, required this.message, required this.fullName})
      : super(key: key);

  /// [types.GroupExitMessage]
  final types.GroupExitMessage message;
  final String fullName;

  Widget _textWidget(types.User user, BuildContext context) {
    return Text(
      '$fullName exited the group',
      style: InheritedChatTheme.of(context).theme.body1.copyWith(
          color: InheritedChatTheme.of(context).theme.secondaryTextColor),
      textWidthBasis: TextWidthBasis.longestLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _width = MediaQuery.of(context).size.width;

    final margin = message.type == types.MessageType.groupExit
        ? const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          )
        : const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          );

    return Container(
      margin: margin,
      child: Center(child: _textWidget(_user, context)),
    );
  }
}
