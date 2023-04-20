class ProductDataModel{
  String? key;
  String? name;
  String? price;

  ProductDataModel({
    this.key,
    this.name,
    this.price
  });

  ProductDataModel.fromJson(Map<String, dynamic> json){
    key = json['key'];
    name = json['name'];
    price = json['price'];
  }
}