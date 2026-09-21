// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/add_item.dart';
// import 'package:inventory_management/Screens/bill_generate.dart';
// import 'package:inventory_management/Screens/billls_management.dart';
// import 'package:inventory_management/Screens/customers.dart';
// import 'package:inventory_management/Screens/inventory.dart';
// import 'Screens/login_service.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Inventory Management'),
//         backgroundColor: const Color(0xFF1565C0),
//         foregroundColor: Colors.white,
//       ),

//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Color(0xFF1565C0)),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Icon(Icons.inventory_2, color: Colors.white, size: 45),
//                   SizedBox(height: 10),
//                   Text(
//                     'Admin Panel',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             ListTile(
//               leading: Icon(Icons.dashboard),
//               title: Text('Dashboard'),
//               selected: true,
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),

//             ListTile(
//               leading: Icon(Icons.inventory_2),
//               title: Text('Inventory'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const InventoryScreen(),
//                   ),
//                 );
//               },
//             ),

//             ListTile(
//               leading: Icon(Icons.people),
//               title: Text('Customers'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const CustomersScreen(),
//                   ),
//                 );
//               },
//             ),

//             ListTile(
//               leading: Icon(Icons.receipt_long),
//               title: Text('Bills'),
//                onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const BillScreen(),
//                   ),
//                 );
//               },
//             ),

//             ListTile(
//               leading: Icon(Icons.payments),
//               title: Text('Payments'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const BillsManagementScreen(),
//                   ),
//                 );
//               },
//             ),

//             const Divider(),

//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Settings'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Logout', style: TextStyle(color: Colors.red)),
//               onTap: () async {
//                 await LoginService.logout();

//                 if (!context.mounted) return;

//                 Navigator.pushReplacementNamed(context, '/');
//               },
//             ),
//           ],
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Dashboard',
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 8),

//             const Text(
//               'Manage your inventory, customers and rental bills.',
//               style: TextStyle(color: Colors.grey, fontSize: 15),
//             ),

//             const SizedBox(height: 25),

//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 15,
//               mainAxisSpacing: 15,
//               childAspectRatio: 1.5,
//               children: [
//                 _dashboardCard(
//                   icon: Icons.inventory_2,
//                   title: 'Total Items',
//                   value: '0',
//                 ),

//                 _dashboardCard(
//                   icon: Icons.shopping_cart,
//                   title: 'Rented Items',
//                   value: '0',
//                 ),

//                 _dashboardCard(
//                   icon: Icons.people,
//                   title: 'Customers',
//                   value: '0',
//                 ),

//                 _dashboardCard(
//                   icon: Icons.receipt_long,
//                   title: 'Active Bills',
//                   value: '0',
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             const Text(
//               'Quick Actions',
//               style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 15),

//             Row(
//               children: [
//                 Expanded(
//                   child: _actionButton(
//                     icon: Icons.add_box,
//                     title: 'Add Item',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const AddItemScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: _actionButton(
//                     icon: Icons.add_shopping_cart,
//                     title: 'New Bill',
//                     onTap: () {
//                       // New Bill screen later
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dashboardCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(18),
//         child: Row(
//           children: [
//             Icon(icon, size: 35, color: const Color(0xFF1565C0)),

//             const SizedBox(width: 15),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(title, style: const TextStyle(color: Colors.grey)),

//                   const SizedBox(height: 5),

//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _actionButton({
//     required IconData icon,
//     required String title,
//     VoidCallback? onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 30, color: Colors.blue),
//             const SizedBox(height: 8),
//             Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/add_item.dart';
// import 'package:inventory_management/Screens/bill_generate.dart';
// import 'package:inventory_management/Screens/billls_management.dart';
// import 'package:inventory_management/Screens/customers.dart';
// import 'package:inventory_management/Screens/drawer.dart';
// import 'package:inventory_management/Screens/inventory.dart';
// import 'Screens/login_service.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   // =========================
//   // APP COLORS
//   // =========================

//   static const Color primaryRed = Color(0xFFE62E2E);
//   static const Color black = Color(0xFF111111);
//   static const Color darkText = Color(0xFF1A1A1A);
//   static const Color greyText = Color(0xFF777777);
//   static const Color lightGrey = Color(0xFFF5F5F5);
//   static const Color borderGrey = Color(0xFFE8E8E8);
//   static const Color white = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,

//       // =========================
//       // APP BAR
//       // =========================

//       appBar: AppBar(
//         backgroundColor: white,
//         elevation: 0,
//         scrolledUnderElevation: 0,

//         leading: Builder(
//           builder: (context) {
//             return IconButton(
//               icon: const Icon(
//                 Icons.menu_rounded,
//                 color: black,
//                 size: 27,
//               ),
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//             );
//           },
//         ),

//         title: const Text(
//           'Dashboard',
//           style: TextStyle(
//             color: black,
//             fontSize: 21,
//             fontWeight: FontWeight.w700,
//           ),
//         ),

//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               color: lightGrey,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: IconButton(
//               tooltip: 'Settings',
//               icon: const Icon(
//                 Icons.settings_outlined,
//                 color: black,
//                 size: 22,
//               ),
//               onPressed: () {
//                 // Settings screen can be added later.
//               },
//             ),
//           ),
//         ],
//       ),

//       // =========================
//       // DRAWER
//       // =========================

//       drawer: const AdminDrawer(
//         selectedIndex: 0,
//       ),

//       // =========================
//       // BODY
//       // =========================

//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // =========================
//               // WELCOME SECTION
//               // =========================

//               const Text(
//                 'Welcome back 👋',
//                 style: TextStyle(
//                   color: greyText,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const SizedBox(height: 5),

//               const Text(
//                 'Admin Dashboard',
//                 style: TextStyle(
//                   color: black,
//                   fontSize: 28,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: -0.5,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               const Text(
//                 'Manage your inventory, customers and rental bills.',
//                 style: TextStyle(
//                   color: greyText,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // =========================
//               // STAT CARDS
//               // =========================

//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final double cardWidth =
//                       (constraints.maxWidth - 14) / 2;

//                   return Wrap(
//                     spacing: 14,
//                     runSpacing: 14,
//                     children: [
//                       SizedBox(
//                         width: cardWidth,
//                         child: _dashboardCard(
//                           icon: Icons.inventory_2_outlined,
//                           title: 'Total Items',
//                           value: '0',
//                         ),
//                       ),

//                       SizedBox(
//                         width: cardWidth,
//                         child: _dashboardCard(
//                           icon: Icons.shopping_cart_outlined,
//                           title: 'Rented Items',
//                           value: '0',
//                         ),
//                       ),

//                       SizedBox(
//                         width: cardWidth,
//                         child: _dashboardCard(
//                           icon: Icons.people_outline_rounded,
//                           title: 'Customers',
//                           value: '0',
//                         ),
//                       ),

//                       SizedBox(
//                         width: cardWidth,
//                         child: _dashboardCard(
//                           icon: Icons.receipt_long_outlined,
//                           title: 'Active Bills',
//                           value: '0',
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),

//               const SizedBox(height: 32),

//               // =========================
//               // QUICK ACTIONS
//               // =========================

//               const Text(
//                 'Quick Actions',
//                 style: TextStyle(
//                   color: black,
//                   fontSize: 21,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),

//               const SizedBox(height: 6),

//               const Text(
//                 'Quickly access your most used actions.',
//                 style: TextStyle(
//                   color: greyText,
//                   fontSize: 13,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Row(
//                 children: [
//                   Expanded(
//                     child: _actionButton(
//                       icon: Icons.add_box_outlined,
//                       title: 'Add Item',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const AddItemScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(width: 14),

//                   Expanded(
//                     child: _actionButton(
//                       icon: Icons.receipt_long_outlined,
//                       title: 'New Bill',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const BillScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 30),

//               // =========================
//               // OVERVIEW CARD
//               // =========================

//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: black,
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 48,
//                       width: 48,
//                       decoration: BoxDecoration(
//                         color: primaryRed,
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: const Icon(
//                         Icons.analytics_outlined,
//                         color: white,
//                         size: 25,
//                       ),
//                     ),

//                     const SizedBox(width: 15),

//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Inventory Overview',
//                             style: TextStyle(
//                               color: white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),

//                           SizedBox(height: 5),

//                           Text(
//                             'Keep track of your rental items and customers.',
//                             style: TextStyle(
//                               color: Color(0xFFBDBDBD),
//                               fontSize: 12,
//                               height: 1.4,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       color: white,
//                       size: 17,
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
//   // DASHBOARD CARD
//   // ============================================================

//   Widget _dashboardCard({
//     required IconData icon,
//     required String title,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(17),
//         border: Border.all(
//           color: borderGrey,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.035),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           // ICON
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               color: primaryRed.withOpacity(0.09),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.inventory_2_outlined,
//               color: primaryRed,
//               size: 21,
//             ),
//           ),

//           const SizedBox(height: 17),

//           Text(
//             title,
//             style: const TextStyle(
//               color: greyText,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             value,
//             style: const TextStyle(
//               color: black,
//               fontSize: 25,
//               fontWeight: FontWeight.w800,
//             ),
//           ),

//           const SizedBox(height: 4),

//           Container(
//             height: 3,
//             width: 25,
//             decoration: BoxDecoration(
//               color: primaryRed,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // QUICK ACTION BUTTON
//   // ============================================================

//   Widget _actionButton({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//             vertical: 19,
//             horizontal: 12,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: borderGrey,
//             ),
//           ),
//           child: Column(
//             children: [

//               Container(
//                 height: 46,
//                 width: 46,
//                 decoration: BoxDecoration(
//                   color: primaryRed.withOpacity(0.09),
//                   borderRadius: BorderRadius.circular(13),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: primaryRed,
//                   size: 24,
//                 ),
//               ),

//               const SizedBox(height: 11),

//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: black,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ================================================================
// // ADMIN DRAWER
// // ================================================================

// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/add_item.dart';
// import 'package:inventory_management/Screens/bill_generate.dart';
// import 'package:inventory_management/Screens/drawer.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   // ============================================================
//   // PREMIUM BEIGE + BRONZE THEME
//   // ============================================================

//   static const Color background = Color(0xFFF7F2EA);
//   static const Color surface = Color(0xFFFFFCF8);
//   static const Color bronze = Color(0xFF9A6A3A);
//   static const Color bronzeDark = Color(0xFF704823);
//   static const Color bronzeLight = Color(0xFFE9D6BC);

//   static const Color darkBrown = Color(0xFF2C2119);
//   static const Color mediumBrown = Color(0xFF59483A);
//   static const Color mutedText = Color(0xFF8A7B6E);

//   static const Color border = Color(0xFFE8DDD0);
//   static const Color white = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,

//       // ============================================================
//       // APP BAR
//       // ============================================================

//       appBar: AppBar(
//         backgroundColor: background,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         scrolledUnderElevation: 0,

//         leading: Builder(
//           builder: (context) {
//             return Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: IconButton(
//                 tooltip: 'Menu',
//                 icon: const Icon(
//                   Icons.menu_rounded,
//                   color: darkBrown,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//               ),
//             );
//           },
//         ),

//         titleSpacing: 4,

//         title: const Text(
//           'Dashboard',
//           style: TextStyle(
//             color: darkBrown,
//             fontSize: 21,
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.3,
//           ),
//         ),

//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               color: surface,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(
//                 color: border,
//               ),
//             ),
//             child: IconButton(
//               tooltip: 'Settings',
//               icon: const Icon(
//                 Icons.settings_outlined,
//                 color: mediumBrown,
//                 size: 21,
//               ),
//               onPressed: () {
//                 // Settings can be added later.
//               },
//             ),
//           ),
//         ],
//       ),

//       // ============================================================
//       // DRAWER
//       // ============================================================

//       drawer: const AdminDrawer(
//         selectedIndex: 0,
//       ),

//       // ============================================================
//       // BODY
//       // ============================================================

//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final bool isMobile = constraints.maxWidth < 600;
//             final bool isTablet = constraints.maxWidth >= 600 &&
//                 constraints.maxWidth < 1000;

//             return SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),

//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile
//                     ? 16
//                     : isTablet
//                         ? 28
//                         : 42,
//                 vertical: 12,
//               ),

//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: 1250,
//                   ),

//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [

//                       // ==================================================
//                       // WELCOME HEADER
//                       // ==================================================

//                       _buildWelcomeSection(
//                         isMobile: isMobile,
//                       ),

//                       const SizedBox(height: 28),

//                       // ==================================================
//                       // STAT CARDS
//                       // ==================================================

//                       _buildStatsSection(
//                         context,
//                         isMobile: isMobile,
//                         isTablet: isTablet,
//                       ),

//                       const SizedBox(height: 34),

//                       // ==================================================
//                       // QUICK ACTIONS
//                       // ==================================================

//                       _buildQuickActions(
//                         context,
//                         isMobile: isMobile,
//                       ),

//                       const SizedBox(height: 32),

//                       // ==================================================
//                       // OVERVIEW
//                       // ==================================================

//                       _buildOverviewCard(
//                         isMobile: isMobile,
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ================================================================
//   // WELCOME SECTION
//   // ================================================================

//   Widget _buildWelcomeSection({
//     required bool isMobile,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'WELCOME BACK',
//           style: TextStyle(
//             color: bronze,
//             fontSize: isMobile ? 11 : 12,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 1.5,
//           ),
//         ),

//         const SizedBox(height: 7),

//         Text(
//           'Admin Dashboard',
//           style: TextStyle(
//             color: darkBrown,
//             fontSize: isMobile ? 27 : 32,
//             fontWeight: FontWeight.w900,
//             letterSpacing: -0.8,
//           ),
//         ),

//         const SizedBox(height: 7),

//         Text(
//           'Manage your inventory, customers and rental bills.',
//           style: TextStyle(
//             color: mutedText,
//             fontSize: isMobile ? 13 : 14,
//             height: 1.5,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   // ================================================================
//   // STAT SECTION
//   // ================================================================

//   Widget _buildStatsSection(
//     BuildContext context, {
//     required bool isMobile,
//     required bool isTablet,
//   }) {
//     int columns;

//     if (isMobile) {
//       columns = 1;
//     } else if (isTablet) {
//       columns = 2;
//     } else {
//       columns = 4;
//     }

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         const double spacing = 14;

//         final double cardWidth =
//             (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

//         return Wrap(
//           spacing: spacing,
//           runSpacing: spacing,
//           children: [
//             SizedBox(
//               width: cardWidth,
//               child: _dashboardCard(
//                 icon: Icons.inventory_2_outlined,
//                 title: 'Total Items',
//                 value: '0',
//                 iconBackground: const Color(0xFFF0E2D1),
//               ),
//             ),

//             SizedBox(
//               width: cardWidth,
//               child: _dashboardCard(
//                 icon: Icons.shopping_bag_outlined,
//                 title: 'Rented Items',
//                 value: '0',
//                 iconBackground: const Color(0xFFE8D6C0),
//               ),
//             ),

//             SizedBox(
//               width: cardWidth,
//               child: _dashboardCard(
//                 icon: Icons.people_outline_rounded,
//                 title: 'Customers',
//                 value: '0',
//                 iconBackground: const Color(0xFFEBDDD0),
//               ),
//             ),

//             SizedBox(
//               width: cardWidth,
//               child: _dashboardCard(
//                 icon: Icons.receipt_long_outlined,
//                 title: 'Active Bills',
//                 value: '0',
//                 iconBackground: const Color(0xFFF1E5D6),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ================================================================
//   // DASHBOARD CARD
//   // ================================================================

//   Widget _dashboardCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required Color iconBackground,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(18),

//       decoration: BoxDecoration(
//         color: surface,
//         borderRadius: BorderRadius.circular(20),

//         border: Border.all(
//           color: border,
//           width: 1,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF6D4C32).withOpacity(0.06),
//             blurRadius: 18,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ICON
//           Container(
//             height: 46,
//             width: 46,

//             decoration: BoxDecoration(
//               color: iconBackground,
//               borderRadius: BorderRadius.circular(14),
//             ),

//             child: Icon(
//               icon,
//               color: bronzeDark,
//               size: 22,
//             ),
//           ),

//           const SizedBox(height: 18),

//           Text(
//             title,
//             style: const TextStyle(
//               color: mutedText,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 5),

//           Text(
//             value,
//             style: const TextStyle(
//               color: darkBrown,
//               fontSize: 27,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -0.5,
//             ),
//           ),

//           const SizedBox(height: 10),

//           Container(
//             height: 3,
//             width: 30,
//             decoration: BoxDecoration(
//               color: bronze,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================================================================
//   // QUICK ACTIONS
//   // ================================================================

//   Widget _buildQuickActions(
//     BuildContext context, {
//     required bool isMobile,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Quick Actions',
//           style: TextStyle(
//             color: darkBrown,
//             fontSize: 21,
//             fontWeight: FontWeight.w800,
//           ),
//         ),

//         const SizedBox(height: 6),

//         const Text(
//           'Quickly access your most used actions.',
//           style: TextStyle(
//             color: mutedText,
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),

//         const SizedBox(height: 17),

//         if (isMobile)
//           Column(
//             children: [
//               _actionButton(
//                 icon: Icons.add_box_outlined,
//                 title: 'Add Item',
//                 subtitle: 'Add new rental item',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const AddItemScreen(),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 12),

//               _actionButton(
//                 icon: Icons.receipt_long_outlined,
//                 title: 'New Bill',
//                 subtitle: 'Create rental bill',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const BillScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           )
//         else
//           Row(
//             children: [
//               Expanded(
//                 child: _actionButton(
//                   icon: Icons.add_box_outlined,
//                   title: 'Add Item',
//                   subtitle: 'Add new rental item',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const AddItemScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               const SizedBox(width: 14),

//               Expanded(
//                 child: _actionButton(
//                   icon: Icons.receipt_long_outlined,
//                   title: 'New Bill',
//                   subtitle: 'Create rental bill',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const BillScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   // ================================================================
//   // ACTION BUTTON
//   // ================================================================

//   Widget _actionButton({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: surface,
//       borderRadius: BorderRadius.circular(18),

//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(18),

//         child: Container(
//           padding: const EdgeInsets.all(17),

//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(18),

//             border: Border.all(
//               color: border,
//             ),

//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF6D4C32).withOpacity(0.045),
//                 blurRadius: 14,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),

//           child: Row(
//             children: [
//               Container(
//                 height: 48,
//                 width: 48,

//                 decoration: BoxDecoration(
//                   color: bronzeLight,
//                   borderRadius: BorderRadius.circular(14),
//                 ),

//                 child: Icon(
//                   icon,
//                   color: bronzeDark,
//                   size: 23,
//                 ),
//               ),

//               const SizedBox(width: 14),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: darkBrown,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),

//                     const SizedBox(height: 3),

//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         color: mutedText,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: bronze,
//                 size: 15,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ================================================================
//   // OVERVIEW CARD
//   // ================================================================

//   Widget _buildOverviewCard({
//     required bool isMobile,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(
//         isMobile ? 18 : 22,
//       ),

//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xFF5D3D24),
//             Color(0xFF7B5432),
//           ],

//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),

//         borderRadius: BorderRadius.circular(22),

//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF6D4C32).withOpacity(0.18),
//             blurRadius: 22,
//             offset: const Offset(0, 9),
//           ),
//         ],
//       ),

//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             height: isMobile ? 46 : 52,
//             width: isMobile ? 46 : 52,

//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(15),
//             ),

//             child: const Icon(
//               Icons.analytics_outlined,
//               color: Colors.white,
//               size: 25,
//             ),
//           ),

//           const SizedBox(width: 15),

//           const Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Inventory Overview',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),

//                 SizedBox(height: 5),

//                 Text(
//                   'Keep track of your rental items, customers and active bills.',
//                   style: TextStyle(
//                     color: Color(0xFFE9DDD0),
//                     fontSize: 12,
//                     height: 1.45,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 10),

//           const Icon(
//             Icons.arrow_forward_ios_rounded,
//             color: Colors.white,
//             size: 16,
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/add_item.dart';
import 'package:inventory_management/Screens/bill_generate.dart';
import 'package:inventory_management/Screens/customers.dart';
import 'package:inventory_management/Screens/drawer.dart';
import 'package:inventory_management/Screens/inventory.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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

  // ============================================================
  // FIRESTORE
  // ============================================================

  // final FirebaseFirestore _db =
  //     FirebaseFirestore.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> _userCollection(
    String collectionName,
  ) {
    return _db.collection('Users').doc(_uid).collection(collectionName);
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int _totalItems = 0;
  int _rentedItems = 0;
  int _customers = 0;
  int _activeBills = 0;

  bool _loading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  // Future<void> _loadDashboardData() async {
  //   try {
  //     final inventorySnapshot =
  //         await _db.collection('inventory').get();

  //     final billsSnapshot =
  //         await _db.collection('bills').get();

  //     // ----------------------------------------------------------
  //     // INVENTORY
  //     // ----------------------------------------------------------

  //     int totalItems = 0;
  //     int rentedItems = 0;

  //     for (final doc in inventorySnapshot.docs) {
  //       final data = doc.data();

  //       totalItems += _toInt(
  //         data['totalStock'],
  //       );

  //       rentedItems += _toInt(
  //         data['rentedStock'],
  //       );
  //     }

  //     // ----------------------------------------------------------
  //     // CUSTOMERS + ACTIVE BILLS
  //     // ----------------------------------------------------------

  //     final Set<String> customers = {};

  //     int activeBills = 0;

  //     for (final doc in billsSnapshot.docs) {
  //       final data = doc.data();

  //       final String customerName =
  //           (data['customerName'] ?? '')
  //               .toString()
  //               .trim();

  //       final String contact =
  //           (data['contactNumber'] ?? '')
  //               .toString()
  //               .trim();

  //       final String cnic =
  //           (data['cnic'] ?? '')
  //               .toString()
  //               .trim();

  //       // --------------------------------------------------------
  //       // UNIQUE CUSTOMER
  //       // --------------------------------------------------------

  //       String customerKey = '';

  //       if (contact.isNotEmpty) {
  //         customerKey = 'contact:$contact';
  //       } else if (cnic.isNotEmpty) {
  //         customerKey = 'cnic:$cnic';
  //       } else if (customerName.isNotEmpty) {
  //         customerKey =
  //             'name:${customerName.toLowerCase()}';
  //       }

  //       if (customerKey.isNotEmpty) {
  //         customers.add(customerKey);
  //       }

  //       // --------------------------------------------------------
  //       // ACTIVE BILL
  //       // --------------------------------------------------------

  //       final String rentalStatus =
  //           (data['rentalStatus'] ?? 'rented')
  //               .toString()
  //               .toLowerCase()
  //               .trim();

  //       if (rentalStatus != 'returned' &&
  //           rentalStatus != 'completed' &&
  //           rentalStatus != 'cancelled') {
  //         activeBills++;
  //       }
  //     }

  //     if (!mounted) return;

  //     setState(() {
  //       _totalItems = totalItems;
  //       _rentedItems = rentedItems;
  //       _customers = customers.length;
  //       _activeBills = activeBills;
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     debugPrint(
  //       'Dashboard error: $e',
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  Future<void> _loadDashboardData() async {
    try {
      // ==========================================================
      // USER-SPECIFIC COLLECTIONS
      // ==========================================================

      final inventoryCollection = _userCollection('inventory');

      final customersCollection = _userCollection('customers');

      final billsCollection = _userCollection('bills');

      // ==========================================================
      // FETCH USER DATA
      // ==========================================================

      final inventorySnapshot = await inventoryCollection.get();

      final customersSnapshot = await customersCollection.get();

      final billsSnapshot = await billsCollection.get();

      // ==========================================================
      // INVENTORY
      // ==========================================================

      int totalItems = 0;
      int rentedItems = 0;

      for (final doc in inventorySnapshot.docs) {
        final data = doc.data();

        totalItems += _toInt(data['totalStock']);

        rentedItems += _toInt(data['rentedStock']);
      }

      // ==========================================================
      // CUSTOMERS
      // ==========================================================

      int customersCount = customersSnapshot.docs.length;

      // ==========================================================
      // ACTIVE BILLS
      // ==========================================================

      int activeBills = 0;

      for (final doc in billsSnapshot.docs) {
        final data = doc.data();

        final String rentalStatus = (data['rentalStatus'] ?? 'rented')
            .toString()
            .toLowerCase()
            .trim();

        if (rentalStatus != 'returned' &&
            rentalStatus != 'completed' &&
            rentalStatus != 'cancelled') {
          activeBills++;
        }
      }

      // ==========================================================
      // UPDATE UI
      // ==========================================================

      if (!mounted) return;

      setState(() {
        _totalItems = totalItems;
        _rentedItems = rentedItems;
        _customers = customersCount;
        _activeBills = activeBills;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // NUMBER CONVERTER
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshDashboard() async {
    setState(() {
      _loading = true;
    });

    await _loadDashboardData();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InventoryScreen()),
    ).then((_) {
      _loadDashboardData();
    });
  }

  void _openCustomers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CustomersScreen()),
    ).then((_) {
      _loadDashboardData();
    });
  }

  void _openBills() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BillScreen()),
    ).then((_) {
      _loadDashboardData();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                tooltip: 'Menu',
                icon: const Icon(
                  Icons.menu_rounded,
                  color: darkBrown,
                  size: 28,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),

        titleSpacing: 4,

        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: darkBrown,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),

        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 14, top: 7, bottom: 7),
        //     decoration: BoxDecoration(
        //       color: surface,
        //       borderRadius: BorderRadius.circular(13),
        //       border: Border.all(color: border),
        //     ),
        //     child: IconButton(
        //       tooltip: 'Refresh',
        //       icon: Icon(
        //         _loading ? Icons.sync_rounded : Icons.refresh_rounded,
        //         color: mediumBrown,
        //         size: 21,
        //       ),
        //       onPressed: _loading ? null : _refreshDashboard,
        //     ),
        //   ),
        // ],
      ),

      // ==========================================================
      // DRAWER
      // ==========================================================
      drawer: const AdminDrawer(selectedIndex: 0),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;

            final bool isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1000;

            return RefreshIndicator(
              color: bronze,
              backgroundColor: surface,
              onRefresh: _refreshDashboard,

              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),

                padding: EdgeInsets.fromLTRB(
                  isMobile
                      ? 16
                      : isTablet
                      ? 28
                      : 42,
                  10,
                  isMobile
                      ? 16
                      : isTablet
                      ? 28
                      : 42,
                  30,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1250),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // WELCOME
                        // ==================================================
                        _buildWelcomeSection(isMobile: isMobile),

                        const SizedBox(height: 24),

                        // ==================================================
                        // QUICK ACTIONS
                        // ==================================================
                        _buildQuickActions(context),

                        const SizedBox(height: 30),

                        // ==================================================
                        // OVERVIEW HEADING
                        // ==================================================
                        const Text(
                          'Overview',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'A quick look at your business.',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // STAT CARDS
                        // ==================================================
                        _buildStatsSection(),

                        const SizedBox(height: 28),

                        // ==================================================
                        // INVENTORY SUMMARY
                        // ==================================================
                        _buildInventoryOverview(isMobile: isMobile),
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

  // ================================================================
  // WELCOME
  // ================================================================

  Widget _buildWelcomeSection({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 23),

      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C32).withOpacity(0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: isMobile ? 48 : 54,
            width: isMobile ? 48 : 54,

            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [bronze, bronzeDark]),
              borderRadius: BorderRadius.circular(16),
            ),

            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    color: bronze,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Admin Dashboard',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: isMobile ? 23 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Manage your inventory, customers and rental bills.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mutedText, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // QUICK ACTIONS
  // ================================================================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: darkBrown,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Start a common task quickly.',
          style: TextStyle(color: mutedText, fontSize: 12),
        ),

        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.add_box_rounded,
                title: 'Add Item',
                subtitle: 'Add new inventory',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddItemScreen(),
                    ),
                  ).then((_) {
                    _loadDashboardData();
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _quickActionCard(
                icon: Icons.receipt_long_rounded,
                title: 'New Bill',
                subtitle: 'Create rental bill',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BillScreen()),
                  ).then((_) {
                    _loadDashboardData();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ================================================================
  // QUICK ACTION CARD
  // ================================================================

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6D4C32).withOpacity(0.055),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0DFCA), Color(0xFFE4C8A8)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: bronzeDark, size: 22),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 29,
                width: 29,

                decoration: BoxDecoration(
                  color: const Color(0xFFF4EADF),
                  borderRadius: BorderRadius.circular(9),
                ),

                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: bronze,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // STATISTICS
  // ================================================================

  Widget _buildStatsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;

        final double cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // --------------------------------------------------------
            // TOTAL ITEMS
            // --------------------------------------------------------
            SizedBox(
              width: cardWidth,
              child: _detailStatCard(
                icon: Icons.inventory_2_outlined,
                title: 'Total Items',
                value: _totalItems,
                description: 'All inventory stock',
                iconBackground: const Color(0xFFF0E2D1),
                onDetails: _openInventory,
              ),
            ),

            // --------------------------------------------------------
            // RENTED ITEMS
            // --------------------------------------------------------
            SizedBox(
              width: cardWidth,
              child: _detailStatCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Rented Items',
                value: _rentedItems,
                description: 'Currently rented units',
                iconBackground: const Color(0xFFE8D6C0),
                onDetails: _openInventory,
              ),
            ),

            // --------------------------------------------------------
            // CUSTOMERS
            // --------------------------------------------------------
            SizedBox(
              width: cardWidth,
              child: _detailStatCard(
                icon: Icons.people_outline_rounded,
                title: 'Customers',
                value: _customers,
                description: 'Registered customers',
                iconBackground: const Color(0xFFEBDDD0),
                onDetails: _openCustomers,
              ),
            ),

            // --------------------------------------------------------
            // ACTIVE BILLS
            // --------------------------------------------------------
            SizedBox(
              width: cardWidth,
              child: _detailStatCard(
                icon: Icons.receipt_long_outlined,
                title: 'Active Rentals',
                value: _activeBills,
                description: 'Bills not yet returned',
                iconBackground: const Color(0xFFF1E5D6),
                onDetails: _openCustomers,
              ),
            ),
          ],
        );
      },
    );
  }

  // ================================================================
  // DETAIL STAT CARD
  // ================================================================

  Widget _detailStatCard({
    required IconData icon,
    required String title,
    required int value,
    required String description,
    required Color iconBackground,
    required VoidCallback onDetails,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),

      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C32).withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // TOP
          // --------------------------------------------------------
          Row(
            children: [
              Container(
                height: 42,
                width: 42,

                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: bronzeDark, size: 21),
              ),

              const Spacer(),

              Container(
                height: 6,
                width: 6,
                decoration: const BoxDecoration(
                  color: bronze,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // TITLE
          // --------------------------------------------------------
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          // --------------------------------------------------------
          // VALUE
          // --------------------------------------------------------
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),

            child: _loading
                ? Container(
                    key: const ValueKey('loading'),
                    height: 32,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE3D8),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  )
                : Text(
                    value.toString(),
                    key: ValueKey(value),
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
          ),

          const SizedBox(height: 3),

          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------------
          // SEE DETAILS
          // --------------------------------------------------------
          InkWell(
            onTap: onDetails,
            borderRadius: BorderRadius.circular(8),

            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'See Details',
                    style: TextStyle(
                      color: bronzeDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: bronze,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // INVENTORY OVERVIEW
  // ================================================================

  Widget _buildInventoryOverview({required bool isMobile}) {
    final int available = _totalItems - _rentedItems;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D3D24), Color(0xFF7B5432)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(21),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D4C32).withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventory Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Current stock availability',
                      style: TextStyle(color: Color(0xFFE8D9CA), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _overviewValue('Total', _totalItems)),

              Container(
                height: 42,
                width: 1,
                color: Colors.white.withOpacity(0.15),
              ),

              Expanded(child: _overviewValue('Rented', _rentedItems)),

              Container(
                height: 42,
                width: 1,
                color: Colors.white.withOpacity(0.15),
              ),

              Expanded(
                child: _overviewValue(
                  'Available',
                  available < 0 ? 0 : available,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // OVERVIEW VALUE
  // ================================================================

  Widget _overviewValue(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFE8D9CA),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
