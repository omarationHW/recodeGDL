# Documentación Técnica: formatosEcologiafrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario formatosEcologiafrm

## 1. Arquitectura General
- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de datos:** PostgreSQL, lógica encapsulada en stored procedures

## 2. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getTramiteById", // o getTramitesByFecha, getCruceCallesByTramite
    "params": { ... } // parámetros según el eRequest
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ],
      "error": null|string
    }
  }
  ```

## 3. Stored Procedures
- Toda la lógica SQL reside en funciones de PostgreSQL:
  - `sp_get_tramite_by_id(id_tramite)`
  - `sp_get_tramites_by_fecha(fecha)`
  - `sp_get_cruce_calles_by_tramite(id_tramite)`
- Los procedimientos devuelven tablas con los campos requeridos y los campos calculados (domcompleto, propietarionvo).

## 4. Laravel Controller
- Controlador `ExecuteController` maneja todas las solicitudes al endpoint `/api/execute`.
- Utiliza `DB::select` para invocar los stored procedures.
- El switch-case en el método `execute` determina qué procedimiento ejecutar según el valor de `eRequest`.
- Maneja errores y devuelve el formato eResponse.

## 5. Vue.js Component
- Página independiente, sin tabs, con navegación breadcrumb.
- Permite buscar por número de trámite o por fecha.
- Muestra resultados en tabla y permite ver detalle de cada trámite.
- Permite simular impresión de reporte (en producción, se integraría con generación de PDF).
- Carga cruce de calles al seleccionar un trámite.
- Maneja errores y estados de carga.

## 6. Seguridad
- Validación de parámetros en backend.
- Uso de funciones parametrizadas para evitar SQL Injection.
- El endpoint puede protegerse con middleware de autenticación según sea necesario.

## 7. Extensibilidad
- Para agregar nuevos formularios, basta con agregar nuevos eRequest y stored procedures.
- El frontend puede extenderse con nuevas páginas independientes.

## 8. Pruebas
- Casos de uso y escenarios de prueba incluidos para asegurar la funcionalidad.

## 9. Consideraciones
- La impresión real de reportes debe implementarse en backend (PDF, Jasper, etc.) y el frontend debe consumir el archivo generado.
- El componente Vue es completamente funcional y desacoplado de otros formularios.

## Casos de Prueba



## Casos de Uso

# Casos de Uso - formatosEcologiafrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite por número de trámite

**Descripción:** El usuario ingresa el número de trámite y obtiene el detalle completo, incluyendo propietario, ubicación, actividad y cruce de calles.

**Precondiciones:**
El trámite con el número ingresado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Verificación Técnica.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del trámite y permite ver el detalle y cruce de calles.

**Resultado esperado:**
Se muestra el detalle del trámite, incluyendo propietario, ubicación, actividad y cruce de calles.

**Datos de prueba:**
{ "tramiteId": 12345 }

---

## Caso de Uso 2: Consulta de trámites por fecha de captura

**Descripción:** El usuario selecciona una fecha y obtiene todos los trámites capturados en esa fecha.

**Precondiciones:**
Existen trámites capturados en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Verificación Técnica.
2. Selecciona una fecha en el campo de fecha.
3. El sistema muestra la lista de trámites capturados en esa fecha.

**Resultado esperado:**
Se muestra una tabla con todos los trámites de la fecha seleccionada.

**Datos de prueba:**
{ "fecha": "2024-06-01" }

---

## Caso de Uso 3: Impresión de reporte de verificación técnica

**Descripción:** El usuario selecciona un trámite y elige imprimir el reporte de verificación técnica o de certificado de anuencia.

**Precondiciones:**
El trámite está cargado y seleccionado.

**Pasos a seguir:**
1. El usuario busca y selecciona un trámite.
2. Elige el tipo de reporte a imprimir (verificación técnica o certificado de anuencia).
3. Presiona el botón 'Imprimir'.
4. El sistema simula la impresión del reporte.

**Resultado esperado:**
Se muestra un mensaje de confirmación de impresión del reporte seleccionado.

**Datos de prueba:**
{ "tramiteId": 12345, "tipoReporte": "verifTec" }

---
