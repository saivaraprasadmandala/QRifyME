import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class AskFeedback extends StatefulWidget {
  final String title;
  final String description;
  const AskFeedback({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<AskFeedback> createState() => _AskFeedbackState();
}

class _AskFeedbackState extends State<AskFeedback> {
  List<Map<String, dynamic>> feedbackList = [];

  Future<void> fetchFeedback() async {
    setState(() {
      feedbackList.clear();
    });

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('title', isEqualTo: widget.title)
        .where('description', isEqualTo: widget.description)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> document
          in querySnapshot.docs) {
        CollectionReference registeredUsersCollection =
            document.reference.collection('feedback');
        QuerySnapshot<Map<String, dynamic>> registeredUsersSnapshot =
            await registeredUsersCollection.get()
                as QuerySnapshot<Map<String, dynamic>>;

        if (registeredUsersSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> feedbackDataList =
              registeredUsersSnapshot.docs
                  .map((doc) => {
                        'email': doc['email'] as String? ?? '',
                        'feedback': doc['feedback'] as String? ?? '',
                      })
                  .toList();
          setState(() {
            feedbackList.addAll(feedbackDataList);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feedback",
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        fetchFeedback();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Get Feedbacks",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn2(
                              label: Text('Serial No.'),
                              size: ColumnSize.S,
                              numeric: true,
                            ),
                            DataColumn2(
                              label: Text('Email'),
                            ),
                            DataColumn2(
                              label: Text('Feedback'),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            feedbackList.length,
                            (index) {
                              final feedbackData = feedbackList[index];
                              final email = feedbackData['email'];
                              final feedback = feedbackData['feedback'];

                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(email)),
                                  DataCell(Text(feedback)),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
