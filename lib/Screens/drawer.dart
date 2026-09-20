// import 'package:flutter/material.dart';
// import 'package:inventory_management/Screens/bill_generate.dart';
// import 'package:inventory_management/Screens/billls_management.dart';
// import 'package:inventory_management/Screens/customers.dart';
// import 'package:inventory_management/Screens/inventory.dart';
// import 'package:inventory_management/Screens/login_service.dart';
// import 'package:inventory_management/dashboard.dart';

// // class MyWidget extends StatefulWidget {
// //   const MyWidget({super.key});

// //   @override
// //   State<MyWidget> createState() => _MyWidgetState();
// // }

// // class _MyWidgetState extends State<MyWidget> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Drawer(

// class AdminDrawer extends StatelessWidget {
//   final int selectedIndex;

//   const AdminDrawer({super.key, required this.selectedIndex});

//   static const Color primaryRed = Color(0xFFE62E2E);
//   static const Color black = Color(0xFF111111);
//   static const Color greyText = Color(0xFF777777);
//   static const Color lightGrey = Color(0xFFF5F5F5);
//   static const Color borderGrey = Color(0xFFE8E8E8);
//   static const Color white = Colors.white;

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: white,
//       width: 300,
//       child: SafeArea(
//         child: Column(
//           children: [
//             // =====================================================
//             // DRAWER HEADER
//             // =====================================================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(18, 15, 18, 12),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: black,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 52,
//                       width: 52,
//                       decoration: BoxDecoration(
//                         color: primaryRed,
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: const Icon(
//                         Icons.inventory_2_rounded,
//                         color: white,
//                         size: 28,
//                       ),
//                     ),

//                     const SizedBox(width: 14),

//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Inventory',
//                             style: TextStyle(
//                               color: white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),

//                           SizedBox(height: 3),

//                           Text(
//                             'Admin Panel',
//                             style: TextStyle(
//                               color: Color(0xFFBDBDBD),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // =====================================================
//             // NAVIGATION LABEL
//             // =====================================================
//             const Padding(
//               padding: EdgeInsets.fromLTRB(23, 8, 20, 8),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'MAIN MENU',
//                   style: TextStyle(
//                     color: greyText,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ),
//             ),

//             // =====================================================
//             // DASHBOARD
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 0,
//               icon: Icons.dashboard_outlined,
//               activeIcon: Icons.dashboard_rounded,
//               title: 'Dashboard',
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AdminDashboard(),
//                   ),
//                 );
//               },
//             ),

//             // =====================================================
//             // INVENTORY
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 1,
//               icon: Icons.inventory_2_outlined,
//               activeIcon: Icons.inventory_2_rounded,
//               title: 'Inventory',
//               onTap: () {
//                 Navigator.pop(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const InventoryScreen(),
//                   ),
//                 );
//               },
//             ),

//             // =====================================================
//             // CUSTOMERS
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 2,
//               icon: Icons.people_outline_rounded,
//               activeIcon: Icons.people_rounded,
//               title: 'Customers',
//               onTap: () {
//                 Navigator.pop(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const CustomersScreen(),
//                   ),
//                 );
//               },
//             ),

//             // =====================================================
//             // BILLS
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 3,
//               icon: Icons.receipt_long_outlined,
//               activeIcon: Icons.receipt_long_rounded,
//               title: 'Bills',
//               onTap: () {
//                 Navigator.pop(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BillScreen()),
//                 );
//               },
//             ),

//             // =====================================================
//             // PAYMENTS / BILL MANAGEMENT
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 4,
//               icon: Icons.payments_outlined,
//               activeIcon: Icons.payments_rounded,
//               title: 'Payments',
//               onTap: () {
//                 Navigator.pop(context);

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const BillsManagementScreen(),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Divider(color: borderGrey, height: 1),
//             ),

//             const SizedBox(height: 8),

//             // =====================================================
//             // SETTINGS
//             // =====================================================
//             _drawerItem(
//               context: context,
//               index: 5,
//               icon: Icons.settings_outlined,
//               activeIcon: Icons.settings_rounded,
//               title: 'Settings',
//               onTap: () {
//                 Navigator.pop(context);

//                 // Settings screen can be connected here.
//               },
//             ),

//             // Push logout to bottom
//             const Spacer(),

//             // =====================================================
//             // LOGOUT
//             // =====================================================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
//               child: Material(
//                 color: const Color(0xFFFFF1F1),
//                 borderRadius: BorderRadius.circular(15),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(15),
//                   onTap: () async {
//                     await LoginService.logout();

//                     if (!context.mounted) return;

//                     Navigator.pushReplacementNamed(context, '/');
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 15,
//                       horizontal: 16,
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.logout_rounded, color: primaryRed, size: 22),

//                         SizedBox(width: 14),

//                         Text(
//                           'Logout',
//                           style: TextStyle(
//                             color: primaryRed,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),

//                         Spacer(),

//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           color: primaryRed,
//                           size: 14,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==============================================================
//   // DRAWER ITEM
//   // ==============================================================

//   Widget _drawerItem({
//     required BuildContext context,
//     required int index,
//     required IconData icon,
//     required IconData activeIcon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     final bool isSelected = selectedIndex == index;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//       child: Material(
//         color: isSelected ? primaryRed.withOpacity(0.10) : Colors.transparent,
//         borderRadius: BorderRadius.circular(13),
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(13),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(13)),
//             child: Row(
//               children: [
//                 // ACTIVE RED INDICATOR
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   width: 4,
//                   height: isSelected ? 25 : 0,
//                   decoration: BoxDecoration(
//                     color: primaryRed,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),

//                 SizedBox(width: isSelected ? 10 : 14),

//                 Icon(
//                   isSelected ? activeIcon : icon,
//                   color: isSelected ? primaryRed : black,
//                   size: 22,
//                 ),

//                 const SizedBox(width: 14),

//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: isSelected ? primaryRed : black,
//                       fontSize: 14,
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w500,
//                     ),
//                   ),
//                 ),

//                 if (isSelected)
//                   const Icon(
//                     Icons.chevron_right_rounded,
//                     color: primaryRed,
//                     size: 20,
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:inventory_management/Screens/bill_generate.dart';
import 'package:inventory_management/Screens/billls_management.dart';
import 'package:inventory_management/Screens/customers.dart';
import 'package:inventory_management/Screens/inventory.dart';
import 'package:inventory_management/Screens/login_service.dart';
import 'package:inventory_management/dashboard.dart';

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
  });

  // ============================================================
  // BEIGE + BRONZE THEME
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
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    // Responsive drawer width.
    // Never wider than 305 and never too wide on small phones.
    final double drawerWidth = screenSize.width < 360
        ? screenSize.width * 0.88
        : screenSize.width < 600
            ? screenSize.width * 0.82
            : 305.0;

    return Drawer(
      backgroundColor: background,
      width: drawerWidth,

      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height -
                  MediaQuery.paddingOf(context).vertical,
            ),

            child: Column(
              children: [

                // ======================================================
                // HEADER
                // ======================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    12,
                    14,
                    15,
                  ),

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5D3D24),
                          Color(0xFF7C5635),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: bronze.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [

                        // ==================================================
                        // APP ICON
                        // ==================================================

                        Container(
                          height: 50,
                          width: 50,

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),

                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Inventory',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              SizedBox(height: 3),

                              Text(
                                'Admin Panel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFFE8D9C9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ==================================================
                        // STATUS DOT
                        // ==================================================

                        Container(
                          height: 8,
                          width: 8,

                          decoration: const BoxDecoration(
                            color: Color(0xFFD9B98A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ======================================================
                // MAIN MENU LABEL
                // ======================================================

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    1,
                    18,
                    8,
                  ),

                  child: Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'MAIN MENU',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                // ======================================================
                // DASHBOARD
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminDashboard(),
                      ),
                    );
                  },
                ),

                // ======================================================
                // INVENTORY
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  title: 'Inventory',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const InventoryScreen(),
                      ),
                    );
                  },
                ),

                // ======================================================
                // CUSTOMERS
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 2,
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  title: 'Customers',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CustomersScreen(),
                      ),
                    );
                  },
                ),

                // ======================================================
                // BILLS
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 3,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  title: 'Bills',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BillScreen(),
                      ),
                    );
                  },
                ),

                // ======================================================
                // PAYMENTS
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 4,
                  icon: Icons.payments_outlined,
                  activeIcon: Icons.payments_rounded,
                  title: 'Payments',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BillsManagementScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ======================================================
                // DIVIDER
                // ======================================================

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Divider(
                    color: border,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 10),

                // ======================================================
                // SETTINGS
                // ======================================================

                _drawerItem(
                  context: context,
                  index: 5,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);

                    // Settings screen can be connected here.
                  },
                ),

                // Small flexible space instead of Spacer().
                const SizedBox(height: 18),

                // ======================================================
                // LOGOUT
                // ======================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    8,
                    14,
                    16,
                  ),

                  child: Material(
                    color: const Color(0xFFF0E1D0),
                    borderRadius: BorderRadius.circular(17),

                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),

                      onTap: () async {
                        await LoginService.logout();

                        if (!context.mounted) return;

                        Navigator.pushReplacementNamed(
                          context,
                          '/',
                        );
                      },

                      child: Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),

                          border: Border.all(
                            color: const Color(0xFFE2CDB5),
                          ),
                        ),

                        child: const Row(
                          children: [

                            Icon(
                              Icons.logout_rounded,
                              color: bronzeDark,
                              size: 21,
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                'Logout',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: darkBrown,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            SizedBox(width: 8),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: bronze,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // DRAWER ITEM
  // ================================================================

  Widget _drawerItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ),

      child: Material(
        color: isSelected
            ? const Color(0xFFEAD8C2)
            : Colors.transparent,

        borderRadius: BorderRadius.circular(15),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),

          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),

            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),

              border: isSelected
                  ? Border.all(
                      color: const Color(0xFFE0C6A7),
                    )
                  : null,
            ),

            child: Row(
              children: [

                // ==================================================
                // ICON
                // ==================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),

                  height: 37,
                  width: 37,

                  decoration: BoxDecoration(
                    color: isSelected
                        ? bronze
                        : const Color(0xFFF0E7DC),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Icon(
                    isSelected ? activeIcon : icon,

                    color: isSelected
                        ? Colors.white
                        : mediumBrown,

                    size: 20,
                  ),
                ),

                const SizedBox(width: 11),

                // ==================================================
                // TITLE
                // ==================================================

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: isSelected
                          ? bronzeDark
                          : darkBrown,

                      fontSize: 14,

                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                // ==================================================
                // ACTIVE ARROW
                // ==================================================

                AnimatedOpacity(
                  duration: const Duration(
                    milliseconds: 150,
                  ),

                  opacity: isSelected ? 1 : 0,

                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: bronze,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
