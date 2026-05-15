import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.raw,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final Map<String, dynamic> raw;

  factory Customer.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = json[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }

      return '';
    }

    final firstName = read(['firstName', 'first_name']);
    final lastName = read(['lastName', 'last_name']);
    final directName = read(['name', 'fullName', 'displayName', 'companyName']);

    final combinedName = [
      firstName,
      lastName,
    ].where((value) => value.trim().isNotEmpty).join(' ');

    final customerName = directName.isNotEmpty ? directName : combinedName;

    return Customer(
      id: read(['id', '_id', 'customerId', 'customer_id']),
      name: customerName.isNotEmpty ? customerName : 'İsimsiz müşteri',
      email: read(['email', 'mail']),
      phone: read(['phone', 'phoneNumber', 'phone_number', 'mobile']),
      raw: json,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        raw,
      ];
}
