import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents text message widget with optional link preview
class DeletedMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class
  const DeletedMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  /// [types.DeleteMessage]
  final types.DeletedMessage message;

  Widget _textWidget(types.User user, BuildContext context) {
    return Text(
      'This message was deleted',
      style: InheritedChatTheme.of(context).theme.body1.copyWith(
            color: user.id == message.authorId
                ? InheritedChatTheme.of(context).theme.primaryTextColor
                : InheritedChatTheme.of(context).theme.secondaryTextColor,
          ),
      textWidthBasis: TextWidthBasis.longestLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: _textWidget(_user, context),
    );
  }
}
