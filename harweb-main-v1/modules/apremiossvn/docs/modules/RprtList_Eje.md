# Documentación Técnica: Migración RprtList_Eje (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `RprtList_Eje` a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (DB). El objetivo es mantener la lógica de negocio y presentación, pero adaptada a tecnologías web y patrones actuales.

## 2. Arquitectura
- **Backend:** Laravel 10+ (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js 3+ (SPA, página independiente para el reporte)
- **Base de Datos:** PostgreSQL (Stored Procedures para lógica de reportes)

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "getRprtListEje",
    "params": {
      "varios": "1,2,3",
      "vvig": "1",
      "vrec": "",
      "vopc": 1,
      "vfec1": "2024-01-01",
      "vfec2": "2024-01-31",
      "vrecaudadora": 0,
      "vfecP1": null,
      "vfecP2": null,
      "vnombre": "",
      "v90d": "S"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## 4. Stored Procedure (PostgreSQL)
Toda la lógica de filtrado y cálculo del reporte se implementa en el SP `rprtlist_eje_report`, que acepta los mismos parámetros que el formulario original y retorna un conjunto de registros con los campos requeridos.

## 5. Frontend (Vue.js)
- Página independiente `/rprtlist-eje`.
- Formulario de filtros (ejecutores, vigencia, fechas, recaudadora, etc).
- Tabla de resultados con paginación simple (si se requiere).
- Breadcrumb de navegación.
- Llamada a `/api/execute` con los parámetros del formulario.

## 6. Backend (Laravel)
- Controlador `ExecuteController` con método `execute` que despacha según el campo `action`.
- Método privado `getRprtListEje` que llama al SP y retorna los datos.
- Manejo de errores y validaciones básicas.

## 7. Seguridad
- Se recomienda proteger el endpoint con autenticación (token JWT o session) en producción.
- Validar y sanear los parámetros recibidos.

## 8. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevas acciones y reportes fácilmente.
- El frontend puede crecer agregando nuevas páginas independientes para otros formularios.

## 9. Notas de Migración
- Los campos calculados ("datos", "aplicacion") pueden requerir lógica adicional en el SP o en el frontend si se desea igualar el comportamiento Delphi exacto.
- El SP puede ser extendido para incluir JOINs adicionales según los módulos (Mercado, Aseo, etc) si se requiere el mismo detalle.

## 10. Dependencias
- Laravel 10+
- Vue.js 3+
- PostgreSQL 13+

## 11. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.
