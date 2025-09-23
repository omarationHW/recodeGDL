# Documentación Técnica: Altas de Convenios Diversos

## Descripción General
Este módulo permite consultar y exportar el reporte de altas de convenios diversos (AltasConvDiv) por recaudadora y rango de fechas. Incluye:
- Endpoint API unificado `/api/execute` (eRequest/eResponse)
- Stored procedure PostgreSQL para el reporte
- Página Vue.js independiente para consulta y exportación
- Controlador Laravel centralizado

## Arquitectura
- **Backend**: Laravel + PostgreSQL
- **Frontend**: Vue.js (SPA, página independiente)
- **API**: Un único endpoint `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Stored Procedures**: Toda la lógica SQL de reportes se implementa en procedimientos almacenados PostgreSQL.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "operation": "getAltasConvDivReport",
      "params": {
        "rec": "ZC1",
        "fecha1": "2024-01-01",
        "fecha2": "2024-06-30"
      }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## Stored Procedure
- **Nombre**: `sp_rpt_altas_conv_div`
- **Parámetros**:
  - `p_rec` (VARCHAR): Código de recaudadora (ej. 'ZC1')
  - `p_fecha1` (DATE): Fecha inicial
  - `p_fecha2` (DATE): Fecha final
- **Retorna**: Tabla con todos los campos requeridos para el reporte, incluyendo campos calculados (expediente, domicilio, estado, nomtipo, nomsubtipo).

## Laravel Controller
- **Clase**: `AltasConvDivController`
- **Método principal**: `execute(Request $request)`
- **Operaciones soportadas**:
  - `getAltasConvDivReport`: Consulta el reporte llamando al SP
  - `exportAltasConvDivExcel`: Exporta el reporte a Excel (dummy, requiere implementación real)
- **Patrón**: eRequest/eResponse

## Vue.js Component
- **Nombre**: `AltasConvDivPage`
- **Rutas**: Página independiente, no usa tabs
- **Funcionalidad**:
  - Formulario para seleccionar recaudadora y rango de fechas
  - Consulta y muestra el reporte en tabla
  - Exporta a Excel
  - Manejo de errores y estados de carga

## Seguridad
- Validación de parámetros en backend
- El endpoint debe estar protegido por autenticación (middleware Laravel)

## Consideraciones de Migración
- Los campos calculados en Delphi (expediente, domicilio, estado, nomtipo, nomsubtipo) se calculan en el SP de PostgreSQL
- El reporte es solo de consulta, no hay edición ni inserción desde la UI
- El export a Excel debe implementarse usando un paquete Laravel (ej. Laravel Excel)

## Estructura de Carpetas
- `app/Http/Controllers/Api/AltasConvDivController.php`
- `resources/js/pages/AltasConvDivPage.vue`
- `database/migrations/` y `database/functions/sp_rpt_altas_conv_div.sql`

## Ejemplo de Uso
1. El usuario accede a la página de Altas de Convenios Diversos
2. Selecciona recaudadora y fechas
3. Presiona "Buscar" y ve el reporte
4. Puede exportar a Excel

---
