# Casos de Prueba: Listado de Notificaciones

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta por lote (notificaciones) | reca=2, axo=2024, inicio=1000, final=2000, tipo='N', orden='lote' | Tabla con registros ordenados por lote y acta, total correcto |
| TC02 | Consulta solo vigentes (requerimientos) | reca=3, axo=2023, inicio=5000, final=6000, tipo='R', orden='vigentes' | Solo registros con cvepago y fecha_cancelacion NULL, ordenados por folioreq |
| TC03 | Consulta por dependencia (secuestros) | reca=1, axo=2022, inicio=7000, final=8000, tipo='S', orden='dependencia' | Registros ordenados por dependencia, año y número de acta |
| TC04 | Parámetro faltante | Falta 'reca' | Error: Missing parameter: reca |
| TC05 | Orden inválido | orden='otro' | Error: Orden no válido: otro |
| TC06 | Sin resultados | rango de folios sin registros | Mensaje: No se encontraron resultados |
| TC07 | SQL Injection | tipo="N'; DROP TABLE multas; --" | Error, sin ejecución de SQL malicioso |
