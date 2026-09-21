// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'dart:typed_data';
// // import 'bill_generate.dart';

// // class BillManagement extends StatefulWidget {
// //   const BillManagement({super.key});

// //   @override
// //   State<BillManagement> createState() => _BillManagementState();
// // }

// // class _BillManagementState extends State<BillManagement> {
// //   final TextEditingController _searchController = TextEditingController();

// //   String _selectedFilter = 'All';

// //   List<QueryDocumentSnapshot> _allBills = [];
// //   List<QueryDocumentSnapshot> _filteredBills = [];

// //   @override
// //   void initState() {
// //     super.initState();

// //     _searchController.addListener(() {
// //       _applyFilters();
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   void _applyFilters() {
// //     final search = _searchController.text.trim().toLowerCase();

// //     List<QueryDocumentSnapshot> results = List.from(_allBills);

// //     // Status filter
// //     if (_selectedFilter != 'All') {
// //       results = results.where((doc) {
// //         final data = doc.data() as Map<String, dynamic>;

// //         final status = (data['status'] ?? 'unpaid').toString().toLowerCase();

// //         return status == _selectedFilter.toLowerCase();
// //       }).toList();
// //     }

// //     // EXACT SEARCH
// //     if (search.isNotEmpty) {
// //       results = results.where((doc) {
// //         final data = doc.data() as Map<String, dynamic>;

// //         final name = (data['name'] ?? '').toString().toLowerCase().trim();

// //         final billNumber = (data['billNumber'] ?? '')
// //             .toString()
// //             .toLowerCase()
// //             .trim();

// //         final nic = (data['nic'] ?? data['cnic'] ?? '')
// //             .toString()
// //             .toLowerCase()
// //             .trim();

// //         // Exact match only.
// //         return name == search || billNumber == search || nic == search;
// //       }).toList();
// //     }

// //     setState(() {
// //       _filteredBills = results;
// //     });
// //   }

// //   void _changeFilter(String filter) {
// //     setState(() {
// //       _selectedFilter = filter;
// //     });

// //     _applyFilters();
// //   }

// //   String _getStatus(Map<String, dynamic> data) {
// //     final status = (data['status'] ?? 'unpaid').toString().toLowerCase();

// //     if (status == 'paid') {
// //       return 'Paid';
// //     }

// //     if (status == 'partial') {
// //       return 'Partial';
// //     }

// //     return 'Unpaid';
// //   }

// //   Color _statusColor(String status) {
// //     switch (status.toLowerCase()) {
// //       case 'paid':
// //         return Colors.green;

// //       case 'partial':
// //         return Colors.orange;

// //       case 'unpaid':
// //         return Colors.red;

// //       default:
// //         return Colors.grey;
// //     }
// //   }

// //   String _formatAmount(dynamic amount) {
// //     if (amount == null) return 'Rs. 0';

// //     if (amount is num) {
// //       return 'Rs. ${amount.toStringAsFixed(0)}';
// //     }

// //     final parsed = double.tryParse(amount.toString());

// //     if (parsed == null) {
// //       return 'Rs. ${amount.toString()}';
// //     }

// //     return 'Rs. ${parsed.toStringAsFixed(0)}';
// //   }

// //   String _getRented(dynamic rented) {
// //     if (rented == null) return '0';

// //     if (rented is List) {
// //       return rented.length.toString();
// //     }

// //     if (rented is num) {
// //       return rented.toString();
// //     }

// //     return rented.toString();
// //   }

// //   Future<void> _openBillPreview(
// //     BuildContext context,
// //     QueryDocumentSnapshot document,
// //   ) async {
// //     final data = document.data() as Map<String, dynamic>;

// //     final pdfData = data['pdfBytes'];

// //     if (pdfData == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('PDF for this bill was not found.')),
// //       );
// //       return;
// //     }

// //     // final List<int> pdf = List<int>.from(pdfData);
// //     final Uint8List pdf = Uint8List.fromList(List<int>.from(pdfData));

// //     final billNumber = (data['billNumber'] ?? document.id).toString();

// //     final customerName = (data['name'] ?? 'Customer').toString();

// //     // await Navigator.push(
// //     //   context,
// //     //   MaterialPageRoute(
// //     //     builder: (context) => BillPreviewScreen(
// //     //       pdfBytes: pdf,
// //     //       billId: billNumber,
// //     //       customerName: customerName,
// //     //     ),
// //     //   ),
// //     // );

// //     await Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => BillPreviewScreen(
// //           pdfBytes: pdf,
// //           billId: billNumber,
// //           customerName: customerName,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSearchAndFilter() {
// //     return LayoutBuilder(
// //       builder: (context, constraints) {
// //         final isSmall = constraints.maxWidth < 650;

// //         if (isSmall) {
// //           return Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               _buildSearchField(),
// //               const SizedBox(height: 12),
// //               _buildFilterButton(),
// //             ],
// //           );
// //         }

// //         return Row(
// //           children: [
// //             Expanded(child: _buildSearchField()),
// //             const SizedBox(width: 12),
// //             _buildFilterButton(),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildSearchField() {
// //     return TextField(
// //       controller: _searchController,
// //       textInputAction: TextInputAction.search,
// //       decoration: InputDecoration(
// //         hintText: 'Search name, bill number or CNIC',
// //         prefixIcon: const Icon(Icons.search),
// //         suffixIcon: _searchController.text.isNotEmpty
// //             ? IconButton(
// //                 icon: const Icon(Icons.clear),
// //                 onPressed: () {
// //                   _searchController.clear();
// //                 },
// //               )
// //             : null,
// //         filled: true,
// //         fillColor: Colors.white,
// //         contentPadding: const EdgeInsets.symmetric(
// //           horizontal: 16,
// //           vertical: 15,
// //         ),
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide.none,
// //         ),
// //         enabledBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide(color: Colors.grey.shade200),
// //         ),
// //         focusedBorder: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilterButton() {
// //     return PopupMenuButton<String>(
// //       onSelected: _changeFilter,
// //       offset: const Offset(0, 50),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       itemBuilder: (context) {
// //         return const [
// //           PopupMenuItem(value: 'All', child: Text('All')),
// //           PopupMenuItem(value: 'Paid', child: Text('Paid')),
// //           PopupMenuItem(value: 'Unpaid', child: Text('Unpaid')),
// //           PopupMenuItem(value: 'Partial', child: Text('Partial')),
// //         ];
// //       },
// //       child: Container(
// //         height: 52,
// //         padding: const EdgeInsets.symmetric(horizontal: 18),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: Colors.grey.shade200),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Icon(Icons.filter_list_rounded, size: 21),
// //             const SizedBox(width: 8),
// //             Text(
// //               _selectedFilter,
// //               style: const TextStyle(fontWeight: FontWeight.w600),
// //             ),
// //             const SizedBox(width: 5),
// //             const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDesktopTable() {
// //     return Container(
// //       width: double.infinity,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: ClipRRect(
// //         borderRadius: BorderRadius.circular(16),
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           child: DataTable(
// //             columnSpacing: 30,
// //             headingRowHeight: 55,
// //             dataRowMinHeight: 68,
// //             dataRowMaxHeight: 76,
// //             headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
// //             columns: const [
// //               DataColumn(
// //                 label: Text(
// //                   'Name',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               DataColumn(
// //                 label: Text(
// //                   'Contact',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               DataColumn(
// //                 label: Text(
// //                   'Rented',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               DataColumn(
// //                 label: Text(
// //                   'Status',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               DataColumn(
// //                 label: Text(
// //                   'Total Bill',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               DataColumn(
// //                 label: Text(
// //                   'Action',
// //                   style: TextStyle(fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //             ],
// //             rows: _filteredBills.map((doc) {
// //               final data = doc.data() as Map<String, dynamic>;

// //               final name = (data['name'] ?? 'Unknown').toString();

// //               final contact =
// //                   (data['contact'] ?? data['phone'] ?? data['mobile'] ?? '-')
// //                       .toString();

// //               final rented = _getRented(data['rented'] ?? data['rentedItems']);

// //               final status = _getStatus(data);

// //               final total =
// //                   data['totalBill'] ??
// //                   data['totalAmount'] ??
// //                   data['total'] ??
// //                   0;

// //               return DataRow(
// //                 cells: [
// //                   DataCell(
// //                     Text(
// //                       name,
// //                       style: const TextStyle(fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(Text(contact)),
// //                   DataCell(Text(rented)),
// //                   DataCell(_buildStatusBadge(status)),
// //                   DataCell(
// //                     Text(
// //                       _formatAmount(total),
// //                       style: const TextStyle(fontWeight: FontWeight.w600),
// //                     ),
// //                   ),
// //                   DataCell(_buildPreviewButton(doc)),
// //                 ],
// //               );
// //             }).toList(),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMobileList() {
// //     if (_filteredBills.isEmpty) {
// //       return _buildEmptyState();
// //     }

// //     return Column(
// //       children: _filteredBills.map((doc) {
// //         final data = doc.data() as Map<String, dynamic>;

// //         final name = (data['name'] ?? 'Unknown').toString();

// //         final contact =
// //             (data['contact'] ?? data['phone'] ?? data['mobile'] ?? '-')
// //                 .toString();

// //         final rented = _getRented(data['rented'] ?? data['rentedItems']);

// //         final status = _getStatus(data);

// //         final total =
// //             data['totalBill'] ?? data['totalAmount'] ?? data['total'] ?? 0;

// //         return Container(
// //           width: double.infinity,
// //           margin: const EdgeInsets.only(bottom: 12),
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(14),
// //             border: Border.all(color: Colors.grey.shade200),
// //           ),
// //           child: Column(
// //             children: [
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: Text(
// //                       name,
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                   _buildStatusBadge(status),
// //                 ],
// //               ),

// //               const SizedBox(height: 14),

// //               Row(
// //                 children: [
// //                   Expanded(child: _mobileInfo('Contact', contact)),
// //                   Expanded(child: _mobileInfo('Rented', rented)),
// //                 ],
// //               ),

// //               const SizedBox(height: 12),

// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: _mobileInfo('Total Bill', _formatAmount(total)),
// //                   ),
// //                   const SizedBox(width: 10),
// //                   Expanded(child: _buildPreviewButton(doc, fullWidth: true)),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         );
// //       }).toList(),
// //     );
// //   }

// //   Widget _mobileInfo(String title, String value) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           title,
// //           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           value,
// //           overflow: TextOverflow.ellipsis,
// //           style: const TextStyle(fontWeight: FontWeight.w600),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildStatusBadge(String status) {
// //     final color = _statusColor(status);

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.10),
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Text(
// //         status,
// //         style: TextStyle(
// //           color: color,
// //           fontSize: 12,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPreviewButton(
// //     QueryDocumentSnapshot doc, {
// //     bool fullWidth = false,
// //   }) {
// //     return SizedBox(
// //       width: fullWidth ? double.infinity : null,
// //       height: 40,
// //       child: OutlinedButton.icon(
// //         onPressed: () {
// //           _openBillPreview(context, doc);
// //         },
// //         icon: const Icon(Icons.visibility_outlined, size: 18),
// //         label: const Text('Preview Bill'),
// //         style: OutlinedButton.styleFrom(
// //           foregroundColor: const Color(0xFF2563EB),
// //           side: const BorderSide(color: Color(0xFF2563EB)),
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEmptyState() {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: Column(
// //         children: [
// //           Icon(
// //             Icons.receipt_long_outlined,
// //             size: 55,
// //             color: Colors.grey.shade400,
// //           ),
// //           const SizedBox(height: 14),
// //           Text(
// //             _searchController.text.isNotEmpty
// //                 ? 'No matching bills found'
// //                 : 'No bills found',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.grey.shade700,
// //             ),
// //           ),
// //           if (_searchController.text.isNotEmpty) ...[
// //             const SizedBox(height: 6),
// //             Text(
// //               'Search uses exact matches only.',
// //               style: TextStyle(color: Colors.grey.shade500),
// //             ),
// //           ],
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FA),
// //       appBar: AppBar(
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //         surfaceTintColor: Colors.white,
// //         title: const Text(
// //           'Bill Management',
// //           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
// //         ),
// //       ),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: FirebaseFirestore.instance
// //             .collection('bills')
// //             .orderBy('createdAt', descending: true)
// //             .snapshots(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }

// //           if (snapshot.hasError) {
// //             return Center(
// //               child: Padding(
// //                 padding: const EdgeInsets.all(20),
// //                 child: Text(
// //                   'Error loading bills:\n${snapshot.error}',
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             );
// //           }

// //           _allBills = snapshot.data?.docs ?? [];

// //           // Keep filtering synchronized with Firestore updates.
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             if (mounted) {
// //               _applyFilters();
// //             }
// //           });

// //           return LayoutBuilder(
// //             builder: (context, constraints) {
// //               final isMobile = constraints.maxWidth < 700;

// //               return SingleChildScrollView(
// //                 padding: EdgeInsets.all(isMobile ? 16 : 24),
// //                 child: Center(
// //                   child: ConstrainedBox(
// //                     constraints: const BoxConstraints(maxWidth: 1400),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           'Manage Bills',
// //                           style: TextStyle(
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),

// //                         const SizedBox(height: 6),

// //                         Text(
// //                           'Search and preview customer bills.',
// //                           style: TextStyle(color: Colors.grey.shade600),
// //                         ),

// //                         const SizedBox(height: 22),

// //                         _buildSearchAndFilter(),

// //                         const SizedBox(height: 20),

// //                         if (isMobile)
// //                           _buildMobileList()
// //                         else if (_filteredBills.isEmpty)
// //                           _buildEmptyState()
// //                         else
// //                           _buildDesktopTable(),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }



// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import 'bill_generate.dart';

// class BillManagement extends StatefulWidget {
//   const BillManagement({super.key});

//   @override
//   State<BillManagement> createState() => _BillManagementState();
// }

// class _BillManagementState extends State<BillManagement> {
//   final TextEditingController _searchController =
//       TextEditingController();

//   late final Stream<QuerySnapshot> _billsStream;

//   String _selectedFilter = 'All';

//   @override
//   void initState() {
//     super.initState();

//     // Create the Firestore stream ONLY ONCE.
//     _billsStream = FirebaseFirestore.instance
//         .collection('bills')
//         .orderBy('createdAt', descending: true)
//         .snapshots();

//     _searchController.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // FILTER
//   // ============================================================

//   List<QueryDocumentSnapshot> _filterBills(
//     List<QueryDocumentSnapshot> bills,
//   ) {
//     List<QueryDocumentSnapshot> results =
//         List<QueryDocumentSnapshot>.from(bills);

//     final search =
//         _searchController.text.trim().toLowerCase();

//     // ----------------------------------------------------------
//     // STATUS FILTER
//     // ----------------------------------------------------------

//     if (_selectedFilter != 'All') {
//       results = results.where((doc) {
//         final data =
//             doc.data() as Map<String, dynamic>;

//         final status =
//             (data['status'] ?? 'unpaid')
//                 .toString()
//                 .trim()
//                 .toLowerCase();

//         return status ==
//             _selectedFilter.toLowerCase();
//       }).toList();
//     }

//     // ----------------------------------------------------------
//     // EXACT SEARCH ONLY
//     // ----------------------------------------------------------

//     if (search.isNotEmpty) {
//       results = results.where((doc) {
//         final data =
//             doc.data() as Map<String, dynamic>;

//         final name =
//             (data['name'] ?? '')
//                 .toString()
//                 .trim()
//                 .toLowerCase();

//         final billNumber =
//             (data['billNumber'] ?? '')
//                 .toString()
//                 .trim()
//                 .toLowerCase();

//         final nic =
//             (data['nic'] ??
//                     data['cnic'] ??
//                     '')
//                 .toString()
//                 .trim()
//                 .toLowerCase();

//         // EXACT MATCH.
//         //
//         // "ah" will NOT find "Ahmed".
//         // "abdullah" will only find "abdullah".
//         //
//         // Amount is deliberately NOT included.
//         return name == search ||
//             billNumber == search ||
//             nic == search;
//       }).toList();
//     }

//     return results;
//   }

//   // ============================================================
//   // FILTER BUTTON
//   // ============================================================

//   void _changeFilter(String filter) {
//     if (_selectedFilter == filter) {
//       return;
//     }

//     setState(() {
//       _selectedFilter = filter;
//     });
//   }

//   // ============================================================
//   // STATUS
//   // ============================================================

//   String _getStatus(
//     Map<String, dynamic> data,
//   ) {
//     final status =
//         (data['status'] ?? 'unpaid')
//             .toString()
//             .trim()
//             .toLowerCase();

//     if (status == 'paid') {
//       return 'Paid';
//     }

//     if (status == 'partial') {
//       return 'Partial';
//     }

//     return 'Unpaid';
//   }

//   Color _statusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//         return Colors.green;

//       case 'partial':
//         return Colors.orange;

//       case 'unpaid':
//         return Colors.red;

//       default:
//         return Colors.grey;
//     }
//   }

//   // ============================================================
//   // FORMAT AMOUNT
//   // ============================================================

//   String _formatAmount(dynamic amount) {
//     if (amount == null) {
//       return 'Rs. 0';
//     }

//     if (amount is num) {
//       return 'Rs. ${amount.toStringAsFixed(0)}';
//     }

//     final parsed =
//         double.tryParse(amount.toString());

//     if (parsed == null) {
//       return 'Rs. ${amount.toString()}';
//     }

//     return 'Rs. ${parsed.toStringAsFixed(0)}';
//   }

//   // ============================================================
//   // RENTED
//   // ============================================================

//   String _getRented(dynamic rented) {
//     if (rented == null) {
//       return '0';
//     }

//     if (rented is List) {
//       return rented.length.toString();
//     }

//     if (rented is num) {
//       return rented.toString();
//     }

//     return rented.toString();
//   }

//   // ============================================================
//   // OPEN BILL PREVIEW
//   // ============================================================

//   Future<void> _openBillPreview(
//     BuildContext context,
//     QueryDocumentSnapshot document,
//   ) async {
//     final data =
//         document.data() as Map<String, dynamic>;

//     final pdfData = data['pdfBytes'];

//     if (pdfData == null) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text('PDF for this bill was not found.'),
//         ),
//       );

//       return;
//     }

//     late Uint8List pdf;

//     // Firestore Blob
//     if (pdfData is Blob) {
//       pdf = pdfData.bytes;
//     } else {
//       // List<int>
//       pdf = Uint8List.fromList(
//         List<int>.from(pdfData),
//       );
//     }

//     final billNumber =
//         (data['billNumber'] ?? document.id)
//             .toString();

//     final customerName =
//         (data['name'] ?? 'Customer')
//             .toString();

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             BillPreviewScreen(
//           pdfBytes: pdf,
//           billId: billNumber,
//           customerName: customerName,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH + FILTER
//   // ============================================================

//   Widget _buildSearchAndFilter() {
//     return LayoutBuilder(
//       builder: (
//         context,
//         constraints,
//       ) {
//         final isSmall =
//             constraints.maxWidth < 650;

//         if (isSmall) {
//           return Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.stretch,
//             children: [
//               _buildSearchField(),

//               const SizedBox(
//                 height: 12,
//               ),

//               _buildFilterButton(),
//             ],
//           );
//         }

//         return Row(
//           children: [
//             Expanded(
//               child: _buildSearchField(),
//             ),

//             const SizedBox(
//               width: 12,
//             ),

//             _buildFilterButton(),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // SEARCH FIELD
//   // ============================================================

//   Widget _buildSearchField() {
//     return TextField(
//       controller: _searchController,

//       textInputAction:
//           TextInputAction.search,

//       decoration: InputDecoration(
//         hintText:
//             'Search name, bill number or CNIC',

//         prefixIcon:
//             const Icon(Icons.search),

//         suffixIcon:
//             _searchController.text.isNotEmpty
//                 ? IconButton(
//                     icon:
//                         const Icon(Icons.clear),
//                     onPressed: () {
//                       _searchController.clear();
//                     },
//                   )
//                 : null,

//         filled: true,

//         fillColor: Colors.white,

//         contentPadding:
//             const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 15,
//         ),

//         border: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide:
//               BorderSide.none,
//         ),

//         enabledBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color:
//                 Colors.grey.shade200,
//           ),
//         ),

//         focusedBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide:
//               const BorderSide(
//             color:
//                 Color(0xFF2563EB),
//             width: 1.5,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTON
//   // ============================================================

//   Widget _buildFilterButton() {
//     return PopupMenuButton<String>(
//       onSelected:
//           _changeFilter,

//       offset:
//           const Offset(0, 50),

//       shape:
//           RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(12),
//       ),

//       itemBuilder:
//           (context) {
//         return const [
//           PopupMenuItem(
//             value: 'All',
//             child: Text('All'),
//           ),

//           PopupMenuItem(
//             value: 'Paid',
//             child: Text('Paid'),
//           ),

//           PopupMenuItem(
//             value: 'Unpaid',
//             child: Text('Unpaid'),
//           ),

//           PopupMenuItem(
//             value: 'Partial',
//             child: Text('Partial'),
//           ),
//         ];
//       },

//       child: Container(
//         height: 52,

//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 18,
//         ),

//         decoration:
//             BoxDecoration(
//           color: Colors.white,

//           borderRadius:
//               BorderRadius.circular(12),

//           border: Border.all(
//             color:
//                 Colors.grey.shade200,
//           ),
//         ),

//         child: Row(
//           mainAxisSize:
//               MainAxisSize.min,

//           children: [
//             const Icon(
//               Icons.filter_list_rounded,
//               size: 21,
//             ),

//             const SizedBox(
//               width: 8,
//             ),

//             Text(
//               _selectedFilter,

//               style:
//                   const TextStyle(
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),

//             const SizedBox(
//               width: 5,
//             ),

//             const Icon(
//               Icons
//                   .keyboard_arrow_down_rounded,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DESKTOP TABLE
//   // ============================================================

//   Widget _buildDesktopTable(
//     List<QueryDocumentSnapshot> bills,
//   ) {
//     return Container(
//       width: double.infinity,

//       decoration:
//           BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color:
//               Colors.grey.shade200,
//         ),
//       ),

//       child: ClipRRect(
//         borderRadius:
//             BorderRadius.circular(16),

//         child:
//             SingleChildScrollView(
//           scrollDirection:
//               Axis.horizontal,

//           child: DataTable(
//             columnSpacing: 30,

//             headingRowHeight: 55,

//             dataRowMinHeight: 68,

//             dataRowMaxHeight: 76,

//             headingRowColor:
//                 WidgetStateProperty.all(
//               const Color(
//                 0xFFF8FAFC,
//               ),
//             ),

//             columns: const [
//               DataColumn(
//                 label: Text(
//                   'Name',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),

//               DataColumn(
//                 label: Text(
//                   'Contact',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),

//               DataColumn(
//                 label: Text(
//                   'Rented',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),

//               DataColumn(
//                 label: Text(
//                   'Status',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),

//               DataColumn(
//                 label: Text(
//                   'Total Bill',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),

//               DataColumn(
//                 label: Text(
//                   'Action',
//                   style: TextStyle(
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],

//             rows: bills.map(
//               (doc) {
//                 final data =
//                     doc.data()
//                         as Map<String,
//                             dynamic>;

//                 final name =
//                     (data['name'] ??
//                             'Unknown')
//                         .toString();

//                 final contact =
//                     (data['contact'] ??
//                             data['phone'] ??
//                             data['mobile'] ??
//                             '-')
//                         .toString();

//                 final rented =
//                     _getRented(
//                   data['rented'] ??
//                       data['rentedItems'],
//                 );

//                 final status =
//                     _getStatus(data);

//                 final total =
//                     data['totalBill'] ??
//                         data['totalAmount'] ??
//                         data['total'] ??
//                         0;

//                 return DataRow(
//                   cells: [
//                     DataCell(
//                       Text(
//                         name,
//                         style:
//                             const TextStyle(
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                     DataCell(
//                       Text(contact),
//                     ),

//                     DataCell(
//                       Text(rented),
//                     ),

//                     DataCell(
//                       _buildStatusBadge(
//                         status,
//                       ),
//                     ),

//                     DataCell(
//                       Text(
//                         _formatAmount(
//                           total,
//                         ),
//                         style:
//                             const TextStyle(
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                     DataCell(
//                       _buildPreviewButton(
//                         doc,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // MOBILE LIST
//   // ============================================================

//   Widget _buildMobileList(
//     List<QueryDocumentSnapshot> bills,
//   ) {
//     if (bills.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: bills.map(
//         (doc) {
//           final data =
//               doc.data()
//                   as Map<String,
//                       dynamic>;

//           final name =
//               (data['name'] ??
//                       'Unknown')
//                   .toString();

//           final contact =
//               (data['contact'] ??
//                       data['phone'] ??
//                       data['mobile'] ??
//                       '-')
//                   .toString();

//           final rented =
//               _getRented(
//             data['rented'] ??
//                 data['rentedItems'],
//           );

//           final status =
//               _getStatus(data);

//           final total =
//               data['totalBill'] ??
//                   data['totalAmount'] ??
//                   data['total'] ??
//                   0;

//           return Container(
//             width: double.infinity,

//             margin:
//                 const EdgeInsets.only(
//               bottom: 12,
//             ),

//             padding:
//                 const EdgeInsets.all(
//               16,
//             ),

//             decoration:
//                 BoxDecoration(
//               color: Colors.white,

//               borderRadius:
//                   BorderRadius.circular(
//                 14,
//               ),

//               border: Border.all(
//                 color:
//                     Colors.grey.shade200,
//               ),
//             ),

//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         name,
//                         style:
//                             const TextStyle(
//                           fontSize: 16,
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),

//                     _buildStatusBadge(
//                       status,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(
//                   height: 14,
//                 ),

//                 Row(
//                   children: [
//                     Expanded(
//                       child:
//                           _mobileInfo(
//                         'Contact',
//                         contact,
//                       ),
//                     ),

//                     Expanded(
//                       child:
//                           _mobileInfo(
//                         'Rented',
//                         rented,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(
//                   height: 12,
//                 ),

//                 Row(
//                   children: [
//                     Expanded(
//                       child:
//                           _mobileInfo(
//                         'Total Bill',
//                         _formatAmount(
//                           total,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(
//                       width: 10,
//                     ),

//                     Expanded(
//                       child:
//                           _buildPreviewButton(
//                         doc,
//                         fullWidth:
//                             true,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       ).toList(),
//     );
//   }

//   // ============================================================
//   // MOBILE INFO
//   // ============================================================

//   Widget _mobileInfo(
//     String title,
//     String value,
//   ) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,

//           style: TextStyle(
//             fontSize: 12,
//             color:
//                 Colors.grey.shade600,
//           ),
//         ),

//         const SizedBox(
//           height: 4,
//         ),

//         Text(
//           value,

//           overflow:
//               TextOverflow.ellipsis,

//           style:
//               const TextStyle(
//             fontWeight:
//                 FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // STATUS BADGE
//   // ============================================================

//   Widget _buildStatusBadge(
//     String status,
//   ) {
//     final color =
//         _statusColor(status);

//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 10,
//         vertical: 6,
//       ),

//       decoration:
//           BoxDecoration(
//         color:
//             color.withOpacity(0.10),

//         borderRadius:
//             BorderRadius.circular(20),
//       ),

//       child: Text(
//         status,

//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight:
//               FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PREVIEW BUTTON
//   // ============================================================

//   Widget _buildPreviewButton(
//     QueryDocumentSnapshot doc, {
//     bool fullWidth = false,
//   }) {
//     return SizedBox(
//       width:
//           fullWidth
//               ? double.infinity
//               : null,

//       height: 40,

//       child:
//           OutlinedButton.icon(
//         onPressed: () {
//           _openBillPreview(
//             context,
//             doc,
//           );
//         },

//         icon: const Icon(
//           Icons.visibility_outlined,
//           size: 18,
//         ),

//         label:
//             const Text(
//           'Preview Bill',
//         ),

//         style:
//             OutlinedButton.styleFrom(
//           foregroundColor:
//               const Color(
//             0xFF2563EB,
//           ),

//           side:
//               const BorderSide(
//             color:
//                 Color(0xFF2563EB),
//           ),

//           shape:
//               RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(
//               9,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     final hasSearch =
//         _searchController
//             .text
//             .trim()
//             .isNotEmpty;

//     return Container(
//       width: double.infinity,

//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 60,
//         horizontal: 20,
//       ),

//       decoration:
//           BoxDecoration(
//         color: Colors.white,

//         borderRadius:
//             BorderRadius.circular(16),

//         border: Border.all(
//           color:
//               Colors.grey.shade200,
//         ),
//       ),

//       child: Column(
//         children: [
//           Icon(
//             Icons
//                 .receipt_long_outlined,

//             size: 55,

//             color:
//                 Colors.grey.shade400,
//           ),

//           const SizedBox(
//             height: 14,
//           ),

//           Text(
//             hasSearch
//                 ? 'No matching bills found'
//                 : 'No bills found',

//             style: TextStyle(
//               fontSize: 16,

//               fontWeight:
//                   FontWeight.w600,

//               color:
//                   Colors.grey.shade700,
//             ),
//           ),

//           if (hasSearch) ...[
//             const SizedBox(
//               height: 6,
//             ),

//             Text(
//               'Search uses exact matches only.',

//               style: TextStyle(
//                 color:
//                     Colors.grey.shade500,
//               ),
//             ),
//           ],
//         ],
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
//         elevation: 0,

//         backgroundColor:
//             Colors.white,

//         surfaceTintColor:
//             Colors.white,

//         title: const Text(
//           'Bill Management',

//           style: TextStyle(
//             color:
//                 Colors.black87,

//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//       ),

//       body:
//           StreamBuilder<QuerySnapshot>(
//         // IMPORTANT:
//         // This is the SAME stream created
//         // once in initState().
//         stream: _billsStream,

//         builder:
//             (context, snapshot) {
//           if (snapshot
//                   .connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child:
//                   CircularProgressIndicator(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.all(
//                   20,
//                 ),

//                 child: Text(
//                   'Error loading bills:\n${snapshot.error}',

//                   textAlign:
//                       TextAlign.center,
//                 ),
//               ),
//             );
//           }

//           final bills =
//               snapshot.data?.docs ??
//                   <QueryDocumentSnapshot>[];

//           final filteredBills =
//               _filterBills(bills);

//           return LayoutBuilder(
//             builder:
//                 (
//               context,
//               constraints,
//             ) {
//               final isMobile =
//                   constraints.maxWidth <
//                       700;

//               return SingleChildScrollView(
//                 padding:
//                     EdgeInsets.all(
//                   isMobile
//                       ? 16
//                       : 24,
//                 ),

//                 child: Center(
//                   child:
//                       ConstrainedBox(
//                     constraints:
//                         const BoxConstraints(
//                       maxWidth: 1400,
//                     ),

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,

//                       children: [
//                         const Text(
//                           'Manage Bills',

//                           style:
//                               TextStyle(
//                             fontSize: 24,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 6,
//                         ),

//                         Text(
//                           'Search and preview customer bills.',

//                           style: TextStyle(
//                             color:
//                                 Colors.grey.shade600,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 22,
//                         ),

//                         _buildSearchAndFilter(),

//                         const SizedBox(
//                           height: 20,
//                         ),

//                         if (isMobile)
//                           _buildMobileList(
//                             filteredBills,
//                           )
//                         else if (filteredBills
//                             .isEmpty)
//                           _buildEmptyState()
//                         else
//                           _buildDesktopTable(
//                             filteredBills,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }


// // // ### The critical difference

// // The Firestore stream is now created **once**:


// // late final Stream<QuerySnapshot> _billsStream; 
// // and:


// // _billsStream = FirebaseFirestore.instance
// //     .collection('bills')
// //     .orderBy('createdAt', descending: true)
// //     .snapshots();


// // Then `build()` only uses:


// // stream: _billsStream,


// // There is **no `addPostFrameCallback`**, no `setState()` from inside the Firestore builder, and no `_allBills` mutation during `build()`.

// // Your search can still call `setState()` because that is an intentional UI update, but it no longer creates a new Firestore stream.

// // If this version **still blinks continuously while you aren't touching the search**, then the issue is likely outside this page — most likely the parent page/navigation widget is repeatedly rebuilding/remounting `BillManagement`, or another widget is pushing/replacing this page. In that case, send me the code where you open `BillManagement` from your drawer/menu, and I can trace that part.




// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillsManagementScreen extends StatefulWidget {
//   const BillsManagementScreen({super.key});

//   @override
//   State<BillsManagementScreen> createState() =>
//       _BillsManagementScreenState();
// }

// class _BillsManagementScreenState
//     extends State<BillsManagementScreen> {
//   final TextEditingController _searchController =
//       TextEditingController();

//   String _selectedFilter = 'All';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // PAYMENT STATUS
//   // READ ONLY ON THIS PAGE
//   // ============================================================

//   String _getPaymentStatus(Map<String, dynamic> bill) {
//     final savedStatus =
//         (bill['paymentStatus'] ?? '').toString().toLowerCase();

//     if (savedStatus == 'paid' ||
//         savedStatus == 'partial' ||
//         savedStatus == 'unpaid') {
//       return savedStatus;
//     }

//     final total = _toDouble(bill['totalAmount']);
//     final paid = _toDouble(bill['paidAmount']);

//     if (total <= 0 || paid >= total) {
//       return 'paid';
//     }

//     if (paid > 0) {
//       return 'partial';
//     }

//     return 'unpaid';
//   }

//   double _toDouble(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   String _money(dynamic value) {
//     return 'Rs. ${_toDouble(value).toStringAsFixed(0)}';
//   }

//   // ============================================================
//   // EXACT SEARCH
//   //
//   // ONLY:
//   // 1. Customer name
//   // 2. Bill number
//   // 3. CNIC
//   //
//   // Exact match only.
//   //
//   // "ah"      -> DOES NOT find "Ahmed"
//   // "ahmed"   -> finds "Ahmed"
//   // ============================================================

//   bool _matchesSearch(Map<String, dynamic> bill) {
//     final query =
//         _searchController.text.trim().toLowerCase();

//     if (query.isEmpty) {
//       return true;
//     }

//     final name =
//         (bill['customerName'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     final billNumber =
//         (bill['billNumber'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     final cnic =
//         (bill['cnic'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     return query == name ||
//         query == billNumber ||
//         query == cnic;
//   }

//   // ============================================================
//   // RENTED ITEMS
//   // ============================================================

//   String _getRentedItems(Map<String, dynamic> bill) {
//     final items = bill['items'];

//     if (items is! List || items.isEmpty) {
//       return 'No items';
//     }

//     final result = <String>[];

//     for (final item in items) {
//       if (item is Map) {
//         final name =
//             (item['name'] ?? 'Item').toString();

//         final quantity =
//             item['quantity'] ?? 0;

//         result.add('$name x$quantity');
//       }
//     }

//     return result.isEmpty
//         ? 'No items'
//         : result.join(', ');
//   }

//   // ============================================================
//   // STATUS COLOR
//   // ============================================================

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'paid':
//         return Colors.green;

//       case 'partial':
//         return Colors.orange;

//       default:
//         return Colors.red;
//     }
//   }

//   // ============================================================
//   // OPEN BILL PREVIEW
//   // ============================================================

//   Future<void> _openBillPreview(
//     Map<String, dynamic> bill,
//   ) async {
//     try {
//       final pdfBytes =
//           await _buildBillPdf(bill);

//       if (!mounted) return;

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BillPreviewScreen(
//             pdfBytes: pdfBytes,
//             billNumber:
//                 (bill['billNumber'] ?? 'Bill')
//                     .toString(),
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content:
//               Text('Could not create bill preview: $e'),
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // BUILD PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf(
//     Map<String, dynamic> bill,
//   ) async {
//     final pdf = pw.Document();

//     final status =
//         _getPaymentStatus(bill);

//     final billNumber =
//         (bill['billNumber'] ?? 'N/A').toString();

//     final customerName =
//         (bill['customerName'] ?? 'N/A').toString();

//     final contact =
//         (bill['contactNumber'] ?? 'N/A').toString();

//     final cnic =
//         (bill['cnic'] ?? 'N/A').toString();

//     final subtotal =
//         _toDouble(bill['subtotal']);

//     final discount =
//         _toDouble(bill['discount']);

//     final total =
//         _toDouble(bill['totalAmount']);

//     final paid =
//         _toDouble(bill['paidAmount']);

//     final remaining =
//         _toDouble(bill['remainingAmount']);

//     final items = <Map<String, dynamic>>[];

//     if (bill['items'] is List) {
//       for (final item in bill['items']) {
//         if (item is Map) {
//           items.add(
//             Map<String, dynamic>.from(item),
//           );
//         }
//       }
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin:
//             const pw.EdgeInsets.all(32),
//         build: (context) {
//           return [
//             pw.Container(
//               padding:
//                   const pw.EdgeInsets.all(18),
//               decoration:
//                   pw.BoxDecoration(
//                 border: pw.Border.all(
//                   color:
//                       PdfColors.blueGrey700,
//                   width: 1.2,
//                 ),
//                 borderRadius:
//                     pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment:
//                     pw.CrossAxisAlignment.start,
//                 children: [
//                   // HEADER
//                   pw.Row(
//                     mainAxisAlignment:
//                         pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         'RENTAL BILL',
//                         style: pw.TextStyle(
//                           fontSize: 24,
//                           fontWeight:
//                               pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Container(
//                         padding:
//                             const pw.EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 7,
//                         ),
//                         decoration:
//                             pw.BoxDecoration(
//                           color:
//                               _pdfStatusColor(
//                             status,
//                           ),
//                           borderRadius:
//                               pw.BorderRadius.circular(
//                             5,
//                           ),
//                         ),
//                         child: pw.Text(
//                           status.toUpperCase(),
//                           style: pw.TextStyle(
//                             color:
//                                 PdfColors.white,
//                             fontWeight:
//                                 pw.FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 15),

//                   pw.Divider(),

//                   // BILL INFO
//                   _pdfInfoRow(
//                     'Bill Number',
//                     billNumber,
//                   ),

//                   _pdfInfoRow(
//                     'Generated Date',
//                     _formatDate(
//                       bill['createdAt'],
//                     ),
//                   ),

//                   pw.SizedBox(height: 10),

//                   // CUSTOMER
//                   pw.Text(
//                     'CUSTOMER DETAILS',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 7),

//                   _pdfInfoRow(
//                     'Name',
//                     customerName,
//                   ),

//                   _pdfInfoRow(
//                     'Contact',
//                     contact,
//                   ),

//                   _pdfInfoRow(
//                     'CNIC',
//                     cnic,
//                   ),

//                   pw.SizedBox(height: 10),

//                   // RENTAL PERIOD
//                   pw.Text(
//                     'RENTAL PERIOD',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 7),

//                   _pdfInfoRow(
//                     'From',
//                     _formatDate(
//                       bill['dateFrom'],
//                     ),
//                   ),

//                   _pdfInfoRow(
//                     'Till',
//                     _formatDate(
//                       bill['dateTill'],
//                     ),
//                   ),

//                   pw.SizedBox(height: 16),

//                   // ITEMS
//                   pw.Text(
//                     'RENTED ITEMS',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 8),

//                   pw.Table(
//                     border:
//                         pw.TableBorder.all(
//                       color:
//                           PdfColors.grey400,
//                     ),
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(
//                         3,
//                       ),
//                       1: const pw.FlexColumnWidth(
//                         1,
//                       ),
//                       2: const pw.FlexColumnWidth(
//                         1.5,
//                       ),
//                       3: const pw.FlexColumnWidth(
//                         1.7,
//                       ),
//                     },
//                     children: [
//                       pw.TableRow(
//                         decoration:
//                             const pw.BoxDecoration(
//                           color:
//                               PdfColors.grey200,
//                         ),
//                         children: [
//                           _pdfTableCell(
//                             'Item',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Qty',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Rate',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Amount',
//                             bold: true,
//                           ),
//                         ],
//                       ),

//                       ...items.map(
//                         (item) {
//                           final quantity =
//                               _toDouble(
//                             item['quantity'],
//                           );

//                           final rate =
//                               _toDouble(
//                             item['rentPrice'] ??
//                                 item['price'],
//                           );

//                           final amount =
//                               _toDouble(
//                             item['total'] ??
//                                 item['amount'],
//                           );

//                           return pw.TableRow(
//                             children: [
//                               _pdfTableCell(
//                                 (item['name'] ??
//                                         'Item')
//                                     .toString(),
//                               ),
//                               _pdfTableCell(
//                                 quantity
//                                     .toStringAsFixed(
//                                   0,
//                                 ),
//                               ),
//                               _pdfTableCell(
//                                 'Rs. ${rate.toStringAsFixed(0)}',
//                               ),
//                               _pdfTableCell(
//                                 'Rs. ${amount.toStringAsFixed(0)}',
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 18),

//                   // TOTALS
//                   pw.Align(
//                     alignment:
//                         pw.Alignment.centerRight,
//                     child: pw.SizedBox(
//                       width: 250,
//                       child: pw.Column(
//                         children: [
//                           _pdfAmountRow(
//                             'Actual Amount',
//                             subtotal,
//                           ),
//                           _pdfAmountRow(
//                             'Discount',
//                             discount,
//                           ),
//                           pw.Divider(),
//                           _pdfAmountRow(
//                             'Total Amount',
//                             total,
//                             bold: true,
//                           ),
//                           _pdfAmountRow(
//                             'Paid',
//                             paid,
//                           ),
//                           _pdfAmountRow(
//                             'Remaining',
//                             remaining,
//                             bold: true,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   pw.SizedBox(height: 18),

//                   pw.Divider(),

//                   pw.SizedBox(height: 8),

//                   if (status == 'paid')
//                     pw.Center(
//                       child: pw.Container(
//                         padding:
//                             const pw.EdgeInsets.symmetric(
//                           horizontal: 25,
//                           vertical: 10,
//                         ),
//                         decoration:
//                             pw.BoxDecoration(
//                           border: pw.Border.all(
//                             color:
//                                 PdfColors.green,
//                             width: 3,
//                           ),
//                         ),
//                         child: pw.Text(
//                           'PAID',
//                           style: pw.TextStyle(
//                             color:
//                                 PdfColors.green,
//                             fontSize: 24,
//                             fontWeight:
//                                 pw.FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   else
//                     pw.Text(
//                       status == 'partial'
//                           ? 'Payment Note: Remaining balance of Rs. ${remaining.toStringAsFixed(0)} is due on or before the return date.'
//                           : 'Payment Note: Bill payment is due on or before the return date.',
//                       style:
//                           const pw.TextStyle(
//                         fontSize: 10,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   pw.Widget _pdfInfoRow(
//     String label,
//     String value,
//   ) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.only(
//         bottom: 4,
//       ),
//       child: pw.Row(
//         children: [
//           pw.SizedBox(
//             width: 105,
//             child: pw.Text(
//               label,
//               style: pw.TextStyle(
//                 fontWeight:
//                     pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _pdfTableCell(
//     String text, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.all(7),
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

//   pw.Widget _pdfAmountRow(
//     String label,
//     double value, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.symmetric(
//         vertical: 3,
//       ),
//       child: pw.Row(
//         mainAxisAlignment:
//             pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               fontWeight: bold
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//             ),
//           ),
//           pw.Text(
//             'Rs. ${value.toStringAsFixed(0)}',
//             style: pw.TextStyle(
//               fontWeight: bold
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PdfColor _pdfStatusColor(
//     String status,
//   ) {
//     switch (status) {
//       case 'paid':
//         return PdfColors.green;

//       case 'partial':
//         return PdfColors.orange;

//       default:
//         return PdfColors.red;
//     }
//   }

//   String _formatDate(dynamic value) {
//     DateTime? date;

//     if (value is Timestamp) {
//       date = value.toDate();
//     } else if (value is DateTime) {
//       date = value;
//     } else if (value is String) {
//       date = DateTime.tryParse(value);
//     }

//     if (date == null) {
//       return 'N/A';
//     }

//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   // ============================================================
//   // MAIN UI
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF5F7FB),

//       appBar: AppBar(
//         title: const Text(
//           'Bill Management',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),

//       drawer: AdminDrawer(selectedIndex: 4),

//       body: StreamBuilder<
//           QuerySnapshot<
//               Map<String, dynamic>>>(
//         stream: FirebaseFirestore
//             .instance
//             .collection('bills')
//             .orderBy(
//               'createdAt',
//               descending: true,
//             )
//             .snapshots(),

//         builder:
//             (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.all(
//                   20,
//                 ),
//                 child: Text(
//                   'Unable to load bills.\n\n'
//                   '${snapshot.error}',
//                   textAlign:
//                       TextAlign.center,
//                 ),
//               ),
//             );
//           }

//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child:
//                   CircularProgressIndicator(),
//             );
//           }

//           final documents =
//               snapshot.data?.docs ?? [];

//           final filteredBills =
//               documents.where((doc) {
//             final bill =
//                 doc.data();

//             final status =
//                 _getPaymentStatus(
//               bill,
//             );

//             final filterMatches =
//                 _selectedFilter ==
//                         'All' ||
//                     status ==
//                         _selectedFilter
//                             .toLowerCase();

//             return filterMatches &&
//                 _matchesSearch(
//                   bill,
//                 );
//           }).toList();

//           return LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               final isDesktop =
//                   constraints.maxWidth >=
//                       850;

//               return Column(
//                 children: [
//                   _buildSummary(
//                     documents,
//                     isDesktop,
//                   ),

//                   // SEARCH BAR
//                   Padding(
//                     padding:
//                         EdgeInsets.fromLTRB(
//                       isDesktop ? 28 : 14,
//                       5,
//                       isDesktop ? 28 : 14,
//                       9,
//                     ),
//                     child: TextField(
//                       controller:
//                           _searchController,
//                       onChanged: (_) {
//                         setState(() {});
//                       },
//                       decoration:
//                           InputDecoration(
//                         hintText:
//                             'Search exact name, bill number or CNIC',
//                         prefixIcon:
//                             const Icon(
//                           Icons.search_rounded,
//                         ),
//                         suffixIcon:
//                             _searchController
//                                     .text
//                                     .isEmpty
//                                 ? null
//                                 : IconButton(
//                                     icon:
//                                         const Icon(
//                                       Icons
//                                           .clear_rounded,
//                                     ),
//                                     onPressed:
//                                         () {
//                                       _searchController
//                                           .clear();
//                                       setState(
//                                         () {},
//                                       );
//                                     },
//                                   ),
//                         filled: true,
//                         fillColor:
//                             Colors.white,
//                         border:
//                             OutlineInputBorder(
//                           borderRadius:
//                               BorderRadius
//                                   .circular(
//                             12,
//                           ),
//                           borderSide:
//                               BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // FILTER
//                   Padding(
//                     padding:
//                         EdgeInsets.fromLTRB(
//                       isDesktop ? 28 : 14,
//                       0,
//                       isDesktop ? 28 : 14,
//                       10,
//                     ),
//                     child: Align(
//                       alignment:
//                           Alignment.centerLeft,
//                       child:
//                           PopupMenuButton<
//                               String>(
//                         onSelected:
//                             (value) {
//                           setState(() {
//                             _selectedFilter =
//                                 value;
//                           });
//                         },
//                         itemBuilder:
//                             (_) => const [
//                           PopupMenuItem(
//                             value: 'All',
//                             child:
//                                 Text('All'),
//                           ),
//                           PopupMenuItem(
//                             value: 'Paid',
//                             child:
//                                 Text('Paid'),
//                           ),
//                           PopupMenuItem(
//                             value: 'Unpaid',
//                             child:
//                                 Text('Unpaid'),
//                           ),
//                           PopupMenuItem(
//                             value: 'Partial',
//                             child:
//                                 Text('Partial'),
//                           ),
//                         ],
//                         child: Container(
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 14,
//                             vertical: 10,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color:
//                                 Colors.white,
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               10,
//                             ),
//                             border:
//                                 Border.all(
//                               color: Colors
//                                   .grey
//                                   .shade300,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize:
//                                 MainAxisSize
//                                     .min,
//                             children: [
//                               const Icon(
//                                 Icons
//                                     .filter_list_rounded,
//                                 size: 19,
//                               ),
//                               const SizedBox(
//                                 width: 7,
//                               ),
//                               Text(
//                                 'Filter: $_selectedFilter',
//                               ),
//                               const Icon(
//                                 Icons
//                                     .keyboard_arrow_down_rounded,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // BILL LIST
//                   Expanded(
//                     child: filteredBills
//                             .isEmpty
//                         ? _emptyState()
//                         : ListView
//                             .builder(
//                             padding:
//                                 EdgeInsets
//                                     .fromLTRB(
//                               isDesktop
//                                   ? 28
//                                   : 14,
//                               0,
//                               isDesktop
//                                   ? 28
//                                   : 14,
//                               25,
//                             ),
//                             itemCount:
//                                 filteredBills
//                                     .length,
//                             itemBuilder:
//                                 (context,
//                                     index) {
//                               return _buildBillCard(
//                                 filteredBills[
//                                         index]
//                                     .data(),
//                                 isDesktop,
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // SUMMARY
//   // ============================================================

//   Widget _buildSummary(
//     List<QueryDocumentSnapshot<
//             Map<String, dynamic>>>
//         documents,
//     bool isDesktop,
//   ) {
//     final all =
//         documents.length;

//     final paid = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'paid',
//         )
//         .length;

//     final unpaid = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'unpaid',
//         )
//         .length;

//     final partial = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'partial',
//         )
//         .length;

//     final cards = [
//       _summaryCard(
//         'All Bills',
//         all,
//         Icons.receipt_long_rounded,
//       ),
//       _summaryCard(
//         'Paid',
//         paid,
//         Icons.check_circle_rounded,
//       ),
//       _summaryCard(
//         'Unpaid',
//         unpaid,
//         Icons.pending_actions_rounded,
//       ),
//       _summaryCard(
//         'Partial',
//         partial,
//         Icons.timelapse_rounded,
//       ),
//     ];

//     if (!isDesktop) {
//       return SizedBox(
//         height: 100,
//         child: ListView.separated(
//           scrollDirection:
//               Axis.horizontal,
//           padding:
//               const EdgeInsets.fromLTRB(
//             14,
//             14,
//             14,
//             7,
//           ),
//           itemCount:
//               cards.length,
//           separatorBuilder:
//               (_, __) =>
//                   const SizedBox(
//             width: 10,
//           ),
//           itemBuilder:
//               (_, index) {
//             return SizedBox(
//               width: 145,
//               child: cards[index],
//             );
//           },
//         ),
//       );
//     }

//     return Padding(
//       padding:
//           const EdgeInsets.fromLTRB(
//         28,
//         20,
//         28,
//         12,
//       ),
//       child: Row(
//         children: [
//           for (int i = 0;
//               i < cards.length;
//               i++) ...[
//             Expanded(
//               child: cards[i],
//             ),
//             if (i <
//                 cards.length - 1)
//               const SizedBox(
//                 width: 12,
//               ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _summaryCard(
//     String title,
//     int value,
//     IconData icon,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.all(
//         14,
//       ),
//       decoration:
//           BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(
//           14,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black
//                 .withOpacity(.04),
//             blurRadius: 10,
//             offset:
//                 const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 23,
//           ),
//           const SizedBox(
//             width: 10,
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment
//                       .start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow:
//                       TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: Colors
//                         .grey
//                         .shade600,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 3,
//                 ),
//                 Text(
//                   '$value',
//                   style:
//                       const TextStyle(
//                     fontSize: 20,
//                     fontWeight:
//                         FontWeight.bold,
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
//   // BILL CARD
//   // ============================================================

//   Widget _buildBillCard(
//     Map<String, dynamic> bill,
//     bool isDesktop,
//   ) {
//     final status =
//         _getPaymentStatus(bill);

//     final statusColor =
//         _statusColor(status);

//     final name =
//         (bill['customerName'] ??
//                 'Unknown Customer')
//             .toString();

//     final contact =
//         (bill['contactNumber'] ??
//                 'N/A')
//             .toString();

//     final rented =
//         _getRentedItems(bill);

//     final total =
//         _money(
//       bill['totalAmount'],
//     );

//     return Container(
//       margin:
//           const EdgeInsets.only(
//         bottom: 10,
//       ),
//       padding:
//           EdgeInsets.all(
//         isDesktop ? 17 : 14,
//       ),
//       decoration:
//           BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(
//           14,
//         ),
//         border: Border.all(
//           color:
//               Colors.grey.shade200,
//         ),
//       ),

//       child: isDesktop
//           ? Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child:
//                       _desktopField(
//                     'Name',
//                     name,
//                   ),
//                 ),

//                 Expanded(
//                   flex: 2,
//                   child:
//                       _desktopField(
//                     'Contact',
//                     contact,
//                   ),
//                 ),

//                 Expanded(
//                   flex: 3,
//                   child:
//                       _desktopField(
//                     'Rented',
//                     rented,
//                     maxLines: 2,
//                   ),
//                 ),

//                 SizedBox(
//                   width: 105,
//                   child:
//                       _statusChip(
//                     status,
//                     statusColor,
//                   ),
//                 ),

//                 SizedBox(
//                   width: 125,
//                   child:
//                       _desktopField(
//                     'Total Bill',
//                     total,
//                     bold: true,
//                   ),
//                 ),

//                 const SizedBox(
//                   width: 8,
//                 ),

//                 ElevatedButton.icon(
//                   onPressed: () =>
//                       _openBillPreview(
//                     bill,
//                   ),
//                   icon: const Icon(
//                     Icons
//                         .visibility_rounded,
//                     size: 18,
//                   ),
//                   label:
//                       const Text(
//                     'Preview Bill',
//                   ),
//                 ),
//               ],
//             )

//           : Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment
//                       .start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         name,
//                         style:
//                             const TextStyle(
//                           fontSize: 16,
//                           fontWeight:
//                               FontWeight
//                                   .bold,
//                         ),
//                       ),
//                     ),
//                     _statusChip(
//                       status,
//                       statusColor,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(
//                   height: 10,
//                 ),

//                 _mobileField(
//                   'Contact',
//                   contact,
//                 ),

//                 _mobileField(
//                   'Rented',
//                   rented,
//                 ),

//                 _mobileField(
//                   'Total Bill',
//                   total,
//                   bold: true,
//                 ),

//                 const SizedBox(
//                   height: 8,
//                 ),

//                 SizedBox(
//                   width:
//                       double.infinity,
//                   child:
//                       ElevatedButton
//                           .icon(
//                     onPressed: () =>
//                         _openBillPreview(
//                       bill,
//                     ),
//                     icon:
//                         const Icon(
//                       Icons
//                           .visibility_rounded,
//                       size: 18,
//                     ),
//                     label:
//                         const Text(
//                       'Preview Bill',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _desktopField(
//     String label,
//     String value, {
//     int maxLines = 1,
//     bool bold = false,
//   }) {
//     return Padding(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 8,
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color:
//                   Colors.grey.shade600,
//               fontSize: 11,
//             ),
//           ),
//           const SizedBox(
//             height: 4,
//           ),
//           Text(
//             value,
//             maxLines: maxLines,
//             overflow:
//                 TextOverflow.ellipsis,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: bold
//                   ? FontWeight.bold
//                   : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _mobileField(
//     String label,
//     String value, {
//     bool bold = false,
//   }) {
//     return Padding(
//       padding:
//           const EdgeInsets.only(
//         bottom: 7,
//       ),
//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color:
//                     Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: bold
//                     ? FontWeight.bold
//                     : FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statusChip(
//     String status,
//     Color color,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration:
//           BoxDecoration(
//         color:
//             color.withOpacity(.10),
//         borderRadius:
//             BorderRadius.circular(
//           20,
//         ),
//       ),
//       child: Text(
//         status.toUpperCase(),
//         textAlign:
//             TextAlign.center,
//         style: TextStyle(
//           color: color,
//           fontSize: 10,
//           fontWeight:
//               FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _emptyState() {
//     final searching =
//         _searchController.text
//             .trim()
//             .isNotEmpty;

//     return Center(
//       child: Padding(
//         padding:
//             const EdgeInsets.all(
//           30,
//         ),
//         child: Column(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons
//                   .receipt_long_outlined,
//               size: 55,
//               color:
//                   Colors.grey.shade400,
//             ),
//             const SizedBox(
//               height: 12,
//             ),
//             Text(
//               searching
//                   ? 'No exact match found'
//                   : 'No bills found',
//               style:
//                   const TextStyle(
//                 fontSize: 17,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Text(
//               searching
//                   ? 'Enter the complete customer name, bill number or CNIC.'
//                   : 'There are no bills in this category.',
//               textAlign:
//                   TextAlign.center,
//               style: TextStyle(
//                 color:
//                     Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // BILL PREVIEW
// //
// // Download + Print buttons are available here.
// // ============================================================

// class BillPreviewScreen
//     extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billNumber;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billNumber,
//   });

//   Future<void> _download() async {
//     await Printing.sharePdf(
//       bytes: pdfBytes,
//       filename: '$billNumber.pdf',
//     );
//   }

//   Future<void> _print() async {
//     await Printing.layoutPdf(
//       onLayout: (_) async => pdfBytes,
//     );
//   }

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Bill Preview - $billNumber',
//         ),
//         actions: [
//           IconButton(
//             tooltip:
//                 'Download / Save',
//             onPressed: _download,
//             icon: const Icon(
//               Icons
//                   .download_rounded,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Print',
//             onPressed: _print,
//             icon: const Icon(
//               Icons.print_rounded,
//             ),
//           ),
//         ],
//       ),

//       body: PdfPreview(
//         build: (_) async =>
//             pdfBytes,

//         allowPrinting: true,
//         allowSharing: true,

//         canChangePageFormat:
//             false,

//         canChangeOrientation:
//             false,

//         pdfFileName:
//             '$billNumber.pdf',
//       ),
//     );
//   }
// }





// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// class BillsManagementScreen extends StatefulWidget {
//   const BillsManagementScreen({super.key});

//   @override
//   State<BillsManagementScreen> createState() =>
//       _BillsManagementScreenState();
// }

// class _BillsManagementScreenState
//     extends State<BillsManagementScreen> {
//   // ============================================================
//   // THEME
//   // ============================================================

//   static const Color background = Color(0xFFF7F2EA);
//   static const Color surface = Color(0xFFFFFCF8);
//   static const Color bronze = Color(0xFF9A6A3A);
//   static const Color bronzeDark = Color(0xFF704823);
//   static const Color bronzeLight = Color(0xFFE9D6BC);
//   static const Color darkBrown = Color(0xFF2C2119);
//   static const Color mediumBrown = Color(0xFF59483A);
//   static const Color mutedText = Color(0xFF8A7B6E);
//   static const Color border = Color(0xFFE6D9CB);

//   final TextEditingController _searchController =
//       TextEditingController();

//   String _selectedFilter = 'All';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // PAYMENT STATUS
//   // ============================================================

//   String _getPaymentStatus(Map<String, dynamic> bill) {
//     final savedStatus =
//         (bill['paymentStatus'] ?? '').toString().toLowerCase();

//     if (savedStatus == 'paid' ||
//         savedStatus == 'partial' ||
//         savedStatus == 'unpaid') {
//       return savedStatus;
//     }

//     final total = _toDouble(bill['totalAmount']);
//     final paid = _toDouble(bill['paidAmount']);

//     if (total <= 0 || paid >= total) {
//       return 'paid';
//     }

//     if (paid > 0) {
//       return 'partial';
//     }

//     return 'unpaid';
//   }

//   double _toDouble(dynamic value) {
//     if (value is num) {
//       return value.toDouble();
//     }

//     return double.tryParse(
//           value?.toString() ?? '',
//         ) ??
//         0;
//   }

//   String _money(dynamic value) {
//     return 'Rs. ${_toDouble(value).toStringAsFixed(0)}';
//   }

//   // ============================================================
//   // EXACT SEARCH
//   // ============================================================

//   bool _matchesSearch(Map<String, dynamic> bill) {
//     final query =
//         _searchController.text.trim().toLowerCase();

//     if (query.isEmpty) {
//       return true;
//     }

//     final name =
//         (bill['customerName'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     final billNumber =
//         (bill['billNumber'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     final cnic =
//         (bill['cnic'] ?? '')
//             .toString()
//             .trim()
//             .toLowerCase();

//     return query == name ||
//         query == billNumber ||
//         query == cnic;
//   }

//   // ============================================================
//   // RENTED ITEMS
//   // ============================================================

//   String _getRentedItems(Map<String, dynamic> bill) {
//     final items = bill['items'];

//     if (items is! List || items.isEmpty) {
//       return 'No items';
//     }

//     final result = <String>[];

//     for (final item in items) {
//       if (item is Map) {
//         final name =
//             (item['name'] ?? 'Item').toString();

//         final quantity =
//             item['quantity'] ?? 0;

//         result.add('$name x$quantity');
//       }
//     }

//     return result.isEmpty
//         ? 'No items'
//         : result.join(', ');
//   }

//   // ============================================================
//   // STATUS COLOR
//   // ============================================================

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'paid':
//         return const Color(0xFF3F7D52);

//       case 'partial':
//         return const Color(0xFFB7791F);

//       default:
//         return const Color(0xFFB64A4A);
//     }
//   }

//   Color _statusBackground(String status) {
//     switch (status) {
//       case 'paid':
//         return const Color(0xFFE5F2E8);

//       case 'partial':
//         return const Color(0xFFFFF0D5);

//       default:
//         return const Color(0xFFFBE6E6);
//     }
//   }

//   IconData _statusIcon(String status) {
//     switch (status) {
//       case 'paid':
//         return Icons.check_circle_rounded;

//       case 'partial':
//         return Icons.timelapse_rounded;

//       default:
//         return Icons.pending_actions_rounded;
//     }
//   }

//   // ============================================================
//   // OPEN BILL PREVIEW
//   // ============================================================

//   Future<void> _openBillPreview(
//     Map<String, dynamic> bill,
//   ) async {
//     try {
//       final pdfBytes =
//           await _buildBillPdf(bill);

//       if (!mounted) return;

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BillPreviewScreen(
//             pdfBytes: pdfBytes,
//             billNumber:
//                 (bill['billNumber'] ?? 'Bill')
//                     .toString(),
//           ),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: const Color(0xFFB64A4A),
//           behavior: SnackBarBehavior.floating,
//           content: Text(
//             'Could not create bill preview: $e',
//           ),
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // BUILD PDF
//   // ============================================================

//   Future<Uint8List> _buildBillPdf(
//     Map<String, dynamic> bill,
//   ) async {
//     final pdf = pw.Document();

//     final status =
//         _getPaymentStatus(bill);

//     final billNumber =
//         (bill['billNumber'] ?? 'N/A').toString();

//     final customerName =
//         (bill['customerName'] ?? 'N/A').toString();

//     final contact =
//         (bill['contactNumber'] ?? 'N/A').toString();

//     final cnic =
//         (bill['cnic'] ?? 'N/A').toString();

//     final subtotal =
//         _toDouble(bill['subtotal']);

//     final discount =
//         _toDouble(bill['discount']);

//     final total =
//         _toDouble(bill['totalAmount']);

//     final paid =
//         _toDouble(bill['paidAmount']);

//     final remaining =
//         _toDouble(bill['remainingAmount']);

//     final items = <Map<String, dynamic>>[];

//     if (bill['items'] is List) {
//       for (final item in bill['items']) {
//         if (item is Map) {
//           items.add(
//             Map<String, dynamic>.from(item),
//           );
//         }
//       }
//     }

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin:
//             const pw.EdgeInsets.all(32),
//         build: (context) {
//           return [
//             pw.Container(
//               padding:
//                   const pw.EdgeInsets.all(18),
//               decoration:
//                   pw.BoxDecoration(
//                 border: pw.Border.all(
//                   color:
//                       PdfColors.blueGrey700,
//                   width: 1.2,
//                 ),
//                 borderRadius:
//                     pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment:
//                     pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Row(
//                     mainAxisAlignment:
//                         pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text(
//                         'RENTAL BILL',
//                         style: pw.TextStyle(
//                           fontSize: 24,
//                           fontWeight:
//                               pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.Container(
//                         padding:
//                             const pw.EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 7,
//                         ),
//                         decoration:
//                             pw.BoxDecoration(
//                           color:
//                               _pdfStatusColor(
//                             status,
//                           ),
//                           borderRadius:
//                               pw.BorderRadius.circular(
//                             5,
//                           ),
//                         ),
//                         child: pw.Text(
//                           status.toUpperCase(),
//                           style: pw.TextStyle(
//                             color:
//                                 PdfColors.white,
//                             fontWeight:
//                                 pw.FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 15),

//                   pw.Divider(),

//                   _pdfInfoRow(
//                     'Bill Number',
//                     billNumber,
//                   ),

//                   _pdfInfoRow(
//                     'Generated Date',
//                     _formatDate(
//                       bill['createdAt'],
//                     ),
//                   ),

//                   pw.SizedBox(height: 10),

//                   pw.Text(
//                     'CUSTOMER DETAILS',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 7),

//                   _pdfInfoRow(
//                     'Name',
//                     customerName,
//                   ),

//                   _pdfInfoRow(
//                     'Contact',
//                     contact,
//                   ),

//                   _pdfInfoRow(
//                     'CNIC',
//                     cnic,
//                   ),

//                   pw.SizedBox(height: 10),

//                   pw.Text(
//                     'RENTAL PERIOD',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 7),

//                   _pdfInfoRow(
//                     'From',
//                     _formatDate(
//                       bill['dateFrom'],
//                     ),
//                   ),

//                   _pdfInfoRow(
//                     'Till',
//                     _formatDate(
//                       bill['dateTill'],
//                     ),
//                   ),

//                   pw.SizedBox(height: 16),

//                   pw.Text(
//                     'RENTED ITEMS',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           pw.FontWeight.bold,
//                     ),
//                   ),

//                   pw.SizedBox(height: 8),

//                   pw.Table(
//                     border:
//                         pw.TableBorder.all(
//                       color:
//                           PdfColors.grey400,
//                     ),
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(
//                         3,
//                       ),
//                       1: const pw.FlexColumnWidth(
//                         1,
//                       ),
//                       2: const pw.FlexColumnWidth(
//                         1.5,
//                       ),
//                       3: const pw.FlexColumnWidth(
//                         1.7,
//                       ),
//                     },
//                     children: [
//                       pw.TableRow(
//                         decoration:
//                             const pw.BoxDecoration(
//                           color:
//                               PdfColors.grey200,
//                         ),
//                         children: [
//                           _pdfTableCell(
//                             'Item',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Qty',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Rate',
//                             bold: true,
//                           ),
//                           _pdfTableCell(
//                             'Amount',
//                             bold: true,
//                           ),
//                         ],
//                       ),
//                       ...items.map(
//                         (item) {
//                           final quantity =
//                               _toDouble(
//                             item['quantity'],
//                           );

//                           final rate =
//                               _toDouble(
//                             item['rentPrice'] ??
//                                 item['price'],
//                           );

//                           final amount =
//                               _toDouble(
//                             item['total'] ??
//                                 item['amount'],
//                           );

//                           return pw.TableRow(
//                             children: [
//                               _pdfTableCell(
//                                 (item['name'] ??
//                                         'Item')
//                                     .toString(),
//                               ),
//                               _pdfTableCell(
//                                 quantity
//                                     .toStringAsFixed(
//                                   0,
//                                 ),
//                               ),
//                               _pdfTableCell(
//                                 'Rs. ${rate.toStringAsFixed(0)}',
//                               ),
//                               _pdfTableCell(
//                                 'Rs. ${amount.toStringAsFixed(0)}',
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),

//                   pw.SizedBox(height: 18),

//                   pw.Align(
//                     alignment:
//                         pw.Alignment.centerRight,
//                     child: pw.SizedBox(
//                       width: 250,
//                       child: pw.Column(
//                         children: [
//                           _pdfAmountRow(
//                             'Actual Amount',
//                             subtotal,
//                           ),
//                           _pdfAmountRow(
//                             'Discount',
//                             discount,
//                           ),
//                           pw.Divider(),
//                           _pdfAmountRow(
//                             'Total Amount',
//                             total,
//                             bold: true,
//                           ),
//                           _pdfAmountRow(
//                             'Paid',
//                             paid,
//                           ),
//                           _pdfAmountRow(
//                             'Remaining',
//                             remaining,
//                             bold: true,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   pw.SizedBox(height: 18),

//                   pw.Divider(),

//                   pw.SizedBox(height: 8),

//                   if (status == 'paid')
//                     pw.Center(
//                       child: pw.Container(
//                         padding:
//                             const pw.EdgeInsets.symmetric(
//                           horizontal: 25,
//                           vertical: 10,
//                         ),
//                         decoration:
//                             pw.BoxDecoration(
//                           border: pw.Border.all(
//                             color:
//                                 PdfColors.green,
//                             width: 3,
//                           ),
//                         ),
//                         child: pw.Text(
//                           'PAID',
//                           style: pw.TextStyle(
//                             color:
//                                 PdfColors.green,
//                             fontSize: 24,
//                             fontWeight:
//                                 pw.FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     )
//                   else
//                     pw.Text(
//                       status == 'partial'
//                           ? 'Payment Note: Remaining balance of Rs. ${remaining.toStringAsFixed(0)} is due on or before the return date.'
//                           : 'Payment Note: Bill payment is due on or before the return date.',
//                       style:
//                           const pw.TextStyle(
//                         fontSize: 10,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   pw.Widget _pdfInfoRow(
//     String label,
//     String value,
//   ) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.only(
//         bottom: 4,
//       ),
//       child: pw.Row(
//         children: [
//           pw.SizedBox(
//             width: 105,
//             child: pw.Text(
//               label,
//               style: pw.TextStyle(
//                 fontWeight:
//                     pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.Expanded(
//             child: pw.Text(value),
//           ),
//         ],
//       ),
//     );
//   }

//   pw.Widget _pdfTableCell(
//     String text, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.all(7),
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

//   pw.Widget _pdfAmountRow(
//     String label,
//     double value, {
//     bool bold = false,
//   }) {
//     return pw.Padding(
//       padding:
//           const pw.EdgeInsets.symmetric(
//         vertical: 3,
//       ),
//       child: pw.Row(
//         mainAxisAlignment:
//             pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(
//             label,
//             style: pw.TextStyle(
//               fontWeight: bold
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//             ),
//           ),
//           pw.Text(
//             'Rs. ${value.toStringAsFixed(0)}',
//             style: pw.TextStyle(
//               fontWeight: bold
//                   ? pw.FontWeight.bold
//                   : pw.FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   PdfColor _pdfStatusColor(
//     String status,
//   ) {
//     switch (status) {
//       case 'paid':
//         return PdfColors.green;

//       case 'partial':
//         return PdfColors.orange;

//       default:
//         return PdfColors.red;
//     }
//   }

//   String _formatDate(dynamic value) {
//     DateTime? date;

//     if (value is Timestamp) {
//       date = value.toDate();
//     } else if (value is DateTime) {
//       date = value;
//     } else if (value is String) {
//       date = DateTime.tryParse(value);
//     }

//     if (date == null) {
//       return 'N/A';
//     }

//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }

//   // ============================================================
//   // MAIN UI
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,

//       appBar: AppBar(
//         backgroundColor: surface,
//         foregroundColor: darkBrown,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         titleSpacing: 20,
//         title: const Row(
//           children: [
//             Icon(
//               Icons.receipt_long_rounded,
//               color: bronze,
//               size: 24,
//             ),
//             SizedBox(width: 10),
//             Text(
//               'Bill Management',
//               style: TextStyle(
//                 color: darkBrown,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 19,
//               ),
//             ),
//           ],
//         ),
//       ),

//       drawer: const AdminDrawer(
//         selectedIndex: 4,
//       ),

//       body: StreamBuilder<
//           QuerySnapshot<
//               Map<String, dynamic>>>(
//         stream: FirebaseFirestore
//             .instance
//             .collection('bills')
//             .orderBy(
//               'createdAt',
//               descending: true,
//             )
//             .snapshots(),
//         builder:
//             (context, snapshot) {
//           if (snapshot.hasError) {
//             return _errorState(
//               snapshot.error.toString(),
//             );
//           }

//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: bronze,
//               ),
//             );
//           }

//           final documents =
//               snapshot.data?.docs ?? [];

//           final filteredBills =
//               documents.where((doc) {
//             final bill =
//                 doc.data();

//             final status =
//                 _getPaymentStatus(
//               bill,
//             );

//             final filterMatches =
//                 _selectedFilter ==
//                         'All' ||
//                     status ==
//                         _selectedFilter
//                             .toLowerCase();

//             return filterMatches &&
//                 _matchesSearch(
//                   bill,
//                 );
//           }).toList();

//           return LayoutBuilder(
//             builder:
//                 (context, constraints) {
//               final width =
//                   constraints.maxWidth;

//               final isMobile =
//                   width < 600;

//               final isTablet =
//                   width >= 600 &&
//                       width < 1000;

//               final horizontalPadding =
//                   isMobile
//                       ? 14.0
//                       : isTablet
//                           ? 22.0
//                           : 30.0;

//               return Column(
//                 children: [
//                   _buildPageHeader(
//                     documents.length,
//                     isMobile,
//                     isTablet,
//                   ),

//                   _buildSummary(
//                     documents,
//                     width,
//                   ),

//                   _buildSearchAndFilter(
//                     width,
//                     horizontalPadding,
//                   ),

//                   Expanded(
//                     child: filteredBills
//                             .isEmpty
//                         ? _emptyState()
//                         : ListView.builder(
//                             padding:
//                                 EdgeInsets.fromLTRB(
//                               horizontalPadding,
//                               4,
//                               horizontalPadding,
//                               30,
//                             ),
//                             itemCount:
//                                 filteredBills
//                                     .length,
//                             itemBuilder:
//                                 (context,
//                                     index) {
//                               return _buildBillCard(
//                                 filteredBills[
//                                         index]
//                                     .data(),
//                                 width,
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // PAGE HEADER
//   // ============================================================

//   Widget _buildPageHeader(
//     int totalBills,
//     bool isMobile,
//     bool isTablet,
//   ) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         isMobile ? 14 : 28,
//         isMobile ? 14 : 22,
//         isMobile ? 14 : 28,
//         4,
//       ),
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(
//           isMobile ? 18 : 22,
//         ),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               bronzeDark,
//               bronze,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius:
//               BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: bronze.withOpacity(.20),
//               blurRadius: 18,
//               offset:
//                   const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: isMobile
//             ? Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   _headerIcon(),
//                   const SizedBox(height: 14),
//                   _headerText(totalBills),
//                 ],
//               )
//             : Row(
//                 children: [
//                   _headerIcon(),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child:
//                         _headerText(
//                       totalBills,
//                     ),
//                   ),
//                   if (!isTablet)
//                     _headerDecoration(),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _headerIcon() {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.white
//             .withOpacity(.14),
//         borderRadius:
//             BorderRadius.circular(15),
//         border: Border.all(
//           color: Colors.white
//               .withOpacity(.20),
//         ),
//       ),
//       child: const Icon(
//         Icons.receipt_long_rounded,
//         color: Colors.white,
//         size: 26,
//       ),
//     );
//   }

//   Widget _headerText(int totalBills) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Bills & Payments',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           '$totalBills bill${totalBills == 1 ? '' : 's'} recorded in your rental system',
//           style: TextStyle(
//             color: Colors.white
//                 .withOpacity(.82),
//             fontSize: 13,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _headerDecoration() {
//     return Container(
//       width: 110,
//       height: 70,
//       decoration: BoxDecoration(
//         color: Colors.white
//             .withOpacity(.07),
//         borderRadius:
//             BorderRadius.circular(20),
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.payments_outlined,
//           color: Colors.white,
//           size: 38,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SUMMARY
//   // ============================================================

//   Widget _buildSummary(
//     List<QueryDocumentSnapshot<
//             Map<String, dynamic>>>
//         documents,
//     double width,
//   ) {
//     final all =
//         documents.length;

//     final paid = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'paid',
//         )
//         .length;

//     final unpaid = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'unpaid',
//         )
//         .length;

//     final partial = documents
//         .where(
//           (doc) =>
//               _getPaymentStatus(
//                 doc.data(),
//               ) ==
//               'partial',
//         )
//         .length;

//     final cards = [
//       _summaryCard(
//         'All Bills',
//         all,
//         Icons.receipt_long_rounded,
//         bronze,
//       ),
//       _summaryCard(
//         'Paid',
//         paid,
//         Icons.check_circle_rounded,
//         const Color(0xFF3F7D52),
//       ),
//       _summaryCard(
//         'Unpaid',
//         unpaid,
//         Icons.pending_actions_rounded,
//         const Color(0xFFB64A4A),
//       ),
//       _summaryCard(
//         'Partial',
//         partial,
//         Icons.timelapse_rounded,
//         const Color(0xFFB7791F),
//       ),
//     ];

//     if (width < 600) {
//       return SizedBox(
//         height: 105,
//         child: ListView.separated(
//           scrollDirection:
//               Axis.horizontal,
//           padding:
//               const EdgeInsets.fromLTRB(
//             14,
//             10,
//             14,
//             8,
//           ),
//           itemCount:
//               cards.length,
//           separatorBuilder:
//               (_, __) =>
//                   const SizedBox(
//             width: 10,
//           ),
//           itemBuilder:
//               (_, index) {
//             return SizedBox(
//               width: 155,
//               child: cards[index],
//             );
//           },
//         ),
//       );
//     }

//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         width < 1000 ? 22 : 30,
//         14,
//         width < 1000 ? 22 : 30,
//         10,
//       ),
//       child: Wrap(
//         spacing: 12,
//         runSpacing: 12,
//         children: cards
//             .map(
//               (card) => SizedBox(
//                 width: width < 1000
//                     ? (width - 56) / 2
//                     : (width - 102) / 4,
//                 child: card,
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   Widget _summaryCard(
//     String title,
//     int value,
//     IconData icon,
//     Color accent,
//   ) {
//     return Container(
//       height: 82,
//       padding:
//           const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: surface,
//         borderRadius:
//             BorderRadius.circular(17),
//         border: Border.all(
//           color: border,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: darkBrown
//                 .withOpacity(.045),
//             blurRadius: 12,
//             offset:
//                 const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color:
//                   accent.withOpacity(.10),
//               borderRadius:
//                   BorderRadius.circular(13),
//             ),
//             child: Icon(
//               icon,
//               color: accent,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 11),
//           Expanded(
//             child: Column(
//               mainAxisAlignment:
//                   MainAxisAlignment.center,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow:
//                       TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: mutedText,
//                     fontSize: 11,
//                     fontWeight:
//                         FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   '$value',
//                   style: const TextStyle(
//                     color: darkBrown,
//                     fontSize: 21,
//                     fontWeight:
//                         FontWeight.w800,
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
//   // SEARCH + FILTER
//   // ============================================================

//   Widget _buildSearchAndFilter(
//     double width,
//     double horizontalPadding,
//   ) {
//     final isMobile =
//         width < 600;

//     final searchField =
//         TextField(
//       controller:
//           _searchController,
//       onChanged: (_) {
//         setState(() {});
//       },
//       style: const TextStyle(
//         color: darkBrown,
//         fontSize: 14,
//       ),
//       decoration:
//           InputDecoration(
//         hintText:
//             'Search exact name, bill number or CNIC',
//         hintStyle: const TextStyle(
//           color: mutedText,
//           fontSize: 13,
//         ),
//         prefixIcon:
//             const Icon(
//           Icons.search_rounded,
//           color: bronze,
//         ),
//         suffixIcon:
//             _searchController
//                     .text
//                     .isEmpty
//                 ? null
//                 : IconButton(
//                     icon:
//                         const Icon(
//                       Icons
//                           .clear_rounded,
//                       color: mutedText,
//                     ),
//                     onPressed: () {
//                       _searchController
//                           .clear();
//                       setState(() {});
//                     },
//                   ),
//         filled: true,
//         fillColor: surface,
//         contentPadding:
//             const EdgeInsets
//                 .symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//         border:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             14,
//           ),
//           borderSide:
//               const BorderSide(
//             color: border,
//           ),
//         ),
//         enabledBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             14,
//           ),
//           borderSide:
//               const BorderSide(
//             color: border,
//           ),
//         ),
//         focusedBorder:
//             OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(
//             14,
//           ),
//           borderSide:
//               const BorderSide(
//             color: bronze,
//             width: 1.5,
//           ),
//         ),
//       ),
//     );

//     final filterButton =
//         PopupMenuButton<String>(
//       onSelected: (value) {
//         setState(() {
//           _selectedFilter =
//               value;
//         });
//       },
//       color: surface,
//       elevation: 8,
//       shape:
//           RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.circular(14),
//       ),
//       itemBuilder: (_) => [
//         _filterMenuItem('All'),
//         _filterMenuItem('Paid'),
//         _filterMenuItem('Unpaid'),
//         _filterMenuItem('Partial'),
//       ],
//       child: Container(
//         height: 52,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 15,
//         ),
//         decoration:
//             BoxDecoration(
//           color: surface,
//           borderRadius:
//               BorderRadius.circular(14),
//           border: Border.all(
//             color: border,
//           ),
//         ),
//         child: Row(
//           mainAxisSize:
//               MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.filter_list_rounded,
//               color: bronze,
//               size: 19,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               _selectedFilter,
//               style:
//                   const TextStyle(
//                 color: darkBrown,
//                 fontWeight:
//                     FontWeight.w600,
//                 fontSize: 13,
//               ),
//             ),
//             const SizedBox(width: 5),
//             const Icon(
//               Icons
//                   .keyboard_arrow_down_rounded,
//               color: mutedText,
//             ),
//           ],
//         ),
//       ),
//     );

//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         horizontalPadding,
//         3,
//         horizontalPadding,
//         8,
//       ),
//       child: isMobile
//           ? Column(
//               children: [
//                 searchField,
//                 const SizedBox(height: 9),
//                 Align(
//                   alignment:
//                       Alignment.centerLeft,
//                   child:
//                       filterButton,
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 Expanded(
//                   child: searchField,
//                 ),
//                 const SizedBox(width: 12),
//                 filterButton,
//               ],
//             ),
//     );
//   }

//   PopupMenuItem<String>
//       _filterMenuItem(String value) {
//     return PopupMenuItem<String>(
//       value: value,
//       child: Row(
//         children: [
//           Icon(
//             value == 'All'
//                 ? Icons
//                     .format_list_bulleted_rounded
//                 : value == 'Paid'
//                     ? Icons
//                         .check_circle_outline_rounded
//                     : value == 'Partial'
//                         ? Icons
//                             .timelapse_rounded
//                         : Icons
//                             .pending_actions_rounded,
//             color: value == 'All'
//                 ? bronze
//                 : _statusColor(
//                     value.toLowerCase(),
//                   ),
//             size: 19,
//           ),
//           const SizedBox(width: 9),
//           Text(
//             value,
//             style:
//                 const TextStyle(
//               color: darkBrown,
//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // BILL CARD
//   // ============================================================

//   Widget _buildBillCard(
//     Map<String, dynamic> bill,
//     double width,
//   ) {
//     final isMobile =
//         width < 600;

//     final isTablet =
//         width >= 600 &&
//             width < 1000;

//     final status =
//         _getPaymentStatus(bill);

//     final statusColor =
//         _statusColor(status);

//     final statusBackground =
//         _statusBackground(status);

//     final name =
//         (bill['customerName'] ??
//                 'Unknown Customer')
//             .toString();

//     final contact =
//         (bill['contactNumber'] ??
//                 'N/A')
//             .toString();

//     final billNumber =
//         (bill['billNumber'] ??
//                 'N/A')
//             .toString();

//     final rented =
//         _getRentedItems(bill);

//     final total =
//         _money(
//       bill['totalAmount'],
//     );

//     final dateFrom =
//         _formatDate(
//       bill['dateFrom'],
//     );

//     final dateTill =
//         _formatDate(
//       bill['dateTill'],
//     );

//     return Container(
//       margin:
//           const EdgeInsets.only(
//         bottom: 12,
//       ),
//       padding:
//           EdgeInsets.all(
//         isMobile ? 15 : 18,
//       ),
//       decoration:
//           BoxDecoration(
//         color: surface,
//         borderRadius:
//             BorderRadius.circular(18),
//         border: Border.all(
//           color: border,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: darkBrown
//                 .withOpacity(.045),
//             blurRadius: 13,
//             offset:
//                 const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: isMobile
//           ? _buildMobileBillCard(
//               bill,
//               name,
//               contact,
//               billNumber,
//               rented,
//               total,
//               dateFrom,
//               dateTill,
//               status,
//               statusColor,
//               statusBackground,
//             )
//           : _buildWideBillCard(
//               bill,
//               name,
//               contact,
//               billNumber,
//               rented,
//               total,
//               dateFrom,
//               dateTill,
//               status,
//               statusColor,
//               statusBackground,
//               isTablet,
//             ),
//     );
//   }

//   // ============================================================
//   // WIDE BILL CARD
//   // ============================================================

//   Widget _buildWideBillCard(
//     Map<String, dynamic> bill,
//     String name,
//     String contact,
//     String billNumber,
//     String rented,
//     String total,
//     String dateFrom,
//     String dateTill,
//     String status,
//     Color statusColor,
//     Color statusBackground,
//     bool isTablet,
//   ) {
//     if (isTablet) {
//       return Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _customerBlock(
//                   name,
//                   contact,
//                 ),
//               ),
//               const SizedBox(width: 15),
//               _statusChip(
//                 status,
//                 statusColor,
//                 statusBackground,
//               ),
//             ],
//           ),
//           const SizedBox(height: 15),
//           Container(
//             padding:
//                 const EdgeInsets.all(13),
//             decoration: BoxDecoration(
//               color: background,
//               borderRadius:
//                   BorderRadius.circular(13),
//             ),
//             child: Column(
//               children: [
//                 _responsiveInfoRow(
//                   'Bill Number',
//                   billNumber,
//                 ),
//                 _responsiveInfoRow(
//                   'Rented Items',
//                   rented,
//                 ),
//                 _responsiveInfoRow(
//                   'Rental Period',
//                   '$dateFrom → $dateTill',
//                 ),
//                 _responsiveInfoRow(
//                   'Total Bill',
//                   total,
//                   bold: true,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: _previewButton(bill),
//           ),
//         ],
//       );
//     }

//     return Row(
//       crossAxisAlignment:
//           CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 2,
//           child: _customerBlock(
//             name,
//             contact,
//           ),
//         ),

//         Expanded(
//           flex: 2,
//           child: _billInfoColumn(
//             'Bill Number',
//             billNumber,
//           ),
//         ),

//         Expanded(
//           flex: 3,
//           child: _billInfoColumn(
//             'Rented Items',
//             rented,
//             maxLines: 2,
//           ),
//         ),

//         Expanded(
//           flex: 2,
//           child: _billInfoColumn(
//             'Rental Period',
//             '$dateFrom\n$dateTill',
//           ),
//         ),

//         SizedBox(
//           width: 95,
//           child: _statusChip(
//             status,
//             statusColor,
//             statusBackground,
//           ),
//         ),

//         const SizedBox(width: 15),

//         SizedBox(
//           width: 105,
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.end,
//             children: [
//               const Text(
//                 'TOTAL',
//                 style: TextStyle(
//                   color: mutedText,
//                   fontSize: 10,
//                   fontWeight:
//                       FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 total,
//                 maxLines: 1,
//                 overflow:
//                     TextOverflow.ellipsis,
//                 style:
//                     const TextStyle(
//                   color: bronzeDark,
//                   fontSize: 15,
//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(width: 15),

//         _previewButton(bill),
//       ],
//     );
//   }

//   // ============================================================
//   // MOBILE BILL CARD
//   // ============================================================

//   Widget _buildMobileBillCard(
//     Map<String, dynamic> bill,
//     String name,
//     String contact,
//     String billNumber,
//     String rented,
//     String total,
//     String dateFrom,
//     String dateTill,
//     String status,
//     Color statusColor,
//     Color statusBackground,
//   ) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration:
//                   BoxDecoration(
//                 color:
//                     bronzeLight.withOpacity(.55),
//                 borderRadius:
//                     BorderRadius.circular(13),
//               ),
//               child: const Icon(
//                 Icons.receipt_long_rounded,
//                 color: bronzeDark,
//                 size: 22,
//               ),
//             ),
//             const SizedBox(width: 11),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     maxLines: 2,
//                     overflow:
//                         TextOverflow.ellipsis,
//                     style:
//                         const TextStyle(
//                       color: darkBrown,
//                       fontSize: 16,
//                       fontWeight:
//                           FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     contact,
//                     style:
//                         const TextStyle(
//                       color: mutedText,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             _statusChip(
//               status,
//               statusColor,
//               statusBackground,
//             ),
//           ],
//         ),

//         const SizedBox(height: 14),

//         Container(
//           width: double.infinity,
//           padding:
//               const EdgeInsets.all(13),
//           decoration: BoxDecoration(
//             color: background,
//             borderRadius:
//                 BorderRadius.circular(14),
//             border: Border.all(
//               color: border,
//             ),
//           ),
//           child: Column(
//             children: [
//               _mobileInfoTile(
//                 Icons.confirmation_number_outlined,
//                 'Bill Number',
//                 billNumber,
//               ),
//               _mobileInfoTile(
//                 Icons.inventory_2_outlined,
//                 'Rented Items',
//                 rented,
//               ),
//               _mobileInfoTile(
//                 Icons.date_range_outlined,
//                 'Rental Period',
//                 '$dateFrom → $dateTill',
//               ),
//               _mobileInfoTile(
//                 Icons.payments_outlined,
//                 'Total Bill',
//                 total,
//                 bold: true,
//                 last: true,
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 12),

//         SizedBox(
//           width: double.infinity,
//           child: _previewButton(bill),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // CUSTOMER BLOCK
//   // ============================================================

//   Widget _customerBlock(
//     String name,
//     String contact,
//   ) {
//     return Row(
//       children: [
//         Container(
//           width: 43,
//           height: 43,
//           decoration:
//               BoxDecoration(
//             color:
//                 bronzeLight.withOpacity(.55),
//             borderRadius:
//                 BorderRadius.circular(12),
//           ),
//           child: const Icon(
//             Icons.person_outline_rounded,
//             color: bronzeDark,
//             size: 22,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'CUSTOMER',
//                 style: TextStyle(
//                   color: mutedText,
//                   fontSize: 9,
//                   fontWeight:
//                       FontWeight.w800,
//                   letterSpacing: .5,
//                 ),
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 name,
//                 maxLines: 1,
//                 overflow:
//                     TextOverflow.ellipsis,
//                 style:
//                     const TextStyle(
//                   color: darkBrown,
//                   fontSize: 14,
//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 contact,
//                 maxLines: 1,
//                 overflow:
//                     TextOverflow.ellipsis,
//                 style:
//                     const TextStyle(
//                   color: mutedText,
//                   fontSize: 11,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // BILL INFO
//   // ============================================================

//   Widget _billInfoColumn(
//     String label,
//     String value, {
//     int maxLines = 1,
//   }) {
//     return Padding(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 7,
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Text(
//             label.toUpperCase(),
//             style:
//                 const TextStyle(
//               color: mutedText,
//               fontSize: 9,
//               fontWeight:
//                   FontWeight.w800,
//               letterSpacing: .3,
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             maxLines: maxLines,
//             overflow:
//                 TextOverflow.ellipsis,
//             style:
//                 const TextStyle(
//               color: darkBrown,
//               fontSize: 12,
//               fontWeight:
//                   FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _responsiveInfoRow(
//     String label,
//     String value, {
//     bool bold = false,
//   }) {
//     return Padding(
//       padding:
//           const EdgeInsets.only(
//         bottom: 8,
//       ),
//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 105,
//             child: Text(
//               label,
//               style:
//                   const TextStyle(
//                 color: mutedText,
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: bold
//                     ? bronzeDark
//                     : darkBrown,
//                 fontSize: 12,
//                 fontWeight: bold
//                     ? FontWeight.w800
//                     : FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _mobileInfoTile(
//     IconData icon,
//     String label,
//     String value, {
//     bool bold = false,
//     bool last = false,
//   }) {
//     return Container(
//       padding:
//           const EdgeInsets.only(
//         bottom: 10,
//       ),
//       margin:
//           EdgeInsets.only(
//         bottom: last ? 0 : 8,
//       ),
//       decoration:
//           last
//               ? null
//               : const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(
//                       color: border,
//                     ),
//                   ),
//                 ),
//       child: Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             color: bronze,
//             size: 17,
//           ),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 92,
//             child: Text(
//               label,
//               style:
//                   const TextStyle(
//                 color: mutedText,
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               textAlign:
//                   TextAlign.right,
//               style: TextStyle(
//                 color: bold
//                     ? bronzeDark
//                     : darkBrown,
//                 fontSize: 12,
//                 fontWeight: bold
//                     ? FontWeight.w800
//                     : FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // STATUS CHIP
//   // ============================================================

//   Widget _statusChip(
//     String status,
//     Color color,
//     Color backgroundColor,
//   ) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 7,
//       ),
//       decoration:
//           BoxDecoration(
//         color: backgroundColor,
//         borderRadius:
//             BorderRadius.circular(30),
//         border: Border.all(
//           color:
//               color.withOpacity(.18),
//         ),
//       ),
//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,
//         children: [
//           Icon(
//             _statusIcon(status),
//             color: color,
//             size: 13,
//           ),
//           const SizedBox(width: 5),
//           Text(
//             status.toUpperCase(),
//             style: TextStyle(
//               color: color,
//               fontSize: 9,
//               fontWeight:
//                   FontWeight.w800,
//               letterSpacing: .3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PREVIEW BUTTON
//   // ============================================================

//   Widget _previewButton(
//     Map<String, dynamic> bill,
//   ) {
//     return ElevatedButton.icon(
//       onPressed: () =>
//           _openBillPreview(bill),
//       icon: const Icon(
//         Icons.visibility_rounded,
//         size: 17,
//       ),
//       label: const Text(
//         'Preview Bill',
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: bronze,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 12,
//         ),
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(11),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _emptyState() {
//     final searching =
//         _searchController.text
//             .trim()
//             .isNotEmpty;

//     return Center(
//       child: SingleChildScrollView(
//         padding:
//             const EdgeInsets.all(30),
//         child: Container(
//           constraints:
//               const BoxConstraints(
//             maxWidth: 480,
//           ),
//           padding:
//               const EdgeInsets.all(30),
//           decoration:
//               BoxDecoration(
//             color: surface,
//             borderRadius:
//                 BorderRadius.circular(22),
//             border: Border.all(
//               color: border,
//             ),
//           ),
//           child: Column(
//             mainAxisSize:
//                 MainAxisSize.min,
//             children: [
//               Container(
//                 width: 75,
//                 height: 75,
//                 decoration:
//                     BoxDecoration(
//                   color:
//                       bronzeLight.withOpacity(.55),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons
//                       .receipt_long_outlined,
//                   size: 36,
//                   color: bronzeDark,
//                 ),
//               ),
//               const SizedBox(height: 17),
//               Text(
//                 searching
//                     ? 'No exact match found'
//                     : 'No bills found',
//                 textAlign:
//                     TextAlign.center,
//                 style:
//                     const TextStyle(
//                   color: darkBrown,
//                   fontSize: 18,
//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 7),
//               Text(
//                 searching
//                     ? 'Enter the complete customer name, bill number or CNIC.'
//                     : 'There are no bills in this category yet.',
//                 textAlign:
//                     TextAlign.center,
//                 style:
//                     const TextStyle(
//                   color: mutedText,
//                   fontSize: 13,
//                   height: 1.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ERROR STATE
//   // ============================================================

//   Widget _errorState(String error) {
//     return Center(
//       child: Padding(
//         padding:
//             const EdgeInsets.all(25),
//         child: Container(
//           constraints:
//               const BoxConstraints(
//             maxWidth: 520,
//           ),
//           padding:
//               const EdgeInsets.all(25),
//           decoration:
//               BoxDecoration(
//             color: surface,
//             borderRadius:
//                 BorderRadius.circular(20),
//             border: Border.all(
//               color:
//                   const Color(0xFFE6C5C5),
//             ),
//           ),
//           child: Column(
//             mainAxisSize:
//                 MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons
//                     .error_outline_rounded,
//                 color:
//                     Color(0xFFB64A4A),
//                 size: 45,
//               ),
//               const SizedBox(height: 12),
//               const Text(
//                 'Unable to load bills',
//                 style:
//                     TextStyle(
//                   color: darkBrown,
//                   fontSize: 17,
//                   fontWeight:
//                       FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 error,
//                 textAlign:
//                     TextAlign.center,
//                 style:
//                     const TextStyle(
//                   color: mutedText,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // BILL PREVIEW SCREEN
// // ============================================================

// class BillPreviewScreen
//     extends StatelessWidget {
//   final Uint8List pdfBytes;
//   final String billNumber;

//   const BillPreviewScreen({
//     super.key,
//     required this.pdfBytes,
//     required this.billNumber,
//   });

//   static const Color background =
//       Color(0xFFF7F2EA);

//   static const Color surface =
//       Color(0xFFFFFCF8);

//   static const Color bronze =
//       Color(0xFF9A6A3A);

//   static const Color darkBrown =
//       Color(0xFF2C2119);

//   Future<void> _download() async {
//     await Printing.sharePdf(
//       bytes: pdfBytes,
//       filename: '$billNumber.pdf',
//     );
//   }

//   Future<void> _print() async {
//     await Printing.layoutPdf(
//       onLayout: (_) async => pdfBytes,
//     );
//   }

//   @override
//   Widget build(
//     BuildContext context,
//   ) {
//     return Scaffold(
//       backgroundColor:
//           background,

//       appBar: AppBar(
//         backgroundColor:
//             surface,
//         foregroundColor:
//             darkBrown,
//         elevation: 0,
//         surfaceTintColor:
//             Colors.transparent,

//         titleSpacing: 8,

//         title: Row(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration:
//                   BoxDecoration(
//                 color:
//                     bronze.withOpacity(.10),
//                 borderRadius:
//                     BorderRadius.circular(11),
//               ),
//               child:
//                   const Icon(
//                 Icons
//                     .receipt_long_rounded,
//                 color: bronze,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 'Bill Preview - $billNumber',
//                 maxLines: 1,
//                 overflow:
//                     TextOverflow.ellipsis,
//                 style:
//                     const TextStyle(
//                   color: darkBrown,
//                   fontSize: 16,
//                   fontWeight:
//                       FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         actions: [
//           IconButton(
//             tooltip:
//                 'Download / Save',
//             onPressed: _download,
//             icon:
//                 const Icon(
//               Icons
//                   .download_rounded,
//               color: bronze,
//             ),
//           ),
//           IconButton(
//             tooltip: 'Print',
//             onPressed: _print,
//             icon:
//                 const Icon(
//               Icons.print_rounded,
//               color: bronze,
//             ),
//           ),
//           const SizedBox(width: 5),
//         ],
//       ),

//       body: Container(
//         color: background,
//         padding:
//             const EdgeInsets.all(8),
//         child: PdfPreview(
//           build: (_) async =>
//               pdfBytes,

//           allowPrinting: true,
//           allowSharing: true,

//           canChangePageFormat:
//               false,

//           canChangeOrientation:
//               false,

//           pdfFileName:
//               '$billNumber.pdf',
//         ),
//       ),
//     );
//   }
// }










import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/drawer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BillsManagementScreen extends StatefulWidget {
  const BillsManagementScreen({super.key});

  @override
  State<BillsManagementScreen> createState() =>
      _BillsManagementScreenState();
}

class _BillsManagementScreenState
    extends State<BillsManagementScreen> {
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

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'All';

  // ============================================================
  // FIREBASE USER / COLLECTION
  // ============================================================

  User? get _currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  DocumentReference<Map<String, dynamic>> get _userDocument {
    final user = _currentUser;

    if (user == null) {
      throw Exception(
        'No user is currently logged in.',
      );
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>>
      get _billsCollection {
    return _userDocument.collection('bills');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAYMENT STATUS
  // ============================================================

  String _getPaymentStatus(
    Map<String, dynamic> bill,
  ) {
    final savedStatus =
        (bill['paymentStatus'] ?? '')
            .toString()
            .toLowerCase();

    if (savedStatus == 'paid' ||
        savedStatus == 'partial' ||
        savedStatus == 'unpaid') {
      return savedStatus;
    }

    final total =
        _toDouble(bill['totalAmount']);

    final paid =
        _toDouble(bill['paidAmount']);

    if (total <= 0 || paid >= total) {
      return 'paid';
    }

    if (paid > 0) {
      return 'partial';
    }

    return 'unpaid';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _money(dynamic value) {
    return 'Rs. ${_toDouble(value).toStringAsFixed(0)}';
  }

  // ============================================================
  // EXACT SEARCH
  // ============================================================

  bool _matchesSearch(
    Map<String, dynamic> bill,
  ) {
    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    final name =
        (bill['customerName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

    final billNumber =
        (bill['billNumber'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

    final cnic =
        (bill['cnic'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

    return query == name ||
        query == billNumber ||
        query == cnic;
  }

  // ============================================================
  // RENTED ITEMS
  // ============================================================

  String _getRentedItems(
    Map<String, dynamic> bill,
  ) {
    final items = bill['items'];

    if (items is! List || items.isEmpty) {
      return 'No items';
    }

    final result = <String>[];

    for (final item in items) {
      if (item is Map) {
        final name =
            (item['name'] ?? 'Item').toString();

        final quantity =
            item['quantity'] ?? 0;

        result.add(
          '$name x$quantity',
        );
      }
    }

    return result.isEmpty
        ? 'No items'
        : result.join(', ');
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'paid':
        return const Color(0xFF3F7D52);

      case 'partial':
        return const Color(0xFFB7791F);

      default:
        return const Color(0xFFB64A4A);
    }
  }

  Color _statusBackground(
    String status,
  ) {
    switch (status) {
      case 'paid':
        return const Color(0xFFE5F2E8);

      case 'partial':
        return const Color(0xFFFFF0D5);

      default:
        return const Color(0xFFFBE6E6);
    }
  }

  IconData _statusIcon(
    String status,
  ) {
    switch (status) {
      case 'paid':
        return Icons.check_circle_rounded;

      case 'partial':
        return Icons.timelapse_rounded;

      default:
        return Icons.pending_actions_rounded;
    }
  }

  // ============================================================
  // OPEN BILL PREVIEW
  // ============================================================

  Future<void> _openBillPreview(
    Map<String, dynamic> bill,
  ) async {
    try {
      final pdfBytes =
          await _buildBillPdf(bill);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BillPreviewScreen(
            pdfBytes: pdfBytes,
            billNumber:
                (bill['billNumber'] ?? 'Bill')
                    .toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor:
              const Color(0xFFB64A4A),
          behavior:
              SnackBarBehavior.floating,
          content: Text(
            'Could not create bill preview: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD PDF
  // ============================================================

  Future<Uint8List> _buildBillPdf(
    Map<String, dynamic> bill,
  ) async {
    final pdf = pw.Document();

    final status =
        _getPaymentStatus(bill);

    final billNumber =
        (bill['billNumber'] ?? 'N/A')
            .toString();

    final customerName =
        (bill['customerName'] ?? 'N/A')
            .toString();

    final contact =
        (bill['contactNumber'] ?? 'N/A')
            .toString();

    final cnic =
        (bill['cnic'] ?? 'N/A')
            .toString();

    // ==========================================================
    // RENTAL LOCATION
    // IMPORTANT:
    // This is read from the SAME BILL DOCUMENT.
    // ==========================================================

    final rentalLocation =
        (bill['rentalLocation'] ?? 'N/A')
            .toString()
            .trim();

    final subtotal =
        _toDouble(bill['subtotal']);

    final discount =
        _toDouble(bill['discount']);

    final total =
        _toDouble(bill['totalAmount']);

    final paid =
        _toDouble(bill['paidAmount']);

    final remaining =
        _toDouble(bill['remainingAmount']);

    final items =
        <Map<String, dynamic>>[];

    if (bill['items'] is List) {
      for (final item in bill['items']) {
        if (item is Map) {
          items.add(
            Map<String, dynamic>.from(item),
          );
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat:
            PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Container(
              padding:
                  const pw.EdgeInsets.all(18),
              decoration:
                  pw.BoxDecoration(
                border:
                    pw.Border.all(
                  color:
                      PdfColors.blueGrey700,
                  width: 1.2,
                ),
                borderRadius:
                    pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'RENTAL BILL',
                        style:
                            pw.TextStyle(
                          fontSize: 24,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                      pw.Container(
                        padding:
                            const pw.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration:
                            pw.BoxDecoration(
                          color:
                              _pdfStatusColor(
                            status,
                          ),
                          borderRadius:
                              pw.BorderRadius.circular(
                            5,
                          ),
                        ),
                        child: pw.Text(
                          status.toUpperCase(),
                          style:
                              pw.TextStyle(
                            color:
                                PdfColors.white,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(
                    height: 15,
                  ),

                  pw.Divider(),

                  // ==================================================
                  // BILL INFORMATION
                  // ==================================================

                  _pdfInfoRow(
                    'Bill Number',
                    billNumber,
                  ),

                  _pdfInfoRow(
                    'Generated Date',
                    _formatDate(
                      bill['createdAt'],
                    ),
                  ),

                  pw.SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // CUSTOMER DETAILS
                  // ==================================================

                  pw.Text(
                    'CUSTOMER DETAILS',
                    style:
                        pw.TextStyle(
                      fontSize: 12,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(
                    height: 7,
                  ),

                  _pdfInfoRow(
                    'Name',
                    customerName,
                  ),

                  _pdfInfoRow(
                    'Contact',
                    contact,
                  ),

                  _pdfInfoRow(
                    'CNIC',
                    cnic,
                  ),

                  // ==================================================
                  // RENTAL LOCATION
                  // ==================================================

                  _pdfInfoRow(
                    'Rental Location',
                    rentalLocation.isEmpty
                        ? 'N/A'
                        : rentalLocation,
                  ),

                  pw.SizedBox(
                    height: 10,
                  ),

                  // ==================================================
                  // RENTAL PERIOD
                  // ==================================================

                  pw.Text(
                    'RENTAL PERIOD',
                    style:
                        pw.TextStyle(
                      fontSize: 12,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(
                    height: 7,
                  ),

                  _pdfInfoRow(
                    'From',
                    _formatDate(
                      bill['dateFrom'],
                    ),
                  ),

                  _pdfInfoRow(
                    'Till',
                    _formatDate(
                      bill['dateTill'],
                    ),
                  ),

                  pw.SizedBox(
                    height: 16,
                  ),

                  // ==================================================
                  // RENTED ITEMS
                  // ==================================================

                  pw.Text(
                    'RENTED ITEMS',
                    style:
                        pw.TextStyle(
                      fontSize: 12,
                      fontWeight:
                          pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(
                    height: 8,
                  ),

                  pw.Table(
                    border:
                        pw.TableBorder.all(
                      color:
                          PdfColors.grey400,
                    ),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(
                        3,
                      ),
                      1: const pw.FlexColumnWidth(
                        1,
                      ),
                      2: const pw.FlexColumnWidth(
                        1.5,
                      ),
                      3: const pw.FlexColumnWidth(
                        1.7,
                      ),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(
                          color:
                              PdfColors.grey200,
                        ),
                        children: [
                          _pdfTableCell(
                            'Item',
                            bold: true,
                          ),
                          _pdfTableCell(
                            'Qty',
                            bold: true,
                          ),
                          _pdfTableCell(
                            'Rate',
                            bold: true,
                          ),
                          _pdfTableCell(
                            'Amount',
                            bold: true,
                          ),
                        ],
                      ),

                      ...items.map(
                        (item) {
                          final quantity =
                              _toDouble(
                            item['quantity'],
                          );

                          final rate =
                              _toDouble(
                            item['rentPrice'] ??
                                item['price'],
                          );

                          final amount =
                              _toDouble(
                            item['total'] ??
                                item['amount'],
                          );

                          return pw.TableRow(
                            children: [
                              _pdfTableCell(
                                (item['name'] ??
                                        'Item')
                                    .toString(),
                              ),
                              _pdfTableCell(
                                quantity
                                    .toStringAsFixed(
                                  0,
                                ),
                              ),
                              _pdfTableCell(
                                'Rs. ${rate.toStringAsFixed(0)}',
                              ),
                              _pdfTableCell(
                                'Rs. ${amount.toStringAsFixed(0)}',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),

                  pw.SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // AMOUNTS
                  // ==================================================

                  pw.Align(
                    alignment:
                        pw.Alignment.centerRight,
                    child: pw.SizedBox(
                      width: 250,
                      child: pw.Column(
                        children: [
                          _pdfAmountRow(
                            'Actual Amount',
                            subtotal,
                          ),

                          _pdfAmountRow(
                            'Discount',
                            discount,
                          ),

                          pw.Divider(),

                          _pdfAmountRow(
                            'Total Amount',
                            total,
                            bold: true,
                          ),

                          _pdfAmountRow(
                            'Paid',
                            paid,
                          ),

                          _pdfAmountRow(
                            'Remaining',
                            remaining,
                            bold: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(
                    height: 18,
                  ),

                  pw.Divider(),

                  pw.SizedBox(
                    height: 8,
                  ),

                  // ==================================================
                  // PAYMENT STATUS
                  // ==================================================

                  if (status == 'paid')
                    pw.Center(
                      child: pw.Container(
                        padding:
                            const pw.EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        decoration:
                            pw.BoxDecoration(
                          border:
                              pw.Border.all(
                            color:
                                PdfColors.green,
                            width: 3,
                          ),
                        ),
                        child: pw.Text(
                          'PAID',
                          style:
                              pw.TextStyle(
                            color:
                                PdfColors.green,
                            fontSize: 24,
                            fontWeight:
                                pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    pw.Text(
                      status == 'partial'
                          ? 'Payment Note: Remaining balance of Rs. ${remaining.toStringAsFixed(0)} is due on or before the return date.'
                          : 'Payment Note: Bill payment is due on or before the return date.',
                      style:
                          const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // PDF INFO ROW
  // ============================================================

  pw.Widget _pdfInfoRow(
    String label,
    String value,
  ) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.only(
        bottom: 4,
      ),
      child: pw.Row(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 105,
            child: pw.Text(
              label,
              style:
                  pw.TextStyle(
                fontWeight:
                    pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF TABLE CELL
  // ============================================================

  pw.Widget _pdfTableCell(
    String text, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        style:
            pw.TextStyle(
          fontSize: 9,
          fontWeight: bold
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ============================================================
  // PDF AMOUNT ROW
  // ============================================================

  pw.Widget _pdfAmountRow(
    String label,
    double value, {
    bool bold = false,
  }) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: pw.Row(
        mainAxisAlignment:
            pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style:
                pw.TextStyle(
              fontWeight: bold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            'Rs. ${value.toStringAsFixed(0)}',
            style:
                pw.TextStyle(
              fontWeight: bold
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PDF STATUS COLOR
  // ============================================================

  PdfColor _pdfStatusColor(
    String status,
  ) {
    switch (status) {
      case 'paid':
        return PdfColors.green;

      case 'partial':
        return PdfColors.orange;

      default:
        return PdfColors.red;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    dynamic value,
  ) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return 'N/A';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(
          child: Text(
            'Please log in to view bills.',
            style: TextStyle(
              color: darkBrown,
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          background,

      appBar: AppBar(
        backgroundColor:
            surface,
        foregroundColor:
            darkBrown,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              color: bronze,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Bill Management',
              style: TextStyle(
                color: darkBrown,
                fontWeight:
                    FontWeight.w700,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),

      drawer: const AdminDrawer(
        selectedIndex: 4,
      ),

      // ==========================================================
      // IMPORTANT:
      // Bills are now loaded from:
      //
      // Users/{currentUserUid}/bills
      //
      // ==========================================================

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: _billsCollection
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),

        builder:
            (context, snapshot) {
          if (snapshot.hasError) {
            return _errorState(
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: bronze,
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          final filteredBills =
              documents.where((doc) {
            final bill =
                doc.data();

            final status =
                _getPaymentStatus(
              bill,
            );

            final filterMatches =
                _selectedFilter ==
                        'All' ||
                    status ==
                        _selectedFilter
                            .toLowerCase();

            return filterMatches &&
                _matchesSearch(
                  bill,
                );
          }).toList();

          return LayoutBuilder(
            builder:
                (context, constraints) {
              final width =
                  constraints.maxWidth;

              final isMobile =
                  width < 600;

              final isTablet =
                  width >= 600 &&
                      width < 1000;

              final horizontalPadding =
                  isMobile
                      ? 14.0
                      : isTablet
                          ? 22.0
                          : 30.0;

              return Column(
                children: [
                  _buildPageHeader(
                    documents.length,
                    isMobile,
                    isTablet,
                  ),

                  _buildSummary(
                    documents,
                    width,
                  ),

                  _buildSearchAndFilter(
                    width,
                    horizontalPadding,
                  ),

                  Expanded(
                    child: filteredBills
                            .isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            padding:
                                EdgeInsets.fromLTRB(
                              horizontalPadding,
                              4,
                              horizontalPadding,
                              30,
                            ),
                            itemCount:
                                filteredBills
                                    .length,
                            itemBuilder:
                                (context,
                                    index) {
                              return _buildBillCard(
                                filteredBills[
                                        index]
                                    .data(),
                                width,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildPageHeader(
    int totalBills,
    bool isMobile,
    bool isTablet,
  ) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        isMobile ? 14 : 28,
        isMobile ? 14 : 22,
        isMobile ? 14 : 28,
        4,
      ),
      child: Container(
        width: double.infinity,
        padding:
            EdgeInsets.all(
          isMobile ? 18 : 22,
        ),
        decoration:
            BoxDecoration(
          gradient:
              const LinearGradient(
            colors: [
              bronzeDark,
              bronze,
            ],
            begin:
                Alignment.topLeft,
            end:
                Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  bronze.withOpacity(.20),
              blurRadius: 18,
              offset:
                  const Offset(0, 8),
            ),
          ],
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _headerIcon(),
                  const SizedBox(
                    height: 14,
                  ),
                  _headerText(
                    totalBills,
                  ),
                ],
              )
            : Row(
                children: [
                  _headerIcon(),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child:
                        _headerText(
                      totalBills,
                    ),
                  ),
                  if (!isTablet)
                    _headerDecoration(),
                ],
              ),
      ),
    );
  }

  Widget _headerIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.14),
        borderRadius:
            BorderRadius.circular(15),
        border:
            Border.all(
          color:
              Colors.white.withOpacity(.20),
        ),
      ),
      child:
          const Icon(
        Icons.receipt_long_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _headerText(
    int totalBills,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Bills & Payments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          '$totalBills bill${totalBills == 1 ? '' : 's'} recorded in your rental system',
          style:
              TextStyle(
            color:
                Colors.white.withOpacity(.82),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _headerDecoration() {
    return Container(
      width: 110,
      height: 70,
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.07),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child:
          const Center(
        child: Icon(
          Icons.payments_outlined,
          color: Colors.white,
          size: 38,
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
    List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>
        documents,
    double width,
  ) {
    final all =
        documents.length;

    final paid = documents
        .where(
          (doc) =>
              _getPaymentStatus(
                doc.data(),
              ) ==
              'paid',
        )
        .length;

    final unpaid = documents
        .where(
          (doc) =>
              _getPaymentStatus(
                doc.data(),
              ) ==
              'unpaid',
        )
        .length;

    final partial = documents
        .where(
          (doc) =>
              _getPaymentStatus(
                doc.data(),
              ) ==
              'partial',
        )
        .length;

    final cards = [
      _summaryCard(
        'All Bills',
        all,
        Icons.receipt_long_rounded,
        bronze,
      ),
      _summaryCard(
        'Paid',
        paid,
        Icons.check_circle_rounded,
        const Color(0xFF3F7D52),
      ),
      _summaryCard(
        'Unpaid',
        unpaid,
        Icons.pending_actions_rounded,
        const Color(0xFFB64A4A),
      ),
      _summaryCard(
        'Partial',
        partial,
        Icons.timelapse_rounded,
        const Color(0xFFB7791F),
      ),
    ];

    if (width < 600) {
      return SizedBox(
        height: 105,
        child:
            ListView.separated(
          scrollDirection:
              Axis.horizontal,
          padding:
              const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            8,
          ),
          itemCount:
              cards.length,
          separatorBuilder:
              (_, __) =>
                  const SizedBox(
            width: 10,
          ),
          itemBuilder:
              (_, index) {
            return SizedBox(
              width: 155,
              child:
                  cards[index],
            );
          },
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        width < 1000 ? 22 : 30,
        14,
        width < 1000 ? 22 : 30,
        10,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children:
            cards
                .map(
                  (card) =>
                      SizedBox(
                    width:
                        width < 1000
                            ? (width -
                                    56) /
                                2
                            : (width -
                                    102) /
                                4,
                    child: card,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    int value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      height: 82,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(17),
        border:
            Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                darkBrown.withOpacity(.045),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child:
          Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  accent.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child:
                Icon(
              icon,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child:
                Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: mutedText,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '$value',
                  style:
                      const TextStyle(
                    color: darkBrown,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
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
  // SEARCH + FILTER
  // ============================================================

  Widget _buildSearchAndFilter(
    double width,
    double horizontalPadding,
  ) {
    final isMobile =
        width < 600;

    final searchField =
        TextField(
      controller:
          _searchController,
      onChanged: (_) {
        setState(() {});
      },
      style:
          const TextStyle(
        color: darkBrown,
        fontSize: 14,
      ),
      decoration:
          InputDecoration(
        hintText:
            'Search exact name, bill number or CNIC',
        hintStyle:
            const TextStyle(
          color: mutedText,
          fontSize: 13,
        ),
        prefixIcon:
            const Icon(
          Icons.search_rounded,
          color: bronze,
        ),
        suffixIcon:
            _searchController
                    .text
                    .isEmpty
                ? null
                : IconButton(
                    icon:
                        const Icon(
                      Icons.clear_rounded,
                      color:
                          mutedText,
                    ),
                    onPressed:
                        () {
                      _searchController
                          .clear();
                      setState(
                        () {},
                      );
                    },
                  ),
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide:
              const BorderSide(
            color: bronze,
            width: 1.5,
          ),
        ),
      ),
    );

    final filterButton =
        PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedFilter =
              value;
        });
      },
      color: surface,
      elevation: 8,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(14),
      ),
      itemBuilder: (_) => [
        _filterMenuItem('All'),
        _filterMenuItem('Paid'),
        _filterMenuItem('Unpaid'),
        _filterMenuItem('Partial'),
      ],
      child: Container(
        height: 52,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        decoration:
            BoxDecoration(
          color: surface,
          borderRadius:
              BorderRadius.circular(14),
          border:
              Border.all(
            color: border,
          ),
        ),
        child:
            Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.filter_list_rounded,
              color: bronze,
              size: 19,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _selectedFilter,
              style:
                  const TextStyle(
                color: darkBrown,
                fontWeight:
                    FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(
              Icons
                  .keyboard_arrow_down_rounded,
              color: mutedText,
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        horizontalPadding,
        3,
        horizontalPadding,
        8,
      ),
      child: isMobile
          ? Column(
              children: [
                searchField,
                const SizedBox(
                  height: 9,
                ),
                Align(
                  alignment:
                      Alignment.centerLeft,
                  child:
                      filterButton,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child:
                      searchField,
                ),
                const SizedBox(
                  width: 12,
                ),
                filterButton,
              ],
            ),
    );
  }

  PopupMenuItem<String>
      _filterMenuItem(
    String value,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child:
          Row(
        children: [
          Icon(
            value == 'All'
                ? Icons
                    .format_list_bulleted_rounded
                : value == 'Paid'
                    ? Icons
                        .check_circle_outline_rounded
                    : value == 'Partial'
                        ? Icons
                            .timelapse_rounded
                        : Icons
                            .pending_actions_rounded,
            color: value == 'All'
                ? bronze
                : _statusColor(
                    value.toLowerCase(),
                  ),
            size: 19,
          ),
          const SizedBox(
            width: 9,
          ),
          Text(
            value,
            style:
                const TextStyle(
              color: darkBrown,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BILL CARD
  // ============================================================

  Widget _buildBillCard(
    Map<String, dynamic> bill,
    double width,
  ) {
    final isMobile =
        width < 600;

    final isTablet =
        width >= 600 &&
            width < 1000;

    final status =
        _getPaymentStatus(bill);

    final statusColor =
        _statusColor(status);

    final statusBackground =
        _statusBackground(status);

    final name =
        (bill['customerName'] ??
                'Unknown Customer')
            .toString();

    final contact =
        (bill['contactNumber'] ??
                'N/A')
            .toString();

    final billNumber =
        (bill['billNumber'] ??
                'N/A')
            .toString();

    final rented =
        _getRentedItems(bill);

    final total =
        _money(
      bill['totalAmount'],
    );

    final dateFrom =
        _formatDate(
      bill['dateFrom'],
    );

    final dateTill =
        _formatDate(
      bill['dateTill'],
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          EdgeInsets.all(
        isMobile ? 15 : 18,
      ),
      decoration:
          BoxDecoration(
        color: surface,
        borderRadius:
            BorderRadius.circular(18),
        border:
            Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                darkBrown.withOpacity(.045),
            blurRadius: 13,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: isMobile
          ? _buildMobileBillCard(
              bill,
              name,
              contact,
              billNumber,
              rented,
              total,
              dateFrom,
              dateTill,
              status,
              statusColor,
              statusBackground,
            )
          : _buildWideBillCard(
              bill,
              name,
              contact,
              billNumber,
              rented,
              total,
              dateFrom,
              dateTill,
              status,
              statusColor,
              statusBackground,
              isTablet,
            ),
    );
  }

  // ============================================================
  // WIDE BILL CARD
  // ============================================================

  Widget _buildWideBillCard(
    Map<String, dynamic> bill,
    String name,
    String contact,
    String billNumber,
    String rented,
    String total,
    String dateFrom,
    String dateTill,
    String status,
    Color statusColor,
    Color statusBackground,
    bool isTablet,
  ) {
    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    _customerBlock(
                  name,
                  contact,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              _statusChip(
                status,
                statusColor,
                statusBackground,
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            padding:
                const EdgeInsets.all(13),
            decoration:
                BoxDecoration(
              color: background,
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child:
                Column(
              children: [
                _responsiveInfoRow(
                  'Bill Number',
                  billNumber,
                ),
                _responsiveInfoRow(
                  'Rented Items',
                  rented,
                ),
                _responsiveInfoRow(
                  'Rental Period',
                  '$dateFrom → $dateTill',
                ),
                _responsiveInfoRow(
                  'Rental Location',
                  (bill['rentalLocation'] ??
                          'N/A')
                      .toString(),
                ),
                _responsiveInfoRow(
                  'Total Bill',
                  total,
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child:
                _previewButton(bill),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child:
              _customerBlock(
            name,
            contact,
          ),
        ),

        Expanded(
          flex: 2,
          child:
              _billInfoColumn(
            'Bill Number',
            billNumber,
          ),
        ),

        Expanded(
          flex: 3,
          child:
              _billInfoColumn(
            'Rented Items',
            rented,
            maxLines: 2,
          ),
        ),

        Expanded(
          flex: 2,
          child:
              _billInfoColumn(
            'Rental Period',
            '$dateFrom\n$dateTill',
          ),
        ),

        SizedBox(
          width: 95,
          child:
              _statusChip(
            status,
            statusColor,
            statusBackground,
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        SizedBox(
          width: 105,
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL',
                style:
                    TextStyle(
                  color: mutedText,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                total,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color: bronzeDark,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          width: 15,
        ),

        _previewButton(bill),
      ],
    );
  }

  // ============================================================
  // MOBILE BILL CARD
  // ============================================================

  Widget _buildMobileBillCard(
    Map<String, dynamic> bill,
    String name,
    String contact,
    String billNumber,
    String rented,
    String total,
    String dateFrom,
    String dateTill,
    String status,
    Color statusColor,
    Color statusBackground,
  ) {
    final rentalLocation =
        (bill['rentalLocation'] ??
                'N/A')
            .toString();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(
                color:
                    bronzeLight.withOpacity(.55),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child:
                  const Icon(
                Icons.receipt_long_rounded,
                color: bronzeDark,
                size: 22,
              ),
            ),
            const SizedBox(
              width: 11,
            ),
            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: darkBrown,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    contact,
                    style:
                        const TextStyle(
                      color: mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            _statusChip(
              status,
              statusColor,
              statusBackground,
            ),
          ],
        ),

        const SizedBox(
          height: 14,
        ),

        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(13),
          decoration:
              BoxDecoration(
            color: background,
            borderRadius:
                BorderRadius.circular(14),
            border:
                Border.all(
              color: border,
            ),
          ),
          child:
              Column(
            children: [
              _mobileInfoTile(
                Icons.confirmation_number_outlined,
                'Bill Number',
                billNumber,
              ),
              _mobileInfoTile(
                Icons.inventory_2_outlined,
                'Rented Items',
                rented,
              ),
              _mobileInfoTile(
                Icons.date_range_outlined,
                'Rental Period',
                '$dateFrom → $dateTill',
              ),
              _mobileInfoTile(
                Icons.location_on_outlined,
                'Rental Location',
                rentalLocation,
              ),
              _mobileInfoTile(
                Icons.payments_outlined,
                'Total Bill',
                total,
                bold: true,
                last: true,
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        SizedBox(
          width: double.infinity,
          child:
              _previewButton(bill),
        ),
      ],
    );
  }

  // ============================================================
  // CUSTOMER BLOCK
  // ============================================================

  Widget _customerBlock(
    String name,
    String contact,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration:
              BoxDecoration(
            color:
                bronzeLight.withOpacity(.55),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child:
              const Icon(
            Icons.person_outline_rounded,
            color: bronzeDark,
            size: 22,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'CUSTOMER',
                style:
                    TextStyle(
                  color: mutedText,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color: darkBrown,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                contact,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color: mutedText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BILL INFO
  // ============================================================

  Widget _billInfoColumn(
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style:
                const TextStyle(
              color: mutedText,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            value,
            maxLines: maxLines,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveInfoRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child:
                Text(
              label,
              style:
                  const TextStyle(
                color: mutedText,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child:
                Text(
              value,
              style:
                  TextStyle(
                color: bold
                    ? bronzeDark
                    : darkBrown,
                fontSize: 12,
                fontWeight: bold
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileInfoTile(
    IconData icon,
    String label,
    String value, {
    bool bold = false,
    bool last = false,
  }) {
    return Container(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      margin:
          EdgeInsets.only(
        bottom: last ? 0 : 8,
      ),
      decoration:
          last
              ? null
              : const BoxDecoration(
                  border:
                      Border(
                    bottom:
                        BorderSide(
                      color: border,
                    ),
                  ),
                ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: bronze,
            size: 17,
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 92,
            child:
                Text(
              label,
              style:
                  const TextStyle(
                color: mutedText,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child:
                Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  TextStyle(
                color: bold
                    ? bronzeDark
                    : darkBrown,
                fontSize: 12,
                fontWeight: bold
                    ? FontWeight.w800
                    : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _statusChip(
    String status,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration:
          BoxDecoration(
        color:
            backgroundColor,
        borderRadius:
            BorderRadius.circular(30),
        border:
            Border.all(
          color:
              color.withOpacity(.18),
        ),
      ),
      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            _statusIcon(status),
            color: color,
            size: 13,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            status.toUpperCase(),
            style:
                TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW BUTTON
  // ============================================================

  Widget _previewButton(
    Map<String, dynamic> bill,
  ) {
    return ElevatedButton.icon(
      onPressed: () =>
          _openBillPreview(bill),
      icon:
          const Icon(
        Icons.visibility_rounded,
        size: 17,
      ),
      label:
          const Text(
        'Preview Bill',
      ),
      style:
          ElevatedButton.styleFrom(
        backgroundColor: bronze,
        foregroundColor:
            Colors.white,
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(11),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    final searching =
        _searchController.text
            .trim()
            .isNotEmpty;

    return Center(
      child:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(30),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 480,
          ),
          padding:
              const EdgeInsets.all(30),
          decoration:
              BoxDecoration(
            color: surface,
            borderRadius:
                BorderRadius.circular(22),
            border:
                Border.all(
              color: border,
            ),
          ),
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration:
                    BoxDecoration(
                  color:
                      bronzeLight.withOpacity(.55),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .receipt_long_outlined,
                  size: 36,
                  color: bronzeDark,
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              Text(
                searching
                    ? 'No exact match found'
                    : 'No bills found',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: darkBrown,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                searching
                    ? 'Enter the complete customer name, bill number or CNIC.'
                    : 'There are no bills in this category yet.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: mutedText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    String error,
  ) {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(25),
        child: Container(
          constraints:
              const BoxConstraints(
            maxWidth: 520,
          ),
          padding:
              const EdgeInsets.all(25),
          decoration:
              BoxDecoration(
            color: surface,
            borderRadius:
                BorderRadius.circular(20),
            border:
                Border.all(
              color:
                  const Color(0xFFE6C5C5),
            ),
          ),
          child:
              Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons
                    .error_outline_rounded,
                color:
                    Color(0xFFB64A4A),
                size: 45,
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Unable to load bills',
                style:
                    TextStyle(
                  color: darkBrown,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                error,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BILL PREVIEW SCREEN
// ============================================================

class BillPreviewScreen
    extends StatelessWidget {
  final Uint8List pdfBytes;
  final String billNumber;

  const BillPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.billNumber,
  });

  static const Color background =
      Color(0xFFF7F2EA);

  static const Color surface =
      Color(0xFFFFFCF8);

  static const Color bronze =
      Color(0xFF9A6A3A);

  static const Color darkBrown =
      Color(0xFF2C2119);

  // ============================================================
  // DOWNLOAD / SHARE
  // ============================================================

  Future<void> _download() async {
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename:
          '$billNumber.pdf',
    );
  }

  // ============================================================
  // PRINT
  // ============================================================

  Future<void> _print() async {
    await Printing.layoutPdf(
      onLayout: (_) async =>
          pdfBytes,
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
          background,

      appBar: AppBar(
        backgroundColor:
            surface,
        foregroundColor:
            darkBrown,
        elevation: 0,
        surfaceTintColor:
            Colors.transparent,

        titleSpacing: 8,

        title:
            Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  BoxDecoration(
                color:
                    bronze.withOpacity(.10),
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .receipt_long_rounded,
                color: bronze,
                size: 20,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  Text(
                'Bill Preview - $billNumber',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  color: darkBrown,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip:
                'Download / Save',
            onPressed:
                _download,
            icon:
                const Icon(
              Icons.download_rounded,
              color: bronze,
            ),
          ),

          IconButton(
            tooltip: 'Print',
            onPressed:
                _print,
            icon:
                const Icon(
              Icons.print_rounded,
              color: bronze,
            ),
          ),

          const SizedBox(
            width: 5,
          ),
        ],
      ),

      // ==========================================================
      // SAME PDF BYTES ARE SHOWN HERE
      //
      // The PDF was generated from the bill document, including:
      //
      // rentalLocation
      //
      // Therefore Preview / Print / Share all use the same bill.
      // ==========================================================

      body:
          Container(
        color: background,
        padding:
            const EdgeInsets.all(8),
        child:
            PdfPreview(
          build: (_) async =>
              pdfBytes,

          allowPrinting:
              true,

          allowSharing:
              true,

          canChangePageFormat:
              false,

          canChangeOrientation:
              false,

          pdfFileName:
              '$billNumber.pdf',
        ),
      ),
    );
  }
}