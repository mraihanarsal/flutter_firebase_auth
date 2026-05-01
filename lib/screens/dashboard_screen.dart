// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadFcmToken();
  }

  Future<void> _loadFcmToken() async {
    final token = await NotificationService().getToken();
    if (mounted) {
      setState(() => _fcmToken = token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () async {
                  await _authService.logout();
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== WELCOME CARD ==========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withBlue(255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat Datang! 👋',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('✓ Terverifikasi',
                              style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========== FCM TOKEN CARD ==========
            const Text('Firebase Cloud Messaging',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FCM Token (untuk Testing):',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(_fcmToken ?? 'Memuat token...',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Salin Token'),
                        onPressed: _fcmToken == null
                            ? null
                            : () {
                                Clipboard.setData(ClipboardData(text: _fcmToken!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Token disalin!')));
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ========== INFO AKUN ==========
            const Text('Informasi Akun',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? '-',
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'User ID',
                    value: user?.uid ?? '-',
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.verified_outlined,
                    label: 'Status Email',
                    value: user?.emailVerified == true
                        ? 'Terverifikasi'
                        : 'Belum Terverifikasi',
                    valueColor: user?.emailVerified == true ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ========== LOGOUT BUTTON ==========
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async => await _authService.logout(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ========== WIDGET HELPER ==========
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      subtitle: Text(value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          )),
    );
  }
}
