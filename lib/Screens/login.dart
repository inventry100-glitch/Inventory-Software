// import 'package:flutter/material.dart';
// import 'package:inventory_management/dashboard.dart';
// import 'login_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController emailController = TextEditingController();

//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;
//   bool obscurePassword = true;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> handleLogin() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final result = await LoginService.login(
//       email: emailController.text.trim(),
//       password: passwordController.text,
//     );

//     if (!mounted) return;

//     setState(() {
//       isLoading = false;
//     });

//     if (result.success) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const AdminDashboard()),
//       );

//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(result.message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   Future<void> handleForgotPassword() async {
//     final email = emailController.text.trim();

//     if (email.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Enter your email first.'),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       return;
//     }

//     final result = await LoginService.resetPassword(email: email);

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(result.message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 430),
//               child: Container(
//                 padding: const EdgeInsets.all(32),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 25,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // Logo
//                       Center(
//                         child: Container(
//                           height: 72,
//                           width: 72,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1565C0),
//                             borderRadius: BorderRadius.circular(18),
//                           ),
//                           child: const Icon(
//                             Icons.inventory_2_rounded,
//                             color: Colors.white,
//                             size: 38,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       const Text(
//                         'Welcome Back',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF17202A),
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       const Text(
//                         'Sign in to manage your inventory',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),

//                       const SizedBox(height: 32),

//                       // Email
//                       const Text(
//                         'Email Address',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       TextFormField(
//                         controller: emailController,
//                         keyboardType: TextInputType.emailAddress,
//                         textInputAction: TextInputAction.next,
//                         decoration: InputDecoration(
//                           hintText: 'Enter your email',
//                           prefixIcon: const Icon(Icons.email_outlined),
//                           filled: true,
//                           fillColor: const Color(0xFFF8F9FA),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Color(0xFFE1E5E8),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF1565C0),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.trim().isEmpty) {
//                             return 'Email is required';
//                           }

//                           final emailRegex = RegExp(
//                             r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
//                           );

//                           if (!emailRegex.hasMatch(value.trim())) {
//                             return 'Enter a valid email address';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // Password
//                       const Text(
//                         'Password',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),

//                       const SizedBox(height: 8),

//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: obscurePassword,
//                         textInputAction: TextInputAction.done,
//                         onFieldSubmitted: (_) {
//                           if (!isLoading) {
//                             handleLogin();
//                           }
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Enter your password',
//                           prefixIcon: const Icon(Icons.lock_outline),
//                           suffixIcon: IconButton(
//                             onPressed: () {
//                               setState(() {
//                                 obscurePassword = !obscurePassword;
//                               });
//                             },
//                             icon: Icon(
//                               obscurePassword
//                                   ? Icons.visibility_outlined
//                                   : Icons.visibility_off_outlined,
//                             ),
//                           ),
//                           filled: true,
//                           fillColor: const Color(0xFFF8F9FA),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Color(0xFFE1E5E8),
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Color(0xFF1565C0),
//                               width: 1.5,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Password is required';
//                           }

//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 10),

//                       // Forgot password
//                         // Align(
//                         //   alignment: Alignment.centerRight,
//                         //   child: TextButton(
//                         //     onPressed: isLoading ? null : handleForgotPassword,
//                         //     child: const Text('Forgot Password?'),
//                         //   ),
//                         // ),

//                       const SizedBox(height: 12),

//                       // Login button
//                       SizedBox(
//                         height: 54,
//                         child: ElevatedButton(
//                           onPressed: isLoading ? null : handleLogin,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF1565C0),
//                             foregroundColor: Colors.white,
//                             elevation: 0,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: isLoading
//                               ? const SizedBox(
//                                   height: 24,
//                                   width: 24,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Colors.white,
//                                   ),
//                                 )
//                               : const Text(
//                                   'LOGIN',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                         ),
//                       ),

//                       const SizedBox(height: 25),

//                       const Text(
//                         'Inventory Management System',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:inventory_management/dashboard.dart';
import 'login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await LoginService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminDashboard(),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> handleForgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result =
        await LoginService.resetPassword(email: email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bronzeDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: mutedText,
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: bronze,
        size: 20,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: bronze,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    final bool mobile = width < 600;
    final bool verySmall = width < 380;

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 18 : 28,
              vertical: mobile ? 20 : 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  verySmall
                      ? 20
                      : mobile
                          ? 25
                          : 34,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(
                    mobile ? 20 : 24,
                  ),
                  border: Border.all(
                    color: border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(.07),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================

                      Center(
                        child: Container(
                          width: mobile ? 66 : 74,
                          height: mobile ? 66 : 74,
                          decoration: BoxDecoration(
                            color: bronze,
                            borderRadius:
                                BorderRadius.circular(19),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    bronze.withOpacity(.20),
                                blurRadius: 15,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: Colors.white,
                            size: mobile ? 32 : 37,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: mobile ? 20 : 24,
                      ),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: mobile ? 25 : 28,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                          letterSpacing: -.3,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Sign in to manage your inventory',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: mutedText,
                        ),
                      ),

                      SizedBox(
                        height: mobile ? 25 : 31,
                      ),

                      // ==================================================
                      // EMAIL LABEL
                      // ==================================================

                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ==================================================
                      // EMAIL
                      // ==================================================

                      TextFormField(
                        controller: emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // PASSWORD LABEL
                      // ==================================================

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // ==================================================
                      // PASSWORD
                      // ==================================================

                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction:
                            TextInputAction.done,
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        onFieldSubmitted: (_) {
                          if (!isLoading) {
                            handleLogin();
                          }
                        },
                        decoration: _inputDecoration(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                            color: bronze,
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Password is required';
                          }

                          return null;
                        },
                      ),

                      // ==================================================
                      // FORGOT PASSWORD
                      // ==================================================

                      // SizedBox(
                      //   height: 5,
                      // ),
                      //
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: isLoading
                      //         ? null
                      //         : handleForgotPassword,
                      //     style: TextButton.styleFrom(
                      //       foregroundColor: bronzeDark,
                      //       padding: EdgeInsets.zero,
                      //     ),
                      //     child: const Text(
                      //       'Forgot Password?',
                      //     ),
                      //   ),
                      // ),

                      SizedBox(
                        height: mobile ? 21 : 25,
                      ),

                      // ==================================================
                      // LOGIN BUTTON
                      // ==================================================

                      SizedBox(
                        height: mobile ? 51 : 54,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bronze,
                            disabledBackgroundColor:
                                bronze.withOpacity(.55),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(
                        height: mobile ? 20 : 25,
                      ),

                      // ==================================================
                      // FOOTER
                      // ==================================================

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: border,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Text(
                              'ADMIN PANEL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.bold,
                                letterSpacing: 1,
                                color: mutedText,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: border,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Inventory Management System',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}