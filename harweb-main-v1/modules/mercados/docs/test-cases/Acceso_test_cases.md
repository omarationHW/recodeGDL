# Casos de Prueba: Acceso

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Acceso exitoso | usuario: admin, contrasena: 1234, ejercicio: 2024 | success: true, datos de usuario |
| 2 | Contraseña incorrecta | usuario: admin, contrasena: erronea, ejercicio: 2024 | success: false, mensaje de error |
| 3 | Usuario vacío | usuario: '', contrasena: 1234, ejercicio: 2024 | success: false, error de validación |
| 4 | Ejercicio fuera de rango | usuario: admin, contrasena: 1234, ejercicio: 1999 | success: false, error de validación |
| 5 | 3 intentos fallidos | usuario: admin, contrasena: erronea, ejercicio: 2024 (x3) | Bloqueo de acceso, mensaje de bloqueo |
| 6 | Logout | acción: logout | success: true, sesión cerrada |
