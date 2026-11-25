import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/mock/mock_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formats.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/admin_user.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/admin_scope.dart';

/// Create user / Edit user (Admin, §11.6 "assign users"). The fields follow the
/// selected role:
///
/// | Role         | Jurisdiction                 | Extra                              |
/// |--------------|------------------------------|------------------------------------|
/// | Admin        | Zone                         | —                                  |
/// | Head Quarter | Zone                         | —                                  |
/// | Division     | Zone, Division               | Nominated for actual failure entry |
/// | Station      | Zone, Division, Station      | Nominated for actual failure entry |
/// | Guest        | Zone, Division (area to view)| Organisation, access valid until   |
///
/// Every user gets an authorised mobile (§11.7) and an email (§11.8: one account
/// per mobile no / email id). A new user starts as "Device pending" until the
/// first OTP sign-in links their mobile.
///
/// With [initial] the page edits that user: fields are pre-filled and the
/// User ID can't change. Changing the mobile number unlinks the device.
class CreateUserPage extends StatefulWidget {
  final AdminUser? initial;

  const CreateUserPage({super.key, this.initial});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  static const _designations = <UserRole, List<String>>{
    UserRole.admin: ['Zonal Admin', 'System Admin'],
    UserRole.headQuarter: ['PCSTE', 'CSTE', 'CSE', 'Dy. CSTE'],
    UserRole.division: ['Sr. DSTE', 'DSTE', 'ASTE', 'Divisional Control'],
    UserRole.station: ['ESM', 'JE/Sig', 'SSE/Sig'],
    UserRole.guest: ['Viewer', 'RDSO official', 'Auditor'],
  };

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _userId = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _organisation = TextEditingController();

  AdminScope? _scope;
  UserRole? _role;
  String? _designation;
  String? _dc;
  String? _sc;
  bool _nominated = false;
  DateTime? _validUntil;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scope != null) return;
    final auth = context.read<AuthBloc>().state;
    _scope = AdminScope.from(
      auth.role,
      auth.currentUser?.data?.jurisdiction ?? MockData.userJurisdiction,
    );
    final initial = widget.initial;
    if (initial == null) {
      _setRole(
        _scope!.creatableRoles.contains(UserRole.station)
            ? UserRole.station
            : _scope!.creatableRoles.first,
      );
      return;
    }
    // Edit: pre-fill from the existing user.
    _setRole(initial.role);
    _name.text = initial.name;
    _userId.text = initial.userId;
    _mobile.text = initial.mobile;
    _email.text = initial.email;
    _designation = initial.designation;
    _dc = initial.dc ?? _scope!.dc;
    _sc = initial.sc;
    _nominated = initial.nominatedForFailureEntry;
    _organisation.text = initial.organisation ?? '';
    _validUntil = initial.validUntil;
  }

  bool get _isEdit => widget.initial != null;

  /// Roles shown as chips; in edit mode also the user's current role.
  List<UserRole> get _roles {
    final roles = _scope!.creatableRoles;
    final current = widget.initial?.role;
    return current == null || roles.contains(current)
        ? roles
        : [current, ...roles];
  }

  /// Designations for the role, plus a saved value that isn't in the list.
  List<String> get _designationItems {
    final items = _designations[_role]!;
    final d = _designation;
    return d == null || items.contains(d) ? items : [d, ...items];
  }

  @override
  void dispose() {
    _name.dispose();
    _userId.dispose();
    _mobile.dispose();
    _email.dispose();
    _organisation.dispose();
    super.dispose();
  }

  /// Switching role resets the fields that depend on it.
  void _setRole(UserRole role) {
    final scope = _scope!;
    _role = role;
    _designation = null;
    _dc = scope.dc; // a Division admin's own division is fixed
    _sc = null;
    _nominated = false;
    _validUntil = null;
    _organisation.clear();
  }

  Zone? get _zone =>
      MockData.zones.where((z) => z.zc == _scope!.zc).firstOrNull;

  List<Division> get _divisions => _zone?.divisions ?? const [];

  List<Station> get _stations =>
      _divisions.where((d) => d.dc == _dc).firstOrNull?.stations ?? const [];

  bool get _needsDivision =>
      _role != UserRole.headQuarter && _role != UserRole.admin;
  bool get _needsStation => _role == UserRole.station;
  bool get _isGuest => _role == UserRole.guest;
  bool get _canBeNominated =>
      _role == UserRole.division || _role == UserRole.station;

  Future<void> _pickValidUntil() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Access valid until',
    );
    if (picked != null) setState(() => _validUntil = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final user = AdminUser(
      userId: _userId.text.trim(),
      name: _name.text.trim(),
      role: _role!,
      designation: _designation!,
      mobile: _mobile.text.trim(),
      email: _email.text.trim(),
      zc: _scope!.zc,
      dc: _needsDivision ? _dc : null,
      sc: _needsStation ? _sc : null,
      nominatedForFailureEntry: _canBeNominated && _nominated,
      organisation: _isGuest ? _organisation.text.trim() : null,
      validUntil: _isGuest ? _validUntil : null,
    );
    final cubit = context.read<AdminCubit>();
    final error = await (_isEdit ? cubit.update(user) : cubit.create(user));
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.pop(true);
  }

  Widget _section(String title, List<Widget> children) => AppCard(
    margin: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          children[i],
        ],
      ],
    ),
  );

  Widget _readOnly(String label, String value) => LabeledField(
    label: label,
    child: InputDecorator(
      decoration: const InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        suffixIcon: Icon(Icons.lock_outline, size: 18),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 15, color: AppColors.textMain),
      ),
    ),
  );

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) => LabeledField(
    label: label,
    child: DropdownButtonFormField<T>(
      key: ValueKey('$label-$_role-$_dc'),
      initialValue: items.contains(value) ? value : null,
      isExpanded: true,
      hint: Text(
        'Select ${label.toLowerCase()}',
        style: AppTextStyles.fieldHint,
      ),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(itemLabel(item))),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? '$label is required' : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scope = _scope!;
    final role = _role!;

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Edit user' : 'Create user')),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: GradientButton(
              label: _isEdit ? 'Save changes' : 'Create user',
              leadingIcon: _isEdit
                  ? Icons.save_outlined
                  : Icons.person_add_alt_1_outlined,
              loading: _saving,
              onPressed: _submit,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screenPadding,
            children: [
              _section('User level', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in _roles)
                      ChoiceChip(
                        label: Text(r.label),
                        selected: r == role,
                        onSelected: (_) => setState(() => _setRole(r)),
                      ),
                  ],
                ),
                Text(
                  _roleHint(role),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ]),
              _section('User details', [
                LabeledField(
                  label: 'Full name',
                  child: TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'e.g. A. Singh',
                    ),
                    validator: (v) => Validators.required(v, 'Name'),
                  ),
                ),
                _isEdit
                    ? _readOnly('User ID', _userId.text)
                    : LabeledField(
                        label: 'User ID',
                        child: TextFormField(
                          controller: _userId,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: _userIdHint(role),
                          ),
                          validator: Validators.userId,
                        ),
                      ),
                _dropdown<String>(
                  label: 'Designation',
                  value: _designation,
                  items: _designationItems,
                  itemLabel: (d) => d,
                  onChanged: (v) => setState(() => _designation = v),
                ),
                LabeledField(
                  label: 'Authorised mobile number',
                  child: TextFormField(
                    controller: _mobile,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: '10-digit mobile number',
                      counterText: '',
                      prefixIcon: Icon(Icons.phone_android_outlined),
                    ),
                    validator: Validators.mobile,
                  ),
                ),
                LabeledField(
                  label: 'Email',
                  child: TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: Validators.email,
                  ),
                ),
              ]),
              _section(
                _isGuest ? 'Area the guest can monitor' : 'Jurisdiction',
                [
                  _readOnly(
                    'Zone',
                    '${scope.zc}${_zone != null ? ' – ${_zone!.name}' : ''}',
                  ),
                  if (_needsDivision)
                    scope.dc != null
                        ? _readOnly('Division', scope.dc!)
                        : _dropdown<Division>(
                            label: 'Division',
                            value: _divisions
                                .where((d) => d.dc == _dc)
                                .firstOrNull,
                            items: _divisions,
                            itemLabel: (d) => '${d.dc} – ${d.name}',
                            onChanged: (d) => setState(() {
                              _dc = d?.dc;
                              _sc = null;
                            }),
                          ),
                  if (_needsStation)
                    _dropdown<Station>(
                      label: 'Station',
                      value: _stations.where((s) => s.sc == _sc).firstOrNull,
                      items: _stations,
                      itemLabel: (s) => '${s.sc} – ${s.name}',
                      onChanged: (s) => setState(() => _sc = s?.sc),
                    ),
                ],
              ),
              if (_isGuest)
                _section('Guest access', [
                  LabeledField(
                    label: 'Organisation',
                    child: TextFormField(
                      controller: _organisation,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(hintText: 'e.g. RDSO'),
                      validator: (v) => Validators.required(v, 'Organisation'),
                    ),
                  ),
                  LabeledField(
                    label: 'Access valid until (optional)',
                    child: OutlinedButton.icon(
                      onPressed: _pickValidUntil,
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        _validUntil == null
                            ? 'No end date'
                            : DateFormats.date(_validUntil!),
                      ),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const Text(
                    'Guests get limited monitoring only: live pages, no reports and no actions (§11.6).',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ]),
              if (_canBeNominated)
                AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _nominated,
                    onChanged: (v) => setState(() => _nominated = v),
                    title: const Text('Nominated for Actual Failure entry'),
                    subtitle: const Text(
                      'Can enter actual signal failures on the Performance page (Annex E §12).',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              Text(
                _isEdit
                    ? 'Changing the authorised mobile number unlinks the current device: the user '
                          'must sign in again with OTP and the device needs approval (§11.7).'
                    : 'The user signs in with this User ID and an OTP sent to the authorised mobile. '
                          'The first sign-in links their mobile device (§11.7), so the user starts as '
                          '"Device pending". One mobile and one desktop per user (§11.8).',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _roleHint(UserRole role) => switch (role) {
    UserRole.admin => 'Zone level. Manages users (create, edit, disable, approve devices), monitors and generates reports. No control functions.',
    UserRole.headQuarter => 'Zone level. Monitors, generates reports and assigns users. No control functions.',
    UserRole.division => 'Division level. Monitors, generates reports and assigns users. No control functions.',
    UserRole.station => 'Station level. Acknowledges alerts, gives T/PT/F/M feedback and uses maintenance mode. Cannot assign users.',
    UserRole.guest =>
      'Limited monitoring only, for users outside the three levels.',
  };

  static String _userIdHint(UserRole role) => switch (role) {
    UserRole.admin => 'e.g. admin.ncr',
    UserRole.headQuarter => 'e.g. cste.ncr',
    UserRole.division => 'e.g. dste.pyrj',
    UserRole.station => 'e.g. esm.pryj.2',
    UserRole.guest => 'e.g. guest.rdso',
  };
}
