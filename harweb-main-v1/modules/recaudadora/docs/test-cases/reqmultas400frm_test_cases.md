## Casos de Prueba para reqmultas400frm

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Consulta por acta válida (federal) | dep: 'DEP', axo: 2023, numacta: 12345, tipo: 6 | Buscar por Acta | Tabla con registros correspondientes |
| 2 | Consulta por folio válida (municipal) | axo: 2022, folio: 54321, tipo: 5 | Buscar por Folio Req | Tabla con registros correspondientes |
| 3 | Consulta por acta inexistente | dep: 'ZZZ', axo: 1900, numacta: 99999, tipo: 6 | Buscar por Acta | Mensaje 'No se encontraron resultados.' |
| 4 | Consulta por folio con campos vacíos | axo: '', folio: '', tipo: 5 | Buscar por Folio Req | Mensaje de error de validación |
| 5 | Consulta por acta con tipo municipal | dep: 'DEP', axo: 2023, numacta: 12345, tipo: 5 | Buscar por Acta | Tabla con registros municipales o mensaje de no encontrados |
| 6 | Error de comunicación (API caída) | Cualquier entrada | Buscar | Mensaje 'Error de comunicación con el servidor.' |
