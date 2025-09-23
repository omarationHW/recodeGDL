# Casos de Prueba: Formulario fechasegfrm

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Guardar registro válido | fecha: 2024-07-01, oficio: OF-1234 | Registro guardado, mensaje de éxito, aparece en la tabla |
| TC02 | Guardar sin oficio | fecha: 2024-07-01, oficio: (vacío) | Mensaje de error, no se guarda registro |
| TC03 | Guardar sin fecha | fecha: (vacío), oficio: OF-1234 | Mensaje de error, no se guarda registro |
| TC04 | Oficio demasiado largo | fecha: 2024-07-01, oficio: (256 caracteres) | Mensaje de error, no se guarda registro |
| TC05 | Visualizar registros recientes | - | Se muestran los últimos 20 registros en la tabla |
| TC06 | Cancelar formulario | (cualquier dato) | Los campos se limpian, no se envía nada al backend |
