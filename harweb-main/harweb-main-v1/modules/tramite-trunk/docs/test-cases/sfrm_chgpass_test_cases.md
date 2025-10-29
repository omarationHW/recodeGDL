# Casos de Prueba: Cambio de Clave

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Cambio exitoso | username=juan, current_password=abc123, new_password=xyz789, confirm_password=xyz789 | Clave cambiada exitosamente |
| 2 | Clave actual incorrecta | username=juan, current_password=wrongpass | Error: La clave actual no es correcta |
| 3 | Nueva clave igual a la actual | username=juan, current_password=abc123, new_password=abc123 | Error: La clave no debe ser igual a la actual |
| 4 | Nueva clave sin números | username=juan, current_password=abc123, new_password=abcdefg | Error: La clave debe contener números y letras |
| 5 | Nueva clave sin letras | username=juan, current_password=abc123, new_password=1234567 | Error: La clave debe contener números y letras |
| 6 | Nueva clave con 3 primeros caracteres iguales | username=juan, current_password=abc123, new_password=abc999 | Error: Los tres primeros caracteres deben ser diferentes al actual |
| 7 | Confirmación de clave diferente | username=juan, current_password=abc123, new_password=xyz789, confirm_password=xyz788 | Error: La confirmación de la clave no es igual |
| 8 | Nueva clave muy corta | username=juan, current_password=abc123, new_password=a1 | Error: La clave debe tener entre 2 y 8 caracteres |
| 9 | Nueva clave muy larga | username=juan, current_password=abc123, new_password=abcdefg1h | Error: La clave debe tener entre 2 y 8 caracteres |
