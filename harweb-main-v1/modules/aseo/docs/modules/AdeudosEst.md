# Estadístico de Pagos (AdeudosEst)

## Descripción General
Este módulo permite consultar y visualizar un reporte estadístico de pagos realizados por periodo (año-mes), discriminando entre Cuota Normal, Excedente y Contenedores, en el sistema de gestión de adeudos. El usuario puede seleccionar un rango de periodos (año y mes inicial/final) y obtener el total de pagos realizados por cada tipo en cada periodo.

## Arquitectura
- **Backend (Laravel):**
  - Un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
  - El controlador `AdeudosEstController` procesa la acción `get_estadistico_pagos` y llama al stored procedure de PostgreSQL.
- **Frontend (Vue.js):**
  - Página independiente `EstadisticoPagos.vue` que permite seleccionar el rango de periodos y muestra el resultado en una tabla.
- **Base de Datos (PostgreSQL):**
  - Stored procedure `sp_estadistico_pagos` que realiza la consulta agregada por periodo.

## Flujo de Datos
1. El usuario ingresa el periodo inicial y final (año y mes).
2. El frontend envía una petición POST a `/api/execute` con la acción `get_estadistico_pagos` y los parámetros.
3. El backend valida los parámetros y ejecuta el stored procedure `sp_estadistico_pagos`.
4. El resultado se retorna al frontend, que lo muestra en una tabla.

## Validaciones
- Los años deben ser numéricos y de 4 dígitos.
- El periodo final no puede ser anterior al inicial.
- Los meses deben estar entre 1 y 12.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel estándar).
- Los parámetros son validados en el backend.

## API
- **POST /api/execute**
  - **action:** `get_estadistico_pagos`
  - **params:** `{ aso_in, mes_in, aso_fin, mes_fin }`
  - **Respuesta:**
    - `success: true|false`
    - `data: [ { periodo, cuota_normal, excedente, contenedores } ]`
    - `message: string`

## SQL
- La función `sp_estadistico_pagos` utiliza la tabla `ta_16_recargos` para obtener los periodos y suma los importes de pagos por tipo de operación y periodo.

## Extensibilidad
- El endpoint y el stored procedure pueden ser extendidos para incluir otros tipos de operaciones o filtros adicionales.

## Pruebas
- Incluye casos de uso y pruebas para rangos válidos, sin resultados y validación de errores.
