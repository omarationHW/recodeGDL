# Documentación Técnica: Migración Formulario sqrp_esta01 (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este desarrollo migra el formulario de reporte de multas de estacionómetros (`sqrp_esta01`) de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El reporte muestra, agrupado por año y tipo de infracción, la cantidad de folios y el importe total de multas.

## 2. Arquitectura
- **Backend**: Laravel API con endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros, y responde con `eResponse`.
- **Frontend**: Componente Vue.js como página independiente, consulta el API y muestra el reporte.
- **Base de Datos**: Toda la lógica SQL se encapsula en un stored procedure PostgreSQL.

## 3. API Unificada
- **Endpoint**: `/api/execute` (POST)
- **Request**:
  ```json
  {
    "eRequest": "sqrp_esta01_report",
    "params": {
      "axo_from": 2020,
      "axo_to": 2023
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [
        { "axo": 2020, "totfol": 100, "infraccion": 1, "totimp": 5000.00 },
        ...
      ],
      "message": ""
    }
  }
  ```

## 4. Stored Procedure
- **Nombre**: `sqrp_esta01_report`
- **Parámetros**: `axo_from` (opcional), `axo_to` (opcional)
- **Retorna**: Tabla con columnas `axo`, `totfol`, `infraccion`, `totimp`
- **Lógica**: Replica el SQL del formulario Delphi, permitiendo filtrar por rango de años.

## 5. Frontend (Vue.js)
- Página independiente, con filtros de año, tabla de resultados, totales y breadcrumbs.
- Consulta el API al cargar y al filtrar.
- Muestra mensajes de carga, error y "sin datos".

## 6. Backend (Laravel)
- Controlador `ExecuteController` maneja todas las peticiones `/api/execute`.
- Llama al stored procedure según el valor de `eRequest`.
- Maneja errores y responde con el patrón `eResponse`.

## 7. Seguridad
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.
- Validar y sanear los parámetros recibidos.

## 8. Pruebas
- Casos de uso y pruebas incluidas para validar funcionamiento y manejo de errores.

## 9. Extensibilidad
- Para agregar nuevos formularios, basta con crear nuevos stored procedures y mapearlos en el controlador.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 11. Notas
- El reporte puede exportarse a PDF/Excel agregando lógica adicional en frontend/backend.
- El diseño visual puede adaptarse a la identidad institucional.
