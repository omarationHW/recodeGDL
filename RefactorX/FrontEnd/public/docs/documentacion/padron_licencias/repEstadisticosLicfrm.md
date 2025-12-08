# Documentación Técnica: repEstadisticosLicfrm

## Análisis Técnico

# Documentación Técnica: Migración de repEstadisticosLicfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente, sin tabs)
- **Base de Datos:** PostgreSQL (toda la lógica SQL en stored procedures)
- **Patrón de integración:** eRequest/eResponse (API unificada)

## Flujo de Trabajo
1. **El usuario accede a la página de reportes estadísticos de licencias** (componente Vue.js).
2. **Selecciona el tipo de reporte** y, si aplica, el rango de fechas y/o clasificación.
3. **Al presionar "Consultar"**, el frontend envía una petición POST a `/api/execute` con el objeto `eRequest`:
   ```json
   {
     "eRequest": {
       "action": "reporte_licencias_rango", // o el que corresponda
       "params": { "fecha1": "2024-01-01", "fecha2": "2024-06-30" }
     }
   }
   ```
4. **El controlador Laravel** recibe la petición, identifica la acción y llama al stored procedure correspondiente en PostgreSQL.
5. **El resultado** se retorna en el objeto `eResponse`:
   ```json
   {
     "eResponse": {
       "success": true,
       "data": [ ... ]
     }
   }
   ```
6. **El frontend muestra los resultados** en una tabla dinámica.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: string, params: object } }`
  - Salida: `{ eResponse: { success: bool, data: array, error?: string } }`

## Stored Procedures
- Toda la lógica de agrupación, conteo y filtrado se implementa en SPs de PostgreSQL.
- Los SPs devuelven tablas con los campos requeridos para los reportes.

## Seguridad
- Validación de parámetros en el controlador Laravel.
- Manejo de errores y logs.

## Frontend
- Cada formulario es una página Vue.js independiente.
- No se usan tabs ni componentes tabulares.
- Navegación y breadcrumbs opcionales.
- El formulario es reactivo y muestra errores de validación.
- Resultados en tabla dinámica con columnas automáticas.

## Extensibilidad
- Para agregar nuevos reportes, basta con:
  1. Crear el SP en PostgreSQL.
  2. Agregar el case en el controlador Laravel.
  3. Añadir la opción en el frontend.

## Pruebas
- Casos de uso y escenarios de prueba incluidos (ver más abajo).

# Notas de Migración
- Todas las queries SQL del Delphi original se migran a SPs.
- El frontend no replica el diseño visual de Delphi, sino la funcionalidad.
- El endpoint es único y desacoplado de la UI.

# Consideraciones
- Los reportes pueden ser exportados desde el frontend usando herramientas de Vue.js.
- El backend puede ser extendido para autenticación y autorización.

## Casos de Prueba

# Casos de Prueba para repEstadisticosLicfrm

## Caso 1: Reporte de licencias dadas de alta en un rango de fechas
- **Entrada:**
  - action: reporte_licencias_rango
  - params: { fecha1: '2024-01-01', fecha2: '2024-06-30' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data es un array con campos: id_giro, descripcion, z_1, ..., total

## Caso 2: Reporte de giros reglamentados por zona (solo tipo D)
- **Entrada:**
  - action: reporte_giros_reglamentados_zona
  - params: { clasificacion: 'D' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data contiene solo giros tipo D

## Caso 3: Reporte de pagos de licencias en un rango de fechas
- **Entrada:**
  - action: reporte_pagos_licencias_rango
  - params: { fecha1: '2024-01-01', fecha2: '2024-06-30' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data contiene campos: recaud, cuantos

## Caso 4: Validación de fechas requeridas
- **Entrada:**
  - action: reporte_licencias_rango
  - params: { fecha1: '', fecha2: '' }
- **Esperado:**
  - HTTP 400, eResponse.success = false
  - eResponse.error indica que las fechas son requeridas

## Caso 5: Acción no soportada
- **Entrada:**
  - action: reporte_no_existente
  - params: {}
- **Esperado:**
  - HTTP 400, eResponse.success = false
  - eResponse.error = 'Acción no soportada'

## Casos de Uso

# Casos de Uso - repEstadisticosLicfrm

**Categoría:** Form

## Caso de Uso 1: Reporte de licencias dadas de alta en un rango de fechas

**Descripción:** El usuario desea obtener un reporte de todas las licencias dadas de alta entre dos fechas específicas, agrupadas por giro y zona.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de reportes estadísticos de licencias.
2. Selecciona la opción 'Licencias dadas de alta en un rango de tiempo'.
3. Ingresa la fecha inicial y final.
4. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los giros, descripción y el conteo de licencias por zona (z_1 a z_7, otros, total) en el rango de fechas seleccionado.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-06-30" }

---

## Caso de Uso 2: Reporte de giros reglamentados por zona (solo tipo C)

**Descripción:** El usuario requiere un reporte de los giros reglamentados tipo C agrupados por zona.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página de reportes estadísticos.
2. Selecciona 'Giros reglamentados por zona'.
3. Selecciona 'Solo C' en clasificación.
4. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los giros tipo C y el conteo por zona.

**Datos de prueba:**
{ "clasificacion": "C" }

---

## Caso de Uso 3: Reporte de pagos de licencias en un rango de fechas

**Descripción:** El usuario desea saber cuántos pagos de licencias se han realizado en cada recaudadora en un periodo.

**Precondiciones:**
El usuario tiene acceso y existen pagos registrados.

**Pasos a seguir:**
1. Accede a la página de reportes.
2. Selecciona 'Pagos de licencias en un rango de tiempo'.
3. Ingresa la fecha inicial y final.
4. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con el número de pagos por recaudadora.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-06-30" }

---


