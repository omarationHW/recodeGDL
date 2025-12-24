# RptIngresoZonificado

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Migración de RptIngresoZonificado (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa el reporte de Ingreso Zonificado, que muestra el total de ingresos por zona en un periodo de fechas, sumando tanto ingresos normales como ajustes. El frontend es un componente Vue.js de página completa, el backend es un controlador Laravel que expone un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse, y la lógica de consulta reside en un stored procedure de PostgreSQL.

## 2. Arquitectura
- **Frontend**: Vue.js SPA, página independiente, sin tabs. Permite seleccionar fechas y muestra tabla de resultados y total.
- **Backend**: Laravel Controller, endpoint único `/api/execute` que recibe `{action, params}` y responde `{success, data, message}`.
- **Base de Datos**: PostgreSQL, lógica de consulta encapsulada en stored procedure `sp_ingreso_zonificado`.

## 3. Flujo de Datos
1. El usuario ingresa fechas y presiona "Consultar".
2. Vue.js envía POST a `/api/execute` con `{ action: 'getIngresoZonificado', params: { fecdesde, fechasta } }`.
3. Laravel Controller ejecuta el stored procedure y retorna los datos.
4. Vue.js muestra la tabla y el total.
5. Para exportar PDF, Vue.js envía `{ action: 'exportIngresoZonificadoPDF', params: { ... } }` y recibe la URL del PDF generado.

## 4. API (eRequest/eResponse)
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "getIngresoZonificado",
    "params": {
      "fecdesde": "2024-01-01",
      "fechasta": "2024-01-31"
    }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [
      { "id_zona": 1, "zona": "CENTRO", "pagado": 12345.67 }, ...
    ],
    "message": ""
  }
  ```

## 5. Stored Procedure (PostgreSQL)
- **Nombre**: `sp_ingreso_zonificado`
- **Parámetros**: `fecdesde DATE`, `fechasta DATE`
- **Retorna**: Tabla con columnas `id_zona`, `zona`, `pagado`
- **Lógica**: Suma ingresos y ajustes por zona en el rango de fechas.

## 6. Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación (middleware Laravel).
- Validar que las fechas sean válidas y que el usuario tenga permisos.

## 7. Consideraciones de Migración
- El frontend NO usa tabs, cada formulario es una página independiente.
- El backend centraliza la lógica en el stored procedure para eficiencia y mantenibilidad.
- El endpoint es unificado para facilitar integración y pruebas automatizadas.

## 8. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón `action/params`.
- El stored procedure puede ser extendido para incluir más filtros si es necesario.

## 9. Dependencias
- Laravel 9+
- Vue.js 3+
- PostgreSQL 12+
- (Opcional) barryvdh/laravel-dompdf para exportar PDF

## 10. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.


## Casos de Uso

# Casos de Uso - RptIngresoZonificado

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingreso Zonificado por Fechas

**Descripción:** El usuario desea obtener el total de ingresos por zona entre el 1 y el 31 de enero de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Ingreso Zonificado.
2. Selecciona fecha desde '2024-01-01' y fecha hasta '2024-01-31'.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con las zonas y el total de ingresos por zona en el periodo, y el total global.

**Datos de prueba:**
{ "fecdesde": "2024-01-01", "fechasta": "2024-01-31" }

---

## Caso de Uso 2: Exportar Reporte de Ingreso Zonificado a PDF

**Descripción:** El usuario desea exportar el reporte consultado a PDF.

**Precondiciones:**
El usuario ya realizó una consulta exitosa.

**Pasos a seguir:**
1. Presiona el botón 'Exportar PDF'.

**Resultado esperado:**
Se descarga o abre el PDF con el reporte de ingresos por zona.

**Datos de prueba:**
{ "fecdesde": "2024-01-01", "fechasta": "2024-01-31" }

---

## Caso de Uso 3: Validación de Fechas Inválidas

**Descripción:** El usuario intenta consultar el reporte sin seleccionar fechas.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Ingreso Zonificado.
2. Deja los campos de fecha vacíos.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que las fechas son requeridas.

**Datos de prueba:**
{ "fecdesde": "", "fechasta": "" }

---



## Casos de Prueba

# Casos de Prueba: Ingreso Zonificado

## Caso 1: Consulta exitosa
- **Input**: { "action": "getIngresoZonificado", "params": { "fecdesde": "2024-01-01", "fechasta": "2024-01-31" } }
- **Resultado esperado**: HTTP 200, success=true, data es un array de zonas con campos id_zona, zona, pagado, message vacío.

## Caso 2: Fechas inválidas
- **Input**: { "action": "getIngresoZonificado", "params": { "fecdesde": "", "fechasta": "" } }
- **Resultado esperado**: HTTP 200, success=false, data=null, message contiene 'Fechas requeridas'.

## Caso 3: Exportar PDF
- **Input**: { "action": "exportIngresoZonificadoPDF", "params": { "fecdesde": "2024-01-01", "fechasta": "2024-01-31" } }
- **Resultado esperado**: HTTP 200, success=true, data.url contiene la URL del PDF generado.

## Caso 4: Acción no soportada
- **Input**: { "action": "accionInexistente", "params": {} }
- **Resultado esperado**: HTTP 200, success=false, message='Acción no soportada'.

## Caso 5: Seguridad
- **Input**: Sin autenticación
- **Resultado esperado**: HTTP 401 Unauthorized.



