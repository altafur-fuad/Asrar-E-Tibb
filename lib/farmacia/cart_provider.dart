import 'package:flutter/material.dart';
import '../models/medicine_model.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});

  double get totalPrice {
    final price = double.tryParse(medicine.unitPrice ?? "0") ?? 0;
    return price * quantity;
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Medicine med) {
    final index = _items.indexWhere((item) => item.medicine.id == med.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(medicine: med));
    }
    notifyListeners();
  }

  void removeItem(Medicine med) {
    _items.removeWhere((item) => item.medicine.id == med.id);
    notifyListeners();
  }

  void increaseQuantity(Medicine med) {
    final index = _items.indexWhere((item) => item.medicine.id == med.id);
    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(Medicine med) {
    final index = _items.indexWhere((item) => item.medicine.id == med.id);
    if (index != -1 && _items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  double get total {
    double total = 0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
