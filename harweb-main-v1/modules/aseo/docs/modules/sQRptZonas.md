# Documentación Técnica: Migración de Formulario sQRptZonas (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de reporte de zonas (`sQRptZonas`) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo consultar y visualizar el catálogo de zonas con diferentes criterios de clasificación.

## 2. Arquitectura
- **Backend**: Laravel expone un endpoint único `/api/execute` que recibe peticiones estructuradas (eRequest/eResponse) y ejecuta la lógica correspondiente, incluyendo la invocación de stored procedures en PostgreSQL.
- **Frontend**: Vue.js implementa una página independiente para el reporte de zonas, permitiendo seleccionar el criterio de clasificación y mostrando los resultados en una tabla.
- **Base de Datos**: Toda la lógica de consulta y ordenamiento se encapsula en un stored procedure (`rpt_ta_16_zonas_report`) en PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": "getZonasReport",
    "params": { "opcion": 1 }
  }
  ```
  - `opcion`: 1=Control, 2=Zona, 3=Sub-Zona, 4=Descripción
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": "Reporte de zonas obtenido correctamente."
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `rpt_ta_16_zonas_report`
- **Parámetro**: `opcion` (integer)
- **Retorna**: Tabla con columnas `ctrol_zona`, `zona`, `sub_zona`, `descripcion` ordenada según la opción.
- **Uso**:
  ```sql
  SELECT * FROM rpt_ta_16_zonas_report(1);
  ```

## 5. Frontend (Vue.js)
- Página independiente `/zonas-report`.
- Permite seleccionar el criterio de clasificación.
- Muestra los resultados en tabla.
- Incluye breadcrumb y fecha/hora de impresión.

## 6. Backend (Laravel)
- Controlador: `Api\ExecuteController`
- Método: `handle(Request $request)`
- Invoca el stored procedure vía DB::select.
- Devuelve respuesta estructurada eResponse.

## 7. Seguridad
- Validación básica de parámetros.
- Se recomienda proteger el endpoint con autenticación según las políticas del sistema.

## 8. Pruebas
- Casos de uso y pruebas detalladas en secciones siguientes.

## 9. Consideraciones
- El endpoint es extensible para otros formularios y operaciones.
- El stored procedure puede ser optimizado según índices y volumen de datos.
