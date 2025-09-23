## Casos de Prueba para Cambio de Clave

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|-------------------|
| 1 | Cambio exitoso | user_id=1, current_password=abc123, new_password=xyz789, confirm_password=xyz789 | Clave cambiada satisfactoriamente |
| 2 | Clave nueva igual a la actual | user_id=1, current_password=abc123, new_password=abc123, confirm_password=abc123 | La clave nueva no debe ser igual a la actual |
| 3 | Clave nueva sin números | user_id=1, current_password=abc123, new_password=abcdef, confirm_password=abcdef | La clave debe contener letras y números |
| 4 | Clave nueva y confirmación no coinciden | user_id=1, current_password=abc123, new_password=xyz789, confirm_password=xyz788 | La nueva clave no es igual a la confirmación |
| 5 | Clave nueva menos de 6 caracteres | user_id=1, current_password=abc123, new_password=ab12, confirm_password=ab12 | La clave debe tener entre 6 y 8 caracteres |
| 6 | Los 3 primeros caracteres iguales | user_id=1, current_password=abc123, new_password=abc456, confirm_password=abc456 | Los tres primeros caracteres de la nueva clave deben ser diferentes a la actual |
| 7 | Clave actual incorrecta | user_id=1, current_password=wrongpass, new_password=xyz789, confirm_password=xyz789 | La clave actual no es correcta |
