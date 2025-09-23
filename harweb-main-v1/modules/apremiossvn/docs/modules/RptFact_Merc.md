# Documentación Técnica: Migración de Formulario RptFact_Merc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de facturación de requerimientos de mercados (RptFact_Merc) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo la consulta de reportes por zona y rango de folios, y presentar los resultados en una página web independiente.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+)
- **Frontend:** Vue.js 2/3 (SPA o multipágina)
- **Base de Datos:** PostgreSQL 12+
- **API:** Unificada bajo el endpoint `/api/execute` usando el patrón eRequest/eResponse
- **Stored Procedures:** Toda la lógica SQL relevante se encapsula en funciones/procedimientos almacenados en PostgreSQL

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "RptFact_Merc.getReport",
      "params": {
        "rec": <int>,
        "fol1": <int>,
        "fol2": <int>
      }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `rptfact_merc_get_report`
- **Parámetros:**
  - `p_rec` (integer): Zona
  - `p_fol1` (integer): Folio inicial
  - `p_fol2` (integer): Folio final
- **Retorno:** Tabla con todos los campos requeridos para el reporte
- **Descripción:** Realiza el JOIN entre `ta_11_locales` y `ta_15_apremios` filtrando por zona y rango de folios.

## 5. Controlador Laravel
- **Ubicación:** `App\Http\Controllers\Api\ExecuteController`
- **Método:** `execute(Request $request)`
- **Funcionalidad:**
  - Recibe el eRequest
  - Ejecuta el stored procedure correspondiente según la acción
  - Devuelve eResponse con los datos o mensaje de error

## 6. Componente Vue.js
- **Nombre:** `RptFactMercPage`
- **Funcionalidad:**
  - Formulario para ingresar zona y rango de folios
  - Consulta la API y muestra los resultados en tabla
  - Manejo de estados: cargando, error, sin resultados
  - Página independiente con breadcrumb

## 7. Seguridad
- Validar que los parámetros sean numéricos y estén presentes
- El endpoint puede protegerse con middleware de autenticación según la política del sistema

## 8. Consideraciones de Migración
- Los nombres de campos y tablas deben coincidir con la estructura de la base de datos PostgreSQL
- El reporte es solo de consulta (READ-ONLY)
- El frontend no permite edición ni eliminación

## 9. Extensibilidad
- El endpoint `/api/execute` puede ampliarse para soportar más acciones y formularios
- El patrón eRequest/eResponse facilita la integración con otros sistemas y formularios

## 10. Dependencias
- Laravel: DB, Routing, Controllers
- Vue.js: fetch API, router-link
- PostgreSQL: Funciones almacenadas, roles de solo lectura
