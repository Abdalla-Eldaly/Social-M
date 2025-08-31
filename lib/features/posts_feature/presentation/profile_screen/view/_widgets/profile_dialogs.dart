import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:social_m_app/features/posts_feature/domain/entities/user.dart';

import '../../cubit/profile_cubit.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Logout',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'Are you sure you want to logout?',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade400,
                Colors.red.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );
}

// Share Profile Bottom Sheet
void showShareOptions(BuildContext context, {User? user}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.share,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Share Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Share Options
          Column(
            children: [
              _buildShareOption(
                context,
                icon: Icons.link,
                title: 'Copy Link',
                subtitle: 'Copy profile link to clipboard',
                color: Colors.blue,
                onTap: () => _copyProfileLink(context, user),
              ),
              _buildShareOption(
                context,
                icon: Icons.share,
                title: 'Share via Apps',
                subtitle: 'Share through messaging apps',
                color: Colors.green,
                onTap: () => _shareViaApps(context, user),
              ),
              _buildShareOption(
                context,
                icon: Icons.qr_code,
                title: 'QR Code',
                subtitle: 'Generate QR code for profile',
                color: Colors.purple,
                onTap: () => _showQRCode(context, user),
              ),
              _buildShareOption(
                context,
                icon: Icons.email_outlined,
                title: 'Share via Email',
                subtitle: 'Send profile link via email',
                color: Colors.orange,
                onTap: () => _shareViaEmail(context, user),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

// More Options Bottom Sheet
void showMoreOptions(BuildContext context, {User? user, VoidCallback? onRefresh}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_horiz,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'More Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // More Options
          Column(
            children: [
              _buildMoreOption(
                context,
                icon: Icons.refresh,
                title: 'Refresh Profile',
                subtitle: 'Update profile data',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).pop();
                  onRefresh?.call();
                },
              ),
              _buildMoreOption(
                context,
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                color: Colors.green,
                onTap: () => _navigateToEditProfile(context),
              ),
              _buildMoreOption(
                context,
                icon: Icons.settings,
                title: 'Account Settings',
                subtitle: 'Privacy and account settings',
                color: Colors.orange,
                onTap: () => _navigateToSettings(context),
              ),
              _buildMoreOption(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                color: Colors.purple,
                onTap: () => _showHelpOptions(context),
              ),
              _buildMoreOption(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App information and version',
                color: Colors.teal,
                onTap: () => _showAboutDialog(context),
              ),
              _buildMoreOption(
                context,
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                color: Colors.red,
                onTap: () => _showLogoutConfirmation(context),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

// Share Option Widget
Widget _buildShareOption(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap,
    }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// More Option Widget
Widget _buildMoreOption(
    BuildContext context, {
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap,
      bool isDestructive = false,
    }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDestructive ? Colors.red[200]! : Colors.grey[200]!,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isDestructive ? Colors.red.withOpacity(0.02) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red[700] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Share Logic Implementation
Future<void> _copyProfileLink(BuildContext context, User? user) async {
  try {
    final profileUrl = _generateProfileUrl(user);
    await Clipboard.setData(ClipboardData(text: profileUrl));
    Navigator.of(context).pop();
    _showSuccessSnackBar(context, 'Profile link copied to clipboard!');
  } catch (e) {
    _showErrorSnackBar(context, 'Failed to copy link');
  }
}

Future<void> _shareViaApps(BuildContext context, User? user) async {
  try {
    final profileUrl = _generateProfileUrl(user);
    final shareText = _generateShareText(user, profileUrl);

    Navigator.of(context).pop();
    await Share.share(
      shareText,
      subject: 'Check out ${user?.username ?? "this profile"} on SocialApp',
    );
  } catch (e) {
    _showErrorSnackBar(context, 'Failed to share profile');
  }
}

Future<void> _shareViaEmail(BuildContext context, User? user) async {
  try {
    final profileUrl = _generateProfileUrl(user);
    final emailBody = _generateEmailBody(user, profileUrl);
    final emailSubject = 'Check out ${user?.username ?? "this profile"} on SocialApp';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': emailSubject,
        'body': emailBody,
      },
    );

    Navigator.of(context).pop();

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback to regular share
      await Share.share('$emailSubject\n\n$emailBody');
    }
  } catch (e) {
    _showErrorSnackBar(context, 'Failed to open email app');
  }
}

void _showQRCode(BuildContext context, User? user) {
  Navigator.of(context).pop();
  showDialog(
    context: context,
    builder: (context) => QRCodeDialog(user: user),
  );
}

// Helper Functions for Share
String _generateProfileUrl(User? user) {
  // Replace with your actual app's profile URL scheme
  final userId = user?.id ?? 0;
  final username = user?.username ?? 'user';
  return 'https://socialapp.com/profile/$username'; // or use userId
}

String _generateShareText(User? user, String profileUrl) {
  final userName = user?.username ?? 'this user';
  return 'Check out $userName\'s profile on SocialApp! $profileUrl';
}

String _generateEmailBody(User? user, String profileUrl) {
  final userName = user?.username ?? 'this user';
  final userBio = user?.bio ?? '';

  String body = 'Hi!\n\nI wanted to share $userName\'s profile with you on SocialApp.\n\n';

  if (userBio.isNotEmpty) {
    body += 'About them: $userBio\n\n';
  }

  body += 'Check out their profile: $profileUrl\n\n';
  body += 'Download SocialApp to connect and see more!';

  return body;
}

// QR Code Dialog
class QRCodeDialog extends StatelessWidget {
  final User? user;

  const QRCodeDialog({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Profile QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // QR Code placeholder (you'll need qr_flutter package)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QR Code Here',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '(Add qr_flutter package)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              user?.username ?? 'User Profile',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save QR code logic
                      Navigator.of(context).pop();
                      _showSuccessSnackBar(context, 'QR code saved to gallery!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// More Options Logic Implementation
void _navigateToEditProfile(BuildContext context) {
  Navigator.of(context).pop();
  // Navigate to edit profile screen
  Navigator.of(context).pushNamed('/edit-profile');
  // Or use your preferred navigation method:
  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfileScreen()));
}

void _navigateToSettings(BuildContext context) {
  Navigator.of(context).pop();
  Navigator.of(context).pushNamed('/settings');
}

void _showHelpOptions(BuildContext context) {
  Navigator.of(context).pop();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          _buildHelpOption(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Contact Support',
            onTap: () => _contactSupport(context),
          ),
          _buildHelpOption(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            onTap: () => _reportBug(context),
          ),
          _buildHelpOption(
            context,
            icon: Icons.lightbulb_outline,
            title: 'Feature Request',
            onTap: () => _featureRequest(context),
          ),
          _buildHelpOption(
            context,
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(context),
          ),
          _buildHelpOption(
            context,
            icon: Icons.gavel_outlined,
            title: 'Terms of Service',
            onTap: () => _openTermsOfService(context),
          ),

          const SizedBox(height: 10),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  );
}

Widget _buildHelpOption(
    BuildContext context, {
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.purple, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showAboutDialog(BuildContext context) {
  Navigator.of(context).pop();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.info, color: Colors.teal),
          SizedBox(width: 8),
          Text('About SocialApp'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Version: 1.0.0'),
          SizedBox(height: 8),
          Text('Build: 2025.01.31'),
          SizedBox(height: 16),
          Text(
            'Connect with friends, share moments, and discover new communities.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

void _showLogoutConfirmation(BuildContext context) {
  Navigator.of(context).pop();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text('Sign Out'),
        ],
      ),
      content: const Text('Are you sure you want to sign out of your account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Call your ProfileCubit logout method
            context.read<ProfileCubit>().logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
}

// Help & Support Functions
void _contactSupport(BuildContext context) {
  Navigator.of(context).pop();
  // Implement support contact logic
  _launchEmail('support@socialapp.com', 'Support Request', '');
}

void _reportBug(BuildContext context) {
  Navigator.of(context).pop();
  _launchEmail('bugs@socialapp.com', 'Bug Report', 'Please describe the bug you encountered:');
}

void _featureRequest(BuildContext context) {
  Navigator.of(context).pop();
  _launchEmail('feedback@socialapp.com', 'Feature Request', 'I would like to suggest a new feature:');
}

void _openPrivacyPolicy(BuildContext context) {
  Navigator.of(context).pop();
  _launchUrl('https://socialapp.com/privacy');
}

void _openTermsOfService(BuildContext context) {
  Navigator.of(context).pop();
  _launchUrl('https://socialapp.com/terms');
}

// Utility Functions
Future<void> _launchEmail(String email, String subject, String body) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  }
}

Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Text(message),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

