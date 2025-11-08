# Documentación Técnica: Migración Formulario ReqsCons (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (eRequest/eResponse)
- **Frontend**: Vue.js SPA, cada formulario es una página independiente
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Payload**:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Respuesta**:
  ```json
  {
    "status": "ok|error|not_found",
    "data": ...,
    "message": "..."
  }
  ```

## 3. Acciones Disponibles
- `getTipoAseo`: Catálogo de tipos de aseo
- `getRecaudadoras`: Catálogo de recaudadoras
- `buscarContrato`: Busca contrato por número y tipo de aseo
- `buscarApremios`: Lista de apremios de un contrato
- `buscarPeriodosApremio`: Periodos de un apremio
- `buscarConvenio`: Convenio relacionado a un contrato
- `ejecutarPagoApremio`: Marca un apremio como pagado

## 4. Seguridad
- Se recomienda implementar autenticación JWT o similar en producción.
- Validar todos los parámetros en backend.

## 5. Vue.js
- Cada formulario es una página independiente (NO tabs)
- Navegación por rutas (ej: `/requerimientos`)
- Uso de fetch para consumir `/api/execute`
- Manejo de errores y mensajes de usuario

## 6. Stored Procedures
- Toda la lógica de negocio y consultas SQL se implementa en stored procedures y funciones PostgreSQL.
- El controlador Laravel solo invoca los SPs y retorna el resultado.

## 7. Flujo de Consulta y Pago de Requerimientos
1. Usuario ingresa contrato y tipo de aseo
2. Se consulta el contrato y su status
3. Se listan los apremios asociados
4. Al seleccionar un apremio, se muestran sus periodos
5. El usuario puede registrar el pago del apremio (si tiene permisos)
6. El pago se ejecuta vía stored procedure y se actualiza la vista

## 8. Consideraciones de Migración
- Los combos Delphi se migran a selects Vue.js
- Los grids Delphi se migran a tablas HTML
- Los procedimientos Delphi se migran a stored procedures y funciones PostgreSQL
- El backend es stateless y desacoplado de la UI

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los stored procedures pueden evolucionar sin afectar la API

## 10. Pruebas y Auditoría
- Todas las acciones relevantes quedan registradas en la base de datos
- Se recomienda agregar triggers de auditoría para cambios críticos
