# Documentación Técnica: Migración de Formulario repmultampalfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este documento describe la migración del formulario Delphi `repmultampalfrm` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio). El objetivo es mantener la funcionalidad original, permitiendo la consulta y reporte de multas municipales con filtros avanzados.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, cada formulario es una página independiente.
- **Backend**: Laravel API, con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos**: PostgreSQL, lógica de reportes en stored procedures.

## 3. Endpoints API
- **POST /api/execute**
  - **eRequest: get_dependencias**
    - Retorna catálogo de dependencias.
  - **eRequest: get_infracciones_by_dependencia**
    - Parámetro: `id_dependencia`
    - Retorna catálogo de infracciones para la dependencia seleccionada.
  - **eRequest: get_multas_report**
    - Parámetros: filtros de reporte (ver stored procedure)
    - Retorna listado de multas según filtros.

## 4. Stored Procedure Principal
- **report_multas**: Recibe todos los filtros posibles y retorna el reporte de multas, incluyendo datos de dependencia (abreviatura).
- Los filtros incluyen:
  - Dependencia
  - Infracción
  - Nombre de contribuyente
  - Domicilio
  - Fecha (única, rango, año)
  - Estatus (vigente, cancelado, pagado)

## 5. Frontend (Vue.js)
- Página independiente con ruta propia.
- Filtros dinámicos (habilitados/deshabilitados según checkbox).
- Carga dinámica de infracciones según dependencia seleccionada.
- Validaciones de campos requeridos según tipo de filtro.
- Resultados en tabla, con total de registros.

## 6. Backend (Laravel)
- Controlador único `ExecuteController`.
- Manejo de eRequest/eResponse.
- Llamadas a stored procedures vía DB::select.
- Validación de parámetros y manejo de errores.

## 7. Seguridad
- Validación de parámetros en backend.
- Uso de parámetros en consultas para evitar SQL Injection.
- El endpoint `/api/execute` debe protegerse según políticas de autenticación/autorización del sistema.

## 8. Consideraciones
- El estatus "Pagado" no está implementado en la lógica original Delphi, se deja como placeholder.
- El frontend puede ser extendido para exportar a PDF/Excel si se requiere.

## 9. Requerimientos Previos
- Tablas: `multas`, `c_dependencias`, `c_infracciones` deben existir y tener los campos esperados.
- El stored procedure debe ser creado en la base de datos PostgreSQL destino.

## 10. Ejemplo de Llamada API
```json
{
  "eRequest": "get_multas_report",
  "params": {
    "id_dependencia": 1,
    "id_infraccion": null,
    "contribuyente": "JUAN",
    "domicilio": null,
    "fecha_tipo": 2,
    "fecha1": "2024-01-01",
    "fecha2": "2024-06-30",
    "anio": null,
    "estatus": 1
  }
}
```

## 11. Errores Comunes
- Si faltan parámetros requeridos, el API retorna `success: false` y un mensaje de error.
- Si no hay resultados, el frontend muestra mensaje de "No se encontraron resultados".
