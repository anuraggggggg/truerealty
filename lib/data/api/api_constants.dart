class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'TRUROOT_CRM_BASE_URL',
    defaultValue: 'https://crmtrueroot.com/api',
  );

  static const String crmBaseUrl = baseUrl;
  static const String authBaseUrl = baseUrl;

  static const Duration requestTimeout = Duration(seconds: 30);
}
