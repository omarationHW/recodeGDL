# Documentación Técnica: Migración Formulario ipor (Delphi) a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde a la migración del formulario de impresión y asignación de requerimientos (ipor) del sistema Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de negocio y SQL se encapsula en stored procedures y funciones PostgreSQL. La comunicación entre frontend y backend se realiza mediante un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.

## Arquitectura
- **Backend:** Laravel Controller único (`IporController`) que recibe peticiones eRequest y responde con eResponse.
- **Frontend:** Componente Vue.js independiente, sin tabs, cada formulario es una página completa.
- **Base de Datos:** PostgreSQL, toda la lógica SQL y reglas de negocio se implementan en stored procedures y funciones.
- **API:** Endpoint único `/api/execute` para todas las operaciones, recibe `{ eRequest: { action, params } }` y responde `{ eResponse: { result, error } }`.

## Endpoints y Acciones
- `list_controls`: Lista todos los controles de emisión de requerimientos.
- `filter_controls`: Filtra controles según recaudadora, fecha, etc.
- `get_requerimientos`: Obtiene requerimientos de predial según parámetros.
- `assign_requerimientos`: Asigna requerimientos a ejecutores.
- `print_requerimientos`: Genera datos para impresión de requerimientos.
- `get_ejecutores`: Lista ejecutores disponibles para una recaudadora y fecha.
- `get_multas_grid`, `get_licencias_grid`, `get_anuncios_grid`, `get_diferencias_grid`: Obtienen grids agrupados para asignación masiva.

## Stored Procedures y Funciones
Toda la lógica de negocio (asignación, impresión, agrupación, validación) se implementa en funciones y procedimientos almacenados en PostgreSQL bajo el esquema `requerimientos`.

## Flujo de Trabajo
1. El usuario filtra controles de emisión (por recaudadora, fecha, etc.).
2. Selecciona un control y solicita la lista de requerimientos asociados.
3. Puede asignar requerimientos a ejecutores (masivo o individual).
4. Puede imprimir los requerimientos (notificación o requerimiento formal).
5. El frontend consume el endpoint `/api/execute` para todas las acciones.

## Seguridad y Validaciones
- Todas las acciones requieren autenticación (middleware Laravel).
- Validaciones de parámetros en el controlador y en los stored procedures.
- Control de errores centralizado en el controlador.

## Consideraciones de Migración
- Los grids y agrupaciones de Delphi se migran a funciones SQL con GROUP BY.
- Los procedimientos de asignación y actualización de folios se migran a funciones/procedimientos con control de transacciones.
- Los reportes se generan en el frontend a partir de los datos devueltos por el backend.

## Estructura de Carpetas
- `app/Http/Controllers/IporController.php` (Laravel)
- `resources/js/pages/IporFormulario.vue` (Vue.js)
- `database/migrations/` y `database/functions/` (PostgreSQL)

## Integración
- El frontend Vue.js se comunica exclusivamente con `/api/execute`.
- El backend Laravel ejecuta los stored procedures y retorna los resultados en formato JSON.

## Ejemplo de Petición
```json
{
  "eRequest": {
    "action": "assign_requerimientos",
    "params": {
      "tipo": "predial",
      "ejecutor_id": 123,
      "fecha": "2024-06-10",
      "recaud": 1,
      "folioini": 1000,
      "foliofin": 1100
    }
  }
}
```

## Ejemplo de Respuesta
```json
{
  "eResponse": {
    "result": [{ "asignados": 100, "mensaje": "Asignados a ejecutor 123" }],
    "error": null
  }
}
```

## Notas
- Cada formulario (predial, multas, licencias, anuncios, diferencias) debe tener su propia página Vue.js.
- El endpoint `/api/execute` es el único punto de entrada para todas las operaciones relacionadas con requerimientos.
- Los reportes se generan en el frontend a partir de los datos JSON devueltos.
