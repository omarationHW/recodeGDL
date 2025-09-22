# Casos de Prueba RAdeudos

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Consulta exitosa de adeudos vencidos | numero: 123, letra: A, vigencia: vencidos | Muestra datos del local y tabla de adeudos vencidos |
| 2 | Consulta exitosa de otro periodo | numero: 456, letra: B, vigencia: otro, aso: 2023, mes: 05 | Muestra datos del local y adeudos del periodo 2023-05 |
| 3 | Local inexistente | numero: 999, letra: Z, vigencia: vencidos | Mensaje de error: 'No existe LOCAL con este dato, intentalo de nuevo' |
| 4 | Falta número de local | numero: '', letra: '', vigencia: vencidos | Mensaje de error: 'Falta el dato del NÚMERO DE LOCAL, intentalo de nuevo' |
| 5 | Falta año en otro periodo | numero: 123, letra: A, vigencia: otro, aso: '', mes: 01 | Mensaje de error: 'Falta el dato del AÑO a consultar, intentalo de nuevo' |
| 6 | Local sin adeudos | numero: 321, letra: C, vigencia: vencidos | Muestra datos del local y tabla vacía de adeudos |
