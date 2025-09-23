# Casos de Prueba: Consulta de Transmisiones Patrimoniales

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|--------------------|
| 1 | Consulta exacta | notaria: 1, municipio: 2, escritura: 123 | Se muestra el registro correspondiente |
| 2 | Consulta solo por notaria | notaria: 5, municipio: null, escritura: null | Se muestran todos los registros de notaria 5 |
| 3 | Consulta sin resultados | notaria: 99, municipio: 99, escritura: 9999 | Mensaje: No se encontraron resultados |
| 4 | Campos vacíos | notaria: null, municipio: null, escritura: null | Se muestran todos los registros de la tabla |
| 5 | Error de conexión | --- | Mensaje de error de comunicación |
| 6 | Ingreso de texto en campos numéricos | notaria: 'abc', municipio: 'def', escritura: 'ghi' | Validación frontend: solo números permitidos |
