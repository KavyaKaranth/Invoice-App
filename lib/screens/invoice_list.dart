import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'invoice_form.dart';
import 'invoice_view.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Future<void> deleteInvoice(String docId) async {
    await FirebaseFirestore.instance.collection('invoices').doc(docId).delete();
  }

  Future<void> markAsResent(String docId) async {
    await FirebaseFirestore.instance.collection('invoices').doc(docId).update({
      'resent': true,
      'resent_timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Column(
        children: [
          // Gradient header like login page
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text(
                "All Invoices",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

          // Invoices list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invoices')
                  .where('user_id', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No invoices found.",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final invoice = docs[index];
                    final dueDate = (invoice['due_date'] as Timestamp).toDate();
                    final isPaid = invoice['status'] == 'Paid';
                    final overdue = isOverdue(dueDate) && !isPaid;

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.purple,
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          invoice['client_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.purple,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Service: ${invoice['service']}"),
                            Text("Amount: ₹${invoice['amount']}"),
                            Text("Due: ${DateFormat.yMMMd().format(dueDate)}"),
                            Text(
                              "Status: ${invoice['status']} ${overdue ? "(Overdue)" : ""}",
                              style: TextStyle(
                                color: overdue
                                    ? Colors.redAccent
                                    : (isPaid ? Colors.green : Colors.orange),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'delete')
                              deleteInvoice(invoice.id);
                            else if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InvoiceFormEdit(
                                    docId: invoice.id,
                                    initialData:
                                        invoice.data() as Map<String, dynamic>,
                                  ),
                                ),
                              );
                            } else if (value == 'view') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InvoiceView(
                                    invoiceData: {
                                      ...invoice.data() as Map<String, dynamic>,
                                      // Convert Timestamp to String for display
                                      'due_date':
                                          (invoice['due_date'] as Timestamp)
                                              .toDate()
                                              .toString(),
                                    },
                                  ),
                                ),
                              );
                            }
                          },

                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'view', child: Text("View")),
                            PopupMenuItem(value: 'edit', child: Text("Edit")),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text("Delete"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
