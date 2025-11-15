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
        return 'Bundles';
      case 4:
        return 'Products';
      case 5:
        return 'Price Plans';
      case 6:
        return 'Invoices';
      case 7:
        return 'Payments';
      case 8:
        return 'Reports';
      case 9:
        return 'Tags';
      case 10:
        return 'Tag Definitions';
      case 11:
        return 'Settings';
      case 12:
        return 'Profile';
      case 14:
        return 'Contacts';
      case 15:
        return 'Opportunities';
      case 16:
        return 'Activities';
      case 17:
        return 'Users';
      case 18:
        return 'Roles';
      case 19:
        return 'Permissions';
      default:
        return 'Dashboard';
    }
  }
}
