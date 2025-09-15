class PageTitleHelper {
  static String getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Accounts';
      case 2:
        return 'Subscriptions';
      case 3:
        return 'Invoices';
      case 4:
        return 'Payments';
      case 5:
        return 'Reports';
      case 6:
        return 'Tags';
      case 7:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }
}
