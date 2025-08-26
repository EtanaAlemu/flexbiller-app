import 'package:flutter/material.dart';
import '../../../../core/theme/theme_toggle_widget.dart';
import '../../../../core/localization/language_selector_widget.dart';
import '../../../../core/widgets/jwt_info_widget.dart';
import '../widgets/login_form.dart';
import '../../../subscriptions/presentation/pages/subscriptions_demo_page.dart';
import '../../../subscriptions/presentation/pages/subscription_details_page.dart';

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LoginForm(),
              SizedBox(height: 32),
              JwtInfoWidget(showDetails: true),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubscriptionsDemoPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.subscriptions),
                label: const Text('View Recent Subscriptions'),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Test with a sample subscription ID
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SubscriptionDetailsPage(
                        subscriptionId: '8a0075a7-104c-4dfc-9e9a-6737c51cd59c',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Test Subscription Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
