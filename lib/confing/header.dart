class ApiHeaders {
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Removes the Ngrok warning page
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
