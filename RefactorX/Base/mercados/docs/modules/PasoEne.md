# PasoEne – Migración de Formulario Delphi a Laravel + Vue.js + PostgreSQL

## Descripción General
El formulario PasoEne permite la carga masiva de pagos de energía eléctrica a partir de archivos de texto plano, su previsualización y la inserción en la base de datos. El proceso se ha migrado a una arquitectura moderna usando Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos con stored procedures).

## Arquitectura
- **Frontend:** Vue.js SPA, página independiente `/pasoene`.
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Base de Datos:** PostgreSQL, lógica de inserción encapsulada en stored procedure `sp_pasoene_insert_pagoenergia`.

## Flujo de Trabajo
1. **Carga de Archivo:** El usuario selecciona un archivo `.txt` con pagos de energía.
2. **Parseo y Previsualización:** El archivo se envía al backend, que lo parsea y devuelve los registros para previsualización.
3. **Ejecución de Actualización:** El usuario confirma y los registros se insertan en la base de datos usando el stored procedure.
4. **Reporte de Resultados:** Se muestra el número de registros insertados y los errores encontrados.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "action": "parse_txt" | "bulk_insert" | "preview",
    "data": { ... }
  }
  ```
- **Salida:**
  ```json
  {
    "status": "ok" | "error",
    "data": { ... },
    "errors": [ ... ]
  }
  ```

## Stored Procedure
- Toda la lógica de inserción se realiza en `sp_pasoene_insert_pagoenergia`, que valida y transforma los datos antes de insertarlos.

## Seguridad y Validaciones
- El backend valida el formato de fechas y tipos de datos.
- Los errores de inserción se reportan por línea.
- El endpoint está protegido por autenticación Laravel (middleware estándar).

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones relacionadas con PasoEne.
- El frontend puede ser adaptado para otros formularios similares.

## Integración
- El frontend y backend se comunican exclusivamente por JSON.
- El frontend no accede directamente a la base de datos.

## Requisitos de Infraestructura
- Laravel 10+, PHP 8.1+
- Vue.js 3+
- PostgreSQL 13+

## Consideraciones de Migración
- El parseo de archivos respeta el layout fijo del archivo original Delphi.
- Los errores de formato se reportan inmediatamente.
- El proceso es idempotente: si un registro ya existe, el SP puede ser adaptado para ignorar o actualizar según reglas de negocio.
