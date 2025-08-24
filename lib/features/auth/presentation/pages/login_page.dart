import 'package:flutter/material.dart';
import '../../../../core/theme/theme_toggle_widget.dart';
import '../../../../core/localization/language_selector_widget.dart';
import '../../../../core/widgets/jwt_info_widget.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlexBiller'),
        actions: [
          const SimpleLanguageSelector(),
          const SizedBox(width: 8),
          const ThemeToggleWidget(),
          const SizedBox(width: 8),
        ],
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              LoginForm(),
              SizedBox(height: 32),
              JwtInfoWidget(showDetails: true),
            ],
          ),
        ),
      ),
    );
  }
}
