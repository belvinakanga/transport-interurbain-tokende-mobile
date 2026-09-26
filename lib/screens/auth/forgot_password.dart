import 'package:flutter/material.dart';

import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController =
  TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void sendCode() {
    if (_formKey.currentState!.validate()) {
      final String phoneNumber = phoneController.text.trim();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: phoneNumber,
          ),
        ),
      );
    }
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // ==============================
                  // LOGO
                  // ==============================
                  const AppLogo(
                    size: 110,
                  ),

                  const SizedBox(height: 25),

                  // ==============================
                  // TITRE
                  // ==============================
                  const Text(
                    "Mot de passe oublié ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2A66),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==============================
                  // DESCRIPTION
                  // ==============================
                  const Text(
                    "Entrez votre numéro de téléphone. "
                        "Nous vous enverrons un code de vérification.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF666666),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==============================
                  // NUMÉRO DE TÉLÉPHONE
                  // ==============================
                  CustomTextField(
                    controller: phoneController,
                    hintText: "Numéro de téléphone",
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Veuillez saisir votre numéro de téléphone.";
                      }

                      if (value.trim().length < 8) {
                        return "Veuillez saisir un numéro valide.";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==============================
                  // ENVOYER LE CODE
                  // ==============================
                  CustomButton(
                    text: "Envoyer le code",
                    onPressed: sendCode,
                  ),

                  const SizedBox(height: 25),

                  // ==============================
                  // RETOUR CONNEXION
                  // ==============================
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Retour à la connexion",
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
      ),
    );
  }
}