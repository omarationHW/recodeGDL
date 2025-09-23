# ExportarExcel - Documentación Técnica

## Descripción General
El módulo ExportarExcel permite consultar y exportar a Excel la estadística de folios pagos por recaudadora, módulo, rango de folios y fechas de emisión/pago. La migración Delphi → Laravel + Vue.js + PostgreSQL implementa:

- Un endpoint API único `/api/execute` (patrón eRequest/eResponse)
- Un controlador Laravel que enruta acciones (`getRecaudadoras`, `getFoliosPagos`, `exportExcel`)
- Un componente Vue.js de página completa, con formulario de filtros y tabla de resultados
- Un stored procedure PostgreSQL para la consulta principal
- Exportación a Excel en frontend (SheetJS)

## Arquitectura
- **Backend**: Laravel 10+, PostgreSQL 13+
- **Frontend**: Vue.js 3, Axios, SheetJS, Bootstrap (opcional)
- **API**: `/api/execute` (POST)
- **Patrón**: eRequest (action, params) / eResponse (status, data, message)

## Flujo de Datos
1. El usuario accede a la página ExportarExcel
2. El frontend carga la lista de recaudadoras (`getRecaudadoras`)
3. El usuario selecciona filtros y consulta (`getFoliosPagos`)
4. El backend ejecuta el stored procedure y retorna los datos
5. El usuario puede exportar los resultados a Excel (frontend)

## Endpoints
- **POST /api/execute**
  - **action**: `getRecaudadoras` | `getFoliosPagos` | `exportExcel`
  - **params**: parámetros según acción

## Stored Procedure
- **spd_15_foliospag**: Consulta los folios pagos según filtros

## Seguridad
- Validación de parámetros en backend
- Solo usuarios autenticados pueden acceder (middleware Laravel)

## Exportación a Excel
- Se realiza en frontend usando SheetJS, permitiendo descarga directa del archivo

## Consideraciones
- El backend no genera archivos Excel, solo datos JSON
- El frontend es una página independiente, no usa tabs ni componentes compartidos
- El endpoint es unificado para facilitar integración y pruebas

## Estructura de Carpetas
- `app/Http/Controllers/ExportarExcelController.php`
- `resources/js/pages/ExportarExcelPage.vue`
- `database/migrations/` y `database/procedures/` para SP

## Ejemplo de eRequest/eResponse
```json
{
  "action": "getFoliosPagos",
  "params": {
    "prec": 1,
    "pmod": 11,
    "pfold": 100,
    "pfolh": 200,
    "pfemi": "2024-06-01",
    "pfpagd": "2024-06-01",
    "pfpagh": "2024-06-30"
  }
}
```

## Ejemplo de respuesta
```json
{
  "status": "success",
  "data": [ ... ],
  "message": "Folios pagos consultados"
}
```
