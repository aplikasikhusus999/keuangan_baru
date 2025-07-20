import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String accountName;
  final String userEmail;
  final int unreadNotifications;
  final VoidCallback onLogout;
  final VoidCallback onAccountInfoTap;
  final VoidCallback onNotificationsTap;

  const CustomAppBar({
    super.key,
    required this.accountName,
    required this.userEmail,
    required this.unreadNotifications,
    required this.onLogout,
    required this.onAccountInfoTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5), // Indigo-600
              Color(0xFF8B5CF6), // Purple-800
            ],
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap:
                onAccountInfoTap, // Fungsi untuk edit nama perusahaan & tambah akun
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Agar Row tidak mengambil lebar penuh
              children: [
                Text(
                  accountName, // Default: "Perusahaan 1"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.edit,
                    color: Colors.white, size: 18), // Ikon edit
              ],
            ),
          ),
          Text(
            userEmail, // Nama user yang login
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          // Bagian financialType dihapus dari sini
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 28),
              onPressed: onNotificationsTap,
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 20); // Menyesuaikan tinggi AppBar
}
