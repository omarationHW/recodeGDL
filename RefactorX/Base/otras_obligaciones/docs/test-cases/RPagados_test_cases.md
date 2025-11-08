# Casos de Prueba: RPagados

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa con ID de control válido | p_Control = 1001 | Tabla con registros de pagos asociados a 1001 |
| TC02 | Consulta con ID de control inexistente | p_Control = 999999 | Mensaje: "No se encontraron registros para el ID Control ingresado." |
| TC03 | Consulta sin ingresar ID de control | p_Control = '' | Mensaje de error: "Parámetro p_Control requerido" |
| TC04 | Consulta con ID de control válido pero sin pagos con status válidos | p_Control = 2002 (existe en t34_pagos pero solo con status no válidos) | Mensaje: "No se encontraron registros para el ID Control ingresado." |
| TC05 | Error de conexión a la base de datos | (Simular caída de DB) | Mensaje de error: "Error de comunicación con el servidor" |
