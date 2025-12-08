# Documentación Técnica: consLic400frm

## Análisis Técnico

# Documentación Técnica: Migración Formulario consLic400frm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este proyecto migra el formulario consLic400frm de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite consultar datos de licencias (lic_400) y sus pagos (pago_lic_400) mediante una interfaz web y un API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 2/3 SPA, rutas independientes para cada formulario.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de entrada:**
  ```json
  {
    "eRequest": "getLic400", // o "getPagoLic400"
    "params": { ... }
  }
  ```
- **Formato de salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- **get_lic_400(p_licencia INTEGER):** Devuelve los datos de la licencia.
- **get_pago_lic_400(p_numlic INTEGER):** Devuelve los pagos asociados a la licencia.

## 5. Frontend (Vue.js)
- **Página 1:** Consulta de datos de la licencia (`/lic400/datos`)
- **Página 2:** Consulta de pagos de la licencia (`/lic400/pagos`)
- Navegación entre páginas mediante router-link.
- Cada página es independiente y funcional por sí sola.

## 6. Backend (Laravel)
- **Controlador:** `Api\ExecuteController`
- **Métodos:**
  - `getLic400`: Llama a SP `get_lic_400`.
  - `getPagoLic400`: Llama a SP `get_pago_lic_400`.
- **Validación:** Parámetros requeridos, manejo de errores.

## 7. Seguridad
- Validación de parámetros en backend.
- No se exponen queries directas, sólo SP parametrizados.

## 8. Pruebas
- Casos de uso y escenarios de prueba detallados (ver más abajo).

## 9. Consideraciones
- El frontend asume uso de Axios y Vue Router.
- El backend asume conexión PostgreSQL configurada en `.env`.
- Los nombres de campos y tablas deben coincidir con la estructura original.

## 10. Extensibilidad
- El endpoint `/api/execute` puede ampliarse para otros formularios y operaciones siguiendo el patrón eRequest/eResponse.

## Casos de Prueba

## Casos de Prueba para consLic400frm Migrado

### Caso 1: Consulta exitosa de licencia
- **Entrada:**
  - eRequest: getLic400
  - params: { licencia: 12345 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene un objeto con todos los campos de lic_400

### Caso 2: Consulta exitosa de pagos
- **Entrada:**
  - eRequest: getPagoLic400
  - params: { numlic: 12345 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo con al menos un pago

### Caso 3: Consulta de licencia inexistente
- **Entrada:**
  - eRequest: getLic400
  - params: { licencia: 999999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
  - Frontend muestra mensaje 'No se encontró la licencia.'

### Caso 4: Consulta de pagos sin pagos registrados
- **Entrada:**
  - eRequest: getPagoLic400
  - params: { numlic: 88888 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
  - Frontend muestra mensaje 'No hay pagos registrados para esta licencia.'

### Caso 5: Parámetro faltante
- **Entrada:**
  - eRequest: getLic400
  - params: { }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica que falta el parámetro

### Caso 6: eRequest inválido
- **Entrada:**
  - eRequest: getLicenciaInexistente
  - params: { licencia: 12345 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Invalid eRequest'

## Casos de Uso

# Casos de Uso - consLic400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos de una licencia existente

**Descripción:** El usuario ingresa el número de una licencia válida y obtiene todos los datos asociados a esa licencia.

**Precondiciones:**
La licencia debe existir en la tabla lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de licencias (/lic400/datos).
2. Ingresa el número de licencia (por ejemplo, 12345) y presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con eRequest 'getLic400' y el parámetro 'licencia'.
4. El backend ejecuta el SP get_lic_400 y retorna los datos.
5. El frontend muestra los datos en la tabla.

**Resultado esperado:**
Se muestran todos los campos de la licencia consultada.

**Datos de prueba:**
licencia: 12345

---

## Caso de Uso 2: Consulta de pagos de una licencia existente

**Descripción:** El usuario consulta los pagos asociados a una licencia válida.

**Precondiciones:**
La licencia debe existir y tener pagos registrados en pago_lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de pagos (/lic400/pagos).
2. Ingresa el número de licencia (por ejemplo, 12345) y presiona 'Buscar Pagos'.
3. El sistema envía una petición POST a /api/execute con eRequest 'getPagoLic400' y el parámetro 'numlic'.
4. El backend ejecuta el SP get_pago_lic_400 y retorna los pagos.
5. El frontend muestra la tabla de pagos.

**Resultado esperado:**
Se muestran todos los pagos asociados a la licencia.

**Datos de prueba:**
numlic: 12345

---

## Caso de Uso 3: Consulta de licencia inexistente

**Descripción:** El usuario intenta consultar una licencia que no existe en la base de datos.

**Precondiciones:**
La licencia no debe existir en lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de licencias (/lic400/datos).
2. Ingresa un número de licencia inexistente (por ejemplo, 999999) y presiona 'Buscar'.
3. El sistema envía la petición al backend.
4. El backend retorna un arreglo vacío.
5. El frontend muestra un mensaje de 'No se encontró la licencia.'

**Resultado esperado:**
Se muestra un mensaje de error indicando que la licencia no existe.

**Datos de prueba:**
licencia: 999999

---
