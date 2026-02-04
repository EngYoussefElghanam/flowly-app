class MarketingOpportunity {
  final int id;
  final String type;
  final String status;
  final String aiMessage;
  final customerPreview customer; //will create that helper class at the end

  MarketingOpportunity({
    required this.id,
    required this.type,
    required this.status,
    required this.aiMessage,
    required this.customer,
  });

  factory MarketingOpportunity.fromJson(Map<String, dynamic> json) {
    return MarketingOpportunity(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      aiMessage: json['aiMessage'],
      customer: customerPreview.fromJson(json['customer']),
    );
  }
}

//created customerPreview helper class
class customerPreview {
  final int id;
  final String name;
  final String? phone;
  final String? favoriteItem;

  customerPreview({
    required this.id,
    required this.name,
    this.phone,
    this.favoriteItem,
  });

  factory customerPreview.fromJson(Map<String, dynamic> json) {
    return customerPreview(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      favoriteItem: json['favoriteItem'],
    );
  }
}
