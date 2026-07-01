/// Validador de Cédula Ecuatoriana
/// Implementa la misma lógica del backend para validación local
class CedulaEcuatorianaValidator {
  /// Valida si una cédula ecuatoriana es válida
  /// 
  /// La cédula debe:
  /// - Tener exactamente 10 dígitos
  /// - Tener un código de provincia válido (01-24)
  /// - Cumplir con el algoritmo del dígito verificador
  static bool esValida(String cedula) {
    if (cedula.isEmpty) return false;
    
    // Debe ser exactamente 10 dígitos
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) {
      return false;
    }

    // Validar código de provincia (01-24)
    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) {
      return false;
    }

    // Validar dígito verificador
    final digitos = cedula.split('').map(int.parse).toList();
    final verificador = digitos.removeLast();

    int suma = 0;
    for (int i = 0; i < digitos.length; i++) {
      int resultado = digitos[i] * ((i % 2 == 0) ? 2 : 1);
      if (resultado >= 10) {
        resultado -= 9;
      }
      suma += resultado;
    }

    final digitoVerificador = (10 - (suma % 10)) % 10;
    return digitoVerificador == verificador;
  }

  /// Obtiene un mensaje de error descriptivo
  static String obtenerMensajeError(String cedula) {
    if (cedula.isEmpty) {
      return 'La cédula no puede estar vacía';
    }
    
    if (!RegExp(r'^\d{10}$').hasMatch(cedula)) {
      return 'La cédula debe tener exactamente 10 dígitos';
    }

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) {
      return 'El código de provincia no es válido';
    }

    return 'La Cedula es invalida';
  }
}
