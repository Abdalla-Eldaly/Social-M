abstract class SvgPath{
  static const String _path = 'assets/svg/';
static String infoIcon = '${_path}info_icon.svg';
static String errorIcon = '${_path}error_icon.svg';
static String successIcon = '${_path}success_icon.svg';
static String profileIcon = '${_path}person.svg';
static String comment = '${_path}comment.svg';
static String location = '${_path}location.svg';
static String love = '${_path}love.svg';
static String share = '${_path}share.svg';

}


abstract class LottiePath {
  static const String _path = 'assets/animations/';
  static String download = '${_path}download_animation.json';
  static String loading = '${_path}loading_animation.json';


}

abstract class AppImagesPath {
  static const String _path = 'assets/images/';
  static String placeholder = '${_path}placeholder.png';


}