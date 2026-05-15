import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/config/app_config.dart';
import '../../account/data/account_repository.dart';
import '../../account/domain/tenant.dart';
import '../data/customers_repository.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  CustomersCubit({
    required AccountRepository accountRepository,
    required CustomersRepository customersRepository,
  })  : _accountRepository = accountRepository,
        _customersRepository = customersRepository,
        super(const CustomersState.initial());

  final AccountRepository _accountRepository;
  final CustomersRepository _customersRepository;

  Future<void> load({Tenant? tenant}) async {
    emit(
      CustomersState.loading(
        currentTenants: state.tenants,
        currentTenant: tenant ?? state.selectedTenant,
      ),
    );

    try {
      final tenants = await _loadTenants();
      final selectedTenant = _resolveSelectedTenant(tenants, tenant);

      if (selectedTenant == null) {
        emit(
          const CustomersState.failure(
            title: 'Tenant bulunamadı',
            message: 'Bu kullanıcıya bağlı tenant bulunamadı.',
          ),
        );
        return;
      }

      final customers = await _customersRepository.fetchCustomers(
        tenantId: selectedTenant.id,
      );

      emit(
        CustomersState.success(
          values: tenants,
          tenant: selectedTenant,
          customerValues: customers,
        ),
      );
    } on AccountApiException catch (error) {
      emit(
        CustomersState.failure(
          title: error.title,
          message: error.message,
          currentTenants: state.tenants,
          currentTenant: state.selectedTenant,
          details: error.debugDetails,
        ),
      );
    } on CustomersApiException catch (error) {
      emit(
        CustomersState.failure(
          title: error.title,
          message: error.message,
          currentTenants: state.tenants,
          currentTenant: state.selectedTenant,
          details: error.debugDetails,
        ),
      );
    } catch (error) {
      emit(
        CustomersState.failure(
          title: 'Beklenmeyen hata',
          message: error.toString(),
          currentTenants: state.tenants,
          currentTenant: state.selectedTenant,
        ),
      );
    }
  }

  Future<void> selectTenant(Tenant tenant) async {
    await load(tenant: tenant);
  }

  Future<List<Tenant>> _loadTenants() async {
    try {
      return await _accountRepository.fetchTenants();
    } on AccountApiException {
      if (AppConfig.hasManualTenant) {
        return const [
          Tenant(
            id: AppConfig.tenant,
            name: 'Runtime Tenant ${AppConfig.tenant}',
          ),
        ];
      }

      rethrow;
    }
  }

  Tenant? _resolveSelectedTenant(
      List<Tenant> tenants, Tenant? preferredTenant) {
    if (tenants.isEmpty) {
      return null;
    }

    final candidate = preferredTenant ?? state.selectedTenant;

    if (candidate != null) {
      for (final tenant in tenants) {
        if (tenant.id == candidate.id) {
          return tenant;
        }
      }
    }

    return tenants.first;
  }
}
