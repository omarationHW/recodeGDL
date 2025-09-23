# Documentación Técnica - Migración ModuloBD (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General

- **Backend:** Laravel 10+ (PHP 8.1+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs), navegación por rutas.
- **Base de Datos:** PostgreSQL 14+, toda la lógica SQL encapsulada en stored procedures (SPs).
- **Autenticación:** Laravel Sanctum/JWT (no incluido aquí, pero recomendado para producción).

## Flujo de Comunicación

1. **Frontend** envía peticiones POST a `/api/execute` con un JSON:
   ```json
   {
     "action": "getCategorias",
     "params": {}
   }
   ```
2. **Backend** (Laravel Controller) recibe la petición, despacha según `action`, llama el SP correspondiente y retorna la respuesta en formato eResponse:
   ```json
   {
     "success": true,
     "data": [...],
     "message": ""
   }
   ```
3. **Frontend** renderiza la respuesta y actualiza la UI.

## Estructura del Endpoint `/api/execute`
- **Método:** POST
- **Body:** `{ action: string, params: object }`
- **Respuesta:** `{ success: bool, data: any, message: string }`

## Ejemplo de Uso
- Obtener categorías:
  - Request: `{ "action": "getCategorias" }`
  - Response: `{ "success": true, "data": [{"categoria":1,"descripcion":"A"},...], "message": "" }`
- Agregar categoría:
  - Request: `{ "action": "addCategoria", "params": { "descripcion": "Nueva" } }`
  - Response: `{ "success": true, "data": [{"categoria":5,"descripcion":"NUEVA"}], "message": "" }`

## Seguridad
- Todas las acciones deben validar permisos del usuario autenticado (no incluido en este ejemplo).
- Validar y sanitizar todos los parámetros antes de ejecutar SPs.

## Convenciones
- Todos los SPs devuelven un TABLE para facilitar el consumo por Laravel.
- Los nombres de los SPs siguen el patrón `sp_[accion]_[entidad]`.
- El frontend debe manejar errores y mostrar mensajes amigables.

## Extensibilidad
- Para agregar nuevos formularios, crear el SP correspondiente y agregar el case en el controlador.
- El frontend puede reutilizar el patrón de página para otros catálogos CRUD.

## Despliegue
- Laravel: Usar migraciones para crear tablas y SPs.
- Vue: Compilar y desplegar en el mismo dominio o como SPA independiente.
- PostgreSQL: Ejecutar los scripts de SPs en la base de datos destino.

## Notas
- El ejemplo de Vue es para "Catálogo de Categorías". Para otros catálogos, replicar el patrón cambiando los campos y acciones.
- El endpoint es unificado para facilitar integración y auditoría.
