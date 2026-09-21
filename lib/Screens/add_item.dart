// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AddItemScreen extends StatefulWidget {
//   const AddItemScreen({super.key});

//   @override
//   State<AddItemScreen> createState() => _AddItemScreenState();
// }

// class _AddItemScreenState extends State<AddItemScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _totalStockController =
//       TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController =
//       TextEditingController();

//   String? _selectedCategory;
//   String? _selectedMaterial;

//   bool _isSaving = false;

//   final List<String> _categories = [
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   final List<String> _materials = [
//     'Wooden',
//     'Steel',
//     'Plastic',
//     'Metal',
//     'Fabric',
//     'Glass',
//     'Aluminium',
//     'Mixed',
//     'Other',
//   ];

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _totalStockController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _saveItem() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_selectedCategory == null) {
//       _showMessage('Please select a category.');
//       return;
//     }

//     if (_selectedMaterial == null) {
//       _showMessage('Please select a material.');
//       return;
//     }

//     final int totalStock = int.parse(_totalStockController.text.trim());
//     final double rentPrice = double.parse(_priceController.text.trim());

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await FirebaseFirestore.instance.collection('inventory').add({
//         'name': _nameController.text.trim(),
//         'category': _selectedCategory,
//         'totalStock': totalStock,

//         // New item starts completely available.
//         'availableStock': totalStock,

//         // Nothing is rented when item is first added.
//         'rentedStock': 0,

//         'material': _selectedMaterial,
//         'rentPrice': rentPrice,
//         'description': _descriptionController.text.trim(),

//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       _showMessage('Item added successfully.');

//       Navigator.pop(context);
//     } on FirebaseException catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Failed to add item: ${e.message ?? e.code}',
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage('Something went wrong.');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair;
//       case 'Decoration':
//         return Icons.auto_awesome;
//       case 'Tent':
//         return Icons.house;
//       case 'Lighting':
//         return Icons.lightbulb;
//       case 'Sound Equipment':
//         return Icons.speaker;
//       case 'Stage Equipment':
//         return Icons.theater_comedy;
//       case 'Catering':
//         return Icons.restaurant;
//       default:
//         return Icons.inventory_2;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),
//       appBar: AppBar(
//         title: const Text(
//           'Add Inventory Item',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 700,
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     // Header
//                     Row(
//                       children: [
//                         Container(
//                           width: 56,
//                           height: 56,
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: const Icon(
//                             Icons.inventory_2,
//                             color: Colors.blue,
//                             size: 30,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Add New Item',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 'Add an item to your rental inventory.',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     // Item Name
//                     _sectionTitle('Item Information'),

//                     const SizedBox(height: 12),

//                     TextFormField(
//                       controller: _nameController,
//                       textCapitalization: TextCapitalization.words,
//                       decoration: _inputDecoration(
//                         label: 'Item Name',
//                         hint: 'e.g. Wooden Chair',
//                         icon: Icons.inventory_2_outlined,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter item name.';
//                         }

//                         if (value.trim().length < 2) {
//                           return 'Item name is too short.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Category
//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,
//                       decoration: _inputDecoration(
//                         label: 'Category',
//                         hint: 'Select category',
//                         icon: Icons.category_outlined,
//                       ),
//                       items: _categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 _getCategoryIcon(category),
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(category),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategory = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a category.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Material
//                     DropdownButtonFormField<String>(
//                       value: _selectedMaterial,
//                       decoration: _inputDecoration(
//                         label: 'Material',
//                         hint: 'Select material',
//                         icon: Icons.layers_outlined,
//                       ),
//                       items: _materials.map((material) {
//                         return DropdownMenuItem<String>(
//                           value: material,
//                           child: Text(material),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedMaterial = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please select a material.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 28),

//                     // Stock
//                     _sectionTitle('Stock Information'),

//                     const SizedBox(height: 12),

//                     TextFormField(
//                       controller: _totalStockController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration(
//                         label: 'Total Stock',
//                         hint: 'e.g. 50',
//                         icon: Icons.inventory_outlined,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter total stock.';
//                         }

//                         final number = int.tryParse(value.trim());

//                         if (number == null) {
//                           return 'Please enter a valid number.';
//                         }

//                         if (number <= 0) {
//                           return 'Stock must be greater than 0.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 10),

//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.06),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Colors.blue,
//                             size: 20,
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               'Available stock will automatically be set equal to total stock when the item is added.',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 28),

//                     // Rental Price
//                     _sectionTitle('Rental Information'),

//                     const SizedBox(height: 12),

//                     TextFormField(
//                       controller: _priceController,
//                       keyboardType: const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),
//                       decoration: _inputDecoration(
//                         label: 'Rental Price / Unit',
//                         hint: 'e.g. 500',
//                         icon: Icons.payments_outlined,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Please enter rental price.';
//                         }

//                         final number =
//                             double.tryParse(value.trim());

//                         if (number == null) {
//                           return 'Please enter a valid price.';
//                         }

//                         if (number < 0) {
//                           return 'Price cannot be negative.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Description
//                     TextFormField(
//                       controller: _descriptionController,
//                       maxLines: 4,
//                       textCapitalization: TextCapitalization.sentences,
//                       decoration: _inputDecoration(
//                         label: 'Description',
//                         hint:
//                             'Optional information about this item...',
//                         icon: Icons.description_outlined,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Add button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 54,
//                       child: ElevatedButton.icon(
//                         onPressed: _isSaving ? null : _saveItem,
//                         icon: _isSaving
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.add),
//                         label: Text(
//                           _isSaving
//                               ? 'Adding Item...'
//                               : 'Add Item',
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

//                     const SizedBox(height: 12),

//                     // Cancel
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: OutlinedButton(
//                         onPressed: _isSaving
//                             ? null
//                             : () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 15,
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

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 17,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String label,
//     required String hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       prefixIcon: Icon(icon),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.blue,
//           width: 2,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.red,
//         ),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.red,
//           width: 2,
//         ),
//       ),
//     );
//   }
// }






// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AddItemScreen extends StatefulWidget {
//   const AddItemScreen({super.key});

//   @override
//   State<AddItemScreen> createState() => _AddItemScreenState();
// }

// class _AddItemScreenState extends State<AddItemScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _totalStockController =
//       TextEditingController();
//   final TextEditingController _rentedStockController =
//       TextEditingController();
//   final TextEditingController _availableStockController =
//       TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController =
//       TextEditingController();

//   String? _selectedCategory;
//   String? _selectedMaterial;

//   bool _isSaving = false;

//   final List<String> _categories = [
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   final List<String> _materials = [
//     'Wooden',
//     'Steel',
//     'Plastic',
//     'Metal',
//     'Fabric',
//     'Glass',
//     'Aluminium',
//     'Mixed',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _totalStockController.addListener(_calculateAvailableStock);
//     _rentedStockController.addListener(_calculateAvailableStock);

//     _availableStockController.text = '0';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _totalStockController.dispose();
//     _rentedStockController.dispose();
//     _availableStockController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _calculateAvailableStock() {
//     final int total =
//         int.tryParse(_totalStockController.text.trim()) ?? 0;

//     final int rented =
//         int.tryParse(_rentedStockController.text.trim()) ?? 0;

//     final int available = total - rented;

//     _availableStockController.text =
//         available >= 0 ? available.toString() : '0';
//   }

//   Future<void> _saveItem() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_selectedCategory == null) {
//       _showMessage('Please select a category.');
//       return;
//     }

//     if (_selectedMaterial == null) {
//       _showMessage('Please select a material.');
//       return;
//     }

//     final int totalStock =
//         int.parse(_totalStockController.text.trim());

//     final int rentedStock =
//         int.parse(_rentedStockController.text.trim());

//     if (rentedStock > totalStock) {
//       _showMessage(
//         'Rented stock cannot be greater than total stock.',
//       );
//       return;
//     }

//     final int availableStock = totalStock - rentedStock;

//     final double rentPrice =
//         double.parse(_priceController.text.trim());

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await FirebaseFirestore.instance.collection('inventory').add({
//         'name': _nameController.text.trim(),
//         'category': _selectedCategory,

//         'totalStock': totalStock,
//         'rentedStock': rentedStock,
//         'availableStock': availableStock,

//         'material': _selectedMaterial,
//         'rentPrice': rentPrice,
//         'description': _descriptionController.text.trim(),

//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item added successfully.'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       Navigator.pop(context);
//     } on FirebaseException catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Failed to add item: ${e.message ?? e.code}',
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage('Something went wrong.');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }

//   IconData _getCategoryIcon(String category) {
//     switch (category) {
//       case 'Furniture':
//         return Icons.chair;
//       case 'Decoration':
//         return Icons.auto_awesome;
//       case 'Tent':
//         return Icons.house;
//       case 'Lighting':
//         return Icons.lightbulb;
//       case 'Sound Equipment':
//         return Icons.speaker;
//       case 'Stage Equipment':
//         return Icons.theater_comedy;
//       case 'Catering':
//         return Icons.restaurant;
//       default:
//         return Icons.inventory_2;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F7FA),

//       appBar: AppBar(
//         title: const Text(
//           'Add Inventory Item',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 0,
//       ),

//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),

//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 700,
//               ),

//               child: Form(
//                 key: _formKey,

//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     // =====================================================
//                     // HEADER
//                     // =====================================================

//                     Row(
//                       children: [
//                         Container(
//                           width: 56,
//                           height: 56,

//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(14),
//                           ),

//                           child: const Icon(
//                             Icons.inventory_2,
//                             color: Colors.blue,
//                             size: 30,
//                           ),
//                         ),

//                         const SizedBox(width: 16),

//                         const Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,

//                             children: [
//                               Text(
//                                 'Add New Item',
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),

//                               SizedBox(height: 4),

//                               Text(
//                                 'Add an item to your rental inventory.',
//                                 style: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 30),

//                     // =====================================================
//                     // ITEM INFORMATION
//                     // =====================================================

//                     _sectionTitle('Item Information'),

//                     const SizedBox(height: 12),

//                     // Item Name
//                     TextFormField(
//                       controller: _nameController,

//                       textCapitalization:
//                           TextCapitalization.words,

//                       decoration: _inputDecoration(
//                         label: 'Item Name',
//                         hint: 'e.g. Wooden Chair',
//                         icon: Icons.inventory_2_outlined,
//                       ),

//                       validator: (value) {
//                         if (value == null ||
//                             value.trim().isEmpty) {
//                           return 'Please enter item name.';
//                         }

//                         if (value.trim().length < 2) {
//                           return 'Item name is too short.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Category
//                     DropdownButtonFormField<String>(
//                       value: _selectedCategory,

//                       decoration: _inputDecoration(
//                         label: 'Category',
//                         hint: 'Select category',
//                         icon: Icons.category_outlined,
//                       ),

//                       items: _categories.map((category) {
//                         return DropdownMenuItem<String>(
//                           value: category,

//                           child: Row(
//                             children: [
//                               Icon(
//                                 _getCategoryIcon(category),
//                                 size: 20,
//                               ),

//                               const SizedBox(width: 10),

//                               Text(category),
//                             ],
//                           ),
//                         );
//                       }).toList(),

//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategory = value;
//                         });
//                       },

//                       validator: (value) {
//                         if (value == null ||
//                             value.isEmpty) {
//                           return 'Please select a category.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Material
//                     DropdownButtonFormField<String>(
//                       value: _selectedMaterial,

//                       decoration: _inputDecoration(
//                         label: 'Material',
//                         hint: 'Select material',
//                         icon: Icons.layers_outlined,
//                       ),

//                       items: _materials.map((material) {
//                         return DropdownMenuItem<String>(
//                           value: material,
//                           child: Text(material),
//                         );
//                       }).toList(),

//                       onChanged: (value) {
//                         setState(() {
//                           _selectedMaterial = value;
//                         });
//                       },

//                       validator: (value) {
//                         if (value == null ||
//                             value.isEmpty) {
//                           return 'Please select a material.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 30),

//                     // =====================================================
//                     // STOCK INFORMATION
//                     // =====================================================

//                     _sectionTitle('Stock Information'),

//                     const SizedBox(height: 12),

//                     // Total + Rented
//                     Row(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [

//                         // Total Stock
//                         Expanded(
//                           child: TextFormField(
//                             controller:
//                                 _totalStockController,

//                             keyboardType:
//                                 TextInputType.number,

//                             decoration: _inputDecoration(
//                               label: 'Total Stock',
//                               hint: 'e.g. 100',
//                               icon:
//                                   Icons.inventory_outlined,
//                             ),

//                             validator: (value) {
//                               if (value == null ||
//                                   value.trim().isEmpty) {
//                                 return 'Enter total stock.';
//                               }

//                               final number =
//                                   int.tryParse(
//                                 value.trim(),
//                               );

//                               if (number == null) {
//                                 return 'Enter a valid number.';
//                               }

//                               if (number <= 0) {
//                                 return 'Must be greater than 0.';
//                               }

//                               return null;
//                             },
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         // Rented Stock
//                         Expanded(
//                           child: TextFormField(
//                             controller:
//                                 _rentedStockController,

//                             keyboardType:
//                                 TextInputType.number,

//                             decoration: _inputDecoration(
//                               label: 'Rented Stock',
//                               hint: 'e.g. 20',
//                               icon: Icons
//                                   .assignment_return_outlined,
//                             ),

//                             validator: (value) {
//                               if (value == null ||
//                                   value.trim().isEmpty) {
//                                 return 'Enter rented stock.';
//                               }

//                               final rented =
//                                   int.tryParse(
//                                 value.trim(),
//                               );

//                               if (rented == null) {
//                                 return 'Enter a valid number.';
//                               }

//                               if (rented < 0) {
//                                 return 'Cannot be negative.';
//                               }

//                               final total =
//                                   int.tryParse(
//                                 _totalStockController
//                                     .text
//                                     .trim(),
//                               );

//                               if (total != null &&
//                                   rented > total) {
//                                 return 'Cannot exceed total.';
//                               }

//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 16),

//                     // Available Stock
//                     TextFormField(
//                       controller:
//                           _availableStockController,

//                       readOnly: true,

//                       decoration: _inputDecoration(
//                         label: 'Available Stock',
//                         hint: 'Automatically calculated',
//                         icon:
//                             Icons.check_circle_outline,
//                       ).copyWith(
//                         filled: true,
//                         fillColor:
//                             Colors.green.withOpacity(0.07),
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // Stock calculation information
//                     Container(
//                       width: double.infinity,

//                       padding: const EdgeInsets.all(14),

//                       decoration: BoxDecoration(
//                         color:
//                             Colors.blue.withOpacity(0.06),

//                         borderRadius:
//                             BorderRadius.circular(10),
//                       ),

//                       child: const Row(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,

//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Colors.blue,
//                             size: 20,
//                           ),

//                           SizedBox(width: 10),

//                           Expanded(
//                             child: Text(
//                               'Available Stock = Total Stock − Rented Stock. '
//                               'Available Stock cannot be entered manually.',
//                               style: TextStyle(
//                                 color: Colors.blue,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 30),

//                     // =====================================================
//                     // RENTAL INFORMATION
//                     // =====================================================

//                     _sectionTitle('Rental Information'),

//                     const SizedBox(height: 12),

//                     // Rental Price
//                     TextFormField(
//                       controller: _priceController,

//                       keyboardType:
//                           const TextInputType.numberWithOptions(
//                         decimal: true,
//                       ),

//                       decoration: _inputDecoration(
//                         label: 'Rental Price / Unit',
//                         hint: 'e.g. 500',
//                         icon: Icons.payments_outlined,
//                       ),

//                       validator: (value) {
//                         if (value == null ||
//                             value.trim().isEmpty) {
//                           return 'Please enter rental price.';
//                         }

//                         final number =
//                             double.tryParse(
//                           value.trim(),
//                         );

//                         if (number == null) {
//                           return 'Please enter a valid price.';
//                         }

//                         if (number < 0) {
//                           return 'Price cannot be negative.';
//                         }

//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // Description
//                     TextFormField(
//                       controller:
//                           _descriptionController,

//                       maxLines: 4,

//                       textCapitalization:
//                           TextCapitalization.sentences,

//                       decoration: _inputDecoration(
//                         label: 'Description',
//                         hint:
//                             'Optional information about this item...',
//                         icon:
//                             Icons.description_outlined,
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // =====================================================
//                     // ADD BUTTON
//                     // =====================================================

//                     SizedBox(
//                       width: double.infinity,
//                       height: 54,

//                       child: ElevatedButton.icon(
//                         onPressed:
//                             _isSaving ? null : _saveItem,

//                         icon: _isSaving
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,

//                                 child:
//                                     CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.add),

//                         label: Text(
//                           _isSaving
//                               ? 'Adding Item...'
//                               : 'Add Item',

//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         style:
//                             ElevatedButton.styleFrom(
//                           backgroundColor:
//                               Colors.blue,

//                           foregroundColor:
//                               Colors.white,

//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     // =====================================================
//                     // CANCEL BUTTON
//                     // =====================================================

//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,

//                       child: OutlinedButton(
//                         onPressed: _isSaving
//                             ? null
//                             : () =>
//                                 Navigator.pop(context),

//                         style:
//                             OutlinedButton.styleFrom(
//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(12),
//                           ),
//                         ),

//                         child: const Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 15,
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

//   // =====================================================
//   // SECTION TITLE
//   // =====================================================

//   Widget _sectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 17,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   // =====================================================
//   // INPUT DECORATION
//   // =====================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required String hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,

//       prefixIcon: Icon(icon),

//       filled: true,
//       fillColor: Colors.white,

//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(
//           color: Colors.grey.shade200,
//         ),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.blue,
//           width: 2,
//         ),
//       ),

//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.red,
//         ),
//       ),

//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(
//           color: Colors.red,
//           width: 2,
//         ),
//       ),
//     );
//   }
// }



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AddItemScreen extends StatefulWidget {
//   const AddItemScreen({super.key});

//   @override
//   State<AddItemScreen> createState() => _AddItemScreenState();
// }

// class _AddItemScreenState extends State<AddItemScreen> {
//   // ============================================================
//   // THEME
//   // ============================================================

//   static const Color primaryColor = Color(0xFFE62E2E);
//   static const Color textColor = Color(0xFF111111);
//   static const Color secondaryTextColor = Color(0xFF6B7280);
//   static const Color borderColor = Color(0xFFE5E7EB);
//   static const Color backgroundColor = Color(0xFFF8F8F8);

//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _totalStockController =
//       TextEditingController();
//   final TextEditingController _rentedStockController =
//       TextEditingController();
//   final TextEditingController _availableStockController =
//       TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController =
//       TextEditingController();

//   String? _selectedCategory;
//   String? _selectedMaterial;

//   bool _isSaving = false;

//   final List<String> _categories = [
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   final List<String> _materials = [
//     'Wooden',
//     'Steel',
//     'Plastic',
//     'Metal',
//     'Fabric',
//     'Glass',
//     'Aluminium',
//     'Mixed',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _totalStockController.addListener(_calculateAvailableStock);
//     _rentedStockController.addListener(_calculateAvailableStock);

//     _availableStockController.text = '0';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _totalStockController.dispose();
//     _rentedStockController.dispose();
//     _availableStockController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // AVAILABLE STOCK
//   // ============================================================

//   void _calculateAvailableStock() {
//     final int total =
//         int.tryParse(_totalStockController.text.trim()) ?? 0;

//     final int rented =
//         int.tryParse(_rentedStockController.text.trim()) ?? 0;

//     final int available = total - rented;

//     _availableStockController.text =
//         available >= 0 ? available.toString() : '0';
//   }

//   // ============================================================
//   // SAVE ITEM
//   // ============================================================

//   Future<void> _saveItem() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_selectedCategory == null) {
//       _showMessage('Please select a category.');
//       return;
//     }

//     if (_selectedMaterial == null) {
//       _showMessage('Please select a material.');
//       return;
//     }

//     final int totalStock =
//         int.parse(_totalStockController.text.trim());

//     final int rentedStock =
//         int.parse(_rentedStockController.text.trim());

//     if (rentedStock > totalStock) {
//       _showMessage(
//         'Rented stock cannot be greater than total stock.',
//       );
//       return;
//     }

//     final int availableStock = totalStock - rentedStock;

//     final double rentPrice =
//         double.parse(_priceController.text.trim());

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       await FirebaseFirestore.instance.collection('inventory').add({
//         'name': _nameController.text.trim(),
//         'category': _selectedCategory,
//         'totalStock': totalStock,
//         'rentedStock': rentedStock,
//         'availableStock': availableStock,
//         'material': _selectedMaterial,
//         'rentPrice': rentPrice,
//         'description': _descriptionController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item added successfully.'),
//           backgroundColor: primaryColor,
//         ),
//       );

//       Navigator.pop(context);
//     } on FirebaseException catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Failed to add item: ${e.message ?? e.code}',
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage('Something went wrong.');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: primaryColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
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
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       // ==========================================================
//       // APP BAR
//       // ==========================================================

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: textColor,
//         elevation: 0,
//         surfaceTintColor: Colors.white,

//         titleSpacing: 24,

//         title: const Text(
//           'Add Inventory Item',
//           style: TextStyle(
//             color: textColor,
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//           ),
//         ),

//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             height: 1,
//             color: borderColor,
//           ),
//         ),
//       ),

//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isMobile = constraints.maxWidth < 650;

//             return SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 16 : 28,
//                 vertical: isMobile ? 20 : 28,
//               ),

//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: 900,
//                   ),

//                   child: Form(
//                     key: _formKey,

//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,

//                       children: [
//                         // ==================================================
//                         // HEADER
//                         // ==================================================

//                         _buildHeader(isMobile),

//                         const SizedBox(height: 28),

//                         // ==================================================
//                         // ITEM INFORMATION CARD
//                         // ==================================================

//                         _buildSectionCard(
//                           icon: Icons.inventory_2_outlined,
//                           title: 'Item Information',
//                           subtitle:
//                               'Enter the basic information about your rental item.',
//                           child: Column(
//                             children: [
//                               TextFormField(
//                                 controller: _nameController,
//                                 textCapitalization:
//                                     TextCapitalization.words,
//                                 decoration: _inputDecoration(
//                                   label: 'Item Name',
//                                   hint: 'e.g. Wooden Chair',
//                                   icon:
//                                       Icons.inventory_2_outlined,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty) {
//                                     return 'Please enter item name.';
//                                   }

//                                   if (value.trim().length < 2) {
//                                     return 'Item name is too short.';
//                                   }

//                                   return null;
//                                 },
//                               ),

//                               const SizedBox(height: 18),

//                               if (isMobile)
//                                 Column(
//                                   children: [
//                                     _categoryField(),
//                                     const SizedBox(height: 18),
//                                     _materialField(),
//                                   ],
//                                 )
//                               else
//                                 Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: _categoryField(),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: _materialField(),
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         // ==================================================
//                         // STOCK INFORMATION CARD
//                         // ==================================================

//                         _buildSectionCard(
//                           icon: Icons.inventory_outlined,
//                           title: 'Stock Information',
//                           subtitle:
//                               'Set the total quantity and currently rented quantity.',
//                           child: Column(
//                             children: [
//                               if (isMobile)
//                                 Column(
//                                   children: [
//                                     _totalStockField(),
//                                     const SizedBox(height: 18),
//                                     _rentedStockField(),
//                                   ],
//                                 )
//                               else
//                                 Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: _totalStockField(),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: _rentedStockField(),
//                                     ),
//                                   ],
//                                 ),

//                               const SizedBox(height: 18),

//                               // AVAILABLE STOCK
//                               _buildAvailableStock(),

//                               const SizedBox(height: 14),

//                               // INFORMATION
//                               _buildInfoBox(),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         // ==================================================
//                         // RENTAL INFORMATION CARD
//                         // ==================================================

//                         _buildSectionCard(
//                           icon: Icons.payments_outlined,
//                           title: 'Rental Information',
//                           subtitle:
//                               'Set the rental price and add optional details.',
//                           child: Column(
//                             children: [
//                               TextFormField(
//                                 controller: _priceController,
//                                 keyboardType:
//                                     const TextInputType
//                                         .numberWithOptions(
//                                   decimal: true,
//                                 ),
//                                 decoration: _inputDecoration(
//                                   label: 'Rental Price / Unit',
//                                   hint: 'e.g. 500',
//                                   icon:
//                                       Icons.payments_outlined,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty) {
//                                     return 'Please enter rental price.';
//                                   }

//                                   final number =
//                                       double.tryParse(
//                                     value.trim(),
//                                   );

//                                   if (number == null) {
//                                     return 'Please enter a valid price.';
//                                   }

//                                   if (number < 0) {
//                                     return 'Price cannot be negative.';
//                                   }

//                                   return null;
//                                 },
//                               ),

//                               const SizedBox(height: 18),

//                               TextFormField(
//                                 controller:
//                                     _descriptionController,
//                                 maxLines: 4,
//                                 textCapitalization:
//                                     TextCapitalization.sentences,
//                                 decoration: _inputDecoration(
//                                   label: 'Description',
//                                   hint:
//                                       'Optional information about this item...',
//                                   icon:
//                                       Icons.description_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 28),

//                         // ==================================================
//                         // ACTION BUTTONS
//                         // ==================================================

//                         if (isMobile)
//                           Column(
//                             children: [
//                               _buildSaveButton(),
//                               const SizedBox(height: 12),
//                               _buildCancelButton(),
//                             ],
//                           )
//                         else
//                           Row(
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: _buildSaveButton(),
//                               ),
//                               const SizedBox(width: 14),
//                               Expanded(
//                                 child: _buildCancelButton(),
//                               ),
//                             ],
//                           ),

//                         const SizedBox(height: 20),
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
//   // HEADER
//   // ============================================================

//   Widget _buildHeader(bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 18 : 22),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: borderColor,
//         ),
//       ),

//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: isMobile ? 52 : 58,
//             height: isMobile ? 52 : 58,

//             decoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(14),
//             ),

//             child: const Icon(
//               Icons.inventory_2_outlined,
//               color: primaryColor,
//               size: 30,
//             ),
//           ),

//           const SizedBox(width: 16),

//           const Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Add New Item',
//                   style: TextStyle(
//                     fontSize: 23,
//                     fontWeight: FontWeight.w800,
//                     color: textColor,
//                   ),
//                 ),

//                 SizedBox(height: 5),

//                 Text(
//                   'Add a new item to your rental inventory.',
//                   style: TextStyle(
//                     color: secondaryTextColor,
//                     fontSize: 14,
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
//   // SECTION CARD
//   // ============================================================

//   Widget _buildSectionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(22),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: borderColor,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.025),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,

//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.08),
//                   borderRadius:
//                       BorderRadius.circular(11),
//                 ),

//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 22,
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: textColor,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           child,
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   Widget _categoryField() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,

//       decoration: _inputDecoration(
//         label: 'Category',
//         hint: 'Select category',
//         icon: Icons.category_outlined,
//       ),

//       items: _categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,

//           child: Row(
//             children: [
//               Icon(
//                 _getCategoryIcon(category),
//                 size: 20,
//                 color: primaryColor,
//               ),

//               const SizedBox(width: 10),

//               Text(category),
//             ],
//           ),
//         );
//       }).toList(),

//       onChanged: (value) {
//         setState(() {
//           _selectedCategory = value;
//         });
//       },

//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a category.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // MATERIAL
//   // ============================================================

//   Widget _materialField() {
//     return DropdownButtonFormField<String>(
//       value: _selectedMaterial,

//       decoration: _inputDecoration(
//         label: 'Material',
//         hint: 'Select material',
//         icon: Icons.layers_outlined,
//       ),

//       items: _materials.map((material) {
//         return DropdownMenuItem<String>(
//           value: material,
//           child: Text(material),
//         );
//       }).toList(),

//       onChanged: (value) {
//         setState(() {
//           _selectedMaterial = value;
//         });
//       },

//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a material.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // TOTAL STOCK
//   // ============================================================

//   Widget _totalStockField() {
//     return TextFormField(
//       controller: _totalStockController,

//       keyboardType: TextInputType.number,

//       decoration: _inputDecoration(
//         label: 'Total Stock',
//         hint: 'e.g. 100',
//         icon: Icons.inventory_outlined,
//       ),

//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return 'Enter total stock.';
//         }

//         final number =
//             int.tryParse(value.trim());

//         if (number == null) {
//           return 'Enter a valid number.';
//         }

//         if (number <= 0) {
//           return 'Must be greater than 0.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // RENTED STOCK
//   // ============================================================

//   Widget _rentedStockField() {
//     return TextFormField(
//       controller: _rentedStockController,

//       keyboardType: TextInputType.number,

//       decoration: _inputDecoration(
//         label: 'Rented Stock',
//         hint: 'e.g. 20',
//         icon: Icons.assignment_return_outlined,
//       ),

//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return 'Enter rented stock.';
//         }

//         final rented =
//             int.tryParse(value.trim());

//         if (rented == null) {
//           return 'Enter a valid number.';
//         }

//         if (rented < 0) {
//           return 'Cannot be negative.';
//         }

//         final total =
//             int.tryParse(
//           _totalStockController.text.trim(),
//         );

//         if (total != null && rented > total) {
//           return 'Cannot exceed total.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // AVAILABLE STOCK
//   // ============================================================

//   Widget _buildAvailableStock() {
//     return ValueListenableBuilder<TextEditingValue>(
//       valueListenable: _availableStockController,

//       builder: (context, value, child) {
//         final int available =
//             int.tryParse(value.text) ?? 0;

//         return Container(
//           width: double.infinity,

//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 15,
//           ),

//           decoration: BoxDecoration(
//             color: primaryColor.withOpacity(0.06),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: primaryColor.withOpacity(0.18),
//             ),
//           ),

//           child: Row(
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,

//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.10),
//                   shape: BoxShape.circle,
//                 ),

//                 child: const Icon(
//                   Icons.check_circle_outline,
//                   color: primaryColor,
//                   size: 21,
//                 ),
//               ),

//               const SizedBox(width: 12),

//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Available Stock',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: secondaryTextColor,
//                       ),
//                     ),

//                     SizedBox(height: 2),

//                     Text(
//                       'Automatically calculated',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Text(
//                 available.toString(),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // INFO BOX
//   // ============================================================

//   Widget _buildInfoBox() {
//     return Container(
//       width: double.infinity,

//       padding: const EdgeInsets.all(13),

//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: borderColor,
//         ),
//       ),

//       child: const Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,

//         children: [
//           Icon(
//             Icons.info_outline,
//             color: primaryColor,
//             size: 19,
//           ),

//           SizedBox(width: 9),

//           Expanded(
//             child: Text(
//               'Available Stock = Total Stock − Rented Stock. '
//               'Available Stock cannot be entered manually.',
//               style: TextStyle(
//                 color: secondaryTextColor,
//                 fontSize: 12.5,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SAVE BUTTON
//   // ============================================================

//   Widget _buildSaveButton() {
//     return SizedBox(
//       height: 54,
//       width: double.infinity,

//       child: ElevatedButton.icon(
//         onPressed:
//             _isSaving ? null : _saveItem,

//         icon: _isSaving
//             ? const SizedBox(
//                 width: 19,
//                 height: 19,
//                 child:
//                     CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : const Icon(
//                 Icons.add_rounded,
//               ),

//         label: Text(
//           _isSaving
//               ? 'Adding Item...'
//               : 'Add Item',
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//           ),
//         ),

//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           disabledBackgroundColor:
//               primaryColor.withOpacity(0.55),
//           disabledForegroundColor:
//               Colors.white,

//           elevation: 0,

//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CANCEL BUTTON
//   // ============================================================

//   Widget _buildCancelButton() {
//     return SizedBox(
//       height: 54,
//       width: double.infinity,

//       child: OutlinedButton(
//         onPressed: _isSaving
//             ? null
//             : () => Navigator.pop(context),

//         style: OutlinedButton.styleFrom(
//           foregroundColor: textColor,

//           side: const BorderSide(
//             color: borderColor,
//           ),

//           backgroundColor: Colors.white,

//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//           ),
//         ),

//         child: const Text(
//           'Cancel',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: textColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required String hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,

//       prefixIcon: Icon(
//         icon,
//         color: primaryColor,
//         size: 21,
//       ),

//       labelStyle: const TextStyle(
//         color: secondaryTextColor,
//       ),

//       hintStyle: const TextStyle(
//         color: Color(0xFF9CA3AF),
//         fontSize: 13,
//       ),

//       filled: true,
//       fillColor: Colors.white,

//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 16,
//       ),

//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: borderColor,
//         ),
//       ),

//       enabledBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: borderColor,
//         ),
//       ),

//       focusedBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//           width: 1.8,
//         ),
//       ),

//       errorBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//         ),
//       ),

//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//           width: 1.8,
//         ),
//       ),
//     );
//   }
// }




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AddItemScreen extends StatefulWidget {
//   const AddItemScreen({super.key});

//   @override
//   State<AddItemScreen> createState() => _AddItemScreenState();
// }

// class _AddItemScreenState extends State<AddItemScreen> {
//   static const Color primaryColor = Color(0xFFE62E2E);
//   static const Color textColor = Color(0xFF111111);
//   static const Color secondaryTextColor = Color(0xFF6B7280);
//   static const Color borderColor = Color(0xFFE5E7EB);
//   static const Color backgroundColor = Color(0xFFF8F8F8);

//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _totalStockController =
//       TextEditingController();
//   final TextEditingController _rentedStockController =
//       TextEditingController();
//   final TextEditingController _availableStockController =
//       TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController =
//       TextEditingController();

//   String? _selectedCategory;
//   String? _selectedMaterial;

//   bool _isSaving = false;

//   final List<String> _categories = [
//     'Furniture',
//     'Decoration',
//     'Tent',
//     'Lighting',
//     'Sound Equipment',
//     'Stage Equipment',
//     'Catering',
//     'Other',
//   ];

//   final List<String> _materials = [
//     'Wooden',
//     'Steel',
//     'Plastic',
//     'Metal',
//     'Fabric',
//     'Glass',
//     'Aluminium',
//     'Mixed',
//     'Other',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     _totalStockController.addListener(_calculateAvailableStock);
//     _rentedStockController.addListener(_calculateAvailableStock);

//     _availableStockController.text = '0';
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _totalStockController.dispose();
//     _rentedStockController.dispose();
//     _availableStockController.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   void _calculateAvailableStock() {
//     final int total =
//         int.tryParse(_totalStockController.text.trim()) ?? 0;

//     final int rented =
//         int.tryParse(_rentedStockController.text.trim()) ?? 0;

//     final int available = total - rented;

//     _availableStockController.text =
//         available >= 0 ? available.toString() : '0';
//   }

//   // ============================================================
//   // SAVE ITEM
//   // ============================================================

//   Future<void> _saveItem() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_selectedCategory == null) {
//       _showMessage('Please select a category.');
//       return;
//     }

//     if (_selectedMaterial == null) {
//       _showMessage('Please select a material.');
//       return;
//     }

//     final int totalStock =
//         int.parse(_totalStockController.text.trim());

//     final int rentedStock =
//         int.parse(_rentedStockController.text.trim());

//     if (rentedStock > totalStock) {
//       _showMessage(
//         'Rented stock cannot be greater than total stock.',
//       );
//       return;
//     }

//     final int availableStock = totalStock - rentedStock;

//     final double rentPrice =
//         double.parse(_priceController.text.trim());

//     setState(() {
//       _isSaving = true;
//     });

//     try {
//       // ========================================================
//       // CURRENT LOGGED-IN USER
//       // ========================================================

//       final User? user = FirebaseAuth.instance.currentUser;

//       if (user == null) {
//         if (!mounted) return;

//         _showMessage(
//           'User session expired. Please login again.',
//         );

//         return;
//       }

//       // ========================================================
//       // USER-SPECIFIC INVENTORY
//       //
//       // users
//       //   └── user UID
//       //        └── inventory
//       //             └── item ID
//       // ========================================================

//       final CollectionReference inventoryCollection =
//           FirebaseFirestore.instance
//               .collection('Users')
//               .doc(user.uid)
//               .collection('inventory');

//       await inventoryCollection.add({
//         'name': _nameController.text.trim(),
//         'category': _selectedCategory,
//         'totalStock': totalStock,
//         'rentedStock': rentedStock,
//         'availableStock': availableStock,
//         'material': _selectedMaterial,
//         'rentPrice': rentPrice,
//         'description': _descriptionController.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Item added successfully.'),
//           backgroundColor: primaryColor,
//         ),
//       );

//       Navigator.pop(context);
//     } on FirebaseException catch (e) {
//       if (!mounted) return;

//       _showMessage(
//         'Failed to add item: ${e.message ?? e.code}',
//       );
//     } catch (e) {
//       if (!mounted) return;

//       _showMessage('Something went wrong.');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: primaryColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
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
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: textColor,
//         elevation: 0,
//         surfaceTintColor: Colors.white,
//         titleSpacing: 24,
//         title: const Text(
//           'Add Inventory Item',
//           style: TextStyle(
//             color: textColor,
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             height: 1,
//             color: borderColor,
//           ),
//         ),
//       ),

//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isMobile = constraints.maxWidth < 650;

//             return SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 16 : 28,
//                 vertical: isMobile ? 20 : 28,
//               ),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: 900,
//                   ),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         _buildHeader(isMobile),

//                         const SizedBox(height: 28),

//                         _buildSectionCard(
//                           icon: Icons.inventory_2_outlined,
//                           title: 'Item Information',
//                           subtitle:
//                               'Enter the basic information about your rental item.',
//                           child: Column(
//                             children: [
//                               TextFormField(
//                                 controller: _nameController,
//                                 textCapitalization:
//                                     TextCapitalization.words,
//                                 decoration: _inputDecoration(
//                                   label: 'Item Name',
//                                   hint: 'e.g. Wooden Chair',
//                                   icon:
//                                       Icons.inventory_2_outlined,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty) {
//                                     return 'Please enter item name.';
//                                   }

//                                   if (value.trim().length < 2) {
//                                     return 'Item name is too short.';
//                                   }

//                                   return null;
//                                 },
//                               ),

//                               const SizedBox(height: 18),

//                               if (isMobile)
//                                 Column(
//                                   children: [
//                                     _categoryField(),
//                                     const SizedBox(height: 18),
//                                     _materialField(),
//                                   ],
//                                 )
//                               else
//                                 Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: _categoryField(),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: _materialField(),
//                                     ),
//                                   ],
//                                 ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         _buildSectionCard(
//                           icon: Icons.inventory_outlined,
//                           title: 'Stock Information',
//                           subtitle:
//                               'Set the total quantity and currently rented quantity.',
//                           child: Column(
//                             children: [
//                               if (isMobile)
//                                 Column(
//                                   children: [
//                                     _totalStockField(),
//                                     const SizedBox(height: 18),
//                                     _rentedStockField(),
//                                   ],
//                                 )
//                               else
//                                 Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                       child: _totalStockField(),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: _rentedStockField(),
//                                     ),
//                                   ],
//                                 ),

//                               const SizedBox(height: 18),

//                               _buildAvailableStock(),

//                               const SizedBox(height: 14),

//                               _buildInfoBox(),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         _buildSectionCard(
//                           icon: Icons.payments_outlined,
//                           title: 'Rental Information',
//                           subtitle:
//                               'Set the rental price and add optional details.',
//                           child: Column(
//                             children: [
//                               TextFormField(
//                                 controller: _priceController,
//                                 keyboardType:
//                                     const TextInputType.numberWithOptions(
//                                   decimal: true,
//                                 ),
//                                 decoration: _inputDecoration(
//                                   label: 'Rental Price / Unit',
//                                   hint: 'e.g. 500',
//                                   icon:
//                                       Icons.payments_outlined,
//                                 ),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty) {
//                                     return 'Please enter rental price.';
//                                   }

//                                   final number =
//                                       double.tryParse(
//                                     value.trim(),
//                                   );

//                                   if (number == null) {
//                                     return 'Please enter a valid price.';
//                                   }

//                                   if (number < 0) {
//                                     return 'Price cannot be negative.';
//                                   }

//                                   return null;
//                                 },
//                               ),

//                               const SizedBox(height: 18),

//                               TextFormField(
//                                 controller:
//                                     _descriptionController,
//                                 maxLines: 4,
//                                 textCapitalization:
//                                     TextCapitalization.sentences,
//                                 decoration: _inputDecoration(
//                                   label: 'Description',
//                                   hint:
//                                       'Optional information about this item...',
//                                   icon:
//                                       Icons.description_outlined,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         const SizedBox(height: 28),

//                         if (isMobile)
//                           Column(
//                             children: [
//                               _buildSaveButton(),
//                               const SizedBox(height: 12),
//                               _buildCancelButton(),
//                             ],
//                           )
//                         else
//                           Row(
//                             children: [
//                               Expanded(
//                                 flex: 2,
//                                 child: _buildSaveButton(),
//                               ),
//                               const SizedBox(width: 14),
//                               Expanded(
//                                 child: _buildCancelButton(),
//                               ),
//                             ],
//                           ),

//                         const SizedBox(height: 20),
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
//   // HEADER
//   // ============================================================

//   Widget _buildHeader(bool isMobile) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(isMobile ? 18 : 22),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: borderColor,
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: isMobile ? 52 : 58,
//             height: isMobile ? 52 : 58,
//             decoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(
//               Icons.inventory_2_outlined,
//               color: primaryColor,
//               size: 30,
//             ),
//           ),

//           const SizedBox(width: 16),

//           const Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Add New Item',
//                   style: TextStyle(
//                     fontSize: 23,
//                     fontWeight: FontWeight.w800,
//                     color: textColor,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   'Add a new item to your rental inventory.',
//                   style: TextStyle(
//                     color: secondaryTextColor,
//                     fontSize: 14,
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
//   // SECTION CARD
//   // ============================================================

//   Widget _buildSectionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Widget child,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: borderColor,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.025),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.08),
//                   borderRadius:
//                       BorderRadius.circular(11),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: primaryColor,
//                   size: 22,
//                 ),
//               ),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: textColor,
//                       ),
//                     ),
//                     const SizedBox(height: 3),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           child,
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   Widget _categoryField() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
//       decoration: _inputDecoration(
//         label: 'Category',
//         hint: 'Select category',
//         icon: Icons.category_outlined,
//       ),
//       items: _categories.map((category) {
//         return DropdownMenuItem<String>(
//           value: category,
//           child: Row(
//             children: [
//               Icon(
//                 _getCategoryIcon(category),
//                 size: 20,
//                 color: primaryColor,
//               ),
//               const SizedBox(width: 10),
//               Text(category),
//             ],
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedCategory = value;
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a category.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // MATERIAL
//   // ============================================================

//   Widget _materialField() {
//     return DropdownButtonFormField<String>(
//       value: _selectedMaterial,
//       decoration: _inputDecoration(
//         label: 'Material',
//         hint: 'Select material',
//         icon: Icons.layers_outlined,
//       ),
//       items: _materials.map((material) {
//         return DropdownMenuItem<String>(
//           value: material,
//           child: Text(material),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() {
//           _selectedMaterial = value;
//         });
//       },
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please select a material.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // TOTAL STOCK
//   // ============================================================

//   Widget _totalStockField() {
//     return TextFormField(
//       controller: _totalStockController,
//       keyboardType: TextInputType.number,
//       decoration: _inputDecoration(
//         label: 'Total Stock',
//         hint: 'e.g. 100',
//         icon: Icons.inventory_outlined,
//       ),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return 'Enter total stock.';
//         }

//         final number =
//             int.tryParse(value.trim());

//         if (number == null) {
//           return 'Enter a valid number.';
//         }

//         if (number <= 0) {
//           return 'Must be greater than 0.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // RENTED STOCK
//   // ============================================================

//   Widget _rentedStockField() {
//     return TextFormField(
//       controller: _rentedStockController,
//       keyboardType: TextInputType.number,
//       decoration: _inputDecoration(
//         label: 'Rented Stock',
//         hint: 'e.g. 20',
//         icon: Icons.assignment_return_outlined,
//       ),
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return 'Enter rented stock.';
//         }

//         final rented =
//             int.tryParse(value.trim());

//         if (rented == null) {
//           return 'Enter a valid number.';
//         }

//         if (rented < 0) {
//           return 'Cannot be negative.';
//         }

//         final total =
//             int.tryParse(
//           _totalStockController.text.trim(),
//         );

//         if (total != null && rented > total) {
//           return 'Cannot exceed total.';
//         }

//         return null;
//       },
//     );
//   }

//   // ============================================================
//   // AVAILABLE STOCK
//   // ============================================================

//   Widget _buildAvailableStock() {
//     return ValueListenableBuilder<TextEditingValue>(
//       valueListenable: _availableStockController,
//       builder: (context, value, child) {
//         final int available =
//             int.tryParse(value.text) ?? 0;

//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 15,
//           ),
//           decoration: BoxDecoration(
//             color: primaryColor.withOpacity(0.06),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: primaryColor.withOpacity(0.18),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: primaryColor.withOpacity(0.10),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.check_circle_outline,
//                   color: primaryColor,
//                   size: 21,
//                 ),
//               ),

//               const SizedBox(width: 12),

//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Available Stock',
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       'Automatically calculated',
//                       style: TextStyle(
//                         fontSize: 11,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Text(
//                 available.toString(),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // INFO BOX
//   // ============================================================

//   Widget _buildInfoBox() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(13),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: borderColor,
//         ),
//       ),
//       child: const Row(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         children: [
//           Icon(
//             Icons.info_outline,
//             color: primaryColor,
//             size: 19,
//           ),
//           SizedBox(width: 9),
//           Expanded(
//             child: Text(
//               'Available Stock = Total Stock − Rented Stock. '
//               'Available Stock cannot be entered manually.',
//               style: TextStyle(
//                 color: secondaryTextColor,
//                 fontSize: 12.5,
//                 height: 1.4,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SAVE BUTTON
//   // ============================================================

//   Widget _buildSaveButton() {
//     return SizedBox(
//       height: 54,
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed:
//             _isSaving ? null : _saveItem,
//         icon: _isSaving
//             ? const SizedBox(
//                 width: 19,
//                 height: 19,
//                 child:
//                     CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : const Icon(
//                 Icons.add_rounded,
//               ),
//         label: Text(
//           _isSaving
//               ? 'Adding Item...'
//               : 'Add Item',
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           disabledBackgroundColor:
//               primaryColor.withOpacity(0.55),
//           disabledForegroundColor:
//               Colors.white,
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CANCEL BUTTON
//   // ============================================================

//   Widget _buildCancelButton() {
//     return SizedBox(
//       height: 54,
//       width: double.infinity,
//       child: OutlinedButton(
//         onPressed: _isSaving
//             ? null
//             : () => Navigator.pop(context),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: textColor,
//           side: const BorderSide(
//             color: borderColor,
//           ),
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(12),
//           ),
//         ),
//         child: const Text(
//           'Cancel',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: textColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INPUT DECORATION
//   // ============================================================

//   InputDecoration _inputDecoration({
//     required String label,
//     required String hint,
//     required IconData icon,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       hintText: hint,
//       prefixIcon: Icon(
//         icon,
//         color: primaryColor,
//         size: 21,
//       ),
//       labelStyle: const TextStyle(
//         color: secondaryTextColor,
//       ),
//       hintStyle: const TextStyle(
//         color: Color(0xFF9CA3AF),
//         fontSize: 13,
//       ),
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding:
//           const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 16,
//       ),
//       border: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: borderColor,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: borderColor,
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//           width: 1.8,
//         ),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//         ),
//       ),
//       focusedErrorBorder:
//           OutlineInputBorder(
//         borderRadius:
//             BorderRadius.circular(11),
//         borderSide:
//             const BorderSide(
//           color: primaryColor,
//           width: 1.8,
//         ),
//       ),
//     );
//   }
// }







import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // ============================================================
  // PREMIUM BEIGE + BRONZE THEME
  // ============================================================

  static const Color backgroundColor = Color(0xFFF7F2EA);
  static const Color surfaceColor = Color(0xFFFFFCF8);
  static const Color bronzeColor = Color(0xFF9A6A3A);
  static const Color bronzeDark = Color(0xFF704823);
  static const Color bronzeLight = Color(0xFFE9D6BC);
  static const Color darkText = Color(0xFF2C2119);
  static const Color mediumText = Color(0xFF59483A);
  static const Color mutedText = Color(0xFF8A7B6E);
  static const Color borderColor = Color(0xFFE6D9CB);
  static const Color softBackground = Color(0xFFF3ECE3);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalStockController =
      TextEditingController();
  final TextEditingController _rentedStockController =
      TextEditingController();
  final TextEditingController _availableStockController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedMaterial;

  bool _isSaving = false;

  final List<String> _categories = [
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
  void initState() {
    super.initState();

    _totalStockController.addListener(_calculateAvailableStock);
    _rentedStockController.addListener(_calculateAvailableStock);

    _availableStockController.text = '0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalStockController.dispose();
    _rentedStockController.dispose();
    _availableStockController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // AVAILABLE STOCK
  // ============================================================

  void _calculateAvailableStock() {
    final int total =
        int.tryParse(_totalStockController.text.trim()) ?? 0;

    final int rented =
        int.tryParse(_rentedStockController.text.trim()) ?? 0;

    final int available = total - rented;

    _availableStockController.text =
        available >= 0 ? available.toString() : '0';
  }

  // ============================================================
  // SAVE ITEM
  // ============================================================

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      _showMessage('Please select a category.');
      return;
    }

    if (_selectedMaterial == null) {
      _showMessage('Please select a material.');
      return;
    }

    final int totalStock =
        int.parse(_totalStockController.text.trim());

    final int rentedStock =
        int.parse(_rentedStockController.text.trim());

    if (rentedStock > totalStock) {
      _showMessage(
        'Rented stock cannot be greater than total stock.',
      );
      return;
    }

    final int availableStock = totalStock - rentedStock;

    final double rentPrice =
        double.parse(_priceController.text.trim());

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        _showMessage(
          'User session expired. Please login again.',
        );

        return;
      }

      final CollectionReference inventoryCollection =
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('inventory');

      await inventoryCollection.add({
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'totalStock': totalStock,
        'rentedStock': rentedStock,
        'availableStock': availableStock,
        'material': _selectedMaterial,
        'rentPrice': rentPrice,
        'description': _descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item added successfully.'),
          backgroundColor: bronzeDark,
        ),
      );

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to add item: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Something went wrong.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bronzeDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: surfaceColor,
        foregroundColor: darkText,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Add Inventory Item',
          style: TextStyle(
            color: darkText,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: borderColor,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isSmallMobile = width < 380;
            final bool isMobile = width < 650;
            final bool isTablet = width >= 650 && width < 1000;

            final double horizontalPadding = isSmallMobile
                ? 12
                : isMobile
                    ? 16
                    : isTablet
                        ? 28
                        : 36;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                isMobile ? 18 : 28,
                horizontalPadding,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(
                          isMobile: isMobile,
                          isSmallMobile: isSmallMobile,
                        ),

                        SizedBox(height: isMobile ? 18 : 24),

                        _buildSectionCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Item Information',
                          subtitle:
                              'Enter the basic information about your rental item.',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                textCapitalization:
                                    TextCapitalization.words,
                                decoration: _inputDecoration(
                                  label: 'Item Name',
                                  hint: 'e.g. Wooden Chair',
                                  icon: Icons.inventory_2_outlined,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter item name.';
                                  }

                                  if (value.trim().length < 2) {
                                    return 'Item name is too short.';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              _responsiveTwoFields(
                                first: _categoryField(),
                                second: _materialField(),
                                mobile: isMobile,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionCard(
                          icon: Icons.inventory_outlined,
                          title: 'Stock Information',
                          subtitle:
                              'Set the total quantity and currently rented quantity.',
                          child: Column(
                            children: [
                              _responsiveTwoFields(
                                first: _totalStockField(),
                                second: _rentedStockField(),
                                mobile: isMobile,
                              ),

                              const SizedBox(height: 18),

                              _buildAvailableStock(),

                              const SizedBox(height: 14),

                              _buildInfoBox(),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        _buildSectionCard(
                          icon: Icons.payments_outlined,
                          title: 'Rental Information',
                          subtitle:
                              'Set the rental price and add optional details.',
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _priceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: _inputDecoration(
                                  label: 'Rental Price / Unit',
                                  hint: 'e.g. 500',
                                  icon: Icons.payments_outlined,
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter rental price.';
                                  }

                                  final number =
                                      double.tryParse(value.trim());

                                  if (number == null) {
                                    return 'Please enter a valid price.';
                                  }

                                  if (number < 0) {
                                    return 'Price cannot be negative.';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: _inputDecoration(
                                  label: 'Description',
                                  hint:
                                      'Optional information about this item...',
                                  icon: Icons.description_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        _buildActionButtons(
                          isMobile: isMobile,
                          isSmallMobile: isSmallMobile,
                        ),

                        const SizedBox(height: 8),
                      ],
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
  // RESPONSIVE TWO FIELD LAYOUT
  // ============================================================

  Widget _responsiveTwoFields({
    required Widget first,
    required Widget second,
    required bool mobile,
  }) {
    if (mobile) {
      return Column(
        children: [
          first,
          const SizedBox(height: 18),
          second,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader({
    required bool isMobile,
    required bool isSmallMobile,
  }) {
    if (isSmallMobile) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerIcon(size: 50),

            const SizedBox(height: 14),

            const Text(
              'Add New Item',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Add a new item to your rental inventory.',
              style: TextStyle(
                color: mutedText,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _headerIcon(size: isMobile ? 52 : 60),

          SizedBox(width: isMobile ? 13 : 17),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add a new item to your rental inventory.',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bronzeLight,
            bronzeColor.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bronzeColor.withOpacity(0.15),
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: bronzeDark,
        size: size * 0.48,
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: bronzeLight.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: bronzeDark,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: mutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: borderColor,
      ),
      boxShadow: [
        BoxShadow(
          color: darkText.withOpacity(0.035),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _categoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: _inputDecoration(
        label: 'Category',
        hint: 'Select category',
        icon: Icons.category_outlined,
      ),
      dropdownColor: surfaceColor,
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 19,
                color: bronzeColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  category,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // MATERIAL
  // ============================================================

  Widget _materialField() {
    return DropdownButtonFormField<String>(
      value: _selectedMaterial,
      isExpanded: true,
      decoration: _inputDecoration(
        label: 'Material',
        hint: 'Select material',
        icon: Icons.layers_outlined,
      ),
      dropdownColor: surfaceColor,
      items: _materials.map((material) {
        return DropdownMenuItem<String>(
          value: material,
          child: Text(
            material,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedMaterial = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a material.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // TOTAL STOCK
  // ============================================================

  Widget _totalStockField() {
    return TextFormField(
      controller: _totalStockController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        label: 'Total Stock',
        hint: 'e.g. 100',
        icon: Icons.inventory_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter total stock.';
        }

        final number = int.tryParse(value.trim());

        if (number == null) {
          return 'Enter a valid number.';
        }

        if (number <= 0) {
          return 'Must be greater than 0.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // RENTED STOCK
  // ============================================================

  Widget _rentedStockField() {
    return TextFormField(
      controller: _rentedStockController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        label: 'Rented Stock',
        hint: 'e.g. 20',
        icon: Icons.assignment_return_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Enter rented stock.';
        }

        final rented = int.tryParse(value.trim());

        if (rented == null) {
          return 'Enter a valid number.';
        }

        if (rented < 0) {
          return 'Cannot be negative.';
        }

        final total = int.tryParse(
          _totalStockController.text.trim(),
        );

        if (total != null && rented > total) {
          return 'Cannot exceed total.';
        }

        return null;
      },
    );
  }

  // ============================================================
  // AVAILABLE STOCK
  // ============================================================

  Widget _buildAvailableStock() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _availableStockController,
      builder: (context, value, child) {
        final int available =
            int.tryParse(value.text) ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: bronzeLight.withOpacity(0.32),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: bronzeColor.withOpacity(0.20),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _smallBronzeIcon(
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Available Stock',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      available.toString(),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: bronzeDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Automatically calculated',
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedText,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  _smallBronzeIcon(
                    Icons.check_circle_outline,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Stock',
                          style: TextStyle(
                            fontSize: 13,
                            color: darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Automatically calculated',
                          style: TextStyle(
                            fontSize: 11,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    available.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: bronzeDark,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _smallBronzeIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bronzeColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: bronzeDark,
        size: 20,
      ),
    );
  }

  // ============================================================
  // INFO BOX
  // ============================================================

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: bronzeColor,
            size: 19,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Text(
              'Available Stock = Total Stock − Rented Stock. '
              'Available Stock cannot be entered manually.',
              style: TextStyle(
                color: mutedText,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons({
    required bool isMobile,
    required bool isSmallMobile,
  }) {
    if (isMobile) {
      return Column(
        children: [
          _buildSaveButton(),
          const SizedBox(height: 11),
          _buildCancelButton(),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSaveButton(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCancelButton(),
        ),
      ],
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveItem,
        icon: _isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.add_rounded,
                size: 21,
              ),
        label: Text(
          _isSaving ? 'Adding Item...' : 'Add Item',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bronzeDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              bronzeDark.withOpacity(0.55),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL BUTTON
  // ============================================================

  Widget _buildCancelButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isSaving
            ? null
            : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(
            color: borderColor,
          ),
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: bronzeColor,
        size: 21,
      ),

      labelStyle: const TextStyle(
        color: mutedText,
        fontSize: 13,
      ),

      hintStyle: const TextStyle(
        color: Color(0xFFA4978B),
        fontSize: 13,
      ),

      filled: true,
      fillColor: surfaceColor,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: bronzeColor,
          width: 1.6,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFB85C38),
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFB85C38),
          width: 1.6,
        ),
      ),
    );
  }
}