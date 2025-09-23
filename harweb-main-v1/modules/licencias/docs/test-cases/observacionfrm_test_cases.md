# Casos de Prueba para Observaciones

| Caso | Descripción | Entrada | Acción | Resultado Esperado |
|------|-------------|---------|--------|-------------------|
| TC01 | Guardar observación válida | "El sistema fue revisado." | Guardar | Observación guardada, mensaje de éxito, aparece en la lista |
| TC02 | Guardar observación vacía | "" | Guardar | Mensaje de error, no se guarda nada |
| TC03 | Guardar observación con minúsculas | "prueba de minusculas" | Guardar | Se guarda como "PRUEBA DE MINUSCULAS" |
| TC04 | Visualizar historial | N/A | Acceder a página | Lista de observaciones mostrada |
| TC05 | Exceso de longitud | Texto de 2001 caracteres | Guardar | Mensaje de error de validación |
| TC06 | Inyección SQL | "'); DROP TABLE observaciones; --" | Guardar | Observación guardada como texto, sin afectar la base de datos |
| TC07 | Carácter especial | "Observación con ñ y acentos áéíóú" | Guardar | Se guarda correctamente en mayúsculas |
