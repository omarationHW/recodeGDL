# Documentación Técnica: Estadística General de Contratos (ContratosEst)

## Descripción General
Este módulo implementa la migración del formulario Delphi `sQRptContratos_Est` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio vía stored procedures). El objetivo es proveer una página de consulta estadística de contratos de aseo, con filtros por tipo de aseo y periodo, y mostrar totales y desgloses por estado y operación.

## Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, componente de página independiente
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures

## API (Laravel)
- **Endpoint:** `POST /api/execute`
- **Request:**
  - `action`: string (ej: `get_estadistica_periodo`)
  - `params`: objeto con parámetros específicos
- **Response:**
  - `success`: boolean
  - `data`: array/objeto con los resultados
  - `message`: string (mensaje de error o éxito)

### Acciones soportadas
- `get_tipo_aseo`: Lista de tipos de aseo
- `get_dia_limite`: Día límite del mes actual
- `get_contratos_estadistica`: Estadística general (por tipo de aseo)
- `get_contratos_estadistica_totales`: Totales generales
- `get_periodos`: Periodos disponibles
- `get_estadistica_periodo`: Estadística filtrada por tipo de aseo y periodo

## Frontend (Vue.js)
- Página independiente `/contratos-estadistica`
- Formulario de filtros: tipo de aseo, año/mes inicio y fin
- Tabla de resultados con totales y desglose por operación y estado
- Navegación breadcrumb
- Manejo de loading y errores

## Stored Procedures (PostgreSQL)
- `sp_contratos_estadistica(p_cve_aseo TEXT)`: Estadística general por tipo de aseo
- `sp_contratos_estadistica_periodo(p_cve_aseo TEXT, p_aso_in INT, p_mes_in INT, p_aso_fin INT, p_mes_fin INT)`: Estadística filtrada por periodo
- `sp_contratos_estadistica_totales()`: Totales generales

## Seguridad
- Validación de parámetros en backend
- Sanitización de entradas
- Manejo de errores y logging

## Integración
- El frontend consume el endpoint `/api/execute` vía fetch/AJAX
- El backend enruta la acción al stored procedure correspondiente
- Los stored procedures devuelven los datos agregados para la vista

## Consideraciones
- El endpoint es unificado para facilitar integración y versionado
- El frontend es desacoplado y puede ser embebido en cualquier SPA
- Los stored procedures pueden ser reutilizados por otros módulos

# Esquema de Base de Datos (relevante)
- `ta_16_contratos`: contratos de aseo
- `ta_16_pagos`: pagos asociados a contratos
- `ta_16_operacion`: catálogo de operaciones (C=Cuota Normal, E=Excedente, D=Contenedor)
- `ta_16_tipo_aseo`: catálogo de tipos de aseo

# Ejemplo de Request/Response
**Request:**
```json
{
  "action": "get_estadistica_periodo",
  "params": {
    "cve_aseo": "O",
    "aso_in": 2023,
    "mes_in": 1,
    "aso_fin": 2023,
    "mes_fin": 6
  }
}
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "tipo_aseo": "O",
      "total_contratos": 120,
      "importe_total": 123456.78,
      ...
    }
  ],
  "message": ""
}
```

# Despliegue
- Registrar el controlador en `routes/api.php`:
  ```php
  Route::post('/execute', [ContratosEstController::class, 'execute']);
  ```
- Registrar los stored procedures en la base de datos PostgreSQL
- Incluir el componente Vue en el router SPA

# Pruebas
- Probar con distintos tipos de aseo y periodos
- Validar que los totales coincidan con los datos históricos
- Verificar manejo de errores y mensajes
