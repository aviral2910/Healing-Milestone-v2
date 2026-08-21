import re

def update_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # Make sure we have the imports for FilteringTextInputFormatter
    if "import 'package:flutter/services.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';")

    input_formatter = """
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                    ],"""

    # Replace validator in professional_onboarding_screen
    if "professional_onboarding_screen.dart" in filepath:
        # Find TextFormField with _usernameController
        pattern = r"(TextFormField\(\s*controller: _usernameController,.*?textInputAction: TextInputAction\.next,)"
        replacement = r"\1" + input_formatter
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        
        # Replace validator
        val_pattern = r"(validator: \(value\) \{\s*if \(value == null \|\| value\.trim\(\)\.length < 3\) \{\s*return 'Username must be at least 3 characters\.';\s*\})"
        val_replacement = r"""validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Username must be at least 3 characters.';
                      }
                      if (value.contains(' ')) {
                        return 'Username cannot contain spaces.';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                        return 'Only letters, numbers, periods, and underscores allowed.';
                      }
                      if (_isUsernameAvailable == false) {
                        return 'Username is already taken.';
                      }
                      return null;
                    }"""
        
        # It might be easier to just find the exact string
        if "if (value == null || value.trim().length < 3) {" in content:
            content = re.sub(val_pattern, val_replacement, content, flags=re.DOTALL)

    elif "edit_profile_screen.dart" in filepath:
        pattern = r"(TextFormField\(\s*controller: _usernameController,.*?decoration: _buildInputDecoration\(.*?\),)"
        replacement = r"\1" + input_formatter
        content = re.sub(pattern, replacement, content, flags=re.DOTALL)
        
        val_pattern = r"(validator: \(value\) \{\s*if \(value == null \|\| value\.trim\(\)\.length < 3\) \{\s*return 'Username must be at least 3 characters\.';\s*\})"
        val_replacement = r"""validator: (value) {
                                      if (value == null || value.trim().length < 3) {
                                        return 'Username must be at least 3 characters.';
                                      }
                                      if (value.contains(' ')) {
                                        return 'Username cannot contain spaces.';
                                      }
                                      if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
                                        return 'Only letters, numbers, periods, and underscores allowed.';
                                      }
                                      if (_isUsernameAvailable == false) {
                                        return 'Username is already taken.';
                                      }
                                      return null;
                                    }"""
        if "if (value == null || value.trim().length < 3) {" in content:
            content = re.sub(val_pattern, val_replacement, content, flags=re.DOTALL)

    with open(filepath, "w") as f:
        f.write(content)

update_file("lib/features/auth/presentation/screens/professional_onboarding_screen.dart")
update_file("lib/features/profile/presentation/screens/edit_profile_screen.dart")
