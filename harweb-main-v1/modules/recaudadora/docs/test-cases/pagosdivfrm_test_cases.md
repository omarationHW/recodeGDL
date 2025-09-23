# Casos de Prueba: Consulta de Pagos Diversos

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Buscar pagos por fecha y recaudadora | fecha: 2024-06-10, recaud: 2 | Tabla con pagos diversos de esa fecha y recaudadora |
| 2 | Buscar pagos por folio inexistente | folio: 99999999 | Mensaje: 'No existen recibos de diversos con este criterio.' |
| 3 | Buscar pagos por nombre de contribuyente | contribuyente: "MARIA" | Tabla con pagos diversos cuyo contribuyente contiene "MARIA" |
| 4 | Ver detalle de pago | cvepago: 12345 | Se muestra detalle con nombre, domicilio, concepto, aplicaciones y cancelación (si existe) |
| 5 | Validación de solo números en recaud y folio | recaud: "abc" | Al teclear letras, alerta: 'Solo puedes teclear números' |
| 6 | Limpiar formulario | (Cualquier búsqueda previa) | Todos los campos vacíos y resultados ocultos |
