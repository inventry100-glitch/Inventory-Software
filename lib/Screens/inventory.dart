// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import 'add_item.dart';

// class InventoryScreen extends StatefulWidget {
//   const InventoryScreen({super.key});

//   @override
//   State<InventoryScreen> createState() => _InventoryScreenState();
// }

// class _InventoryScreenState extends State<InventoryScreen> {
//   final TextEditingController _searchController =
//       TextEditingController();

//   String _selectedCategory = 'All';

//   final List<String> _categories = [
//     'All',
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
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
//   // SEARCH VALIDATION
//   // ============================================================

//   void _onSearchChanged(String value) {
//     // Numbers are not allowed in search.
//     final cleanedValue = value.replaceAll(RegExp(r'[0-9]'), '');

//     if (cleanedValue != value) {
//       _searchController.value = TextEditingValue(
//         text: cleanedValue,
//         selection: TextSelection.collapsed(
//           offset: cleanedValue.length,
//         ),
//       );
//     }

//     setState(() {});
//   }

//   // ============================================================
//   // FILTER ITEMS
//   // ============================================================

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterItems(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
//   ) {
//     final search = _searchController.text.trim().toLowerCase();

//     return items.where((document) {
//       final data = document.data();

//       final name =
//           (data['name'] ?? '').toString().toLowerCase();

//       final category =
//           (data['category'] ?? '').toString().toLowerCase();

//       final material =
//           (data['material'] ?? '').toString().toLowerCase();

//       final description =
//           (data['description'] ?? '').toString().toLowerCase();

//       final matchesSearch =
//           search.isEmpty ||
//           name.contains(search) ||
//           category.contains(search) ||
//           material.contains(search) ||
//           description.contains(search);

//       final matchesCategory =
//           _selectedCategory == 'All' ||
//           data['category'] == _selectedCategory;

//       return matchesSearch && matchesCategory;
//     }).toList();
//   }

//   // ============================================================
//   // DELETE ITEM
//   // ============================================================

//   Future<void> _deleteItem(
//     String documentId,
//     String itemName,
//   ) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Item'),
//           content: Text(
//             'Are you sure you want to delete "$itemName"?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance
//           .collection('inventory')
//           .doc(documentId)
//           .delete();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item deleted successfully.'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to delete item.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // EDIT ITEM
//   // ============================================================

//   Future<void> _editItem(
//     String documentId,
//     Map<String, dynamic> data,
//   ) async {
//     final nameController = TextEditingController(
//       text: data['name']?.toString() ?? '',
//     );

//     final totalController = TextEditingController(
//       text: data['totalStock']?.toString() ?? '0',
//     );

//     final rentedController = TextEditingController(
//       text: data['rentedStock']?.toString() ?? '0',
//     );

//     final priceController = TextEditingController(
//       text: data['rentPrice']?.toString() ?? '0',
//     );

//     final descriptionController = TextEditingController(
//       text: data['description']?.toString() ?? '',
//     );

//     String selectedCategory =
//         data['category']?.toString() ?? 'Other';

//     String selectedMaterial =
//         data['material']?.toString() ?? 'Other';

//     final editFormKey = GlobalKey<FormState>();

//     bool isSaving = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             final total =
//                 int.tryParse(totalController.text.trim()) ?? 0;

//             final rented =
//                 int.tryParse(rentedController.text.trim()) ?? 0;

//             final available =
//                 total - rented;

//             return AlertDialog(
//               title: const Text(
//                 'Edit Inventory Item',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               content: SizedBox(
//                 width: 600,

//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: editFormKey,

//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [

//                         // NAME
//                         TextFormField(
//                           controller: nameController,
//                           decoration: _dialogInputDecoration(
//                             'Item Name',
//                             Icons.inventory_2_outlined,
//                           ),
//                           validator: (value) {
//                             if (value == null ||
//                                 value.trim().isEmpty) {
//                               return 'Enter item name.';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // CATEGORY
//                         DropdownButtonFormField<String>(
//                           value: _categories.contains(
//                             selectedCategory,
//                           )
//                               ? selectedCategory
//                               : 'Other',

//                           decoration: _dialogInputDecoration(
//                             'Category',
//                             Icons.category_outlined,
//                           ),

//                           items: _categories
//                               .where((category) =>
//                                   category != 'All')
//                               .map((category) {
//                             return DropdownMenuItem<String>(
//                               value: category,
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     _getCategoryIcon(category),
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Text(category),
//                                 ],
//                               ),
//                             );
//                           }).toList(),

//                           onChanged: (value) {
//                             if (value != null) {
//                               setDialogState(() {
//                                 selectedCategory = value;
//                               });
//                             }
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // MATERIAL
//                         DropdownButtonFormField<String>(
//                           value: const [
//                             'Wooden',
//                             'Steel',
//                             'Plastic',
//                             'Metal',
//                             'Fabric',
//                             'Glass',
//                             'Aluminium',
//                             'Mixed',
//                             'Other',
//                           ].contains(selectedMaterial)
//                               ? selectedMaterial
//                               : 'Other',

//                           decoration: _dialogInputDecoration(
//                             'Material',
//                             Icons.layers_outlined,
//                           ),

//                           items: const [
//                             'Wooden',
//                             'Steel',
//                             'Plastic',
//                             'Metal',
//                             'Fabric',
//                             'Glass',
//                             'Aluminium',
//                             'Mixed',
//                             'Other',
//                           ].map((material) {
//                             return DropdownMenuItem<String>(
//                               value: material,
//                               child: Text(material),
//                             );
//                           }).toList(),

//                           onChanged: (value) {
//                             if (value != null) {
//                               setDialogState(() {
//                                 selectedMaterial = value;
//                               });
//                             }
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // STOCK
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: totalController,
//                                 keyboardType:
//                                     TextInputType.number,
//                                 onChanged: (_) {
//                                   setDialogState(() {});
//                                 },
//                                 decoration:
//                                     _dialogInputDecoration(
//                                   'Total Stock',
//                                   Icons.inventory_outlined,
//                                 ),
//                                 validator: (value) {
//                                   final number =
//                                       int.tryParse(
//                                     value?.trim() ?? '',
//                                   );

//                                   if (number == null) {
//                                     return 'Invalid';
//                                   }

//                                   if (number <= 0) {
//                                     return 'Must be > 0';
//                                   }

//                                   return null;
//                                 },
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             Expanded(
//                               child: TextFormField(
//                                 controller: rentedController,
//                                 keyboardType:
//                                     TextInputType.number,
//                                 onChanged: (_) {
//                                   setDialogState(() {});
//                                 },
//                                 decoration:
//                                     _dialogInputDecoration(
//                                   'Rented Stock',
//                                   Icons.assignment_return_outlined,
//                                 ),
//                                 validator: (value) {
//                                   final rented =
//                                       int.tryParse(
//                                     value?.trim() ?? '',
//                                   );

//                                   final total =
//                                       int.tryParse(
//                                     totalController.text.trim(),
//                                   );

//                                   if (rented == null) {
//                                     return 'Invalid';
//                                   }

//                                   if (rented < 0) {
//                                     return 'Invalid';
//                                   }

//                                   if (total != null &&
//                                       rented > total) {
//                                     return 'Too high';
//                                   }

//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // AVAILABLE
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withOpacity(0.07),
//                             borderRadius:
//                                 BorderRadius.circular(10),
//                             border: Border.all(
//                               color: Colors.green.withOpacity(0.2),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle_outline,
//                                 color: Colors.green,
//                               ),

//                               const SizedBox(width: 10),

//                               const Text(
//                                 'Available Stock',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),

//                               const Spacer(),

//                               Text(
//                                 available >= 0
//                                     ? available.toString()
//                                     : '0',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 14),

//                         // PRICE
//                         TextFormField(
//                           controller: priceController,
//                           keyboardType:
//                               const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           decoration: _dialogInputDecoration(
//                             'Rental Price / Unit',
//                             Icons.payments_outlined,
//                           ),
//                           validator: (value) {
//                             final price =
//                                 double.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (price == null) {
//                               return 'Invalid price';
//                             }

//                             if (price < 0) {
//                               return 'Invalid price';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // DESCRIPTION
//                         TextFormField(
//                           controller: descriptionController,
//                           maxLines: 3,
//                           decoration: _dialogInputDecoration(
//                             'Description',
//                             Icons.description_outlined,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               actions: [
//                 TextButton(
//                   onPressed: isSaving
//                       ? null
//                       : () {
//                           Navigator.pop(dialogContext);
//                         },
//                   child: const Text('Cancel'),
//                 ),

//                 ElevatedButton(
//                   onPressed: isSaving
//                       ? null
//                       : () async {
//                           if (!editFormKey.currentState!
//                               .validate()) {
//                             return;
//                           }

//                           final total =
//                               int.parse(
//                             totalController.text.trim(),
//                           );

//                           final rented =
//                               int.parse(
//                             rentedController.text.trim(),
//                           );

//                           if (rented > total) {
//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Rented stock cannot be greater than total stock.',
//                                 ),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );

//                             return;
//                           }

//                           setDialogState(() {
//                             isSaving = true;
//                           });

//                           try {
//                             await FirebaseFirestore
//                                 .instance
//                                 .collection('inventory')
//                                 .doc(documentId)
//                                 .update({
//                               'name':
//                                   nameController.text.trim(),

//                               'category':
//                                   selectedCategory,

//                               'material':
//                                   selectedMaterial,

//                               'totalStock':
//                                   total,

//                               'rentedStock':
//                                   rented,

//                               'availableStock':
//                                   total - rented,

//                               'rentPrice':
//                                   double.parse(
//                                 priceController.text.trim(),
//                               ),

//                               'description':
//                                   descriptionController
//                                       .text
//                                       .trim(),

//                               'updatedAt':
//                                   FieldValue
//                                       .serverTimestamp(),
//                             });

//                             if (!dialogContext.mounted) {
//                               return;
//                             }

//                             Navigator.pop(dialogContext);

//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Item updated successfully.',
//                                 ),
//                                 backgroundColor:
//                                     Colors.green,
//                               ),
//                             );
//                           } catch (e) {
//                             setDialogState(() {
//                               isSaving = false;
//                             });

//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Failed to update item.',
//                                 ),
//                                 backgroundColor:
//                                     Colors.red,
//                               ),
//                             );
//                           }
//                         },

//                   child: isSaving
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child:
//                               CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text('Save Changes'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     nameController.dispose();
//     totalController.dispose();
//     rentedController.dispose();
//     priceController.dispose();
//     descriptionController.dispose();
//   }

//   // ============================================================
//   // INVENTORY CARD
//   // ============================================================

//   Widget _inventoryCard(
//     QueryDocumentSnapshot<Map<String, dynamic>> document,
//   ) {
//     final data = document.data();

//     final String name =
//         data['name']?.toString() ?? 'Unnamed Item';

//     final String category =
//         data['category']?.toString() ?? 'Other';

//     final String material =
//         data['material']?.toString() ?? 'Unknown';

//     final int total =
//         (data['totalStock'] as num?)?.toInt() ?? 0;

//     final int rented =
//         (data['rentedStock'] as num?)?.toInt() ?? 0;

//     final int available =
//         (data['availableStock'] as num?)?.toInt() ??
//             (total - rented);

//     final double price =
//         (data['rentPrice'] as num?)?.toDouble() ?? 0;

//     final IconData icon =
//         _getCategoryIcon(category);

//     Color availabilityColor;

//     if (available <= 0) {
//       availabilityColor = Colors.red;
//     } else if (available <= total * 0.2) {
//       availabilityColor = Colors.orange;
//     } else {
//       availabilityColor = Colors.green;
//     }

//     return Card(
//       elevation: 0,

//       margin: const EdgeInsets.only(bottom: 12),

//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//         side: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),

//       child: Padding(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 18,
//           vertical: 16,
//         ),

//         child: Row(
//           children: [

//             // ========================================================
//             // ICON
//             // ========================================================

//             Container(
//               width: 64,
//               height: 64,

//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(14),
//               ),

//               child: Icon(
//                 icon,
//                 size: 34,
//                 color: Colors.blue,
//               ),
//             ),

//             const SizedBox(width: 18),

//             // ========================================================
//             // ITEM NAME + MATERIAL
//             // ========================================================

//             Expanded(
//               flex: 4,

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [

//                   Text(
//                     name,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,

//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 7),

//                   Row(
//                     children: [

//                       Container(
//                         padding:
//                             const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),

//                         decoration: BoxDecoration(
//                           color:
//                               Colors.blue.withOpacity(0.08),
//                           borderRadius:
//                               BorderRadius.circular(6),
//                         ),

//                         child: Text(
//                           category,
//                           style: const TextStyle(
//                             color: Colors.blue,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 8),

//                       Flexible(
//                         child: Text(
//                           'Material: $material',
//                           overflow:
//                               TextOverflow.ellipsis,

//                           style: TextStyle(
//                             color: Colors.grey.shade600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // ========================================================
//             // AVAILABLE
//             // ========================================================

//             Expanded(
//               flex: 2,

//               child: _stockInfo(
//                 title: 'Available',
//                 value: available.toString(),
//                 color: availabilityColor,
//                 icon: Icons.check_circle_outline,
//               ),
//             ),

//             // ========================================================
//             // RENTED
//             // ========================================================

//             Expanded(
//               flex: 2,

//               child: _stockInfo(
//                 title: 'Rented',
//                 value: rented.toString(),
//                 color: Colors.orange,
//                 icon: Icons.assignment_return_outlined,
//               ),
//             ),

//             // ========================================================
//             // TOTAL
//             // ========================================================

//             Expanded(
//               flex: 2,

//               child: _stockInfo(
//                 title: 'Total',
//                 value: total.toString(),
//                 color: Colors.blue,
//                 icon: Icons.inventory_2_outlined,
//               ),
//             ),

//             // ========================================================
//             // PRICE
//             // ========================================================

//             Expanded(
//               flex: 2,

//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,

//                 children: [

//                   Text(
//                     'Rent / Unit',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 12,
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     'Rs. ${price.toStringAsFixed(0)}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ========================================================
//             // ACTIONS
//             // ========================================================

//             PopupMenuButton<String>(
//               tooltip: 'Manage Item',

//               onSelected: (value) {
//                 if (value == 'edit') {
//                   _editItem(
//                     document.id,
//                     data,
//                   );
//                 }

//                 if (value == 'delete') {
//                   _deleteItem(
//                     document.id,
//                     name,
//                   );
//                 }
//               },

//               itemBuilder: (context) {
//                 return const [
//                   PopupMenuItem<String>(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.edit_outlined,
//                           size: 20,
//                         ),
//                         SizedBox(width: 10),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),

//                   PopupMenuItem<String>(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.delete_outline,
//                           size: 20,
//                           color: Colors.red,
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           'Delete',
//                           style: TextStyle(
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ];
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // STOCK INFO
//   // ============================================================

//   Widget _stockInfo({
//     required String title,
//     required String value,
//     required Color color,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,

//       children: [

//         Row(
//           children: [
//             Icon(
//               icon,
//               size: 16,
//               color: color,
//             ),

//             const SizedBox(width: 5),

//             Text(
//               title,
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 4),

//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _searchBar() {
//     return TextField(
//       controller: _searchController,

//       onChanged: _onSearchChanged,

//       textCapitalization:
//           TextCapitalization.words,

//       decoration: InputDecoration(
//         hintText:
//             'Search by name, category, material...',

//         prefixIcon: const Icon(
//           Icons.search,
//         ),

//         suffixIcon:
//             _searchController.text.isNotEmpty
//                 ? IconButton(
//                     onPressed: () {
//                       _searchController.clear();
//                       setState(() {});
//                     },
//                     icon: const Icon(
//                       Icons.clear,
//                     ),
//                   )
//                 : null,

//         filled: true,
//         fillColor: Colors.white,

//         border: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),

//         enabledBorder: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: Colors.grey.shade200,
//           ),
//         ),

//         focusedBorder: OutlineInputBorder(
//           borderRadius:
//               BorderRadius.circular(12),
//           borderSide: const BorderSide(
//             color: Colors.blue,
//             width: 2,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DIALOG INPUT
//   // ============================================================

//   InputDecoration _dialogInputDecoration(
//     String label,
//     IconData icon,
//   ) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),

//       filled: true,
//       fillColor: Colors.grey.shade50,

//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(10),
//         borderSide: BorderSide.none,
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(10),
//         borderSide: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           const Color(0xFFF5F7FA),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),

//           child: Column(
//             crossAxisAlignment:
//                 CrossAxisAlignment.start,

//             children: [

//               // ======================================================
//               // TOP HEADER
//               // ======================================================

//               Row(
//                 children: [

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: const [
//                         Text(
//                           'Inventory',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),

//                         SizedBox(height: 5),

//                         Text(
//                           'Manage all your rental items and stock.',
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ADD BUTTON
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const AddItemScreen(),
//                         ),
//                       );
//                     },

//                     icon: const Icon(
//                       Icons.add,
//                     ),

//                     label: const Text(
//                       'Add Item',
//                     ),

//                     style:
//                         ElevatedButton.styleFrom(
//                       backgroundColor:
//                           Colors.blue,
//                       foregroundColor:
//                           Colors.white,

//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 14,
//                       ),

//                       shape:
//                           RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // ======================================================
//               // SEARCH + FILTER
//               // ======================================================

//               Row(
//                 children: [

//                   Expanded(
//                     child: _searchBar(),
//                   ),

//                   const SizedBox(width: 12),

//                   Container(
//                     width: 210,

//                     padding:
//                         const EdgeInsets.symmetric(
//                       horizontal: 12,
//                     ),

//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius:
//                           BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.grey.shade200,
//                       ),
//                     ),

//                     child:
//                         DropdownButtonHideUnderline(
//                       child:
//                           DropdownButton<String>(
//                         value:
//                             _selectedCategory,

//                         isExpanded: true,

//                         icon: const Icon(
//                           Icons.filter_list,
//                         ),

//                         items: _categories
//                             .map((category) {
//                           return DropdownMenuItem<
//                               String>(
//                             value: category,

//                             child: Row(
//                               children: [
//                                 Icon(
//                                   category == 'All'
//                                       ? Icons
//                                           .inventory_2_outlined
//                                       : _getCategoryIcon(
//                                           category,
//                                         ),
//                                   size: 19,
//                                 ),

//                                 const SizedBox(
//                                   width: 9,
//                                 ),

//                                 Text(category),
//                               ],
//                             ),
//                           );
//                         }).toList(),

//                         onChanged: (value) {
//                           if (value == null) {
//                             return;
//                           }

//                           setState(() {
//                             _selectedCategory =
//                                 value;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // ======================================================
//               // INVENTORY LIST
//               // ======================================================

//               Expanded(
//                 child: StreamBuilder<
//                     QuerySnapshot<
//                         Map<String, dynamic>>>(
//                   stream: FirebaseFirestore
//                       .instance
//                       .collection('inventory')
//                       .orderBy(
//                         'createdAt',
//                         descending: true,
//                       )
//                       .snapshots(),

//                   builder: (
//                     context,
//                     snapshot,
//                   ) {

//                     // LOADING
//                     if (snapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return const Center(
//                         child:
//                             CircularProgressIndicator(),
//                       );
//                     }

//                     // ERROR
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment:
//                               MainAxisAlignment.center,

//                           children: [
//                             const Icon(
//                               Icons.error_outline,
//                               size: 50,
//                               color: Colors.red,
//                             ),

//                             const SizedBox(
//                               height: 12,
//                             ),

//                             const Text(
//                               'Unable to load inventory.',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(
//                               height: 6,
//                             ),

//                             Text(
//                               '${snapshot.error}',
//                               textAlign:
//                                   TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final allItems =
//                         snapshot.data?.docs ?? [];

//                     final filteredItems =
//                         _filterItems(
//                       allItems,
//                     );

//                     // NO ITEMS
//                     if (allItems.isEmpty) {
//                       return _emptyInventory(
//                         isSearchResult: false,
//                       );
//                     }

//                     // SEARCH HAS NO RESULTS
//                     if (filteredItems.isEmpty) {
//                       return _emptyInventory(
//                         isSearchResult: true,
//                       );
//                     }

//                     // =================================================
//                     // LIST
//                     // =================================================

//                     return Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [

//                         Text(
//                           '${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'}',
//                           style: TextStyle(
//                             color:
//                                 Colors.grey.shade600,
//                             fontSize: 13,
//                             fontWeight:
//                                 FontWeight.w500,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 10,
//                         ),

//                         Expanded(
//                           child: ListView.builder(
//                             itemCount:
//                                 filteredItems.length,

//                             itemBuilder:
//                                 (context, index) {
//                               return _inventoryCard(
//                                 filteredItems[index],
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _emptyInventory({
//     required bool isSearchResult,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment:
//             MainAxisAlignment.center,

//         children: [

//           Container(
//             width: 80,
//             height: 80,

//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.08),
//               shape: BoxShape.circle,
//             ),

//             child: Icon(
//               isSearchResult
//                   ? Icons.search_off
//                   : Icons.inventory_2_outlined,
//               size: 40,
//               color: Colors.blue,
//             ),
//           ),

//           const SizedBox(height: 18),

//           Text(
//             isSearchResult
//                 ? 'No items found'
//                 : 'No inventory items yet',

//             style: const TextStyle(
//               fontSize: 19,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 7),

//           Text(
//             isSearchResult
//                 ? 'Try another search or category.'
//                 : 'Start by adding your first inventory item.',

//             style: const TextStyle(
//               color: Colors.grey,
//             ),
//           ),

//           if (!isSearchResult) ...[
//             const SizedBox(height: 18),

//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         const AddItemScreen(),
//                   ),
//                 );
//               },

//               icon: const Icon(Icons.add),

//               label: const Text(
//                 'Add First Item',
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';

// import 'add_item.dart';



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/drawer.dart';

// import 'add_item.dart';

// class InventoryScreen extends StatefulWidget {
//   const InventoryScreen({super.key});

//   @override
//   State<InventoryScreen> createState() => _InventoryScreenState();
// }

// class _InventoryScreenState extends State<InventoryScreen> {
//   CollectionReference<Map<String, dynamic>> get _inventoryCollection {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       throw Exception('No user is currently logged in.');
//     }

//     return FirebaseFirestore.instance
//         .collection('Users')
//         .doc(user.uid)
//         .collection('inventory');
//   }

//   final TextEditingController _searchController = TextEditingController();

//   String _selectedCategory = 'All';

//   // ============================================================
//   // THEME COLORS
//   // ============================================================

//   static const Color primaryRed = Color(0xFFE62E2E);
//   static const Color black = Color(0xFF111111);
//   static const Color darkText = Color(0xFF1A1A1A);
//   static const Color greyText = Color(0xFF777777);
//   static const Color lightGrey = Color(0xFFF5F5F5);
//   static const Color borderGrey = Color(0xFFE8E8E8);
//   static const Color white = Colors.white;

  

//   final List<String> _categories = [
//     'All',
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
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
//   // SEARCH VALIDATION
//   // ============================================================

//   void _onSearchChanged(String value) {
//     // Numbers are not allowed in search.
//     final cleanedValue = value.replaceAll(RegExp(r'[0-9]'), '');

//     if (cleanedValue != value) {
//       _searchController.value = TextEditingValue(
//         text: cleanedValue,
//         selection: TextSelection.collapsed(offset: cleanedValue.length),
//       );
//     }

//     setState(() {});
//   }

//   // ============================================================
//   // FILTER ITEMS
//   // ============================================================

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterItems(
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
//   ) {
//     final search = _searchController.text.trim().toLowerCase();

//     return items.where((document) {
//       final data = document.data();

//       final name = (data['name'] ?? '').toString().toLowerCase();

//       final category = (data['category'] ?? '').toString().toLowerCase();

//       final material = (data['material'] ?? '').toString().toLowerCase();

//       final description = (data['description'] ?? '').toString().toLowerCase();

//       final matchesSearch =
//           search.isEmpty ||
//           name.contains(search) ||
//           category.contains(search) ||
//           material.contains(search) ||
//           description.contains(search);

//       final matchesCategory =
//           _selectedCategory == 'All' || data['category'] == _selectedCategory;

//       return matchesSearch && matchesCategory;
//     }).toList();
//   }

//   // ============================================================
//   // DELETE ITEM
//   // ============================================================

//   Future<void> _deleteItem(String documentId, String itemName) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Text(
//             'Delete Item',
//             style: TextStyle(color: black, fontWeight: FontWeight.w700),
//           ),
//           content: Text(
//             'Are you sure you want to delete "$itemName"?',
//             style: const TextStyle(color: greyText, height: 1.4),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               style: TextButton.styleFrom(foregroundColor: black),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryRed,
//                 foregroundColor: white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     try {
//       // await FirebaseFirestore.instance
//       //     .collection('inventory')
//       //     .doc(documentId)
//       //     .delete();

//       await _inventoryCollection.doc(documentId).delete();

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item deleted successfully.'),
//           backgroundColor: primaryRed,
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to delete item.'),
//           backgroundColor: primaryRed,
//         ),
//       );
//     }
//   }

//   // ============================================================
//   // EDIT ITEM
//   // ============================================================

//   Future<void> _editItem(String documentId, Map<String, dynamic> data) async {
//     final nameController = TextEditingController(
//       text: data['name']?.toString() ?? '',
//     );

//     final totalController = TextEditingController(
//       text: data['totalStock']?.toString() ?? '0',
//     );

//     final rentedController = TextEditingController(
//       text: data['rentedStock']?.toString() ?? '0',
//     );

//     final priceController = TextEditingController(
//       text: data['rentPrice']?.toString() ?? '0',
//     );

//     final descriptionController = TextEditingController(
//       text: data['description']?.toString() ?? '',
//     );

//     String selectedCategory = data['category']?.toString() ?? 'Other';

//     String selectedMaterial = data['material']?.toString() ?? 'Other';

//     final editFormKey = GlobalKey<FormState>();

//     bool isSaving = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             final total = int.tryParse(totalController.text.trim()) ?? 0;

//             final rented = int.tryParse(rentedController.text.trim()) ?? 0;

//             final available = total - rented;

//             return AlertDialog(
//               backgroundColor: white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),

//               title: const Text(
//                 'Edit Inventory Item',
//                 style: TextStyle(
//                   color: black,
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),

//               content: SizedBox(
//                 width: 600,

//                 child: SingleChildScrollView(
//                   child: Form(
//                     key: editFormKey,

//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // NAME
//                         TextFormField(
//                           controller: nameController,
//                           decoration: _dialogInputDecoration(
//                             'Item Name',
//                             Icons.inventory_2_outlined,
//                           ),
//                           validator: (value) {
//                             if (value == null || value.trim().isEmpty) {
//                               return 'Enter item name.';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // CATEGORY
//                         DropdownButtonFormField<String>(
//                           value: _categories.contains(selectedCategory)
//                               ? selectedCategory
//                               : 'Other',

//                           decoration: _dialogInputDecoration(
//                             'Category',
//                             Icons.category_outlined,
//                           ),

//                           dropdownColor: white,

//                           items: _categories
//                               .where((category) => category != 'All')
//                               .map((category) {
//                                 return DropdownMenuItem<String>(
//                                   value: category,
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         _getCategoryIcon(category),
//                                         size: 20,
//                                         color: primaryRed,
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Text(
//                                         category,
//                                         style: const TextStyle(color: black),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               })
//                               .toList(),

//                           onChanged: (value) {
//                             if (value != null) {
//                               setDialogState(() {
//                                 selectedCategory = value;
//                               });
//                             }
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // MATERIAL
//                         DropdownButtonFormField<String>(
//                           value:
//                               const [
//                                 'Wooden',
//                                 'Steel',
//                                 'Plastic',
//                                 'Metal',
//                                 'Fabric',
//                                 'Glass',
//                                 'Aluminium',
//                                 'Mixed',
//                                 'Other',
//                               ].contains(selectedMaterial)
//                               ? selectedMaterial
//                               : 'Other',

//                           decoration: _dialogInputDecoration(
//                             'Material',
//                             Icons.layers_outlined,
//                           ),

//                           dropdownColor: white,

//                           items:
//                               const [
//                                 'Wooden',
//                                 'Steel',
//                                 'Plastic',
//                                 'Metal',
//                                 'Fabric',
//                                 'Glass',
//                                 'Aluminium',
//                                 'Mixed',
//                                 'Other',
//                               ].map((material) {
//                                 return DropdownMenuItem<String>(
//                                   value: material,
//                                   child: Text(
//                                     material,
//                                     style: TextStyle(color: black),
//                                   ),
//                                 );
//                               }).toList(),

//                           onChanged: (value) {
//                             if (value != null) {
//                               setDialogState(() {
//                                 selectedMaterial = value;
//                               });
//                             }
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // STOCK
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 controller: totalController,
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) {
//                                   setDialogState(() {});
//                                 },
//                                 decoration: _dialogInputDecoration(
//                                   'Total Stock',
//                                   Icons.inventory_outlined,
//                                 ),
//                                 validator: (value) {
//                                   final number = int.tryParse(
//                                     value?.trim() ?? '',
//                                   );

//                                   if (number == null) {
//                                     return 'Invalid';
//                                   }

//                                   if (number <= 0) {
//                                     return 'Must be > 0';
//                                   }

//                                   return null;
//                                 },
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             Expanded(
//                               child: TextFormField(
//                                 controller: rentedController,
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) {
//                                   setDialogState(() {});
//                                 },
//                                 decoration: _dialogInputDecoration(
//                                   'Rented Stock',
//                                   Icons.assignment_return_outlined,
//                                 ),
//                                 validator: (value) {
//                                   final rented = int.tryParse(
//                                     value?.trim() ?? '',
//                                   );

//                                   final total = int.tryParse(
//                                     totalController.text.trim(),
//                                   );

//                                   if (rented == null) {
//                                     return 'Invalid';
//                                   }

//                                   if (rented < 0) {
//                                     return 'Invalid';
//                                   }

//                                   if (total != null && rented > total) {
//                                     return 'Too high';
//                                   }

//                                   return null;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 12),

//                         // AVAILABLE
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: primaryRed.withOpacity(0.06),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: primaryRed.withOpacity(0.15),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle_outline_rounded,
//                                 color: primaryRed,
//                               ),

//                               const SizedBox(width: 10),

//                               const Text(
//                                 'Available Stock',
//                                 style: TextStyle(
//                                   color: black,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),

//                               const Spacer(),

//                               Text(
//                                 available >= 0 ? available.toString() : '0',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w800,
//                                   color: primaryRed,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 14),

//                         // PRICE
//                         TextFormField(
//                           controller: priceController,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           decoration: _dialogInputDecoration(
//                             'Rental Price / Unit',
//                             Icons.payments_outlined,
//                           ),
//                           validator: (value) {
//                             final price = double.tryParse(value?.trim() ?? '');

//                             if (price == null) {
//                               return 'Invalid price';
//                             }

//                             if (price < 0) {
//                               return 'Invalid price';
//                             }

//                             return null;
//                           },
//                         ),

//                         const SizedBox(height: 14),

//                         // DESCRIPTION
//                         TextFormField(
//                           controller: descriptionController,
//                           maxLines: 3,
//                           decoration: _dialogInputDecoration(
//                             'Description',
//                             Icons.description_outlined,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               actions: [
//                 TextButton(
//                   onPressed: isSaving
//                       ? null
//                       : () {
//                           Navigator.pop(dialogContext);
//                         },
//                   style: TextButton.styleFrom(foregroundColor: black),
//                   child: const Text('Cancel'),
//                 ),

//                 ElevatedButton(
//                   onPressed: isSaving
//                       ? null
//                       : () async {
//                           if (!editFormKey.currentState!.validate()) {
//                             return;
//                           }

//                           final total = int.parse(totalController.text.trim());

//                           final rented = int.parse(
//                             rentedController.text.trim(),
//                           );

//                           if (rented > total) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'Rented stock cannot be greater than total stock.',
//                                 ),
//                                 backgroundColor: primaryRed,
//                               ),
//                             );

//                             return;
//                           }

//                           setDialogState(() {
//                             isSaving = true;
//                           });

//                           try {
//                             await _inventoryCollection.doc(documentId).update({
//                               'name': nameController.text.trim(),

//                               'category': selectedCategory,

//                               'material': selectedMaterial,

//                               'totalStock': total,

//                               'rentedStock': rented,

//                               'availableStock': total - rented,

//                               'rentPrice': double.parse(
//                                 priceController.text.trim(),
//                               ),

//                               'description': descriptionController.text.trim(),

//                               'updatedAt': FieldValue.serverTimestamp(),
//                             });

//                             if (!dialogContext.mounted) {
//                               return;
//                             }

//                             Navigator.pop(dialogContext);

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Item updated successfully.'),
//                                 backgroundColor: primaryRed,
//                               ),
//                             );
//                           } catch (e) {
//                             setDialogState(() {
//                               isSaving = false;
//                             });

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Failed to update item.'),
//                                 backgroundColor: primaryRed,
//                               ),
//                             );
//                           }
//                         },

//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryRed,
//                     foregroundColor: white,
//                     elevation: 0,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 13,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),

//                   child: isSaving
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: white,
//                           ),
//                         )
//                       : const Text('Save Changes'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     nameController.dispose();
//     totalController.dispose();
//     rentedController.dispose();
//     priceController.dispose();
//     descriptionController.dispose();
//   }

//   // ============================================================
//   // INVENTORY CARD
//   // ============================================================

//   Widget _inventoryCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
//     final data = document.data();

//     final String name = data['name']?.toString() ?? 'Unnamed Item';

//     final String category = data['category']?.toString() ?? 'Other';

//     final String material = data['material']?.toString() ?? 'Unknown';

//     final int total = (data['totalStock'] as num?)?.toInt() ?? 0;

//     final int rented = (data['rentedStock'] as num?)?.toInt() ?? 0;

//     final int available =
//         (data['availableStock'] as num?)?.toInt() ?? (total - rented);

//     final double price = (data['rentPrice'] as num?)?.toDouble() ?? 0;

//     final IconData icon = _getCategoryIcon(category);

//     return Card(
//       elevation: 0,
//       margin: const EdgeInsets.only(bottom: 12),
//       color: white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: const BorderSide(color: borderGrey),
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // ========================================================
//           // MOBILE CARD
//           // ========================================================

//           if (constraints.maxWidth < 700) {
//             return _mobileInventoryCard(
//               document: document,
//               data: data,
//               name: name,
//               category: category,
//               material: material,
//               total: total,
//               rented: rented,
//               available: available,
//               price: price,
//               icon: icon,
//             );
//           }

//           // ========================================================
//           // DESKTOP / TABLET CARD
//           // ========================================================

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//             child: Row(
//               children: [
//                 // ICON
//                 Container(
//                   width: 62,
//                   height: 62,
//                   decoration: BoxDecoration(
//                     color: primaryRed.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Icon(icon, size: 32, color: primaryRed),
//                 ),

//                 const SizedBox(width: 17),

//                 // NAME + CATEGORY
//                 Expanded(
//                   flex: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),

//                       const SizedBox(height: 7),

//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 9,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: primaryRed.withOpacity(0.08),
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                             child: Text(
//                               category,
//                               style: const TextStyle(
//                                 color: primaryRed,
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),

//                           const SizedBox(width: 8),

//                           Flexible(
//                             child: Text(
//                               'Material: $material',
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: greyText,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // AVAILABLE
//                 Expanded(
//                   flex: 2,
//                   child: _stockInfo(
//                     title: 'Available',
//                     value: available.toString(),
//                     icon: Icons.check_circle_outline_rounded,
//                   ),
//                 ),

//                 // RENTED
//                 Expanded(
//                   flex: 2,
//                   child: _stockInfo(
//                     title: 'Rented',
//                     value: rented.toString(),
//                     icon: Icons.assignment_return_outlined,
//                   ),
//                 ),

//                 // TOTAL
//                 Expanded(
//                   flex: 2,
//                   child: _stockInfo(
//                     title: 'Total',
//                     value: total.toString(),
//                     icon: Icons.inventory_2_outlined,
//                   ),
//                 ),

//                 // PRICE
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Rent / Unit',
//                         style: TextStyle(color: greyText, fontSize: 11),
//                       ),

//                       const SizedBox(height: 4),

//                       Text(
//                         'Rs. ${price.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           color: black,
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // ACTIONS
//                 _actionMenu(document: document, data: data, name: name),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ============================================================
//   // MOBILE INVENTORY CARD
//   // ============================================================

//   Widget _mobileInventoryCard({
//     required QueryDocumentSnapshot<Map<String, dynamic>> document,
//     required Map<String, dynamic> data,
//     required String name,
//     required String category,
//     required String material,
//     required int total,
//     required int rented,
//     required int available,
//     required double price,
//     required IconData icon,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.all(15),
//       child: Column(
//         children: [
//           // TOP
//           Row(
//             children: [
//               Container(
//                 width: 55,
//                 height: 55,
//                 decoration: BoxDecoration(
//                   color: primaryRed.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 child: Icon(icon, size: 29, color: primaryRed),
//               ),

//               const SizedBox(width: 13),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         color: black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),

//                     const SizedBox(height: 5),

//                     Row(
//                       children: [
//                         Flexible(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: primaryRed.withOpacity(0.08),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               category,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                 color: primaryRed,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 7),

//                         Flexible(
//                           child: Text(
//                             material,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               color: greyText,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               _actionMenu(document: document, data: data, name: name),
//             ],
//           ),

//           const SizedBox(height: 15),

//           const Divider(color: borderGrey, height: 1),

//           const SizedBox(height: 14),

//           // STOCK INFORMATION
//           Row(
//             children: [
//               Expanded(
//                 child: _mobileStockBox(
//                   title: 'Available',
//                   value: available.toString(),
//                   icon: Icons.check_circle_outline_rounded,
//                 ),
//               ),

//               const SizedBox(width: 8),

//               Expanded(
//                 child: _mobileStockBox(
//                   title: 'Rented',
//                   value: rented.toString(),
//                   icon: Icons.assignment_return_outlined,
//                 ),
//               ),

//               const SizedBox(width: 8),

//               Expanded(
//                 child: _mobileStockBox(
//                   title: 'Total',
//                   value: total.toString(),
//                   icon: Icons.inventory_2_outlined,
//                 ),
//               ),

//               const SizedBox(width: 8),

//               Expanded(
//                 child: _mobileStockBox(
//                   title: 'Rent',
//                   value: 'Rs. ${price.toStringAsFixed(0)}',
//                   icon: Icons.payments_outlined,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // MOBILE STOCK BOX
//   // ============================================================

//   Widget _mobileStockBox({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
//       decoration: BoxDecoration(
//         color: lightGrey,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: primaryRed, size: 17),

//           const SizedBox(height: 4),

//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: greyText,
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//             ),
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: black,
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // STOCK INFO
//   // ============================================================

//   Widget _stockInfo({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 16, color: primaryRed),

//             const SizedBox(width: 5),

//             Text(title, style: const TextStyle(color: greyText, fontSize: 11)),
//           ],
//         ),

//         const SizedBox(height: 4),

//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w800,
//             color: black,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // ACTION MENU
//   // ============================================================

//   Widget _actionMenu({
//     required QueryDocumentSnapshot<Map<String, dynamic>> document,
//     required Map<String, dynamic> data,
//     required String name,
//   }) {
//     return PopupMenuButton<String>(
//       tooltip: 'Manage Item',

//       icon: const Icon(Icons.more_vert_rounded, color: black),

//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

//       onSelected: (value) {
//         if (value == 'edit') {
//           _editItem(document.id, data);
//         }

//         if (value == 'delete') {
//           _deleteItem(document.id, name);
//         }
//       },

//       itemBuilder: (context) {
//         return const [
//           PopupMenuItem<String>(
//             value: 'edit',
//             child: Row(
//               children: [
//                 Icon(Icons.edit_outlined, size: 20, color: black),
//                 SizedBox(width: 10),
//                 Text('Edit', style: TextStyle(color: black)),
//               ],
//             ),
//           ),

//           PopupMenuItem<String>(
//             value: 'delete',
//             child: Row(
//               children: [
//                 Icon(Icons.delete_outline, size: 20, color: primaryRed),
//                 SizedBox(width: 10),
//                 Text('Delete', style: TextStyle(color: primaryRed)),
//               ],
//             ),
//           ),
//         ];
//       },
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _searchBar() {
//     return TextField(
//       controller: _searchController,

//       onChanged: _onSearchChanged,

//       textCapitalization: TextCapitalization.words,

//       style: const TextStyle(color: black, fontSize: 14),

//       decoration: InputDecoration(
//         hintText: 'Search by name, category, material...',

//         hintStyle: const TextStyle(color: greyText, fontSize: 13),

//         prefixIcon: const Icon(Icons.search_rounded, color: black, size: 21),

//         suffixIcon: _searchController.text.isNotEmpty
//             ? IconButton(
//                 onPressed: () {
//                   _searchController.clear();
//                   setState(() {});
//                 },
//                 icon: const Icon(Icons.clear_rounded, color: black),
//               )
//             : null,

//         filled: true,
//         fillColor: white,

//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 15,
//           vertical: 16,
//         ),

//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(13),
//           borderSide: BorderSide(color: borderGrey),
//         ),

//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(13),
//           borderSide: const BorderSide(color: borderGrey),
//         ),

//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(13),
//           borderSide: const BorderSide(color: primaryRed, width: 1.5),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _categoryFilter() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 13),
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(color: borderGrey),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedCategory,
//           isExpanded: true,

//           icon: const Icon(Icons.keyboard_arrow_down_rounded, color: black),

//           dropdownColor: white,

//           items: _categories.map((category) {
//             return DropdownMenuItem<String>(
//               value: category,

//               child: Row(
//                 children: [
//                   Icon(
//                     category == 'All'
//                         ? Icons.inventory_2_outlined
//                         : _getCategoryIcon(category),
//                     size: 19,
//                     color: black,
//                   ),

//                   const SizedBox(width: 9),

//                   Expanded(
//                     child: Text(
//                       category,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(color: black, fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),

//           onChanged: (value) {
//             if (value == null) {
//               return;
//             }

//             setState(() {
//               _selectedCategory = value;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DIALOG INPUT
//   // ============================================================

//   InputDecoration _dialogInputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,

//       labelStyle: const TextStyle(color: greyText),

//       prefixIcon: Icon(icon, color: black),

//       filled: true,
//       fillColor: lightGrey,

//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(11),
//         borderSide: BorderSide.none,
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(11),
//         borderSide: const BorderSide(color: borderGrey),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(11),
//         borderSide: const BorderSide(color: primaryRed, width: 1.5),
//       ),
//     );
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       backgroundColor: white,

//       // drawer: AdminDrawer(selectedIndex: 1),
//       drawer: const AdminDrawer(selectedIndex: 1),

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,

//             children: [
//               // ======================================================
//               // TOP HEADER
//               // ======================================================
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final isMobile = constraints.maxWidth < 600;

//                   if (isMobile) {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Inventory',
//                                     style: TextStyle(
//                                       color: black,
//                                       fontSize: 27,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),

//                                   SizedBox(height: 5),

//                                   Text(
//                                     'Manage your rental items and stock.',
//                                     style: TextStyle(
//                                       color: greyText,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(width: 10),

//                             _addItemButton(compact: true),
//                           ],
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Inventory',
//                               style: TextStyle(
//                                 color: black,
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),

//                             SizedBox(height: 5),

//                             Text(
//                               'Manage all your rental items and stock.',
//                               style: TextStyle(color: greyText, fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ),

//                       _addItemButton(),
//                     ],
//                   );
//                 },
//               ),

//               const SizedBox(height: 24),

//               // ======================================================
//               // SEARCH + FILTER
//               // ======================================================
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final isMobile = constraints.maxWidth < 650;

//                   if (isMobile) {
//                     return Column(
//                       children: [
//                         _searchBar(),

//                         const SizedBox(height: 10),

//                         SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: _categoryFilter(),
//                         ),
//                       ],
//                     );
//                   }

//                   return Row(
//                     children: [
//                       Expanded(child: _searchBar()),

//                       const SizedBox(width: 12),

//                       SizedBox(
//                         width: 210,
//                         height: 52,
//                         child: _categoryFilter(),
//                       ),
//                     ],
//                   );
//                 },
//               ),

//               const SizedBox(height: 20),

//               // ======================================================
//               // INVENTORY LIST
//               // ======================================================
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                   stream: _inventoryCollection
//                       .orderBy('createdAt', descending: true)
//                       .snapshots(),

//                   builder: (context, snapshot) {
//                     // LOADING
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(
//                         child: CircularProgressIndicator(color: primaryRed),
//                       );
//                     }

//                     // ERROR
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               width: 70,
//                               height: 70,
//                               decoration: BoxDecoration(
//                                 color: primaryRed.withOpacity(0.08),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.error_outline,
//                                 size: 35,
//                                 color: primaryRed,
//                               ),
//                             ),

//                             const SizedBox(height: 14),

//                             const Text(
//                               'Unable to load inventory.',
//                               style: TextStyle(
//                                 color: black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),

//                             const SizedBox(height: 6),

//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                               ),
//                               child: Text(
//                                 '${snapshot.error}',
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(color: greyText),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }

//                     final allItems = snapshot.data?.docs ?? [];

//                     final filteredItems = _filterItems(allItems);

//                     // NO ITEMS
//                     if (allItems.isEmpty) {
//                       return _emptyInventory(isSearchResult: false);
//                     }

//                     // SEARCH HAS NO RESULTS
//                     if (filteredItems.isEmpty) {
//                       return _emptyInventory(isSearchResult: true);
//                     }

//                     // =================================================
//                     // LIST
//                     // =================================================

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 7,
//                               height: 7,
//                               decoration: const BoxDecoration(
//                                 color: primaryRed,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),

//                             const SizedBox(width: 8),

//                             Text(
//                               '${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'}',
//                               style: const TextStyle(
//                                 color: greyText,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 10),

//                         Expanded(
//                           child: ListView.builder(
//                             physics: const BouncingScrollPhysics(),

//                             itemCount: filteredItems.length,

//                             itemBuilder: (context, index) {
//                               return _inventoryCard(filteredItems[index]);
//                             },
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // ADD ITEM BUTTON
//   // ============================================================

//   Widget _addItemButton({bool compact = false}) {
//     return ElevatedButton.icon(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const AddItemScreen()),
//         );
//       },

//       icon: Icon(Icons.add_rounded, size: compact ? 19 : 20),

//       label: compact ? const Text('Add') : const Text('Add Item'),

//       style: ElevatedButton.styleFrom(
//         backgroundColor: primaryRed,
//         foregroundColor: white,
//         elevation: 0,

//         padding: EdgeInsets.symmetric(
//           horizontal: compact ? 13 : 20,
//           vertical: compact ? 12 : 14,
//         ),

//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _emptyInventory({required bool isSearchResult}) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,

//           children: [
//             Container(
//               width: 82,
//               height: 82,
//               decoration: BoxDecoration(
//                 color: primaryRed.withOpacity(0.08),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isSearchResult
//                     ? Icons.search_off_rounded
//                     : Icons.inventory_2_outlined,
//                 size: 39,
//                 color: primaryRed,
//               ),
//             ),

//             const SizedBox(height: 18),

//             Text(
//               isSearchResult ? 'No items found' : 'No inventory items yet',
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: black,
//                 fontSize: 19,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),

//             const SizedBox(height: 7),

//             Text(
//               isSearchResult
//                   ? 'Try another search or category.'
//                   : 'Start by adding your first inventory item.',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: greyText, fontSize: 13),
//             ),

//             if (!isSearchResult) ...[
//               const SizedBox(height: 18),

//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const AddItemScreen(),
//                     ),
//                   );
//                 },

//                 icon: const Icon(Icons.add_rounded, size: 20),

//                 label: const Text('Add First Item'),

//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryRed,
//                   foregroundColor: white,
//                   elevation: 0,

//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 13,
//                   ),

//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(11),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/drawer.dart';

import 'add_item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  CollectionReference<Map<String, dynamic>> get _inventoryCollection {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('inventory');
  }

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';

  // ============================================================
  // PREMIUM BEIGE + BRONZE THEME
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

  final List<String> _categories = [
    'All',
    'Furniture',
    'Decoration',
    'Tent',
    'Lighting',
    'Sound Equipment',
    'Stage Equipment',
    'Catering',
    'Other',
  ];

  final List<String> _materials = [
    'Wooden',
    'Steel',
    'Plastic',
    'Metal',
    'Fabric',
    'Glass',
    'Aluminium',
    'Mixed',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(String category) {
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
  // SEARCH
  // ============================================================

  void _onSearchChanged(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'[0-9]'), '');

    if (cleanedValue != value) {
      _searchController.value = TextEditingValue(
        text: cleanedValue,
        selection: TextSelection.collapsed(
          offset: cleanedValue.length,
        ),
      );
    }

    setState(() {});
  }

  // ============================================================
  // FILTER ITEMS
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterItems(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> items,
  ) {
    final search = _searchController.text.trim().toLowerCase();

    return items.where((document) {
      final data = document.data();

      final name = (data['name'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? '').toString().toLowerCase();
      final material = (data['material'] ?? '').toString().toLowerCase();
      final description =
          (data['description'] ?? '').toString().toLowerCase();

      final matchesSearch =
          search.isEmpty ||
          name.contains(search) ||
          category.contains(search) ||
          material.contains(search) ||
          description.contains(search);

      final matchesCategory =
          _selectedCategory == 'All' ||
          data['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ============================================================
  // DELETE ITEM
  // ============================================================

  Future<void> _deleteItem(
    String documentId,
    String itemName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: bronzeDark,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Delete Item',
                  style: TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "$itemName"?',
            style: const TextStyle(
              color: mutedText,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: TextButton.styleFrom(
                foregroundColor: mediumBrown,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bronzeDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _inventoryCollection.doc(documentId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted successfully.'),
          backgroundColor: bronzeDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to delete item.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDIT ITEM
  // ============================================================

  Future<void> _editItem(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    final nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    final totalController = TextEditingController(
      text: data['totalStock']?.toString() ?? '0',
    );

    final rentedController = TextEditingController(
      text: data['rentedStock']?.toString() ?? '0',
    );

    final priceController = TextEditingController(
      text: data['rentPrice']?.toString() ?? '0',
    );

    final descriptionController = TextEditingController(
      text: data['description']?.toString() ?? '',
    );

    String selectedCategory =
        data['category']?.toString() ?? 'Other';

    String selectedMaterial =
        data['material']?.toString() ?? 'Other';

    final editFormKey = GlobalKey<FormState>();

    bool isSaving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final total =
                int.tryParse(totalController.text.trim()) ?? 0;

            final rented =
                int.tryParse(rentedController.text.trim()) ?? 0;

            final available = total - rented;

            return AlertDialog(
              backgroundColor: surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                10,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                8,
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: bronze,
                    size: 23,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Edit Inventory Item',
                      style: TextStyle(
                        color: darkBrown,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 620,
                child: SingleChildScrollView(
                  child: Form(
                    key: editFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: _dialogInputDecoration(
                            'Item Name',
                            Icons.inventory_2_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter item name.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 450) {
                              return Column(
                                children: [
                                  _categoryDropdown(
                                    selectedCategory,
                                    (value) {
                                      setDialogState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  _materialDropdown(
                                    selectedMaterial,
                                    (value) {
                                      setDialogState(() {
                                        selectedMaterial = value;
                                      });
                                    },
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: _categoryDropdown(
                                    selectedCategory,
                                    (value) {
                                      setDialogState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _materialDropdown(
                                    selectedMaterial,
                                    (value) {
                                      setDialogState(() {
                                        selectedMaterial = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 450) {
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: totalController,
                                    keyboardType:
                                        TextInputType.number,
                                    onChanged: (_) {
                                      setDialogState(() {});
                                    },
                                    decoration:
                                        _dialogInputDecoration(
                                      'Total Stock',
                                      Icons.inventory_outlined,
                                    ),
                                    validator: (value) {
                                      final number =
                                          int.tryParse(
                                        value?.trim() ?? '',
                                      );

                                      if (number == null) {
                                        return 'Invalid';
                                      }

                                      if (number <= 0) {
                                        return 'Must be > 0';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: rentedController,
                                    keyboardType:
                                        TextInputType.number,
                                    onChanged: (_) {
                                      setDialogState(() {});
                                    },
                                    decoration:
                                        _dialogInputDecoration(
                                      'Rented Stock',
                                      Icons.assignment_return_outlined,
                                    ),
                                    validator: (value) {
                                      final rented =
                                          int.tryParse(
                                        value?.trim() ?? '',
                                      );

                                      final total =
                                          int.tryParse(
                                        totalController.text.trim(),
                                      );

                                      if (rented == null) {
                                        return 'Invalid';
                                      }

                                      if (rented < 0) {
                                        return 'Invalid';
                                      }

                                      if (total != null &&
                                          rented > total) {
                                        return 'Too high';
                                      }

                                      return null;
                                    },
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: totalController,
                                    keyboardType:
                                        TextInputType.number,
                                    onChanged: (_) {
                                      setDialogState(() {});
                                    },
                                    decoration:
                                        _dialogInputDecoration(
                                      'Total Stock',
                                      Icons.inventory_outlined,
                                    ),
                                    validator: (value) {
                                      final number =
                                          int.tryParse(
                                        value?.trim() ?? '',
                                      );

                                      if (number == null) {
                                        return 'Invalid';
                                      }

                                      if (number <= 0) {
                                        return 'Must be > 0';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: rentedController,
                                    keyboardType:
                                        TextInputType.number,
                                    onChanged: (_) {
                                      setDialogState(() {});
                                    },
                                    decoration:
                                        _dialogInputDecoration(
                                      'Rented Stock',
                                      Icons.assignment_return_outlined,
                                    ),
                                    validator: (value) {
                                      final rented =
                                          int.tryParse(
                                        value?.trim() ?? '',
                                      );

                                      final total =
                                          int.tryParse(
                                        totalController.text.trim(),
                                      );

                                      if (rented == null) {
                                        return 'Invalid';
                                      }

                                      if (rented < 0) {
                                        return 'Invalid';
                                      }

                                      if (total != null &&
                                          rented > total) {
                                        return 'Too high';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: bronzeLight.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: bronzeLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: bronze.withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: bronzeDark,
                                  size: 21,
                                ),
                              ),
                              const SizedBox(width: 11),
                              const Expanded(
                                child: Text(
                                  'Available Stock',
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                available >= 0
                                    ? available.toString()
                                    : '0',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: bronzeDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _dialogInputDecoration(
                            'Rental Price / Unit',
                            Icons.payments_outlined,
                          ),
                          validator: (value) {
                            final price =
                                double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (price == null) {
                              return 'Invalid price';
                            }

                            if (price < 0) {
                              return 'Invalid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: _dialogInputDecoration(
                            'Description',
                            Icons.description_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                20,
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: mediumBrown,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!editFormKey.currentState!
                              .validate()) {
                            return;
                          }

                          final total =
                              int.parse(
                            totalController.text.trim(),
                          );

                          final rented =
                              int.parse(
                            rentedController.text.trim(),
                          );

                          if (rented > total) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Rented stock cannot be greater than total stock.',
                                ),
                                backgroundColor: bronzeDark,
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            await _inventoryCollection
                                .doc(documentId)
                                .update({
                              'name':
                                  nameController.text.trim(),
                              'category': selectedCategory,
                              'material': selectedMaterial,
                              'totalStock': total,
                              'rentedStock': rented,
                              'availableStock': total - rented,
                              'rentPrice': double.parse(
                                priceController.text.trim(),
                              ),
                              'description':
                                  descriptionController.text.trim(),
                              'updatedAt':
                                  FieldValue.serverTimestamp(),
                            });

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Item updated successfully.',
                                ),
                                backgroundColor: bronzeDark,
                                behavior:
                                    SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Failed to update item.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bronzeDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    totalController.dispose();
    rentedController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }

  // ============================================================
  // CATEGORY DROPDOWN
  // ============================================================

  Widget _categoryDropdown(
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: _categories.contains(selected)
          ? selected
          : 'Other',
      decoration: _dialogInputDecoration(
        'Category',
        Icons.category_outlined,
      ),
      dropdownColor: surface,
      items: _categories
          .where((category) => category != 'All')
          .map(
            (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 19,
                      color: bronze,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: darkBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // ============================================================
  // MATERIAL DROPDOWN
  // ============================================================

  Widget _materialDropdown(
    String selected,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: _materials.contains(selected)
          ? selected
          : 'Other',
      decoration: _dialogInputDecoration(
        'Material',
        Icons.layers_outlined,
      ),
      dropdownColor: surface,
      items: _materials.map(
        (material) {
          return DropdownMenuItem<String>(
            value: material,
            child: Text(
              material,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: darkBrown,
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // ============================================================
  // INVENTORY CARD
  // ============================================================

  Widget _inventoryCard(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    final String name =
        data['name']?.toString() ?? 'Unnamed Item';

    final String category =
        data['category']?.toString() ?? 'Other';

    final String material =
        data['material']?.toString() ?? 'Unknown';

    final int total =
        (data['totalStock'] as num?)?.toInt() ?? 0;

    final int rented =
        (data['rentedStock'] as num?)?.toInt() ?? 0;

    final int available =
        (data['availableStock'] as num?)?.toInt() ??
            (total - rented);

    final double price =
        (data['rentPrice'] as num?)?.toDouble() ?? 0;

    final IconData icon = _getCategoryIcon(category);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return _mobileInventoryCard(
              document: document,
              data: data,
              name: name,
              category: category,
              material: material,
              total: total,
              rented: rented,
              available: available,
              price: price,
              icon: icon,
            );
          }

          return _desktopInventoryCard(
            document: document,
            data: data,
            name: name,
            category: category,
            material: material,
            total: total,
            rented: rented,
            available: available,
            price: price,
            icon: icon,
          );
        },
      ),
    );
  }

  // ============================================================
  // DESKTOP CARD
  // ============================================================

  Widget _desktopInventoryCard({
    required QueryDocumentSnapshot<Map<String, dynamic>> document,
    required Map<String, dynamic> data,
    required String name,
    required String category,
    required String material,
    required int total,
    required int rented,
    required int available,
    required double price,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bronzeLight.withOpacity(0.38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 30,
              color: bronzeDark,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Wrap(
                  spacing: 7,
                  runSpacing: 5,
                  children: [
                    _categoryBadge(category),
                    Text(
                      material,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            flex: 2,
            child: _stockInfo(
              title: 'Available',
              value: available.toString(),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),

          Expanded(
            flex: 2,
            child: _stockInfo(
              title: 'Rented',
              value: rented.toString(),
              icon: Icons.assignment_return_outlined,
            ),
          ),

          Expanded(
            flex: 2,
            child: _stockInfo(
              title: 'Total',
              value: total.toString(),
              icon: Icons.inventory_2_outlined,
            ),
          ),

          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rent / Unit',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: darkBrown,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          _actionMenu(
            document: document,
            data: data,
            name: name,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE CARD
  // ============================================================

  Widget _mobileInventoryCard({
    required QueryDocumentSnapshot<Map<String, dynamic>> document,
    required Map<String, dynamic> data,
    required String name,
    required String category,
    required String material,
    required int total,
    required int rented,
    required int available,
    required double price,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: bronzeLight.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 27,
                  color: bronzeDark,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        _categoryBadge(category),
                        Text(
                          material,
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _actionMenu(
                document: document,
                data: data,
                name: name,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            height: 1,
            color: border,
          ),

          const SizedBox(height: 13),

          LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  (constraints.maxWidth - 9) / 2;

              return Wrap(
                spacing: 9,
                runSpacing: 9,
                children: [
                  SizedBox(
                    width: width,
                    child: _mobileStockBox(
                      title: 'Available',
                      value: available.toString(),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _mobileStockBox(
                      title: 'Rented',
                      value: rented.toString(),
                      icon: Icons.assignment_return_outlined,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _mobileStockBox(
                      title: 'Total',
                      value: total.toString(),
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _mobileStockBox(
                      title: 'Rent / Unit',
                      value:
                          'Rs. ${price.toStringAsFixed(0)}',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY BADGE
  // ============================================================

  Widget _categoryBadge(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bronzeLight.withOpacity(0.42),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: bronzeDark,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // MOBILE STOCK BOX
  // ============================================================

  Widget _mobileStockBox({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: bronze,
            size: 17,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkBrown,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DESKTOP STOCK INFO
  // ============================================================

  Widget _stockInfo({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: bronze,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: mutedText,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: darkBrown,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION MENU
  // ============================================================

  Widget _actionMenu({
    required QueryDocumentSnapshot<Map<String, dynamic>> document,
    required Map<String, dynamic> data,
    required String name,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Manage Item',
      icon: const Icon(
        Icons.more_vert_rounded,
        color: mediumBrown,
      ),
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: border),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _editItem(document.id, data);
        }

        if (value == 'delete') {
          _deleteItem(document.id, name);
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: bronzeDark,
                ),
                SizedBox(width: 10),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(
        color: darkBrown,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText:
            'Search by name, category, material...',
        hintStyle: const TextStyle(
          color: mutedText,
          fontSize: 13,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: bronzeDark,
          size: 21,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.clear_rounded,
                  color: mediumBrown,
                ),
              )
            : null,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: bronze,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _categoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: mediumBrown,
          ),
          dropdownColor: surface,
          borderRadius: BorderRadius.circular(14),
          items: _categories.map(
            (category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      category == 'All'
                          ? Icons.inventory_2_outlined
                          : _getCategoryIcon(category),
                      size: 19,
                      color: bronzeDark,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        category,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // DIALOG INPUT
  // ============================================================

  InputDecoration _dialogInputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: mutedText,
      ),
      prefixIcon: Icon(
        icon,
        color: bronzeDark,
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
    );
  }

  // ============================================================
  // ADD ITEM BUTTON
  // ============================================================

  Widget _addItemButton({
    bool compact = false,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddItemScreen(),
          ),
        );
      },
      icon: Icon(
        Icons.add_rounded,
        size: compact ? 19 : 20,
      ),
      label: compact
          ? const Text('Add')
          : const Text('Add Item'),
      style: ElevatedButton.styleFrom(
        backgroundColor: bronzeDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: compact ? 12 : 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyInventory({
    required bool isSearchResult,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: bronzeLight.withOpacity(0.42),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchResult
                    ? Icons.search_off_rounded
                    : Icons.inventory_2_outlined,
                size: 39,
                color: bronzeDark,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              isSearchResult
                  ? 'No items found'
                  : 'No inventory items yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              isSearchResult
                  ? 'Try another search or category.'
                  : 'Start by adding your first inventory item.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedText,
                fontSize: 13,
              ),
            ),

            if (!isSearchResult) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AddItemScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_rounded,
                  size: 20,
                ),
                label: const Text(
                  'Add First Item',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bronzeDark,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: surface,
        foregroundColor: darkBrown,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
      ),

      drawer: const AdminDrawer(
        selectedIndex: 1,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, outerConstraints) {
            final isMobile =
                outerConstraints.maxWidth < 650;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 14 : 24,
                    isMobile ? 16 : 24,
                    isMobile ? 14 : 24,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // HEADER
                      // ==================================================

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 550) {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: bronzeLight
                                            .withOpacity(0.45),
                                        borderRadius:
                                            BorderRadius.circular(
                                          13,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons
                                            .inventory_2_outlined,
                                        color: bronzeDark,
                                        size: 23,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            'Inventory',
                                            style: TextStyle(
                                              color: darkBrown,
                                              fontSize: 25,
                                              fontWeight:
                                                  FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            'Manage your rental items and stock.',
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
                                const SizedBox(height: 13),
                                SizedBox(
                                  width: double.infinity,
                                  child: _addItemButton(),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: bronzeLight
                                      .withOpacity(0.45),
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: bronzeDark,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Inventory',
                                      style: TextStyle(
                                        color: darkBrown,
                                        fontSize: 28,
                                        fontWeight:
                                            FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage all your rental items and stock.',
                                      style: TextStyle(
                                        color: mutedText,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _addItemButton(),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      // ==================================================
                      // SEARCH + FILTER
                      // ==================================================

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth < 650) {
                            return Column(
                              children: [
                                _searchBar(),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: _categoryFilter(),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _searchBar(),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 215,
                                height: 52,
                                child: _categoryFilter(),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // INVENTORY
                      // ==================================================

                      Expanded(
                        child: StreamBuilder<
                            QuerySnapshot<
                                Map<String, dynamic>>>(
                          stream: _inventoryCollection
                              .orderBy(
                                'createdAt',
                                descending: true,
                              )
                              .snapshots(),

                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(
                                  color: bronze,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: SingleChildScrollView(
                                  padding:
                                      const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration:
                                            BoxDecoration(
                                          color: bronzeLight
                                              .withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons
                                              .error_outline_rounded,
                                          size: 34,
                                          color: bronzeDark,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'Unable to load inventory.',
                                        textAlign:
                                            TextAlign.center,
                                        style: TextStyle(
                                          color: darkBrown,
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        '${snapshot.error}',
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
                              );
                            }

                            final allItems =
                                snapshot.data?.docs ?? [];

                            final filteredItems =
                                _filterItems(allItems);

                            if (allItems.isEmpty) {
                              return _emptyInventory(
                                isSearchResult: false,
                              );
                            }

                            if (filteredItems.isEmpty) {
                              return _emptyInventory(
                                isSearchResult: true,
                              );
                            }

                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration:
                                          const BoxDecoration(
                                        color: bronze,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${filteredItems.length} item${filteredItems.length == 1 ? '' : 's'}',
                                      style:
                                          const TextStyle(
                                        color: mutedText,
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Expanded(
                                  child: ListView.builder(
                                    physics:
                                        const BouncingScrollPhysics(),
                                    padding:
                                        const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    itemCount:
                                        filteredItems.length,
                                    itemBuilder:
                                        (context, index) {
                                      return _inventoryCard(
                                        filteredItems[index],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}