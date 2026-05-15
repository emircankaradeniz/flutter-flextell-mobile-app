import 'package:equatable/equatable.dart';

class Tenant extends Equatable {
  const Tenant({
    required this.id,
    required this.name,
    this.logoUrl,
    this.raw = const {},
  });

  final String id;
  final String name;
  final String? logoUrl;
  final Map<String, dynamic> raw;

  factory Tenant.fromJson(Map<String, dynamic> json) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = json[key];

        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }

      return '';
    }

    final id = read(['id', 'tenant_id', 'tenantId', 'clinic_id', 'clinicId']);
    final name = read([
      'name',
      'title',
      'company_name',
      'companyName',
      'clinic_name',
      'clinicName'
    ]);
    final logoUrl = read(['logo_url', 'logoUrl', 'avatar_url', 'avatarUrl']);

    return Tenant(
      id: id,
      name: name.isEmpty ? 'Tenant $id' : name,
      logoUrl: logoUrl.isEmpty ? null : logoUrl,
      raw: json,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        raw,
      ];
}
