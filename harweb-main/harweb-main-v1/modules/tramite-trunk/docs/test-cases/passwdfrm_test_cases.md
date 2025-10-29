# Casos de Prueba passwdfrm

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Autorización exitosa | usuario: admin, password: &T123456 | success: true, autorizado: true, message: 'Autorización concedida' |
| 2 | Contraseña incorrecta | usuario: admin, password: wrongpass | success: false, autorizado: false, message: 'Password incorrecto' |
| 3 | Usuario no autorizado | usuario: user1, password: 123456 | success: false, autorizado: false, message: 'Usuario NO registrado para autorizaciones' |
| 4 | Usuario no existe | usuario: noexiste, password: 123456 | success: false, autorizado: false, message: 'Usuario no registrado para autorizaciones' |
| 5 | Campos vacíos | usuario: '', password: '' | success: false, message: 'Datos incompletos' |
| 6 | Obtener datos de usuario | usuario: admin | success: true, usuario: { ... } |
