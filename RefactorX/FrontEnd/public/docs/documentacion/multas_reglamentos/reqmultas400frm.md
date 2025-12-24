# Documentación: reqmultas400frm

## Análisis Técnico

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

## Casos de Uso

# Casos de Uso - reqmultas400frm

**Categoría:** Form

## Caso de Uso 1: Consulta por Acta - Multa Federal

**Descripción:** El usuario desea consultar los requerimientos de multas federales por dependencia, año y número de acta.

**Precondiciones:**
El usuario tiene acceso a la página y conoce los datos de dependencia, año y número de acta.

**Pasos a seguir:**
1. Seleccionar 'Multas Federales'.
2. Ingresar 'DEP' en Dependencia.
3. Ingresar '2023' en Año de Acta.
4. Ingresar '12345' en Número de Acta.
5. Presionar 'Buscar por Acta'.

**Resultado esperado:**
Se muestra una tabla con los registros de la tabla req_mul_400 que cumplen los criterios.

**Datos de prueba:**
{ dep: 'DEP', axo: 2023, numacta: 12345, tipo: 6 }

---

## Caso de Uso 2: Consulta por Folio - Multa Municipal

**Descripción:** El usuario desea consultar los requerimientos de multas municipales por año y folio de requerimiento.

**Precondiciones:**
El usuario tiene acceso a la página y conoce el año y folio de requerimiento.

**Pasos a seguir:**
1. Seleccionar 'Multas Municipales'.
2. Ingresar '2022' en Año req.
3. Ingresar '54321' en Folio req.
4. Presionar 'Buscar por Folio Req'.

**Resultado esperado:**
Se muestra una tabla con los registros de la tabla req_mul_400 que cumplen los criterios.

**Datos de prueba:**
{ axo: 2022, folio: 54321, tipo: 5 }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario realiza una consulta con datos que no existen en la base.

**Precondiciones:**
El usuario accede a la página y realiza una búsqueda con datos inexistentes.

**Pasos a seguir:**
1. Seleccionar cualquier tipo de multa.
2. Ingresar valores inexistentes en los campos requeridos.
3. Presionar el botón de búsqueda correspondiente.

**Resultado esperado:**
Se muestra el mensaje 'No se encontraron resultados.'

**Datos de prueba:**
{ dep: 'ZZZ', axo: 1900, numacta: 99999, tipo: 6 }

---

## Casos de Prueba

## Casos de Prueba para reqmultas400frm

| # | Descripción | Entrada | Acción | Resultado Esperado |
|---|-------------|---------|--------|-------------------|
| 1 | Consulta por acta válida (federal) | dep: 'DEP', axo: 2023, numacta: 12345, tipo: 6 | Buscar por Acta | Tabla con registros correspondientes |
| 2 | Consulta por folio válida (municipal) | axo: 2022, folio: 54321, tipo: 5 | Buscar por Folio Req | Tabla con registros correspondientes |
| 3 | Consulta por acta inexistente | dep: 'ZZZ', axo: 1900, numacta: 99999, tipo: 6 | Buscar por Acta | Mensaje 'No se encontraron resultados.' |
| 4 | Consulta por folio con campos vacíos | axo: '', folio: '', tipo: 5 | Buscar por Folio Req | Mensaje de error de validación |
| 5 | Consulta por acta con tipo municipal | dep: 'DEP', axo: 2023, numacta: 12345, tipo: 5 | Buscar por Acta | Tabla con registros municipales o mensaje de no encontrados |
| 6 | Error de comunicación (API caída) | Cualquier entrada | Buscar | Mensaje 'Error de comunicación con el servidor.' |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

