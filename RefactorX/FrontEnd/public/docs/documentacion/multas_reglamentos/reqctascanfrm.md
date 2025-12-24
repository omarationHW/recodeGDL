# Documentación: reqctascanfrm

## Análisis Técnico

# Documentación Técnica: Migración Formulario reqctascanfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde al formulario "Listado de folios de requerimiento de cuentas canceladas" (reqctascanfrm) migrado desde Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel API con endpoint unificado `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js como página independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica SQL migrada a stored procedures.

## 3. Flujo de la Aplicación
1. El usuario accede a la página del formulario.
2. Selecciona una recaudadora y un rango de fechas.
3. Al hacer clic en "Imprimir", se consulta la API para obtener las cuentas canceladas y, para cada una, los folios asociados.
4. Los resultados se muestran en una tabla, agrupando folios por cuenta.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "eRequest": "reqctascanfrm.get_cancelled_accounts",
    "params": {
      "recaud": 1,
      "fini": "2024-01-01",
      "ffin": "2024-01-31"
    }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## 5. Stored Procedures
- **report_reqctascanfrm:** Devuelve las cuentas canceladas para una recaudadora y rango de fechas.
- **report_reqctascanfrm_folios:** Devuelve los folios vigentes y no cancelados para una cuenta.

## 6. Seguridad
- Validación de parámetros en el backend.
- Manejo de errores y mensajes claros en la respuesta.

## 7. Frontend
- Página Vue.js independiente.
- Validación de campos obligatorios.
- Consulta asincrónica de datos y despliegue en tabla.
- Breadcrumb para navegación.

## 8. Consideraciones
- Las recaudadoras están fijas (4 zonas), pero pueden obtenerse por API para futura escalabilidad.
- El reporte es visualizado en pantalla, pero puede adaptarse para exportar a PDF/Excel si se requiere.

## 9. Extensibilidad
- El endpoint `/api/execute` puede manejar otros formularios y operaciones agregando nuevos valores de `eRequest`.

## 10. Dependencias
- Laravel >= 8.x
- Vue.js >= 2.x o 3.x
- PostgreSQL >= 11

## 11. Instalación de Stored Procedures
Ejecutar los scripts SQL proporcionados en la base de datos destino.

## 12. Pruebas
Ver sección de casos de uso y casos de prueba.

## Casos de Uso

# Casos de Uso - reqctascanfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de cuentas canceladas en Zona Centro para un rango de fechas

**Descripción:** El usuario desea obtener el listado de cuentas canceladas en la recaudadora 'Zona Centro' entre el 1 y el 31 de enero de 2024.

**Precondiciones:**
Existen cuentas canceladas en la base de datos para la recaudadora 1 (Zona Centro) en el rango de fechas especificado.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de folios de requerimiento de cuentas canceladas'.
2. Selecciona 'Zona Centro' como recaudadora.
3. Ingresa '2024-01-01' como fecha inicial y '2024-01-31' como fecha final.
4. Hace clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las cuentas canceladas en ese rango, cada una con sus folios vigentes.

**Datos de prueba:**
recaud: 1, fini: '2024-01-01', ffin: '2024-01-31'

---

## Caso de Uso 2: Validación de campos obligatorios

**Descripción:** El usuario intenta consultar sin seleccionar recaudadora o sin ingresar fechas.

**Precondiciones:**
El usuario accede al formulario.

**Pasos a seguir:**
1. El usuario deja la recaudadora sin seleccionar y/o deja vacías las fechas.
2. Hace clic en 'Imprimir'.

**Resultado esperado:**
El sistema muestra mensajes de error indicando los campos obligatorios.

**Datos de prueba:**
recaud: '', fini: '', ffin: ''

---

## Caso de Uso 3: Consulta de folios para una cuenta específica

**Descripción:** El sistema debe mostrar los folios vigentes y no cancelados para una cuenta seleccionada.

**Precondiciones:**
Existe una cuenta con cvecuenta=12345 y folios vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario realiza una consulta general.
2. El sistema, para cada cuenta, consulta los folios usando el stored procedure correspondiente.

**Resultado esperado:**
En la tabla de resultados, la columna 'Folios' muestra los folios vigentes para la cuenta 12345.

**Datos de prueba:**
cvecuenta: 12345

---

## Casos de Prueba

## Casos de Prueba para reqctascanfrm

### Caso 1: Consulta exitosa de cuentas canceladas
- **Entrada:**
  - recaud: 2
  - fini: '2024-02-01'
  - ffin: '2024-02-28'
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_cancelled_accounts' y los parámetros anteriores.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con campos cvecuenta, recaud, cuenta, cuenta_utm.

### Caso 2: Validación de recaudadora no seleccionada
- **Entrada:**
  - recaud: ''
  - fini: '2024-01-01'
  - ffin: '2024-01-31'
- **Acción:**
  - Enviar petición a /api/execute sin recaudadora.
- **Resultado esperado:**
  - eResponse.success = false
  - eResponse.message contiene 'Parámetros requeridos'

### Caso 3: Consulta de folios para cuenta sin folios vigentes
- **Entrada:**
  - cvecuenta: 99999 (sin folios vigentes)
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_folios_by_cvecuenta'.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío

### Caso 4: Consulta de folios para cuenta con folios vigentes
- **Entrada:**
  - cvecuenta: 12345 (con folios vigentes)
- **Acción:**
  - Enviar petición a /api/execute con eRequest 'reqctascanfrm.get_folios_by_cvecuenta'.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un objeto con campo folioreq

### Caso 5: Fechas fuera de rango
- **Entrada:**
  - recaud: 1
  - fini: '1900-01-01'
  - ffin: '1900-01-31'
- **Acción:**
  - Enviar petición a /api/execute con fechas donde no existen datos.
- **Resultado esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

