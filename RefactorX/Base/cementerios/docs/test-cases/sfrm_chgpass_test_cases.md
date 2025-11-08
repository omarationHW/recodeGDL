# Casos de Prueba: Cambio de Clave de Acceso

| Caso | Descripción | Datos de Prueba | Resultado Esperado |
|------|-------------|-----------------|-------------------|
| 1 | Cambio exitoso | current: abc123, new: xyz789, confirm: xyz789 | Mensaje de éxito, clave cambiada |
| 2 | Clave actual incorrecta | current: wrongpass | Mensaje de error, no avanza |
| 3 | Nueva clave igual a actual | current: abc123, new: abc123, confirm: abc123 | Error: 'La clave no debe ser igual a la actual.' |
| 4 | Nueva clave < 6 caracteres | current: abc123, new: ab12, confirm: ab12 | Error: 'La clave debe ser mayor a 5 dígitos.' |
| 5 | Nueva clave sin letras | current: abc123, new: 123456, confirm: 123456 | Error: 'La clave debe contener números y letras.' |
| 6 | Nueva clave sin números | current: abc123, new: abcdef, confirm: abcdef | Error: 'La clave debe contener números y letras.' |
| 7 | Nueva clave con 3 primeros caracteres iguales a actual | current: abc123, new: abc999, confirm: abc999 | Error: 'Los tres primeros caracteres deben ser diferentes al actual.' |
| 8 | Confirmación distinta | current: abc123, new: xyz789, confirm: xyz788 | Error: 'La confirmación de la clave no es igual.' |
| 9 | Usuario inactivo | current: abc123, new: xyz789, confirm: xyz789 | Error: 'Usuario no encontrado o inactivo.' |
