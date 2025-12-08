# Documentación Técnica: ZonaLicencia

## Análisis Técnico
# Documentación Técnica: Migración Formulario ZonaLicencia (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la actualización de la zona, subzona y recaudadora asociada a una licencia municipal. El formulario original en Delphi ha sido migrado a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos), utilizando un endpoint API unificado y stored procedures para la lógica de negocio.

## 2. Arquitectura
- **Backend:** Laravel 10+, con un único endpoint `/api/execute` que recibe peticiones eRequest/eResponse.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente (no tabs).
- **Base de datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": ...
  }
  ```

### Acciones soportadas
- `get_zonas`: Listado de zonas para una recaudadora
- `get_subzonas`: Listado de subzonas para una zona y recaudadora
- `get_recaudadoras`: Listado de recaudadoras
- `get_licencia`: Datos de una licencia
- `get_licencias_zona`: Zona/subzona/recaudadora de una licencia
- `save_licencias_zona`: Guardar/actualizar zona/subzona/recaudadora de una licencia

## 4. Stored Procedures
Toda la lógica de consulta y actualización se implementa en funciones PL/pgSQL, ver sección `stored_procedures`.

## 5. Seguridad
- El endpoint requiere autenticación JWT (o similar).
- El usuario autenticado se utiliza como `capturista` en los cambios.
- Validación de parámetros en backend y frontend.

## 6. Frontend (Vue.js)
- Página independiente `/zona-licencia`.
- Formulario con campos: Licencia, Zona, Subzona, Recaudadora.
- Al ingresar la licencia, se cargan los datos actuales y se precargan los valores de zona/subzona/recaudadora si existen.
- Al guardar, se llama a la acción `save_licencias_zona`.
- Mensajes de éxito/error y validación de campos.

## 7. Backend (Laravel)
- Controlador único `ZonaLicenciaController`.
- Métodos para cada acción, usando DB::select/insert/update.
- Uso de transacciones y manejo de errores.

## 8. Base de Datos
- Tablas involucradas: `licencias`, `licencias_zona`, `c_zonas`, `c_subzonas`, `c_recaud`, `c_zonayrec`.
- Índices en campos clave.

## 9. Pruebas y Casos de Uso
Ver secciones `use_cases` y `test_cases`.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ser versionados y auditados.

## 11. Consideraciones
- El frontend puede ser adaptado a cualquier framework SPA.
- El backend puede ser extendido para auditoría, logging, y control de permisos.

## Casos de Prueba
## Casos de Prueba para ZonaLicencia

### 1. Consulta de Zona/Subzona/Recaudadora
- **Entrada:** licencia = 123456
- **Acción:** POST /api/execute { action: 'get_licencias_zona', params: { licencia: 123456 } }
- **Esperado:** Respuesta con los campos zona, subzona, recaud actuales.

### 2. Actualización Exitosa
- **Entrada:** licencia = 123456, zona = 2, subzona = 5, recaud = 3
- **Acción:** POST /api/execute { action: 'save_licencias_zona', params: { licencia: 123456, zona: 2, subzona: 5, recaud: 3 }
- **Esperado:** success: true, los datos quedan actualizados en la tabla licencias_zona.

### 3. Validación de Campos Vacíos
- **Entrada:** licencia = 123456, zona = '', subzona = '', recaud = ''
- **Acción:** POST /api/execute { action: 'save_licencias_zona', params: { licencia: 123456, zona: '', subzona: '', recaud: '' }
- **Esperado:** success: false, error: 'Todos los campos son obligatorios' (en frontend), no se realiza ningún cambio en la base de datos.

### 4. Licencia No Encontrada
- **Entrada:** licencia = 999999
- **Acción:** POST /api/execute { action: 'get_licencia', params: { licencia: 999999 } }
- **Esperado:** success: true, data: null

### 5. Listado de Zonas para Recaudadora
- **Entrada:** recaud = 2
- **Acción:** POST /api/execute { action: 'get_zonas', params: { recaud: 2 } }
- **Esperado:** success: true, data: [ ...zonas... ]

### 6. Listado de Subzonas para Zona y Recaudadora
- **Entrada:** cvezona = 2, recaud = 2
- **Acción:** POST /api/execute { action: 'get_subzonas', params: { cvezona: 2, recaud: 2 } }
- **Esperado:** success: true, data: [ ...subzonas... ]

## Casos de Uso
# Casos de Uso - ZonaLicencia

**Categoría:** Form

## Caso de Uso 1: Consulta de Zona/Subzona/Recaudadora de una Licencia

**Descripción:** El usuario desea consultar la zona, subzona y recaudadora asociada a una licencia específica.

**Precondiciones:**
El usuario está autenticado y conoce el número de licencia.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia en el campo correspondiente.
3. El sistema consulta los datos de la licencia y su zona/subzona/recaudadora actual.
4. El sistema muestra los datos en pantalla.

**Resultado esperado:**
Se muestran los datos actuales de zona, subzona y recaudadora de la licencia.

**Datos de prueba:**
{ "licencia": 123456 }

---

## Caso de Uso 2: Actualización de Zona/Subzona/Recaudadora

**Descripción:** El usuario desea actualizar la zona, subzona y recaudadora de una licencia.

**Precondiciones:**
El usuario está autenticado y tiene permisos de edición.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia y espera a que se carguen los datos.
3. Selecciona una nueva recaudadora, zona y subzona de los combos.
4. Presiona el botón Guardar.
5. El sistema guarda los cambios y muestra mensaje de éxito.

**Resultado esperado:**
La zona, subzona y recaudadora quedan actualizadas en la base de datos.

**Datos de prueba:**
{ "licencia": 123456, "zona": 2, "subzona": 5, "recaud": 3 }

---

## Caso de Uso 3: Validación de Campos Obligatorios

**Descripción:** El usuario intenta guardar sin seleccionar todos los campos requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de Zona de Licencia.
2. Ingresa el número de licencia.
3. No selecciona zona, subzona o recaudadora.
4. Presiona Guardar.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que todos los campos son obligatorios.

**Datos de prueba:**
{ "licencia": 123456, "zona": "", "subzona": "", "recaud": "" }

---
