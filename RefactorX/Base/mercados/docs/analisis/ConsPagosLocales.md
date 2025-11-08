# Documentación Técnica: Consulta de Pagos del Local

## Descripción General
Este módulo permite consultar los pagos realizados por locales comerciales, ya sea filtrando por los datos del local (recaudadora, mercado, sección, etc.) o por fecha de pago y operación. La solución está compuesta por:

- **Backend Laravel**: Un controlador con endpoint único `/api/execute` que recibe acciones y parámetros en formato eRequest/eResponse.
- **Frontend Vue.js**: Un componente de página completa que permite la consulta y visualización de los pagos.
- **Stored Procedures PostgreSQL**: Toda la lógica de consulta reside en procedimientos almacenados para eficiencia y seguridad.

## Arquitectura
- **API Unificada**: Todas las operaciones se realizan mediante el endpoint `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend**: Cada formulario es una página independiente, sin tabs ni componentes tabulares.
- **Backend**: El controlador interpreta la acción y llama al stored procedure correspondiente.
- **Base de Datos**: Toda la lógica SQL reside en stored procedures PostgreSQL.

## Flujo de Datos
1. El usuario selecciona el tipo de consulta (por local o por fecha de pago) y llena los filtros.
2. Al presionar "Buscar", el frontend envía un POST a `/api/execute` con `{ action: ..., params: ... }`.
3. El backend ejecuta el stored procedure adecuado y retorna los resultados en formato JSON.
4. El frontend muestra los resultados en una tabla.

## Seguridad
- Todas las consultas usan parámetros para evitar SQL Injection.
- El endpoint puede ser protegido con middleware de autenticación si se requiere.

## Extensibilidad
- Se pueden agregar nuevas acciones y stored procedures sin modificar el endpoint ni el frontend, solo agregando lógica en el controlador y el procedimiento correspondiente.

## Estructura de Carpetas
- `app/Http/Controllers/ConsPagosLocalesController.php`
- `resources/js/pages/ConsPagosLocalesPage.vue`
- `database/migrations/` y `database/functions/` para los stored procedures

## Convenciones
- Todas las fechas se manejan en formato ISO (YYYY-MM-DD).
- Los nombres de los stored procedures siguen el patrón `buscar_*` o `get_*` según su función.

# Parámetros de Entrada
- **Por Local**: oficina, num_mercado, categoria, seccion, local, letra_local, bloque
- **Por Fecha**: fecha_pago, oficina_pago, caja_pago, operacion_pago

# Parámetros de Salida
- Listado de pagos con todos los campos relevantes (ver tabla en el frontend)

# Errores
- Si ocurre un error, el campo `success` es `false` y `message` contiene el detalle.

# Ejemplo de eRequest/eResponse
```json
{
  "action": "buscarPagosPorLocal",
  "params": {
    "oficina": 1,
    "num_mercado": 10,
    "categoria": 2,
    "seccion": "A",
    "local": 5,
    "letra_local": "B",
    "bloque": "C"
  }
}
```

# Ejemplo de Respuesta
```json
{
  "success": true,
  "data": [
    { "id_local": 123, "oficina": 1, ... }
  ],
  "message": ""
}
```
