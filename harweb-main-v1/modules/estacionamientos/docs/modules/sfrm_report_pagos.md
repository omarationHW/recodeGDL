# Documentación Técnica: Migración de Formulario sfrm_report_pagos

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrm_report_pagos` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad de reportes de folios pagados y folios elaborados por usuario, centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, con un único controlador API (`/api/execute`) que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 3+, componente de página independiente para el formulario de reportes.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

### Acciones soportadas
- `report_folios_pagados` (params: reca, fechora)
- `report_folios_elaborados_usuario` (params: fechora, vigila)
- `report_folios_adeudo_por_inspector` (params: fechora)
- `get_usuarios` (sin params)

## 4. Stored Procedures
Toda la lógica de reportes se encuentra en funciones PostgreSQL:
- `report_folios_pagados(reca int, fechora date)`
- `report_folios_elaborados_usuario(fechora date, vigila int)`
- `report_folios_adeudo_por_inspector(fechora date)`

## 5. Frontend
- El componente Vue.js es una página completa, con navegación breadcrumb.
- Permite seleccionar el tipo de reporte y la fecha.
- Muestra los resultados en tablas responsivas.
- Calcula totales de folios e importes.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej: JWT, Sanctum) en producción.
- Los parámetros deben validarse en el backend.

## 7. Consideraciones
- El valor de `reca` y `vigila` (usuario actual) debe obtenerse del contexto de autenticación en producción.
- El frontend asume que el backend retorna los datos en el formato esperado.

## 8. Pruebas
- Se recomienda usar Postman o similar para pruebas directas al endpoint.
- El frontend puede probarse navegando a la ruta correspondiente y generando reportes con diferentes fechas y tipos.

## 9. Extensibilidad
- Para agregar nuevos reportes, basta con crear un nuevo stored procedure y mapearlo en el controlador.

## 10. Migración de Datos
- Se asume que las tablas `ta14_refrecibo`, `ta14_folios_histo`, `ta14_folios_adeudo`, `ta14_tarifas`, `ta14_personas`, `ta14_codigomovtos`, y `ta_12_passwords` existen en PostgreSQL y contienen los datos migrados desde el sistema original.
