# Casos de Prueba para Catálogo de Claves de Recolección

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta por número de control | ejercicio=2024, order_by=ctrol | Tabla con registros 2024 ordenados por ctrol_recolec |
| TC02 | Consulta por clave | ejercicio=2024, order_by=cve | Tabla con registros 2024 ordenados por cve_recolec |
| TC03 | Consulta por descripción | ejercicio=2023, order_by=descripcion | Tabla con registros 2023 ordenados por descripcion |
| TC04 | Consulta por costo de unidad | ejercicio=2023, order_by=costo | Tabla con registros 2023 ordenados por costo_unidad |
| TC05 | Consulta sin resultados | ejercicio=2022, order_by=ctrol | Mensaje de 'No se encontraron registros' |
| TC06 | Error de parámetro inválido | ejercicio=2024, order_by=INVALIDO | Se usa orden por ctrol_recolec por defecto |
| TC07 | Listado de ejercicios | - | Lista de ejercicios únicos disponibles |
| TC08 | Error de conexión a BD | - | Mensaje de error adecuado en frontend |
