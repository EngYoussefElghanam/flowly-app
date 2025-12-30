class DashboardStatsModel {
  final double totalRevenue;
  final int totalOrders;
  final double totalProfit;
  final double averageOrderValue;

  DashboardStatsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProfit,
    required this.averageOrderValue,
  });
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalRevenue: double.parse(json['totalRevenue'].toString()),
      totalOrders: int.parse(json['totalOrders'].toString()),
      totalProfit: double.parse(json['totalProfit'].toString()),
      averageOrderValue: double.parse(json['averageOrderValue'].toString()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalProfit': totalProfit,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
    };
  }
}
