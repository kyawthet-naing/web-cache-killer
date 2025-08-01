/// Logger utility for colored console output
class Logger {
  final bool verbose;

  // ANSI color codes
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _purple = '\x1B[35m';
  static const String _reset = '\x1B[0m';

  Logger(this.verbose);

  void printHeader(String title) {
    print('$_blue🚀 $title$_reset');
    print('==================================');
  }

  void printStep(String message) {
    print('$_blue$message$_reset');
  }

  void printSuccess(String message) {
    print('$_green✅ $message$_reset');
  }

  void printWarning(String message) {
    print('$_yellow⚠️  $message$_reset');
  }

  void printError(String message) {
    print('$_red❌ $message$_reset');
  }

  void printInfo(String message) {
    print('$_purple📋 $message$_reset');
  }

  void printVerbose(String message) {
    if (verbose) {
      print('$_purple🔍 $message$_reset');
    }
  }

  void printPlain(String message) {
    print(message);
  }
}