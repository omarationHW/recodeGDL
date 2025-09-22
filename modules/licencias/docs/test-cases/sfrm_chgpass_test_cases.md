## Casos de Prueba para Cambio de Contraseña

| Caso | Descripción | Datos de Prueba | Resultado Esperado |
|------|-------------|-----------------|-------------------|
| 1 | Cambio exitoso | username: jdoe, current_password: abc123, new_password: xyz789, confirm_password: xyz789 | Clave cambiada exitosamente |
| 2 | Clave nueva igual a actual | username: jdoe, current_password: abc123, new_password: abc123, confirm_password: abc123 | La nueva clave no debe ser igual a la actual |
| 3 | Clave nueva sin números | username: jdoe, current_password: abc123, new_password: abcdef, confirm_password: abcdef | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 4 | Clave nueva sin letras | username: jdoe, current_password: abc123, new_password: 123456, confirm_password: 123456 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 5 | Clave nueva menos de 6 caracteres | username: jdoe, current_password: abc123, new_password: ab12, confirm_password: ab12 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 6 | Clave nueva más de 8 caracteres | username: jdoe, current_password: abc123, new_password: abcd12345, confirm_password: abcd12345 | La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres |
| 7 | Los tres primeros caracteres iguales | username: jdoe, current_password: abc123, new_password: abc456, confirm_password: abc456 | Los tres primeros caracteres deben ser diferentes a la clave actual |
| 8 | Confirmación no coincide | username: jdoe, current_password: abc123, new_password: xyz789, confirm_password: xyz788 | La nueva clave no es igual a la confirmación |
| 9 | Contraseña actual incorrecta | username: jdoe, current_password: wrongpass, new_password: xyz789, confirm_password: xyz789 | La clave actual no es correcta |
