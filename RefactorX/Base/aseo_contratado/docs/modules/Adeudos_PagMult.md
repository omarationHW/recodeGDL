# Documentación Técnica: Adeudos_PagMult (Laravel + Vue.js + PostgreSQL)

## Descripción General
El formulario "Adeudos_PagMult" permite dar de pagado en forma múltiple los adeudos vigentes (excedencias) de un contrato. El proceso incluye:
- Selección de contrato y tipo de aseo
- Visualización de adeudos vigentes
- Selección múltiple de adeudos a pagar
- Captura de datos de pago (fecha, recaudadora, caja, consecutivo, folio)
- Ejecución del pago en lote

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js SPA, página independiente para el formulario
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## API (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "listar_catalogos|buscar_contrato|listar_adeudos|pagar_adeudos",
      ... parámetros ...
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

### Acciones soportadas
- `listar_catalogos`: Devuelve catálogos de tipos de aseo, recaudadoras y cajas
- `buscar_contrato`: Busca contrato por número y tipo de aseo
- `listar_adeudos`: Lista adeudos vigentes de un contrato
- `pagar_adeudos`: Marca como pagados los adeudos seleccionados

## Stored Procedures
- **sp_adeudos_pagmult_listar_catalogos**: Devuelve catálogos
- **sp_adeudos_pagmult_buscar_contrato**: Busca contrato
- **sp_adeudos_pagmult_listar_adeudos**: Lista adeudos vigentes
- **sp_adeudos_pagmult_pagar_adeudos**: Marca como pagados los adeudos seleccionados

## Seguridad
- El endpoint requiere autenticación (no implementada en ejemplo, pero debe integrarse con middleware de Laravel)
- Validación de parámetros en backend
- Transacciones para operaciones de pago

## Frontend (Vue.js)
- Página independiente, sin tabs
- Navegación breadcrumb
- Tabla de adeudos con selección múltiple
- Formulario de datos de pago
- Mensajes de error y éxito

## Flujo de Usuario
1. Selecciona contrato y tipo de aseo
2. Visualiza datos del contrato
3. Consulta adeudos vigentes
4. Selecciona adeudos a pagar
5. Captura datos de pago y ejecuta
6. El sistema actualiza los registros y muestra confirmación

## Integración
- El componente Vue.js se comunica con el backend mediante fetch/AJAX al endpoint `/api/execute`
- El backend ejecuta el stored procedure correspondiente según la acción

## Consideraciones
- El usuario debe estar autenticado (simulado en ejemplo)
- Los SP deben estar creados en la base de datos PostgreSQL
- El endpoint puede ser extendido para otras acciones del sistema
