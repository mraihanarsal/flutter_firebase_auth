// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
 
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    // Ambil data user yang sedang login
    final User? user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final theme = Theme.of(context);
 
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      
      // ========== APP BAR ==========
      appBar: AppBar(
        title: const Text('Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold)),
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
                  await authService.logout();
                  // Navigasi otomatis oleh StreamBuilder
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
 
            // ========== STATISTIK CARDS ==========
            const Text('Ringkasan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
 
            Row(
              children: [
                _StatCard(
                  icon: Icons.task_alt,
                  label: 'Total Tugas',
                  value: '12',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Selesai',
                  value: '8',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.pending_actions,
                  label: 'Pending',
                  value: '4',
                  color: Colors.orange,
                ),
              ],
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
                    value: user?.uid.substring(0, 16) ?? '-',
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.verified_outlined,
                    label: 'Status Email',
                    value: user?.emailVerified == true
                      ? 'Terverifikasi' : 'Belum Terverifikasi',
                    valueColor: user?.emailVerified == true
                      ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),
 
            const SizedBox(height: 24),
 
            // ========== LOGOUT BUTTON ==========
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async => await authService.logout(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
 
  const _StatCard({
    required this.icon, required this.label,
    required this.value, required this.color,
  });
 
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
 
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
 
  const _InfoTile({
    required this.icon, required this.label,
    required this.value, this.valueColor,
  });
 
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      subtitle: Text(value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: valueColor ?? Colors.black87,
        )),
    );
  }
}


