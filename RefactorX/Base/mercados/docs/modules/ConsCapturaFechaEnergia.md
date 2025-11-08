# Documentación Técnica: ConsCapturaFechaEnergia

## Descripción General
Este módulo permite consultar y eliminar pagos capturados de energía eléctrica por fecha, oficina, caja y operación. Incluye:
- Consulta de pagos por filtros
- Eliminación de pagos seleccionados (con regeneración de adeudos si corresponde)
- Listado de oficinas y cajas

## Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Componente Vue.js como página independiente
- **Base de Datos:** PostgreSQL con stored procedures

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Body:**
  ```json
  {
    "action": "getPagosByFecha", // o 'deletePagosEnergia', 'getOficinas', 'getCajasByOficina'
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": ""
  }
  ```

## Stored Procedures
- `sp_get_pagos_energia_fecha`: Devuelve pagos por fecha/oficina/caja/operación
- `sp_delete_pagos_energia`: Borra pagos seleccionados y regenera adeudos si corresponde

## Seguridad
- El endpoint requiere autenticación (token JWT o sesión Laravel)
- El userId se obtiene del usuario autenticado

## Validaciones
- Todos los parámetros son validados en backend
- El frontend valida que los filtros estén completos antes de buscar
- Solo usuarios autorizados pueden borrar pagos

## Flujo de Eliminación
1. El usuario selecciona uno o varios pagos
2. Se envía la lista de IDs al backend
3. Por cada pago:
   - Si no existe adeudo para ese periodo, se regenera
   - Se elimina el pago
4. Se devuelve el resultado

## Navegación
- Cada formulario es una página independiente
- Breadcrumb incluido
- No se usan tabs

## Estructura de Carpetas
- `app/Http/Controllers/ConsCapturaFechaEnergiaController.php`
- `resources/js/pages/ConsCapturaFechaEnergia.vue`
- `database/migrations/` y `database/procedures/` para los SP

## Ejemplo de Request
```json
{
  "action": "getPagosByFecha",
  "params": {
    "fecha_pago": "2024-06-01",
    "oficina_pago": 1,
    "caja_pago": "A",
    "operacion_pago": 12345
  }
}
```

## Ejemplo de Respuesta
```json
{
  "success": true,
  "data": [ ... ],
  "message": ""
}
```

# Notas de Migración
- Todas las operaciones SQL se migran a stored procedures PostgreSQL
- El frontend nunca accede directo a la base de datos
- El endpoint `/api/execute` es el único punto de entrada
- El componente Vue es una página completa, sin tabs
