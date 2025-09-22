# Documentación Técnica - Migración Formulario EdoCuenta (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.
- **Frontend**: Vue.js SPA, cada formulario es una página independiente (no tabs), navegación por rutas.
- **Base de Datos**: PostgreSQL, toda la lógica SQL relevante se implementa en stored procedures y funciones.

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute` (POST)
- **Entrada**: `{ eRequest: { action: string, params: object } }`
- **Salida**: `{ eResponse: { status: 'ok'|'error', data: any, message: string } }`
- **Acciones soportadas**:
  - `getTipos`: Lista de tipos de convenios
  - `getSubTipos`: Lista de subtipos para un tipo
  - `getEdoCuenta`: Consulta de convenios por tipo/subtipo
  - `getPagos`: Pagos de un convenio
  - `getAdeudos`: Adeudos de un convenio (con cálculo de recargos)
  - `getRecargos`: Cálculo de recargos para un periodo

## 3. Stored Procedures y Funciones
- Toda la lógica de consulta y cálculo de recargos se implementa en funciones PostgreSQL.
- Los cálculos de recargos replican la lógica Delphi, incluyendo días inhábiles y reglas de truncamiento.

## 4. Vue.js Component
- Página independiente `/edo-cuenta`.
- Formulario para seleccionar tipo y subtipo.
- Tabla de convenios encontrados.
- Al seleccionar un convenio, muestra detalle de pagos y adeudos (con recargos calculados).
- Navegación breadcrumb.
- Sin tabs ni componentes tabulares.

## 5. Laravel Controller
- Un solo método `execute` que despacha según `action`.
- Cada acción llama a un stored procedure o función.
- Manejo de errores y validaciones.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar que los parámetros sean correctos y que el usuario tenga permisos.

## 7. Pruebas
- Se proveen casos de uso y escenarios de prueba para QA.

## 8. Extensibilidad
- Para agregar nuevas acciones, basta con agregar un nuevo case en el controlador y el SP correspondiente.

## 9. Notas de Migración
- Los cálculos de recargos y días inhábiles se migran fielmente de Delphi a SQL.
- El frontend es completamente reactivo y desacoplado del backend.

# Esquema de Base de Datos
- Tablas principales: `ta_17_con_reg_pred`, `ta_17_conv_d_resto`, `ta_17_adeudos_div`, `ta_17_conv_pagos`, `ta_13_recargosrcm`, `ta_12_diasinhabil`.

# Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "getEdoCuenta",
    "params": { "tipo": 14, "subtipo": 1 }
  }
}
```

```json
{
  "eResponse": {
    "status": "ok",
    "data": [ ... ],
    "message": ""
  }
}
```
