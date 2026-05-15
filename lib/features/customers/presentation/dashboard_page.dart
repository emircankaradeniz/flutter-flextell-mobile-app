import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../account/data/account_repository.dart';
import '../../account/domain/tenant.dart';
import '../../auth/domain/auth_session.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/logic/auth_state.dart';
import '../data/customers_repository.dart';
import '../domain/customer.dart';
import '../logic/customers_cubit.dart';
import '../logic/customers_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final session = authState.session;

    if (authState.status != AuthStatus.authenticated || session == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocProvider(
      create: (context) => CustomersCubit(
        accountRepository: context.read<AccountRepository>(),
        customersRepository: context.read<CustomersRepository>(),
      )..load(),
      child: _DashboardContent(session: session),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.session,
  });

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flextell Panel'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().refresh(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Token yenile',
          ),
          IconButton(
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış yap',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CustomersCubit>().load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            _HeroCard(session: session),
            const SizedBox(height: 18),
            _TokenCard(session: session),
            const SizedBox(height: 18),
            const _TenantSection(),
            const SizedBox(height: 18),
            const _CustomersSection(),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.session,
  });

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB),
            Color(0xFF1D4ED8),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.26),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 18),
          const Text(
            'Oturum başarıyla açıldı',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Access token aktif. Kalan süre: ${session.expiresIn} saniye',
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  const _TokenCard({
    required this.session,
  });

  final AuthSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Token Bilgileri',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          _TokenField(
            title: 'Access Token',
            value: session.accessToken,
          ),
          const SizedBox(height: 12),
          _TokenField(
            title: 'Refresh Token',
            value: session.refreshToken.isEmpty
                ? 'Refresh token dönmedi'
                : session.refreshToken,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Expires In',
            value: '${session.expiresIn} saniye',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Token Type',
            value: session.tokenType ?? 'Belirtilmedi',
          ),
        ],
      ),
    );
  }
}

class _TokenField extends StatelessWidget {
  const _TokenField({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 190),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TenantSection extends StatelessWidget {
  const _TenantSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        final selectedTenant = state.selectedTenant;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tenant Bilgisi',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              if (state.status == CustomersStatus.loading &&
                  selectedTenant == null)
                const LinearProgressIndicator()
              else if (state.tenants.isEmpty)
                const Text(
                  'Tenant listesi henüz alınamadı.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                )
              else
                _TenantPicker(
                  tenants: state.tenants,
                  selectedTenant: selectedTenant ?? state.tenants.first,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TenantPicker extends StatelessWidget {
  const _TenantPicker({
    required this.tenants,
    required this.selectedTenant,
  });

  final List<Tenant> tenants;
  final Tenant selectedTenant;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedTenant.id,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Aktif tenant',
        helperText: 'Customer isteğinde X-Tenant olarak bu ID gönderilir.',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: tenants.map((tenant) {
        return DropdownMenuItem<String>(
          value: tenant.id,
          child: Text(
            '${tenant.name} (#${tenant.id})',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        final tenant = tenants.firstWhere(
          (item) => item.id == value,
          orElse: () => selectedTenant,
        );

        context.read<CustomersCubit>().selectTenant(tenant);
      },
    );
  }
}

class _CustomersSection extends StatelessWidget {
  const _CustomersSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (context, state) {
        if (state.status == CustomersStatus.loading) {
          return Container(
            padding: const EdgeInsets.all(28),
            decoration: _cardDecoration(),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == CustomersStatus.failure) {
          return _CustomersErrorCard(state: state);
        }

        if (state.customers.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(22),
            decoration: _cardDecoration(),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Müşteri bulunamadı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Panel üzerinden birkaç test müşterisi oluşturduktan sonra ekranı aşağı çekerek listeyi yenileyebilirsiniz.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Müşteriler (${state.customers.length})',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              ...state.customers.map(
                (customer) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CustomerTile(customer: customer),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomersErrorCard extends StatelessWidget {
  const _CustomersErrorCard({
    required this.state,
  });

  final CustomersState state;

  @override
  Widget build(BuildContext context) {
    final debugDetails = state.debugDetails;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.errorTitle ?? 'Müşteriler alınamadı',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Bilinmeyen hata',
                      style: const TextStyle(
                        color: Color(0xFF7F1D1D),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (debugDetails != null && debugDetails.isNotEmpty) ...[
            const SizedBox(height: 14),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: const Text(
                  'Debug bilgileri',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SelectableText(
                      debugDetails,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.read<CustomersCubit>().load(),
              child: const Text('Tekrar dene'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
  });

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
            child: Text(
              customer.name.trim().isEmpty
                  ? '?'
                  : customer.name.trim()[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle(customer),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(Customer customer) {
    final values = [
      if (customer.email.isNotEmpty) customer.email,
      if (customer.phone.isNotEmpty) customer.phone,
      if (customer.id.isNotEmpty) 'ID: ${customer.id}',
    ];

    if (values.isEmpty) {
      return 'Detay bilgisi bulunamadı';
    }

    return values.join(' • ');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}
