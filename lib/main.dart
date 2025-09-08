import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'pages/sign_in_page.dart';
import 'pages/home_page.dart';
import 'data/sn_parser.dart';

import 'dart:async';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await loadSnPrefixesFromFirebase();
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiltonBro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ConnectionGuard(child: _Root()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Root extends StatelessWidget {
  const _Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage(); // user is signed in
        } else {
          return const SignInPage(); // not signed in
        }
      },
    );
  }
}

class ConnectionGuard extends StatefulWidget {
  final Widget child;
  const ConnectionGuard({super.key, required this.child});

  @override
  State<ConnectionGuard> createState() => _ConnectionGuardState();
}

class _ConnectionGuardState extends State<ConnectionGuard> {
  late StreamSubscription _subscription;
  bool _offline = false;

  @override
  void initState() {
    super.initState();

    // Listen for actual internet status
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _offline = (status == InternetStatus.disconnected);
      });
    });

    // Initial check
    InternetConnection().hasInternetAccess.then((hasInternet) {
      setState(() => _offline = !hasInternet);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_offline) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                "No Internet Connection",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("Please check your network and try again."),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
