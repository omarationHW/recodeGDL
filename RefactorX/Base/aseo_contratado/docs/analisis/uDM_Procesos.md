# Documentación Técnica: Migración de uDM_Procesos (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (SPA, página independiente para Procesos de Aseo)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)
- **Patrón de API:** eRequest/eResponse (el request indica la operación y parámetros)

## 2. Endpoint Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "message": "..."
    }
  }
  ```

## 3. Operaciones Soportadas
- `get_tipo_aseo`: Lista tipos de aseo (parámetro: tipo)
- `get_dia_limite`: Obtiene día límite para un mes (parámetro: mes)
- `get_contratos_count`: Cuenta contratos por tipo y status (parámetros: ctrol, status)
- `get_pagos_summary`: Resumen de pagos por operación y status (parámetros: ctrol_a, fecha, operacion, status)
- `procesos_dashboard`: Devuelve el resumen principal de contratos y pagos para el dashboard (parámetros: ctrol_a, fecha1, fecha2)

## 4. Stored Procedures
- Toda la lógica de consultas y agregados está en SPs PostgreSQL.
- El controlador Laravel solo invoca los SPs vía `DB::select`.

## 5. Frontend Vue.js
- Página independiente (no tab, no subcomponente)
- Selección de tipo de aseo (combobox)
- Al seleccionar, calcula fechas corte y consulta el dashboard
- Muestra resumen de contratos y pagos por operación/status
- Navegación breadcrumb incluida

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej: Sanctum, JWT) en producción.
- Validar parámetros en el backend antes de invocar SPs.

## 7. Consideraciones
- El frontend asume que los SPs devuelven los datos en el formato esperado.
- El dashboard simula la lógica del evento AfterScroll de Delphi.
- El endpoint es extensible para otras operaciones.

## 8. Ejemplo de Request/Response
### Request
```json
{
  "eRequest": {
    "operation": "procesos_dashboard",
    "params": {
      "ctrol_a": 1,
      "fecha1": "2024-06",
      "fecha2": "2024-04"
    }
  }
}
```
### Response
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "contratos_total": 100,
        "contratos_vigentes": 80,
        "contratos_cancelados": 20,
        "pagos": [ ... ]
      }
    ],
    "message": ""
  }
}
```
