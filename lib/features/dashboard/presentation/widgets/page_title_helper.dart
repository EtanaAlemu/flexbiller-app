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
        return 'Price Plans';
      case 5:
        return 'Invoices';
      case 6:
        return 'Payments';
      case 7:
        return 'Reports';
      case 8:
        return 'Tags';
      case 9:
        return 'Tag Definitions';
      case 10:
        return 'Settings';
      case 11:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }
}
