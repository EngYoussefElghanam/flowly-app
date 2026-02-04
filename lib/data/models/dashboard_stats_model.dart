class DashboardStatsModel {
  final double totalRevenue;
  final int totalOrders;
  final double totalProfit;
  final double averageOrderValue;

  // 🆕 NEW FIELDS
  final String topSellingItem;
  final String lowStockItem;

  DashboardStatsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProfit,
    required this.averageOrderValue,
    required this.topSellingItem,
    required this.lowStockItem,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalRevenue: double.parse(json['totalRevenue'].toString()),
      totalOrders: int.parse(json['totalOrders'].toString()),
      totalProfit: double.parse(json['totalProfit'].toString()),
      averageOrderValue: double.parse(json['averageOrderValue'].toString()),

      // 🆕 Handle Strings (Default to generic text if null)
      topSellingItem: json['topSellingItem'] ?? "N/A",
      lowStockItem: json['lowStockItem'] ?? "All Stock Good",
    );
  }
}
