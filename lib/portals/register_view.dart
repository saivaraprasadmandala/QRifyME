import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/home/loading.dart';
import 'package:app/portals/verify_email.dart';
import '../firebase_options.dart';
import 'login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _uname;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _password;
  late final TextEditingController _cpassword;

  bool _isLoading = false;

  @override
  void initState() {
    _uname = TextEditingController();
    _email = TextEditingController();
    _phone = TextEditingController();
    _password = TextEditingController();
    _cpassword = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _uname.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _cpassword.dispose();
    super.dispose();
  }

  Future addUserDetails(
    String uname,
    String email,
    String phone,
    int blockCount,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      "uname": uname,
      "email": email,
      "phone": phone,
      "blockCount": 0,
    });
  }

  void registerUser() async {
    final uname = _uname.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text.trim();
    final cpassword = _cpassword.text.trim();

    if (uname.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        password == cpassword &&
        password.length >= 8 &&
        phone.length == 10) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        addUserDetails(uname, email, phone, 0);
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const VerifyEmailView();
        }));
        _uname.clear();
        _email.clear();
        _phone.clear();
        _password.clear();
        _cpassword.clear();
      } on FirebaseAuthException catch (e) {
        //print(e.code);
        if (e.code == 'weak-password') {
          showAlertDialog(context, 'Invalid Input', 'Weak password');
        } else if (e.code == 'email-already-in-use') {
          showAlertDialog(context, 'Invalid Input', 'Email already in use');
        } else if (e.code == 'invalid-email') {
          showAlertDialog(context, 'Invalid Input', 'Invalid email');
        } else if (e.code == 'user-not-found') {
          showAlertDialog(context, 'Invalid Input', 'User not found');
        } else if (e.code == 'too-many-requests') {
          showAlertDialog(context, 'Invalid Input',
              'Too many login attempts. Please try again later.');
        } else if (e.code == 'user-disabled') {
          showAlertDialog(context, 'Invalid Input', 'User account disabled');
        } else if (e.code == 'operation-not-allowed') {
          showAlertDialog(context, 'Invalid Input', 'Operation not allowed');
        } else if (e.code == 'invalid-credential') {
          showAlertDialog(context, 'Invalid Input', 'Invalid credential');
        } else if (e.code == 'account-exists-with-different-credential') {
          showAlertDialog(context, 'Invalid Input',
              'An account with the same email already exists but with a different sign-in method');
        } else if (e.code == 'network-request-failed') {
          showAlertDialog(context, 'Invalid Input', 'check your internet');
        }
      } catch (e) {
        // print("something bad happened");
        // print(e
        //     .runtimeType); //this will give the type of exception that occured
        // print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (uname.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter username");
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter your email");
    } else if (!email.contains('@')) {
      showAlertDialog(context, "Invalid Input", "please enter correct email");
    } else if (!email.contains('@')) {
      showAlertDialog(context, "Invalid Input", "please enter correct email");
    } else if (phone.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter your mobile no.");
    } else if (phone.length != 10) {
      showAlertDialog(
          context, "Invalid Input", "please enter correct phone no.");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
    } else if (password.length < 8) {
      showAlertDialog(context, "Invalid Input",
          "password length must be minimum of 8 characters");
    } else if (password != cpassword) {
      showAlertDialog(context, "Invalid Input",
          "password and confirm password are not same");
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        return Column(
                          children: [
                            const Text(
                              "Hello User!!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const Text(
                              " We Are Happy To See You Here",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),

                            // username textfield
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextField(
                                    cursorColor: Colors.deepPurple,
                                    controller: _uname,
                                    decoration: const InputDecoration(
                                      hintText: 'enter username',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //email textfiled
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextField(
                                    controller: _email,
                                    cursorColor: Colors.deepPurple,
                                    decoration: const InputDecoration(
                                      hintText: 'enter email',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //phone text field
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextField(
                                    controller: _phone,
                                    cursorColor: Colors.deepPurple,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'enter mobile no.',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //password textfield
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextField(
                                    controller: _password,
                                    cursorColor: Colors.deepPurple,
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      hintText: 'enter password',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // confirm password textfield
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextField(
                                    controller: _cpassword,
                                    cursorColor: Colors.deepPurple,
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    decoration: const InputDecoration(
                                      hintText: 'enter password again',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            //register button
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: 300,
                                    child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : registerUser,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text(
                                          "REGISTER",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                  ),
                                ]),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "already registered ? ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return const LoginView();
                                        }));
                                      },
                                      child: const Text(
                                        'Login now',
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      )),
                                ]),
                          ],
                        );
                      default:
                        {
                          return const Loading();
                        }
                    }
                  }),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: Loading()),
            ),
        ],
      ),
    );
  }
}

// class VerifyEmailView extends StatefulWidget {
//   const VerifyEmailView({Key? key}) : super(key: key);

//   @override
//   State<VerifyEmailView> createState() => _VerifyEmailViewState();
// }

// class _VerifyEmailViewState extends State<VerifyEmailView> {
//   bool isVerified = false;
//   Timer? timer;

//   Future<void> sendVerificationEmail() async {
//     final user = FirebaseAuth.instance.currentUser!;
//     await user.sendEmailVerification();
//   }

//   Future<void> checkEmailVerified() async {
//     await FirebaseAuth.instance.currentUser!.reload();
//     setState(() {
//       isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
//     });
//     if (isVerified) {
//       timer?.cancel();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     isVerified = FirebaseAuth.instance.currentUser!.emailVerified;

//     if (!isVerified) {
//       sendVerificationEmail();

//       timer = Timer.periodic(const Duration(seconds: 3), (_) {
//         checkEmailVerified();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   void showAlertDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             TextButton(
//               child: const Text(
//                 'OK',
//                 style: TextStyle(color: Colors.deepPurple),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isVerified
//         ? Scaffold(
//             backgroundColor: Colors.white,
//             body: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(
//                   child: Stack(
//                     children: [
//                       Lottie.asset(
//                         'assets/animations/registrationsuccessful.json',
//                         reverse: true,
//                         repeat: true,
//                       ),
//                       Positioned(
//                         top: 16,
//                         right: 16,
//                         child: IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                             Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (BuildContext context) {
//                               return const LoginView();
//                             }));
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : Scaffold(
//             backgroundColor: Colors.grey[300],
//             body: Center(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Lottie.asset(
//                       'assets/animations/email.json',
//                       fit: BoxFit.cover,
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.all(20.0),
//                       child: Text(
//                         "An email has been sent to your mail.\n Please click on it to verify.\nIf there is no mail in your Inbox then check your SPAM.",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     //   const Text("didn't receive any mail ? "),
//                     //   TextButton(
//                     //     onPressed: sendVerificationEmail,
//                     //     child: const Text(
//                     //       "Resend Link",
//                     //       style: TextStyle(color: Colors.deepPurple),
//                     //     ),
//                     //   ),
//                     // ]),
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
// }
