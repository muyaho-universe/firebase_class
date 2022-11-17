import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_class/src/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'guest_book_message.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class GuestBook extends StatefulWidget {
  const GuestBook(
      {required this.addMessage,
      super.key,
      required this.messages,
      required this.userId});

  final FutureOr<void> Function(String message) addMessage;
  final List<GuestBookMessage> messages;
  final String? userId;

  @override
  State<GuestBook> createState() => _GuestBookState();
}

class _GuestBookState extends State<GuestBook> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_GuestBookState');
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Leave a message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your message to continue';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                StyledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await widget.addMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.send),
                      SizedBox(width: 4),
                      Text('SEND'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var message in widget.messages)
          Message(message.name, message.message, message.time, widget.userId,
              MediaQuery.of(context).size.height),
        const SizedBox(height: 8),
      ],
    );
  }
}

Widget Message(
    String name, String message, String time, String? currentId, double width) {
  return (name == currentId)
      ? SizedBox(
          width: width * 4 / 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: RichText(
                    maxLines: 100,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: name),
                        TextSpan(text: ': '),
                        TextSpan(text: message),
                        TextSpan(text: '\n'),
                        TextSpan(
                            text: time, style: const TextStyle(fontSize: 10)),
                      ],
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final String _collection = 'guestbook';
                    final FirebaseFirestore _fireStore =
                        FirebaseFirestore.instance;

                    getData() async {
                      return await _fireStore.collection(_collection).get();
                    }

                    getData().then((val) {
                      if (val.docs.length > 0) {
                        for (var doc in val.docs) {
                          if (doc.data().values.first == name &&
                              doc.data().values.last == time) {
                            print(doc.data().values);
                            db
                                .collection('guestbook')
                                .doc(doc.id)
                                .delete()
                                .then(
                                  (doc) => print("Document deleted"),
                                  onError: (e) => print(
                                      "Error updating document $e\n ${FirebaseAuth.instance.currentUser!.uid}"),
                                );
                          }
                        }
                      } else {
                        print("Not Found");
                      }
                    });
                  },
                  icon: Icon(
                    Icons.delete_outlined,
                  ),
                ),
              ],
            ),
          ),
        )
      : SizedBox(
          width: width * 4 / 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: RichText(
                    maxLines: 100,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: name),
                        TextSpan(text: ': '),
                        TextSpan(text: message),
                        TextSpan(text: '\n'),
                        TextSpan(
                            text: time, style: const TextStyle(fontSize: 10)),
                      ],
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Icon(null),
              ],
            ),
          ),
        );
}
