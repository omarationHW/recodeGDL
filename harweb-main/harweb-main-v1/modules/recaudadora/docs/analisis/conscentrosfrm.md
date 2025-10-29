# Documentación Técnica: Migración conscentrosfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde al formulario `conscentrosfrm` de Delphi, que muestra el listado de multas cobradas en centros de recaudación, asociadas al importe del pago. La migración se realiza a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend:** Vue.js 3 (Composition API opcional), componente de página independiente
- **Base de datos:** PostgreSQL 14+, lógica SQL en stored procedures

## API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "get_centros_list|get_centros_by_fecha|get_centros_by_dependencia|get_centros_by_acta",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ]
  }
  ```

## Stored Procedures
Toda la lógica de consulta reside en funciones PostgreSQL (tipo `RETURNS TABLE`).
- `sp_get_centros_list()`
- `sp_get_centros_by_fecha(p_fecha DATE)`
- `sp_get_centros_by_dependencia(p_id_dependencia INTEGER)`
- `sp_get_centros_by_acta(p_axo_acta INTEGER, p_num_acta INTEGER)`

La vista `centros_recaudacion_view` debe existir y contener los campos:
- fecha, abrevia, axo_acta, num_acta, num_recibo, importe_pago, contribuyente, domicilio, id_dependencia

## Laravel Controller
- Controlador: `ConsCentrosController`
- Método principal: `execute(Request $request)`
- Métodos auxiliares para cada acción
- Validación de parámetros
- Uso de DB::select para ejecutar las consultas

## Vue.js Component
- Página independiente (no tabs)
- Filtros: fecha, dependencia, año acta, número acta
- Tabla responsive con los campos requeridos
- Navegación y limpieza de filtros
- Consumo del endpoint `/api/execute`

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o Laravel Sanctum
- Validar y sanear todos los parámetros recibidos

## Consideraciones de Migración
- El formulario Delphi sólo mostraba datos, no permitía edición ni acciones sobre los registros
- El grid se reemplaza por una tabla HTML con paginación opcional
- Los stored procedures pueden ser extendidos para paginación si se requiere

## Pruebas y QA
- Se deben realizar pruebas funcionales de todos los filtros
- Validar que los datos coincidan con el sistema original
- Probar casos de error y validación

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- El frontend puede ser extendido para exportar a Excel o PDF
