# Documentación Técnica: uDM_Procesos

## Análisis

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


## Casos de Uso

# Casos de Uso - uDM_Procesos

**Categoría:** Form

## Caso de Uso 1: Consulta de Tipos de Aseo

**Descripción:** El usuario accede a la página de Procesos de Aseo y visualiza la lista de tipos de aseo disponibles.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_tipo_aseo.

**Pasos a seguir:**
1. El usuario navega a la página de Procesos de Aseo.
2. El frontend realiza una petición a /api/execute con operación 'get_tipo_aseo' y tipo=0.
3. El backend responde con la lista de tipos de aseo.

**Resultado esperado:**
Se muestra un combobox con todos los tipos de aseo disponibles (excepto ctrol_aseo=0).

**Datos de prueba:**
ta_16_tipo_aseo: [{ctrol_aseo: 1, descripcion: 'Doméstico'}, {ctrol_aseo: 2, descripcion: 'Industrial'}]

---

## Caso de Uso 2: Visualización de Dashboard de Procesos

**Descripción:** El usuario selecciona un tipo de aseo y visualiza el resumen de contratos y pagos.

**Precondiciones:**
Existen contratos y pagos asociados al tipo de aseo seleccionado.

**Pasos a seguir:**
1. El usuario selecciona un tipo de aseo del combobox.
2. El frontend calcula las fechas corte según la lógica Delphi.
3. El frontend consulta el día límite del mes actual.
4. El frontend llama a /api/execute con operación 'procesos_dashboard' y los parámetros calculados.
5. El backend responde con el resumen de contratos y pagos.

**Resultado esperado:**
Se muestra el resumen de contratos (total, vigentes, cancelados) y una tabla con los pagos por operación y status.

**Datos de prueba:**
ta_16_contratos y ta_16_pagos con datos para ctrol_aseo=1, pagos con ctrol_operacion=6,7,8 y status_vigencia='V','C','P','S'.

---

## Caso de Uso 3: Consulta de Contratos por Status

**Descripción:** El usuario (o proceso) consulta cuántos contratos existen para un tipo de aseo y status específico.

**Precondiciones:**
Existen contratos con diferentes status_vigencia.

**Pasos a seguir:**
1. El frontend o backend llama a /api/execute con operación 'get_contratos_count', ctrol=1, status='V'.
2. El backend ejecuta el SP correspondiente y responde con el conteo.

**Resultado esperado:**
Se recibe el número de contratos vigentes para el tipo de aseo seleccionado.

**Datos de prueba:**
ta_16_contratos: varios registros con ctrol_aseo=1 y status_vigencia='V'.

---



## Casos de Prueba

# Casos de Prueba para Procesos de Aseo

## Caso 1: Consulta de Tipos de Aseo
- **Input:**
  - operation: get_tipo_aseo
  - params: { tipo: 0 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene lista de tipos de aseo (sin ctrol_aseo=0)

## Caso 2: Consulta de Día Límite
- **Input:**
  - operation: get_dia_limite
  - params: { mes: 6 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].dia = valor esperado según tabla

## Caso 3: Consulta de Contratos Totales
- **Input:**
  - operation: get_contratos_count
  - params: { ctrol: 1 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros = número esperado

## Caso 4: Consulta de Contratos por Status
- **Input:**
  - operation: get_contratos_count
  - params: { ctrol: 1, status: 'V' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros = número esperado de vigentes

## Caso 5: Resumen de Pagos por Operación
- **Input:**
  - operation: get_pagos_summary
  - params: { ctrol_a: 1, fecha: '2024-06', operacion: 6, status: 'V' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros y .importe correctos

## Caso 6: Dashboard de Procesos
- **Input:**
  - operation: procesos_dashboard
  - params: { ctrol_a: 1, fecha1: '2024-06', fecha2: '2024-04' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0] contiene contratos_total, contratos_vigentes, contratos_cancelados y pagos (array)

## Caso 7: Operación No Soportada
- **Input:**
  - operation: unknown_operation
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message = 'Operación no soportada'


