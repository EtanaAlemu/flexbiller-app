import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/back_button_handler_service.dart';

/// A wrapper widget that handles back button behavior with double-tap to exit
/// This widget should wrap the main content of screens where double-tap exit is desired
class BackButtonHandlerWidget extends StatefulWidget {
  final Widget child;
  final String? exitMessage;
  final bool enableDoubleTapExit;
  final bool showSnackBar;
  final bool isMainMenu;

  const BackButtonHandlerWidget({
    Key? key,
    required this.child,
    this.exitMessage,
    this.enableDoubleTapExit = true,
    this.showSnackBar = true,
    this.isMainMenu = true,
  }) : super(key: key);

  @override
  State<BackButtonHandlerWidget> createState() =>
      _BackButtonHandlerWidgetState();
}

class _BackButtonHandlerWidgetState extends State<BackButtonHandlerWidget> {
  late BackButtonHandlerService _backButtonHandler;

  @override
  void initState() {
    super.initState();
    _backButtonHandler = BackButtonHandlerService();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableDoubleTapExit) {
      return widget.child;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = !(await _backButtonHandler.handleBackButton(
            context,
            exitMessage: widget.exitMessage,
            showSnackBar: widget.showSnackBar,
            isMainMenu: widget.isMainMenu,
          ));

          if (shouldPop) {
            // If we should pop but can't pop normally, exit the app
            SystemNavigator.pop();
          }
        }
      },
      child: widget.child,
    );
  }
}

/// A specialized wrapper for dashboard/main menu screens
/// This provides a more user-friendly exit message for main navigation screens
class DashboardBackButtonHandler extends StatelessWidget {
  final Widget child;
  final bool isMainMenu;
  final VoidCallback? onBackPressed;

  const DashboardBackButtonHandler({
    Key? key,
    required this.child,
    this.isMainMenu = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackButtonHandlerWidget(
      exitMessage: isMainMenu
          ? 'Press back again to exit the app'
          : 'Press back again to go back',
      isMainMenu: isMainMenu,
      child: child,
    );
  }
}

/// A specialized wrapper for dashboard navigation that handles sub-page navigation
class DashboardNavigationHandler extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigate;

  const DashboardNavigationHandler({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<DashboardNavigationHandler> createState() =>
      _DashboardNavigationHandlerState();
}

class _DashboardNavigationHandlerState
    extends State<DashboardNavigationHandler> {
  late BackButtonHandlerService _backButtonHandler;

  @override
  void initState() {
    super.initState();
    _backButtonHandler = BackButtonHandlerService();
  }

  @override
  Widget build(BuildContext context) {
    final isMainMenu = widget.currentIndex == 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (isMainMenu) {
            // On main dashboard, use double-tap to exit
            final shouldPop = !(await _backButtonHandler.handleBackButton(
              context,
              exitMessage: 'Press back again to exit the app',
              showSnackBar: true,
              isMainMenu: true,
            ));

            if (shouldPop) {
              SystemNavigator.pop();
            }
          } else {
            // On sub-pages, go back to main dashboard
            final shouldPop = !(await _backButtonHandler.handleBackButton(
              context,
              exitMessage: 'Press back again to go back to dashboard',
              showSnackBar: true,
              isMainMenu: false,
            ));

            if (shouldPop) {
              widget.onNavigate(0); // Navigate to main dashboard
            }
          }
        }
      },
      child: widget.child,
    );
  }
}
