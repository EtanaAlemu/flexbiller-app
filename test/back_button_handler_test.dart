import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexbiller_app/core/services/back_button_handler_service.dart';
import 'package:flexbiller_app/core/widgets/back_button_handler_widget.dart';

void main() {
  group('BackButtonHandlerService', () {
    late BackButtonHandlerService service;

    setUp(() {
      service = BackButtonHandlerService();
      service.reset(); // Ensure clean state
    });

    test('should reset state correctly', () {
      expect(service.isWaitingForDoubleTap, false);
    });

    test('should be singleton instance', () {
      final service1 = BackButtonHandlerService();
      final service2 = BackButtonHandlerService();
      expect(identical(service1, service2), true);
    });
  });

  group('BackButtonHandlerWidget', () {
    testWidgets('should render child widget correctly', (WidgetTester tester) async {
      const testWidget = Text('Test Content');
      
      await tester.pumpWidget(
        MaterialApp(
          home: BackButtonHandlerWidget(
            child: testWidget,
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should disable double tap exit when specified', (WidgetTester tester) async {
      const testWidget = Text('Test Content');
      
      await tester.pumpWidget(
        MaterialApp(
          home: BackButtonHandlerWidget(
            enableDoubleTapExit: false,
            child: testWidget,
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });
  });

  group('DashboardBackButtonHandler', () {
    testWidgets('should render child widget correctly', (WidgetTester tester) async {
      const testWidget = Text('Dashboard Content');
      
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardBackButtonHandler(
            isMainMenu: true,
            child: testWidget,
          ),
        ),
      );

      expect(find.text('Dashboard Content'), findsOneWidget);
    });
  });
}
