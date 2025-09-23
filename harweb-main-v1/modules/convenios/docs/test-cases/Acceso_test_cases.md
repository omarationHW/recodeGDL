# Casos de Prueba: Formulario de Acceso

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Login exitoso | usuario: admin, password: admin123 | Acceso correcto, token generado, redirección a Home |
| 2 | Usuario incorrecto | usuario: noexiste, password: cualquier | Mensaje de error 'Usuario y/o contraseña incorrectos' |
| 3 | Contraseña incorrecta | usuario: admin, password: wrongpass | Mensaje de error 'Usuario y/o contraseña incorrectos' |
| 4 | Usuario inactivo | usuario: inactivo, password: inactivo123 | Mensaje de error 'Usuario y/o contraseña incorrectos' |
| 5 | Campos vacíos | usuario: '', password: '' | Mensaje de error 'El Usuario o la Contraseña no pueden estar vacíos' |
| 6 | Usuario con espacios | usuario: ' admin ', password: 'admin123' | Acceso correcto (espacios ignorados) |
| 7 | SQL Injection | usuario: "' OR 1=1;--", password: "' OR 1=1;--" | Mensaje de error 'Usuario y/o contraseña incorrectos' |
| 8 | Token inválido en getUserInfo | token: inválido | Mensaje de error o usuario anónimo |
