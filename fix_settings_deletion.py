import re

with open("lib/features/settings/presentation/screens/settings_screen.dart", "r") as f:
    content = f.read()

replacement = """                          String errorMessage = e.toString();
                          if (errorMessage.contains('requires-recent-login')) {
                            // Automatically sign them out for now
                            // Wait, we need to handle in-place re-auth
                            try {
                              import 'package:firebase_auth/firebase_auth.dart';
                            } catch (e) {}"""
