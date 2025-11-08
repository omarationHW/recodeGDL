## Casos de Prueba para Formulario tipobloqueofrm

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Bloqueo exitoso con datos válidos | tipo_bloqueo_id=2, motivo='FALTA DE PAGO', usuario_id=1, licencia_id=1001 | Bloqueo registrado correctamente. |
| 2 | Tipo de bloqueo inválido | tipo_bloqueo_id=999, motivo='PRUEBA', usuario_id=1, licencia_id=1001 | Tipo de bloqueo inválido. |
| 3 | Licencia inexistente | tipo_bloqueo_id=2, motivo='PRUEBA', usuario_id=1, licencia_id=9999 | Licencia no encontrada. |
| 4 | Motivo vacío | tipo_bloqueo_id=2, motivo='', usuario_id=1, licencia_id=1001 | Error de validación: motivo requerido. |
| 5 | Cancelar formulario | - | No se realiza ningún cambio, regresa a la página anterior. |
| 6 | Cargar catálogo de tipos de bloqueo | - | Lista de tipos de bloqueo activos mostrada en el select. |
