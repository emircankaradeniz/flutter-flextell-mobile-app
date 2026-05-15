import 'package:equatable/equatable.dart';

import '../../account/domain/tenant.dart';
import '../domain/customer.dart';

enum CustomersStatus {
  initial,
  loading,
  success,
  failure,
}

class CustomersState extends Equatable {
  const CustomersState({
    required this.status,
    this.tenants = const [],
    this.selectedTenant,
    this.customers = const [],
    this.errorTitle,
    this.errorMessage,
    this.debugDetails,
  });

  const CustomersState.initial()
      : status = CustomersStatus.initial,
        tenants = const [],
        selectedTenant = null,
        customers = const [],
        errorTitle = null,
        errorMessage = null,
        debugDetails = null;

  const CustomersState.loading({
    List<Tenant> currentTenants = const [],
    Tenant? currentTenant,
  })  : status = CustomersStatus.loading,
        tenants = currentTenants,
        selectedTenant = currentTenant,
        customers = const [],
        errorTitle = null,
        errorMessage = null,
        debugDetails = null;

  const CustomersState.success({
    required List<Tenant> values,
    required Tenant tenant,
    required List<Customer> customerValues,
  })  : status = CustomersStatus.success,
        tenants = values,
        selectedTenant = tenant,
        customers = customerValues,
        errorTitle = null,
        errorMessage = null,
        debugDetails = null;

  const CustomersState.failure({
    required String title,
    required String message,
    List<Tenant> currentTenants = const [],
    Tenant? currentTenant,
    String? details,
  })  : status = CustomersStatus.failure,
        tenants = currentTenants,
        selectedTenant = currentTenant,
        customers = const [],
        errorTitle = title,
        errorMessage = message,
        debugDetails = details;

  final CustomersStatus status;
  final List<Tenant> tenants;
  final Tenant? selectedTenant;
  final List<Customer> customers;
  final String? errorTitle;
  final String? errorMessage;
  final String? debugDetails;

  @override
  List<Object?> get props => [
        status,
        tenants,
        selectedTenant,
        customers,
        errorTitle,
        errorMessage,
        debugDetails,
      ];
}
