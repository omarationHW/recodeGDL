# Documentación Técnica: Consulta Múltiple por Fecha de Emisión (CMultEmision)

## Descripción General
Este módulo permite consultar folios de la tabla `ta_15_apremios` filtrando por módulo (aplicación), zona (recaudadora) y fecha de emisión. Permite visualizar el listado y detalle de cada folio.

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## API
### Endpoint Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas:**
  - `getRecaudadoras`: Lista todas las recaudadoras.
  - `searchFoliosByFechaEmision`: Busca folios por módulo, zona y fecha de emisión.
  - `getFolioDetail`: Obtiene el detalle de un folio por id_control.

### Ejemplo de Request
```json
{
  "action": "searchFoliosByFechaEmision",
  "params": {
    "modulo": 11,
    "zona": 2,
    "fecha_emision": "2024-06-01"
  }
}
```

### Ejemplo de Response
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

## Stored Procedures
- **sp_cmultemision_search:** Devuelve todos los folios que coinciden con módulo, zona y fecha de emisión.
- **sp_cmultemision_folio_detail:** Devuelve el detalle completo de un folio por id_control.

## Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite seleccionar recaudadora, módulo y fecha de emisión.
- Muestra tabla de resultados y permite ver detalle de cada folio.
- Usa axios para consumir el endpoint `/api/execute`.

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede ser protegido por middleware de autenticación según la política de la aplicación.

## Consideraciones
- El endpoint es genérico y puede ser extendido para otras acciones.
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.

# Diagrama de Flujo
1. Usuario accede a la página de Consulta Múltiple.
2. Selecciona recaudadora, módulo y fecha de emisión.
3. Hace clic en Buscar.
4. El frontend llama a `/api/execute` con acción `searchFoliosByFechaEmision`.
5. El backend ejecuta el stored procedure y retorna los folios.
6. El usuario puede ver el detalle de cada folio (acción `getFolioDetail`).

# Estructura de la Tabla ta_15_apremios (Resumen)
- id_control (PK)
- zona
- modulo
- control_otr
- folio
- diligencia
- importe_global
- importe_multa
- importe_recargo
- importe_actualizacion
- importe_gastos
- zona_apremio
- fecha_emision
- clave_practicado
- fecha_practicado
- ... (otros campos)

# Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser extendidos para incluir joins o lógica adicional.
