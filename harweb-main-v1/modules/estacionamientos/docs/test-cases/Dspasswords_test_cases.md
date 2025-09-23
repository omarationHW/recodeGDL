# Casos de Prueba para Gestión de Passwords

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Listar passwords de usuario existente | { "eRequest": "passwords.list", "params": { "usuario": "admin" } } | Lista de registros para 'admin' |
| TC02 | Listar passwords sin filtro | { "eRequest": "passwords.list", "params": {} } | Lista completa de registros |
| TC03 | Crear nuevo password válido | { "eRequest": "passwords.create", "params": { "usuario": "jdoe", "nombre": "John Doe", "estado": "A", "id_rec": 1, "nivel": 2 } } | Registro creado correctamente |
| TC04 | Crear password con usuario duplicado | { "eRequest": "passwords.create", "params": { "usuario": "admin", "nombre": "Admin", "estado": "A", "id_rec": 1, "nivel": 1 } } | Error de duplicidad (si aplica restricción) |
| TC05 | Editar password existente | { "eRequest": "passwords.update", "params": { "id_usuario": 2, "usuario": "jdoe", "nombre": "John Doe Updated", "estado": "I", "id_rec": 1, "nivel": 3 } } | Registro actualizado correctamente |
| TC06 | Eliminar password existente | { "eRequest": "passwords.delete", "params": { "id_usuario": 2 } } | Confirmación de eliminación |
| TC07 | Eliminar password inexistente | { "eRequest": "passwords.delete", "params": { "id_usuario": 9999 } } | Eliminación sin error, sin afectar registros |
| TC08 | Crear password con campos vacíos | { "eRequest": "passwords.create", "params": { "usuario": "", "nombre": "", "estado": "", "id_rec": null, "nivel": null } } | Error de validación |
