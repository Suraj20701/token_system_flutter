// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:token_system/db/users_db.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String scannedData = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController mobController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MobileScannerController scannerController = MobileScannerController(
      torchEnabled: true,
      detectionSpeed: DetectionSpeed.unrestricted,
    );
    String guess = "";
    int guessCounter = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Center(
          child: SizedBox(
            width: 300,
            height: 150,
            child: MobileScanner(
              controller: scannerController,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                final Uint8List? image = capture.image;

                for (var barcode in barcodes) {
                  print("Random Guess : ${barcode.rawValue}");
                  if (guessCounter >= 8) {
                    scannerController.stop();
                    setState(() {
                      scannedData = guess;
                      guessCounter = 0;
                    });

                    Map<String, Object?>? account =
                        await UserDbOperation.getAccount(scannedData);
                    if (account == null) {
                      // Account not present
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Card(
                            elevation: 2,
                            child: SizedBox(
                              height: 250,
                              child: Column(
                                children: [
                                  Center(
                                    child: Text(
                                        "Opps! Account not present $scannedData"),
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Username"),
                                      controller: nameController,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: 250,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Mobile",
                                      ),
                                      controller: mobController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        UserDbOperation.createUser(
                                          nameController.text,
                                          scannedData,
                                          mobController.text,
                                        );
                                        scannerController.start();
                                        nameController.text = "";
                                        mobController.text = "";
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Create Account")),
                                  ElevatedButton(
                                      onPressed: () {
                                        nameController.text = "";
                                        mobController.text = "";
                                        scannerController.start();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancle")),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Account present
                      await UserDbOperation.decrementToken(scannedData);
                      showBottomSheet(
                        context: context,
                        builder: (context) {
                          return Card(
                            elevation: 2,
                            child: SizedBox(
                              height: 150,
                              child: Center(
                                child: Column(
                                  children: [
                                    Text("Name : ${account['NAME']}"),
                                    Text("Id : ${account['ID']}"),
                                    Text(
                                        "Tokens after deduct are : ${(account['TOKENS'] as int) - 1}"),
                                    ElevatedButton(
                                      onPressed: () {
                                        scannerController.start();
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Done"),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          UserDbOperation.deleteUser(
                                              scannedData);
                                          scannerController.start();
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                  if (guess != barcode.rawValue) {
                    guess = barcode.rawValue ?? "";
                  }
                  guessCounter++;
                }
              },
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              children: const [
                Text("Scan the ID"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
