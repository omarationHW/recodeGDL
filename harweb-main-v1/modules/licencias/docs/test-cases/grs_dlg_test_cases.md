## Casos de Prueba para grs_dlg (Laravel + Vue.js + PostgreSQL)

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Búsqueda parcial insensible en clientes | table: clientes, field: nombre, value: juan, case_insensitive: true, partial: true | Lista de clientes con 'juan' en el nombre (mayúsculas/minúsculas indiferente) |
| 2 | Búsqueda exacta sensible en productos | table: productos, field: codigo, value: ABC123, case_insensitive: false, partial: false | Solo el producto con código exactamente 'ABC123' |
| 3 | Búsqueda sin resultados | table: proveedores, field: razon_social, value: ZZZZZZ, case_insensitive: true, partial: true | Mensaje 'No se encontraron resultados.' |
| 4 | Campo tabla vacío | table: '', field: nombre, value: juan | Mensaje de error 'Missing table or field parameter.' |
| 5 | Campo field vacío | table: clientes, field: '', value: juan | Mensaje de error 'Missing table or field parameter.' |
| 6 | Búsqueda con valor vacío | table: clientes, field: nombre, value: '', case_insensitive: true, partial: true | Todos los registros de clientes (búsqueda con '%') |
| 7 | SQL Injection en campo tabla | table: 'clientes; DROP TABLE clientes;', field: nombre, value: juan | Error de SQL o validación (no debe ejecutarse) |

### Notas:
- Probar con y sin mayúsculas/minúsculas.
- Probar con y sin búsqueda parcial.
- Probar con tablas/campos inexistentes para validar manejo de errores.
