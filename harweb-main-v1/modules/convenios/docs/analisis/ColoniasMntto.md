# Documentación Técnica: Migración Formulario ColoniasMntto (Delphi → Laravel + Vue.js + PostgreSQL)

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente (NO tabs)
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures
- **Seguridad:** Autenticación Laravel Sanctum/JWT, validación de datos en backend y frontend

## Flujo de Datos
1. **Frontend** envía petición a `/api/execute` con `{ action: 'colonias.create', payload: { ... } }` (o update/list/delete)
2. **Laravel Controller** recibe, valida, y despacha a stored procedure correspondiente
3. **Stored Procedure** ejecuta la lógica (insert/update/delete/select)
4. **Controller** retorna eResponse `{ success, message, data }`
5. **Vue Component** actualiza UI según respuesta

## Endpoints y Acciones
- `colonias.list` → Lista todas las colonias
- `colonias.create` → Crea una colonia
- `colonias.update` → Actualiza una colonia
- `colonias.delete` → Elimina una colonia
- `colonias.get` → Obtiene una colonia específica
- `colonias.catalogs` → Catálogos de recaudadoras y zonas

## Validaciones
- Todos los campos obligatorios deben estar presentes
- `colonia` es clave primaria, numérica, 1-999
- `descripcion` máximo 50 caracteres
- `id_rec` y `id_zona` deben existir en sus catálogos
- `col_obra94` es opcional

## Seguridad
- Solo usuarios autenticados pueden crear/editar/eliminar
- El id_usuario se toma del usuario autenticado

## Manejo de Errores
- Todos los errores de validación y de base de datos se retornan en el campo `message` del eResponse
- El frontend muestra alertas según el resultado

## Stored Procedures
- Toda la lógica de inserción, actualización y borrado está en SPs PostgreSQL
- Los SPs retornan `{ success, message }` para manejo uniforme

## Vue.js
- Página independiente, sin tabs
- Formulario de alta/modificación y tabla de listado
- Acciones de editar/eliminar inline
- Breadcrumb para navegación
- Validación básica en frontend y mensajes de error

## API Unificada
- Todas las acciones usan `/api/execute` con `{ action, payload }`
- El backend despacha según el valor de `action`

## Ejemplo de eRequest/eResponse
```json
{
  "action": "colonias.create",
  "payload": {
    "colonia": 123,
    "descripcion": "COLONIA NUEVA",
    "id_rec": 1,
    "id_zona": 2,
    "col_obra94": 0
  }
}
```
Respuesta:
```json
{
  "success": true,
  "message": "Colonia insertada correctamente",
  "data": null
}
```

## Notas de Migración
- El formulario Delphi usaba componentes visuales y lógica procedural; ahora todo es desacoplado y reactivo
- El control de transacciones y errores se maneja en los SPs y el Controller
- El frontend es completamente independiente y puede ser embebido en cualquier SPA

# Despliegue y Pruebas
- Los SPs deben crearse en la base de datos PostgreSQL destino
- El endpoint `/api/execute` debe estar protegido por autenticación
- El componente Vue debe ser registrado en el router principal como página

# Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente
- Los catálogos de recaudadoras y zonas pueden ser cacheados en frontend
