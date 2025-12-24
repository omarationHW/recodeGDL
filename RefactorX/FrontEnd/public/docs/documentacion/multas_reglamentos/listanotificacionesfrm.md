# Documentación: listanotificacionesfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario listanotificacionesfrm

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `listanotificacionesfrm` a una arquitectura moderna basada en Laravel (API RESTful), Vue.js (SPA) y PostgreSQL (procedimientos almacenados). El objetivo es permitir la consulta y generación de reportes de notificaciones, requerimientos y secuestros de multas, filtrando por recaudadora, año, folios y tipo de documento, con diferentes criterios de ordenamiento.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedure `sp_listanotificaciones_report`.

## 3. Flujo de Datos
1. El usuario ingresa los filtros y opciones en la página Vue.
2. Al hacer clic en "Imprimir", se envía una petición POST a `/api/execute` con el siguiente payload:
   ```json
   {
     "eRequest": "listanotificaciones_report",
     "params": {
       "reca": 2,
       "axo": 2024,
       "inicio": 1000,
       "final": 2000,
       "tipo": "N",
       "orden": "lote"
     }
   }
   ```
3. Laravel recibe la petición, identifica el eRequest y llama al stored procedure correspondiente.
4. El resultado se retorna en el campo `data` del eResponse.
5. Vue.js muestra el resultado en tabla y el total de actas encontradas.

## 4. Stored Procedure
- **Nombre:** sp_listanotificaciones_report
- **Parámetros:**
  - p_axo: Año de la notificación
  - p_reca: Recaudadora
  - p_inicio: Folio inicial
  - p_final: Folio final
  - p_tipo: Tipo de documento ('N', 'R', 'S')
  - p_orden: Criterio de orden ('lote', 'vigentes', 'dependencia')
- **Retorna:** abrevia, axo_acta, num_acta, num_lote, folioreq
- **Lógica:** Ejecuta el SELECT adecuado según el criterio de orden.

## 5. API
- **Endpoint:** POST /api/execute
- **Request:**
  - eRequest: string (ej. 'listanotificaciones_report')
  - params: objeto con los parámetros requeridos
- **Response:**
  - success: boolean
  - data: array de resultados
  - message: string de error si aplica

## 6. Validaciones
- Todos los campos son obligatorios.
- El campo 'tipo' debe ser uno de 'N', 'R', 'S'.
- El campo 'orden' debe ser uno de 'lote', 'vigentes', 'dependencia'.

## 7. Seguridad
- El endpoint debe estar protegido por autenticación (no incluido aquí, agregar middleware si es necesario).
- Validar y sanear todos los parámetros recibidos.

## 8. Extensibilidad
- Para agregar nuevos reportes, crear nuevos stored procedures y mapearlos en el controlador.

## 9. Pruebas
- Ver sección de casos de uso y casos de prueba.

## Casos de Uso

# Casos de Uso - listanotificacionesfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Notificaciones por Lote

**Descripción:** El usuario desea obtener el listado de notificaciones de multas para una recaudadora y año específicos, filtrando por un rango de folios y ordenando por número de lote.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en las tablas reqmultas, multas y c_dependencias que cumplen los criterios.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 2).
2. Ingresar el año (ej. 2024).
3. Ingresar el folio inicial (ej. 1000).
4. Ingresar el folio final (ej. 2000).
5. Seleccionar 'Notificación' como tipo de documento.
6. Seleccionar 'Número de lote' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las columnas: Dependencia, Año Acta, Número Acta, Número Lote, Folio Req, ordenada por número de lote y acta. El total de actas se muestra al pie.

**Datos de prueba:**
{ "reca": 2, "axo": 2024, "inicio": 1000, "final": 2000, "tipo": "N", "orden": "lote" }

---

## Caso de Uso 2: Consulta de Requerimientos Vigentes

**Descripción:** El usuario desea obtener solo los requerimientos de multas vigentes (no pagadas ni canceladas) en un rango de folios.

**Precondiciones:**
Existen registros de requerimientos con cvepago y fecha_cancelacion en NULL.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 3).
2. Ingresar el año (ej. 2023).
3. Ingresar el folio inicial (ej. 5000).
4. Ingresar el folio final (ej. 6000).
5. Seleccionar 'Requerimiento' como tipo de documento.
6. Seleccionar 'Folio de notificación (solo vigentes)' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos vigentes, ordenada por folio de notificación.

**Datos de prueba:**
{ "reca": 3, "axo": 2023, "inicio": 5000, "final": 6000, "tipo": "R", "orden": "vigentes" }

---

## Caso de Uso 3: Consulta de Secuestros por Dependencia y Número de Acta

**Descripción:** El usuario desea obtener el listado de secuestros de multas, ordenado por dependencia y número de acta.

**Precondiciones:**
Existen registros de secuestros en el rango de folios indicado.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 1).
2. Ingresar el año (ej. 2022).
3. Ingresar el folio inicial (ej. 7000).
4. Ingresar el folio final (ej. 8000).
5. Seleccionar 'Secuestro' como tipo de documento.
6. Seleccionar 'Dependencia y número de acta' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los secuestros, ordenada por dependencia, año de acta y número de acta.

**Datos de prueba:**
{ "reca": 1, "axo": 2022, "inicio": 7000, "final": 8000, "tipo": "S", "orden": "dependencia" }

---

## Casos de Prueba

# Casos de Prueba: Listado de Notificaciones

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta por lote (notificaciones) | reca=2, axo=2024, inicio=1000, final=2000, tipo='N', orden='lote' | Tabla con registros ordenados por lote y acta, total correcto |
| TC02 | Consulta solo vigentes (requerimientos) | reca=3, axo=2023, inicio=5000, final=6000, tipo='R', orden='vigentes' | Solo registros con cvepago y fecha_cancelacion NULL, ordenados por folioreq |
| TC03 | Consulta por dependencia (secuestros) | reca=1, axo=2022, inicio=7000, final=8000, tipo='S', orden='dependencia' | Registros ordenados por dependencia, año y número de acta |
| TC04 | Parámetro faltante | Falta 'reca' | Error: Missing parameter: reca |
| TC05 | Orden inválido | orden='otro' | Error: Orden no válido: otro |
| TC06 | Sin resultados | rango de folios sin registros | Mensaje: No se encontraron resultados |
| TC07 | SQL Injection | tipo="N'; DROP TABLE multas; --" | Error, sin ejecución de SQL malicioso |

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

