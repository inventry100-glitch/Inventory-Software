// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';

// class CustomersScreen extends StatefulWidget {
//   const CustomersScreen({super.key});

//   @override
//   State<CustomersScreen> createState() => _CustomersScreenState();
// }

// class _CustomersScreenState extends State<CustomersScreen> {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final TextEditingController _search = TextEditingController();
//   int _tab = 0;

//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }

//   String _s(dynamic v) => v?.toString() ?? '';

//   double _n(dynamic v) {
//     if (v is num) return v.toDouble();
//     return double.tryParse(_s(v)) ?? 0;
//   }

//   String _rs(dynamic v) => 'Rs. ${_n(v).toStringAsFixed(0)}';

//   String _payment(Map<String, dynamic> d) {
//     final s = _s(d['paymentStatus']).toLowerCase();
//     if (s == 'paid' || s == 'partial' || s == 'unpaid') return s;
//     final total = _n(d['totalAmount']);
//     final paid = _n(d['paidAmount']);
//     if (total <= 0 || paid >= total) return 'paid';
//     if (paid > 0) return 'partial';
//     return 'unpaid';
//   }

//   String _rental(Map<String, dynamic> d) {
//     return _s(d['rentalStatus']).toLowerCase() == 'returned'
//         ? 'returned'
//         : 'rented';
//   }

//   bool _cleared(Map<String, dynamic> d) =>
//       _rental(d) == 'returned' && _payment(d) == 'paid';

//   List<Map<String, dynamic>> _items(Map<String, dynamic> d) {
//     final raw = d['items'];
//     if (raw is! List) return [];
//     return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
//   }

//   String _itemsText(Map<String, dynamic> d) {
//     final items = _items(d);
//     if (items.isEmpty) return 'No rental items';
//     return items.map((i) {
//       final name = _s(i['name']).isEmpty ? 'Unnamed Item' : _s(i['name']);
//       final q = _n(i['quantity'] ?? i['qty']).toStringAsFixed(0);
//       return '$name × $q';
//     }).join(', ');
//   }

//   String _date(dynamic v) {
//     DateTime? d;
//     if (v is Timestamp) d = v.toDate();
//     if (v is DateTime) d = v;
//     if (d == null) d = DateTime.tryParse(_s(v));
//     if (d == null) return '-';
//     return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
//   }

//   void _msg(String text, {bool error = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(text), backgroundColor: error ? Colors.red : null),
//     );
//   }

//   Future<void> _markPaid(DocumentSnapshot<Map<String, dynamic>> bill) async {
//     final d = bill.data() ?? {};
//     if (_payment(d) == 'paid') {
//       _msg('Paid payments are locked and cannot be changed.');
//       return;
//     }

//     final total = _n(d['totalAmount']);
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: const Text('Mark Payment as Paid'),
//         content: Text(
//           'Customer: ${_s(d['customerName'])}\n'
//           'Total: ${_rs(total)}\n'
//           'Remaining: ${_rs(d['remainingAmount'])}\n\n'
//           'After this, the payment status will be locked.',
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Mark Paid')),
//         ],
//       ),
//     );

//     if (ok != true) return;

//     try {
//       await bill.reference.update({
//         'paidAmount': total,
//         'remainingAmount': 0,
//         'paymentStatus': 'paid',
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       _msg('Payment marked as paid and locked.');
//     } catch (e) {
//       _msg('Could not update payment: $e', error: true);
//     }
//   }

//   Future<void> _returnItems(DocumentSnapshot<Map<String, dynamic>> bill) async {
//     final d = bill.data() ?? {};
//     if (_rental(d) == 'returned') return;

//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: const Text('Return Rental Items'),
//         content: Text('Mark these items as returned?\n\n${_itemsText(d)}'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Mark Returned')),
//         ],
//       ),
//     );
//     if (ok != true) return;

//     try {
//       await _db.runTransaction((tx) async {
//         final items = _items(d);
//         final refs = <DocumentReference<Map<String, dynamic>>>[];
//         final snaps = <DocumentSnapshot<Map<String, dynamic>>>[];
//         final qtys = <double>[];

//         for (final item in items) {
//           final id = _s(item['itemId']).isNotEmpty ? _s(item['itemId']) : _s(item['id']);
//           if (id.isEmpty) continue;
//           final ref = _db.collection('inventory').doc(id);
//           refs.add(ref);
//           snaps.add(await tx.get(ref));
//           qtys.add(_n(item['quantity'] ?? item['qty']));
//         }

//         for (var i = 0; i < refs.length; i++) {
//           if (!snaps[i].exists) continue;
//           final x = snaps[i].data() ?? {};
//           tx.update(refs[i], {
//             'availableStock': _n(x['availableStock']) + qtys[i],
//             'rentedStock': (_n(x['rentedStock']) - qtys[i]).clamp(0, 999999999),
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         }

//         tx.update(bill.reference, {
//           'rentalStatus': 'returned',
//           'returnedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       });
//       _msg('Rental items returned successfully.');
//     } catch (e) {
//       _msg('Could not return items: $e', error: true);
//     }
//   }

//   Future<void> _edit(DocumentSnapshot<Map<String, dynamic>> bill) async {
//     final d = bill.data() ?? {};
//     final name = TextEditingController(text: _s(d['customerName']));
//     final contact = TextEditingController(text: _s(d['contactNumber']));
//     final cnic = TextEditingController(text: _s(d['cnic']));

//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: const Text('Edit Customer'),
//         content: SizedBox(
//           width: 450,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(controller: name, decoration: const InputDecoration(labelText: 'Customer Name')),
//               const SizedBox(height: 12),
//               TextField(controller: contact, decoration: const InputDecoration(labelText: 'Contact Number')),
//               const SizedBox(height: 12),
//               TextField(controller: cnic, decoration: const InputDecoration(labelText: 'CNIC')),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
//           ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
//         ],
//       ),
//     );

//     if (ok == true) {
//       try {
//         await bill.reference.update({
//           'customerName': name.text.trim(),
//           'contactNumber': contact.text.trim(),
//           'cnic': cnic.text.trim(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//         _msg('Customer updated.');
//       } catch (e) {
//         _msg('Could not update customer: $e', error: true);
//       }
//     }
//     name.dispose();
//     contact.dispose();
//     cnic.dispose();
//   }

//   Future<void> _delete(DocumentSnapshot<Map<String, dynamic>> bill) async {
//     final d = bill.data() ?? {};
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (c) => AlertDialog(
//         title: const Text('Delete Customer Record?'),
//         content: const Text(
//           'If this rental is still active, its stock will be returned before the record is deleted.',
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//             onPressed: () => Navigator.pop(c, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     if (ok != true) return;

//     try {
//       await _db.runTransaction((tx) async {
//         if (_rental(d) != 'returned') {
//           for (final item in _items(d)) {
//             final id = _s(item['itemId']).isNotEmpty ? _s(item['itemId']) : _s(item['id']);
//             if (id.isEmpty) continue;
//             final ref = _db.collection('inventory').doc(id);
//             final snap = await tx.get(ref);
//             if (!snap.exists) continue;
//             final x = snap.data() ?? {};
//             final q = _n(item['quantity'] ?? item['qty']);
//             tx.update(ref, {
//               'availableStock': _n(x['availableStock']) + q,
//               'rentedStock': (_n(x['rentedStock']) - q).clamp(0, 999999999),
//               'updatedAt': FieldValue.serverTimestamp(),
//             });
//           }
//         }
//         tx.delete(bill.reference);
//       });
//       _msg('Customer record deleted.');
//     } catch (e) {
//       _msg('Could not delete record: $e', error: true);
//     }
//   }

//   void _billView(Map<String, dynamic> d) {
//     final items = _items(d);
//     final payment = _payment(d);
//     final rental = _rental(d);

//     showDialog(
//       context: context,
//       builder: (c) => Dialog(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 700, maxHeight: 760),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   const Expanded(child: Text('Bill View', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
//                   IconButton(onPressed: () => Navigator.pop(c), icon: const Icon(Icons.close)),
//                 ]),
//                 const Divider(),
//                 _info('Bill Number', _s(d['billNumber']).isEmpty ? '-' : _s(d['billNumber'])),
//                 _info('Generated', _date(d['createdAt'])),
//                 _info('Customer', _s(d['customerName'])),
//                 _info('Contact', _s(d['contactNumber'])),
//                 _info('CNIC', _s(d['cnic'])),
//                 _info('Rental From', _date(d['dateFrom'])),
//                 _info('Rental Till', _date(d['dateTill'])),
//                 const SizedBox(height: 18),
//                 const Text('Rental Items', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 8),
//                 ...items.map((i) => ListTile(
//                   dense: true,
//                   contentPadding: EdgeInsets.zero,
//                   title: Text(_s(i['name']).isEmpty ? 'Unnamed Item' : _s(i['name'])),
//                   subtitle: Text('Quantity: ${_n(i['quantity'] ?? i['qty']).toStringAsFixed(0)}'),
//                   trailing: Text(_rs(i['totalPrice'] ?? i['total'] ?? i['amount'])),
//                 )),
//                 const Divider(),
//                 _amount('Actual Amount', d['subtotal']),
//                 _amount('Discount', d['discount']),
//                 _amount('Total Amount', d['totalAmount'], bold: true),
//                 _amount('Paid', d['paidAmount']),
//                 _amount('Remaining', d['remainingAmount'], bold: true),
//                 const SizedBox(height: 10),
//                 Wrap(spacing: 8, children: [
//                   _badge(payment.toUpperCase(), _paymentColor(payment)),
//                   _badge(rental == 'returned' ? 'RETURNED' : 'RENTED', rental == 'returned' ? Colors.green : Colors.orange),
//                 ]),
//                 if (payment == 'unpaid')
//                   _note('Payment is due on or before the return date.'),
//                 if (payment == 'partial')
//                   _note('Remaining balance of ${_rs(d['remainingAmount'])} is due on or before the return date.'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _info(String a, String b) => Padding(
//     padding: const EdgeInsets.only(bottom: 8),
//     child: Row(children: [
//       SizedBox(width: 120, child: Text(a, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600))),
//       Expanded(child: Text(b.isEmpty ? '-' : b)),
//     ]),
//   );

//   Widget _amount(String a, dynamic b, {bool bold = false}) => Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(children: [
//       Expanded(child: Text(a, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500))),
//       Text(_rs(b), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
//     ]),
//   );

//   Widget _note(String text) => Container(
//     width: double.infinity,
//     margin: const EdgeInsets.only(top: 14),
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: Colors.orange.withOpacity(.08),
//       borderRadius: BorderRadius.circular(10),
//       border: Border.all(color: Colors.orange.withOpacity(.3)),
//     ),
//     child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
//   );

//   Widget _badge(String text, Color color) => Container(
//     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//     decoration: BoxDecoration(
//       color: color.withOpacity(.1),
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: color.withOpacity(.3)),
//     ),
//     child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
//   );

//   Color _paymentColor(String s) {
//     if (s == 'paid') return Colors.green;
//     if (s == 'partial') return Colors.orange;
//     return Colors.red;
//   }

//   Widget _summary(String title, String value, IconData icon, Color color) => Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(15),
//       border: Border.all(color: Colors.grey.shade200),
//     ),
//     child: Row(children: [
//       Icon(icon, color: color, size: 30),
//       const SizedBox(width: 12),
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
//         Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
//       ]),
//     ]),
//   );

//   Widget _tabButton(String text, int index, int count, IconData icon) {
//     final selected = _tab == index;
//     final color = Theme.of(context).colorScheme.primary;
//     return Expanded(
//       child: InkWell(
//         onTap: () => setState(() => _tab = index),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
//           decoration: BoxDecoration(
//             color: selected ? color : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: selected ? color : Colors.grey.shade300),
//           ),
//           child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Icon(icon, color: selected ? Colors.white : Colors.black87),
//             const SizedBox(width: 7),
//             Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))),
//             const SizedBox(width: 7),
//             Text('$count', style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget _card(DocumentSnapshot<Map<String, dynamic>> bill) {
//     final d = bill.data() ?? {};
//     final name = _s(d['customerName']).isEmpty ? 'Unnamed Customer' : _s(d['customerName']);
//     final payment = _payment(d);
//     final rental = _rental(d);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _cleared(d) ? Colors.green.withOpacity(.2) : Colors.orange.withOpacity(.2)),
//       ),
//       child: Column(children: [
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           CircleAvatar(child: Text(name[0].toUpperCase())),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(_s(d['contactNumber']).isEmpty ? 'No contact' : _s(d['contactNumber'])),
//             const SizedBox(height: 3),
//             Text('Bill: ${_s(d['billNumber']).isEmpty ? bill.id : d['billNumber']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
//           ])),
//           Wrap(spacing: 5, children: [
//             _badge(payment.toUpperCase(), _paymentColor(payment)),
//             _badge(rental == 'returned' ? 'RETURNED' : 'RENTED', rental == 'returned' ? Colors.green : Colors.orange),
//           ]),
//           PopupMenuButton<String>(
//             onSelected: (v) => v == 'edit' ? _edit(bill) : _delete(bill),
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: 'edit', child: Text('Edit')),
//               PopupMenuItem(value: 'delete', child: Text('Delete')),
//             ],
//           ),
//         ]),
//         const SizedBox(height: 14),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
//           child: Row(children: [
//             const Icon(Icons.inventory_2_outlined, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(_itemsText(d), style: const TextStyle(fontWeight: FontWeight.w600))),
//           ]),
//         ),
//         const SizedBox(height: 12),
//         Row(children: [
//           Expanded(child: _smallAmount('Total', d['totalAmount'], Colors.blue)),
//           const SizedBox(width: 7),
//           Expanded(child: _smallAmount('Paid', d['paidAmount'], Colors.green)),
//           const SizedBox(width: 7),
//           Expanded(child: _smallAmount('Remaining', d['remainingAmount'], payment == 'paid' ? Colors.green : Colors.red)),
//         ]),
//         const SizedBox(height: 12),
//         Row(children: [
//           Expanded(child: OutlinedButton.icon(
//             onPressed: () => _billView(d),
//             icon: const Icon(Icons.receipt_long_outlined),
//             label: const Text('Bill View'),
//           )),
//           const SizedBox(width: 8),
//           Expanded(child: payment == 'paid'
//             ? OutlinedButton.icon(onPressed: null, icon: Icon(Icons.lock_outline), label: Text('Paid'))
//             : ElevatedButton.icon(onPressed: () => _markPaid(bill), icon: const Icon(Icons.check_circle_outline), label: const Text('Mark Paid'))),
//         ]),
//         const SizedBox(height: 8),
//         if (rental != 'returned')
//           SizedBox(width: double.infinity, child: OutlinedButton.icon(
//             onPressed: () => _returnItems(bill),
//             icon: const Icon(Icons.assignment_return_outlined),
//             label: const Text('Mark Rental Items Returned'),
//           ))
//         else
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: Colors.green.withOpacity(.06), borderRadius: BorderRadius.circular(9)),
//             child: Text(
//               payment == 'paid' ? '✓ Rental returned & payment cleared' : '✓ Rental returned • payment still pending',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
//             ),
//           ),
//         const SizedBox(height: 7),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'Rental: ${_date(d['dateFrom'])} → ${_date(d['dateTill'])}',
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _smallAmount(String title, dynamic value, Color color) => Container(
//     padding: const EdgeInsets.all(9),
//     decoration: BoxDecoration(color: color.withOpacity(.06), borderRadius: BorderRadius.circular(9)),
//     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
//       const SizedBox(height: 3),
//       Text(_rs(value), overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
//     ]),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: AppBar(title: const Text('Customer Management', style: TextStyle(fontWeight: FontWeight.bold))),
//       drawer: AdminDrawer(selectedIndex: 2),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _db.collection('bills').orderBy('createdAt', descending: true).snapshots(),
//         builder: (context, snap) {
//           if (snap.hasError) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Could not load customers.\n\n${snap.error}', textAlign: TextAlign.center)));
//           if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

//           final all = snap.data?.docs ?? [];
//           final filtered = all.where((b) => _s(b.data()['customerName']).toLowerCase().contains(_search.text.toLowerCase())).toList();
//           final current = filtered.where((b) => !_cleared(b.data())).toList();
//           final cleared = filtered.where((b) => _cleared(b.data())).toList();
//           final shown = _tab == 0 ? current : cleared;

//           return Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1100),
//               child: ListView(
//                 padding: const EdgeInsets.all(20),
//                 children: [
//                   LayoutBuilder(builder: (context, c) {
//                     final cards = [
//                       _summary('Customers / Rentals', '${all.length}', Icons.people_outline, Colors.blue),
//                       _summary('Current / Pending', '${current.length}', Icons.pending_actions_outlined, Colors.orange),
//                       _summary('Cleared / Returned', '${cleared.length}', Icons.verified_outlined, Colors.green),
//                     ];
//                     if (c.maxWidth < 650) return Column(children: [cards[0], const SizedBox(height: 10), cards[1], const SizedBox(height: 10), cards[2]]);
//                     return Row(children: [for (var i = 0; i < cards.length; i++) Expanded(child: cards[i]),]);
//                   }),
//                   const SizedBox(height: 18),
//                   TextField(
//                     controller: _search,
//                     onChanged: (_) => setState(() {}),
//                     decoration: InputDecoration(
//                       hintText: 'Search customer by name only...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   LayoutBuilder(builder: (context, c) {
//                     final a = _tabButton('Current / Pending Clearance', 0, current.length, Icons.pending_actions_outlined);
//                     final b = _tabButton('Cleared / Returned', 1, cleared.length, Icons.verified_outlined);
//                     if (c.maxWidth < 600) return Column(children: [a, const SizedBox(height: 8), b]);
//                     return Row(children: [a, const SizedBox(width: 10), b]);
//                   }),
//                   const SizedBox(height: 18),
//                   Text(_tab == 0 ? 'Current / Pending Clearance' : 'Cleared / Returned', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 10),
//                   if (shown.isEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(45),
//                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
//                       child: Column(children: [
//                         Icon(_tab == 0 ? Icons.assignment_turned_in_outlined : Icons.verified_outlined, size: 50, color: Colors.grey.shade400),
//                         const SizedBox(height: 10),
//                         Text(_tab == 0 ? 'No current or pending customers' : 'No cleared customers yet', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
//                       ]),
//                     )
//                   else
//                     ...shown.map(_card),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/drawer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _search = TextEditingController();

  int _tab = 0;

  // ============================================================
  // THEME
  // ============================================================

  static const Color background = Color(0xFFF7F2EA);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color bronze = Color(0xFF9A6A3A);
  static const Color bronzeDark = Color(0xFF704823);
  static const Color bronzeLight = Color(0xFFE9D6BC);
  static const Color darkBrown = Color(0xFF2C2119);
  static const Color mediumBrown = Color(0xFF59483A);
  static const Color mutedText = Color(0xFF8A7B6E);
  static const Color border = Color(0xFFE6D9CB);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _s(dynamic v) => v?.toString() ?? '';

  double _n(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(_s(v)) ?? 0;
  }

  String _rs(dynamic v) => 'Rs. ${_n(v).toStringAsFixed(0)}';

  String _payment(Map<String, dynamic> d) {
    final s = _s(d['paymentStatus']).toLowerCase();

    if (s == 'paid' || s == 'partial' || s == 'unpaid') {
      return s;
    }

    final total = _n(d['totalAmount']);
    final paid = _n(d['paidAmount']);

    if (total <= 0 || paid >= total) {
      return 'paid';
    }

    if (paid > 0) {
      return 'partial';
    }

    return 'unpaid';
  }

  String _rental(Map<String, dynamic> d) {
    return _s(d['rentalStatus']).toLowerCase() == 'returned'
        ? 'returned'
        : 'rented';
  }

  bool _cleared(Map<String, dynamic> d) {
    return _rental(d) == 'returned' && _payment(d) == 'paid';
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> d) {
    final raw = d['items'];

    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _itemsText(Map<String, dynamic> d) {
    final items = _items(d);

    if (items.isEmpty) {
      return 'No rental items';
    }

    return items.map((i) {
      final name =
          _s(i['name']).isEmpty ? 'Unnamed Item' : _s(i['name']);

      final q = _n(i['quantity'] ?? i['qty']).toStringAsFixed(0);

      return '$name × $q';
    }).join(', ');
  }

  String _date(dynamic v) {
    DateTime? d;

    if (v is Timestamp) {
      d = v.toDate();
    }

    if (v is DateTime) {
      d = v;
    }

    if (d == null) {
      d = DateTime.tryParse(_s(v));
    }

    if (d == null) {
      return '-';
    }

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  void _msg(String text, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? Colors.red.shade700 : bronzeDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // MARK PAYMENT PAID
  // ============================================================

  Future<void> _markPaid(
    DocumentSnapshot<Map<String, dynamic>> bill,
  ) async {
    final d = bill.data() ?? {};

    if (_payment(d) == 'paid') {
      _msg('Paid payments are locked and cannot be changed.');
      return;
    }

    final total = _n(d['totalAmount']);

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Mark Payment as Paid',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          content: Text(
            'Customer: ${_s(d['customerName'])}\n'
            'Total: ${_rs(total)}\n'
            'Remaining: ${_rs(d['remainingAmount'])}\n\n'
            'After this, the payment status will be locked.',
            style: const TextStyle(
              color: mediumBrown,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mediumBrown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bronze,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Mark Paid'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await bill.reference.update({
        'paidAmount': total,
        'remainingAmount': 0,
        'paymentStatus': 'paid',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _msg('Payment marked as paid and locked.');
    } catch (e) {
      _msg(
        'Could not update payment: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // RETURN ITEMS
  // ============================================================

  Future<void> _returnItems(
    DocumentSnapshot<Map<String, dynamic>> bill,
  ) async {
    final d = bill.data() ?? {};

    if (_rental(d) == 'returned') {
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Return Rental Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          content: Text(
            'Mark these items as returned?\n\n${_itemsText(d)}',
            style: const TextStyle(
              color: mediumBrown,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mediumBrown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bronze,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Mark Returned'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await _db.runTransaction((tx) async {
        final items = _items(d);

        final refs =
            <DocumentReference<Map<String, dynamic>>>[];

        final snaps =
            <DocumentSnapshot<Map<String, dynamic>>>[];

        final qtys = <double>[];

        for (final item in items) {
          final id = _s(item['itemId']).isNotEmpty
              ? _s(item['itemId'])
              : _s(item['id']);

          if (id.isEmpty) continue;

          final ref = _db.collection('inventory').doc(id);

          refs.add(ref);
          snaps.add(await tx.get(ref));

          qtys.add(
            _n(item['quantity'] ?? item['qty']),
          );
        }

        for (var i = 0; i < refs.length; i++) {
          if (!snaps[i].exists) continue;

          final x = snaps[i].data() ?? {};

          tx.update(refs[i], {
            'availableStock':
                _n(x['availableStock']) + qtys[i],
            'rentedStock':
                (_n(x['rentedStock']) - qtys[i])
                    .clamp(0, 999999999),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        tx.update(bill.reference, {
          'rentalStatus': 'returned',
          'returnedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      _msg('Rental items returned successfully.');
    } catch (e) {
      _msg(
        'Could not return items: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // EDIT CUSTOMER
  // ============================================================

  Future<void> _edit(
    DocumentSnapshot<Map<String, dynamic>> bill,
  ) async {
    final d = bill.data() ?? {};

    final name =
        TextEditingController(text: _s(d['customerName']));

    final contact =
        TextEditingController(text: _s(d['contactNumber']));

    final cnic =
        TextEditingController(text: _s(d['cnic']));

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        final width = MediaQuery.sizeOf(c).width;

        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Edit Customer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          content: SizedBox(
            width: width < 500 ? width * .82 : 430,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(
                  controller: name,
                  label: 'Customer Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: contact,
                  label: 'Contact Number',
                  icon: Icons.phone_outlined,
                ),
                const SizedBox(height: 12),
                _dialogField(
                  controller: cnic,
                  label: 'CNIC',
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mediumBrown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bronze,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      try {
        await bill.reference.update({
          'customerName': name.text.trim(),
          'contactNumber': contact.text.trim(),
          'cnic': cnic.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _msg('Customer updated.');
      } catch (e) {
        _msg(
          'Could not update customer: $e',
          error: true,
        );
      }
    }

    name.dispose();
    contact.dispose();
    cnic.dispose();
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: darkBrown,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: bronze,
        ),
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: bronze,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _delete(
    DocumentSnapshot<Map<String, dynamic>> bill,
  ) async {
    final d = bill.data() ?? {};

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Customer Record?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          content: const Text(
            'If this rental is still active, its stock will be '
            'returned before the record is deleted.',
            style: TextStyle(
              color: mediumBrown,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: mediumBrown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await _db.runTransaction((tx) async {
        if (_rental(d) != 'returned') {
          for (final item in _items(d)) {
            final id = _s(item['itemId']).isNotEmpty
                ? _s(item['itemId'])
                : _s(item['id']);

            if (id.isEmpty) continue;

            final ref =
                _db.collection('inventory').doc(id);

            final snap = await tx.get(ref);

            if (!snap.exists) continue;

            final x = snap.data() ?? {};

            final q = _n(
              item['quantity'] ?? item['qty'],
            );

            tx.update(ref, {
              'availableStock':
                  _n(x['availableStock']) + q,
              'rentedStock':
                  (_n(x['rentedStock']) - q)
                      .clamp(0, 999999999),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        tx.delete(bill.reference);
      });

      _msg('Customer record deleted.');
    } catch (e) {
      _msg(
        'Could not delete record: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // BILL VIEW
  // ============================================================

  void _billView(Map<String, dynamic> d) {
    final items = _items(d);
    final payment = _payment(d);
    final rental = _rental(d);

    showDialog(
      context: context,
      builder: (c) {
        final screen = MediaQuery.sizeOf(c);

        return Dialog(
          backgroundColor: surface,
          insetPadding: EdgeInsets.symmetric(
            horizontal: screen.width < 500 ? 12 : 28,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: screen.height * .90,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                screen.width < 450 ? 17 : 24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bronzeLight,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: bronzeDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bill View',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.pop(c),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    height: 1,
                    color: border,
                  ),

                  const SizedBox(height: 18),

                  _info(
                    'Bill Number',
                    _s(d['billNumber']).isEmpty
                        ? '-'
                        : _s(d['billNumber']),
                  ),
                  _info(
                    'Generated',
                    _date(d['createdAt']),
                  ),
                  _info(
                    'Customer',
                    _s(d['customerName']),
                  ),
                  _info(
                    'Contact',
                    _s(d['contactNumber']),
                  ),
                  _info(
                    'CNIC',
                    _s(d['cnic']),
                  ),
                  _info(
                    'Rental From',
                    _date(d['dateFrom']),
                  ),
                  _info(
                    'Rental Till',
                    _date(d['dateTill']),
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle(
                    'Rental Items',
                    Icons.inventory_2_outlined,
                  ),

                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    _emptyBox('No rental items')
                  else
                    ...items.map(
                      (i) => Container(
                        margin: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: background,
                          borderRadius:
                              BorderRadius.circular(11),
                          border: Border.all(
                            color: border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _s(i['name']).isEmpty
                                    ? 'Unnamed Item'
                                    : _s(i['name']),
                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.w700,
                                  color: darkBrown,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '× ${_n(i['quantity'] ?? i['qty']).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: mediumBrown,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _rs(
                                i['totalPrice'] ??
                                    i['total'] ??
                                    i['amount'],
                              ),
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color: bronzeDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: border,
                  ),
                  const SizedBox(height: 12),

                  _amount(
                    'Actual Amount',
                    d['subtotal'],
                  ),
                  _amount(
                    'Discount',
                    d['discount'],
                  ),
                  _amount(
                    'Total Amount',
                    d['totalAmount'],
                    bold: true,
                  ),
                  _amount(
                    'Paid',
                    d['paidAmount'],
                  ),
                  _amount(
                    'Remaining',
                    d['remainingAmount'],
                    bold: true,
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(
                        payment.toUpperCase(),
                        _paymentColor(payment),
                      ),
                      _badge(
                        rental == 'returned'
                            ? 'RETURNED'
                            : 'RENTED',
                        rental == 'returned'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ],
                  ),

                  if (payment == 'unpaid')
                    _note(
                      'Payment is due on or before the return date.',
                    ),

                  if (payment == 'partial')
                    _note(
                      'Remaining balance of '
                      '${_rs(d['remainingAmount'])} is due on '
                      'or before the return date.',
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: bronze,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: darkBrown,
          ),
        ),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: mutedText,
        ),
      ),
    );
  }

  Widget _info(String a, String b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              a,
              style: const TextStyle(
                color: mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              b.isEmpty ? '-' : b,
              style: const TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amount(
    String a,
    dynamic b, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a,
              style: TextStyle(
                color: darkBrown,
                fontWeight: bold
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ),
          Text(
            _rs(b),
            style: TextStyle(
              color: bold ? bronzeDark : mediumBrown,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _note(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.orange.withOpacity(.25),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: mediumBrown,
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _paymentColor(String s) {
    if (s == 'paid') return Colors.green.shade700;
    if (s == 'partial') return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summary(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BUTTON
  // ============================================================

  Widget _tabButton(
    String text,
    int index,
    int count,
    IconData icon,
  ) {
    final selected = _tab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _tab = index;
          });
        },
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? bronze : surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? bronze : border,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected
                    ? Colors.white
                    : bronzeDark,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : darkBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(.18)
                      : bronzeLight,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : bronzeDark,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CUSTOMER CARD
  // ============================================================

  Widget _card(
    DocumentSnapshot<Map<String, dynamic>> bill,
  ) {
    final d = bill.data() ?? {};

    final name =
        _s(d['customerName']).isEmpty
            ? 'Unnamed Customer'
            : _s(d['customerName']);

    final payment = _payment(d);
    final rental = _rental(d);
    final cleared = _cleared(d);

    final width = MediaQuery.sizeOf(context).width;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(
        width < 400 ? 14 : 18,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cleared
              ? Colors.green.withOpacity(.22)
              : bronzeLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // CUSTOMER HEADER
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bronzeLight,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: bronzeDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize:
                            width < 400 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _s(d['contactNumber']).isEmpty
                          ? 'No contact'
                          : _s(d['contactNumber']),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mediumBrown,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bill: ${_s(d['billNumber']).isEmpty ? bill.id : d['billNumber']}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert,
                  color: mediumBrown,
                ),
                onSelected: (v) {
                  if (v == 'edit') {
                    _edit(bill);
                  } else {
                    _delete(bill);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 19,
                        ),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // STATUS
          // ----------------------------------------------------

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _badge(
                payment.toUpperCase(),
                _paymentColor(payment),
              ),
              _badge(
                rental == 'returned'
                    ? 'RETURNED'
                    : 'RENTED',
                rental == 'returned'
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // ITEMS
          // ----------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: border,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: bronzeLight,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: bronzeDark,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rental Items',
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedText,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _itemsText(d),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: darkBrown,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // AMOUNTS
          // ----------------------------------------------------

          LayoutBuilder(
            builder: (context, c) {
              final amountWidth =
                  (c.maxWidth - 14) / 3;

              if (amountWidth < 100) {
                return Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    SizedBox(
                      width: (c.maxWidth - 7) / 2,
                      child: _smallAmount(
                        'Total',
                        d['totalAmount'],
                        bronzeDark,
                      ),
                    ),
                    SizedBox(
                      width: (c.maxWidth - 7) / 2,
                      child: _smallAmount(
                        'Paid',
                        d['paidAmount'],
                        Colors.green.shade700,
                      ),
                    ),
                    SizedBox(
                      width: c.maxWidth,
                      child: _smallAmount(
                        'Remaining',
                        d['remainingAmount'],
                        payment == 'paid'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _smallAmount(
                      'Total',
                      d['totalAmount'],
                      bronzeDark,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _smallAmount(
                      'Paid',
                      d['paidAmount'],
                      Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _smallAmount(
                      'Remaining',
                      d['remainingAmount'],
                      payment == 'paid'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // MAIN ACTIONS
          // ----------------------------------------------------

          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 430) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _billView(d),
                        icon: const Icon(
                          Icons.receipt_long_outlined,
                          size: 19,
                        ),
                        label:
                            const Text('View Bill'),
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor: bronzeDark,
                          side: const BorderSide(
                            color: bronzeLight,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: payment == 'paid'
                          ? OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(
                                Icons.lock_outline,
                                size: 18,
                              ),
                              label:
                                  const Text('Paid'),
                            )
                          : ElevatedButton.icon(
                              onPressed: () =>
                                  _markPaid(bill),
                              icon: const Icon(
                                Icons
                                    .check_circle_outline,
                                size: 18,
                              ),
                              label:
                                  const Text('Mark Paid'),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    bronze,
                                foregroundColor:
                                    Colors.white,
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _billView(d),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        size: 19,
                      ),
                      label: const Text('View Bill'),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor: bronzeDark,
                        side: const BorderSide(
                          color: bronzeLight,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: payment == 'paid'
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(
                              Icons.lock_outline,
                              size: 18,
                            ),
                            label:
                                const Text('Paid'),
                          )
                        : ElevatedButton.icon(
                            onPressed: () =>
                                _markPaid(bill),
                            icon: const Icon(
                              Icons
                                  .check_circle_outline,
                              size: 18,
                            ),
                            label:
                                const Text('Mark Paid'),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  bronze,
                              foregroundColor:
                                  Colors.white,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // ----------------------------------------------------
          // RETURN BUTTON
          // ----------------------------------------------------

          if (rental != 'returned')
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _returnItems(bill),
                icon: const Icon(
                  Icons.assignment_return_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Mark Rental Items Returned',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: bronzeDark,
                  side: const BorderSide(
                    color: bronzeLight,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color:
                    Colors.green.withOpacity(.06),
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Colors.green.withOpacity(.18),
                ),
              ),
              child: Text(
                payment == 'paid'
                    ? '✓ Rental returned & payment cleared'
                    : '✓ Rental returned • payment still pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 9),

          // ----------------------------------------------------
          // RENTAL DATES
          // ----------------------------------------------------

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: mutedText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Rental: ${_date(d['dateFrom'])} → ${_date(d['dateTill'])}',
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallAmount(
    String title,
    dynamic value,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(.10),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _rs(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: surface,
        foregroundColor: darkBrown,
        titleSpacing: screenWidth < 400 ? 8 : 16,
        title: Text(
          'Customer Management',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth < 400 ? 18 : 20,
            color: darkBrown,
          ),
        ),
      ),

      drawer: const AdminDrawer(
        selectedIndex: 2,
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _db
            .collection('bills')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),

        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: border,
                    ),
                  ),
                  child: Text(
                    'Could not load customers.\n\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: mediumBrown,
                    ),
                  ),
                ),
              ),
            );
          }

          if (snap.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: bronze,
              ),
            );
          }

          final all = snap.data?.docs ?? [];

          final searchText =
              _search.text.trim().toLowerCase();

          final filtered = all.where((b) {
            final name =
                _s(b.data()['customerName'])
                    .toLowerCase();

            return name.contains(searchText);
          }).toList();

          final current = filtered
              .where((b) => !_cleared(b.data()))
              .toList();

          final cleared = filtered
              .where((b) => _cleared(b.data()))
              .toList();

          final shown =
              _tab == 0 ? current : cleared;

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1150,
              ),
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      screenWidth < 400 ? 12 : 20,
                  vertical:
                      screenWidth < 400 ? 14 : 20,
                ),
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customers',
                              style: TextStyle(
                                fontSize:
                                    screenWidth < 400
                                        ? 23
                                        : 28,
                                fontWeight:
                                    FontWeight.bold,
                                color: darkBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Manage rentals, payments and customer records.',
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                color: mutedText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SUMMARY
                  // ==================================================

                  LayoutBuilder(
                    builder: (context, c) {
                      final cards = [
                        _summary(
                          'Customers / Rentals',
                          '${all.length}',
                          Icons.people_outline,
                          bronze,
                        ),
                        _summary(
                          'Current / Pending',
                          '${current.length}',
                          Icons.pending_actions_outlined,
                          Colors.orange.shade700,
                        ),
                        _summary(
                          'Cleared / Returned',
                          '${cleared.length}',
                          Icons.verified_outlined,
                          Colors.green.shade700,
                        ),
                      ];

                      if (c.maxWidth < 650) {
                        return Column(
                          children: [
                            cards[0],
                            const SizedBox(height: 9),
                            cards[1],
                            const SizedBox(height: 9),
                            cards[2],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: cards[0],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: cards[1],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: cards[2],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // SEARCH
                  // ==================================================

                  Container(
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: border,
                      ),
                    ),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) {
                        setState(() {});
                      },
                      style: const TextStyle(
                        color: darkBrown,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search customer by name...',
                        hintStyle: const TextStyle(
                          color: mutedText,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: bronze,
                        ),
                        suffixIcon:
                            _search.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _search.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                      color: mutedText,
                                    ),
                                  ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // TABS
                  // ==================================================

                  LayoutBuilder(
                    builder: (context, c) {
                      final a = _tabButton(
                        'Current / Pending',
                        0,
                        current.length,
                        Icons.pending_actions_outlined,
                      );

                      final b = _tabButton(
                        'Cleared / Returned',
                        1,
                        cleared.length,
                        Icons.verified_outlined,
                      );

                      if (c.maxWidth < 600) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: a,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: b,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          a,
                          const SizedBox(width: 10),
                          b,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SECTION TITLE
                  // ==================================================

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: bronze,
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _tab == 0
                              ? 'Current / Pending Clearance'
                              : 'Cleared / Returned',
                          style: TextStyle(
                            fontSize:
                                screenWidth < 400
                                    ? 18
                                    : 20,
                            fontWeight:
                                FontWeight.bold,
                            color: darkBrown,
                          ),
                        ),
                      ),
                      Text(
                        '${shown.length}',
                        style: const TextStyle(
                          color: mutedText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  // ==================================================
                  // EMPTY STATE
                  // ==================================================

                  if (shown.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        screenWidth < 400
                            ? 32
                            : 45,
                      ),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius:
                            BorderRadius.circular(17),
                        border: Border.all(
                          color: border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: bronzeLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _tab == 0
                                  ? Icons
                                      .assignment_turned_in_outlined
                                  : Icons
                                      .verified_outlined,
                              size: 31,
                              color: bronzeDark,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            _tab == 0
                                ? 'No current or pending customers'
                                : 'No cleared customers yet',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Customer records will appear here automatically.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...shown.map(_card),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}