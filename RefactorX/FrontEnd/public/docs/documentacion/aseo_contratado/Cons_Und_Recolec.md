# Documentación Técnica: Cons_Und_Recolec

## Análisis

# Documentación Técnica: Consulta de Unidades de Recolección

## Descripción General
Este módulo permite consultar y exportar la lista de Unidades de Recolección para un ejercicio fiscal determinado, ordenando por diferentes criterios. Incluye:
- Endpoint API unificado `/api/execute` (patrón eRequest/eResponse)
- Stored Procedure PostgreSQL para consulta eficiente
- Componente Vue.js como página independiente
- Controlador Laravel para orquestación

## Arquitectura
- **Backend**: Laravel + PostgreSQL
- **Frontend**: Vue.js (SPA, página independiente)
- **API**: Único endpoint `/api/execute` que recibe `{ eRequest, params }` y responde `{ success, data, message }`
- **Stored Procedure**: `sp_cons_und_recolec_list` encapsula la lógica de consulta y ordenamiento

## Flujo de Datos
1. El usuario accede a la página de consulta y selecciona el ejercicio y el criterio de orden.
2. Vue.js envía un POST a `/api/execute` con `eRequest: 'cons_und_recolec_list'` y los parámetros.
3. El controlador Laravel ejecuta el stored procedure y retorna los datos.
4. Vue.js muestra la tabla y permite exportar a Excel (CSV).

## Detalles Técnicos
### Endpoint API
- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**:
  - `eRequest`: string (ej. 'cons_und_recolec_list')
  - `params`: objeto con parámetros (ejercicio, order)
- **Salida**:
  - `success`: boolean
  - `data`: array de objetos (campos de la tabla)
  - `message`: string (mensaje de error o éxito)

### Stored Procedure
- **Nombre**: `sp_cons_und_recolec_list`
- **Parámetros**:
  - `p_ejercicio` (INTEGER): Ejercicio fiscal
  - `p_order` (TEXT): Campo de ordenamiento
- **Retorna**: Tabla con los campos principales de la unidad de recolección
- **Seguridad**: El campo de ordenamiento se valida usando `format` para evitar SQL Injection

### Vue.js
- Página independiente, sin tabs
- Permite seleccionar ejercicio y orden
- Muestra tabla y exporta a CSV
- Usa axios para llamadas API

### Laravel Controller
- Recibe eRequest y params
- Ejecuta el stored procedure
- Devuelve respuesta estándar

## Seguridad
- El campo de ordenamiento se valida en el stored procedure usando `format` y no se concatena directamente
- El endpoint requiere autenticación (no mostrado aquí, pero debe protegerse en producción)

## Extensibilidad
- Se pueden agregar más operaciones al endpoint `/api/execute` usando nuevos valores de `eRequest`
- El stored procedure puede ampliarse para filtros adicionales

## Ejemplo de Request
```json
{
  "eRequest": "cons_und_recolec_list",
  "params": {
    "ejercicio": 2024,
    "order": "descripcion"
  }
}
```

## Ejemplo de Response
```json
{
  "success": true,
  "data": [
    {
      "ctrol_recolec": 1,
      "ejercicio_recolec": 2024,
      "cve_recolec": "A",
      "descripcion": "Unidad A",
      "costo_unidad": 100.00,
      "costo_exed": 50.00
    },
    ...
  ],
  "message": ""
}
```


## Casos de Uso

# Casos de Uso - Cons_Und_Recolec

**Categoría:** Form

## Caso de Uso 1: Consulta básica de Unidades de Recolección por ejercicio

**Descripción:** El usuario consulta todas las unidades de recolección del ejercicio actual, ordenadas por número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla ta_16_unidades para el ejercicio actual.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Unidades de Recolección.
2. Selecciona el ejercicio actual (por defecto).
3. Selecciona 'Control' como criterio de orden.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra la tabla con todas las unidades de recolección del ejercicio actual, ordenadas por número de control.

**Datos de prueba:**
Ejercicio: 2024, Orden: ctrol_recolec

---

## Caso de Uso 2: Exportar listado de Unidades de Recolección a Excel

**Descripción:** El usuario exporta el listado filtrado a un archivo Excel (CSV).

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar Excel'.
2. El sistema genera y descarga un archivo CSV con los datos mostrados.

**Resultado esperado:**
El archivo CSV contiene las mismas filas y columnas que la tabla mostrada.

**Datos de prueba:**
Ejercicio: 2024, Orden: descripcion

---

## Caso de Uso 3: Consulta por descripción

**Descripción:** El usuario consulta las unidades de recolección ordenadas por descripción.

**Precondiciones:**
El usuario tiene acceso y existen varias unidades con diferentes descripciones.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona el ejercicio deseado.
3. Selecciona 'Descripción' como criterio de orden.
4. Presiona 'Buscar'.

**Resultado esperado:**
La tabla muestra las unidades ordenadas alfabéticamente por descripción.

**Datos de prueba:**
Ejercicio: 2023, Orden: descripcion

---



## Casos de Prueba

# Casos de Prueba: Consulta Unidades de Recolección

## Caso 1: Consulta básica por ejercicio
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 2024, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - Código HTTP 200
  - success: true
  - data: array con filas (campos: ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
  - message: ''

## Caso 2: Consulta con orden por descripción
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 2023, order: 'descripcion' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: array ordenada alfabéticamente por descripcion

## Caso 3: Exportar a Excel
- **Entrada:**
  - eRequest: cons_und_recolec_export
  - params: { ejercicio: 2024, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: array con los mismos datos que la consulta
  - El frontend genera y descarga un archivo CSV

## Caso 4: Error por parámetro inválido
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 'abcd', order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: false
  - message: error de tipo/conversión

## Caso 5: Ejercicio sin datos
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 1999, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: []
  - message: ''


