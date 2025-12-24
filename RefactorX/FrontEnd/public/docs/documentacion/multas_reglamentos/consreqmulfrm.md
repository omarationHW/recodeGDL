# Documentación: consreqmulfrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario consreqmulfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la consulta de requerimientos asociados a una multa municipal. Permite buscar multas por contribuyente, domicilio o dependencia, visualizar los requerimientos asociados, editar/cancelar multas y consultar histórico y prescripción.

## 2. Arquitectura
- **Backend:** Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js SPA (Single Page Application), componente de página independiente
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Comunicación:** JSON, patrón eRequest/eResponse

## 3. API Backend
### Endpoint Unificado
- **URL:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error",
    "data": [ ... ],
    "message": "..."
  }
  ```

### Acciones soportadas
- `getMultaById`: Consulta una multa por ID
- `searchMultas`: Búsqueda avanzada de multas
- `getRequerimientosByMulta`: Lista requerimientos asociados a una multa
- `updateMulta`: Modifica calificación, multa y comentario
- `cancelMulta`: Cancela multa y requerimientos asociados
- `getPrescripcion`: Consulta prescripción por id_prescri
- `getMultasHistorico`: Consulta histórico de una multa

## 4. Frontend Vue.js
- Página independiente, sin tabs
- Permite búsqueda, listado, edición y cancelación de multas
- Visualización de requerimientos asociados
- Formularios reactivos y validación básica
- Navegación entre vistas (breadcrumb opcional)
- Manejo de estados (loading, error)

## 5. Stored Procedures PostgreSQL
- Toda la lógica de negocio y reportes se implementa en funciones y procedimientos almacenados
- Se usan funciones con `RETURNS TABLE` para consultas y `RETURNS VOID` para acciones
- Ejemplo: `sp_get_multas_by_id`, `sp_search_multas`, `sp_update_multa`, etc.

## 6. Seguridad
- Validación de parámetros en backend
- Manejo de errores y transacciones
- Los cambios de estado (cancelación, edición) requieren usuario autenticado

## 7. Pruebas y Casos de Uso
- Incluye casos de uso y escenarios de prueba para búsqueda, edición y cancelación

## 8. Consideraciones
- El frontend debe consumir el endpoint `/api/execute` para todas las operaciones
- El backend debe mapear cada acción a la función/procedimiento correspondiente
- El frontend debe mostrar mensajes claros de error y éxito

## 9. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los stored procedures pueden evolucionar sin afectar el frontend

---

## Casos de Uso

> ⚠️ Pendiente de documentar

## Casos de Prueba

> ⚠️ Pendiente de documentar

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

