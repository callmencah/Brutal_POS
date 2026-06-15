import 'package:equatable/equatable.dart';

class TaxConfig extends Equatable {
  final double percentage;

  const TaxConfig({required this.percentage});

  double calculateTax(double amount) => amount * (percentage / 100);

  @override
  List<Object?> get props => [percentage];
}

