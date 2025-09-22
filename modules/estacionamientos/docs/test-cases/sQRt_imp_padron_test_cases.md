# Casos de Prueba: Padrón Vehicular

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta exitosa con resultados | id1=100, id2=110 | Tabla con registros entre 100 y 110 |
| TC02 | Consulta sin resultados | id1=999999, id2=1000000 | Mensaje: 'No hay resultados para mostrar.' |
| TC03 | Parámetro faltante (id1 vacío) | id1='', id2=200 | Mensaje de error: 'Missing parameters id1 or id2' |
| TC04 | id1 > id2 | id1=200, id2=100 | Tabla vacía o mensaje de 'No hay resultados' |
| TC05 | id1 y id2 iguales | id1=150, id2=150 | Tabla con un solo registro si existe el ID 150 |
| TC06 | Error de conexión a la base de datos | (Simular caída de DB) | Mensaje de error de servidor |
