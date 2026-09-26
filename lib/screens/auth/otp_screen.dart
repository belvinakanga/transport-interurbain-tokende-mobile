import 'package:flutter/material.dart';

import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void verifyCode() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Pour l'instant, la vérification est simulée.
    // La vraie vérification sera faite avec Laravel plus tard.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Code vérifié avec succès !',
        ),
        backgroundColor: Color(0xFF0A2A66),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0A2A66),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Icône
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFFF6B00),
                    size: 40,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Vérification',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A66),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Entrez le code à 6 chiffres envoyé au\n${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                    color: Color(0xFF0A2A66),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF6B00),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer le code.';
                    }

                    if (value.length != 6) {
                      return 'Le code doit contenir 6 chiffres.';
                    }

                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Le code doit contenir uniquement des chiffres.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Vérifier',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Un nouveau code a été envoyé.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Renvoyer le code',
                    style: TextStyle(
                      color: Color(0xFFFF6B00),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}