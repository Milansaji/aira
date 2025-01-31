import 'dart:convert';

import 'package:aira/widgets/message_bubble_green.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GrammerScreen extends StatefulWidget {
  GrammerScreen({super.key});

  @override
  State<GrammerScreen> createState() => _GrammerScreenState();
}

class _GrammerScreenState extends State<GrammerScreen> {
  final TextEditingController _summaryController = TextEditingController();
  List<Widget> messageWidgets = [];
  var replayMessages = [];
  String promptMessage = '';
  int words = 0;

  @override
  void dispose() {
    _summaryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fix Grammer',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.grey)
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 140, 241, 221),
                    width: 1,
                  )),
              child: messageWidgets.isEmpty
                  ? const Center(
                      child: Text(
                        'Write the text with grammatical errors below ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  : ListView.builder(
                      itemCount: messageWidgets.length,
                      itemBuilder: (context, index) {
                        return messageWidgets[index];
                      },
                    ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20),
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: _summaryController,
              maxLines: 5,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 140, 241, 221), width: 2)),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 140, 241, 221), width: 2)),
                border: const OutlineInputBorder(),
                floatingLabelAlignment: FloatingLabelAlignment.center,
                suffixIcon: IconButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() {});
                      promptMessage = _summaryController.text;
                      List<String> splitMessage = promptMessage.split(' ');

                      words = splitMessage.length;

                      _summaryController.clear();

                      messageWidgets.add(MessageBubbleGreen.first(
                          userImage: 'https://i.ibb.co/m4vFSDZ/user.png',
                          username: 'User',
                          message: promptMessage,
                          isMe: true));

                      final response = await http.post(
                          Uri.parse(
                              'https://api.openai.com/v1/chat/completions'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ${dotenv.env['token']}',
                          },
                          body: jsonEncode({
                            'model': 'gpt-3.5-turbo',
                            "messages": [
                              {
                                "role": "user",
                                "content": " Fix the grammer of  $promptMessage"
                              }
                            ],
                            'temperature': 0.7,
                          }));
                      setState(() {
                        print(response.body);

                        print(jsonDecode(response.body)['choices'][0]['message']
                            ['content']);

                        messageWidgets.add(MessageBubbleGreen.first(
                            userImage: 'https://i.ibb.co/Zm0mWSb/pngegg-1.png',
                            username: 'AI',
                            message: jsonDecode(response.body)['choices'][0]
                                ['message']['content'],
                            isMe: false));
                      });
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 52, 135, 119),
                    )),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                hintText: 'Enter text',
              ),
            ),
          ),
        ],
      )),
    );
  }
}
