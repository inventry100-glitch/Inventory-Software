// import 'dart:io';
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});

//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }

// class _BillScreenState extends State<BillScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController =
//       TextEditingController();

//   final TextEditingController _cnicController =
//       TextEditingController();

//   DateTime? _dateFrom;
//   DateTime? _dateTill;

//   final List<RentedItem> _rentedItems = [];

//   bool _isGenerating = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cnicController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // CNIC FORMAT
//   // ============================================================

//   void _formatCnic(String value) {
//     String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     // Maximum 16 digits
//     if (digits.length > 16) {
//       digits = digits.substring(0, 16);
//     }

//     String formatted = '';

//     for (int i = 0; i < digits.length; i++) {
//       if (i == 5 || i == 10) {
//         formatted += '-';
//       }

//       formatted += digits[i];
//     }

//     _cnicController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(
//         offset: formatted.length,
//       ),
//     );

//     setState(() {});
//   }

//   // ============================================================
//   // DATE PICKER
//   // ============================================================

//   Future<void> _selectDate({
//     required bool isFrom,
//   }) async {
//     final DateTime initialDate =
//         isFrom
//             ? (_dateFrom ?? DateTime.now())
//             : (_dateTill ?? _dateFrom ?? DateTime.now());

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );

//     if (picked == null) {
//       return;
//     }

//     setState(() {
//       if (isFrom) {
//         _dateFrom = picked;

//         // If till date was before from date,
//         // reset till date.
//         if (_dateTill != null &&
//             _dateTill!.isBefore(picked)) {
//           _dateTill = null;
//         }
//       } else {
//         if (_dateFrom != null &&
//             picked.isBefore(_dateFrom!)) {
//           _showMessage(
//             'Date Till cannot be before Date From.',
//           );
//           return;
//         }

//         _dateTill = picked;
//       }
//     });
//   }

//   // ============================================================
//   // ADD ITEM MODAL
//   // ============================================================

//   Future<void> _showAddItemModal() async {
//     String? selectedItemId;

//     int selectedAvailableStock = 0;

//     final TextEditingController quantityController =
//         TextEditingController();

//     bool isAdding = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (
//             context,
//             setDialogState,
//           ) {
//             return AlertDialog(
//               title: const Row(
//                 children: [
//                   Icon(
//                     Icons.add_shopping_cart,
//                     color: Colors.blue,
//                   ),
//                   SizedBox(width: 10),
//                   Text(
//                     'Add Renting Item',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),

//               content: SizedBox(
//                 width: 500,

//                 child: StreamBuilder<
//                     QuerySnapshot<
//                         Map<String, dynamic>>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('inventory')
//                       .orderBy('name')
//                       .snapshots(),

//                   builder: (
//                     context,
//                     snapshot,
//                   ) {
//                     if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const SizedBox(
//                         height: 120,
//                         child: Center(
//                           child:
//                               CircularProgressIndicator(),
//                         ),
//                       );
//                     }

//                     if (snapshot.hasError) {
//                       return const Padding(
//                         padding:
//                             EdgeInsets.all(20),
//                         child: Text(
//                           'Unable to load inventory.',
//                         ),
//                       );
//                     }

//                     final documents =
//                         snapshot.data?.docs ?? [];

//                     if (documents.isEmpty) {
//                       return const Padding(
//                         padding:
//                             EdgeInsets.all(20),
//                         child: Text(
//                           'No inventory items found.',
//                         ),
//                       );
//                     }

//                     // ------------------------------------------------
//                     // Calculate stock while excluding quantities
//                     // already added to this bill.
//                     // ------------------------------------------------

//                     int getRemainingStock(
//                       QueryDocumentSnapshot<
//                               Map<String, dynamic>>
//                           document,
//                     ) {
//                       final data =
//                           document.data();

//                       final available =
//                           (data['availableStock']
//                                   as num?)
//                               ?.toInt() ??
//                           0;

//                       final alreadyAdded =
//                           _getAlreadyAddedQuantity(
//                         document.id,
//                       );

//                       return available -
//                           alreadyAdded;
//                     }

//                     // Selected item's latest available stock
//                     if (selectedItemId != null) {
//                       final selectedDocument =
//                           documents
//                               .where(
//                                 (doc) =>
//                                     doc.id ==
//                                     selectedItemId,
//                               )
//                               .firstOrNull;

//                       if (selectedDocument !=
//                           null) {
//                         selectedAvailableStock =
//                             getRemainingStock(
//                           selectedDocument,
//                         );
//                       }
//                     }

//                     return Column(
//                       mainAxisSize:
//                           MainAxisSize.min,
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [

//                         // ============================================
//                         // ITEM DROPDOWN
//                         // ============================================

//                         DropdownButtonFormField<
//                             String>(
//                           value: selectedItemId,

//                           isExpanded: true,

//                           decoration:
//                               _inputDecoration(
//                             label: 'Select Item',
//                             icon:
//                                 Icons.inventory_2_outlined,
//                           ),

//                           items: documents.map(
//                             (document) {
//                               final data =
//                                   document.data();

//                               final String itemName =
//                                   data['name']
//                                           ?.toString() ??
//                                       'Unnamed Item';

//                               final int remaining =
//                                   getRemainingStock(
//                                 document,
//                               );

//                               final bool disabled =
//                                   remaining <= 0;

//                               return DropdownMenuItem<
//                                   String>(
//                                 value: disabled
//                                     ? null
//                                     : document.id,

//                                 enabled: !disabled,

//                                 child: Row(
//                                   children: [

//                                     Icon(
//                                       _getCategoryIcon(
//                                         data['category']
//                                                 ?.toString() ??
//                                             'Other',
//                                       ),
//                                       size: 20,
//                                       color: disabled
//                                           ? Colors.grey
//                                           : Colors.blue,
//                                     ),

//                                     const SizedBox(
//                                       width: 10,
//                                     ),

//                                     Expanded(
//                                       child: Text(
//                                         itemName,
//                                         overflow:
//                                             TextOverflow
//                                                 .ellipsis,
//                                         style: TextStyle(
//                                           color: disabled
//                                               ? Colors.grey
//                                               : Colors
//                                                   .black87,
//                                         ),
//                                       ),
//                                     ),

//                                     Text(
//                                       disabled
//                                           ? 'Out of stock'
//                                           : '$remaining available',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: disabled
//                                             ? Colors.red
//                                             : Colors.green,
//                                         fontWeight:
//                                             FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ).toList(),

//                           onChanged: (value) {
//                             setDialogState(() {
//                               selectedItemId =
//                                   value;

//                               quantityController
//                                   .clear();

//                               if (value != null) {
//                                 final document =
//                                     documents.firstWhere(
//                                   (doc) =>
//                                       doc.id ==
//                                       value,
//                                 );

//                                 selectedAvailableStock =
//                                     getRemainingStock(
//                                   document,
//                                 );
//                               } else {
//                                 selectedAvailableStock =
//                                     0;
//                               }
//                             });
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // ============================================
//                         // AVAILABLE STOCK INFO
//                         // ============================================

//                         Container(
//                           width: double.infinity,

//                           padding:
//                               const EdgeInsets.all(
//                             13,
//                           ),

//                           decoration:
//                               BoxDecoration(
//                             color: Colors.blue
//                                 .withOpacity(
//                               0.06,
//                             ),
//                             borderRadius:
//                                 BorderRadius.circular(
//                               10,
//                             ),
//                           ),

//                           child: Row(
//                             children: [

//                               const Icon(
//                                 Icons
//                                     .inventory_2_outlined,
//                                 size: 20,
//                                 color: Colors.blue,
//                               ),

//                               const SizedBox(
//                                 width: 10,
//                               ),

//                               const Text(
//                                 'Available Stock:',
//                                 style: TextStyle(
//                                   fontWeight:
//                                       FontWeight.w600,
//                                 ),
//                               ),

//                               const Spacer(),

//                               Text(
//                                 selectedItemId ==
//                                         null
//                                     ? '-'
//                                     : selectedAvailableStock
//                                         .toString(),
//                                 style:
//                                     const TextStyle(
//                                   fontWeight:
//                                       FontWeight.bold,
//                                   fontSize: 17,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 8),

//                         const Text(
//                           'Rented quantity cannot be greater than available stock.',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 12,
//                           ),
//                         ),

//                         const SizedBox(height: 14),

//                         // ============================================
//                         // QUANTITY
//                         // ============================================

//                         TextFormField(
//                           controller:
//                               quantityController,

//                           keyboardType:
//                               TextInputType.number,

//                           decoration:
//                               _inputDecoration(
//                             label:
//                                 'Quantity to Rent',
//                             icon:
//                                 Icons.numbers,
//                           ),

//                           validator: (value) {
//                             return null;
//                           },

//                           onChanged: (_) {
//                             setDialogState(
//                               () {},
//                             );
//                           },
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),

//               actions: [

//                 TextButton(
//                   onPressed: isAdding
//                       ? null
//                       : () {
//                           Navigator.pop(
//                             dialogContext,
//                           );
//                         },
//                   child: const Text(
//                     'Cancel',
//                   ),
//                 ),

//                 ElevatedButton.icon(
//                   onPressed: isAdding
//                       ? null
//                       : () async {
//                           final quantity =
//                               int.tryParse(
//                             quantityController
//                                 .text
//                                 .trim(),
//                           );

//                           if (selectedItemId ==
//                               null) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Please select an item.',
//                             );
//                             return;
//                           }

//                           if (quantity == null ||
//                               quantity <= 0) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Enter a valid quantity.',
//                             );
//                             return;
//                           }

//                           if (quantity >
//                               selectedAvailableStock) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Quantity cannot be greater than available stock.',
//                             );
//                             return;
//                           }

//                           final selectedDocument =
//                               await FirebaseFirestore.instance
//                                   .collection('inventory')
//                                   .doc(selectedItemId)
//                                   .get();

//                           if (!selectedDocument.exists) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Selected inventory item no longer exists.',
//                             );
//                             return;
//                           }

//                           final data = selectedDocument.data() ?? {};

//                           final String itemName =
//                               data['name']
//                                       ?.toString() ??
//                                   'Unnamed Item';

//                           final String category =
//                               data['category']
//                                       ?.toString() ??
//                                   'Other';

//                           final String material =
//                               data['material']
//                                       ?.toString() ??
//                                   'Unknown';

//                           final double rentPrice =
//                               (data['rentPrice']
//                                           as num?)
//                                       ?.toDouble() ??
//                                   0;

//                           setState(() {
//                             final existingIndex =
//                                 _rentedItems.indexWhere(
//                               (item) =>
//                                   item.itemId ==
//                                   selectedItemId,
//                             );

//                             if (existingIndex >=
//                                 0) {
//                               _rentedItems[
//                                       existingIndex]
//                                   .quantity +=
//                                   quantity;
//                             } else {
//                               _rentedItems.add(
//                                 RentedItem(
//                                   itemId:
//                                       selectedItemId!,
//                                   name:
//                                       itemName,
//                                   category:
//                                       category,
//                                   material:
//                                       material,
//                                   quantity:
//                                       quantity,
//                                   rentPrice:
//                                       rentPrice,
//                                 ),
//                               );
//                             }
//                           });

//                           Navigator.pop(
//                             dialogContext,
//                           );
//                         },

//                   icon: const Icon(
//                     Icons.add,
//                   ),

//                   label: const Text(
//                     'Add Item',
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     quantityController.dispose();
//   }

//   // ============================================================
//   // ALREADY ADDED QUANTITY
//   // ============================================================

//   int _getAlreadyAddedQuantity(
//     String itemId,
//   ) {
//     final existing = _rentedItems
//         .where(
//           (item) => item.itemId == itemId,
//         )
//         .toList();

//     if (existing.isEmpty) {
//       return 0;
//     }

//     return existing.first.quantity;
//   }

//   // ============================================================
//   // REMOVE RENTED ITEM
//   // ============================================================

//   void _removeItem(int index) {
//     setState(() {
//       _rentedItems.removeAt(index);
//     });
//   }

//   // ============================================================
//   // TOTAL
//   // ============================================================

//   double get _grandTotal {
//     double total = 0;

//     for (final item in _rentedItems) {
//       total += item.totalPrice;
//     }

//     return total;
//   }

//   // ============================================================
//   // GENERATE BILL
//   // ============================================================

//   Future<void> _generateBill() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_dateFrom == null) {
//       _showMessage(
//         'Please select Date From.',
//       );
//       return;
//     }

//     if (_dateTill == null) {
//       _showMessage(
//         'Please select Date Till.',
//       );
//       return;
//     }

//     if (_rentedItems.isEmpty) {
//       _showMessage(
//         'Please add at least one renting item.',
//       );
//       return;
//     }

//     final cnicDigits =
//         _cnicController.text.replaceAll(
//       RegExp(r'[^0-9]'),
//       '',
//     );

//     if (cnicDigits.length != 16) {
//       _showMessage(
//         'CNIC must contain exactly 16 digits.',
//       );
//       return;
//     }

//     setState(() {
//       _isGenerating = true;
//     });

//     try {
//       final firestore =
//           FirebaseFirestore.instance;

//       final billReference =
//           firestore.collection('bills').doc();

//       final customerReference =
//           firestore.collection('customers').doc();

//       // ==========================================================
//       // TRANSACTION
//       // ==========================================================

//       await firestore.runTransaction(
//         (transaction) async {
//           final List<DocumentSnapshot<
//               Map<String, dynamic>>> inventorySnapshots =
//               [];

//           // Read every inventory item first.
//           for (final rentedItem in _rentedItems) {
//             final reference = firestore
//                 .collection('inventory')
//                 .doc(rentedItem.itemId);

//             final snapshot =
//                 await transaction.get(
//               reference,
//             );

//             inventorySnapshots.add(
//               snapshot,
//             );
//           }

//           // ========================================================
//           // RE-CHECK STOCK
//           // ========================================================

//           for (int i = 0;
//               i < _rentedItems.length;
//               i++) {
//             final rentedItem =
//                 _rentedItems[i];

//             final snapshot =
//                 inventorySnapshots[i];

//             if (!snapshot.exists) {
//               throw Exception(
//                 '${rentedItem.name} no longer exists in inventory.',
//               );
//             }

//             final data =
//                 snapshot.data()!;

//             final available =
//                 (data['availableStock']
//                             as num?)
//                         ?.toInt() ??
//                     0;

//             if (rentedItem.quantity >
//                 available) {
//               throw Exception(
//                 'Only $available units of ${rentedItem.name} are available.',
//               );
//             }
//           }

//           // ========================================================
//           // DEDUCT STOCK
//           // ========================================================

//           for (int i = 0;
//               i < _rentedItems.length;
//               i++) {
//             final rentedItem =
//                 _rentedItems[i];

//             final snapshot =
//                 inventorySnapshots[i];

//             final data =
//                 snapshot.data()!;

//             final currentAvailable =
//                 (data['availableStock']
//                             as num?)
//                         ?.toInt() ??
//                     0;

//             final currentRented =
//                 (data['rentedStock']
//                             as num?)
//                         ?.toInt() ??
//                     0;

//             final newAvailable =
//                 currentAvailable -
//                     rentedItem.quantity;

//             final newRented =
//                 currentRented +
//                     rentedItem.quantity;

//             transaction.update(
//               snapshot.reference,
//               {
//                 'availableStock':
//                     newAvailable,

//                 'rentedStock':
//                     newRented,

//                 'updatedAt':
//                     FieldValue
//                         .serverTimestamp(),
//               },
//             );
//           }

//           // ========================================================
//           // BILL DATA
//           // ========================================================

//           final billItems =
//               _rentedItems.map(
//             (item) {
//               return {
//                 'itemId': item.itemId,
//                 'name': item.name,
//                 'category': item.category,
//                 'material': item.material,
//                 'quantity': item.quantity,
//                 'rentPrice': item.rentPrice,
//                 'totalPrice': item.totalPrice,
//               };
//             },
//           ).toList();

//           transaction.set(
//             billReference,
//             {
//               'billId': billReference.id,

//               'customerName':
//                   _nameController.text.trim(),

//               'cnic':
//                   _cnicController.text.trim(),

//               'dateFrom':
//                   Timestamp.fromDate(
//                 _dateFrom!,
//               ),

//               'dateTill':
//                   Timestamp.fromDate(
//                 _dateTill!,
//               ),

//               'items': billItems,

//               'totalAmount':
//                   _grandTotal,

//               'status': 'active',

//               'createdAt':
//                   FieldValue
//                       .serverTimestamp(),

//               'updatedAt':
//                   FieldValue
//                       .serverTimestamp(),
//             },
//           );

//           // ========================================================
//           // CUSTOMER DATA
//           // ========================================================

//           transaction.set(
//             customerReference,
//             {
//               'name':
//                   _nameController.text.trim(),

//               'cnic':
//                   _cnicController.text.trim(),

//               'lastBillId':
//                   billReference.id,

//               'lastRentalFrom':
//                   Timestamp.fromDate(
//                 _dateFrom!,
//               ),

//               'lastRentalTill':
//                   Timestamp.fromDate(
//                 _dateTill!,
//               ),

//               'createdAt':
//                   FieldValue
//                       .serverTimestamp(),

//               'updatedAt':
//                   FieldValue
//                       .serverTimestamp(),
//             },
//           );
//         },
//       );

//       if (!mounted) return;

//       // ==========================================================
//       // CREATE PDF
//       // ==========================================================

//       final pdf = await _buildBillPdf(
//         billId: billReference.id,
//       );

//       // Open bill preview.
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BillPreviewScreen(
//             pdfBytes: pdf,
//             billId: billReference.id,
//             customerName:
//                 _nameController.text.trim(),
//           ),
//         ),
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Bill generated and stock updated successfully.',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Clear the form after successful bill.
//       _nameController.clear();
//       _cnicController.clear();

//       setState(() {
//         _dateFrom = null;
//         _dateTill = null;
//         _rentedItems.clear();
//       });
//     } catch (e) {
//       if (!mounted) return;

//       String message = e.toString();

//       if (message.startsWith(
//         'Exception: ',
//       )) {
//         message = message.substring(
//           11,
//         );
//       }

//       _showMessage(
//         'Bill could not be generated: $message',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isGenerating = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BUILD PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf({
//     required String billId,
//   }) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,

//         margin: const pw.EdgeInsets.all(
//           32,
//         ),

//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment:
//                 pw.CrossAxisAlignment.start,

//             children: [

//               // ======================================================
//               // HEADER
//               // ======================================================

//               pw.Row(
//                 mainAxisAlignment:
//                     pw.MainAxisAlignment
//                         .spaceBetween,

//                 children: [
//                   pw.Column(
//                     crossAxisAlignment:
//                         pw.CrossAxisAlignment
//                             .start,

//                     children: [
//                       pw.Text(
//                         'RENTAL BILL',
//                         style: pw.TextStyle(
//                           fontSize: 25,
//                           fontWeight:
//                               pw.FontWeight.bold,
//                         ),
//                       ),

//                       pw.SizedBox(
//                         height: 5,
//                       ),

//                       pw.Text(
//                         'Inventory Management',
//                         style: const pw.TextStyle(
//                           fontSize: 11,
//                           color:
//                               PdfColors.grey700,
//                         ),
//                       ),
//                     ],
//                   ),

//                   pw.Container(
//                     padding:
//                         const pw.EdgeInsets.all(
//                       10,
//                     ),

//                     decoration:
//                         pw.BoxDecoration(
//                       border: pw.Border.all(
//                         color:
//                             PdfColors.grey400,
//                       ),
//                     ),

//                     child: pw.Column(
//                       crossAxisAlignment:
//                           pw.CrossAxisAlignment
//                               .end,

//                       children: [
//                         pw.Text(
//                           'Bill #',
//                           style:
//                               const pw.TextStyle(
//                             fontSize: 9,
//                           ),
//                         ),

//                         pw.SizedBox(
//                           height: 3,
//                         ),

//                         pw.Text(
//                           billId
//                               .substring(
//                             0,
//                             8,
//                           )
//                               .toUpperCase(),
//                           style:
//                               pw.TextStyle(
//                             fontWeight:
//                                 pw.FontWeight
//                                     .bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               pw.SizedBox(
//                 height: 25,
//               ),

//               pw.Divider(),

//               pw.SizedBox(
//                 height: 15,
//               ),

//               // ======================================================
//               // CUSTOMER
//               // ======================================================

//               pw.Text(
//                 'CUSTOMER DETAILS',
//                 style: pw.TextStyle(
//                   fontSize: 13,
//                   fontWeight:
//                       pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(
//                 height: 10,
//               ),

//               pw.Row(
//                 children: [
//                   pw.Expanded(
//                     child: pw.Text(
//                       'Name: ${_nameController.text.trim()}',
//                     ),
//                   ),

//                   pw.Expanded(
//                     child: pw.Text(
//                       'CNIC: ${_cnicController.text.trim()}',
//                     ),
//                   ),
//                 ],
//               ),

//               pw.SizedBox(
//                 height: 8,
//               ),

//               pw.Row(
//                 children: [
//                   pw.Expanded(
//                     child: pw.Text(
//                       'Date From: ${_formatDate(_dateFrom!)}',
//                     ),
//                   ),

//                   pw.Expanded(
//                     child: pw.Text(
//                       'Date Till: ${_formatDate(_dateTill!)}',
//                     ),
//                   ),
//                 ],
//               ),

//               pw.SizedBox(
//                 height: 25,
//               ),

//               // ======================================================
//               // ITEMS TABLE
//               // ======================================================

//               pw.Text(
//                 'RENTED ITEMS',
//                 style: pw.TextStyle(
//                   fontSize: 13,
//                   fontWeight:
//                       pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(
//                 height: 10,
//               ),

//               pw.Table(
//                 border: pw.TableBorder.all(
//                   color:
//                       PdfColors.grey400,
//                 ),

//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(
//                     3,
//                   ),
//                   1: const pw.FlexColumnWidth(
//                     1.2,
//                   ),
//                   2: const pw.FlexColumnWidth(
//                     1.5,
//                   ),
//                   3: const pw.FlexColumnWidth(
//                     1.5,
//                   ),
//                 },

//                 children: [
//                   pw.TableRow(
//                     decoration:
//                         const pw.BoxDecoration(
//                       color:
//                           PdfColors.grey200,
//                     ),

//                     children: [
//                       _pdfCell(
//                         'Item',
//                         bold: true,
//                       ),

//                       _pdfCell(
//                         'Qty',
//                         bold: true,
//                       ),

//                       _pdfCell(
//                         'Rate',
//                         bold: true,
//                       ),

//                       _pdfCell(
//                         'Amount',
//                         bold: true,
//                       ),
//                     ],
//                   ),

//                   ..._rentedItems.map(
//                     (item) {
//                       return pw.TableRow(
//                         children: [
//                           _pdfCell(
//                             item.name,
//                           ),

//                           _pdfCell(
//                             item.quantity
//                                 .toString(),
//                           ),

//                           _pdfCell(
//                             'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                           ),

//                           _pdfCell(
//                             'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),

//               pw.SizedBox(
//                 height: 25,
//               ),

//               // ======================================================
//               // TOTAL
//               // ======================================================

//               pw.Align(
//                 alignment:
//                     pw.Alignment.centerRight,

//                 child: pw.Container(
//                   width: 220,

//                   padding:
//                       const pw.EdgeInsets.all(
//                     12,
//                   ),

//                   decoration:
//                       pw.BoxDecoration(
//                     border: pw.Border.all(
//                       color:
//                           PdfColors.grey400,
//                     ),
//                   ),

//                   child: pw.Row(
//                     mainAxisAlignment:
//                         pw.MainAxisAlignment
//                             .spaceBetween,

//                     children: [
//                       pw.Text(
//                         'TOTAL',
//                         style: pw.TextStyle(
//                           fontWeight:
//                               pw.FontWeight
//                                   .bold,
//                           fontSize: 14,
//                         ),
//                       ),

//                       pw.Text(
//                         'Rs. ${_grandTotal.toStringAsFixed(0)}',
//                         style: pw.TextStyle(
//                           fontWeight:
//                               pw.FontWeight
//                                   .bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               pw.Spacer(),

//               pw.Divider(),

//               pw.SizedBox(
//                 height: 8,
//               ),

//               pw.Center(
//                 child: pw.Text(
//                   'Thank you for your business.',
//                   style:
//                       const pw.TextStyle(
//                     fontSize: 10,
//                     color:
//                         PdfColors.grey600,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   // ============================================================
//   // PDF CELL
//   // ============================================================

//   pw.Widget _pdfCell(
//     String text, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.all(8),

//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 10,
//           fontWeight: bold
//               ? pw.FontWeight.bold
//               : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ITEM CARD
//   // ============================================================

//   Widget _rentedItemCard(
//     RentedItem item,
//     int index,
//   ) {
//     return Container(
//       margin:
//           const EdgeInsets.only(bottom: 10),

//       padding:
//           const EdgeInsets.all(14),

//       decoration: BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(12),

//         border: Border.all(
//           color: Colors.grey.shade200,
//         ),
//       ),

//       child: Row(
//         children: [

//           // ICON
//           Container(
//             width: 50,
//             height: 50,

//             decoration: BoxDecoration(
//               color:
//                   Colors.blue.withOpacity(
//                 0.08,
//               ),
//               borderRadius:
//                   BorderRadius.circular(
//                 10,
//               ),
//             ),

//             child: Icon(
//               _getCategoryIcon(
//                 item.category,
//               ),
//               color: Colors.blue,
//               size: 27,
//             ),
//           ),

//           const SizedBox(
//             width: 14,
//           ),

//           // ITEM NAME
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,

//               children: [

//                 Text(
//                   item.name,
//                   style:
//                       const TextStyle(
//                     fontSize: 16,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(
//                   height: 5,
//                 ),

//                 Text(
//                   'Material: ${item.material}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // QUANTITY
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),

//             decoration: BoxDecoration(
//               color: Colors.orange
//                   .withOpacity(
//                 0.08,
//               ),

//               borderRadius:
//                   BorderRadius.circular(
//                 8,
//               ),
//             ),

//             child: Column(
//               children: [
//                 Text(
//                   'Quantity',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),

//                 const SizedBox(
//                   height: 2,
//                 ),

//                 Text(
//                   item.quantity.toString(),
//                   style:
//                       const TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(
//             width: 16,
//           ),

//           // AMOUNT
//           SizedBox(
//             width: 100,

//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.end,

//               children: [
//                 Text(
//                   'Amount',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color:
//                         Colors.grey.shade600,
//                   ),
//                 ),

//                 const SizedBox(
//                   height: 3,
//                 ),

//                 Text(
//                   'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                   style:
//                       const TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // REMOVE
//           IconButton(
//             tooltip: 'Remove Item',

//             onPressed: () {
//               _removeItem(index);
//             },

//             icon: const Icon(
//               Icons.close,
//               color: Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY ICON
//   // ============================================================

//   IconData _getCategoryIcon(
//     String category,
//   ) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair_outlined;

//       case 'Decoration':
//         return Icons.auto_awesome_outlined;

//       case 'Tent':
//         return Icons.house_outlined;

//       case 'Lighting':
//         return Icons.lightbulb_outline;

//       case 'Sound Equipment':
//         return Icons.speaker_outlined;

//       case 'Stage Equipment':
//         return Icons.theater_comedy_outlined;

//       case 'Catering':
//         return Icons.restaurant_outlined;

//       default:
//         return Icons.inventory_2_outlined;
//     }
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,

//       prefixIcon: Icon(icon),

//       filled: true,
//       fillColor: Colors.white,

//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),

//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),

//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide:
//             const BorderSide(
//           color: Colors.blue,
//           width: 2,
//         ),
//       ),

//       errorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//         borderSide:
//             const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DATE TEXT
//   // ============================================================

//   String _formatDate(
//     DateTime date,
//   ) {
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   // ============================================================
//   // DATE FIELD
//   // ============================================================

//   Widget _dateField({
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,

//         borderRadius:
//             BorderRadius.circular(12),

//         child: Container(
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 15,
//           ),

//           decoration: BoxDecoration(
//             color: Colors.white,

//             borderRadius:
//                 BorderRadius.circular(12),

//             border: Border.all(
//               color: Colors.grey.shade200,
//             ),
//           ),

//           child: Row(
//             children: [

//               const Icon(
//                 Icons.calendar_month_outlined,
//                 color: Colors.blue,
//               ),

//               const SizedBox(
//                 width: 12,
//               ),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color:
//                             Colors.grey.shade600,
//                       ),
//                     ),

//                     const SizedBox(
//                       height: 3,
//                     ),

//                     Text(
//                       date == null
//                           ? 'Select date'
//                           : _formatDate(
//                               date,
//                             ),

//                       style:
//                           const TextStyle(
//                         fontSize: 14,
//                         fontWeight:
//                             FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(
//     String title,
//   ) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight:
//             FontWeight.bold,
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   void _showDialogMessage(
//     BuildContext context,
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF5F7FA),

//       appBar: AppBar(
//         backgroundColor:
//             Colors.white,

//         foregroundColor:
//             Colors.black87,

//         elevation: 0,

//         title: const Text(
//           'Create New Bill',
//           style: TextStyle(
//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//       ),

//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding:
//                 const EdgeInsets.all(24),

//             child: ConstrainedBox(
//               constraints:
//                   const BoxConstraints(
//                 maxWidth: 800,
//               ),

//               child: Form(
//                 key: _formKey,

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [

//                     // ==================================================
//                     // HEADER
//                     // ==================================================

//                     Row(
//                       children: [

//                         Container(
//                           width: 55,
//                           height: 55,

//                           decoration:
//                               BoxDecoration(
//                             color: Colors.blue
//                                 .withOpacity(
//                               0.1,
//                             ),
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               14,
//                             ),
//                           ),

//                           child: const Icon(
//                             Icons
//                                 .receipt_long_outlined,
//                             color: Colors.blue,
//                             size: 30,
//                           ),
//                         ),

//                         const SizedBox(
//                           width: 15,
//                         ),

//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment
//                                     .start,

//                             children: [
//                               Text(
//                                 'New Rental Bill',
//                                 style:
//                                     TextStyle(
//                                   fontSize: 24,
//                                   fontWeight:
//                                       FontWeight
//                                           .bold,
//                                 ),
//                               ),

//                               SizedBox(
//                                 height: 4,
//                               ),

//                               Text(
//                                 'Create a rental bill and update inventory stock.',
//                                 style:
//                                     TextStyle(
//                                   color:
//                                       Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(
//                       height: 30,
//                     ),

//                     // ==================================================
//                     // CUSTOMER DETAILS
//                     // ==================================================

//                     _sectionTitle(
//                       'Customer Details',
//                     ),

//                     const SizedBox(
//                       height: 12,
//                     ),

//                     TextFormField(
//                       controller:
//                           _nameController,

//                       textCapitalization:
//                           TextCapitalization
//                               .words,

//                       decoration:
//                           _inputDecoration(
//                         label:
//                             'Customer Name',
//                         icon: Icons
//                             .person_outline,
//                       ),

//                       validator: (value) {
//                         if (value == null ||
//                             value
//                                 .trim()
//                                 .isEmpty) {
//                           return 'Please enter customer name.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(
//                       height: 16,
//                     ),

//                     TextFormField(
//                       controller:
//                           _cnicController,

//                       keyboardType:
//                           TextInputType
//                               .number,

//                       onChanged:
//                           _formatCnic,

//                       decoration:
//                           _inputDecoration(
//                         label: 'CNIC #',
//                         icon: Icons
//                             .badge_outlined,
//                       ).copyWith(
//                         hintText:
//                             'XXXXX-XXXXX-XXXXXX',
//                       ),

//                       validator: (value) {
//                         final digits =
//                             (value ?? '')
//                                 .replaceAll(
//                           RegExp(
//                               r'[^0-9]'),
//                           '',
//                         );

//                         if (digits.length !=
//                             16) {
//                           return 'CNIC must contain exactly 16 digits.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(
//                       height: 30,
//                     ),

//                     // ==================================================
//                     // RENTAL DATES
//                     // ==================================================

//                     _sectionTitle(
//                       'Rental Period',
//                     ),

//                     const SizedBox(
//                       height: 12,
//                     ),

//                     Row(
//                       children: [

//                         _dateField(
//                           title:
//                               'Date From',
//                           date: _dateFrom,
//                           onTap: () {
//                             _selectDate(
//                               isFrom: true,
//                             );
//                           },
//                         ),

//                         const SizedBox(
//                           width: 12,
//                         ),

//                         _dateField(
//                           title:
//                               'Date Till',
//                           date: _dateTill,
//                           onTap: () {
//                             _selectDate(
//                               isFrom: false,
//                             );
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(
//                       height: 30,
//                     ),

//                     // ==================================================
//                     // RENTING ITEMS
//                     // ==================================================

//                     Row(
//                       children: [

//                         Expanded(
//                           child: _sectionTitle(
//                             'Renting Items',
//                           ),
//                         ),

//                         ElevatedButton
//                             .icon(
//                           onPressed:
//                               _showAddItemModal,

//                           icon:
//                               const Icon(
//                             Icons.add,
//                           ),

//                           label:
//                               const Text(
//                             'Add Item',
//                           ),

//                           style:
//                               ElevatedButton
//                                   .styleFrom(
//                             backgroundColor:
//                                 Colors.blue,
//                             foregroundColor:
//                                 Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(
//                       height: 12,
//                     ),

//                     // ==================================================
//                     // RENTED ITEMS
//                     // ==================================================

//                     if (_rentedItems
//                         .isEmpty)
//                       Container(
//                         width:
//                             double.infinity,

//                         padding:
//                             const EdgeInsets
//                                 .symmetric(
//                           vertical: 30,
//                           horizontal: 20,
//                         ),

//                         decoration:
//                             BoxDecoration(
//                           color: Colors.white,

//                           borderRadius:
//                               BorderRadius
//                                   .circular(
//                             12,
//                           ),

//                           border:
//                               Border.all(
//                             color: Colors
//                                 .grey
//                                 .shade200,
//                           ),
//                         ),

//                         child: Column(
//                           children: [

//                             Icon(
//                               Icons
//                                   .shopping_cart_outlined,
//                               size: 40,
//                               color: Colors
//                                   .grey
//                                   .shade400,
//                             ),

//                             const SizedBox(
//                               height: 10,
//                             ),

//                             const Text(
//                               'No renting items added.',
//                               style:
//                                   TextStyle(
//                                 fontWeight:
//                                     FontWeight
//                                         .w600,
//                               ),
//                             ),

//                             const SizedBox(
//                               height: 5,
//                             ),

//                             const Text(
//                               'Click "Add Item" to select inventory items.',
//                               style:
//                                   TextStyle(
//                                 color:
//                                     Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       Column(
//                         children:
//                             List.generate(
//                           _rentedItems
//                               .length,
//                           (index) {
//                             return _rentedItemCard(
//                               _rentedItems[
//                                   index],
//                               index,
//                             );
//                           },
//                         ),
//                       ),

//                     const SizedBox(
//                       height: 20,
//                     ),

//                     // ==================================================
//                     // TOTAL
//                     // ==================================================

//                     if (_rentedItems
//                         .isNotEmpty)
//                       Container(
//                         width:
//                             double.infinity,

//                         padding:
//                             const EdgeInsets
//                                 .all(
//                           18,
//                         ),

//                         decoration:
//                             BoxDecoration(
//                           color: Colors.white,

//                           borderRadius:
//                               BorderRadius
//                                   .circular(
//                             12,
//                           ),

//                           border:
//                               Border.all(
//                             color: Colors
//                                 .grey
//                                 .shade200,
//                           ),
//                         ),

//                         child: Row(
//                           children: [

//                             const Icon(
//                               Icons
//                                   .calculate_outlined,
//                               color:
//                                   Colors.blue,
//                             ),

//                             const SizedBox(
//                               width: 10,
//                             ),

//                             const Text(
//                               'Grand Total',
//                               style:
//                                   TextStyle(
//                                 fontSize:
//                                     16,
//                                 fontWeight:
//                                     FontWeight
//                                         .bold,
//                               ),
//                             ),

//                             const Spacer(),

//                             Text(
//                               'Rs. ${_grandTotal.toStringAsFixed(0)}',

//                               style:
//                                   const TextStyle(
//                                 fontSize:
//                                     22,
//                                 fontWeight:
//                                     FontWeight
//                                         .bold,
//                                 color:
//                                     Colors.blue,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                     const SizedBox(
//                       height: 30,
//                     ),

//                     // ==================================================
//                     // GENERATE BILL
//                     // ==================================================

//                     SizedBox(
//                       width:
//                           double.infinity,

//                       height: 56,

//                       child:
//                           ElevatedButton
//                               .icon(
//                         onPressed:
//                             _isGenerating
//                                 ? null
//                                 : _generateBill,

//                         icon:
//                             _isGenerating
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child:
//                                         CircularProgressIndicator(
//                                       strokeWidth:
//                                           2,
//                                       color:
//                                           Colors
//                                               .white,
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons
//                                         .receipt_long,
//                                   ),

//                         label: Text(
//                           _isGenerating
//                               ? 'Generating Bill...'
//                               : 'Generate Bill',
//                           style:
//                               const TextStyle(
//                             fontSize:
//                                 16,
//                             fontWeight:
//                                 FontWeight
//                                     .bold,
//                           ),
//                         ),

//                         style:
//                             ElevatedButton
//                                 .styleFrom(
//                           backgroundColor:
//                               Colors.blue,
//                           foregroundColor:
//                               Colors.white,

//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               12,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==================================================================
// // RENTED ITEM MODEL
// // ==================================================================

// class RentedItem {
//   final String itemId;
//   final String name;
//   final String category;
//   final String material;

//   int quantity;

//   final double rentPrice;

//   RentedItem({
//     required this.itemId,
//     required this.name,
//     required this.category,
//     required this.material,
//     required this.quantity,
//     required this.rentPrice,
//   });

//   double get totalPrice =>
//       quantity * rentPrice;
// }

// // ==================================================================
// // BILL PREVIEW SCREEN
// // ==================================================================

// class BillPreviewScreen extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billId;
//   final String customerName;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billId,
//     required this.customerName,
//   });

//   // ...

//   // ============================================================
//   // SAVE PDF TO DEVICE
//   // ============================================================

//   Future<void> _savePdf(
//     BuildContext context,
//   ) async {
//     try {
//       final directory =
//           await getApplicationDocumentsDirectory();

//       final file = File(
//         '${directory.path}/Bill_${billId.substring(0, 8).toUpperCase()}.pdf',
//       );

//       await file.writeAsBytes(
//         pdfBytes,
//         flush: true,
//       );

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         SnackBar(
//           content: Text(
//             'Bill saved successfully:\n${file.path}',
//           ),
//           backgroundColor:
//               Colors.green,
//           duration:
//               const Duration(
//             seconds: 4,
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context)
//           .showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Unable to save PDF.',
//           ),
//           backgroundColor:
//               Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Bill Preview',
//         ),

//         actions: [

//           // ========================================================
//           // SAVE ICON
//           // ========================================================

//           IconButton(
//             tooltip:
//                 'Save Bill',

//             onPressed: () {
//               _savePdf(context);
//             },

//             icon: const Icon(
//               Icons.save_outlined,
//             ),
//           ),

//           // ========================================================
//           // SHARE / PRINT
//           // ========================================================

//           IconButton(
//             tooltip:
//                 'Print / Share',

//             onPressed: () async {
//               await Printing.sharePdf(
//                 bytes:
//                     pdfBytes,
//                 filename:
//                     'Bill_${billId.substring(0, 8).toUpperCase()}.pdf',
//               );
//             },

//             icon: const Icon(
//               Icons.print_outlined,
//             ),
//           ),
//         ],
//       ),

//       body: PdfPreview(
//         build: (format) async {
//           return pdfBytes;
//         },

//         canChangePageFormat:
//             false,

//         canChangeOrientation:
//             false,

//         allowPrinting: true,

//         allowSharing: true,

//         pdfFileName:
//             'Bill_${billId.substring(0, 8).toUpperCase()}.pdf',
//       ),
//     );
//   }
// }

// import 'dart:math';

// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});

//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }

// class _BillScreenState extends State<BillScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();

//   final TextEditingController _cnicController = TextEditingController();

//   final TextEditingController _contactController = TextEditingController();

//   final TextEditingController _discountController = TextEditingController(
//     text: '0',
//   );

//   final TextEditingController _paidController = TextEditingController(
//     text: '0',
//   );

//   DateTime? _dateFrom;
//   DateTime? _dateTill;

//   final List<RentedItem> _rentedItems = [];

//   bool _isGenerating = false;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cnicController.dispose();
//     _contactController.dispose();
//     _discountController.dispose();
//     _paidController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // CNIC FORMAT
//   // ============================================================

//   void _formatCnic(String value) {
//     String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 16) {
//       digits = digits.substring(0, 16);
//     }

//     String formatted = '';

//     for (int i = 0; i < digits.length; i++) {
//       if (i == 5 || i == 10) {
//         formatted += '-';
//       }

//       formatted += digits[i];
//     }

//     _cnicController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // CONTACT FORMAT
//   // ============================================================

//   void _formatContact(String value) {
//     String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 11) {
//       digits = digits.substring(0, 11);
//     }

//     String formatted = digits;

//     if (digits.length > 4) {
//       formatted = '${digits.substring(0, 4)}-${digits.substring(4)}';
//     }

//     _contactController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // MONEY
//   // ============================================================

//   double _parseMoney(String value) {
//     return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
//   }

//   double get _subtotal {
//     double total = 0;

//     for (final item in _rentedItems) {
//       total += item.totalPrice;
//     }

//     return total;
//   }

//   double get _discount {
//     final entered = _parseMoney(_discountController.text);

//     if (entered < 0) return 0;
//     if (entered > _subtotal) return _subtotal;

//     return entered;
//   }

//   double get _finalTotal {
//     final total = _subtotal - _discount;
//     return total < 0 ? 0 : total;
//   }

//   double get _paidAmount {
//     final entered = _parseMoney(_paidController.text);

//     if (entered < 0) return 0;
//     if (entered > _finalTotal) return _finalTotal;

//     return entered;
//   }

//   double get _remainingAmount {
//     final remaining = _finalTotal - _paidAmount;

//     return remaining < 0 ? 0 : remaining;
//   }

//   String get _paymentStatus {
//     if (_finalTotal <= 0) {
//       return 'paid';
//     }

//     if (_paidAmount <= 0) {
//       return 'unpaid';
//     }

//     if (_paidAmount >= _finalTotal) {
//       return 'paid';
//     }

//     return 'partial';
//   }

//   String _statusTitle(String status) {
//     switch (status) {
//       case 'paid':
//         return 'Paid';
//       case 'partial':
//         return 'Partial';
//       default:
//         return 'Unpaid';
//     }
//   }

//   String _generateBillNumber() {
//     final now = DateTime.now();
//     final random = Random().nextInt(9000) + 1000;

//     return 'RB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
//   }

//   // ============================================================
//   // DATE PICKER
//   // ============================================================

//   Future<void> _selectDate({required bool isFrom}) async {
//     final DateTime initialDate = isFrom
//         ? (_dateFrom ?? DateTime.now())
//         : (_dateTill ?? _dateFrom ?? DateTime.now());

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );

//     if (picked == null) {
//       return;
//     }

//     setState(() {
//       if (isFrom) {
//         _dateFrom = picked;

//         if (_dateTill != null && _dateTill!.isBefore(picked)) {
//           _dateTill = null;
//         }
//       } else {
//         if (_dateFrom != null && picked.isBefore(_dateFrom!)) {
//           _showMessage('Return date cannot be before Date From.');
//           return;
//         }

//         _dateTill = picked;
//       }
//     });
//   }

//   // ============================================================
//   // ADD ITEM MODAL
//   // ============================================================

//   Future<void> _showAddItemModal() async {
//     String? selectedItemId;
//     int selectedAvailableStock = 0;

//     final quantityController = TextEditingController();

//     bool isAdding = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Row(
//                 children: [
//                   Icon(Icons.add_shopping_cart, color: Colors.blue),
//                   SizedBox(width: 10),
//                   Text(
//                     'Add Renting Item',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               content: SizedBox(
//                 width: 500,
//                 child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('inventory')
//                       .orderBy('name')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const SizedBox(
//                         height: 120,
//                         child: Center(child: CircularProgressIndicator()),
//                       );
//                     }

//                     if (snapshot.hasError) {
//                       return const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text('Unable to load inventory.'),
//                       );
//                     }

//                     final documents = snapshot.data?.docs ?? [];

//                     if (documents.isEmpty) {
//                       return const Padding(
//                         padding: EdgeInsets.all(20),
//                         child: Text('No inventory items found.'),
//                       );
//                     }

//                     int getRemainingStock(
//                       QueryDocumentSnapshot<Map<String, dynamic>> document,
//                     ) {
//                       final data = document.data();

//                       final available =
//                           (data['availableStock'] as num?)?.toInt() ?? 0;

//                       final alreadyAdded = _getAlreadyAddedQuantity(
//                         document.id,
//                       );

//                       return available - alreadyAdded;
//                     }

//                     if (selectedItemId != null) {
//                       QueryDocumentSnapshot<Map<String, dynamic>>?
//                       selectedDocument;

//                       for (final document in documents) {
//                         if (document.id == selectedItemId) {
//                           selectedDocument = document;
//                           break;
//                         }
//                       }

//                       if (selectedDocument != null) {
//                         selectedAvailableStock = getRemainingStock(
//                           selectedDocument,
//                         );
//                       }
//                     }

//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         DropdownButtonFormField<String>(
//                           value: selectedItemId,
//                           isExpanded: true,
//                           decoration: _inputDecoration(
//                             label: 'Select Item',
//                             icon: Icons.inventory_2_outlined,
//                           ),
//                           items: documents.map((document) {
//                             final data = document.data();

//                             final itemName =
//                                 data['name']?.toString() ?? 'Unnamed Item';

//                             final remaining = getRemainingStock(document);

//                             final disabled = remaining <= 0;

//                             return DropdownMenuItem<String>(
//                               value: disabled ? null : document.id,
//                               enabled: !disabled,
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     _getCategoryIcon(
//                                       data['category']?.toString() ?? 'Other',
//                                     ),
//                                     size: 20,
//                                     color: disabled ? Colors.grey : Colors.blue,
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: Text(
//                                       itemName,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                         color: disabled
//                                             ? Colors.grey
//                                             : Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     disabled
//                                         ? 'Out of stock'
//                                         : '$remaining available',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: disabled
//                                           ? Colors.red
//                                           : Colors.green,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setDialogState(() {
//                               selectedItemId = value;
//                               quantityController.clear();

//                               if (value == null) {
//                                 selectedAvailableStock = 0;
//                                 return;
//                               }

//                               for (final document in documents) {
//                                 if (document.id == value) {
//                                   selectedAvailableStock = getRemainingStock(
//                                     document,
//                                   );
//                                   break;
//                                 }
//                               }
//                             });
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(13),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.06),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.inventory_2_outlined,
//                                 size: 20,
//                                 color: Colors.blue,
//                               ),
//                               const SizedBox(width: 10),
//                               const Text(
//                                 'Available Stock:',
//                                 style: TextStyle(fontWeight: FontWeight.w600),
//                               ),
//                               const Spacer(),
//                               Text(
//                                 selectedItemId == null
//                                     ? '-'
//                                     : selectedAvailableStock.toString(),
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 17,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 8),

//                         const Text(
//                           'Rented quantity cannot be greater than available stock.',
//                           style: TextStyle(color: Colors.grey, fontSize: 12),
//                         ),

//                         const SizedBox(height: 14),

//                         TextFormField(
//                           controller: quantityController,
//                           keyboardType: TextInputType.number,
//                           decoration: _inputDecoration(
//                             label: 'Quantity to Rent',
//                             icon: Icons.numbers,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAdding
//                       ? null
//                       : () {
//                           Navigator.pop(dialogContext);
//                         },
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: isAdding
//                       ? null
//                       : () async {
//                           final quantity = int.tryParse(
//                             quantityController.text.trim(),
//                           );

//                           if (selectedItemId == null) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Please select an item.',
//                             );
//                             return;
//                           }

//                           if (quantity == null || quantity <= 0) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Enter a valid quantity.',
//                             );
//                             return;
//                           }

//                           if (quantity > selectedAvailableStock) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Quantity cannot be greater than available stock.',
//                             );
//                             return;
//                           }

//                           isAdding = true;
//                           setDialogState(() {});

//                           try {
//                             final selectedDocument = await FirebaseFirestore
//                                 .instance
//                                 .collection('inventory')
//                                 .doc(selectedItemId)
//                                 .get();

//                             if (!selectedDocument.exists) {
//                               _showDialogMessage(
//                                 dialogContext,
//                                 'Selected inventory item no longer exists.',
//                               );
//                               return;
//                             }

//                             final data = selectedDocument.data() ?? {};

//                             final itemName =
//                                 data['name']?.toString() ?? 'Unnamed Item';

//                             final category =
//                                 data['category']?.toString() ?? 'Other';

//                             final material =
//                                 data['material']?.toString() ?? 'Unknown';

//                             final rentPrice =
//                                 (data['rentPrice'] as num?)?.toDouble() ?? 0;

//                             if (!mounted) return;

//                             setState(() {
//                               final existingIndex = _rentedItems.indexWhere(
//                                 (item) => item.itemId == selectedItemId,
//                               );

//                               if (existingIndex >= 0) {
//                                 _rentedItems[existingIndex].quantity +=
//                                     quantity;
//                               } else {
//                                 _rentedItems.add(
//                                   RentedItem(
//                                     itemId: selectedItemId!,
//                                     name: itemName,
//                                     category: category,
//                                     material: material,
//                                     quantity: quantity,
//                                     rentPrice: rentPrice,
//                                   ),
//                                 );
//                               }
//                             });

//                             Navigator.pop(dialogContext);
//                           } finally {
//                             isAdding = false;
//                             if (mounted) {
//                               setDialogState(() {});
//                             }
//                           }
//                         },
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add Item'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     quantityController.dispose();
//   }

//   // ============================================================
//   // ALREADY ADDED QUANTITY
//   // ============================================================

//   int _getAlreadyAddedQuantity(String itemId) {
//     for (final item in _rentedItems) {
//       if (item.itemId == itemId) {
//         return item.quantity;
//       }
//     }

//     return 0;
//   }

//   // ============================================================
//   // REMOVE ITEM
//   // ============================================================

//   void _removeItem(int index) {
//     setState(() {
//       _rentedItems.removeAt(index);
//     });
//   }

//   // ============================================================
//   // GENERATE BILL
//   // ============================================================

//   Future<void> _generateBill() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_dateFrom == null) {
//       _showMessage('Please select Date From.');
//       return;
//     }

//     if (_dateTill == null) {
//       _showMessage('Please select Return Date.');
//       return;
//     }

//     if (_rentedItems.isEmpty) {
//       _showMessage('Please add at least one renting item.');
//       return;
//     }

//     final cnicDigits = _cnicController.text.replaceAll(RegExp(r'[^0-9]'), '');

//     if (cnicDigits.length != 16) {
//       _showMessage('CNIC must contain exactly 16 digits.');
//       return;
//     }

//     final contactDigits = _contactController.text.replaceAll(
//       RegExp(r'[^0-9]'),
//       '',
//     );

//     if (contactDigits.length != 11 || !contactDigits.startsWith('03')) {
//       _showMessage('Contact number must be 11 digits and start with 03.');
//       return;
//     }

//     final subtotal = _subtotal;
//     final discount = _discount;
//     final finalTotal = _finalTotal;
//     final paidAmount = _paidAmount;
//     final remainingAmount = _remainingAmount;
//     final paymentStatus = _paymentStatus;

//     if (discount > subtotal) {
//       _showMessage('Discount cannot be greater than actual amount.');
//       return;
//     }

//     if (paidAmount > finalTotal) {
//       _showMessage('Paid amount cannot be greater than final total.');
//       return;
//     }

//     final billNumber = _generateBillNumber();
//     final generatedAt = DateTime.now();

//     setState(() {
//       _isGenerating = true;
//     });

//     try {
//       final firestore = FirebaseFirestore.instance;

//       final billReference = firestore.collection('bills').doc();

//       final customerReference = firestore.collection('customers').doc();

//       await firestore.runTransaction((transaction) async {
//         final List<DocumentSnapshot<Map<String, dynamic>>> inventorySnapshots =
//             [];

//         // --------------------------------------------------------
//         // READ INVENTORY FIRST
//         // --------------------------------------------------------
//         for (final rentedItem in _rentedItems) {
//           final reference = firestore
//               .collection('inventory')
//               .doc(rentedItem.itemId);

//           final snapshot = await transaction.get(reference);

//           inventorySnapshots.add(snapshot);
//         }

//         // --------------------------------------------------------
//         // RECHECK STOCK
//         // --------------------------------------------------------
//         for (int i = 0; i < _rentedItems.length; i++) {
//           final rentedItem = _rentedItems[i];

//           final snapshot = inventorySnapshots[i];

//           if (!snapshot.exists) {
//             throw Exception(
//               '${rentedItem.name} no longer exists in inventory.',
//             );
//           }

//           final data = snapshot.data() ?? {};

//           final available = (data['availableStock'] as num?)?.toInt() ?? 0;

//           if (rentedItem.quantity > available) {
//             throw Exception(
//               'Only $available units of ${rentedItem.name} are available.',
//             );
//           }
//         }

//         // --------------------------------------------------------
//         // DEDUCT STOCK
//         // --------------------------------------------------------
//         for (int i = 0; i < _rentedItems.length; i++) {
//           final rentedItem = _rentedItems[i];

//           final snapshot = inventorySnapshots[i];

//           final data = snapshot.data() ?? {};

//           final currentAvailable =
//               (data['availableStock'] as num?)?.toInt() ?? 0;

//           final currentRented = (data['rentedStock'] as num?)?.toInt() ?? 0;

//           transaction.update(snapshot.reference, {
//             'availableStock': currentAvailable - rentedItem.quantity,
//             'rentedStock': currentRented + rentedItem.quantity,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         }

//         final billItems = _rentedItems.map((item) {
//           return {
//             'itemId': item.itemId,
//             'name': item.name,
//             'category': item.category,
//             'material': item.material,
//             'quantity': item.quantity,
//             'rentPrice': item.rentPrice,
//             'totalPrice': item.totalPrice,
//           };
//         }).toList();

//         // --------------------------------------------------------
//         // BILL
//         // --------------------------------------------------------
//         transaction.set(billReference, {
//           'billId': billReference.id,
//           'billNumber': billNumber,

//           'customerName': _nameController.text.trim(),

//           'contactNumber': _contactController.text.trim(),

//           'cnic': _cnicController.text.trim(),

//           'dateFrom': Timestamp.fromDate(_dateFrom!),

//           'dateTill': Timestamp.fromDate(_dateTill!),

//           'items': billItems,

//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,

//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,

//           'paymentStatus': paymentStatus,

//           'status': 'active',

//           'createdAt': FieldValue.serverTimestamp(),

//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//         // --------------------------------------------------------
//         // CUSTOMER
//         // --------------------------------------------------------
//         transaction.set(customerReference, {
//           'name': _nameController.text.trim(),

//           'contactNumber': _contactController.text.trim(),

//           'cnic': _cnicController.text.trim(),

//           'lastBillId': billReference.id,

//           'lastBillNumber': billNumber,

//           'lastRentalFrom': Timestamp.fromDate(_dateFrom!),

//           'lastRentalTill': Timestamp.fromDate(_dateTill!),

//           'rentalItems': billItems,

//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,

//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,

//           'paymentStatus': paymentStatus,

//           'createdAt': FieldValue.serverTimestamp(),

//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       });

//       if (!mounted) return;

//       // ------------------------------------------------------------
//       // CREATE PDF
//       // ------------------------------------------------------------
//       final pdf = await _buildBillPdf(
//         billNumber: billNumber,
//         generatedAt: generatedAt,
//       );

//       if (!mounted) return;

//       // await Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) =>
//       //         BillPreviewScreen(
//       //       pdfBytes: pdf,
//       //       billId: billNumber,
//       //       customerName:
//       //           _nameController.text.trim(),
//       //     ),
//       //   ),
//       // );

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BillPreviewScreen(
//             pdfBytes: pdf,
//             billId: billNumber,
//             customerName: _nameController.text.trim(),
//           ),
//         ),
//       );

//       if (!mounted) return;

//       _nameController.clear();
//       _cnicController.clear();
//       _contactController.clear();
//       _discountController.text = '0';
//       _paidController.text = '0';

//       setState(() {
//         _dateFrom = null;
//         _dateTill = null;
//         _rentedItems.clear();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Bill $billNumber generated successfully.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       String message = e.toString();

//       if (message.startsWith('Exception: ')) {
//         message = message.substring(11);
//       }

//       _showMessage('Bill could not be generated: $message');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isGenerating = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf({
//     required String billNumber,
//     required DateTime generatedAt,
//   }) async {
//     final pdf = pw.Document();

//     final status = _paymentStatus;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               // ------------------------------------------------------
//               // HEADER
//               // ------------------------------------------------------
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(18),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'RENTAL BILL',
//                           style: pw.TextStyle(
//                             fontSize: 25,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Text(
//                           'Inventory Management',
//                           style: const pw.TextStyle(
//                             fontSize: 10,
//                             color: PdfColors.grey700,
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(color: PdfColors.grey500),
//                         borderRadius: pw.BorderRadius.circular(8),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text(
//                             'BILL #',
//                             style: const pw.TextStyle(
//                               fontSize: 8,
//                               color: PdfColors.grey700,
//                             ),
//                           ),
//                           pw.SizedBox(height: 3),
//                           pw.Text(
//                             billNumber,
//                             style: pw.TextStyle(
//                               fontSize: 11,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                           pw.SizedBox(height: 4),
//                           pw.Text(
//                             'Generated: ${_formatLongDate(generatedAt)}',
//                             style: const pw.TextStyle(
//                               fontSize: 8,
//                               color: PdfColors.grey700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 18),

//               // ------------------------------------------------------
//               // CUSTOMER
//               // ------------------------------------------------------
//               pw.Text(
//                 'CUSTOMER DETAILS',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(height: 8),

//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(12),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.grey100,
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Name: ${_nameController.text.trim()}',
//                           ),
//                         ),
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Contact: ${_contactController.text.trim()}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 7),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           child: pw.Text(
//                             'CNIC: ${_cnicController.text.trim()}',
//                           ),
//                         ),
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Bill Date: ${_formatLongDate(generatedAt)}',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 18),

//               // ------------------------------------------------------
//               // RENTAL PERIOD
//               // ------------------------------------------------------
//               pw.Text(
//                 'RENTAL PERIOD',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(height: 8),

//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(11),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('From: ${_formatDate(_dateFrom!)}'),
//                     pw.Text('Return: ${_formatDate(_dateTill!)}'),
//                   ],
//                 ),
//               ),

//               pw.SizedBox(height: 18),

//               // ------------------------------------------------------
//               // ITEMS
//               // ------------------------------------------------------
//               pw.Text(
//                 'RENTED ITEMS',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),

//               pw.SizedBox(height: 8),

//               pw.Table(
//                 border: pw.TableBorder.all(color: PdfColors.grey400),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(3),
//                   1: const pw.FlexColumnWidth(1.1),
//                   2: const pw.FlexColumnWidth(1.5),
//                   3: const pw.FlexColumnWidth(1.7),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey200,
//                     ),
//                     children: [
//                       _pdfCell('Item', bold: true),
//                       _pdfCell('Qty', bold: true),
//                       _pdfCell('Rate', bold: true),
//                       _pdfCell('Amount', bold: true),
//                     ],
//                   ),
//                   ..._rentedItems.map((item) {
//                     return pw.TableRow(
//                       children: [
//                         _pdfCell(item.name),
//                         _pdfCell(item.quantity.toString()),
//                         _pdfCell('Rs. ${item.rentPrice.toStringAsFixed(0)}'),
//                         _pdfCell('Rs. ${item.totalPrice.toStringAsFixed(0)}'),
//                       ],
//                     );
//                   }),
//                 ],
//               ),

//               pw.SizedBox(height: 18),

//               // ------------------------------------------------------
//               // AMOUNT SUMMARY
//               // ------------------------------------------------------
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Container(
//                   width: 270,
//                   padding: const pw.EdgeInsets.all(14),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey400),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       _pdfAmountRow('Actual Amount', _subtotal),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow('Discount', _discount),
//                       pw.Divider(),
//                       _pdfAmountRow('Total Amount', _finalTotal, bold: true),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow('Paid', _paidAmount),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow('Remaining', _remainingAmount, bold: true),
//                     ],
//                   ),
//                 ),
//               ),

//               pw.SizedBox(height: 14),

//               // ------------------------------------------------------
//               // STATUS
//               // ------------------------------------------------------
//               if (status == 'paid')
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Transform.rotate(
//                     angle: -0.08,
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 9,
//                       ),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(color: PdfColors.green, width: 2),
//                         borderRadius: pw.BorderRadius.circular(5),
//                       ),
//                       child: pw.Text(
//                         'PAID',
//                         style: pw.TextStyle(
//                           fontSize: 21,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.green,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 7,
//                     ),
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(
//                         color: status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                       ),
//                       borderRadius: pw.BorderRadius.circular(5),
//                     ),
//                     child: pw.Text(
//                       _statusTitle(status).toUpperCase(),
//                       style: pw.TextStyle(
//                         fontSize: 12,
//                         fontWeight: pw.FontWeight.bold,
//                         color: status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                       ),
//                     ),
//                   ),
//                 ),

//               pw.SizedBox(height: 14),

//               // ------------------------------------------------------
//               // PAYMENT NOTE
//               // ------------------------------------------------------
//               if (status == 'unpaid' || status == 'partial')
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(12),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey100,
//                     border: pw.Border.all(color: PdfColors.grey400),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Text(
//                     status == 'unpaid'
//                         ? 'Payment Note: Bill payment is due on or before the return date.'
//                         : 'Payment Note: Remaining balance of Rs. ${_remainingAmount.toStringAsFixed(0)} is due on or before the return date.',
//                     style: const pw.TextStyle(
//                       fontSize: 9,
//                       color: PdfColors.grey800,
//                     ),
//                   ),
//                 ),

//               pw.Spacer(),

//               pw.Divider(),

//               pw.SizedBox(height: 7),

//               pw.Center(
//                 child: pw.Text(
//                   'Thank you for your business.',
//                   style: const pw.TextStyle(
//                     fontSize: 9,
//                     color: PdfColors.grey600,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   // ============================================================
//   // PDF HELPERS
//   // ============================================================

//   pw.Widget _pdfAmountRow(String label, double amount, {bool bold = false}) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _pdfCell(String text, {bool bold = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ITEM CARD
//   // ============================================================

//   Widget _rentedItemCard(RentedItem item, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               _getCategoryIcon(item.category),
//               color: Colors.blue,
//               size: 27,
//             ),
//           ),

//           const SizedBox(width: 14),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   'Material: ${item.material}',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   'Quantity',
//                   style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   item.quantity.toString(),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 16),

//           SizedBox(
//             width: 100,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   'Amount',
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           IconButton(
//             tooltip: 'Remove Item',
//             onPressed: () {
//               _removeItem(index);
//             },
//             icon: const Icon(Icons.close, color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY ICON
//   // ============================================================

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair_outlined;
//       case 'Decoration':
//         return Icons.auto_awesome_outlined;
//       case 'Tent':
//         return Icons.house_outlined;
//       case 'Lighting':
//         return Icons.lightbulb_outline;
//       case 'Sound Equipment':
//         return Icons.speaker_outlined;
//       case 'Stage Equipment':
//         return Icons.theater_comedy_outlined;
//       case 'Catering':
//         return Icons.restaurant_outlined;
//       default:
//         return Icons.inventory_2_outlined;
//     }
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade200),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.blue, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.red),
//       ),
//     );
//   }

//   // ============================================================
//   // SUMMARY ROW
//   // ============================================================

//   Widget _summaryRow(
//     String label,
//     double amount, {
//     bool bold = false,
//     Color? valueColor,
//   }) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: bold ? 16 : 14,
//             fontWeight: bold ? FontWeight.bold : FontWeight.w500,
//           ),
//         ),
//         const Spacer(),
//         Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: TextStyle(
//             fontSize: bold ? 18 : 15,
//             fontWeight: bold ? FontWeight.bold : FontWeight.w600,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DATE
//   // ============================================================

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   String _formatLongDate(DateTime date) {
//     return _formatDate(date);
//   }

//   // ============================================================
//   // DATE FIELD
//   // ============================================================

//   Widget _dateField({
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.grey.shade200),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.calendar_month_outlined, color: Colors.blue),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       date == null ? 'Select date' : _formatDate(date),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _showDialogMessage(BuildContext dialogContext, String message) {
//     ScaffoldMessenger.of(
//       dialogContext,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final status = _paymentStatus;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//         title: const Text(
//           'Create New Bill',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//       drawer: AdminDrawer(selectedIndex: 3),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 800),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ------------------------------------------------
//                     // HEADER
//                     // ------------------------------------------------
//                     Row(
//                       children: [
//                         Container(
//                           width: 55,
//                           height: 55,
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: const Icon(
//                             Icons.receipt_long_outlined,
//                             color: Colors.blue,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(width: 15),
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'New Rental Bill',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Create a rental bill, record payment, and update inventory stock.',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     // ------------------------------------------------
//                     // CUSTOMER DETAILS
//                     // ------------------------------------------------
//                     _sectionTitle('Customer Details'),

//                     const SizedBox(height: 12),

//                     TextFormField(
//                       controller: _nameController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: _inputDecoration(
//                         label: 'Customer Name',
//                         icon: Icons.person_outline,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter customer name.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _contactController,
//                       keyboardType: TextInputType.phone,
//                       onChanged: _formatContact,
//                       decoration: _inputDecoration(
//                         label: 'Contact Number',
//                         icon: Icons.phone_outlined,
//                       ).copyWith(hintText: '0300-1234567'),
//                       validator: (value) {
//                         final digits = (value ?? '').replaceAll(
//                           RegExp(r'[^0-9]'),
//                           '',
//                         );

//                         if (digits.length != 11 || !digits.startsWith('03')) {
//                           return 'Enter a valid 11-digit mobile number.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     TextFormField(
//                       controller: _cnicController,
//                       keyboardType: TextInputType.number,
//                       onChanged: _formatCnic,
//                       decoration: _inputDecoration(
//                         label: 'CNIC #',
//                         icon: Icons.badge_outlined,
//                       ).copyWith(hintText: 'XXXXX-XXXXX-XXXXXX'),
//                       validator: (value) {
//                         final digits = (value ?? '').replaceAll(
//                           RegExp(r'[^0-9]'),
//                           '',
//                         );

//                         if (digits.length != 16) {
//                           return 'CNIC must contain exactly 16 digits.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 30),

//                     // ------------------------------------------------
//                     // RENTAL DATES
//                     // ------------------------------------------------
//                     _sectionTitle('Rental Period'),

//                     const SizedBox(height: 12),

//                     Row(
//                       children: [
//                         _dateField(
//                           title: 'Date From',
//                           date: _dateFrom,
//                           onTap: () {
//                             _selectDate(isFrom: true);
//                           },
//                         ),
//                         const SizedBox(width: 12),
//                         _dateField(
//                           title: 'Return Date',
//                           date: _dateTill,
//                           onTap: () {
//                             _selectDate(isFrom: false);
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     // ------------------------------------------------
//                     // ITEMS
//                     // ------------------------------------------------
//                     Row(
//                       children: [
//                         Expanded(child: _sectionTitle('Renting Items')),
//                         ElevatedButton.icon(
//                           onPressed: _showAddItemModal,
//                           icon: const Icon(Icons.add),
//                           label: const Text('Add Item'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),

//                     if (_rentedItems.isEmpty)
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 30,
//                           horizontal: 20,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.shopping_cart_outlined,
//                               size: 40,
//                               color: Colors.grey.shade400,
//                             ),
//                             const SizedBox(height: 10),
//                             const Text(
//                               'No renting items added.',
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                             const SizedBox(height: 5),
//                             const Text(
//                               'Click "Add Item" to select inventory items.',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       Column(
//                         children: List.generate(_rentedItems.length, (index) {
//                           return _rentedItemCard(_rentedItems[index], index);
//                         }),
//                       ),

//                     const SizedBox(height: 20),

//                     // ------------------------------------------------
//                     // BILL SUMMARY & PAYMENT
//                     // ------------------------------------------------
//                     if (_rentedItems.isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _sectionTitle('Bill Summary & Payment'),
//                           const SizedBox(height: 12),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(18),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(14),
//                               border: Border.all(color: Colors.grey.shade200),
//                             ),
//                             child: Column(
//                               children: [
//                                 _summaryRow('Actual Amount', _subtotal),

//                                 const SizedBox(height: 12),

//                                 TextFormField(
//                                   controller: _discountController,
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                         decimal: true,
//                                       ),
//                                   onChanged: (_) {
//                                     setState(() {});
//                                   },
//                                   decoration: _inputDecoration(
//                                     label: 'Discount Amount',
//                                     icon: Icons.discount_outlined,
//                                   ).copyWith(hintText: '0'),
//                                 ),

//                                 const SizedBox(height: 12),

//                                 _summaryRow(
//                                   'Discount',
//                                   _discount,
//                                   valueColor: Colors.orange,
//                                 ),

//                                 const Divider(height: 24),

//                                 _summaryRow(
//                                   'Total Amount',
//                                   _finalTotal,
//                                   bold: true,
//                                   valueColor: Colors.blue,
//                                 ),

//                                 const SizedBox(height: 14),

//                                 TextFormField(
//                                   controller: _paidController,
//                                   keyboardType:
//                                       const TextInputType.numberWithOptions(
//                                         decimal: true,
//                                       ),
//                                   onChanged: (_) {
//                                     setState(() {});
//                                   },
//                                   decoration: _inputDecoration(
//                                     label: 'Paid Amount',
//                                     icon: Icons.payments_outlined,
//                                   ).copyWith(hintText: '0'),
//                                 ),

//                                 const SizedBox(height: 14),

//                                 _summaryRow(
//                                   'Paid',
//                                   _paidAmount,
//                                   valueColor: Colors.green,
//                                 ),

//                                 const SizedBox(height: 10),

//                                 _summaryRow(
//                                   'Remaining',
//                                   _remainingAmount,
//                                   bold: true,
//                                   valueColor: _remainingAmount > 0
//                                       ? Colors.red
//                                       : Colors.green,
//                                 ),

//                                 const SizedBox(height: 16),

//                                 Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: status == 'paid'
//                                         ? Colors.green.withOpacity(0.08)
//                                         : status == 'partial'
//                                         ? Colors.orange.withOpacity(0.08)
//                                         : Colors.red.withOpacity(0.08),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         status == 'paid'
//                                             ? Icons.check_circle_outline
//                                             : status == 'partial'
//                                             ? Icons.timelapse
//                                             : Icons.pending_actions_outlined,
//                                         color: status == 'paid'
//                                             ? Colors.green
//                                             : status == 'partial'
//                                             ? Colors.orange
//                                             : Colors.red,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         'Payment Status: ${_statusTitle(status)}',
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: status == 'paid'
//                                               ? Colors.green
//                                               : status == 'partial'
//                                               ? Colors.orange
//                                               : Colors.red,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                     const SizedBox(height: 30),

//                     // ------------------------------------------------
//                     // GENERATE
//                     // ------------------------------------------------
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed: _isGenerating ? null : _generateBill,
//                         icon: _isGenerating
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.receipt_long),
//                         label: Text(
//                           _isGenerating
//                               ? 'Generating Bill...'
//                               : 'Generate Bill',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ==================================================================
// // RENTED ITEM MODEL
// // ==================================================================

// class RentedItem {
//   final String itemId;
//   final String name;
//   final String category;
//   final String material;

//   int quantity;

//   final double rentPrice;

//   RentedItem({
//     required this.itemId,
//     required this.name,
//     required this.category,
//     required this.material,
//     required this.quantity,
//     required this.rentPrice,
//   });

//   double get totalPrice => quantity * rentPrice;
// }

// // ==================================================================
// // BILL PREVIEW SCREEN
// // ==================================================================

// class BillPreviewScreen extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billId;
//   final String customerName;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billId,
//     required this.customerName,
//   });

//   // ============================================================
//   // SAVE / DOWNLOAD / SHARE
//   // ============================================================

//   Future<void> _savePdf(BuildContext context) async {
//     try {
//       await Printing.sharePdf(
//         bytes: pdfBytes,
//         filename: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       );

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Bill ready to save/share.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to save/share the bill.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bill Preview'),
//         actions: [
//           IconButton(
//             tooltip: 'Save / Download Bill',
//             onPressed: () {
//               _savePdf(context);
//             },
//             icon: const Icon(Icons.save_outlined),
//           ),
//           IconButton(
//             tooltip: 'Print / Share',
//             onPressed: () async {
//               try {
//                 await Printing.sharePdf(
//                   bytes: pdfBytes,
//                   filename: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//                 );
//               } catch (_) {}
//             },
//             icon: const Icon(Icons.print_outlined),
//           ),
//         ],
//       ),
//       body: PdfPreview(
//         build: (format) async {
//           return pdfBytes;
//         },
//         canChangePageFormat: false,
//         canChangeOrientation: false,
//         allowPrinting: true,
//         allowSharing: true,
//         pdfFileName: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       ),
//     );
//   }
// }

// import 'dart:math';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});

//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }

// class _BillScreenState extends State<BillScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _cnicController = TextEditingController();
//   final TextEditingController _contactController = TextEditingController();

//   final TextEditingController _discountController =
//       TextEditingController(text: '0');

//   final TextEditingController _paidController =
//       TextEditingController(text: '0');

//   DateTime? _dateFrom;
//   DateTime? _dateTill;

//   final List<RentedItem> _rentedItems = [];

//   bool _isGenerating = false;

//   // ============================================================
//   // THEME
//   // ============================================================

//   static const Color _background = Color(0xFFF7F2EA);
//   static const Color _surface = Color(0xFFFFFCF8);
//   static const Color _bronze = Color(0xFF9A6A3A);
//   static const Color _bronzeDark = Color(0xFF704823);
//   static const Color _bronzeLight = Color(0xFFE9D6BC);
//   static const Color _darkBrown = Color(0xFF2C2119);
//   static const Color _mediumBrown = Color(0xFF59483A);
//   static const Color _mutedText = Color(0xFF8A7B6E);
//   static const Color _border = Color(0xFFE6D9CB);

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cnicController.dispose();
//     _contactController.dispose();
//     _discountController.dispose();
//     _paidController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // CNIC FORMAT
//   // ============================================================

//   void _formatCnic(String value) {
//     String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 16) {
//       digits = digits.substring(0, 16);
//     }

//     String formatted = '';

//     for (int i = 0; i < digits.length; i++) {
//       if (i == 5 || i == 10) {
//         formatted += '-';
//       }

//       formatted += digits[i];
//     }

//     _cnicController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // CONTACT FORMAT
//   // ============================================================

//   void _formatContact(String value) {
//     String digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 11) {
//       digits = digits.substring(0, 11);
//     }

//     String formatted = digits;

//     if (digits.length > 4) {
//       formatted = '${digits.substring(0, 4)}-${digits.substring(4)}';
//     }

//     _contactController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // MONEY
//   // ============================================================

//   double _parseMoney(String value) {
//     return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
//   }

//   double get _subtotal {
//     double total = 0;

//     for (final item in _rentedItems) {
//       total += item.totalPrice;
//     }

//     return total;
//   }

//   double get _discount {
//     final entered = _parseMoney(_discountController.text);

//     if (entered < 0) return 0;
//     if (entered > _subtotal) return _subtotal;

//     return entered;
//   }

//   double get _finalTotal {
//     final total = _subtotal - _discount;
//     return total < 0 ? 0 : total;
//   }

//   double get _paidAmount {
//     final entered = _parseMoney(_paidController.text);

//     if (entered < 0) return 0;
//     if (entered > _finalTotal) return _finalTotal;

//     return entered;
//   }

//   double get _remainingAmount {
//     final remaining = _finalTotal - _paidAmount;

//     return remaining < 0 ? 0 : remaining;
//   }

//   String get _paymentStatus {
//     if (_finalTotal <= 0) {
//       return 'paid';
//     }

//     if (_paidAmount <= 0) {
//       return 'unpaid';
//     }

//     if (_paidAmount >= _finalTotal) {
//       return 'paid';
//     }

//     return 'partial';
//   }

//   String _statusTitle(String status) {
//     switch (status) {
//       case 'paid':
//         return 'Paid';
//       case 'partial':
//         return 'Partial';
//       default:
//         return 'Unpaid';
//     }
//   }

//   String _generateBillNumber() {
//     final now = DateTime.now();
//     final random = Random().nextInt(9000) + 1000;

//     return 'RB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
//   }

//   // ============================================================
//   // DATE PICKER
//   // ============================================================

//   Future<void> _selectDate({required bool isFrom}) async {
//     final DateTime initialDate = isFrom
//         ? (_dateFrom ?? DateTime.now())
//         : (_dateTill ?? _dateFrom ?? DateTime.now());

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );

//     if (picked == null) {
//       return;
//     }

//     setState(() {
//       if (isFrom) {
//         _dateFrom = picked;

//         if (_dateTill != null && _dateTill!.isBefore(picked)) {
//           _dateTill = null;
//         }
//       } else {
//         if (_dateFrom != null && picked.isBefore(_dateFrom!)) {
//           _showMessage('Return date cannot be before Date From.');
//           return;
//         }

//         _dateTill = picked;
//       }
//     });
//   }

//   // ============================================================
//   // ADD ITEM MODAL
//   // ============================================================

//   Future<void> _showAddItemModal() async {
//     String? selectedItemId;
//     int selectedAvailableStock = 0;

//     final quantityController = TextEditingController();

//     bool isAdding = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             final screenWidth = MediaQuery.of(context).size.width;

//             return AlertDialog(
//               backgroundColor: _surface,
//               surfaceTintColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
//               contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
//               actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
//               title: Row(
//                 children: [
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: _bronzeLight,
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     child: const Icon(
//                       Icons.add_shopping_cart_outlined,
//                       color: _bronzeDark,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Add Renting Item',
//                       style: TextStyle(
//                         color: _darkBrown,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 19,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               content: SizedBox(
//                 width: screenWidth > 620 ? 520 : screenWidth * 0.82,
//                 child: SingleChildScrollView(
//                   child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                     stream: FirebaseFirestore.instance
//                         .collection('inventory')
//                         .orderBy('name')
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return const SizedBox(
//                           height: 150,
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               color: _bronze,
//                             ),
//                           ),
//                         );
//                       }

//                       if (snapshot.hasError) {
//                         return const Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Text(
//                             'Unable to load inventory.',
//                             style: TextStyle(color: _mediumBrown),
//                           ),
//                         );
//                       }

//                       final documents = snapshot.data?.docs ?? [];

//                       if (documents.isEmpty) {
//                         return const Padding(
//                           padding: EdgeInsets.all(20),
//                           child: Text(
//                             'No inventory items found.',
//                             style: TextStyle(color: _mediumBrown),
//                           ),
//                         );
//                       }

//                       int getRemainingStock(
//                         QueryDocumentSnapshot<Map<String, dynamic>> document,
//                       ) {
//                         final data = document.data();

//                         final available =
//                             (data['availableStock'] as num?)?.toInt() ?? 0;

//                         final alreadyAdded =
//                             _getAlreadyAddedQuantity(document.id);

//                         return available - alreadyAdded;
//                       }

//                       if (selectedItemId != null) {
//                         QueryDocumentSnapshot<Map<String, dynamic>>?
//                             selectedDocument;

//                         for (final document in documents) {
//                           if (document.id == selectedItemId) {
//                             selectedDocument = document;
//                             break;
//                           }
//                         }

//                         if (selectedDocument != null) {
//                           selectedAvailableStock =
//                               getRemainingStock(selectedDocument);
//                         }
//                       }

//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           DropdownButtonFormField<String>(
//                             value: selectedItemId,
//                             isExpanded: true,
//                             decoration: _inputDecoration(
//                               label: 'Select Item',
//                               icon: Icons.inventory_2_outlined,
//                             ),
//                             items: documents.map((document) {
//                               final data = document.data();

//                               final itemName =
//                                   data['name']?.toString() ?? 'Unnamed Item';

//                               final remaining = getRemainingStock(document);

//                               final disabled = remaining <= 0;

//                               return DropdownMenuItem<String>(
//                                 value: disabled ? null : document.id,
//                                 enabled: !disabled,
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       _getCategoryIcon(
//                                         data['category']?.toString() ??
//                                             'Other',
//                                       ),
//                                       size: 20,
//                                       color: disabled
//                                           ? Colors.grey
//                                           : _bronze,
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Expanded(
//                                       child: Text(
//                                         itemName,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color: disabled
//                                               ? Colors.grey
//                                               : _darkBrown,
//                                         ),
//                                       ),
//                                     ),
//                                     Text(
//                                       disabled
//                                           ? 'Out of stock'
//                                           : '$remaining available',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: disabled
//                                             ? Colors.red
//                                             : Colors.green.shade700,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setDialogState(() {
//                                 selectedItemId = value;
//                                 quantityController.clear();

//                                 if (value == null) {
//                                   selectedAvailableStock = 0;
//                                   return;
//                                 }

//                                 for (final document in documents) {
//                                   if (document.id == value) {
//                                     selectedAvailableStock =
//                                         getRemainingStock(document);
//                                     break;
//                                   }
//                                 }
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 14),
//                           Container(
//                             width: double.infinity,
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               color: _bronzeLight.withOpacity(0.38),
//                               borderRadius: BorderRadius.circular(13),
//                               border: Border.all(
//                                 color: _bronzeLight,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 38,
//                                   height: 38,
//                                   decoration: BoxDecoration(
//                                     color: _surface,
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Icon(
//                                     Icons.inventory_2_outlined,
//                                     size: 19,
//                                     color: _bronzeDark,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 11),
//                                 const Expanded(
//                                   child: Text(
//                                     'Available Stock',
//                                     style: TextStyle(
//                                       color: _mediumBrown,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   selectedItemId == null
//                                       ? '-'
//                                       : selectedAvailableStock.toString(),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w800,
//                                     fontSize: 18,
//                                     color: _bronzeDark,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 9),
//                           const Text(
//                             'Rented quantity cannot be greater than available stock.',
//                             style: TextStyle(
//                               color: _mutedText,
//                               fontSize: 12,
//                             ),
//                           ),
//                           const SizedBox(height: 14),
//                           TextFormField(
//                             controller: quantityController,
//                             keyboardType: TextInputType.number,
//                             decoration: _inputDecoration(
//                               label: 'Quantity to Rent',
//                               icon: Icons.numbers_outlined,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isAdding
//                       ? null
//                       : () {
//                           Navigator.pop(dialogContext);
//                         },
//                   style: TextButton.styleFrom(
//                     foregroundColor: _mediumBrown,
//                   ),
//                   child: const Text('Cancel'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: isAdding
//                       ? null
//                       : () async {
//                           final quantity = int.tryParse(
//                             quantityController.text.trim(),
//                           );

//                           if (selectedItemId == null) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Please select an item.',
//                             );
//                             return;
//                           }

//                           if (quantity == null || quantity <= 0) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Enter a valid quantity.',
//                             );
//                             return;
//                           }

//                           if (quantity > selectedAvailableStock) {
//                             _showDialogMessage(
//                               dialogContext,
//                               'Quantity cannot be greater than available stock.',
//                             );
//                             return;
//                           }

//                           isAdding = true;
//                           setDialogState(() {});

//                           try {
//                             final selectedDocument = await FirebaseFirestore
//                                 .instance
//                                 .collection('inventory')
//                                 .doc(selectedItemId)
//                                 .get();

//                             if (!selectedDocument.exists) {
//                               _showDialogMessage(
//                                 dialogContext,
//                                 'Selected inventory item no longer exists.',
//                               );
//                               return;
//                             }

//                             final data = selectedDocument.data() ?? {};

//                             final itemName =
//                                 data['name']?.toString() ?? 'Unnamed Item';

//                             final category =
//                                 data['category']?.toString() ?? 'Other';

//                             final material =
//                                 data['material']?.toString() ?? 'Unknown';

//                             final rentPrice =
//                                 (data['rentPrice'] as num?)?.toDouble() ?? 0;

//                             if (!mounted) return;

//                             setState(() {
//                               final existingIndex = _rentedItems.indexWhere(
//                                 (item) => item.itemId == selectedItemId,
//                               );

//                               if (existingIndex >= 0) {
//                                 _rentedItems[existingIndex].quantity +=
//                                     quantity;
//                               } else {
//                                 _rentedItems.add(
//                                   RentedItem(
//                                     itemId: selectedItemId!,
//                                     name: itemName,
//                                     category: category,
//                                     material: material,
//                                     quantity: quantity,
//                                     rentPrice: rentPrice,
//                                   ),
//                                 );
//                               }
//                             });

//                             Navigator.pop(dialogContext);
//                           } finally {
//                             isAdding = false;
//                             if (mounted) {
//                               setDialogState(() {});
//                             }
//                           }
//                         },
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add Item'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _bronze,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 13,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(11),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     quantityController.dispose();
//   }

//   // ============================================================
//   // ALREADY ADDED QUANTITY
//   // ============================================================

//   int _getAlreadyAddedQuantity(String itemId) {
//     for (final item in _rentedItems) {
//       if (item.itemId == itemId) {
//         return item.quantity;
//       }
//     }

//     return 0;
//   }

//   // ============================================================
//   // REMOVE ITEM
//   // ============================================================

//   void _removeItem(int index) {
//     setState(() {
//       _rentedItems.removeAt(index);
//     });
//   }

//   // ============================================================
//   // GENERATE BILL
//   // ============================================================

//   Future<void> _generateBill() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_dateFrom == null) {
//       _showMessage('Please select Date From.');
//       return;
//     }

//     if (_dateTill == null) {
//       _showMessage('Please select Return Date.');
//       return;
//     }

//     if (_rentedItems.isEmpty) {
//       _showMessage('Please add at least one renting item.');
//       return;
//     }

//     final cnicDigits = _cnicController.text.replaceAll(RegExp(r'[^0-9]'), '');

//     if (cnicDigits.length != 16) {
//       _showMessage('CNIC must contain exactly 16 digits.');
//       return;
//     }

//     final contactDigits = _contactController.text.replaceAll(
//       RegExp(r'[^0-9]'),
//       '',
//     );

//     if (contactDigits.length != 11 || !contactDigits.startsWith('03')) {
//       _showMessage('Contact number must be 11 digits and start with 03.');
//       return;
//     }

//     final subtotal = _subtotal;
//     final discount = _discount;
//     final finalTotal = _finalTotal;
//     final paidAmount = _paidAmount;
//     final remainingAmount = _remainingAmount;
//     final paymentStatus = _paymentStatus;

//     if (discount > subtotal) {
//       _showMessage('Discount cannot be greater than actual amount.');
//       return;
//     }

//     if (paidAmount > finalTotal) {
//       _showMessage('Paid amount cannot be greater than final total.');
//       return;
//     }

//     final billNumber = _generateBillNumber();
//     final generatedAt = DateTime.now();

//     setState(() {
//       _isGenerating = true;
//     });

//     try {
//       final firestore = FirebaseFirestore.instance;

//       final billReference = firestore.collection('bills').doc();

//       final customerReference = firestore.collection('customers').doc();

//       await firestore.runTransaction((transaction) async {
//         final List<DocumentSnapshot<Map<String, dynamic>>>
//             inventorySnapshots = [];

//         for (final rentedItem in _rentedItems) {
//           final reference = firestore
//               .collection('inventory')
//               .doc(rentedItem.itemId);

//           final snapshot = await transaction.get(reference);

//           inventorySnapshots.add(snapshot);
//         }

//         for (int i = 0; i < _rentedItems.length; i++) {
//           final rentedItem = _rentedItems[i];

//           final snapshot = inventorySnapshots[i];

//           if (!snapshot.exists) {
//             throw Exception(
//               '${rentedItem.name} no longer exists in inventory.',
//             );
//           }

//           final data = snapshot.data() ?? {};

//           final available = (data['availableStock'] as num?)?.toInt() ?? 0;

//           if (rentedItem.quantity > available) {
//             throw Exception(
//               'Only $available units of ${rentedItem.name} are available.',
//             );
//           }
//         }

//         for (int i = 0; i < _rentedItems.length; i++) {
//           final rentedItem = _rentedItems[i];

//           final snapshot = inventorySnapshots[i];

//           final data = snapshot.data() ?? {};

//           final currentAvailable =
//               (data['availableStock'] as num?)?.toInt() ?? 0;

//           final currentRented =
//               (data['rentedStock'] as num?)?.toInt() ?? 0;

//           transaction.update(snapshot.reference, {
//             'availableStock': currentAvailable - rentedItem.quantity,
//             'rentedStock': currentRented + rentedItem.quantity,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         }

//         final billItems = _rentedItems.map((item) {
//           return {
//             'itemId': item.itemId,
//             'name': item.name,
//             'category': item.category,
//             'material': item.material,
//             'quantity': item.quantity,
//             'rentPrice': item.rentPrice,
//             'totalPrice': item.totalPrice,
//           };
//         }).toList();

//         transaction.set(billReference, {
//           'billId': billReference.id,
//           'billNumber': billNumber,
//           'customerName': _nameController.text.trim(),
//           'contactNumber': _contactController.text.trim(),
//           'cnic': _cnicController.text.trim(),
//           'dateFrom': Timestamp.fromDate(_dateFrom!),
//           'dateTill': Timestamp.fromDate(_dateTill!),
//           'items': billItems,
//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,
//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,
//           'paymentStatus': paymentStatus,
//           'status': 'active',
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//         transaction.set(customerReference, {
//           'name': _nameController.text.trim(),
//           'contactNumber': _contactController.text.trim(),
//           'cnic': _cnicController.text.trim(),
//           'lastBillId': billReference.id,
//           'lastBillNumber': billNumber,
//           'lastRentalFrom': Timestamp.fromDate(_dateFrom!),
//           'lastRentalTill': Timestamp.fromDate(_dateTill!),
//           'rentalItems': billItems,
//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,
//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,
//           'paymentStatus': paymentStatus,
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       });

//       if (!mounted) return;

//       final pdf = await _buildBillPdf(
//         billNumber: billNumber,
//         generatedAt: generatedAt,
//       );

//       if (!mounted) return;

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => BillPreviewScreen(
//             pdfBytes: pdf,
//             billId: billNumber,
//             customerName: _nameController.text.trim(),
//           ),
//         ),
//       );

//       if (!mounted) return;

//       _nameController.clear();
//       _cnicController.clear();
//       _contactController.clear();
//       _discountController.text = '0';
//       _paidController.text = '0';

//       setState(() {
//         _dateFrom = null;
//         _dateTill = null;
//         _rentedItems.clear();
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Bill $billNumber generated successfully.'),
//           backgroundColor: Colors.green.shade700,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       String message = e.toString();

//       if (message.startsWith('Exception: ')) {
//         message = message.substring(11);
//       }

//       _showMessage('Bill could not be generated: $message');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isGenerating = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf({
//     required String billNumber,
//     required DateTime generatedAt,
//   }) async {
//     final pdf = pw.Document();

//     final status = _paymentStatus;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Container(
//                 padding: const pw.EdgeInsets.all(18),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(12),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.start,
//                       children: [
//                         pw.Text(
//                           'RENTAL BILL',
//                           style: pw.TextStyle(
//                             fontSize: 25,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 5),
//                         pw.Text(
//                           'Inventory Management',
//                           style: const pw.TextStyle(
//                             fontSize: 10,
//                             color: PdfColors.grey700,
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 14,
//                         vertical: 10,
//                       ),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(color: PdfColors.grey500),
//                         borderRadius: pw.BorderRadius.circular(8),
//                       ),
//                       child: pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.end,
//                         children: [
//                           pw.Text(
//                             'BILL #',
//                             style: const pw.TextStyle(
//                               fontSize: 8,
//                               color: PdfColors.grey700,
//                             ),
//                           ),
//                           pw.SizedBox(height: 3),
//                           pw.Text(
//                             billNumber,
//                             style: pw.TextStyle(
//                               fontSize: 11,
//                               fontWeight: pw.FontWeight.bold,
//                             ),
//                           ),
//                           pw.SizedBox(height: 4),
//                           pw.Text(
//                             'Generated: ${_formatLongDate(generatedAt)}',
//                             style: const pw.TextStyle(
//                               fontSize: 8,
//                               color: PdfColors.grey700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 18),
//               pw.Text(
//                 'CUSTOMER DETAILS',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(12),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.grey100,
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Name: ${_nameController.text.trim()}',
//                           ),
//                         ),
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Contact: ${_contactController.text.trim()}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 7),
//                     pw.Row(
//                       children: [
//                         pw.Expanded(
//                           child: pw.Text(
//                             'CNIC: ${_cnicController.text.trim()}',
//                           ),
//                         ),
//                         pw.Expanded(
//                           child: pw.Text(
//                             'Bill Date: ${_formatLongDate(generatedAt)}',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 18),
//               pw.Text(
//                 'RENTAL PERIOD',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(11),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('From: ${_formatDate(_dateFrom!)}'),
//                     pw.Text('Return: ${_formatDate(_dateTill!)}'),
//                   ],
//                 ),
//               ),
//               pw.SizedBox(height: 18),
//               pw.Text(
//                 'RENTED ITEMS',
//                 style: pw.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//               pw.SizedBox(height: 8),
//               pw.Table(
//                 border: pw.TableBorder.all(color: PdfColors.grey400),
//                 columnWidths: {
//                   0: const pw.FlexColumnWidth(3),
//                   1: const pw.FlexColumnWidth(1.1),
//                   2: const pw.FlexColumnWidth(1.5),
//                   3: const pw.FlexColumnWidth(1.7),
//                 },
//                 children: [
//                   pw.TableRow(
//                     decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey200,
//                     ),
//                     children: [
//                       _pdfCell('Item', bold: true),
//                       _pdfCell('Qty', bold: true),
//                       _pdfCell('Rate', bold: true),
//                       _pdfCell('Amount', bold: true),
//                     ],
//                   ),
//                   ..._rentedItems.map((item) {
//                     return pw.TableRow(
//                       children: [
//                         _pdfCell(item.name),
//                         _pdfCell(item.quantity.toString()),
//                         _pdfCell(
//                           'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                         ),
//                         _pdfCell(
//                           'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//               pw.SizedBox(height: 18),
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Container(
//                   width: 270,
//                   padding: const pw.EdgeInsets.all(14),
//                   decoration: pw.BoxDecoration(
//                     border: pw.Border.all(color: PdfColors.grey400),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       _pdfAmountRow('Actual Amount', _subtotal),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow('Discount', _discount),
//                       pw.Divider(),
//                       _pdfAmountRow(
//                         'Total Amount',
//                         _finalTotal,
//                         bold: true,
//                       ),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow('Paid', _paidAmount),
//                       pw.SizedBox(height: 7),
//                       _pdfAmountRow(
//                         'Remaining',
//                         _remainingAmount,
//                         bold: true,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               pw.SizedBox(height: 14),
//               if (status == 'paid')
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Transform.rotate(
//                     angle: -0.08,
//                     child: pw.Container(
//                       padding: const pw.EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 9,
//                       ),
//                       decoration: pw.BoxDecoration(
//                         border: pw.Border.all(
//                           color: PdfColors.green,
//                           width: 2,
//                         ),
//                         borderRadius: pw.BorderRadius.circular(5),
//                       ),
//                       child: pw.Text(
//                         'PAID',
//                         style: pw.TextStyle(
//                           fontSize: 21,
//                           fontWeight: pw.FontWeight.bold,
//                           color: PdfColors.green,
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               else
//                 pw.Align(
//                   alignment: pw.Alignment.centerRight,
//                   child: pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 7,
//                     ),
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(
//                         color: status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                       ),
//                       borderRadius: pw.BorderRadius.circular(5),
//                     ),
//                     child: pw.Text(
//                       _statusTitle(status).toUpperCase(),
//                       style: pw.TextStyle(
//                         fontSize: 12,
//                         fontWeight: pw.FontWeight.bold,
//                         color: status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                       ),
//                     ),
//                   ),
//                 ),
//               pw.SizedBox(height: 14),
//               if (status == 'unpaid' || status == 'partial')
//                 pw.Container(
//                   width: double.infinity,
//                   padding: const pw.EdgeInsets.all(12),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey100,
//                     border: pw.Border.all(color: PdfColors.grey400),
//                     borderRadius: pw.BorderRadius.circular(8),
//                   ),
//                   child: pw.Text(
//                     status == 'unpaid'
//                         ? 'Payment Note: Bill payment is due on or before the return date.'
//                         : 'Payment Note: Remaining balance of Rs. ${_remainingAmount.toStringAsFixed(0)} is due on or before the return date.',
//                     style: const pw.TextStyle(
//                       fontSize: 9,
//                       color: PdfColors.grey800,
//                     ),
//                   ),
//                 ),
//               pw.Spacer(),
//               pw.Divider(),
//               pw.SizedBox(height: 7),
//               pw.Center(
//                 child: pw.Text(
//                   'Thank you for your business.',
//                   style: const pw.TextStyle(
//                     fontSize: 9,
//                     color: PdfColors.grey600,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   // ============================================================
//   // PDF HELPERS
//   // ============================================================

//   pw.Widget _pdfAmountRow(
//     String label,
//     double amount, {
//     bool bold = false,
//   }) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold
//                 ? pw.FontWeight.bold
//                 : pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold
//                 ? pw.FontWeight.bold
//                 : pw.FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _pdfCell(
//     String text, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: bold
//               ? pw.FontWeight.bold
//               : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ITEM CARD
//   // ============================================================

//   Widget _rentedItemCard(
//     RentedItem item,
//     int index, {
//     bool compact = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _border),
//         boxShadow: [
//           BoxShadow(
//             color: _darkBrown.withOpacity(0.035),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: compact
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     _itemIcon(item),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: _itemName(item),
//                     ),
//                     _removeButton(index),
//                   ],
//                 ),
//                 const SizedBox(height: 13),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _itemInfoChip(
//                       'Qty',
//                       item.quantity.toString(),
//                       _bronze,
//                     ),
//                     _itemInfoChip(
//                       'Rate',
//                       'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                       _mediumBrown,
//                     ),
//                     _itemInfoChip(
//                       'Amount',
//                       'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                       _bronzeDark,
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 _itemIcon(item),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: _itemName(item),
//                 ),
//                 const SizedBox(width: 12),
//                 _itemInfoChip(
//                   'Quantity',
//                   item.quantity.toString(),
//                   _bronze,
//                 ),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   width: 120,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'Amount',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: _mutedText,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 15,
//                           color: _darkBrown,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _removeButton(index),
//               ],
//             ),
//     );
//   }

//   Widget _itemIcon(RentedItem item) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: _bronzeLight.withOpacity(0.45),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Icon(
//         _getCategoryIcon(item.category),
//         color: _bronzeDark,
//         size: 25,
//       ),
//     );
//   }

//   Widget _itemName(RentedItem item) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           item.name,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           'Material: ${item.material}',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             fontSize: 12,
//             color: _mutedText,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _itemInfoChip(
//     String label,
//     String value,
//     Color valueColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color: valueColor.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: valueColor.withOpacity(0.12),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 9,
//               color: _mutedText,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w800,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _removeButton(int index) {
//     return IconButton(
//       tooltip: 'Remove Item',
//       onPressed: () {
//         _removeItem(index);
//       },
//       style: IconButton.styleFrom(
//         backgroundColor: Colors.red.withOpacity(0.07),
//         foregroundColor: Colors.red.shade700,
//       ),
//       icon: const Icon(
//         Icons.close,
//         size: 19,
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY ICON
//   // ============================================================

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair_outlined;
//       case 'Decoration':
//         return Icons.auto_awesome_outlined;
//       case 'Tent':
//         return Icons.house_outlined;
//       case 'Lighting':
//         return Icons.lightbulb_outline;
//       case 'Sound Equipment':
//         return Icons.speaker_outlined;
//       case 'Stage Equipment':
//         return Icons.theater_comedy_outlined;
//       case 'Catering':
//         return Icons.restaurant_outlined;
//       default:
//         return Icons.inventory_2_outlined;
//     }
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(
//         color: _mutedText,
//         fontSize: 13,
//       ),
//       prefixIcon: Icon(
//         icon,
//         color: _bronze,
//         size: 21,
//       ),
//       filled: true,
//       fillColor: _surface,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 16,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(
//           color: _border,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(
//           color: _border,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(
//           color: _bronze,
//           width: 1.6,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(
//           color: Colors.red,
//           width: 1.4,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SUMMARY ROW
//   // ============================================================

//   Widget _summaryRow(
//     String label,
//     double amount, {
//     bool bold = false,
//     Color? valueColor,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: bold ? 15 : 13,
//               fontWeight: bold
//                   ? FontWeight.w800
//                   : FontWeight.w600,
//               color: bold ? _darkBrown : _mediumBrown,
//             ),
//           ),
//         ),
//         Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: TextStyle(
//             fontSize: bold ? 17 : 14,
//             fontWeight: bold
//                 ? FontWeight.w800
//                 : FontWeight.w700,
//             color: valueColor ?? _darkBrown,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DATE
//   // ============================================================

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   String _formatLongDate(DateTime date) {
//     return _formatDate(date);
//   }

//   // ============================================================
//   // DATE FIELD
//   // ============================================================

//   Widget _dateField({
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 15,
//         ),
//         decoration: BoxDecoration(
//           color: _surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _border),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: _bronzeLight.withOpacity(0.42),
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               child: const Icon(
//                 Icons.calendar_month_outlined,
//                 color: _bronzeDark,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: _mutedText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     date == null
//                         ? 'Select date'
//                         : _formatDate(date),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: date == null
//                           ? _mutedText
//                           : _darkBrown,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: _mutedText,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(
//     String title, {
//     String? subtitle,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         if (subtitle != null) ...[
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 12,
//               color: _mutedText,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // ============================================================
//   // CARD
//   // ============================================================

//   Widget _sectionCard({
//     required Widget child,
//     EdgeInsets padding = const EdgeInsets.all(20),
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: padding,
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _border),
//         boxShadow: [
//           BoxShadow(
//             color: _darkBrown.withOpacity(0.035),
//             blurRadius: 18,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader(bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 18 : 24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             _bronzeDark,
//             _bronze,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: _bronzeDark.withOpacity(0.20),
//             blurRadius: 22,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: isMobile
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _headerIcon(),
//                 const SizedBox(height: 15),
//                 _headerText(),
//               ],
//             )
//           : Row(
//               children: [
//                 _headerIcon(),
//                 const SizedBox(width: 16),
//                 Expanded(child: _headerText()),
//               ],
//             ),
//     );
//   }

//   Widget _headerIcon() {
//     return Container(
//       width: 58,
//       height: 58,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.18),
//         ),
//       ),
//       child: const Icon(
//         Icons.receipt_long_outlined,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   Widget _headerText() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'New Rental Bill',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Create a rental bill, record payment, and update inventory stock.',
//           style: TextStyle(
//             color: Colors.white70,
//             fontSize: 13,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     final status = _paymentStatus;

//     return Scaffold(
//       backgroundColor: _background,
//       appBar: AppBar(
//         backgroundColor: _surface,
//         foregroundColor: _darkBrown,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         titleSpacing: 18,
//         title: const Text(
//           'Create New Bill',
//           style: TextStyle(
//             fontWeight: FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//       ),
//       drawer: const AdminDrawer(selectedIndex: 3),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final width = constraints.maxWidth;

//             final isMobile = width < 650;
//             final isTablet = width >= 650 && width < 950;

//             final horizontalPadding = isMobile
//                 ? 14.0
//                 : isTablet
//                     ? 24.0
//                     : 34.0;

//             return SingleChildScrollView(
//               padding: EdgeInsets.fromLTRB(
//                 horizontalPadding,
//                 20,
//                 horizontalPadding,
//                 35,
//               ),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: 1120,
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         _buildHeader(isMobile),

//                         const SizedBox(height: 24),

//                         // ==================================================
//                         // CUSTOMER DETAILS
//                         // ==================================================

//                         _sectionCard(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               _sectionTitle(
//                                 'Customer Details',
//                                 subtitle:
//                                     'Enter the customer information for this rental.',
//                               ),
//                               const SizedBox(height: 18),

//                               LayoutBuilder(
//                                 builder: (context, box) {
//                                   final twoColumns =
//                                       box.maxWidth >= 700;

//                                   if (!twoColumns) {
//                                     return Column(
//                                       children: [
//                                         TextFormField(
//                                           controller:
//                                               _nameController,
//                                           textCapitalization:
//                                               TextCapitalization.words,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'Customer Name',
//                                             icon:
//                                                 Icons.person_outline,
//                                           ),
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value
//                                                     .trim()
//                                                     .isEmpty) {
//                                               return 'Please enter customer name.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                         const SizedBox(height: 14),
//                                         TextFormField(
//                                           controller:
//                                               _contactController,
//                                           keyboardType:
//                                               TextInputType.phone,
//                                           onChanged:
//                                               _formatContact,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'Contact Number',
//                                             icon:
//                                                 Icons.phone_outlined,
//                                           ).copyWith(
//                                             hintText:
//                                                 '0300-1234567',
//                                           ),
//                                           validator: (value) {
//                                             final digits =
//                                                 (value ?? '')
//                                                     .replaceAll(
//                                               RegExp(r'[^0-9]'),
//                                               '',
//                                             );

//                                             if (digits.length !=
//                                                     11 ||
//                                                 !digits.startsWith(
//                                                     '03')) {
//                                               return 'Enter a valid 11-digit mobile number.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                         const SizedBox(height: 14),
//                                         TextFormField(
//                                           controller:
//                                               _cnicController,
//                                           keyboardType:
//                                               TextInputType.number,
//                                           onChanged: _formatCnic,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'CNIC #',
//                                             icon:
//                                                 Icons.badge_outlined,
//                                           ).copyWith(
//                                             hintText:
//                                                 'XXXXX-XXXXX-XXXXXX',
//                                           ),
//                                           validator: (value) {
//                                             final digits =
//                                                 (value ?? '')
//                                                     .replaceAll(
//                                               RegExp(r'[^0-9]'),
//                                               '',
//                                             );

//                                             if (digits.length !=
//                                                 16) {
//                                               return 'CNIC must contain exactly 16 digits.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   }

//                                   return Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextFormField(
//                                           controller:
//                                               _nameController,
//                                           textCapitalization:
//                                               TextCapitalization
//                                                   .words,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'Customer Name',
//                                             icon:
//                                                 Icons.person_outline,
//                                           ),
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value
//                                                     .trim()
//                                                     .isEmpty) {
//                                               return 'Please enter customer name.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(width: 14),
//                                       Expanded(
//                                         child: TextFormField(
//                                           controller:
//                                               _contactController,
//                                           keyboardType:
//                                               TextInputType.phone,
//                                           onChanged:
//                                               _formatContact,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'Contact Number',
//                                             icon:
//                                                 Icons.phone_outlined,
//                                           ).copyWith(
//                                             hintText:
//                                                 '0300-1234567',
//                                           ),
//                                           validator: (value) {
//                                             final digits =
//                                                 (value ?? '')
//                                                     .replaceAll(
//                                               RegExp(r'[^0-9]'),
//                                               '',
//                                             );

//                                             if (digits.length !=
//                                                     11 ||
//                                                 !digits.startsWith(
//                                                     '03')) {
//                                               return 'Enter a valid 11-digit mobile number.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(width: 14),
//                                       Expanded(
//                                         child: TextFormField(
//                                           controller:
//                                               _cnicController,
//                                           keyboardType:
//                                               TextInputType.number,
//                                           onChanged: _formatCnic,
//                                           decoration:
//                                               _inputDecoration(
//                                             label: 'CNIC #',
//                                             icon:
//                                                 Icons.badge_outlined,
//                                           ).copyWith(
//                                             hintText:
//                                                 'XXXXX-XXXXX-XXXXXX',
//                                           ),
//                                           validator: (value) {
//                                             final digits =
//                                                 (value ?? '')
//                                                     .replaceAll(
//                                               RegExp(r'[^0-9]'),
//                                               '',
//                                             );

//                                             if (digits.length !=
//                                                 16) {
//                                               return 'CNIC must contain exactly 16 digits.';
//                                             }

//                                             return null;
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         // ==================================================
//                         // RENTAL PERIOD
//                         // ==================================================

//                         _sectionCard(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               _sectionTitle(
//                                 'Rental Period',
//                                 subtitle:
//                                     'Select when the rental starts and when the items are expected back.',
//                               ),
//                               const SizedBox(height: 18),
//                               LayoutBuilder(
//                                 builder: (context, box) {
//                                   if (box.maxWidth < 600) {
//                                     return Column(
//                                       children: [
//                                         _dateField(
//                                           title: 'Date From',
//                                           date: _dateFrom,
//                                           onTap: () {
//                                             _selectDate(
//                                               isFrom: true,
//                                             );
//                                           },
//                                         ),
//                                         const SizedBox(height: 12),
//                                         _dateField(
//                                           title: 'Return Date',
//                                           date: _dateTill,
//                                           onTap: () {
//                                             _selectDate(
//                                               isFrom: false,
//                                             );
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   }

//                                   return Row(
//                                     children: [
//                                       Expanded(
//                                         child: _dateField(
//                                           title: 'Date From',
//                                           date: _dateFrom,
//                                           onTap: () {
//                                             _selectDate(
//                                               isFrom: true,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(width: 14),
//                                       Expanded(
//                                         child: _dateField(
//                                           title: 'Return Date',
//                                           date: _dateTill,
//                                           onTap: () {
//                                             _selectDate(
//                                               isFrom: false,
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         // ==================================================
//                         // RENTING ITEMS
//                         // ==================================================

//                         _sectionCard(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             children: [
//                               LayoutBuilder(
//                                 builder: (context, box) {
//                                   final mobile =
//                                       box.maxWidth < 520;

//                                   if (mobile) {
//                                     return Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment
//                                               .start,
//                                       children: [
//                                         _sectionTitle(
//                                           'Renting Items',
//                                           subtitle:
//                                               'Items selected for this rental.',
//                                         ),
//                                         const SizedBox(height: 14),
//                                         SizedBox(
//                                           width:
//                                               double.infinity,
//                                           child:
//                                               _addItemButton(),
//                                         ),
//                                       ],
//                                     );
//                                   }

//                                   return Row(
//                                     children: [
//                                       Expanded(
//                                         child: _sectionTitle(
//                                           'Renting Items',
//                                           subtitle:
//                                               'Items selected for this rental.',
//                                         ),
//                                       ),
//                                       _addItemButton(),
//                                     ],
//                                   );
//                                 },
//                               ),
//                               const SizedBox(height: 18),
//                               if (_rentedItems.isEmpty)
//                                 _emptyItemsState()
//                               else
//                                 LayoutBuilder(
//                                   builder:
//                                       (context, box) {
//                                     final compact =
//                                         box.maxWidth < 680;

//                                     return Column(
//                                       children:
//                                           List.generate(
//                                         _rentedItems.length,
//                                         (index) {
//                                           return _rentedItemCard(
//                                             _rentedItems[index],
//                                             index,
//                                             compact: compact,
//                                           );
//                                         },
//                                       ),
//                                     );
//                                   },
//                                 ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         // ==================================================
//                         // BILL SUMMARY & PAYMENT
//                         // ==================================================

//                         if (_rentedItems.isNotEmpty)
//                           _sectionCard(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 _sectionTitle(
//                                   'Bill Summary & Payment',
//                                   subtitle:
//                                       'Review the amount and record the customer payment.',
//                                 ),
//                                 const SizedBox(height: 18),
//                                 LayoutBuilder(
//                                   builder: (context, box) {
//                                     final twoColumns =
//                                         box.maxWidth >= 780;

//                                     if (!twoColumns) {
//                                       return _paymentContent(
//                                         status,
//                                       );
//                                     }

//                                     return Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment
//                                               .start,
//                                       children: [
//                                         Expanded(
//                                           child:
//                                               _amountSummary(),
//                                         ),
//                                         const SizedBox(width: 24),
//                                         Expanded(
//                                           child:
//                                               _paymentDetails(
//                                             status,
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),

//                         const SizedBox(height: 22),

//                         // ==================================================
//                         // GENERATE BUTTON
//                         // ==================================================

//                         SizedBox(
//                           width: double.infinity,
//                           height: 58,
//                           child: ElevatedButton.icon(
//                             onPressed: _isGenerating
//                                 ? null
//                                 : _generateBill,
//                             icon: _isGenerating
//                                 ? const SizedBox(
//                                     width: 21,
//                                     height: 21,
//                                     child:
//                                         CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Icon(
//                                     Icons.receipt_long_outlined,
//                                   ),
//                             label: Text(
//                               _isGenerating
//                                   ? 'Generating Bill...'
//                                   : 'Generate Bill',
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _bronzeDark,
//                               foregroundColor: Colors.white,
//                               disabledBackgroundColor:
//                                   _bronze.withOpacity(0.5),
//                               disabledForegroundColor:
//                                   Colors.white,
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(15),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ADD ITEM BUTTON
//   // ============================================================

//   Widget _addItemButton() {
//     return ElevatedButton.icon(
//       onPressed: _showAddItemModal,
//       icon: const Icon(
//         Icons.add,
//         size: 19,
//       ),
//       label: const Text(
//         'Add Item',
//         style: TextStyle(
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _bronze,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 13,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(11),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY ITEMS
//   // ============================================================

//   Widget _emptyItemsState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 32,
//         horizontal: 20,
//       ),
//       decoration: BoxDecoration(
//         color: _background,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: _border,
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 58,
//             height: 58,
//             decoration: BoxDecoration(
//               color: _bronzeLight.withOpacity(0.42),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.shopping_cart_outlined,
//               size: 27,
//               color: _bronzeDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'No renting items added',
//             style: TextStyle(
//               fontWeight: FontWeight.w800,
//               color: _darkBrown,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Click "Add Item" to select inventory items.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: _mutedText,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PAYMENT CONTENT
//   // ============================================================

//   Widget _paymentContent(String status) {
//     return Column(
//       children: [
//         _amountSummary(),
//         const SizedBox(height: 22),
//         _paymentDetails(status),
//       ],
//     );
//   }

//   // ============================================================
//   // AMOUNT SUMMARY
//   // ============================================================

//   Widget _amountSummary() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: _background,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: _border,
//         ),
//       ),
//       child: Column(
//         children: [
//           _summaryRow(
//             'Actual Amount',
//             _subtotal,
//           ),
//           const SizedBox(height: 14),
//           TextFormField(
//             controller: _discountController,
//             keyboardType:
//                 const TextInputType.numberWithOptions(
//               decimal: true,
//             ),
//             onChanged: (_) {
//               setState(() {});
//             },
//             decoration: _inputDecoration(
//               label: 'Discount Amount',
//               icon: Icons.discount_outlined,
//             ).copyWith(
//               hintText: '0',
//             ),
//           ),
//           const SizedBox(height: 13),
//           _summaryRow(
//             'Discount',
//             _discount,
//             valueColor: Colors.orange.shade700,
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 15),
//             child: Divider(
//               color: _border,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 13,
//             ),
//             decoration: BoxDecoration(
//               color: _bronzeLight.withOpacity(0.35),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: _summaryRow(
//               'Total Amount',
//               _finalTotal,
//               bold: true,
//               valueColor: _bronzeDark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PAYMENT DETAILS
//   // ============================================================

//   Widget _paymentDetails(String status) {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _paidController,
//           keyboardType:
//               const TextInputType.numberWithOptions(
//             decimal: true,
//           ),
//           onChanged: (_) {
//             setState(() {});
//           },
//           decoration: _inputDecoration(
//             label: 'Paid Amount',
//             icon: Icons.payments_outlined,
//           ).copyWith(
//             hintText: '0',
//           ),
//         ),
//         const SizedBox(height: 14),
//         _summaryRow(
//           'Paid',
//           _paidAmount,
//           valueColor: Colors.green.shade700,
//         ),
//         const SizedBox(height: 11),
//         _summaryRow(
//           'Remaining',
//           _remainingAmount,
//           bold: true,
//           valueColor: _remainingAmount > 0
//               ? Colors.red.shade700
//               : Colors.green.shade700,
//         ),
//         const SizedBox(height: 17),
//         _paymentStatusCard(status),
//       ],
//     );
//   }

//   // ============================================================
//   // PAYMENT STATUS
//   // ============================================================

//   Widget _paymentStatusCard(String status) {
//     final Color color;
//     final IconData icon;

//     if (status == 'paid') {
//       color = Colors.green.shade700;
//       icon = Icons.check_circle_outline;
//     } else if (status == 'partial') {
//       color = Colors.orange.shade700;
//       icon = Icons.timelapse;
//     } else {
//       color = Colors.red.shade700;
//       icon = Icons.pending_actions_outlined;
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(
//           color: color.withOpacity(0.14),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 21,
//             ),
//           ),
//           const SizedBox(width: 11),
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Payment Status',
//                   style: TextStyle(
//                     color: _mutedText,
//                     fontSize: 11,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _statusTitle(status),
//                   style: TextStyle(
//                     fontWeight: FontWeight.w800,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _darkBrown,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   void _showDialogMessage(
//     BuildContext dialogContext,
//     String message,
//   ) {
//     ScaffoldMessenger.of(dialogContext).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _darkBrown,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }
// }

// // ==================================================================
// // RENTED ITEM MODEL
// // ==================================================================

// class RentedItem {
//   final String itemId;
//   final String name;
//   final String category;
//   final String material;

//   int quantity;

//   final double rentPrice;

//   RentedItem({
//     required this.itemId,
//     required this.name,
//     required this.category,
//     required this.material,
//     required this.quantity,
//     required this.rentPrice,
//   });

//   double get totalPrice => quantity * rentPrice;
// }

// // ==================================================================
// // BILL PREVIEW SCREEN
// // ==================================================================

// class BillPreviewScreen extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billId;
//   final String customerName;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billId,
//     required this.customerName,
//   });

//   // ============================================================
//   // SAVE / DOWNLOAD / SHARE
//   // ============================================================

//   Future<void> _savePdf(BuildContext context) async {
//     try {
//       await Printing.sharePdf(
//         bytes: pdfBytes,
//         filename: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       );

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Bill ready to save/share.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to save/share the bill.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _BillScreenState._background,
//       appBar: AppBar(
//         backgroundColor: _BillScreenState._surface,
//         foregroundColor: _BillScreenState._darkBrown,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Bill Preview',
//           style: TextStyle(
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Save / Download Bill',
//             onPressed: () {
//               _savePdf(context);
//             },
//             style: IconButton.styleFrom(
//               foregroundColor: _BillScreenState._bronzeDark,
//             ),
//             icon: const Icon(
//               Icons.save_outlined,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Print / Share',
//             onPressed: () async {
//               try {
//                 await Printing.sharePdf(
//                   bytes: pdfBytes,
//                   filename:
//                       'Bill_${billId.replaceAll(' ', '_')}.pdf',
//                 );
//               } catch (_) {}
//             },
//             style: IconButton.styleFrom(
//               foregroundColor: _BillScreenState._bronzeDark,
//             ),
//             icon: const Icon(
//               Icons.print_outlined,
//             ),
//           ),
//           const SizedBox(width: 6),
//         ],
//       ),
//       body: Container(
//         color: _BillScreenState._background,
//         child: PdfPreview(
//           build: (format) async {
//             return pdfBytes;
//           },
//           canChangePageFormat: false,
//           canChangeOrientation: false,
//           allowPrinting: true,
//           allowSharing: true,
//           pdfFileName:
//               'Bill_${billId.replaceAll(' ', '_')}.pdf',
//         ),
//       ),
//     );
//   }
// }




// import 'dart:math';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});

//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }

// class _BillScreenState extends State<BillScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _cnicController = TextEditingController();
//   final _contactController = TextEditingController();
//   final _discountController = TextEditingController(text: '0');
//   final _paidController = TextEditingController(text: '0');

//   DateTime? _dateFrom;
//   DateTime? _dateTill;

//   final List<RentedItem> _rentedItems = [];
//   bool _isGenerating = false;

//   static const Color _background = Color(0xFFF7F2EA);
//   static const Color _surface = Color(0xFFFFFCF8);
//   static const Color _bronze = Color(0xFF9A6A3A);
//   static const Color _bronzeDark = Color(0xFF704823);
//   static const Color _bronzeLight = Color(0xFFE9D6BC);
//   static const Color _darkBrown = Color(0xFF2C2119);
//   static const Color _mediumBrown = Color(0xFF59483A);
//   static const Color _mutedText = Color(0xFF8A7B6E);
//   static const Color _border = Color(0xFFE6D9CB);

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cnicController.dispose();
//     _contactController.dispose();
//     _discountController.dispose();
//     _paidController.dispose();
//     super.dispose();
//   }

//   void _formatCnic(String value) {
//     var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
//     if (digits.length > 16) digits = digits.substring(0, 16);

//     var formatted = '';
//     for (var i = 0; i < digits.length; i++) {
//       if (i == 5 || i == 10) formatted += '-';
//       formatted += digits[i];
//     }

//     _cnicController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//     if (mounted) setState(() {});
//   }

//   void _formatContact(String value) {
//     var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
//     if (digits.length > 11) digits = digits.substring(0, 11);

//     final formatted = digits.length > 4
//         ? '${digits.substring(0, 4)}-${digits.substring(4)}'
//         : digits;

//     _contactController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//     if (mounted) setState(() {});
//   }

//   double _parseMoney(String value) =>
//       double.tryParse(value.replaceAll(',', '').trim()) ?? 0;

//   double get _subtotal =>
//       _rentedItems.fold(0, (sum, item) => sum + item.totalPrice);

//   double get _discount {
//     final value = _parseMoney(_discountController.text);
//     if (value <= 0) return 0;
//     return value > _subtotal ? _subtotal : value;
//   }

//   double get _finalTotal {
//     final value = _subtotal - _discount;
//     return value < 0 ? 0 : value;
//   }

//   double get _paidAmount {
//     final value = _parseMoney(_paidController.text);
//     if (value <= 0) return 0;
//     return value > _finalTotal ? _finalTotal : value;
//   }

//   double get _remainingAmount {
//     final value = _finalTotal - _paidAmount;
//     return value < 0 ? 0 : value;
//   }

//   String get _paymentStatus {
//     if (_finalTotal <= 0 || _paidAmount >= _finalTotal) return 'paid';
//     if (_paidAmount <= 0) return 'unpaid';
//     return 'partial';
//   }

//   String _statusTitle(String status) {
//     switch (status) {
//       case 'paid':
//         return 'Paid';
//       case 'partial':
//         return 'Partial';
//       default:
//         return 'Unpaid';
//     }
//   }

//   String _generateBillNumber() {
//     final now = DateTime.now();
//     final random = Random().nextInt(9000) + 1000;
//     return 'RB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
//   }

//   Future<void> _selectDate({required bool isFrom}) async {
//     final initial = isFrom
//         ? (_dateFrom ?? DateTime.now())
//         : (_dateTill ?? _dateFrom ?? DateTime.now());

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );

//     if (picked == null || !mounted) return;

//     if (!isFrom && _dateFrom != null && picked.isBefore(_dateFrom!)) {
//       _showMessage('Return date cannot be before Date From.');
//       return;
//     }

//     setState(() {
//       if (isFrom) {
//         _dateFrom = picked;
//         if (_dateTill != null && _dateTill!.isBefore(picked)) {
//           _dateTill = null;
//         }
//       } else {
//         _dateTill = picked;
//       }
//     });
//   }

//   // IMPORTANT:
//   // The dialog is intentionally kept isolated from the parent form.
//   // Cancel only pops the dialog. It does not call setState, snackbar,
//   // or setDialogState after the dialog has been deactivated.
//   Future<void> _showAddItemModal() async {
//     String? selectedItemId;
//     int selectedAvailableStock = 0;
//     final quantityController = TextEditingController();
//     bool isAdding = false;

//     try {
//       await showDialog<void>(
//         context: context,
//         barrierDismissible: false,
//         builder: (dialogContext) {
//           return StatefulBuilder(
//             builder: (dialogViewContext, setDialogState) {
//               return AlertDialog(
//                 backgroundColor: _surface,
//                 surfaceTintColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//                 titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 8),
//                 contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
//                 actionsPadding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
//                 title: Row(
//                   children: [
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: _bronzeLight,
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       child: const Icon(
//                         Icons.add_shopping_cart_outlined,
//                         color: _bronzeDark,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Add Renting Item',
//                         style: TextStyle(
//                           color: _darkBrown,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 19,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: SizedBox(
//                   width: MediaQuery.of(dialogViewContext).size.width > 620
//                       ? 520
//                       : MediaQuery.of(dialogViewContext).size.width * .82,
//                   child: SingleChildScrollView(
//                     child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                       stream: FirebaseFirestore.instance
//                           .collection('inventory')
//                           .orderBy('name')
//                           .snapshots(),
//                       builder: (streamContext, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const SizedBox(
//                             height: 150,
//                             child: Center(
//                               child: CircularProgressIndicator(color: _bronze),
//                             ),
//                           );
//                         }

//                         if (snapshot.hasError) {
//                           return const Padding(
//                             padding: EdgeInsets.all(20),
//                             child: Text(
//                               'Unable to load inventory.',
//                               style: TextStyle(color: _mediumBrown),
//                             ),
//                           );
//                         }

//                         final documents = snapshot.data?.docs ?? [];

//                         if (documents.isEmpty) {
//                           return const Padding(
//                             padding: EdgeInsets.all(20),
//                             child: Text(
//                               'No inventory items found.',
//                               style: TextStyle(color: _mediumBrown),
//                             ),
//                           );
//                         }

//                         int remainingFor(
//                           QueryDocumentSnapshot<Map<String, dynamic>> doc,
//                         ) {
//                           final data = doc.data();
//                           final available =
//                               (data['availableStock'] as num?)?.toInt() ?? 0;
//                           return available - _getAlreadyAddedQuantity(doc.id);
//                         }

//                         if (selectedItemId != null) {
//                           for (final doc in documents) {
//                             if (doc.id == selectedItemId) {
//                               selectedAvailableStock = remainingFor(doc);
//                               break;
//                             }
//                           }
//                         }

//                         return Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             DropdownButtonFormField<String>(
//                               value: selectedItemId,
//                               isExpanded: true,
//                               decoration: _inputDecoration(
//                                 label: 'Select Item',
//                                 icon: Icons.inventory_2_outlined,
//                               ),
//                               items: documents.map((document) {
//                                 final data = document.data();
//                                 final name =
//                                     data['name']?.toString() ?? 'Unnamed Item';
//                                 final remaining = remainingFor(document);
//                                 final disabled = remaining <= 0;

//                                 // FIX:
//                                 // Never use null as the value for disabled
//                                 // dropdown entries. Multiple null values can
//                                 // trigger DropdownButton assertions.
//                                 return DropdownMenuItem<String>(
//                                   value: document.id,
//                                   enabled: !disabled,
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         _getCategoryIcon(
//                                           data['category']?.toString() ??
//                                               'Other',
//                                         ),
//                                         size: 20,
//                                         color: disabled ? Colors.grey : _bronze,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           name,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: TextStyle(
//                                             color: disabled
//                                                 ? Colors.grey
//                                                 : _darkBrown,
//                                           ),
//                                         ),
//                                       ),
//                                       Text(
//                                         disabled
//                                             ? 'Out of stock'
//                                             : '$remaining available',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: disabled
//                                               ? Colors.red
//                                               : Colors.green.shade700,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 if (!dialogViewContext.mounted) return;

//                                 setDialogState(() {
//                                   selectedItemId = value;
//                                   quantityController.clear();
//                                   selectedAvailableStock = 0;

//                                   if (value != null) {
//                                     for (final doc in documents) {
//                                       if (doc.id == value) {
//                                         selectedAvailableStock = remainingFor(
//                                           doc,
//                                         );
//                                         break;
//                                       }
//                                     }
//                                   }
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 14),
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: _bronzeLight.withOpacity(.38),
//                                 borderRadius: BorderRadius.circular(13),
//                                 border: Border.all(color: _bronzeLight),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 38,
//                                     height: 38,
//                                     decoration: BoxDecoration(
//                                       color: _surface,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Icon(
//                                       Icons.inventory_2_outlined,
//                                       size: 19,
//                                       color: _bronzeDark,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 11),
//                                   const Expanded(
//                                     child: Text(
//                                       'Available Stock',
//                                       style: TextStyle(
//                                         color: _mediumBrown,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     selectedItemId == null
//                                         ? '-'
//                                         : selectedAvailableStock.toString(),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w800,
//                                       fontSize: 18,
//                                       color: _bronzeDark,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 9),
//                             const Text(
//                               'Rented quantity cannot be greater than available stock.',
//                               style: TextStyle(color: _mutedText, fontSize: 12),
//                             ),
//                             const SizedBox(height: 14),
//                             TextFormField(
//                               controller: quantityController,
//                               keyboardType: TextInputType.number,
//                               decoration: _inputDecoration(
//                                 label: 'Quantity to Rent',
//                                 icon: Icons.numbers_outlined,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     // FIX:
//                     // Cancel does nothing to the parent form and does not
//                     // touch the deactivated StatefulBuilder context.
//                     onPressed: isAdding
//                         ? null
//                         : () => Navigator.of(dialogContext).pop(),
//                     style: TextButton.styleFrom(foregroundColor: _mediumBrown),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: isAdding
//                         ? null
//                         : () async {
//                             final quantity = int.tryParse(
//                               quantityController.text.trim(),
//                             );

//                             if (selectedItemId == null) {
//                               _showDialogMessage('Please select an item.');
//                               return;
//                             }

//                             if (quantity == null || quantity <= 0) {
//                               _showDialogMessage('Enter a valid quantity.');
//                               return;
//                             }

//                             if (quantity > selectedAvailableStock) {
//                               _showDialogMessage(
//                                 'Quantity cannot be greater than available stock.',
//                               );
//                               return;
//                             }

//                             setDialogState(() => isAdding = true);

//                             try {
//                               final selectedId = selectedItemId!;

//                               final selectedDocument = await FirebaseFirestore
//                                   .instance
//                                   .collection('inventory')
//                                   .doc(selectedId)
//                                   .get();

//                               if (!selectedDocument.exists) {
//                                 if (dialogViewContext.mounted) {
//                                   setDialogState(() => isAdding = false);
//                                 }
//                                 _showDialogMessage(
//                                   'Selected inventory item no longer exists.',
//                                 );
//                                 return;
//                               }

//                               final data = selectedDocument.data() ?? {};

//                               final itemName =
//                                   data['name']?.toString() ?? 'Unnamed Item';
//                               final category =
//                                   data['category']?.toString() ?? 'Other';
//                               final material =
//                                   data['material']?.toString() ?? 'Unknown';
//                               final rentPrice =
//                                   (data['rentPrice'] as num?)?.toDouble() ?? 0;

//                               if (!mounted) return;

//                               setState(() {
//                                 final existingIndex = _rentedItems.indexWhere(
//                                   (item) => item.itemId == selectedId,
//                                 );

//                                 if (existingIndex >= 0) {
//                                   _rentedItems[existingIndex].quantity +=
//                                       quantity;
//                                 } else {
//                                   _rentedItems.add(
//                                     RentedItem(
//                                       itemId: selectedId,
//                                       name: itemName,
//                                       category: category,
//                                       material: material,
//                                       quantity: quantity,
//                                       rentPrice: rentPrice,
//                                     ),
//                                   );
//                                 }
//                               });

//                               // Set the flag before popping. Do NOT execute
//                               // setDialogState after Navigator.pop().
//                               isAdding = false;

//                               if (dialogViewContext.mounted) {
//                                 Navigator.of(dialogContext).pop();
//                               }
//                             } catch (e) {
//                               if (dialogViewContext.mounted) {
//                                 setDialogState(() => isAdding = false);
//                                 _showDialogMessage('Unable to add item: $e');
//                               }
//                             }
//                           },
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Item'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _bronze,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 18,
//                         vertical: 13,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(11),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     } finally {
//       quantityController.dispose();
//     }
//   }

//   int _getAlreadyAddedQuantity(String itemId) {
//     for (final item in _rentedItems) {
//       if (item.itemId == itemId) return item.quantity;
//     }
//     return 0;
//   }

//   void _removeItem(int index) {
//     setState(() => _rentedItems.removeAt(index));
//   }

//   Future<void> _generateBill() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_dateFrom == null) {
//       _showMessage('Please select Date From.');
//       return;
//     }
//     if (_dateTill == null) {
//       _showMessage('Please select Return Date.');
//       return;
//     }
//     if (_rentedItems.isEmpty) {
//       _showMessage('Please add at least one renting item.');
//       return;
//     }

//     final cnicDigits = _cnicController.text.replaceAll(RegExp(r'[^0-9]'), '');
//     if (cnicDigits.length != 16) {
//       _showMessage('CNIC must contain exactly 16 digits.');
//       return;
//     }

//     final contactDigits = _contactController.text.replaceAll(
//       RegExp(r'[^0-9]'),
//       '',
//     );
//     if (contactDigits.length != 11 || !contactDigits.startsWith('03')) {
//       _showMessage('Contact number must be 11 digits and start with 03.');
//       return;
//     }

//     final subtotal = _subtotal;
//     final discount = _discount;
//     final finalTotal = _finalTotal;
//     final paidAmount = _paidAmount;
//     final remainingAmount = _remainingAmount;
//     final paymentStatus = _paymentStatus;

//     final billNumber = _generateBillNumber();
//     final generatedAt = DateTime.now();

//     setState(() => _isGenerating = true);

//     try {
//       final firestore = FirebaseFirestore.instance;
//       final billReference = firestore.collection('bills').doc();
//       final customerReference = firestore.collection('customers').doc();

//       await firestore.runTransaction((transaction) async {
//         final snapshots = <DocumentSnapshot<Map<String, dynamic>>>[];

//         for (final item in _rentedItems) {
//           final ref = firestore.collection('inventory').doc(item.itemId);
//           snapshots.add(await transaction.get(ref));
//         }

//         for (var i = 0; i < _rentedItems.length; i++) {
//           final item = _rentedItems[i];
//           final snapshot = snapshots[i];

//           if (!snapshot.exists) {
//             throw Exception('${item.name} no longer exists in inventory.');
//           }

//           final available =
//               (snapshot.data()?['availableStock'] as num?)?.toInt() ?? 0;

//           if (item.quantity > available) {
//             throw Exception(
//               'Only $available units of ${item.name} are available.',
//             );
//           }
//         }

//         for (var i = 0; i < _rentedItems.length; i++) {
//           final item = _rentedItems[i];
//           final snapshot = snapshots[i];
//           final data = snapshot.data() ?? {};

//           final available = (data['availableStock'] as num?)?.toInt() ?? 0;
//           final rented = (data['rentedStock'] as num?)?.toInt() ?? 0;

//           transaction.update(snapshot.reference, {
//             'availableStock': available - item.quantity,
//             'rentedStock': rented + item.quantity,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });
//         }

//         final billItems = _rentedItems
//             .map(
//               (item) => {
//                 'itemId': item.itemId,
//                 'name': item.name,
//                 'category': item.category,
//                 'material': item.material,
//                 'quantity': item.quantity,
//                 'rentPrice': item.rentPrice,
//                 'totalPrice': item.totalPrice,
//               },
//             )
//             .toList();

//         transaction.set(billReference, {
//           'billId': billReference.id,
//           'billNumber': billNumber,
//           'customerName': _nameController.text.trim(),
//           'contactNumber': _contactController.text.trim(),
//           'cnic': _cnicController.text.trim(),
//           'dateFrom': Timestamp.fromDate(_dateFrom!),
//           'dateTill': Timestamp.fromDate(_dateTill!),
//           'items': billItems,
//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,
//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,
//           'paymentStatus': paymentStatus,
//           'rentalStatus': 'rented',
//           'status': 'active',
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });

//         transaction.set(customerReference, {
//           'name': _nameController.text.trim(),
//           'contactNumber': _contactController.text.trim(),
//           'cnic': _cnicController.text.trim(),
//           'lastBillId': billReference.id,
//           'lastBillNumber': billNumber,
//           'lastRentalFrom': Timestamp.fromDate(_dateFrom!),
//           'lastRentalTill': Timestamp.fromDate(_dateTill!),
//           'rentalItems': billItems,
//           'subtotal': subtotal,
//           'discount': discount,
//           'totalAmount': finalTotal,
//           'paidAmount': paidAmount,
//           'remainingAmount': remainingAmount,
//           'paymentStatus': paymentStatus,
//           'rentalStatus': 'rented',
//           'createdAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       });

//       if (!mounted) return;

//       final pdf = await _buildBillPdf(
//         billNumber: billNumber,
//         generatedAt: generatedAt,
//       );

//       if (!mounted) return;

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BillPreviewScreen(
//             pdfBytes: pdf,
//             billId: billNumber,
//             customerName: _nameController.text.trim(),
//           ),
//         ),
//       );

//       if (!mounted) return;

//       _nameController.clear();
//       _cnicController.clear();
//       _contactController.clear();
//       _discountController.text = '0';
//       _paidController.text = '0';

//       setState(() {
//         _dateFrom = null;
//         _dateTill = null;
//         _rentedItems.clear();
//       });

//       _showMessage('Bill $billNumber generated successfully.');
//     } catch (e) {
//       if (!mounted) return;
//       var message = e.toString();
//       if (message.startsWith('Exception: ')) {
//         message = message.substring(11);
//       }
//       _showMessage('Bill could not be generated: $message');
//     } finally {
//       if (mounted) setState(() => _isGenerating = false);
//     }
//   }

//   Future<Uint8List> _buildBillPdf({
//     required String billNumber,
//     required DateTime generatedAt,
//   }) async {
//     final pdf = pw.Document();
//     final status = _paymentStatus;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (_) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Container(
//               padding: const pw.EdgeInsets.all(18),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey400),
//                 borderRadius: pw.BorderRadius.circular(12),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'RENTAL BILL',
//                         style: pw.TextStyle(
//                           fontSize: 25,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text(
//                         'Inventory Management',
//                         style: const pw.TextStyle(
//                           fontSize: 10,
//                           color: PdfColors.grey700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.Container(
//                     padding: const pw.EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     decoration: pw.BoxDecoration(
//                       border: pw.Border.all(color: PdfColors.grey500),
//                       borderRadius: pw.BorderRadius.circular(8),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment: pw.CrossAxisAlignment.end,
//                       children: [
//                         pw.Text(
//                           'BILL #',
//                           style: const pw.TextStyle(
//                             fontSize: 8,
//                             color: PdfColors.grey700,
//                           ),
//                         ),
//                         pw.SizedBox(height: 3),
//                         pw.Text(
//                           billNumber,
//                           style: pw.TextStyle(
//                             fontSize: 11,
//                             fontWeight: pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 4),
//                         pw.Text(
//                           'Generated: ${_formatDate(generatedAt)}',
//                           style: const pw.TextStyle(
//                             fontSize: 8,
//                             color: PdfColors.grey700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 18),
//             pw.Text(
//               'CUSTOMER DETAILS',
//               style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Container(
//               width: double.infinity,
//               padding: const pw.EdgeInsets.all(12),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.grey100,
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 children: [
//                   pw.Row(
//                     children: [
//                       pw.Expanded(
//                         child: pw.Text('Name: ${_nameController.text.trim()}'),
//                       ),
//                       pw.Expanded(
//                         child: pw.Text(
//                           'Contact: ${_contactController.text.trim()}',
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.SizedBox(height: 7),
//                   pw.Row(
//                     children: [
//                       pw.Expanded(
//                         child: pw.Text('CNIC: ${_cnicController.text.trim()}'),
//                       ),
//                       pw.Expanded(
//                         child: pw.Text(
//                           'Bill Date: ${_formatDate(generatedAt)}',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 18),
//             pw.Text(
//               'RENTAL PERIOD',
//               style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Container(
//               width: double.infinity,
//               padding: const pw.EdgeInsets.all(11),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey400),
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text('From: ${_formatDate(_dateFrom!)}'),
//                   pw.Text('Return: ${_formatDate(_dateTill!)}'),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 18),
//             pw.Text(
//               'RENTED ITEMS',
//               style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
//             ),
//             pw.SizedBox(height: 8),
//             pw.Table(
//               border: pw.TableBorder.all(color: PdfColors.grey400),
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(3),
//                 1: const pw.FlexColumnWidth(1.1),
//                 2: const pw.FlexColumnWidth(1.5),
//                 3: const pw.FlexColumnWidth(1.7),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                   children: [
//                     _pdfCell('Item', bold: true),
//                     _pdfCell('Qty', bold: true),
//                     _pdfCell('Rate', bold: true),
//                     _pdfCell('Amount', bold: true),
//                   ],
//                 ),
//                 ..._rentedItems.map(
//                   (item) => pw.TableRow(
//                     children: [
//                       _pdfCell(item.name),
//                       _pdfCell(item.quantity.toString()),
//                       _pdfCell('Rs. ${item.rentPrice.toStringAsFixed(0)}'),
//                       _pdfCell('Rs. ${item.totalPrice.toStringAsFixed(0)}'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 18),
//             pw.Align(
//               alignment: pw.Alignment.centerRight,
//               child: pw.Container(
//                 width: 270,
//                 padding: const pw.EdgeInsets.all(14),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     _pdfAmountRow('Actual Amount', _subtotal),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow('Discount', _discount),
//                     pw.Divider(),
//                     _pdfAmountRow('Total Amount', _finalTotal, bold: true),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow('Paid', _paidAmount),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow('Remaining', _remainingAmount, bold: true),
//                   ],
//                 ),
//               ),
//             ),
//             pw.SizedBox(height: 14),
//             pw.Align(
//               alignment: pw.Alignment.centerRight,
//               child: pw.Container(
//                 padding: const pw.EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: pw.BoxDecoration(
//                   border: pw.Border.all(
//                     color: status == 'paid'
//                         ? PdfColors.green
//                         : status == 'partial'
//                         ? PdfColors.orange
//                         : PdfColors.red,
//                   ),
//                   borderRadius: pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Text(
//                   _statusTitle(status).toUpperCase(),
//                   style: pw.TextStyle(
//                     fontSize: 13,
//                     fontWeight: pw.FontWeight.bold,
//                     color: status == 'paid'
//                         ? PdfColors.green
//                         : status == 'partial'
//                         ? PdfColors.orange
//                         : PdfColors.red,
//                   ),
//                 ),
//               ),
//             ),
//             pw.SizedBox(height: 14),
//             if (status != 'paid')
//               pw.Container(
//                 width: double.infinity,
//                 padding: const pw.EdgeInsets.all(12),
//                 decoration: pw.BoxDecoration(
//                   color: PdfColors.grey100,
//                   border: pw.Border.all(color: PdfColors.grey400),
//                   borderRadius: pw.BorderRadius.circular(8),
//                 ),
//                 child: pw.Text(
//                   status == 'unpaid'
//                       ? 'Payment Note: Bill payment is due on or before the return date.'
//                       : 'Payment Note: Remaining balance of Rs. ${_remainingAmount.toStringAsFixed(0)} is due on or before the return date.',
//                   style: const pw.TextStyle(
//                     fontSize: 9,
//                     color: PdfColors.grey800,
//                   ),
//                 ),
//               ),
//             pw.Spacer(),
//             pw.Divider(),
//             pw.SizedBox(height: 7),
//             pw.Center(
//               child: pw.Text(
//                 'Thank you for your business.',
//                 style: const pw.TextStyle(
//                   fontSize: 9,
//                   color: PdfColors.grey600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     return Uint8List.fromList(await pdf.save());
//   }

//   pw.Widget _pdfAmountRow(String label, double amount, {bool bold = false}) {
//     return pw.Row(
//       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   pw.Widget _pdfCell(String text, {bool bold = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   Widget _rentedItemCard(RentedItem item, int index, {bool compact = false}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _border),
//         boxShadow: [
//           BoxShadow(
//             color: _darkBrown.withOpacity(.035),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: compact
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     _itemIcon(item),
//                     const SizedBox(width: 12),
//                     Expanded(child: _itemName(item)),
//                     _removeButton(index),
//                   ],
//                 ),
//                 const SizedBox(height: 13),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _itemInfoChip('Qty', item.quantity.toString(), _bronze),
//                     _itemInfoChip(
//                       'Rate',
//                       'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                       _mediumBrown,
//                     ),
//                     _itemInfoChip(
//                       'Amount',
//                       'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                       _bronzeDark,
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 _itemIcon(item),
//                 const SizedBox(width: 14),
//                 Expanded(child: _itemName(item)),
//                 const SizedBox(width: 12),
//                 _itemInfoChip('Quantity', item.quantity.toString(), _bronze),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   width: 120,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'Amount',
//                         style: TextStyle(fontSize: 11, color: _mutedText),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w800,
//                           fontSize: 15,
//                           color: _darkBrown,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _removeButton(index),
//               ],
//             ),
//     );
//   }

//   Widget _itemIcon(RentedItem item) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: _bronzeLight.withOpacity(.45),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Icon(
//         _getCategoryIcon(item.category),
//         color: _bronzeDark,
//         size: 25,
//       ),
//     );
//   }

//   Widget _itemName(RentedItem item) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           item.name,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           'Material: ${item.material}',
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(fontSize: 12, color: _mutedText),
//         ),
//       ],
//     );
//   }

//   Widget _itemInfoChip(String label, String value, Color valueColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: valueColor.withOpacity(.07),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: valueColor.withOpacity(.12)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 9, color: _mutedText)),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w800,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _removeButton(int index) {
//     return IconButton(
//       tooltip: 'Remove Item',
//       onPressed: () => _removeItem(index),
//       style: IconButton.styleFrom(
//         backgroundColor: Colors.red.withOpacity(.07),
//         foregroundColor: Colors.red.shade700,
//       ),
//       icon: const Icon(Icons.close, size: 19),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair_outlined;
//       case 'Decoration':
//         return Icons.auto_awesome_outlined;
//       case 'Tent':
//         return Icons.house_outlined;
//       case 'Lighting':
//         return Icons.lightbulb_outline;
//       case 'Sound Equipment':
//         return Icons.speaker_outlined;
//       case 'Stage Equipment':
//         return Icons.theater_comedy_outlined;
//       case 'Catering':
//         return Icons.restaurant_outlined;
//       default:
//         return Icons.inventory_2_outlined;
//     }
//   }

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: _mutedText, fontSize: 13),
//       prefixIcon: Icon(icon, color: _bronze, size: 21),
//       filled: true,
//       fillColor: _surface,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(color: _border),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(color: _border),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(color: _bronze, width: 1.6),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(color: Colors.red),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(13),
//         borderSide: const BorderSide(color: Colors.red, width: 1.4),
//       ),
//     );
//   }

//   Widget _summaryRow(
//     String label,
//     double amount, {
//     bool bold = false,
//     Color? valueColor,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: bold ? 15 : 13,
//               fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//               color: bold ? _darkBrown : _mediumBrown,
//             ),
//           ),
//         ),
//         Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: TextStyle(
//             fontSize: bold ? 17 : 14,
//             fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
//             color: valueColor ?? _darkBrown,
//           ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   Widget _dateField({
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//         decoration: BoxDecoration(
//           color: _surface,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _border),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: _bronzeLight.withOpacity(.42),
//                 borderRadius: BorderRadius.circular(11),
//               ),
//               child: const Icon(
//                 Icons.calendar_month_outlined,
//                 color: _bronzeDark,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: _mutedText,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     date == null ? 'Select date' : _formatDate(date),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: date == null ? _mutedText : _darkBrown,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.keyboard_arrow_down_rounded, color: _mutedText),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _sectionTitle(String title, {String? subtitle}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         if (subtitle != null) ...[
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: const TextStyle(fontSize: 12, color: _mutedText),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _sectionCard({
//     required Widget child,
//     EdgeInsets padding = const EdgeInsets.all(20),
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: padding,
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _border),
//         boxShadow: [
//           BoxShadow(
//             color: _darkBrown.withOpacity(.035),
//             blurRadius: 18,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildHeader(bool mobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(mobile ? 18 : 24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [_bronzeDark, _bronze],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: mobile
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _headerIcon(),
//                 const SizedBox(height: 15),
//                 _headerText(),
//               ],
//             )
//           : Row(
//               children: [
//                 _headerIcon(),
//                 const SizedBox(width: 16),
//                 Expanded(child: _headerText()),
//               ],
//             ),
//     );
//   }

//   Widget _headerIcon() {
//     return Container(
//       width: 58,
//       height: 58,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(.15),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withOpacity(.18)),
//       ),
//       child: const Icon(
//         Icons.receipt_long_outlined,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   Widget _headerText() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'New Rental Bill',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Create a rental bill, record payment, and update inventory stock.',
//           style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
//         ),
//       ],
//     );
//   }

//   Widget _addItemButton() {
//     return ElevatedButton.icon(
//       onPressed: _showAddItemModal,
//       icon: const Icon(Icons.add, size: 19),
//       label: const Text(
//         'Add Item',
//         style: TextStyle(fontWeight: FontWeight.w700),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _bronze,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
//       ),
//     );
//   }

//   Widget _emptyItemsState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
//       decoration: BoxDecoration(
//         color: _background,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: _border),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 58,
//             height: 58,
//             decoration: BoxDecoration(
//               color: _bronzeLight.withOpacity(.42),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.shopping_cart_outlined,
//               size: 27,
//               color: _bronzeDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'No renting items added',
//             style: TextStyle(fontWeight: FontWeight.w800, color: _darkBrown),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Click "Add Item" to select inventory items.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: _mutedText, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _amountSummary() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: _background,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _border),
//       ),
//       child: Column(
//         children: [
//           _summaryRow('Actual Amount', _subtotal),
//           const SizedBox(height: 14),
//           TextFormField(
//             controller: _discountController,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             onChanged: (_) => setState(() {}),
//             decoration: _inputDecoration(
//               label: 'Discount Amount',
//               icon: Icons.discount_outlined,
//             ).copyWith(hintText: '0'),
//           ),
//           const SizedBox(height: 13),
//           _summaryRow(
//             'Discount',
//             _discount,
//             valueColor: Colors.orange.shade700,
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 15),
//             child: Divider(color: _border),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
//             decoration: BoxDecoration(
//               color: _bronzeLight.withOpacity(.35),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: _summaryRow(
//               'Total Amount',
//               _finalTotal,
//               bold: true,
//               valueColor: _bronzeDark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _paymentDetails(String status) {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _paidController,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           onChanged: (_) => setState(() {}),
//           decoration: _inputDecoration(
//             label: 'Paid Amount',
//             icon: Icons.payments_outlined,
//           ).copyWith(hintText: '0'),
//         ),
//         const SizedBox(height: 14),
//         _summaryRow('Paid', _paidAmount, valueColor: Colors.green.shade700),
//         const SizedBox(height: 11),
//         _summaryRow(
//           'Remaining',
//           _remainingAmount,
//           bold: true,
//           valueColor: _remainingAmount > 0
//               ? Colors.red.shade700
//               : Colors.green.shade700,
//         ),
//         const SizedBox(height: 17),
//         _paymentStatusCard(status),
//       ],
//     );
//   }

//   Widget _paymentStatusCard(String status) {
//     final color = status == 'paid'
//         ? Colors.green.shade700
//         : status == 'partial'
//         ? Colors.orange.shade700
//         : Colors.red.shade700;

//     final icon = status == 'paid'
//         ? Icons.check_circle_outline
//         : status == 'partial'
//         ? Icons.timelapse
//         : Icons.pending_actions_outlined;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.07),
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: color.withOpacity(.14)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 23),
//           const SizedBox(width: 11),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Payment Status',
//                   style: TextStyle(color: _mutedText, fontSize: 11),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _statusTitle(status),
//                   style: TextStyle(fontWeight: FontWeight.w800, color: color),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormContent(bool mobile) {
//     final status = _paymentStatus;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildHeader(mobile),
//         const SizedBox(height: 24),
//         _sectionCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _sectionTitle(
//                 'Customer Details',
//                 subtitle: 'Enter the customer information for this rental.',
//               ),
//               const SizedBox(height: 18),
//               LayoutBuilder(
//                 builder: (_, box) {
//                   final two = box.maxWidth >= 700;

//                   final fields = [
//                     TextFormField(
//                       controller: _nameController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: _inputDecoration(
//                         label: 'Customer Name',
//                         icon: Icons.person_outline,
//                       ),
//                       validator: (v) => v == null || v.trim().isEmpty
//                           ? 'Please enter customer name.'
//                           : null,
//                     ),
//                     TextFormField(
//                       controller: _contactController,
//                       keyboardType: TextInputType.phone,
//                       onChanged: _formatContact,
//                       decoration: _inputDecoration(
//                         label: 'Contact Number',
//                         icon: Icons.phone_outlined,
//                       ).copyWith(hintText: '0300-1234567'),
//                       validator: (v) {
//                         final d = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
//                         return d.length != 11 || !d.startsWith('03')
//                             ? 'Enter a valid 11-digit mobile number.'
//                             : null;
//                       },
//                     ),
//                     TextFormField(
//                       controller: _cnicController,
//                       keyboardType: TextInputType.number,
//                       onChanged: _formatCnic,
//                       decoration: _inputDecoration(
//                         label: 'CNIC #',
//                         icon: Icons.badge_outlined,
//                       ).copyWith(hintText: 'XXXXX-XXXXX-XXXXXX'),
//                       validator: (v) {
//                         final d = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
//                         return d.length != 16
//                             ? 'CNIC must contain exactly 16 digits.'
//                             : null;
//                       },
//                     ),
//                   ];

//                   if (!two) {
//                     return Column(
//                       children: [
//                         fields[0],
//                         const SizedBox(height: 14),
//                         fields[1],
//                         const SizedBox(height: 14),
//                         fields[2],
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(child: fields[0]),
//                       const SizedBox(width: 14),
//                       Expanded(child: fields[1]),
//                       const SizedBox(width: 14),
//                       Expanded(child: fields[2]),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 18),
//         _sectionCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _sectionTitle(
//                 'Rental Period',
//                 subtitle:
//                     'Select when the rental starts and when the items are expected back.',
//               ),
//               const SizedBox(height: 18),
//               LayoutBuilder(
//                 builder: (_, box) {
//                   if (box.maxWidth < 600) {
//                     return Column(
//                       children: [
//                         _dateField(
//                           title: 'Date From',
//                           date: _dateFrom,
//                           onTap: () => _selectDate(isFrom: true),
//                         ),
//                         const SizedBox(height: 12),
//                         _dateField(
//                           title: 'Return Date',
//                           date: _dateTill,
//                           onTap: () => _selectDate(isFrom: false),
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(
//                         child: _dateField(
//                           title: 'Date From',
//                           date: _dateFrom,
//                           onTap: () => _selectDate(isFrom: true),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: _dateField(
//                           title: 'Return Date',
//                           date: _dateTill,
//                           onTap: () => _selectDate(isFrom: false),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 18),
//         _sectionCard(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               LayoutBuilder(
//                 builder: (_, box) {
//                   if (box.maxWidth < 520) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _sectionTitle(
//                           'Renting Items',
//                           subtitle: 'Items selected for this rental.',
//                         ),
//                         const SizedBox(height: 14),
//                         SizedBox(
//                           width: double.infinity,
//                           child: _addItemButton(),
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(
//                         child: _sectionTitle(
//                           'Renting Items',
//                           subtitle: 'Items selected for this rental.',
//                         ),
//                       ),
//                       _addItemButton(),
//                     ],
//                   );
//                 },
//               ),
//               const SizedBox(height: 18),
//               if (_rentedItems.isEmpty)
//                 _emptyItemsState()
//               else
//                 LayoutBuilder(
//                   builder: (_, box) {
//                     final compact = box.maxWidth < 680;
//                     return Column(
//                       children: List.generate(
//                         _rentedItems.length,
//                         (i) => _rentedItemCard(
//                           _rentedItems[i],
//                           i,
//                           compact: compact,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//         if (_rentedItems.isNotEmpty) ...[
//           const SizedBox(height: 18),
//           _sectionCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _sectionTitle(
//                   'Bill Summary & Payment',
//                   subtitle:
//                       'Review the amount and record the customer payment.',
//                 ),
//                 const SizedBox(height: 18),
//                 LayoutBuilder(
//                   builder: (_, box) {
//                     if (box.maxWidth < 780) {
//                       return Column(
//                         children: [
//                           _amountSummary(),
//                           const SizedBox(height: 22),
//                           _paymentDetails(status),
//                         ],
//                       );
//                     }

//                     return Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(child: _amountSummary()),
//                         const SizedBox(width: 24),
//                         Expanded(child: _paymentDetails(status)),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//         const SizedBox(height: 22),
//         SizedBox(
//           width: double.infinity,
//           height: 58,
//           child: ElevatedButton.icon(
//             onPressed: _isGenerating ? null : _generateBill,
//             icon: _isGenerating
//                 ? const SizedBox(
//                     width: 21,
//                     height: 21,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Icon(Icons.receipt_long_outlined),
//             label: Text(
//               _isGenerating ? 'Generating Bill...' : 'Generate Bill',
//               style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _bronzeDark,
//               foregroundColor: Colors.white,
//               disabledBackgroundColor: _bronze.withOpacity(.5),
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _background,
//       appBar: AppBar(
//         backgroundColor: _surface,
//         foregroundColor: _darkBrown,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         titleSpacing: 18,
//         title: const Text(
//           'Create New Bill',
//           style: TextStyle(fontWeight: FontWeight.w800, color: _darkBrown),
//         ),
//       ),
//       drawer: const AdminDrawer(selectedIndex: 3),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (_, constraints) {
//             final width = constraints.maxWidth;
//             final mobile = width < 650;
//             final tablet = width >= 650 && width < 950;
//             final horizontal = mobile
//                 ? 14.0
//                 : tablet
//                 ? 24.0
//                 : 34.0;

//             return SingleChildScrollView(
//               padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 35),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 1120),
//                   child: Form(key: _formKey, child: _buildFormContent(mobile)),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   void _showMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _darkBrown,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   void _showDialogMessage(String message) {
//     if (!mounted) return;
//     // Use the parent State context, not the dialog's deactivated context.
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: _darkBrown,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
// }

// class RentedItem {
//   final String itemId;
//   final String name;
//   final String category;
//   final String material;
//   int quantity;
//   final double rentPrice;

//   RentedItem({
//     required this.itemId,
//     required this.name,
//     required this.category,
//     required this.material,
//     required this.quantity,
//     required this.rentPrice,
//   });

//   double get totalPrice => quantity * rentPrice;
// }

// class BillPreviewScreen extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billId;
//   final String customerName;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billId,
//     required this.customerName,
//   });

//   Future<void> _savePdf(BuildContext context) async {
//     try {
//       await Printing.sharePdf(
//         bytes: pdfBytes,
//         filename: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       );

//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Bill ready to save/share.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (_) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to save/share the bill.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _BillScreenState._background,
//       appBar: AppBar(
//         backgroundColor: _BillScreenState._surface,
//         foregroundColor: _BillScreenState._darkBrown,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Bill Preview',
//           style: TextStyle(fontWeight: FontWeight.w800),
//         ),
//         actions: [
//           IconButton(
//             tooltip: 'Save / Download Bill',
//             onPressed: () => _savePdf(context),
//             style: IconButton.styleFrom(
//               foregroundColor: _BillScreenState._bronzeDark,
//             ),
//             icon: const Icon(Icons.save_outlined),
//           ),
//           IconButton(
//             tooltip: 'Print / Share',
//             onPressed: () async {
//               try {
//                 await Printing.sharePdf(
//                   bytes: pdfBytes,
//                   filename: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//                 );
//               } catch (_) {}
//             },
//             style: IconButton.styleFrom(
//               foregroundColor: _BillScreenState._bronzeDark,
//             ),
//             icon: const Icon(Icons.print_outlined),
//           ),
//           const SizedBox(width: 6),
//         ],
//       ),
//       body: PdfPreview(
//         build: (_) async => pdfBytes,
//         canChangePageFormat: false,
//         canChangeOrientation: false,
//         allowPrinting: true,
//         allowSharing: true,
//         pdfFileName: 'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       ),
//     );
//   }
// }








// import 'dart:math';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillScreen extends StatefulWidget {
//   const BillScreen({super.key});

//   @override
//   State<BillScreen> createState() => _BillScreenState();
// }

// class _BillScreenState extends State<BillScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _nameController = TextEditingController();
//   final _cnicController = TextEditingController();
//   final _contactController = TextEditingController();
//   final _discountController = TextEditingController(text: '0');
//   final _paidController = TextEditingController(text: '0');

//   DateTime? _dateFrom;
//   DateTime? _dateTill;

//   final List<RentedItem> _rentedItems = [];
//   bool _isGenerating = false;

//   static const Color _background = Color(0xFFF7F2EA);
//   static const Color _surface = Color(0xFFFFFCF8);
//   static const Color _bronze = Color(0xFF9A6A3A);
//   static const Color _bronzeDark = Color(0xFF704823);
//   static const Color _bronzeLight = Color(0xFFE9D6BC);
//   static const Color _darkBrown = Color(0xFF2C2119);
//   static const Color _mediumBrown = Color(0xFF59483A);
//   static const Color _mutedText = Color(0xFF8A7B6E);
//   static const Color _border = Color(0xFFE6D9CB);

//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   // ============================================================
//   // CURRENT USER / USER-SCOPED FIRESTORE COLLECTIONS
//   // ============================================================

//   User? get _currentUser => FirebaseAuth.instance.currentUser;

//   DocumentReference<Map<String, dynamic>> get _userDocument {
//     final user = _currentUser;

//     if (user == null) {
//       throw Exception('No user is currently logged in.');
//     }

//     return _db.collection('Users').doc(user.uid);
//   }

//   CollectionReference<Map<String, dynamic>> get _inventoryCollection {
//     return _userDocument.collection('inventory');
//   }

//   CollectionReference<Map<String, dynamic>> get _billsCollection {
//     return _userDocument.collection('bills');
//   }

//   CollectionReference<Map<String, dynamic>> get _customersCollection {
//     return _userDocument.collection('customers');
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _cnicController.dispose();
//     _contactController.dispose();
//     _discountController.dispose();
//     _paidController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // CNIC FORMAT
//   // ============================================================

//   void _formatCnic(String value) {
//     var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 16) {
//       digits = digits.substring(0, 16);
//     }

//     var formatted = '';

//     for (var i = 0; i < digits.length; i++) {
//       if (i == 5 || i == 10) {
//         formatted += '-';
//       }

//       formatted += digits[i];
//     }

//     _cnicController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(
//         offset: formatted.length,
//       ),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // CONTACT FORMAT
//   // ============================================================

//   void _formatContact(String value) {
//     var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

//     if (digits.length > 11) {
//       digits = digits.substring(0, 11);
//     }

//     final formatted = digits.length > 4
//         ? '${digits.substring(0, 4)}-${digits.substring(4)}'
//         : digits;

//     _contactController.value = TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(
//         offset: formatted.length,
//       ),
//     );

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // ============================================================
//   // MONEY
//   // ============================================================

//   double _parseMoney(String value) {
//     return double.tryParse(
//           value.replaceAll(',', '').trim(),
//         ) ??
//         0;
//   }

//   double get _subtotal {
//     return _rentedItems.fold(
//       0,
//       (sum, item) => sum + item.totalPrice,
//     );
//   }

//   double get _discount {
//     final value = _parseMoney(_discountController.text);

//     if (value <= 0) {
//       return 0;
//     }

//     return value > _subtotal ? _subtotal : value;
//   }

//   double get _finalTotal {
//     final value = _subtotal - _discount;

//     return value < 0 ? 0 : value;
//   }

//   double get _paidAmount {
//     final value = _parseMoney(_paidController.text);

//     if (value <= 0) {
//       return 0;
//     }

//     return value > _finalTotal ? _finalTotal : value;
//   }

//   double get _remainingAmount {
//     final value = _finalTotal - _paidAmount;

//     return value < 0 ? 0 : value;
//   }

//   String get _paymentStatus {
//     if (_finalTotal <= 0 || _paidAmount >= _finalTotal) {
//       return 'paid';
//     }

//     if (_paidAmount <= 0) {
//       return 'unpaid';
//     }

//     return 'partial';
//   }

//   String _statusTitle(String status) {
//     switch (status) {
//       case 'paid':
//         return 'Paid';

//       case 'partial':
//         return 'Partial';

//       default:
//         return 'Unpaid';
//     }
//   }

//   // ============================================================
//   // BILL NUMBER
//   // ============================================================

//   String _generateBillNumber() {
//     final now = DateTime.now();
//     final random = Random().nextInt(9000) + 1000;

//     return 'RB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
//   }

//   // ============================================================
//   // DATE PICKER
//   // ============================================================

//   Future<void> _selectDate({
//     required bool isFrom,
//   }) async {
//     final initial = isFrom
//         ? (_dateFrom ?? DateTime.now())
//         : (_dateTill ?? _dateFrom ?? DateTime.now());

//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );

//     if (picked == null || !mounted) {
//       return;
//     }

//     if (!isFrom &&
//         _dateFrom != null &&
//         picked.isBefore(_dateFrom!)) {
//       _showMessage(
//         'Return date cannot be before Date From.',
//       );
//       return;
//     }

//     setState(() {
//       if (isFrom) {
//         _dateFrom = picked;

//         if (_dateTill != null &&
//             _dateTill!.isBefore(picked)) {
//           _dateTill = null;
//         }
//       } else {
//         _dateTill = picked;
//       }
//     });
//   }

//   // ============================================================
//   // ADD RENTING ITEM MODAL
//   // ============================================================

//   Future<void> _showAddItemModal() async {
//     String? selectedItemId;
//     int selectedAvailableStock = 0;

//     final quantityController = TextEditingController();

//     bool isAdding = false;

//     try {
//       await showDialog<void>(
//         context: context,
//         barrierDismissible: false,
//         builder: (dialogContext) {
//           return StatefulBuilder(
//             builder: (
//               dialogViewContext,
//               setDialogState,
//             ) {
//               return AlertDialog(
//                 backgroundColor: _surface,
//                 surfaceTintColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//                 titlePadding: const EdgeInsets.fromLTRB(
//                   24,
//                   22,
//                   24,
//                   8,
//                 ),
//                 contentPadding: const EdgeInsets.fromLTRB(
//                   24,
//                   10,
//                   24,
//                   8,
//                 ),
//                 actionsPadding: const EdgeInsets.fromLTRB(
//                   18,
//                   8,
//                   18,
//                   18,
//                 ),
//                 title: Row(
//                   children: [
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: _bronzeLight,
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       child: const Icon(
//                         Icons.add_shopping_cart_outlined,
//                         color: _bronzeDark,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Add Renting Item',
//                         style: TextStyle(
//                           color: _darkBrown,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 19,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: SizedBox(
//                   width: MediaQuery.of(dialogViewContext).size.width > 620
//                       ? 520
//                       : MediaQuery.of(dialogViewContext).size.width * .82,
//                   child: SingleChildScrollView(
//                     child: StreamBuilder<
//                         QuerySnapshot<Map<String, dynamic>>>(
//                       // IMPORTANT:
//                       // Fetch inventory ONLY for the current user.
//                       stream: _inventoryCollection
//                           .orderBy('name')
//                           .snapshots(),
//                       builder: (
//                         streamContext,
//                         snapshot,
//                       ) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const SizedBox(
//                             height: 150,
//                             child: Center(
//                               child: CircularProgressIndicator(
//                                 color: _bronze,
//                               ),
//                             ),
//                           );
//                         }

//                         if (snapshot.hasError) {
//                           return const Padding(
//                             padding: EdgeInsets.all(20),
//                             child: Text(
//                               'Unable to load inventory.',
//                               style: TextStyle(
//                                 color: _mediumBrown,
//                               ),
//                             ),
//                           );
//                         }

//                         final documents =
//                             snapshot.data?.docs ?? [];

//                         if (documents.isEmpty) {
//                           return const Padding(
//                             padding: EdgeInsets.all(20),
//                             child: Text(
//                               'No inventory items found.',
//                               style: TextStyle(
//                                 color: _mediumBrown,
//                               ),
//                             ),
//                           );
//                         }

//                         int remainingFor(
//                           QueryDocumentSnapshot<
//                                   Map<String, dynamic>>
//                               doc,
//                         ) {
//                           final data = doc.data();

//                           final available =
//                               (data['availableStock'] as num?)
//                                       ?.toInt() ??
//                                   0;

//                           return available -
//                               _getAlreadyAddedQuantity(
//                                 doc.id,
//                               );
//                         }

//                         if (selectedItemId != null) {
//                           for (final doc in documents) {
//                             if (doc.id == selectedItemId) {
//                               selectedAvailableStock =
//                                   remainingFor(doc);
//                               break;
//                             }
//                           }
//                         }

//                         return Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             DropdownButtonFormField<String>(
//                               value: selectedItemId,
//                               isExpanded: true,
//                               decoration: _inputDecoration(
//                                 label: 'Select Item',
//                                 icon:
//                                     Icons.inventory_2_outlined,
//                               ),
//                               items: documents.map(
//                                 (document) {
//                                   final data =
//                                       document.data();

//                                   final name =
//                                       data['name']?.toString() ??
//                                           'Unnamed Item';

//                                   final remaining =
//                                       remainingFor(document);

//                                   final disabled =
//                                       remaining <= 0;

//                                   return DropdownMenuItem<
//                                       String>(
//                                     value: document.id,
//                                     enabled: !disabled,
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           _getCategoryIcon(
//                                             data['category']
//                                                     ?.toString() ??
//                                                 'Other',
//                                           ),
//                                           size: 20,
//                                           color: disabled
//                                               ? Colors.grey
//                                               : _bronze,
//                                         ),
//                                         const SizedBox(width: 10),
//                                         Expanded(
//                                           child: Text(
//                                             name,
//                                             overflow:
//                                                 TextOverflow
//                                                     .ellipsis,
//                                             style: TextStyle(
//                                               color: disabled
//                                                   ? Colors.grey
//                                                   : _darkBrown,
//                                             ),
//                                           ),
//                                         ),
//                                         Text(
//                                           disabled
//                                               ? 'Out of stock'
//                                               : '$remaining available',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: disabled
//                                                 ? Colors.red
//                                                 : Colors
//                                                     .green
//                                                     .shade700,
//                                             fontWeight:
//                                                 FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ).toList(),
//                               onChanged: (value) {
//                                 if (!dialogViewContext.mounted) {
//                                   return;
//                                 }

//                                 setDialogState(() {
//                                   selectedItemId = value;
//                                   quantityController.clear();
//                                   selectedAvailableStock = 0;

//                                   if (value != null) {
//                                     for (final doc in documents) {
//                                       if (doc.id == value) {
//                                         selectedAvailableStock =
//                                             remainingFor(doc);
//                                         break;
//                                       }
//                                     }
//                                   }
//                                 });
//                               },
//                             ),
//                             const SizedBox(height: 14),
//                             Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color:
//                                     _bronzeLight.withOpacity(.38),
//                                 borderRadius:
//                                     BorderRadius.circular(13),
//                                 border: Border.all(
//                                   color: _bronzeLight,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 38,
//                                     height: 38,
//                                     decoration: BoxDecoration(
//                                       color: _surface,
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                               10),
//                                     ),
//                                     child: const Icon(
//                                       Icons.inventory_2_outlined,
//                                       size: 19,
//                                       color: _bronzeDark,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 11),
//                                   const Expanded(
//                                     child: Text(
//                                       'Available Stock',
//                                       style: TextStyle(
//                                         color: _mediumBrown,
//                                         fontWeight:
//                                             FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                   Text(
//                                     selectedItemId == null
//                                         ? '-'
//                                         : selectedAvailableStock
//                                             .toString(),
//                                     style: const TextStyle(
//                                       fontWeight:
//                                           FontWeight.w800,
//                                       fontSize: 18,
//                                       color: _bronzeDark,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 9),
//                             const Text(
//                               'Rented quantity cannot be greater than available stock.',
//                               style: TextStyle(
//                                 color: _mutedText,
//                                 fontSize: 12,
//                               ),
//                             ),
//                             const SizedBox(height: 14),
//                             TextFormField(
//                               controller: quantityController,
//                               keyboardType:
//                                   TextInputType.number,
//                               decoration: _inputDecoration(
//                                 label: 'Quantity to Rent',
//                                 icon: Icons.numbers_outlined,
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: isAdding
//                         ? null
//                         : () => Navigator.of(
//                               dialogContext,
//                             ).pop(),
//                     style: TextButton.styleFrom(
//                       foregroundColor: _mediumBrown,
//                     ),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: isAdding
//                         ? null
//                         : () async {
//                             final quantity = int.tryParse(
//                               quantityController.text.trim(),
//                             );

//                             if (selectedItemId == null) {
//                               _showDialogMessage(
//                                 'Please select an item.',
//                               );
//                               return;
//                             }

//                             if (quantity == null ||
//                                 quantity <= 0) {
//                               _showDialogMessage(
//                                 'Enter a valid quantity.',
//                               );
//                               return;
//                             }

//                             if (quantity >
//                                 selectedAvailableStock) {
//                               _showDialogMessage(
//                                 'Quantity cannot be greater than available stock.',
//                               );
//                               return;
//                             }

//                             setDialogState(
//                               () => isAdding = true,
//                             );

//                             try {
//                               final selectedId =
//                                   selectedItemId!;

//                               // IMPORTANT:
//                               // Fetch selected inventory item
//                               // from current user's inventory.
//                               final selectedDocument =
//                                   await _inventoryCollection
//                                       .doc(selectedId)
//                                       .get();

//                               if (!selectedDocument.exists) {
//                                 if (dialogViewContext.mounted) {
//                                   setDialogState(
//                                     () => isAdding = false,
//                                   );
//                                 }

//                                 _showDialogMessage(
//                                   'Selected inventory item no longer exists.',
//                                 );
//                                 return;
//                               }

//                               final data =
//                                   selectedDocument.data() ?? {};

//                               final itemName =
//                                   data['name']?.toString() ??
//                                       'Unnamed Item';

//                               final category =
//                                   data['category']?.toString() ??
//                                       'Other';

//                               final material =
//                                   data['material']?.toString() ??
//                                       'Unknown';

//                               final rentPrice =
//                                   (data['rentPrice'] as num?)
//                                           ?.toDouble() ??
//                                       0;

//                               if (!mounted) {
//                                 return;
//                               }

//                               setState(() {
//                                 final existingIndex =
//                                     _rentedItems.indexWhere(
//                                   (item) =>
//                                       item.itemId == selectedId,
//                                 );

//                                 if (existingIndex >= 0) {
//                                   _rentedItems[existingIndex]
//                                           .quantity +=
//                                       quantity;
//                                 } else {
//                                   _rentedItems.add(
//                                     RentedItem(
//                                       itemId: selectedId,
//                                       name: itemName,
//                                       category: category,
//                                       material: material,
//                                       quantity: quantity,
//                                       rentPrice: rentPrice,
//                                     ),
//                                   );
//                                 }
//                               });

//                               isAdding = false;

//                               if (dialogViewContext.mounted) {
//                                 Navigator.of(
//                                   dialogContext,
//                                 ).pop();
//                               }
//                             } catch (e) {
//                               if (dialogViewContext.mounted) {
//                                 setDialogState(
//                                   () => isAdding = false,
//                                 );

//                                 _showDialogMessage(
//                                   'Unable to add item: $e',
//                                 );
//                               }
//                             }
//                           },
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add Item'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _bronze,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 18,
//                         vertical: 13,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(11),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       );
//     } finally {
//       quantityController.dispose();
//     }
//   }

//   // ============================================================
//   // ALREADY ADDED QUANTITY
//   // ============================================================

//   int _getAlreadyAddedQuantity(String itemId) {
//     for (final item in _rentedItems) {
//       if (item.itemId == itemId) {
//         return item.quantity;
//       }
//     }

//     return 0;
//   }

//   // ============================================================
//   // REMOVE ITEM
//   // ============================================================

//   void _removeItem(int index) {
//     setState(() {
//       _rentedItems.removeAt(index);
//     });
//   }

//   // ============================================================
//   // GENERATE BILL
//   // ============================================================

//   Future<void> _generateBill() async {
//     if (_currentUser == null) {
//       _showMessage(
//         'Please login before creating a bill.',
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_dateFrom == null) {
//       _showMessage(
//         'Please select Date From.',
//       );
//       return;
//     }

//     if (_dateTill == null) {
//       _showMessage(
//         'Please select Return Date.',
//       );
//       return;
//     }

//     if (_rentedItems.isEmpty) {
//       _showMessage(
//         'Please add at least one renting item.',
//       );
//       return;
//     }

//     final cnicDigits = _cnicController.text
//         .replaceAll(RegExp(r'[^0-9]'), '');

//     if (cnicDigits.length != 16) {
//       _showMessage(
//         'CNIC must contain exactly 16 digits.',
//       );
//       return;
//     }

//     final contactDigits = _contactController.text
//         .replaceAll(RegExp(r'[^0-9]'), '');

//     if (contactDigits.length != 11 ||
//         !contactDigits.startsWith('03')) {
//       _showMessage(
//         'Contact number must be 11 digits and start with 03.',
//       );
//       return;
//     }

//     final subtotal = _subtotal;
//     final discount = _discount;
//     final finalTotal = _finalTotal;
//     final paidAmount = _paidAmount;
//     final remainingAmount = _remainingAmount;
//     final paymentStatus = _paymentStatus;

//     final billNumber = _generateBillNumber();
//     final generatedAt = DateTime.now();

//     setState(() {
//       _isGenerating = true;
//     });

//     try {
//       // ========================================================
//       // USER-SCOPED REFERENCES
//       // ========================================================

//       final billReference = _billsCollection.doc();
//       final customerReference = _customersCollection.doc();

//       await _db.runTransaction(
//         (transaction) async {
//           final snapshots =
//               <DocumentSnapshot<Map<String, dynamic>>>[];

//           // ----------------------------------------------------
//           // READ CURRENT USER'S INVENTORY
//           // ----------------------------------------------------

//           for (final item in _rentedItems) {
//             final ref =
//                 _inventoryCollection.doc(item.itemId);

//             snapshots.add(
//               await transaction.get(ref),
//             );
//           }

//           // ----------------------------------------------------
//           // CHECK STOCK
//           // ----------------------------------------------------

//           for (var i = 0;
//               i < _rentedItems.length;
//               i++) {
//             final item = _rentedItems[i];
//             final snapshot = snapshots[i];

//             if (!snapshot.exists) {
//               throw Exception(
//                 '${item.name} no longer exists in inventory.',
//               );
//             }

//             final available =
//                 (snapshot.data()?['availableStock'] as num?)
//                         ?.toInt() ??
//                     0;

//             if (item.quantity > available) {
//               throw Exception(
//                 'Only $available units of ${item.name} are available.',
//               );
//             }
//           }

//           // ----------------------------------------------------
//           // DEDUCT STOCK FROM CURRENT USER'S INVENTORY
//           // ----------------------------------------------------

//           for (var i = 0;
//               i < _rentedItems.length;
//               i++) {
//             final item = _rentedItems[i];
//             final snapshot = snapshots[i];
//             final data = snapshot.data() ?? {};

//             final available =
//                 (data['availableStock'] as num?)?.toInt() ??
//                     0;

//             final rented =
//                 (data['rentedStock'] as num?)?.toInt() ??
//                     0;

//             transaction.update(
//               snapshot.reference,
//               {
//                 'availableStock':
//                     available - item.quantity,
//                 'rentedStock':
//                     rented + item.quantity,
//                 'updatedAt':
//                     FieldValue.serverTimestamp(),
//               },
//             );
//           }

//           // ----------------------------------------------------
//           // BILL ITEMS
//           // ----------------------------------------------------

//           final billItems = _rentedItems
//               .map(
//                 (item) => {
//                   'itemId': item.itemId,
//                   'name': item.name,
//                   'category': item.category,
//                   'material': item.material,
//                   'quantity': item.quantity,
//                   'rentPrice': item.rentPrice,
//                   'totalPrice': item.totalPrice,
//                 },
//               )
//               .toList();

//           // ----------------------------------------------------
//           // CREATE BILL UNDER:
//           //
//           // Users/{uid}/bills/{billId}
//           // ----------------------------------------------------

//           transaction.set(
//             billReference,
//             {
//               'billId': billReference.id,
//               'billNumber': billNumber,

//               'customerName':
//                   _nameController.text.trim(),

//               'contactNumber':
//                   _contactController.text.trim(),

//               'cnic':
//                   _cnicController.text.trim(),

//               'dateFrom':
//                   Timestamp.fromDate(_dateFrom!),

//               'dateTill':
//                   Timestamp.fromDate(_dateTill!),

//               'items': billItems,

//               'subtotal': subtotal,
//               'discount': discount,
//               'totalAmount': finalTotal,

//               'paidAmount': paidAmount,
//               'remainingAmount': remainingAmount,

//               'paymentStatus': paymentStatus,

//               'rentalStatus': 'rented',

//               // Bill starts as active.
//               'billStatus': 'active',
//               'finalBill': false,

//               'status': 'active',

//               'createdAt':
//                   FieldValue.serverTimestamp(),

//               'updatedAt':
//                   FieldValue.serverTimestamp(),
//             },
//           );

//           // ----------------------------------------------------
//           // CREATE CUSTOMER UNDER:
//           //
//           // Users/{uid}/customers/{customerId}
//           // ----------------------------------------------------

//           transaction.set(
//             customerReference,
//             {
//               'name':
//                   _nameController.text.trim(),

//               'contactNumber':
//                   _contactController.text.trim(),

//               'cnic':
//                   _cnicController.text.trim(),

//               'lastBillId':
//                   billReference.id,

//               'lastBillNumber':
//                   billNumber,

//               'lastRentalFrom':
//                   Timestamp.fromDate(_dateFrom!),

//               'lastRentalTill':
//                   Timestamp.fromDate(_dateTill!),

//               'rentalItems': billItems,

//               'subtotal': subtotal,
//               'discount': discount,
//               'totalAmount': finalTotal,

//               'paidAmount': paidAmount,
//               'remainingAmount': remainingAmount,

//               'paymentStatus': paymentStatus,

//               'rentalStatus': 'rented',

//               'createdAt':
//                   FieldValue.serverTimestamp(),

//               'updatedAt':
//                   FieldValue.serverTimestamp(),
//             },
//           );
//         },
//       );

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // CREATE PDF
//       // ========================================================

//       final pdf = await _buildBillPdf(
//         billNumber: billNumber,
//         generatedAt: generatedAt,
//       );

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // OPEN PREVIEW
//       // ========================================================

//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BillPreviewScreen(
//             pdfBytes: pdf,
//             billId: billNumber,
//             customerName:
//                 _nameController.text.trim(),
//           ),
//         ),
//       );

//       if (!mounted) {
//         return;
//       }

//       // ========================================================
//       // CLEAR FORM
//       // ========================================================

//       _nameController.clear();
//       _cnicController.clear();
//       _contactController.clear();

//       _discountController.text = '0';
//       _paidController.text = '0';

//       setState(() {
//         _dateFrom = null;
//         _dateTill = null;
//         _rentedItems.clear();
//       });

//       _showMessage(
//         'Bill $billNumber generated successfully.',
//       );
//     } catch (e) {
//       if (!mounted) {
//         return;
//       }

//       var message = e.toString();

//       if (message.startsWith('Exception: ')) {
//         message = message.substring(11);
//       }

//       _showMessage(
//         'Bill could not be generated: $message',
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isGenerating = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // BUILD PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf({
//     required String billNumber,
//     required DateTime generatedAt,
//   }) async {
//     final pdf = pw.Document();

//     final status = _paymentStatus;

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (_) => pw.Column(
//           crossAxisAlignment:
//               pw.CrossAxisAlignment.start,
//           children: [
//             // --------------------------------------------------
//             // HEADER
//             // --------------------------------------------------

//             pw.Container(
//               padding: const pw.EdgeInsets.all(18),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(
//                   color: PdfColors.grey400,
//                 ),
//                 borderRadius:
//                     pw.BorderRadius.circular(12),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment:
//                     pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment:
//                         pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'RENTAL BILL',
//                         style: pw.TextStyle(
//                           fontSize: 25,
//                           fontWeight:
//                               pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.SizedBox(height: 5),
//                       pw.Text(
//                         'Inventory Management',
//                         style:
//                             const pw.TextStyle(
//                           fontSize: 10,
//                           color:
//                               PdfColors.grey700,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pw.Container(
//                     padding:
//                         const pw.EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     decoration:
//                         pw.BoxDecoration(
//                       border: pw.Border.all(
//                         color:
//                             PdfColors.grey500,
//                       ),
//                       borderRadius:
//                           pw.BorderRadius.circular(
//                         8,
//                       ),
//                     ),
//                     child: pw.Column(
//                       crossAxisAlignment:
//                           pw.CrossAxisAlignment.end,
//                       children: [
//                         pw.Text(
//                           'BILL #',
//                           style:
//                               const pw.TextStyle(
//                             fontSize: 8,
//                             color:
//                                 PdfColors.grey700,
//                           ),
//                         ),
//                         pw.SizedBox(height: 3),
//                         pw.Text(
//                           billNumber,
//                           style: pw.TextStyle(
//                             fontSize: 11,
//                             fontWeight:
//                                 pw.FontWeight.bold,
//                           ),
//                         ),
//                         pw.SizedBox(height: 4),
//                         pw.Text(
//                           'Generated: ${_formatDate(generatedAt)}',
//                           style:
//                               const pw.TextStyle(
//                             fontSize: 8,
//                             color:
//                                 PdfColors.grey700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 18),

//             // --------------------------------------------------
//             // CUSTOMER DETAILS
//             // --------------------------------------------------

//             pw.Text(
//               'CUSTOMER DETAILS',
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 fontWeight:
//                     pw.FontWeight.bold,
//               ),
//             ),

//             pw.SizedBox(height: 8),

//             pw.Container(
//               width: double.infinity,
//               padding: const pw.EdgeInsets.all(12),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.grey100,
//                 borderRadius:
//                     pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 children: [
//                   pw.Row(
//                     children: [
//                       pw.Expanded(
//                         child: pw.Text(
//                           'Name: ${_nameController.text.trim()}',
//                         ),
//                       ),
//                       pw.Expanded(
//                         child: pw.Text(
//                           'Contact: ${_contactController.text.trim()}',
//                         ),
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 7),

//                   pw.Row(
//                     children: [
//                       pw.Expanded(
//                         child: pw.Text(
//                           'CNIC: ${_cnicController.text.trim()}',
//                         ),
//                       ),
//                       pw.Expanded(
//                         child: pw.Text(
//                           'Bill Date: ${_formatDate(generatedAt)}',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 18),

//             // --------------------------------------------------
//             // RENTAL PERIOD
//             // --------------------------------------------------

//             pw.Text(
//               'RENTAL PERIOD',
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 fontWeight:
//                     pw.FontWeight.bold,
//               ),
//             ),

//             pw.SizedBox(height: 8),

//             pw.Container(
//               width: double.infinity,
//               padding:
//                   const pw.EdgeInsets.all(11),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(
//                   color: PdfColors.grey400,
//                 ),
//                 borderRadius:
//                     pw.BorderRadius.circular(8),
//               ),
//               child: pw.Row(
//                 mainAxisAlignment:
//                     pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text(
//                     'From: ${_formatDate(_dateFrom!)}',
//                   ),
//                   pw.Text(
//                     'Return: ${_formatDate(_dateTill!)}',
//                   ),
//                 ],
//               ),
//             ),

//             pw.SizedBox(height: 18),

//             // --------------------------------------------------
//             // ITEMS
//             // --------------------------------------------------

//             pw.Text(
//               'RENTED ITEMS',
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 fontWeight:
//                     pw.FontWeight.bold,
//               ),
//             ),

//             pw.SizedBox(height: 8),

//             pw.Table(
//               border:
//                   pw.TableBorder.all(
//                 color: PdfColors.grey400,
//               ),
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(3),
//                 1: const pw.FlexColumnWidth(1.1),
//                 2: const pw.FlexColumnWidth(1.5),
//                 3: const pw.FlexColumnWidth(1.7),
//               },
//               children: [
//                 pw.TableRow(
//                   decoration:
//                       const pw.BoxDecoration(
//                     color:
//                         PdfColors.grey200,
//                   ),
//                   children: [
//                     _pdfCell(
//                       'Item',
//                       bold: true,
//                     ),
//                     _pdfCell(
//                       'Qty',
//                       bold: true,
//                     ),
//                     _pdfCell(
//                       'Rate',
//                       bold: true,
//                     ),
//                     _pdfCell(
//                       'Amount',
//                       bold: true,
//                     ),
//                   ],
//                 ),
//                 ..._rentedItems.map(
//                   (item) => pw.TableRow(
//                     children: [
//                       _pdfCell(item.name),
//                       _pdfCell(
//                         item.quantity.toString(),
//                       ),
//                       _pdfCell(
//                         'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                       ),
//                       _pdfCell(
//                         'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             pw.SizedBox(height: 18),

//             // --------------------------------------------------
//             // AMOUNT SUMMARY
//             // --------------------------------------------------

//             pw.Align(
//               alignment:
//                   pw.Alignment.centerRight,
//               child: pw.Container(
//                 width: 270,
//                 padding:
//                     const pw.EdgeInsets.all(14),
//                 decoration:
//                     pw.BoxDecoration(
//                   border: pw.Border.all(
//                     color:
//                         PdfColors.grey400,
//                   ),
//                   borderRadius:
//                       pw.BorderRadius.circular(
//                     8,
//                   ),
//                 ),
//                 child: pw.Column(
//                   children: [
//                     _pdfAmountRow(
//                       'Actual Amount',
//                       _subtotal,
//                     ),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow(
//                       'Discount',
//                       _discount,
//                     ),
//                     pw.Divider(),
//                     _pdfAmountRow(
//                       'Total Amount',
//                       _finalTotal,
//                       bold: true,
//                     ),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow(
//                       'Paid',
//                       _paidAmount,
//                     ),
//                     pw.SizedBox(height: 7),
//                     _pdfAmountRow(
//                       'Remaining',
//                       _remainingAmount,
//                       bold: true,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             pw.SizedBox(height: 14),

//             // --------------------------------------------------
//             // PAYMENT STATUS
//             // --------------------------------------------------

//             pw.Align(
//               alignment:
//                   pw.Alignment.centerRight,
//               child: pw.Container(
//                 padding:
//                     const pw.EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration:
//                     pw.BoxDecoration(
//                   border: pw.Border.all(
//                     color: status == 'paid'
//                         ? PdfColors.green
//                         : status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                   ),
//                   borderRadius:
//                       pw.BorderRadius.circular(5),
//                 ),
//                 child: pw.Text(
//                   _statusTitle(status)
//                       .toUpperCase(),
//                   style: pw.TextStyle(
//                     fontSize: 13,
//                     fontWeight:
//                         pw.FontWeight.bold,
//                     color: status == 'paid'
//                         ? PdfColors.green
//                         : status == 'partial'
//                             ? PdfColors.orange
//                             : PdfColors.red,
//                   ),
//                 ),
//               ),
//             ),

//             pw.SizedBox(height: 14),

//             if (status != 'paid')
//               pw.Container(
//                 width: double.infinity,
//                 padding:
//                     const pw.EdgeInsets.all(12),
//                 decoration:
//                     pw.BoxDecoration(
//                   color:
//                       PdfColors.grey100,
//                   border: pw.Border.all(
//                     color:
//                         PdfColors.grey400,
//                   ),
//                   borderRadius:
//                       pw.BorderRadius.circular(
//                     8,
//                   ),
//                 ),
//                 child: pw.Text(
//                   status == 'unpaid'
//                       ? 'Payment Note: Bill payment is due on or before the return date.'
//                       : 'Payment Note: Remaining balance of Rs. ${_remainingAmount.toStringAsFixed(0)} is due on or before the return date.',
//                   style:
//                       const pw.TextStyle(
//                     fontSize: 9,
//                     color:
//                         PdfColors.grey800,
//                   ),
//                 ),
//               ),

//             pw.Spacer(),

//             pw.Divider(),

//             pw.SizedBox(height: 7),

//             pw.Center(
//               child: pw.Text(
//                 'Thank you for your business.',
//                 style:
//                     const pw.TextStyle(
//                   fontSize: 9,
//                   color:
//                       PdfColors.grey600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//     return Uint8List.fromList(
//       await pdf.save(),
//     );
//   }

//   // ============================================================
//   // PDF AMOUNT ROW
//   // ============================================================

//   pw.Widget _pdfAmountRow(
//     String label,
//     double amount, {
//     bool bold = false,
//   }) {
//     return pw.Row(
//       mainAxisAlignment:
//           pw.MainAxisAlignment.spaceBetween,
//       children: [
//         pw.Text(
//           label,
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold
//                 ? pw.FontWeight.bold
//                 : pw.FontWeight.normal,
//           ),
//         ),
//         pw.Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: pw.TextStyle(
//             fontSize: bold ? 11 : 9,
//             fontWeight: bold
//                 ? pw.FontWeight.bold
//                 : pw.FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // PDF CELL
//   // ============================================================

//   pw.Widget _pdfCell(
//     String text, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 9,
//           fontWeight: bold
//               ? pw.FontWeight.bold
//               : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RENTED ITEM CARD
//   // ============================================================

//   Widget _rentedItemCard(
//     RentedItem item,
//     int index, {
//     bool compact = false,
//   }) {
//     return Container(
//       margin:
//           const EdgeInsets.only(bottom: 10),
//       padding:
//           const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: _surface,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: _border,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 _darkBrown.withOpacity(.035),
//             blurRadius: 12,
//             offset:
//                 const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: compact
//           ? Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     _itemIcon(item),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child:
//                           _itemName(item),
//                     ),
//                     _removeButton(index),
//                   ],
//                 ),
//                 const SizedBox(height: 13),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 8,
//                   children: [
//                     _itemInfoChip(
//                       'Qty',
//                       item.quantity.toString(),
//                       _bronze,
//                     ),
//                     _itemInfoChip(
//                       'Rate',
//                       'Rs. ${item.rentPrice.toStringAsFixed(0)}',
//                       _mediumBrown,
//                     ),
//                     _itemInfoChip(
//                       'Amount',
//                       'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                       _bronzeDark,
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 _itemIcon(item),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child:
//                       _itemName(item),
//                 ),
//                 const SizedBox(width: 12),
//                 _itemInfoChip(
//                   'Quantity',
//                   item.quantity.toString(),
//                   _bronze,
//                 ),
//                 const SizedBox(width: 12),
//                 SizedBox(
//                   width: 120,
//                   child: Column(
//                     crossAxisAlignment:
//                         CrossAxisAlignment.end,
//                     children: [
//                       const Text(
//                         'Amount',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: _mutedText,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         'Rs. ${item.totalPrice.toStringAsFixed(0)}',
//                         style:
//                             const TextStyle(
//                           fontWeight:
//                               FontWeight.w800,
//                           fontSize: 15,
//                           color:
//                               _darkBrown,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _removeButton(index),
//               ],
//             ),
//     );
//   }

//   // ============================================================
//   // ITEM ICON
//   // ============================================================

//   Widget _itemIcon(RentedItem item) {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color:
//             _bronzeLight.withOpacity(.45),
//         borderRadius:
//             BorderRadius.circular(14),
//       ),
//       child: Icon(
//         _getCategoryIcon(
//           item.category,
//         ),
//         color: _bronzeDark,
//         size: 25,
//       ),
//     );
//   }

//   // ============================================================
//   // ITEM NAME
//   // ============================================================

//   Widget _itemName(RentedItem item) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Text(
//           item.name,
//           maxLines: 1,
//           overflow:
//               TextOverflow.ellipsis,
//           style:
//               const TextStyle(
//             fontSize: 15,
//             fontWeight:
//                 FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           'Material: ${item.material}',
//           maxLines: 1,
//           overflow:
//               TextOverflow.ellipsis,
//           style:
//               const TextStyle(
//             fontSize: 12,
//             color: _mutedText,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ITEM CHIP
//   // ============================================================

//   Widget _itemInfoChip(
//     String label,
//     String value,
//     Color valueColor,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color:
//             valueColor.withOpacity(.07),
//         borderRadius:
//             BorderRadius.circular(10),
//         border: Border.all(
//           color:
//               valueColor.withOpacity(.12),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style:
//                 const TextStyle(
//               fontSize: 9,
//               color: _mutedText,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight:
//                   FontWeight.w800,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // REMOVE BUTTON
//   // ============================================================

//   Widget _removeButton(int index) {
//     return IconButton(
//       tooltip: 'Remove Item',
//       onPressed: () => _removeItem(index),
//       style: IconButton.styleFrom(
//         backgroundColor:
//             Colors.red.withOpacity(.07),
//         foregroundColor:
//             Colors.red.shade700,
//       ),
//       icon: const Icon(
//         Icons.close,
//         size: 19,
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY ICON
//   // ============================================================

//   IconData _getCategoryIcon(
//     String category,
//   ) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair_outlined;

//       case 'Decoration':
//         return Icons.auto_awesome_outlined;

//       case 'Tent':
//         return Icons.house_outlined;

//       case 'Lighting':
//         return Icons.lightbulb_outline;

//       case 'Sound Equipment':
//         return Icons.speaker_outlined;

//       case 'Stage Equipment':
//         return Icons.theater_comedy_outlined;

//       case 'Catering':
//         return Icons.restaurant_outlined;

//       default:
//         return Icons.inventory_2_outlined;
//     }
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle:
//           const TextStyle(
//         color: _mutedText,
//         fontSize: 13,
//       ),
//       prefixIcon: Icon(
//         icon,
//         color: _bronze,
//         size: 21,
//       ),
//       filled: true,
//       fillColor: _surface,
//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 16,
//       ),
//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(13),
//         borderSide:
//             const BorderSide(
//           color: _border,
//         ),
//       ),
//       enabledBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(13),
//         borderSide:
//             const BorderSide(
//           color: _border,
//         ),
//       ),
//       focusedBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(13),
//         borderSide:
//             const BorderSide(
//           color: _bronze,
//           width: 1.6,
//         ),
//       ),
//       errorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(13),
//         borderSide:
//             const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(13),
//         borderSide:
//             const BorderSide(
//           color: Colors.red,
//           width: 1.4,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SUMMARY ROW
//   // ============================================================

//   Widget _summaryRow(
//     String label,
//     double amount, {
//     bool bold = false,
//     Color? valueColor,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize:
//                   bold ? 15 : 13,
//               fontWeight: bold
//                   ? FontWeight.w800
//                   : FontWeight.w600,
//               color: bold
//                   ? _darkBrown
//                   : _mediumBrown,
//             ),
//           ),
//         ),
//         Text(
//           'Rs. ${amount.toStringAsFixed(0)}',
//           style: TextStyle(
//             fontSize:
//                 bold ? 17 : 14,
//             fontWeight: bold
//                 ? FontWeight.w800
//                 : FontWeight.w700,
//             color:
//                 valueColor ?? _darkBrown,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // DATE FORMAT
//   // ============================================================

//   String _formatDate(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];

//     return '${date.day} ${months[date.month - 1]} ${date.year}';
//   }

//   // ============================================================
//   // DATE FIELD
//   // ============================================================

//   Widget _dateField({
//     required String title,
//     required DateTime? date,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius:
//           BorderRadius.circular(14),
//       child: Container(
//         width: double.infinity,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 15,
//         ),
//         decoration:
//             BoxDecoration(
//           color: _surface,
//           borderRadius:
//               BorderRadius.circular(14),
//           border: Border.all(
//             color: _border,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration:
//                   BoxDecoration(
//                 color:
//                     _bronzeLight.withOpacity(
//                   .42,
//                 ),
//                 borderRadius:
//                     BorderRadius.circular(
//                   11,
//                 ),
//               ),
//               child:
//                   const Icon(
//                 Icons.calendar_month_outlined,
//                 color: _bronzeDark,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style:
//                         const TextStyle(
//                       fontSize: 11,
//                       color:
//                           _mutedText,
//                       fontWeight:
//                           FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     date == null
//                         ? 'Select date'
//                         : _formatDate(date),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight:
//                           FontWeight.w700,
//                       color: date == null
//                           ? _mutedText
//                           : _darkBrown,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               color: _mutedText,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SECTION TITLE
//   // ============================================================

//   Widget _sectionTitle(
//     String title, {
//     String? subtitle,
//   }) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style:
//               const TextStyle(
//             fontSize: 18,
//             fontWeight:
//                 FontWeight.w800,
//             color: _darkBrown,
//           ),
//         ),
//         if (subtitle != null) ...[
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style:
//                 const TextStyle(
//               fontSize: 12,
//               color: _mutedText,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   // ============================================================
//   // SECTION CARD
//   // ============================================================

//   Widget _sectionCard({
//     required Widget child,
//     EdgeInsets padding =
//         const EdgeInsets.all(20),
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: padding,
//       decoration:
//           BoxDecoration(
//         color: _surface,
//         borderRadius:
//             BorderRadius.circular(20),
//         border: Border.all(
//           color: _border,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 _darkBrown.withOpacity(.035),
//             blurRadius: 18,
//             offset:
//                 const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader(
//     bool mobile,
//   ) {
//     return Container(
//       width: double.infinity,
//       padding:
//           EdgeInsets.all(
//         mobile ? 18 : 24,
//       ),
//       decoration:
//           BoxDecoration(
//         gradient:
//             const LinearGradient(
//           colors: [
//             _bronzeDark,
//             _bronze,
//           ],
//           begin:
//               Alignment.topLeft,
//           end:
//               Alignment.bottomRight,
//         ),
//         borderRadius:
//             BorderRadius.circular(22),
//       ),
//       child: mobile
//           ? Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _headerIcon(),
//                 const SizedBox(height: 15),
//                 _headerText(),
//               ],
//             )
//           : Row(
//               children: [
//                 _headerIcon(),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child:
//                       _headerText(),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _headerIcon() {
//     return Container(
//       width: 58,
//       height: 58,
//       decoration:
//           BoxDecoration(
//         color:
//             Colors.white.withOpacity(.15),
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color:
//               Colors.white.withOpacity(.18),
//         ),
//       ),
//       child:
//           const Icon(
//         Icons.receipt_long_outlined,
//         color: Colors.white,
//         size: 30,
//       ),
//     );
//   }

//   Widget _headerText() {
//     return const Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Text(
//           'New Rental Bill',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),
//         SizedBox(height: 6),
//         Text(
//           'Create a rental bill, record payment, and update inventory stock.',
//           style: TextStyle(
//             color: Colors.white70,
//             fontSize: 13,
//             height: 1.4,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ADD ITEM BUTTON
//   // ============================================================

//   Widget _addItemButton() {
//     return ElevatedButton.icon(
//       onPressed:
//           _showAddItemModal,
//       icon: const Icon(
//         Icons.add,
//         size: 19,
//       ),
//       label:
//           const Text(
//         'Add Item',
//         style:
//             TextStyle(
//           fontWeight:
//               FontWeight.w700,
//         ),
//       ),
//       style:
//           ElevatedButton.styleFrom(
//         backgroundColor:
//             _bronze,
//         foregroundColor:
//             Colors.white,
//         elevation: 0,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 13,
//         ),
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(
//             11,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY ITEMS
//   // ============================================================

//   Widget _emptyItemsState() {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 32,
//         horizontal: 20,
//       ),
//       decoration:
//           BoxDecoration(
//         color: _background,
//         borderRadius:
//             BorderRadius.circular(15),
//         border: Border.all(
//           color: _border,
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 58,
//             height: 58,
//             decoration:
//                 BoxDecoration(
//               color:
//                   _bronzeLight.withOpacity(
//                 .42,
//               ),
//               shape:
//                   BoxShape.circle,
//             ),
//             child:
//                 const Icon(
//               Icons.shopping_cart_outlined,
//               size: 27,
//               color: _bronzeDark,
//             ),
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             'No renting items added',
//             style:
//                 TextStyle(
//               fontWeight:
//                   FontWeight.w800,
//               color:
//                   _darkBrown,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Click "Add Item" to select inventory items.',
//             textAlign:
//                 TextAlign.center,
//             style:
//                 TextStyle(
//               color: _mutedText,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // AMOUNT SUMMARY
//   // ============================================================

//   Widget _amountSummary() {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.all(17),
//       decoration:
//           BoxDecoration(
//         color: _background,
//         borderRadius:
//             BorderRadius.circular(16),
//         border: Border.all(
//           color: _border,
//         ),
//       ),
//       child: Column(
//         children: [
//           _summaryRow(
//             'Actual Amount',
//             _subtotal,
//           ),
//           const SizedBox(height: 14),
//           TextFormField(
//             controller:
//                 _discountController,
//             keyboardType:
//                 const TextInputType
//                     .numberWithOptions(
//               decimal: true,
//             ),
//             onChanged: (_) =>
//                 setState(() {}),
//             decoration:
//                 _inputDecoration(
//               label:
//                   'Discount Amount',
//               icon:
//                   Icons.discount_outlined,
//             ).copyWith(
//               hintText: '0',
//             ),
//           ),
//           const SizedBox(height: 13),
//           _summaryRow(
//             'Discount',
//             _discount,
//             valueColor:
//                 Colors.orange.shade700,
//           ),
//           const Padding(
//             padding:
//                 EdgeInsets.symmetric(
//               vertical: 15,
//             ),
//             child:
//                 Divider(
//               color: _border,
//             ),
//           ),
//           Container(
//             padding:
//                 const EdgeInsets.symmetric(
//               horizontal: 14,
//               vertical: 13,
//             ),
//             decoration:
//                 BoxDecoration(
//               color:
//                   _bronzeLight.withOpacity(
//                 .35,
//               ),
//               borderRadius:
//                   BorderRadius.circular(
//                 12,
//               ),
//             ),
//             child: _summaryRow(
//               'Total Amount',
//               _finalTotal,
//               bold: true,
//               valueColor:
//                   _bronzeDark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PAYMENT DETAILS
//   // ============================================================

//   Widget _paymentDetails(
//     String status,
//   ) {
//     return Column(
//       children: [
//         TextFormField(
//           controller:
//               _paidController,
//           keyboardType:
//               const TextInputType
//                   .numberWithOptions(
//             decimal: true,
//           ),
//           onChanged: (_) =>
//               setState(() {}),
//           decoration:
//               _inputDecoration(
//             label:
//                 'Paid Amount',
//             icon:
//                 Icons.payments_outlined,
//           ).copyWith(
//             hintText: '0',
//           ),
//         ),
//         const SizedBox(height: 14),
//         _summaryRow(
//           'Paid',
//           _paidAmount,
//           valueColor:
//               Colors.green.shade700,
//         ),
//         const SizedBox(height: 11),
//         _summaryRow(
//           'Remaining',
//           _remainingAmount,
//           bold: true,
//           valueColor:
//               _remainingAmount > 0
//                   ? Colors.red.shade700
//                   : Colors.green.shade700,
//         ),
//         const SizedBox(height: 17),
//         _paymentStatusCard(
//           status,
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // PAYMENT STATUS CARD
//   // ============================================================

//   Widget _paymentStatusCard(
//     String status,
//   ) {
//     final color = status == 'paid'
//         ? Colors.green.shade700
//         : status == 'partial'
//             ? Colors.orange.shade700
//             : Colors.red.shade700;

//     final icon = status == 'paid'
//         ? Icons.check_circle_outline
//         : status == 'partial'
//             ? Icons.timelapse
//             : Icons.pending_actions_outlined;

//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.all(14),
//       decoration:
//           BoxDecoration(
//         color:
//             color.withOpacity(.07),
//         borderRadius:
//             BorderRadius.circular(13),
//         border: Border.all(
//           color:
//               color.withOpacity(.14),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: color,
//             size: 23,
//           ),
//           const SizedBox(width: 11),
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Payment Status',
//                   style: TextStyle(
//                     color: _mutedText,
//                     fontSize: 11,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _statusTitle(
//                     status,
//                   ),
//                   style:
//                       TextStyle(
//                     fontWeight:
//                         FontWeight.w800,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FORM CONTENT
//   // ============================================================

//   Widget _buildFormContent(
//     bool mobile,
//   ) {
//     final status =
//         _paymentStatus;

//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         _buildHeader(
//           mobile,
//         ),

//         const SizedBox(height: 24),

//         // ------------------------------------------------------
//         // CUSTOMER DETAILS
//         // ------------------------------------------------------

//         _sectionCard(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               _sectionTitle(
//                 'Customer Details',
//                 subtitle:
//                     'Enter the customer information for this rental.',
//               ),
//               const SizedBox(height: 18),
//               LayoutBuilder(
//                 builder: (_, box) {
//                   final two =
//                       box.maxWidth >= 700;

//                   final fields = [
//                     TextFormField(
//                       controller:
//                           _nameController,
//                       textCapitalization:
//                           TextCapitalization
//                               .words,
//                       decoration:
//                           _inputDecoration(
//                         label:
//                             'Customer Name',
//                         icon:
//                             Icons.person_outline,
//                       ),
//                       validator: (v) =>
//                           v == null ||
//                                   v.trim()
//                                       .isEmpty
//                               ? 'Please enter customer name.'
//                               : null,
//                     ),
//                     TextFormField(
//                       controller:
//                           _contactController,
//                       keyboardType:
//                           TextInputType.phone,
//                       onChanged:
//                           _formatContact,
//                       decoration:
//                           _inputDecoration(
//                         label:
//                             'Contact Number',
//                         icon:
//                             Icons.phone_outlined,
//                       ).copyWith(
//                         hintText:
//                             '0300-1234567',
//                       ),
//                       validator: (v) {
//                         final d =
//                             (v ?? '')
//                                 .replaceAll(
//                           RegExp(
//                             r'[^0-9]',
//                           ),
//                           '',
//                         );

//                         return d.length !=
//                                     11 ||
//                                 !d.startsWith(
//                                   '03',
//                                 )
//                             ? 'Enter a valid 11-digit mobile number.'
//                             : null;
//                       },
//                     ),
//                     TextFormField(
//                       controller:
//                           _cnicController,
//                       keyboardType:
//                           TextInputType
//                               .number,
//                       onChanged:
//                           _formatCnic,
//                       decoration:
//                           _inputDecoration(
//                         label:
//                             'CNIC #',
//                         icon:
//                             Icons.badge_outlined,
//                       ).copyWith(
//                         hintText:
//                             'XXXXX-XXXXX-XXXXXX',
//                       ),
//                       validator: (v) {
//                         final d =
//                             (v ?? '')
//                                 .replaceAll(
//                           RegExp(
//                             r'[^0-9]',
//                           ),
//                           '',
//                         );

//                         return d.length !=
//                                 16
//                             ? 'CNIC must contain exactly 16 digits.'
//                             : null;
//                       },
//                     ),
//                   ];

//                   if (!two) {
//                     return Column(
//                       children: [
//                         fields[0],
//                         const SizedBox(
//                           height: 14,
//                         ),
//                         fields[1],
//                         const SizedBox(
//                           height: 14,
//                         ),
//                         fields[2],
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(
//                         child:
//                             fields[0],
//                       ),
//                       const SizedBox(
//                         width: 14,
//                       ),
//                       Expanded(
//                         child:
//                             fields[1],
//                       ),
//                       const SizedBox(
//                         width: 14,
//                       ),
//                       Expanded(
//                         child:
//                             fields[2],
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 18),

//         // ------------------------------------------------------
//         // RENTAL PERIOD
//         // ------------------------------------------------------

//         _sectionCard(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               _sectionTitle(
//                 'Rental Period',
//                 subtitle:
//                     'Select when the rental starts and when the items are expected back.',
//               ),
//               const SizedBox(height: 18),
//               LayoutBuilder(
//                 builder: (_, box) {
//                   if (box.maxWidth <
//                       600) {
//                     return Column(
//                       children: [
//                         _dateField(
//                           title:
//                               'Date From',
//                           date:
//                               _dateFrom,
//                           onTap: () =>
//                               _selectDate(
//                             isFrom:
//                                 true,
//                           ),
//                         ),
//                         const SizedBox(
//                           height: 12,
//                         ),
//                         _dateField(
//                           title:
//                               'Return Date',
//                           date:
//                               _dateTill,
//                           onTap: () =>
//                               _selectDate(
//                             isFrom:
//                                 false,
//                           ),
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(
//                         child:
//                             _dateField(
//                           title:
//                               'Date From',
//                           date:
//                               _dateFrom,
//                           onTap: () =>
//                               _selectDate(
//                             isFrom:
//                                 true,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 14,
//                       ),
//                       Expanded(
//                         child:
//                             _dateField(
//                           title:
//                               'Return Date',
//                           date:
//                               _dateTill,
//                           onTap: () =>
//                               _selectDate(
//                             isFrom:
//                                 false,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 18),

//         // ------------------------------------------------------
//         // RENTING ITEMS
//         // ------------------------------------------------------

//         _sectionCard(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               LayoutBuilder(
//                 builder: (_, box) {
//                   if (box.maxWidth <
//                       520) {
//                     return Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         _sectionTitle(
//                           'Renting Items',
//                           subtitle:
//                               'Items selected for this rental.',
//                         ),
//                         const SizedBox(
//                           height: 14,
//                         ),
//                         SizedBox(
//                           width:
//                               double.infinity,
//                           child:
//                               _addItemButton(),
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(
//                         child:
//                             _sectionTitle(
//                           'Renting Items',
//                           subtitle:
//                               'Items selected for this rental.',
//                         ),
//                       ),
//                       _addItemButton(),
//                     ],
//                   );
//                 },
//               ),

//               const SizedBox(
//                 height: 18,
//               ),

//               if (_rentedItems.isEmpty)
//                 _emptyItemsState()
//               else
//                 LayoutBuilder(
//                   builder: (_, box) {
//                     final compact =
//                         box.maxWidth <
//                             680;

//                     return Column(
//                       children:
//                           List.generate(
//                         _rentedItems.length,
//                         (i) =>
//                             _rentedItemCard(
//                           _rentedItems[i],
//                           i,
//                           compact:
//                               compact,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),

//         // ------------------------------------------------------
//         // SUMMARY
//         // ------------------------------------------------------

//         if (_rentedItems
//             .isNotEmpty) ...[
//           const SizedBox(height: 18),
//           _sectionCard(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 _sectionTitle(
//                   'Bill Summary & Payment',
//                   subtitle:
//                       'Review the amount and record the customer payment.',
//                 ),
//                 const SizedBox(
//                   height: 18,
//                 ),
//                 LayoutBuilder(
//                   builder: (_, box) {
//                     if (box.maxWidth <
//                         780) {
//                       return Column(
//                         children: [
//                           _amountSummary(),
//                           const SizedBox(
//                             height: 22,
//                           ),
//                           _paymentDetails(
//                             status,
//                           ),
//                         ],
//                       );
//                     }

//                     return Row(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         Expanded(
//                           child:
//                               _amountSummary(),
//                         ),
//                         const SizedBox(
//                           width: 24,
//                         ),
//                         Expanded(
//                           child:
//                               _paymentDetails(
//                             status,
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],

//         const SizedBox(height: 22),

//         // ------------------------------------------------------
//         // GENERATE BUTTON
//         // ------------------------------------------------------

//         SizedBox(
//           width: double.infinity,
//           height: 58,
//           child:
//               ElevatedButton.icon(
//             onPressed:
//                 _isGenerating
//                     ? null
//                     : _generateBill,
//             icon: _isGenerating
//                 ? const SizedBox(
//                     width: 21,
//                     height: 21,
//                     child:
//                         CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color:
//                           Colors.white,
//                     ),
//                   )
//                 : const Icon(
//                     Icons.receipt_long_outlined,
//                   ),
//             label: Text(
//               _isGenerating
//                   ? 'Generating Bill...'
//                   : 'Generate Bill',
//               style:
//                   const TextStyle(
//                 fontSize: 15,
//                 fontWeight:
//                     FontWeight.w800,
//               ),
//             ),
//             style:
//                 ElevatedButton.styleFrom(
//               backgroundColor:
//                   _bronzeDark,
//               foregroundColor:
//                   Colors.white,
//               disabledBackgroundColor:
//                   _bronze.withOpacity(.5),
//               elevation: 0,
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(
//                   15,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           _background,
//       appBar: AppBar(
//         backgroundColor:
//             _surface,
//         foregroundColor:
//             _darkBrown,
//         elevation: 0,
//         surfaceTintColor:
//             Colors.transparent,
//         titleSpacing: 18,
//         title:
//             const Text(
//           'Create New Bill',
//           style:
//               TextStyle(
//             fontWeight:
//                 FontWeight.w800,
//             color:
//                 _darkBrown,
//           ),
//         ),
//       ),
//       drawer:
//           const AdminDrawer(
//         selectedIndex: 3,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (_, constraints) {
//             final width =
//                 constraints.maxWidth;

//             final mobile =
//                 width < 650;

//             final tablet =
//                 width >= 650 &&
//                     width < 950;

//             final horizontal =
//                 mobile
//                     ? 14.0
//                     : tablet
//                         ? 24.0
//                         : 34.0;

//             return SingleChildScrollView(
//               padding:
//                   EdgeInsets.fromLTRB(
//                 horizontal,
//                 20,
//                 horizontal,
//                 35,
//               ),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints:
//                       const BoxConstraints(
//                     maxWidth: 1120,
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child:
//                         _buildFormContent(
//                       mobile,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//     String message,
//   ) {
//     if (!mounted) {
//       return;
//     }

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(
//       SnackBar(
//         content:
//             Text(message),
//         behavior:
//             SnackBarBehavior
//                 .floating,
//         backgroundColor:
//             _darkBrown,
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DIALOG MESSAGE
//   // ============================================================

//   void _showDialogMessage(
//     String message,
//   ) {
//     if (!mounted) {
//       return;
//     }

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(
//       SnackBar(
//         content:
//             Text(message),
//         behavior:
//             SnackBarBehavior
//                 .floating,
//         backgroundColor:
//             _darkBrown,
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(
//             12,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // RENTED ITEM MODEL
// // ============================================================================

// class RentedItem {
//   final String itemId;
//   final String name;
//   final String category;
//   final String material;

//   int quantity;

//   final double rentPrice;

//   RentedItem({
//     required this.itemId,
//     required this.name,
//     required this.category,
//     required this.material,
//     required this.quantity,
//     required this.rentPrice,
//   });

//   double get totalPrice =>
//       quantity * rentPrice;
// }

// // ============================================================================
// // BILL PREVIEW
// // ============================================================================

// class BillPreviewScreen
//     extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billId;
//   final String customerName;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billId,
//     required this.customerName,
//   });

//   // ============================================================
//   // SAVE / SHARE PDF
//   // ============================================================

//   Future<void> _savePdf(
//     BuildContext context,
//   ) async {
//     try {
//       await Printing.sharePdf(
//         bytes: pdfBytes,
//         filename:
//             'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       );

//       if (!context.mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Bill ready to save/share.',
//           ),
//           backgroundColor:
//               Colors.green,
//         ),
//       );
//     } catch (_) {
//       if (!context.mounted) {
//         return;
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Unable to save/share the bill.',
//           ),
//           backgroundColor:
//               Colors.red,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // BUILD PREVIEW
//   // ============================================================

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           _BillScreenState._background,
//       appBar: AppBar(
//         backgroundColor:
//             _BillScreenState._surface,
//         foregroundColor:
//             _BillScreenState._darkBrown,
//         surfaceTintColor:
//             Colors.transparent,
//         elevation: 0,
//         title:
//             const Text(
//           'Bill Preview',
//           style:
//               TextStyle(
//             fontWeight:
//                 FontWeight.w800,
//           ),
//         ),
//         actions: [
//           IconButton(
//             tooltip:
//                 'Save / Download Bill',
//             onPressed: () =>
//                 _savePdf(context),
//             style:
//                 IconButton.styleFrom(
//               foregroundColor:
//                   _BillScreenState
//                       ._bronzeDark,
//             ),
//             icon:
//                 const Icon(
//               Icons.save_outlined,
//             ),
//           ),
//           IconButton(
//             tooltip:
//                 'Print / Share',
//             onPressed: () async {
//               try {
//                 await Printing.sharePdf(
//                   bytes: pdfBytes,
//                   filename:
//                       'Bill_${billId.replaceAll(' ', '_')}.pdf',
//                 );
//               } catch (_) {}
//             },
//             style:
//                 IconButton.styleFrom(
//               foregroundColor:
//                   _BillScreenState
//                       ._bronzeDark,
//             ),
//             icon:
//                 const Icon(
//               Icons.print_outlined,
//             ),
//           ),
//           const SizedBox(
//             width: 6,
//           ),
//         ],
//       ),
//       body: PdfPreview(
//         build: (_) async =>
//             pdfBytes,
//         canChangePageFormat:
//             false,
//         canChangeOrientation:
//             false,
//         allowPrinting: true,
//         allowSharing: true,
//         pdfFileName:
//             'Bill_${billId.replaceAll(' ', '_')}.pdf',
//       ),
//     );
//   }
// }





import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/drawer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cnicController = TextEditingController();
  final _contactController = TextEditingController();
  final _rentalLocationController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paidController = TextEditingController(text: '0');

  DateTime? _dateFrom;
  DateTime? _dateTill;

  final List<RentedItem> _rentedItems = [];
  bool _isGenerating = false;

  static const Color _background = Color(0xFFF7F2EA);
  static const Color _surface = Color(0xFFFFFCF8);
  static const Color _bronze = Color(0xFF9A6A3A);
  static const Color _bronzeDark = Color(0xFF704823);
  static const Color _bronzeLight = Color(0xFFE9D6BC);
  static const Color _darkBrown = Color(0xFF2C2119);
  static const Color _mediumBrown = Color(0xFF59483A);
  static const Color _mutedText = Color(0xFF8A7B6E);
  static const Color _border = Color(0xFFE6D9CB);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // CURRENT USER / USER-SCOPED FIRESTORE COLLECTIONS
  // ============================================================

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final user = _currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return _db.collection('Users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    return _userDocument.collection('inventory');
  }

  CollectionReference<Map<String, dynamic>> get _billsCollection {
    return _userDocument.collection('bills');
  }

  CollectionReference<Map<String, dynamic>> get _customersCollection {
    return _userDocument.collection('customers');
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _contactController.dispose();
    _rentalLocationController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  // ============================================================
  // CNIC FORMAT
  // ============================================================

  void _formatCnic(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    // CNIC = exactly 13 digits
    if (digits.length > 13) {
      digits = digits.substring(0, 13);
    }

    var formatted = '';

    for (var i = 0; i < digits.length; i++) {
      if (i == 5 || i == 12) {
        formatted += '-';
      }

      formatted += digits[i];
    }

    _cnicController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CONTACT FORMAT
  // ============================================================

  void _formatContact(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final formatted = digits.length > 4
        ? '${digits.substring(0, 4)}-${digits.substring(4)}'
        : digits;

    _contactController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // MONEY
  // ============================================================

  double _parseMoney(String value) {
    return double.tryParse(
          value.replaceAll(',', '').trim(),
        ) ??
        0;
  }

  double get _subtotal {
    return _rentedItems.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  double get _discount {
    final value = _parseMoney(_discountController.text);

    if (value <= 0) {
      return 0;
    }

    return value > _subtotal ? _subtotal : value;
  }

  double get _finalTotal {
    final value = _subtotal - _discount;

    return value < 0 ? 0 : value;
  }

  double get _paidAmount {
    final value = _parseMoney(_paidController.text);

    if (value <= 0) {
      return 0;
    }

    return value > _finalTotal ? _finalTotal : value;
  }

  double get _remainingAmount {
    final value = _finalTotal - _paidAmount;

    return value < 0 ? 0 : value;
  }

  String get _paymentStatus {
    if (_finalTotal <= 0 || _paidAmount >= _finalTotal) {
      return 'paid';
    }

    if (_paidAmount <= 0) {
      return 'unpaid';
    }

    return 'partial';
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'paid':
        return 'Paid';

      case 'partial':
        return 'Partial';

      default:
        return 'Unpaid';
    }
  }

  // ============================================================
  // BILL NUMBER
  // ============================================================

  String _generateBillNumber() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000;

    return 'RB-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate({
    required bool isFrom,
  }) async {
    final initial = isFrom
        ? (_dateFrom ?? DateTime.now())
        : (_dateTill ?? _dateFrom ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) {
      return;
    }

    if (!isFrom &&
        _dateFrom != null &&
        picked.isBefore(_dateFrom!)) {
      _showMessage(
        'Return date cannot be before Date From.',
      );
      return;
    }

    setState(() {
      if (isFrom) {
        _dateFrom = picked;

        if (_dateTill != null &&
            _dateTill!.isBefore(picked)) {
          _dateTill = null;
        }
      } else {
        _dateTill = picked;
      }
    });
  }

  // ============================================================
  // ADD RENTING ITEM MODAL
  // ============================================================

  Future<void> _showAddItemModal() async {
    String? selectedItemId;
    int selectedAvailableStock = 0;

    final quantityController = TextEditingController();

    bool isAdding = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
              dialogViewContext,
              setDialogState,
            ) {
              return AlertDialog(
                backgroundColor: _surface,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                titlePadding: const EdgeInsets.fromLTRB(
                  24,
                  22,
                  24,
                  8,
                ),
                contentPadding: const EdgeInsets.fromLTRB(
                  24,
                  10,
                  24,
                  8,
                ),
                actionsPadding: const EdgeInsets.fromLTRB(
                  18,
                  8,
                  18,
                  18,
                ),
                title: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _bronzeLight,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart_outlined,
                        color: _bronzeDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add Renting Item',
                        style: TextStyle(
                          color: _darkBrown,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(dialogViewContext).size.width > 620
                      ? 520
                      : MediaQuery.of(dialogViewContext).size.width * .82,
                  child: SingleChildScrollView(
                    child: StreamBuilder<
                        QuerySnapshot<Map<String, dynamic>>>(
                      stream: _inventoryCollection
                          .orderBy('name')
                          .snapshots(),
                      builder: (
                        streamContext,
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 150,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: _bronze,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Unable to load inventory.',
                              style: TextStyle(
                                color: _mediumBrown,
                              ),
                            ),
                          );
                        }

                        final documents =
                            snapshot.data?.docs ?? [];

                        if (documents.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No inventory items found.',
                              style: TextStyle(
                                color: _mediumBrown,
                              ),
                            ),
                          );
                        }

                        int remainingFor(
                          QueryDocumentSnapshot<
                                  Map<String, dynamic>>
                              doc,
                        ) {
                          final data = doc.data();

                          final available =
                              (data['availableStock'] as num?)
                                      ?.toInt() ??
                                  0;

                          return available -
                              _getAlreadyAddedQuantity(
                                doc.id,
                              );
                        }

                        if (selectedItemId != null) {
                          for (final doc in documents) {
                            if (doc.id == selectedItemId) {
                              selectedAvailableStock =
                                  remainingFor(doc);
                              break;
                            }
                          }
                        }

                        return Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedItemId,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: 'Select Item',
                                icon:
                                    Icons.inventory_2_outlined,
                              ),
                              items: documents.map(
                                (document) {
                                  final data =
                                      document.data();

                                  final name =
                                      data['name']?.toString() ??
                                          'Unnamed Item';

                                  final remaining =
                                      remainingFor(document);

                                  final disabled =
                                      remaining <= 0;

                                  return DropdownMenuItem<
                                      String>(
                                    value: document.id,
                                    enabled: !disabled,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(
                                            data['category']
                                                    ?.toString() ??
                                                'Other',
                                          ),
                                          size: 20,
                                          color: disabled
                                              ? Colors.grey
                                              : _bronze,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            name,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                            style: TextStyle(
                                              color: disabled
                                                  ? Colors.grey
                                                  : _darkBrown,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          disabled
                                              ? 'Out of stock'
                                              : '$remaining available',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: disabled
                                                ? Colors.red
                                                : Colors
                                                    .green
                                                    .shade700,
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                if (!dialogViewContext.mounted) {
                                  return;
                                }

                                setDialogState(() {
                                  selectedItemId = value;
                                  quantityController.clear();
                                  selectedAvailableStock = 0;

                                  if (value != null) {
                                    for (final doc in documents) {
                                      if (doc.id == value) {
                                        selectedAvailableStock =
                                            remainingFor(doc);
                                        break;
                                      }
                                    }
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    _bronzeLight.withOpacity(.38),
                                borderRadius:
                                    BorderRadius.circular(13),
                                border: Border.all(
                                  color: _bronzeLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: _surface,
                                      borderRadius:
                                          BorderRadius.circular(
                                              10),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 19,
                                      color: _bronzeDark,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  const Expanded(
                                    child: Text(
                                      'Available Stock',
                                      style: TextStyle(
                                        color: _mediumBrown,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    selectedItemId == null
                                        ? '-'
                                        : selectedAvailableStock
                                            .toString(),
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                      fontSize: 18,
                                      color: _bronzeDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 9),
                            const Text(
                              'Rented quantity cannot be greater than available stock.',
                              style: TextStyle(
                                color: _mutedText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: quantityController,
                              keyboardType:
                                  TextInputType.number,
                              decoration: _inputDecoration(
                                label: 'Quantity to Rent',
                                icon: Icons.numbers_outlined,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isAdding
                        ? null
                        : () => Navigator.of(
                              dialogContext,
                            ).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _mediumBrown,
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isAdding
                        ? null
                        : () async {
                            final quantity = int.tryParse(
                              quantityController.text.trim(),
                            );

                            if (selectedItemId == null) {
                              _showDialogMessage(
                                'Please select an item.',
                              );
                              return;
                            }

                            if (quantity == null ||
                                quantity <= 0) {
                              _showDialogMessage(
                                'Enter a valid quantity.',
                              );
                              return;
                            }

                            if (quantity >
                                selectedAvailableStock) {
                              _showDialogMessage(
                                'Quantity cannot be greater than available stock.',
                              );
                              return;
                            }

                            setDialogState(
                              () => isAdding = true,
                            );

                            try {
                              final selectedId =
                                  selectedItemId!;

                              final selectedDocument =
                                  await _inventoryCollection
                                      .doc(selectedId)
                                      .get();

                              if (!selectedDocument.exists) {
                                if (dialogViewContext.mounted) {
                                  setDialogState(
                                    () => isAdding = false,
                                  );
                                }

                                _showDialogMessage(
                                  'Selected inventory item no longer exists.',
                                );
                                return;
                              }

                              final data =
                                  selectedDocument.data() ?? {};

                              final itemName =
                                  data['name']?.toString() ??
                                      'Unnamed Item';

                              final category =
                                  data['category']?.toString() ??
                                      'Other';

                              final material =
                                  data['material']?.toString() ??
                                      'Unknown';

                              final rentPrice =
                                  (data['rentPrice'] as num?)
                                          ?.toDouble() ??
                                      0;

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                final existingIndex =
                                    _rentedItems.indexWhere(
                                  (item) =>
                                      item.itemId == selectedId,
                                );

                                if (existingIndex >= 0) {
                                  _rentedItems[existingIndex]
                                          .quantity +=
                                      quantity;
                                } else {
                                  _rentedItems.add(
                                    RentedItem(
                                      itemId: selectedId,
                                      name: itemName,
                                      category: category,
                                      material: material,
                                      quantity: quantity,
                                      rentPrice: rentPrice,
                                    ),
                                  );
                                }
                              });

                              isAdding = false;

                              if (dialogViewContext.mounted) {
                                Navigator.of(
                                  dialogContext,
                                ).pop();
                              }
                            } catch (e) {
                              if (dialogViewContext.mounted) {
                                setDialogState(
                                  () => isAdding = false,
                                );

                                _showDialogMessage(
                                  'Unable to add item: $e',
                                );
                              }
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bronze,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      quantityController.dispose();
    }
  }

  // ============================================================
  // ALREADY ADDED QUANTITY
  // ============================================================

  int _getAlreadyAddedQuantity(String itemId) {
    for (final item in _rentedItems) {
      if (item.itemId == itemId) {
        return item.quantity;
      }
    }

    return 0;
  }

  // ============================================================
  // REMOVE ITEM
  // ============================================================

  void _removeItem(int index) {
    setState(() {
      _rentedItems.removeAt(index);
    });
  }

  // ============================================================
  // GENERATE BILL
  // ============================================================

  Future<void> _generateBill() async {
    if (_currentUser == null) {
      _showMessage(
        'Please login before creating a bill.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateFrom == null) {
      _showMessage(
        'Please select Date From.',
      );
      return;
    }

    if (_dateTill == null) {
      _showMessage(
        'Please select Return Date.',
      );
      return;
    }

    if (_rentedItems.isEmpty) {
      _showMessage(
        'Please add at least one renting item.',
      );
      return;
    }

    // ==========================================================
    // CNIC VALIDATION
    // CNIC MUST CONTAIN EXACTLY 13 DIGITS
    // ==========================================================

    final cnicDigits = _cnicController.text
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (cnicDigits.length != 13) {
      _showMessage(
        'CNIC must contain exactly 13 digits.',
      );
      return;
    }

    final contactDigits = _contactController.text
        .replaceAll(RegExp(r'[^0-9]'), '');

    if (contactDigits.length != 11 ||
        !contactDigits.startsWith('03')) {
      _showMessage(
        'Contact number must be 11 digits and start with 03.',
      );
      return;
    }

    final rentalLocation =
        _rentalLocationController.text.trim();

    if (rentalLocation.isEmpty) {
      _showMessage(
        'Please enter rental location.',
      );
      return;
    }

    final subtotal = _subtotal;
    final discount = _discount;
    final finalTotal = _finalTotal;
    final paidAmount = _paidAmount;
    final remainingAmount = _remainingAmount;
    final paymentStatus = _paymentStatus;

    final billNumber = _generateBillNumber();
    final generatedAt = DateTime.now();

    setState(() {
      _isGenerating = true;
    });

    try {
      // ========================================================
      // USER-SCOPED REFERENCES
      // ========================================================

      final billReference = _billsCollection.doc();
      final customerReference = _customersCollection.doc();

      await _db.runTransaction(
        (transaction) async {
          final snapshots =
              <DocumentSnapshot<Map<String, dynamic>>>[];

          // ----------------------------------------------------
          // READ CURRENT USER'S INVENTORY
          // ----------------------------------------------------

          for (final item in _rentedItems) {
            final ref =
                _inventoryCollection.doc(item.itemId);

            snapshots.add(
              await transaction.get(ref),
            );
          }

          // ----------------------------------------------------
          // CHECK STOCK
          // ----------------------------------------------------

          for (var i = 0;
              i < _rentedItems.length;
              i++) {
            final item = _rentedItems[i];
            final snapshot = snapshots[i];

            if (!snapshot.exists) {
              throw Exception(
                '${item.name} no longer exists in inventory.',
              );
            }

            final available =
                (snapshot.data()?['availableStock'] as num?)
                        ?.toInt() ??
                    0;

            if (item.quantity > available) {
              throw Exception(
                'Only $available units of ${item.name} are available.',
              );
            }
          }

          // ----------------------------------------------------
          // DEDUCT STOCK FROM CURRENT USER'S INVENTORY
          // ----------------------------------------------------

          for (var i = 0;
              i < _rentedItems.length;
              i++) {
            final item = _rentedItems[i];
            final snapshot = snapshots[i];
            final data = snapshot.data() ?? {};

            final available =
                (data['availableStock'] as num?)?.toInt() ??
                    0;

            final rented =
                (data['rentedStock'] as num?)?.toInt() ??
                    0;

            transaction.update(
              snapshot.reference,
              {
                'availableStock':
                    available - item.quantity,
                'rentedStock':
                    rented + item.quantity,
                'updatedAt':
                    FieldValue.serverTimestamp(),
              },
            );
          }

          // ----------------------------------------------------
          // BILL ITEMS
          // ----------------------------------------------------

          final billItems = _rentedItems
              .map(
                (item) => {
                  'itemId': item.itemId,
                  'name': item.name,
                  'category': item.category,
                  'material': item.material,
                  'quantity': item.quantity,
                  'rentPrice': item.rentPrice,
                  'totalPrice': item.totalPrice,
                },
              )
              .toList();

          // ----------------------------------------------------
          // CREATE BILL
          //
          // Users/{uid}/bills/{billId}
          // ----------------------------------------------------

          transaction.set(
            billReference,
            {
              'billId': billReference.id,
              'billNumber': billNumber,

              'customerName':
                  _nameController.text.trim(),

              'contactNumber':
                  _contactController.text.trim(),

              'cnic':
                  _cnicController.text.trim(),

              // RENTAL LOCATION
              'rentalLocation':
                  rentalLocation,

              'dateFrom':
                  Timestamp.fromDate(_dateFrom!),

              'dateTill':
                  Timestamp.fromDate(_dateTill!),

              'items': billItems,

              'subtotal': subtotal,
              'discount': discount,
              'totalAmount': finalTotal,

              'paidAmount': paidAmount,
              'remainingAmount': remainingAmount,

              'paymentStatus': paymentStatus,

              'rentalStatus': 'rented',

              'billStatus': 'active',
              'finalBill': false,

              'status': 'active',

              'createdAt':
                  FieldValue.serverTimestamp(),

              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );

          // ----------------------------------------------------
          // CREATE CUSTOMER
          //
          // Users/{uid}/customers/{customerId}
          // ----------------------------------------------------

          transaction.set(
            customerReference,
            {
              'name':
                  _nameController.text.trim(),

              'contactNumber':
                  _contactController.text.trim(),

              'cnic':
                  _cnicController.text.trim(),

              // RENTAL LOCATION
              'rentalLocation':
                  rentalLocation,

              'lastBillId':
                  billReference.id,

              'lastBillNumber':
                  billNumber,

              'lastRentalFrom':
                  Timestamp.fromDate(_dateFrom!),

              'lastRentalTill':
                  Timestamp.fromDate(_dateTill!),

              'rentalItems': billItems,

              'subtotal': subtotal,
              'discount': discount,
              'totalAmount': finalTotal,

              'paidAmount': paidAmount,
              'remainingAmount': remainingAmount,

              'paymentStatus': paymentStatus,

              'rentalStatus': 'rented',

              'createdAt':
                  FieldValue.serverTimestamp(),

              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        },
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // CREATE PDF
      // ========================================================

      final pdf = await _buildBillPdf(
        billNumber: billNumber,
        generatedAt: generatedAt,
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // OPEN PREVIEW
      // ========================================================

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BillPreviewScreen(
            pdfBytes: pdf,
            billId: billNumber,
            customerName:
                _nameController.text.trim(),
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // CLEAR FORM
      // ========================================================

      _nameController.clear();
      _cnicController.clear();
      _contactController.clear();
      _rentalLocationController.clear();

      _discountController.text = '0';
      _paidController.text = '0';

      setState(() {
        _dateFrom = null;
        _dateTill = null;
        _rentedItems.clear();
      });

      _showMessage(
        'Bill $billNumber generated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      var message = e.toString();

      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }

      _showMessage(
        'Bill could not be generated: $message',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD PDF
  // ============================================================

  Future<Uint8List> _buildBillPdf({
    required String billNumber,
    required DateTime generatedAt,
  }) async {
    final pdf = pw.Document();

    final status = _paymentStatus;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------

            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                ),
                borderRadius:
                    pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RENTAL BILL',
                        style: pw.TextStyle(
                          fontSize: 25,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Inventory Management',
                        style:
                            const pw.TextStyle(
                          fontSize: 10,
                          color:
                              PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding:
                        const pw.EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration:
                        pw.BoxDecoration(
                      border: pw.Border.all(
                        color:
                            PdfColors.grey500,
                      ),
                      borderRadius:
                          pw.BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'BILL #',
                          style:
                              const pw.TextStyle(
                            fontSize: 8,
                            color:
                                PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          billNumber,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Generated: ${_formatDate(generatedAt)}',
                          style:
                              const pw.TextStyle(
                            fontSize: 8,
                            color:
                                PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            // --------------------------------------------------
            // CUSTOMER DETAILS
            // --------------------------------------------------

            pw.Text(
              'CUSTOMER DETAILS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                    pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Name: ${_nameController.text.trim()}',
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Contact: ${_contactController.text.trim()}',
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 7),

                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'CNIC: ${_cnicController.text.trim()}',
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Bill Date: ${_formatDate(generatedAt)}',
                        ),
                      ),
                    ],
                  ),

                  // RENTAL LOCATION
                  pw.SizedBox(height: 7),

                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Rental Location: ${_rentalLocationController.text.trim()}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            // --------------------------------------------------
            // RENTAL PERIOD
            // --------------------------------------------------

            pw.Text(
              'RENTAL PERIOD',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.all(11),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                ),
                borderRadius:
                    pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'From: ${_formatDate(_dateFrom!)}',
                  ),
                  pw.Text(
                    'Return: ${_formatDate(_dateTill!)}',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 18),

            // --------------------------------------------------
            // ITEMS
            // --------------------------------------------------

            pw.Text(
              'RENTED ITEMS',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border:
                  pw.TableBorder.all(
                color: PdfColors.grey400,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.1),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.7),
              },
              children: [
                pw.TableRow(
                  decoration:
                      const pw.BoxDecoration(
                    color:
                        PdfColors.grey200,
                  ),
                  children: [
                    _pdfCell(
                      'Item',
                      bold: true,
                    ),
                    _pdfCell(
                      'Qty',
                      bold: true,
                    ),
                    _pdfCell(
                      'Rate',
                      bold: true,
                    ),
                    _pdfCell(
                      'Amount',
                      bold: true,
                    ),
                  ],
                ),
                ..._rentedItems.map(
                  (item) => pw.TableRow(
                    children: [
                      _pdfCell(item.name),
                      _pdfCell(
                        item.quantity.toString(),
                      ),
                      _pdfCell(
                        'Rs. ${item.rentPrice.toStringAsFixed(0)}',
                      ),
                      _pdfCell(
                        'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 18),

            // --------------------------------------------------
            // AMOUNT SUMMARY
            // --------------------------------------------------

            pw.Align(
              alignment:
                  pw.Alignment.centerRight,
              child: pw.Container(
                width: 270,
                padding:
                    const pw.EdgeInsets.all(14),
                decoration:
                    pw.BoxDecoration(
                  border: pw.Border.all(
                    color:
                        PdfColors.grey400,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(
                    8,
                  ),
                ),
                child: pw.Column(
                  children: [
                    _pdfAmountRow(
                      'Actual Amount',
                      _subtotal,
                    ),
                    pw.SizedBox(height: 7),
                    _pdfAmountRow(
                      'Discount',
                      _discount,
                    ),
                    pw.Divider(),
                    _pdfAmountRow(
                      'Total Amount',
                      _finalTotal,
                      bold: true,
                    ),
                    pw.SizedBox(height: 7),
                    _pdfAmountRow(
                      'Paid',
                      _paidAmount,
                    ),
                    pw.SizedBox(height: 7),
                    _pdfAmountRow(
                      'Remaining',
                      _remainingAmount,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 14),

            // --------------------------------------------------
            // PAYMENT STATUS
            // --------------------------------------------------

            pw.Align(
              alignment:
                  pw.Alignment.centerRight,
              child: pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration:
                    pw.BoxDecoration(
                  border: pw.Border.all(
                    color: status == 'paid'
                        ? PdfColors.green
                        : status == 'partial'
                            ? PdfColors.orange
                            : PdfColors.red,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  _statusTitle(status)
                      .toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight:
                        pw.FontWeight.bold,
                    color: status == 'paid'
                        ? PdfColors.green
                        : status == 'partial'
                            ? PdfColors.orange
                            : PdfColors.red,
                  ),
                ),
              ),
            ),

            pw.SizedBox(height: 14),

            if (status != 'paid')
              pw.Container(
                width: double.infinity,
                padding:
                    const pw.EdgeInsets.all(12),
                decoration:
                    pw.BoxDecoration(
                  color:
                      PdfColors.grey100,
                  border: pw.Border.all(
                    color:
                        PdfColors.grey400,
                  ),
                  borderRadius:
                      pw.BorderRadius.circular(
                    8,
                  ),
                ),
                child: pw.Text(
                  status == 'unpaid'
                      ? 'Payment Note: Bill payment is due on or before the return date.'
                      : 'Payment Note: Remaining balance of Rs. ${_remainingAmount.toStringAsFixed(0)} is due on or before the return date.',
                  style:
                      const pw.TextStyle(
                    fontSize: 9,
                    color:
                        PdfColors.grey800,
                  ),
                ),
              ),

            pw.Spacer(),

            pw.Divider(),

            pw.SizedBox(height: 7),

            pw.Center(
              child: pw.Text(
                'Thank you for your business.',
                style:
                    const pw.TextStyle(
                  fontSize: 9,
                  color:
                      PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Uint8List.fromList(
      await pdf.save(),
    );
  }

  // ============================================================
  // PDF AMOUNT ROW
  // ============================================================

  pw.Widget _pdfAmountRow(
    String label,
    double amount, {
    bool bold = false,
  }) {
    return pw.Row(
      mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: bold ? 11 : 9,
            fontWeight: bold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: pw.TextStyle(
            fontSize: bold ? 11 : 9,
            fontWeight: bold
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PDF CELL
  // ============================================================

  pw.Widget _pdfCell(
    String text, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ============================================================
  // RENTED ITEM CARD
  // ============================================================

  Widget _rentedItemCard(
    RentedItem item,
    int index, {
    bool compact = false,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkBrown.withOpacity(.035),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _itemIcon(item),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _itemName(item),
                    ),
                    _removeButton(index),
                  ],
                ),
                const SizedBox(height: 13),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _itemInfoChip(
                      'Qty',
                      item.quantity.toString(),
                      _bronze,
                    ),
                    _itemInfoChip(
                      'Rate',
                      'Rs. ${item.rentPrice.toStringAsFixed(0)}',
                      _mediumBrown,
                    ),
                    _itemInfoChip(
                      'Amount',
                      'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                      _bronzeDark,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                _itemIcon(item),
                const SizedBox(width: 14),
                Expanded(
                  child:
                      _itemName(item),
                ),
                const SizedBox(width: 12),
                _itemInfoChip(
                  'Quantity',
                  item.quantity.toString(),
                  _bronze,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 11,
                          color: _mutedText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 15,
                          color:
                              _darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                _removeButton(index),
              ],
            ),
    );
  }

  // ============================================================
  // ITEM ICON
  // ============================================================

  Widget _itemIcon(RentedItem item) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color:
            _bronzeLight.withOpacity(.45),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Icon(
        _getCategoryIcon(
          item.category,
        ),
        color: _bronzeDark,
        size: 25,
      ),
    );
  }

  // ============================================================
  // ITEM NAME
  // ============================================================

  Widget _itemName(RentedItem item) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.w800,
            color: _darkBrown,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Material: ${item.material}',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            fontSize: 12,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ITEM CHIP
  // ============================================================

  Widget _itemInfoChip(
    String label,
    String value,
    Color valueColor,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
            valueColor.withOpacity(.07),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              valueColor.withOpacity(.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              fontSize: 9,
              color: _mutedText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // REMOVE BUTTON
  // ============================================================

  Widget _removeButton(int index) {
    return IconButton(
      tooltip: 'Remove Item',
      onPressed: () => _removeItem(index),
      style: IconButton.styleFrom(
        backgroundColor:
            Colors.red.withOpacity(.07),
        foregroundColor:
            Colors.red.shade700,
      ),
      icon: const Icon(
        Icons.close,
        size: 19,
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(
    String category,
  ) {
    switch (category) {
      case 'Furniture':
        return Icons.chair_outlined;

      case 'Decoration':
        return Icons.auto_awesome_outlined;

      case 'Tent':
        return Icons.house_outlined;

      case 'Lighting':
        return Icons.lightbulb_outline;

      case 'Sound Equipment':
        return Icons.speaker_outlined;

      case 'Stage Equipment':
        return Icons.theater_comedy_outlined;

      case 'Catering':
        return Icons.restaurant_outlined;

      default:
        return Icons.inventory_2_outlined;
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(
        color: _mutedText,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: _bronze,
        size: 21,
      ),
      filled: true,
      fillColor: _surface,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: _bronze,
          width: 1.6,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide:
            const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY ROW
  // ============================================================

  Widget _summaryRow(
    String label,
    double amount, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize:
                  bold ? 15 : 13,
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: bold
                  ? _darkBrown
                  : _mediumBrown,
            ),
          ),
        ),
        Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize:
                bold ? 17 : 14,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w700,
            color:
                valueColor ?? _darkBrown,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        decoration:
            BoxDecoration(
          color: _surface,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: _border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color:
                    _bronzeLight.withOpacity(
                  .42,
                ),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child:
                  const Icon(
                Icons.calendar_month_outlined,
                color: _bronzeDark,
                size: 20,
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
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color:
                          _mutedText,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date == null
                        ? 'Select date'
                        : _formatDate(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                      color: date == null
                          ? _mutedText
                          : _darkBrown,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _mutedText,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w800,
            color: _darkBrown,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style:
                const TextStyle(
              fontSize: 12,
              color: _mutedText,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required Widget child,
    EdgeInsets padding =
        const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration:
          BoxDecoration(
        color: _surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: _border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _darkBrown.withOpacity(.035),
            blurRadius: 18,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    bool mobile,
  ) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(
        mobile ? 18 : 24,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            _bronzeDark,
            _bronze,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _headerIcon(),
                const SizedBox(height: 15),
                _headerText(),
              ],
            )
          : Row(
              children: [
                _headerIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      _headerText(),
                ),
              ],
            ),
    );
  }

  Widget _headerIcon() {
    return Container(
      width: 58,
      height: 58,
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.15),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.18),
        ),
      ),
      child:
          const Icon(
        Icons.receipt_long_outlined,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'New Rental Bill',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Create a rental bill, record payment, and update inventory stock.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADD ITEM BUTTON
  // ============================================================

  Widget _addItemButton() {
    return ElevatedButton.icon(
      onPressed:
          _showAddItemModal,
      icon: const Icon(
        Icons.add,
        size: 19,
      ),
      label:
          const Text(
        'Add Item',
        style:
            TextStyle(
          fontWeight:
              FontWeight.w700,
        ),
      ),
      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            _bronze,
        foregroundColor:
            Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            11,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY ITEMS
  // ============================================================

  Widget _emptyItemsState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 20,
      ),
      decoration:
          BoxDecoration(
        color: _background,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  _bronzeLight.withOpacity(
                .42,
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                const Icon(
              Icons.shopping_cart_outlined,
              size: 27,
              color: _bronzeDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No renting items added',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w800,
              color:
                  _darkBrown,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Click "Add Item" to select inventory items.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color: _mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AMOUNT SUMMARY
  // ============================================================

  Widget _amountSummary() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: _background,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Actual Amount',
            _subtotal,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller:
                _discountController,
            keyboardType:
                const TextInputType
                    .numberWithOptions(
              decimal: true,
            ),
            onChanged: (_) =>
                setState(() {}),
            decoration:
                _inputDecoration(
              label:
                  'Discount Amount',
              icon:
                  Icons.discount_outlined,
            ).copyWith(
              hintText: '0',
            ),
          ),
          const SizedBox(height: 13),
          _summaryRow(
            'Discount',
            _discount,
            valueColor:
                Colors.orange.shade700,
          ),
          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 15,
            ),
            child:
                Divider(
              color: _border,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration:
                BoxDecoration(
              color:
                  _bronzeLight.withOpacity(
                .35,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: _summaryRow(
              'Total Amount',
              _finalTotal,
              bold: true,
              valueColor:
                  _bronzeDark,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT DETAILS
  // ============================================================

  Widget _paymentDetails(
    String status,
  ) {
    return Column(
      children: [
        TextFormField(
          controller:
              _paidController,
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) =>
              setState(() {}),
          decoration:
              _inputDecoration(
            label:
                'Paid Amount',
            icon:
                Icons.payments_outlined,
          ).copyWith(
            hintText: '0',
          ),
        ),
        const SizedBox(height: 14),
        _summaryRow(
          'Paid',
          _paidAmount,
          valueColor:
              Colors.green.shade700,
        ),
        const SizedBox(height: 11),
        _summaryRow(
          'Remaining',
          _remainingAmount,
          bold: true,
          valueColor:
              _remainingAmount > 0
                  ? Colors.red.shade700
                  : Colors.green.shade700,
        ),
        const SizedBox(height: 17),
        _paymentStatusCard(
          status,
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT STATUS CARD
  // ============================================================

  Widget _paymentStatusCard(
    String status,
  ) {
    final color = status == 'paid'
        ? Colors.green.shade700
        : status == 'partial'
            ? Colors.orange.shade700
            : Colors.red.shade700;

    final icon = status == 'paid'
        ? Icons.check_circle_outline
        : status == 'partial'
            ? Icons.timelapse
            : Icons.pending_actions_outlined;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.07),
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color:
              color.withOpacity(.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Status',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusTitle(
                    status,
                  ),
                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    color: color,
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
  // FORM CONTENT
  // ============================================================

  Widget _buildFormContent(
    bool mobile,
  ) {
    final status =
        _paymentStatus;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _buildHeader(
          mobile,
        ),

        const SizedBox(height: 24),

        // ------------------------------------------------------
        // CUSTOMER DETAILS
        // ------------------------------------------------------

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Customer Details',
                subtitle:
                    'Enter the customer information for this rental.',
              ),
              const SizedBox(height: 18),

              LayoutBuilder(
                builder: (_, box) {
                  final two =
                      box.maxWidth >= 700;

                  final fields = [
                    TextFormField(
                      controller:
                          _nameController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          _inputDecoration(
                        label:
                            'Customer Name',
                        icon:
                            Icons.person_outline,
                      ),
                      validator: (v) =>
                          v == null ||
                                  v.trim()
                                      .isEmpty
                              ? 'Please enter customer name.'
                              : null,
                    ),
                    TextFormField(
                      controller:
                          _contactController,
                      keyboardType:
                          TextInputType.phone,
                      onChanged:
                          _formatContact,
                      decoration:
                          _inputDecoration(
                        label:
                            'Contact Number',
                        icon:
                            Icons.phone_outlined,
                      ).copyWith(
                        hintText:
                            '0300-1234567',
                      ),
                      validator: (v) {
                        final d =
                            (v ?? '')
                                .replaceAll(
                          RegExp(
                            r'[^0-9]',
                          ),
                          '',
                        );

                        return d.length !=
                                    11 ||
                                !d.startsWith(
                                  '03',
                                )
                            ? 'Enter a valid 11-digit mobile number.'
                            : null;
                      },
                    ),
                    TextFormField(
                      controller:
                          _cnicController,
                      keyboardType:
                          TextInputType.number,
                      onChanged:
                          _formatCnic,
                      maxLength: 15,
                      decoration:
                          _inputDecoration(
                        label:
                            'CNIC #',
                        icon:
                            Icons.badge_outlined,
                      ).copyWith(
                        hintText:
                            'XXXXX-XXXXXXX-X',
                        counterText: '',
                      ),
                      validator: (v) {
                        final d =
                            (v ?? '')
                                .replaceAll(
                          RegExp(
                            r'[^0-9]',
                          ),
                          '',
                        );

                        return d.length !=
                                13
                            ? 'CNIC must contain exactly 13 digits.'
                            : null;
                      },
                    ),
                  ];

                  if (!two) {
                    return Column(
                      children: [
                        fields[0],
                        const SizedBox(
                          height: 14,
                        ),
                        fields[1],
                        const SizedBox(
                          height: 14,
                        ),
                        fields[2],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child:
                            fields[0],
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child:
                            fields[1],
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child:
                            fields[2],
                      ),
                    ],
                  );
                },
              ),

              // ------------------------------------------------
              // RENTAL LOCATION
              // ------------------------------------------------

              const SizedBox(height: 14),

              TextFormField(
                controller:
                    _rentalLocationController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    _inputDecoration(
                  label:
                      'Rental Location',
                  icon:
                      Icons.location_on_outlined,
                ).copyWith(
                  hintText:
                      'Enter rental / event location',
                ),
                validator: (v) =>
                    v == null ||
                            v.trim().isEmpty
                        ? 'Please enter rental location.'
                        : null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // RENTAL PERIOD
        // ------------------------------------------------------

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Rental Period',
                subtitle:
                    'Select when the rental starts and when the items are expected back.',
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (_, box) {
                  if (box.maxWidth <
                      600) {
                    return Column(
                      children: [
                        _dateField(
                          title:
                              'Date From',
                          date:
                              _dateFrom,
                          onTap: () =>
                              _selectDate(
                            isFrom:
                                true,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        _dateField(
                          title:
                              'Return Date',
                          date:
                              _dateTill,
                          onTap: () =>
                              _selectDate(
                            isFrom:
                                false,
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child:
                            _dateField(
                          title:
                              'Date From',
                          date:
                              _dateFrom,
                          onTap: () =>
                              _selectDate(
                            isFrom:
                                true,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child:
                            _dateField(
                          title:
                              'Return Date',
                          date:
                              _dateTill,
                          onTap: () =>
                              _selectDate(
                            isFrom:
                                false,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // RENTING ITEMS
        // ------------------------------------------------------

        _sectionCard(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (_, box) {
                  if (box.maxWidth <
                      520) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        _sectionTitle(
                          'Renting Items',
                          subtitle:
                              'Items selected for this rental.',
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                              _addItemButton(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child:
                            _sectionTitle(
                          'Renting Items',
                          subtitle:
                              'Items selected for this rental.',
                        ),
                      ),
                      _addItemButton(),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 18,
              ),

              if (_rentedItems.isEmpty)
                _emptyItemsState()
              else
                LayoutBuilder(
                  builder: (_, box) {
                    final compact =
                        box.maxWidth <
                            680;

                    return Column(
                      children:
                          List.generate(
                        _rentedItems.length,
                        (i) =>
                            _rentedItemCard(
                          _rentedItems[i],
                          i,
                          compact:
                              compact,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        // ------------------------------------------------------
        // SUMMARY
        // ------------------------------------------------------

        if (_rentedItems
            .isNotEmpty) ...[
          const SizedBox(height: 18),
          _sectionCard(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'Bill Summary & Payment',
                  subtitle:
                      'Review the amount and record the customer payment.',
                ),
                const SizedBox(
                  height: 18,
                ),
                LayoutBuilder(
                  builder: (_, box) {
                    if (box.maxWidth <
                        780) {
                      return Column(
                        children: [
                          _amountSummary(),
                          const SizedBox(
                            height: 22,
                          ),
                          _paymentDetails(
                            status,
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child:
                              _amountSummary(),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        Expanded(
                          child:
                              _paymentDetails(
                            status,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 22),

        // ------------------------------------------------------
        // GENERATE BUTTON
        // ------------------------------------------------------

        SizedBox(
          width: double.infinity,
          height: 58,
          child:
              ElevatedButton.icon(
            onPressed:
                _isGenerating
                    ? null
                    : _generateBill,
            icon: _isGenerating
                ? const SizedBox(
                    width: 21,
                    height: 21,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.receipt_long_outlined,
                  ),
            label: Text(
              _isGenerating
                  ? 'Generating Bill...'
                  : 'Generate Bill',
              style:
                  const TextStyle(
                fontSize: 15,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  _bronzeDark,
              foregroundColor:
                  Colors.white,
              disabledBackgroundColor:
                  _bronze.withOpacity(.5),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _background,
      appBar: AppBar(
        backgroundColor:
            _surface,
        foregroundColor:
            _darkBrown,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        titleSpacing: 18,
        title:
            const Text(
          'Create New Bill',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w800,
            color:
                _darkBrown,
          ),
        ),
      ),
      drawer:
          const AdminDrawer(
        selectedIndex: 3,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final width =
                constraints.maxWidth;

            final mobile =
                width < 650;

            final tablet =
                width >= 650 &&
                    width < 950;

            final horizontal =
                mobile
                    ? 14.0
                    : tablet
                        ? 24.0
                        : 34.0;

            return SingleChildScrollView(
              padding:
                  EdgeInsets.fromLTRB(
                horizontal,
                20,
                horizontal,
                35,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child: Form(
                    key: _formKey,
                    child:
                        _buildFormContent(
                      mobile,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior
                .floating,
        backgroundColor:
            _darkBrown,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG MESSAGE
  // ============================================================

  void _showDialogMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior
                .floating,
        backgroundColor:
            _darkBrown,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RENTED ITEM MODEL
// ============================================================================

class RentedItem {
  final String itemId;
  final String name;
  final String category;
  final String material;

  int quantity;

  final double rentPrice;

  RentedItem({
    required this.itemId,
    required this.name,
    required this.category,
    required this.material,
    required this.quantity,
    required this.rentPrice,
  });

  double get totalPrice =>
      quantity * rentPrice;
}

// ============================================================================
// BILL PREVIEW
// ============================================================================

class BillPreviewScreen
    extends StatelessWidget {
  final Uint8List pdfBytes;
  final String billId;
  final String customerName;

  const BillPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.billId,
    required this.customerName,
  });

  // ============================================================
  // SAVE / SHARE PDF
  // ============================================================

  Future<void> _savePdf(
    BuildContext context,
  ) async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename:
            'Bill_${billId.replaceAll(' ', '_')}.pdf',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Bill ready to save/share.',
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save/share the bill.',
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD PREVIEW
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          _BillScreenState._background,
      appBar: AppBar(
        backgroundColor:
            _BillScreenState._surface,
        foregroundColor:
            _BillScreenState._darkBrown,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        title:
            const Text(
          'Bill Preview',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                'Save / Download Bill',
            onPressed: () =>
                _savePdf(context),
            style:
                IconButton.styleFrom(
              foregroundColor:
                  _BillScreenState
                      ._bronzeDark,
            ),
            icon:
                const Icon(
              Icons.save_outlined,
            ),
          ),
          IconButton(
            tooltip:
                'Print / Share',
            onPressed: () async {
              try {
                await Printing.sharePdf(
                  bytes: pdfBytes,
                  filename:
                      'Bill_${billId.replaceAll(' ', '_')}.pdf',
                );
              } catch (_) {}
            },
            style:
                IconButton.styleFrom(
              foregroundColor:
                  _BillScreenState
                      ._bronzeDark,
            ),
            icon:
                const Icon(
              Icons.print_outlined,
            ),
          ),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) async =>
            pdfBytes,
        canChangePageFormat:
            false,
        canChangeOrientation:
            false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName:
            'Bill_${billId.replaceAll(' ', '_')}.pdf',
      ),
    );
  }
}