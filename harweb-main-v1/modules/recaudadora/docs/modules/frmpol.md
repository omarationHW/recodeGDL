# Documentación Técnica: Migración de Formulario frmpol (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el formulario de reporte de póliza por recaudadora (frmpol) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y catálogo se implementa mediante stored procedures en PostgreSQL y se expone a través de un endpoint API unificado siguiendo el patrón eRequest/eResponse.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente `/frmpol`.
- **Backend**: Laravel Controller único (`ExecuteController`) con endpoint `/api/execute`.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## 3. API Unificada
- **Endpoint**: `POST /api/execute`
- **Request**:
  - `eRequest`: Nombre de la operación (ej: `getPolizaReporte`, `getRecaudadoras`)
  - `params`: Parámetros específicos de la operación
- **Response**:
  - `eResponse.success`: true/false
  - `eResponse.data`: Datos de respuesta (array/objeto)
  - `eResponse.message`: Mensaje de error o información

## 4. Stored Procedures
- **reporte_poliza_por_recaudadora(fecha, recaud)**: Devuelve el reporte agrupado por cuenta de aplicación, con totales y sumas.
- **catalogo_recaudadoras()**: Devuelve el catálogo de recaudadoras disponibles.

## 5. Flujo de la Aplicación
1. El usuario accede a la página `/frmpol`.
2. El frontend solicita el catálogo de recaudadoras (`getRecaudadoras`).
3. El usuario selecciona fecha y recaudadora, y presiona "Imprimir".
4. El frontend envía la solicitud `getPolizaReporte` con los parámetros.
5. El backend ejecuta el stored procedure y devuelve los resultados.
6. El frontend muestra la tabla de resultados y totales.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse mediante autenticación (ej: middleware `auth:api`), según la política de la aplicación.
- Validación de parámetros en el backend.

## 7. Consideraciones de Migración
- El reporte visual se implementa como tabla HTML con totales, no como PDF/impreso (puede exportarse si se requiere).
- Los nombres de campos y lógica se mantienen fieles al original Delphi.
- El catálogo de recaudadoras se obtiene de la tabla `c_ctasapl`.

## 8. Extensibilidad
- Nuevos formularios pueden integrarse fácilmente usando el mismo patrón eRequest/eResponse y agregando nuevos stored procedures y casos en el controlador.

## 9. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+

## 10. Ejemplo de Solicitud API
```json
{
  "eRequest": "getPolizaReporte",
  "params": {
    "fecha": "2024-06-01",
    "recaud": "003"
  }
}
```

## 11. Ejemplo de Respuesta API
```json
{
  "eResponse": {
    "success": true,
    "data": [
      { "cvectaapl": "003", "ctaaplicacion": "Recaudadora Centro", "totpar": 12, "suma": 15000.00 },
      ...
    ],
    "message": ""
  }
}
```
