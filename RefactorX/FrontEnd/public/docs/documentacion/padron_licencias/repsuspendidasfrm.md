# Documentación Técnica: repsuspendidasfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario repsuspendidasfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al reporte de licencias suspendidas, migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). Toda la lógica de consulta y filtrado se encapsula en un stored procedure, y la comunicación entre frontend y backend se realiza mediante un endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.

## 2. Backend (Laravel)
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** El endpoint recibe un JSON con los campos `eRequest` (nombre de la operación) y `params` (parámetros de entrada). El controlador despacha la petición según el valor de `eRequest`.
- **Reporte:** Para `eRequest: 'repsuspendidas_report'`, el controlador llama al stored procedure `report_licencias_suspendidas` pasando los parámetros recibidos.
- **Validación:** Si no se recibe año ni fechas, retorna error 422.
- **Respuesta:**
  - `eResponse: 'ok'` y los datos del reporte si hay resultados.
  - `eResponse: 'ok'` y mensaje si no hay resultados.
  - `eResponse: 'error'` y mensaje si hay error de validación o ejecución.

## 3. Frontend (Vue.js)
- **Componente:** Página independiente `RepSuspendidasPage.vue`.
- **Ruta:** Debe ser registrada como página completa (no tab).
- **Formulario:** Permite filtrar por año, rango de fechas y tipo de suspensión (botones tipo radio).
- **Validación:** No permite enviar si no hay año ni fechas.
- **Resultados:** Muestra tabla con los campos principales del reporte, incluyendo traducción del campo `bloqueado` a texto legible.
- **UX:** Incluye breadcrumbs, mensajes de error y éxito, y spinner de carga.

## 4. Stored Procedure (PostgreSQL)
- **Nombre:** `report_licencias_suspendidas`
- **Parámetros:**
  - `p_year` (INT): Año de búsqueda (opcional)
  - `p_date_from` (DATE): Fecha inicial (opcional)
  - `p_date_to` (DATE): Fecha final (opcional)
  - `p_tipo_suspension` (INT): Tipo de suspensión (0=Todas, 1=Bloqueo, ...)
- **Lógica:**
  - Si se indica año, filtra desde el 1 de enero de ese año.
  - Si se indica fecha inicial y no final, filtra por esa fecha exacta.
  - Si se indican ambas fechas, filtra entre ellas.
  - Si se indica tipo de suspensión > 0, filtra por ese valor en `bloqueado`.
  - Siempre filtra por `b.vigente = 'V'`.
  - Devuelve todos los campos de licencias más el campo calculado `propietarionvo`.

## 5. API Unificada
- **Entrada:**
  ```json
  {
    "eRequest": "repsuspendidas_report",
    "params": {
      "year": 2024,
      "date_from": "2024-01-01",
      "date_to": "2024-01-31",
      "tipo_suspension": 1
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": "ok",
    "data": [ ... ],
    "total": 5
  }
  ```

## 6. Seguridad
- El endpoint debe protegerse con autenticación (ej: Sanctum, JWT) según la política del sistema.
- Validar y sanear todos los parámetros recibidos.

## 7. Consideraciones
- El frontend asume que el backend retorna los campos con los mismos nombres que en la base de datos.
- El campo `bloqueado` se traduce a texto en el frontend.
- El reporte puede ser exportado a PDF/Excel agregando funcionalidad adicional.

## Casos de Prueba

## Casos de Prueba para Reporte de Licencias Suspendidas

### Caso 1: Consulta por año
- **Entrada:** year=2022, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data con registros de 2022, total > 0.

### Caso 2: Consulta por rango de fechas y tipo
- **Entrada:** year=0, date_from='2024-03-01', date_to='2024-03-10', tipo_suspension=1
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data solo con registros entre esas fechas y bloqueado=1.

### Caso 3: Validación de campos requeridos
- **Entrada:** year=0, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='error', mensaje 'Debes indicar el año o las fechas de las licencias ...'.

### Caso 4: Consulta sin resultados
- **Entrada:** year=1999, date_from=null, date_to=null, tipo_suspension=0
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data vacía, mensaje 'No se encontraron licencias con esas condiciones ...'.

### Caso 5: Consulta por fecha exacta
- **Entrada:** year=0, date_from='2024-04-15', date_to=null, tipo_suspension=3
- **Acción:** Enviar petición a /api/execute con eRequest='repsuspendidas_report'.
- **Esperado:** Respuesta eResponse='ok', data solo con registros de esa fecha y bloqueado=3.

## Casos de Uso

# Casos de Uso - repsuspendidasfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de licencias suspendidas por año

**Descripción:** El usuario desea obtener un reporte de todas las licencias suspendidas en el año 2023, sin filtrar por tipo de suspensión.

**Precondiciones:**
El usuario tiene acceso al sistema y existen licencias suspendidas en 2023.

**Pasos a seguir:**
1. Ingresar a la página de 'Reporte de Licencias Suspendidas'.
2. Ingresar '2023' en el campo Año.
3. Dejar vacíos los campos de fecha.
4. Seleccionar 'Todas' en tipo de suspensión.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las licencias suspendidas en 2023, incluyendo los datos principales y el total de registros.

**Datos de prueba:**
{ "year": 2023, "date_from": null, "date_to": null, "tipo_suspension": 0 }

---

## Caso de Uso 2: Consulta por rango de fechas y tipo de suspensión

**Descripción:** El usuario requiere ver las licencias suspendidas entre el 1 y el 15 de febrero de 2024, solo del tipo 'Suspendida'.

**Precondiciones:**
El usuario tiene acceso y existen licencias suspendidas en ese rango y tipo.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Dejar vacío el campo Año.
3. Seleccionar fecha inicial '2024-02-01' y fecha final '2024-02-15'.
4. Seleccionar 'Suspendida' como tipo de suspensión.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se listan solo las licencias suspendidas entre esas fechas y con tipo 'Suspendida'.

**Datos de prueba:**
{ "year": 0, "date_from": "2024-02-01", "date_to": "2024-02-15", "tipo_suspension": 4 }

---

## Caso de Uso 3: Validación de campos requeridos

**Descripción:** El usuario intenta consultar el reporte sin ingresar año ni fechas.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar a la página de reporte.
2. Dejar vacíos todos los campos de filtro.
3. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe indicar el año o las fechas.

**Datos de prueba:**
{ "year": 0, "date_from": null, "date_to": null, "tipo_suspension": 0 }

---


