# Documentación Técnica: Pagos_Cons_ContAsc

## Descripción General
Este módulo permite consultar los pagos asociados a contratos de recolección de residuos, filtrando por número de contrato (mayor o igual) y tipo de aseo, mostrando los pagos en orden ascendente. Incluye:
- Backend API (Laravel Controller)
- Frontend (Vue.js)
- Stored Procedures PostgreSQL
- API unificada eRequest/eResponse

## Arquitectura
- **Backend**: Laravel 10+, endpoint único `/api/execute`.
- **Frontend**: Vue.js 2/3 SPA, componente de página independiente.
- **Base de datos**: PostgreSQL, lógica en stored procedures.
- **Patrón API**: eRequest/eResponse, acción y parámetros.

## Flujo de Datos
1. El usuario ingresa un número de contrato y selecciona tipo de aseo.
2. El frontend llama a `/api/execute` con acción `buscarContratos`.
3. El backend ejecuta `sp_buscar_contratos_asc` y retorna los contratos.
4. El usuario selecciona un contrato y el frontend llama a `/api/execute` con acción `pagosPorContrato`.
5. El backend ejecuta `sp_pagos_por_contrato_asc` y retorna los pagos.

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "buscarContratos",
    "params": { "contrato": 123, "ctrol_aseo": 8 }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Stored Procedures
- `sp_get_tipo_aseo()`: Catálogo de tipos de aseo.
- `sp_buscar_contratos_asc(p_num_contrato, p_ctrol_aseo)`: Contratos >= número y tipo aseo.
- `sp_pagos_por_contrato_asc(p_control_contrato)`: Pagos del contrato (vigencia 'P').

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación si es necesario.

## Validaciones
- El número de contrato debe ser numérico y mayor a cero.
- El tipo de aseo debe existir en catálogo.
- El control de errores se maneja en el backend y se muestra en el frontend.

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón.
- Los stored procedures pueden ampliarse para incluir más filtros o lógica.

## Integración
- El componente Vue puede integrarse en cualquier SPA.
- El backend puede ser consumido por otros sistemas vía REST.

## Notas
- No se usan tabs ni subcomponentes: cada formulario es una página independiente.
- El frontend muestra mensajes de error y validación amigables.
