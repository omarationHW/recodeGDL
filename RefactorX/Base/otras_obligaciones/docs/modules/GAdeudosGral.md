# Documentación Técnica: Migración de GAdeudosGral (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful unificada con endpoint `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse, todas las operaciones pasan por un único endpoint.

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "GAdeudosGral.sp34_adeudototal",
      "params": {
        "par_tabla": 3,
        "par_fecha": "2024-06"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica de consulta y reporte se implementa en funciones/stored procedures PostgreSQL.
- Los SPs reciben parámetros y devuelven tablas (RETURNS TABLE).
- Ejemplo: `sp34_adeudototal(par_tabla, par_fecha)` devuelve el resumen de adeudos por tabla y periodo.

## 4. Controlador Laravel
- Un solo controlador (`ExecuteController`) maneja todas las operaciones.
- El método `execute` despacha según el campo `operation`.
- Cada operación llama al SP correspondiente usando DB::select('CALL ...').
- Manejo de errores y logging incluido.

## 5. Componente Vue.js
- Página independiente, sin tabs.
- Permite seleccionar tipo de reporte, opción, periodo (actual u otro), año y mes.
- Botones para consultar, vista de adeudo y exportar a Excel.
- Resultados en tabla responsive.
- Lógica de navegación y breadcrumbs incluida.
- Llama a `/api/execute` con la operación y parámetros adecuados.

## 6. Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validar y sanitizar todos los parámetros recibidos.

## 7. Exportación a Excel
- El endpoint `GAdeudosGral.exportExcel` debe ser implementado en backend para generar y servir el archivo.
- En este ejemplo, se simula devolviendo una URL dummy.

## 8. Consideraciones de Migración
- Los combos y selects Delphi se migran a `<select>` en Vue.
- Los reportes Delphi (QuickReport) se migran a tablas HTML y exportación a Excel.
- Los SPs deben ser adaptados a la estructura real de la base de datos destino.
- Los nombres de tablas y campos pueden requerir ajuste según el modelo real.

## 9. Extensibilidad
- Para agregar nuevas operaciones, basta con agregar un nuevo case en el controlador y el SP correspondiente.
- El frontend puede extenderse fácilmente para nuevos filtros o columnas.

## 10. Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

