# Casos de Prueba: Cambio de Clave

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|--------------------|
| 1 | Cambio exitoso | user_id: 1, current_password: 'abc123', new_password: 'xyz789', confirm_password: 'xyz789' | Clave cambiada satisfactoriamente |
| 2 | Clave actual incorrecta | user_id: 1, current_password: 'wrongpass' | Error: La clave actual no es correcta |
| 3 | Nueva clave igual a la actual | user_id: 1, current_password: 'abc123', new_password: 'abc123', confirm_password: 'abc123' | Error: La clave nueva no debe ser igual a la actual |
| 4 | Nueva clave menos de 6 caracteres | user_id: 1, current_password: 'abc123', new_password: 'a1b2', confirm_password: 'a1b2' | Error: La clave debe ser mayor a 5 dígitos |
| 5 | Nueva clave sólo letras | user_id: 1, current_password: 'abc123', new_password: 'abcdef', confirm_password: 'abcdef' | Error: La clave debe contener números y letras |
| 6 | Nueva clave sólo números | user_id: 1, current_password: 'abc123', new_password: '123456', confirm_password: '123456' | Error: La clave debe contener números y letras |
| 7 | Confirmación no coincide | user_id: 1, current_password: 'abc123', new_password: 'xyz789', confirm_password: 'xyz788' | Error: La confirmación de la clave no es igual |
| 8 | Primeros 3 caracteres iguales | user_id: 1, current_password: 'abc123', new_password: 'abc999', confirm_password: 'abc999' | Error: Los tres primeros caracteres deben ser diferentes al actual |
