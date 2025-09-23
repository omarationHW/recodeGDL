## Casos de Prueba DsDBGasto

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Login y conexión exitosos | user: admin, pass: admin123 | success: true, mensaje de éxito |
| 2 | Login seguridad incorrecto | user: admin, pass: wrongpass | success: false, error: 'Usuario o contraseña incorrectos' |
| 3 | Login seguridad vacío | user: '', pass: '' | success: false, error: 'Usuario o contraseña incorrectos' |
| 4 | Conexión a estación falla | user: admin, pass: admin123 (pero 'estacion' no existe) | success: false, error: 'No se pudo conectar a estación' |
| 5 | eRequest desconocido | eRequest: 'unknown', params: {} | success: false, error: 'Unknown eRequest' |
