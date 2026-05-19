import 'package:flutter/material.dart';

// Personalized file imports
import 'package:travelmate/shared/widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelMate Home'),
        // Use the context to get colors from the global theme
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Trova il tuo compagno di viaggio ideale',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Filtra le persone in base alla tua prossima destinazione.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // CustomButton call
              CustomButton(
                text: "Inizia a Esplorare",
                onPressed: () {
                  print("L'utente vuole cercare compagni di viaggio!");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}