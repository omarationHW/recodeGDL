# Documentación Técnica: Migración de Formulario reqmultas400frm

## 1. Descripción General
Este módulo permite consultar requerimientos de multas 400 por dos criterios:
- Por Dependencia, Año de Acta y Número de Acta
- Por Año de Requerimiento y Folio de Requerimiento

La migración incluye:
- Backend Laravel con endpoint unificado `/api/execute`.
- Stored Procedures en PostgreSQL para encapsular la lógica de consulta.
- Componente Vue.js como página independiente.

## 2. Backend Laravel
- **Controlador:** `App\Http\Controllers\Api\ExecuteController`
- **Endpoint:** `POST /api/execute`
- **Patrón:** Recibe un objeto JSON con `eRequest` y `params`.
- **eRequest**:
  - `reqmultas400_by_acta`: Consulta por acta.
  - `reqmultas400_by_folio`: Consulta por folio.
- **params**:
  - Para `reqmultas400_by_acta`: `{ dep, axo, numacta, tipo }`
  - Para `reqmultas400_by_folio`: `{ axo, folio, tipo }`
- **Respuesta:**
  - `{ eResponse: { success, data, error } }`

## 3. Stored Procedures PostgreSQL
- **req_mul_400_by_acta**: Consulta por dependencia, año de acta, número de acta y tipo.
- **req_mul_400_by_folio**: Consulta por año de requerimiento, folio y tipo.
- Ambas devuelven un SETOF de la tabla `req_mul_400`.

## 4. Frontend Vue.js
- **Componente:** `ReqMultas400Page.vue`
- **Rutas:** Página independiente, no usa tabs.
- **Funcionalidad:**
  - Permite seleccionar tipo de multa (federal/municipal).
  - Permite buscar por acta o por folio.
  - Muestra resultados en tabla.
  - Maneja errores y estados de carga.

## 5. Seguridad
- Validación de parámetros en frontend y backend.
- Uso de stored procedures para evitar SQL injection.
- Manejo de errores y logs en backend.

## 6. Pruebas
- Casos de uso y escenarios de prueba incluidos para asegurar la funcionalidad.

## 7. Consideraciones
- El campo `cvelet` se asume de longitud suficiente para extraer los caracteres 4-6 como dependencia.
- El frontend espera que los nombres de columnas sean los de la tabla `req_mul_400`.
