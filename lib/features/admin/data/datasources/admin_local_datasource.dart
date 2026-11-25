import '../../../../core/auth/user_role.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/entities/audit_event.dart';
import '../../domain/entities/config_setting.dart';
import 'admin_mock_data.dart';

/// In-memory user list for the UI-only phase. Replace with a remote data
/// source when the user-management API is available.
abstract class AdminLocalDataSource {
  List<AdminUser> getUsers();

  /// Throws [ServerException] if the user ID, mobile or email is already used.
  AdminUser createUser(AdminUser user);

  /// Throws [ServerException] if the user doesn't exist, or the new mobile /
  /// email belongs to another user.
  AdminUser updateUser(AdminUser user);

  /// Throws [ServerException] if the user doesn't exist.
  AdminUser approveDevice(String userId);

  /// Throws [ServerException] if the user doesn't exist.
  AdminUser setDisabled(String userId, {required bool disabled});

  /// Annex D §17 parameters, by row number.
  List<ConfigSetting> getConfigSettings();

  /// Saves [setting] and logs the change as [changedBy] (Annex D §19).
  /// Throws [ServerException] if the row doesn't exist.
  ConfigSetting updateConfigSetting(
    ConfigSetting setting, {
    required String changedBy,
  });

  /// Audit log, newest first (Annex D §19).
  List<AuditEvent> getAuditLog();
}

class AdminLocalDataSourceImpl implements AdminLocalDataSource {
  final List<AdminUser> _users = [
    const AdminUser(
      userId: 'esm.bmu.1',
      name: 'V. Yadav',
      role: UserRole.station,
      designation: 'ESM',
      mobile: '9600000032',
      email: 'esm.bmu@example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      sc: 'BMU',
      status: UserStatus.devicePending,
    ),
    const AdminUser(
      userId: 'sse.sig.pryj',
      name: 'R. Kumar',
      role: UserRole.station,
      designation: 'SSE/Sig',
      mobile: '9700000010',
      email: 'sse.pryj@example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      sc: 'PRYJ',
      status: UserStatus.active,
      deviceLinked: true,
      nominatedForFailureEntry: true,
    ),
    const AdminUser(
      userId: 'esm.pryj.1',
      name: 'A. Singh',
      role: UserRole.station,
      designation: 'ESM',
      mobile: '9900000077',
      email: 'esm.pryj@example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      sc: 'PRYJ',
      status: UserStatus.active,
      deviceLinked: true,
    ),
    const AdminUser(
      userId: 'je.sig.mja',
      name: 'S. Patel',
      role: UserRole.station,
      designation: 'JE/Sig',
      mobile: '9500000008',
      email: 'je.mja@example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      sc: 'MJA',
      status: UserStatus.active,
      deviceLinked: true,
    ),
    const AdminUser(
      userId: 'dste.pyrj',
      name: 'K. Rao',
      role: UserRole.division,
      designation: 'DSTE',
      mobile: '9800000045',
      email: 'dste.pyrj@example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      status: UserStatus.active,
      deviceLinked: true,
    ),
    const AdminUser(
      userId: 'cste.ncr',
      name: 'S. Verma',
      role: UserRole.headQuarter,
      designation: 'CSTE',
      mobile: '9800000021',
      email: 'cste.ncr@example.com',
      zc: 'NCR',
      status: UserStatus.active,
      deviceLinked: true,
    ),
    const AdminUser(
      userId: 'guest.rdso',
      name: 'Visitor',
      role: UserRole.guest,
      designation: 'Viewer',
      mobile: '9400000090',
      email: 'visitor@rdso.example.com',
      zc: 'NCR',
      dc: 'PYRJ',
      status: UserStatus.disabled,
      organisation: 'RDSO',
    ),
    const AdminUser(
      userId: 'esm.lko.1',
      name: 'P. Mishra',
      role: UserRole.station,
      designation: 'ESM',
      mobile: '9300000011',
      email: 'esm.lko@example.com',
      zc: 'NR',
      dc: 'LKO',
      sc: 'LKO',
      status: UserStatus.active,
      deviceLinked: true,
    ),
  ];

  final List<ConfigSetting> _settings = AdminMockData.settings();
  final List<AuditEvent> _audit = AdminMockData.auditLog();

  @override
  List<ConfigSetting> getConfigSettings() => List.unmodifiable(_settings);

  @override
  ConfigSetting updateConfigSetting(
    ConfigSetting setting, {
    required String changedBy,
  }) {
    final i = _settings.indexWhere((s) => s.number == setting.number);
    if (i < 0) throw const ServerException('Parameter not found');
    _settings[i] = setting;
    // "Changed by Admin only · every change is logged" (W22, Annex D §19).
    _audit.insert(
      0,
      AuditEvent(
        time: DateTime.now(),
        userId: changedBy,
        event:
            'Changed parameter #${setting.number}: ${setting.title} → ${setting.summary}',
        source: 'RDPMS App',
        device: 'Mobile app',
        result: AuditResult.logged,
      ),
    );
    return setting;
  }

  @override
  List<AuditEvent> getAuditLog() => List.unmodifiable(_audit);

  int _indexOf(String userId) {
    final i = _users.indexWhere((u) => u.userId == userId);
    if (i < 0) throw const ServerException('User not found');
    return i;
  }

  /// One account per mobile no / email id (§11.8).
  void _checkUnique(AdminUser user, {String? exceptUserId}) {
    final others = _users.where((u) => u.userId != exceptUserId);
    if (others.any((u) => u.mobile == user.mobile)) {
      throw ServerException(
        'Mobile ${user.mobile} is already linked to another user',
      );
    }
    final email = user.email.toLowerCase();
    if (others.any((u) => u.email.toLowerCase() == email)) {
      throw ServerException(
        'Email ${user.email} is already linked to another user',
      );
    }
  }

  @override
  List<AdminUser> getUsers() => List.unmodifiable(_users);

  @override
  AdminUser createUser(AdminUser user) {
    final id = user.userId.toLowerCase();
    if (_users.any((u) => u.userId.toLowerCase() == id)) {
      throw ServerException('User ID ${user.userId} already exists');
    }
    _checkUnique(user);
    final created = user.copyWith(
      status: UserStatus.devicePending,
      deviceLinked: false,
    );
    _users.insert(0, created);
    return created;
  }

  @override
  AdminUser updateUser(AdminUser user) {
    final i = _indexOf(user.userId);
    final old = _users[i];
    _checkUnique(user, exceptUserId: user.userId);
    // The device is linked to the authorised mobile (§11.7): a new mobile
    // number needs a new OTP sign-in and device approval.
    final linked = old.deviceLinked && old.mobile == user.mobile;
    final updated = user.copyWith(
      deviceLinked: linked,
      status: old.isDisabled
          ? UserStatus.disabled
          : (linked ? UserStatus.active : UserStatus.devicePending),
    );
    _users[i] = updated;
    return updated;
  }

  @override
  AdminUser approveDevice(String userId) {
    final i = _indexOf(userId);
    final updated = _users[i].copyWith(
      status: UserStatus.active,
      deviceLinked: true,
    );
    _users[i] = updated;
    return updated;
  }

  @override
  AdminUser setDisabled(String userId, {required bool disabled}) {
    final i = _indexOf(userId);
    final user = _users[i];
    final updated = user.copyWith(
      status: disabled ? UserStatus.disabled : user.enabledStatus,
    );
    _users[i] = updated;
    return updated;
  }
}
