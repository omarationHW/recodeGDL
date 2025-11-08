# Casos de Prueba: Formulario Acceso (unAcceso)

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Login exitoso | usuario: admin, contrasena: admin123 | status: ok, redirección a menú |
| 2 | Login con contraseña incorrecta | usuario: admin, contrasena: wrongpass | status: error, mensaje de error |
| 3 | Usuario no existe | usuario: noexiste, contrasena: cualquier | status: error, mensaje de error |
| 4 | Campos vacíos | usuario: '', contrasena: '' | status: error, mensaje de validación |
| 5 | Recuperación de usuario | localStorage.usuarioSistema = 'admin' | Campo usuario autocompletado |
| 6 | Cancelar limpia campos | Click en 'Cancelar' | usuario y contraseña vacíos |
