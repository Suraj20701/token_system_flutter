import 'package:flutter/material.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("M-Scan"),
          bottom: PreferredSize(
            preferredSize: const Size(
              double.infinity,
              40,
            ),
            child: TabBar(
              padding: const EdgeInsets.all(16),
              labelStyle: Theme.of(context).textTheme.headlineSmall,
              labelColor: Colors.white,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Text(
                  "Accounts",
                ),
                Text(
                  "Scanner",
                ),
              ],
            ),
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              AccountWidget(),
              QRScanner(),
            ],
          ),
        ),
      ),
    );
  }
}
