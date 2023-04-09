import 'package:flutter/material.dart';
import '../db/users_db.dart';

class AccountWidget extends StatefulWidget {
  const AccountWidget({super.key});

  @override
  State<AccountWidget> createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  Future<List<Map<String, Object?>>>? accounts;
  TextEditingController tokenController = TextEditingController();
  @override
  void initState() {
    setState(() {
      accounts = UserDbOperation.getAccounts();
    });
    super.initState();
  }

  Future<void> refreshScreen() async {
    setState(() {
      accounts = UserDbOperation.getAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => refreshScreen(),
      child: FutureBuilder<List<Map<String, Object?>>>(
        future: accounts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No accounts yet"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, Object?> account = snapshot.data![index];
                return ListTile(
                  title: Text(account["NAME"] as String),
                  subtitle: Text(
                      "ID : ${account['ID']}  TOKENS : ${account['TOKENS']}"),
                  trailing: ElevatedButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Card(
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: SizedBox(
                                height: 250,
                                child: Center(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: tokenController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Tokens",
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await UserDbOperation.incrementToken(
                                            account["ID"] as String,
                                            int.parse(tokenController.text),
                                          );
                                          refreshScreen();
                                          FocusScope.of(context).unfocus();
                                          tokenController.clear();

                                          Navigator.pop(context);
                                        },
                                        child: const Text("Add"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          FocusScope.of(context).unfocus();
                                          tokenController.clear();

                                          Navigator.pop(context);
                                        },
                                        child: const Text("Cancle"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () => refreshScreen(),
            child: ListView(
              children: const [
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
