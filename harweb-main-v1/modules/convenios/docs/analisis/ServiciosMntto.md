# Documentación Técnica: Migración de Formulario ServiciosMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al catálogo de Servicios de Obra Pública (ta_17_servicios). Permite alta, edición, consulta y eliminación de servicios, con integración a una API unificada y frontend Vue.js.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js independiente (página completa)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato:**
  ```json
  {
    "action": "servicios_create|servicios_update|servicios_delete|servicios_list|servicios_get",
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## 4. Stored Procedures
- Toda la lógica de inserción, actualización y borrado se realiza vía SPs en PostgreSQL:
  - `sp_servicios_insert(servicio, descripcion, serv_obra94)`
  - `sp_servicios_update(servicio, descripcion, serv_obra94)`
  - `sp_servicios_delete(servicio)`

## 5. Validaciones
- El backend valida que la descripción no sea nula y que el número de servicio sea único.
- El frontend previene envíos vacíos y muestra errores de validación.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (ejemplo: JWT o session).
- Los SPs deben validar tipos y restricciones de integridad.

## 7. Frontend (Vue.js)
- Página independiente, sin tabs.
- Tabla de servicios con acciones CRUD.
- Formulario modal para alta/edición.
- Mensajes de error y loading.

## 8. Navegación
- Breadcrumbs para contexto.
- Botón para agregar nuevo servicio.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- Los SPs pueden evolucionar para lógica adicional (auditoría, triggers, etc).

## 11. Migración de Datos
- Para migrar datos existentes, usar scripts de ETL o migraciones Laravel.

## 12. Errores y Manejo de Excepciones
- Todos los errores de SPs y validaciones se devuelven en el campo `message` de la respuesta.

---
