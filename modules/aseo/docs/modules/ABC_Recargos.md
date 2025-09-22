# Documentación Técnica: Catálogo de Recargos (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL 13+, lógica de negocio en stored procedures.
- **Seguridad**: Validación de parámetros en backend, manejo de errores y mensajes amigables.

## API Unificada `/api/execute`
- **Método**: POST
- **Body**: `{ action: string, params: object }`
- **Ejemplo**:
  ```json
  {
    "action": "recargos.create",
    "params": {
      "aso_mes_recargo": "2024-06-01",
      "porc_recargo": 2.5,
      "porc_multa": 1.5
    }
  }
  ```
- **Respuesta**: `{ success: bool, message: string, data: any }`

## Stored Procedures
- Toda la lógica de negocio y validación reside en SPs PostgreSQL.
- Los SPs devuelven siempre un resultado estructurado (success, message, data).
- El controlador Laravel solo enruta y valida parámetros básicos.

## Vue.js
- Cada formulario es una página completa (no tabs, no subcomponentes).
- Navegación por rutas, breadcrumbs opcional.
- Tabla principal con selección de fila.
- Modal para alta, baja y cambios.
- Validación básica en frontend, validación estricta en backend.

## Flujo de Operación
1. El usuario accede a la página de Recargos.
2. Se listan todos los recargos (consulta vía `/api/execute` con `recargos.list`).
3. El usuario puede seleccionar un registro y realizar alta, baja o cambios.
4. Cada operación abre un modal con el formulario correspondiente.
5. Al guardar, se envía la petición a `/api/execute` con la acción y parámetros.
6. El backend ejecuta el SP correspondiente y responde con éxito o error.
7. El frontend muestra el mensaje y refresca la tabla si corresponde.

## Validaciones
- No se permite crear dos recargos para el mismo periodo.
- No se puede modificar/eliminar un recargo inexistente.
- Los campos son obligatorios y numéricos donde corresponda.

## Seguridad
- Todas las operaciones pasan por validación de usuario (middleware Laravel, no mostrado aquí).
- Los SPs previenen duplicados y operaciones inválidas.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los SPs pueden ser versionados y auditados.

## Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

