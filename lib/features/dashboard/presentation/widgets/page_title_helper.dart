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
        return 'Products';
      case 4:
        return 'Invoices';
      case 5:
        return 'Payments';
      case 6:
        return 'Reports';
      case 7:
        return 'Tags';
      case 8:
        return 'Settings';
      case 9:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }
}
