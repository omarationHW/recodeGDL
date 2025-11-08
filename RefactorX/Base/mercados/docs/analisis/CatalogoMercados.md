# Documentación Técnica: Catálogo de Mercados (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Seguridad:** Autenticación Laravel Sanctum/JWT, validación de datos en backend y frontend

## API Unificada `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "list|create|update|delete|report",
    "module": "catalogo_mercados",
    "payload": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## Controlador Laravel
- Un solo método `execute(Request $request)`
- Despacha la acción según el campo `action` y ejecuta el stored procedure correspondiente
- Valida los datos antes de llamar al SP
- Devuelve siempre JSON

## Componente Vue.js
- Página independiente `/catalogo-mercados`
- Tabla con todos los mercados
- Botón para agregar, editar, eliminar, y ver reporte
- Formulario modal para alta/modificación
- Mensajes de error y éxito
- Llama a `/api/execute` con el action adecuado

## Stored Procedures PostgreSQL
- Toda la lógica de CRUD y reportes está en SPs
- Los SPs devuelven siempre un TABLE o un mensaje de resultado
- Validaciones de integridad y errores se manejan en el SP y en el controlador

## Seguridad y Validación
- El backend valida todos los campos requeridos
- El frontend también valida antes de enviar
- El endpoint requiere autenticación

## Navegación
- Breadcrumbs para contexto
- Cada formulario es una página, no hay tabs

## Reportes
- El reporte se obtiene vía SP y se muestra en una tabla modal
- Puede exportarse a Excel/CSV desde el frontend si se requiere

## Errores y Mensajes
- Todos los errores se devuelven en el campo `message` del JSON
- El frontend muestra los mensajes en alertas

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más módulos y acciones fácilmente
- Los SPs pueden ser versionados y auditados

## Pruebas
- Casos de uso y pruebas detalladas incluidas abajo
