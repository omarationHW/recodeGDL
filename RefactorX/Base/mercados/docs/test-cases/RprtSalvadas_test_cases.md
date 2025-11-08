## Casos de Prueba para RprtSalvadas

| #  | Descripción                                      | Datos de Entrada                        | Resultado Esperado                                             |
|----|--------------------------------------------------|-----------------------------------------|---------------------------------------------------------------|
| 1  | Reporte con resultados                           | start_date: 2024-06-01<br>end_date: 2024-06-30 | Tabla con registros de salvadas del mes de junio 2024         |
| 2  | Reporte sin resultados                           | start_date: 2023-01-01<br>end_date: 2023-01-31 | Mensaje: "No se encontraron resultados para el rango seleccionado." |
| 3  | Fechas inválidas (inicio > fin)                  | start_date: 2024-07-01<br>end_date: 2024-06-01 | Mensaje de error: "El rango de fechas es inválido."           |
| 4  | Error de conexión a la API                       | (Desconectar backend)                    | Mensaje de error: "Error de red o del servidor"               |
| 5  | Campos requeridos vacíos                         | start_date: (vacío)<br>end_date: (vacío)   | Mensaje de error: "Campos requeridos" o validación frontend   |
