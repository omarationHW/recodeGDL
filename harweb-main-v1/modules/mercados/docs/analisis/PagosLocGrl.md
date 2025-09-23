# Documentación Técnica: PagosLocGrl (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo permite consultar y exportar los pagos realizados por locales de un mercado específico en un rango de fechas, filtrando por oficina recaudadora y mercado. Incluye integración con stored procedures en PostgreSQL, un endpoint API unificado y una interfaz Vue.js.

## Arquitectura
- **Backend**: Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Frontend**: Componente Vue.js de página completa (sin tabs)
- **Base de Datos**: PostgreSQL con stored procedures para lógica de negocio y reportes

## Flujo de Datos
1. El usuario accede a la página de "Pagos por Mercado".
2. El frontend solicita la lista de recaudadoras (`getRecaudadoras`).
3. Al seleccionar una recaudadora, se cargan los mercados asociados (`getMercadosByRecaudadora`).
4. El usuario selecciona mercado y rango de fechas, y ejecuta la búsqueda (`getPagosLocGrl`).
5. Los resultados se muestran en una tabla. Puede exportar a Excel.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "nombreAccion",
    "params": { ... }
  }
  ```
- **Acciones soportadas**:
  - `getRecaudadoras`: Lista recaudadoras
  - `getMercadosByRecaudadora`: Mercados por recaudadora
  - `getPagosLocGrl`: Reporte de pagos
  - `exportPagosLocGrlExcel`: Exportación (simulada)

## Stored Procedures
- **get_recaudadoras**: Devuelve recaudadoras
- **get_mercados_by_recaudadora**: Devuelve mercados de una recaudadora
- **get_pagos_loc_grl**: Devuelve pagos filtrados por recaudadora, mercado y fechas

## Validaciones
- Todos los parámetros requeridos son validados en el frontend y backend.
- El backend retorna mensajes de error claros en caso de parámetros faltantes o errores de ejecución.

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (ej: JWT, session, etc).
- Los stored procedures no permiten SQL injection (uso de parámetros).

## Exportación a Excel
- El endpoint `exportPagosLocGrlExcel` simula la exportación y retorna una URL de descarga.
- En producción, se recomienda usar un job que genere el archivo y lo almacene en storage público.

## Estructura de Carpetas
- `app/Http/Controllers/PagosLocGrlController.php`
- `resources/js/pages/PagosLocGrlPage.vue`
- `database/migrations/` y `database/functions/` para los SP

## Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el mismo patrón.
- Los stored procedures pueden ser extendidos para incluir más filtros o columnas.

## Pruebas
- Incluye casos de uso y escenarios de prueba para asegurar la funcionalidad.

#