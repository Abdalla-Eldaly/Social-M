extension StringExtensions on String {
  bool isValidEmail() => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}