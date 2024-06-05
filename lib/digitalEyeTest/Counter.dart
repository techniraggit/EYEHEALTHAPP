class Counter {
  final String id;
  final String title;
  final String description;
  final int price;

  Counter({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  // Factory method to create a Counter from a JSON map
  factory Counter.fromJson(Map<String, dynamic> json) {
    return Counter(
      id: json['id'],
      title: json['title'],
      description : json['description'],
      price: json['price'],
    );
  }
}