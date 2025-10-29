# Documentación Técnica: Migración Formulario RptReq_Aseo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la migración del formulario de Orden de Requerimiento de Pago y Embargo (Aseo Contratado) desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos). El acceso a la funcionalidad se realiza mediante un endpoint API unificado `/api/execute` usando el patrón `eRequest/eResponse`.

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8), API RESTful, acceso a datos vía stored procedures PostgreSQL.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica SQL encapsulada en stored procedures.

## 3. Endpoint Unificado
- **Ruta:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "eRequest": "RptReq_Aseo.getReport",
    "params": {
      "folio1": 1000,
      "folio2": 1100,
      "ofna": 5
    }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "eResponse": "RptReq_Aseo.getReport",
    "data": {
      "adeudos": [ ... ],
      "recaudadora": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- **rptreq_aseo_report:** Devuelve todos los adeudos de aseo contratado para un rango de folios y una oficina recaudadora.
- **rptreq_aseo_recaudadora:** Devuelve los datos de la recaudadora y su zona para la oficina indicada.

## 5. Controlador Laravel
- **Clase:** `App\Http\Controllers\Api\ExecuteController`
- **Método principal:** `execute(Request $request)`
- **Lógica:**
  - Recibe el `eRequest` y parámetros.
  - Ejecuta el stored procedure correspondiente.
  - Devuelve la respuesta en formato JSON.

## 6. Componente Vue.js
- **Nombre:** `RptReqAseoPage.vue`
- **Características:**
  - Página independiente (no usa tabs).
  - Formulario para ingresar folio inicial, folio final y oficina.
  - Consulta el API y muestra los resultados en tarjetas.
  - Incluye navegación breadcrumb.
  - Muestra datos de recaudadora y lista de adeudos.
  - Formatea fechas y montos.

## 7. Seguridad
- El endpoint puede requerir autenticación JWT o session según configuración del proyecto.
- Validación de parámetros en backend.

## 8. Consideraciones de Migración
- El reporte Delphi agrupaba por folio y año; en la migración se entrega la información lista para que el frontend la agrupe o muestre según necesidad.
- Los textos legales y estructura visual se adaptan a HTML/CSS.
- Los cálculos de totales se pueden realizar en el frontend o backend según preferencia.

## 9. Extensibilidad
- Se pueden agregar nuevos eRequest fácilmente en el controlador.
- Los stored procedures pueden ser optimizados o extendidos para nuevos requerimientos.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad.

---
