# Documentación: RepOper

## Análisis Técnico

# Documentación Técnica: Migración Formulario RepOper (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario de "Listado de Operaciones por Caja" (RepOper) migrado desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El objetivo es mantener la funcionalidad original, permitiendo consultar totales y desgloses de operaciones por fecha, recaudadora y caja.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "getTotalesOperaciones", // o "getDesgloseOperaciones", "getCajasByFechaRecaud"
      "params": {
        "fecha": "2024-06-01",
        "recaud": "1",
        "caja": "A"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": { ... },
      "error": null
    }
  }
  ```

## 4. Stored Procedures
- **repoper_totales:** Devuelve los totales de operaciones (canceladas, cheques, doc cero, totales, puro efectivo, etc.)
- **repoper_desglose:** Devuelve el listado detallado de operaciones para la selección dada.

## 5. Flujo de la Interfaz
1. Usuario selecciona fecha y recaudadora.
2. El sistema carga las cajas disponibles para esa fecha y recaudadora.
3. Usuario selecciona caja y elige entre "Totales" o "Desglose".
4. El sistema consulta el API y muestra los resultados en tablas.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de consultas parametrizadas para evitar SQL Injection.

## 7. Consideraciones
- Los nombres de campos y lógica se mantienen fieles al sistema original.
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.
- El backend es extensible para otras operaciones bajo el mismo endpoint.

## 8. Extensión
- Se pueden agregar más operaciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.

## 9. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+

## 10. Pruebas
- Incluye casos de uso y escenarios de prueba para QA.

## Casos de Uso

# Casos de Uso - RepOper

**Categoría:** Form

## Caso de Uso 1: Consulta de Totales de Operaciones

**Descripción:** El usuario desea conocer los totales de operaciones (canceladas, cheques, efectivo, etc.) para una caja, recaudadora y fecha específica.

**Precondiciones:**
Existen registros en las tablas pagos y cheqpag para la fecha, recaudadora y caja seleccionadas.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Operaciones por Caja.
2. Selecciona la fecha de ingreso.
3. Selecciona la recaudadora (por ejemplo, '1').
4. El sistema carga las cajas disponibles para esa fecha y recaudadora.
5. El usuario selecciona una caja.
6. El usuario hace clic en el botón 'Totales'.
7. El sistema muestra los totales de operaciones.

**Resultado esperado:**
Se muestran los totales de operaciones correctamente calculados para la selección dada.

**Datos de prueba:**
fecha: '2024-06-01', recaud: '1', caja: 'A'

---

## Caso de Uso 2: Consulta de Desglose de Operaciones

**Descripción:** El usuario requiere ver el detalle de todas las operaciones realizadas en una caja, recaudadora y fecha.

**Precondiciones:**
Existen operaciones registradas en pagos y auditoria para la combinación seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Operaciones por Caja.
2. Selecciona la fecha de ingreso.
3. Selecciona la recaudadora.
4. El sistema carga las cajas disponibles.
5. El usuario selecciona una caja.
6. El usuario hace clic en el botón 'Desglose'.
7. El sistema muestra el listado detallado de operaciones.

**Resultado esperado:**
Se muestra una tabla con el detalle de cada operación (folio, cuenta, importe, mensaje, etc.).

**Datos de prueba:**
fecha: '2024-06-01', recaud: '2', caja: 'B'

---

## Caso de Uso 3: Carga dinámica de cajas por fecha y recaudadora

**Descripción:** El usuario selecciona una fecha y recaudadora, y el sistema debe mostrar solo las cajas disponibles para esa combinación.

**Precondiciones:**
Existen registros en pagos para varias cajas en la fecha y recaudadora seleccionadas.

**Pasos a seguir:**
1. El usuario accede al formulario.
2. Selecciona una fecha.
3. Selecciona una recaudadora.
4. El sistema consulta y muestra las cajas disponibles en el combo de cajas.

**Resultado esperado:**
El combo de cajas muestra solo las cajas válidas para la fecha y recaudadora seleccionadas.

**Datos de prueba:**
fecha: '2024-06-01', recaud: '3'

---

## Casos de Prueba

## Casos de Prueba para RepOper

### Caso 1: Consulta de Totales Correcta
- **Entradas:** fecha = '2024-06-01', recaud = '1', caja = 'A'
- **Acción:** Solicitar totales vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - Los campos `canceladas`, `cheques`, `doc_cero`, `tot_total`, etc. tienen valores numéricos coherentes.

### Caso 2: Consulta de Desglose Correcta
- **Entradas:** fecha = '2024-06-01', recaud = '2', caja = 'B'
- **Acción:** Solicitar desglose vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El array `data` contiene objetos con los campos: folio, cvecuenta, importe, mensaje, etc.

### Caso 3: Carga de Cajas Dinámica
- **Entradas:** fecha = '2024-06-01', recaud = '3'
- **Acción:** Solicitar cajas vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El array `data` contiene objetos con campo `caja`.

### Caso 4: Parámetros Faltantes
- **Entradas:** recaud = '1', caja = 'A' (sin fecha)
- **Acción:** Solicitar totales vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `false`.
  - El campo `error` indica parámetro faltante.

### Caso 5: Sin Resultados
- **Entradas:** fecha = '2099-01-01', recaud = '1', caja = 'Z'
- **Acción:** Solicitar totales o desglose vía API.
- **Esperado:**
  - El objeto `eResponse.success` es `true`.
  - El campo `data` es null (totales) o array vacío (desglose).

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

