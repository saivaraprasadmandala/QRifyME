import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/admin/host_event.dart';
import 'package:app/attendee/attendee_events_page.dart';
import 'package:app/home/loading.dart';
import 'package:app/portals/forgot_password.dart';
import 'package:app/portals/register_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isLoading = false;

  Future<void> storeUserType(String userType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  void hostLogin() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await storeUserType('host');
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const HostEvent();
        }));
        _email.clear();
        _password.clear();
      } on FirebaseAuthException catch (e) {
        // print(e.code);
        if (e.code == "user-not-found") {
          showAlertDialog(
              context, "Invalid Input", "user not found, please register");
        } else if (e.code == "wrong-password") {
          showAlertDialog(context, "Invalid Input", "incorrect password");
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
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter email");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
    }
  }

  void attendeeLogin() async {
    final email = _email.text.trim();
    final password = _password.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await storeUserType('attendee');
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const Events();
        }));
        _email.clear();
        _password.clear();
      } on FirebaseAuthException catch (e) {
        // print(e.code);
        if (e.code == "user-not-found") {
          showAlertDialog(
              context, "Invalid Input", "user not found, please register");
        } else if (e.code == "wrong-password") {
          showAlertDialog(context, "Invalid Input", "incorrect password");
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
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter email");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
    }
  }

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
      // appBar: AppBar(
      //   title: const Text("Login"),
      // ),
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
                            " Welcome back, you've been missed! ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),

                          //email text field
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
                          //forgot password

                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 30.0),
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return const ForgotPasswordView();
                                        }));
                                      },
                                      child: const Text(
                                        ' forgot password?',
                                        style: TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                ),
                              ]),
                          //Login button

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : hostLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    "LOGIN AS HOST",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 300,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : attendeeLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      "LOGIN AS ATTENDEE",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          //register now button
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "not a member ? ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return const RegisterView();
                                      }));
                                    },
                                    child: const Text(
                                      'Register now',
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
                },
              ),
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
