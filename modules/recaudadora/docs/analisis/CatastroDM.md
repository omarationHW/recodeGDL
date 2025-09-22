# Documentación Técnica - Migración CatastroDM Delphi a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.
- **Patrón API:** eRequest/eResponse, entrada y salida JSON.

## Flujo de Trabajo
1. **El usuario accede a la página de descuentos predial.**
2. **Busca una cuenta por clave catastral.**
3. **El sistema consulta la cuenta y muestra los adeudos y descuentos vigentes.**
4. **El usuario puede agregar un nuevo descuento, que se inserta vía stored procedure.**
5. **El usuario puede cancelar un descuento vigente.**

## Endpoints y Acciones
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'nombre_accion', params: { ... } } }`
  - Salida: `{ eResponse: { success, data, message } }`

### Acciones soportadas
- `getCuentaByClave`: Busca cuenta por clave catastral
- `getAdeudosByCuenta`: Lista adeudos de la cuenta
- `insertDescuentoPredial`: Inserta descuento
- `getDescuentosPredial`: Lista descuentos
- `cancelarDescuentoPredial`: Cancela descuento
- `getUsuarios`: Lista usuarios activos
- `getCatalogoDescuentos`: Catálogo de tipos de descuento

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de parámetros en backend y frontend.
- Control de permisos para acciones de alta/cancelación.

## Integración Vue.js
- Cada formulario es una página Vue independiente.
- Navegación por rutas, sin tabs.
- Uso de fetch/AJAX para consumir `/api/execute`.
- Manejo de errores y mensajes de usuario.

## Migración de Stored Procedures
- Toda la lógica SQL de Delphi se encapsula en funciones y procedimientos PostgreSQL.
- Los procedimientos se llaman desde Laravel vía DB::select o DB::statement.

## Consideraciones
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones.
- El frontend debe manejar la estructura eRequest/eResponse.
- Los formularios deben ser independientes y no usar tabs.

# Ejemplo de Llamada API
```json
POST /api/execute
{
  "eRequest": {
    "action": "getCuentaByClave",
    "params": { "clave": "D65J1234567" }
  }
}
```

# Ejemplo de Respuesta
```json
{
  "eResponse": {
    "success": true,
    "data": { "cvecuenta": 12345, ... },
    "message": ""
  }
}
```

# Notas
- Todos los formularios Delphi deben migrarse como páginas Vue independientes.
- Los stored procedures deben cubrir toda la lógica de negocio y validación de datos.
- El endpoint `/api/execute` debe ser el único punto de acceso para el frontend.
