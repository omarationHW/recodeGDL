# RptEstadPagosyAdeudos

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: Estadística de Pagos y Adeudos de Mercados

## Descripción General
Este módulo permite consultar la estadística de pagos, capturas y adeudos de los mercados municipales, agrupados por recaudadora y mercado, para un periodo y rango de fechas determinado. Incluye:
- Backend en Laravel (API RESTful, endpoint unificado)
- Frontend en Vue.js (página independiente)
- Lógica de negocio y reportes en stored procedures PostgreSQL
- Comunicación vía eRequest/eResponse con endpoint único `/api/execute`

## Arquitectura
- **Backend:** Laravel Controller con endpoint `/api/execute` que recibe un objeto JSON con los campos `action` y `params`.
- **Frontend:** Componente Vue.js que implementa la UI y consume el endpoint vía Axios.
- **Base de Datos:** PostgreSQL, lógica de reportes encapsulada en stored procedures.

## Flujo de Datos
1. El usuario accede a la página de "Estadística de Pagos y Adeudos".
2. Selecciona recaudadora, mercado, año, mes y rango de fechas.
3. El frontend envía un POST a `/api/execute` con la acción y parámetros.
4. El backend ejecuta el stored procedure correspondiente y retorna los datos en formato JSON.
5. El frontend muestra la tabla resumen.

## API eRequest/eResponse
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "action": "getEstadisticaPagosyAdeudos",
    "params": {
      "id_rec": 1,
      "axo": 2024,
      "mes": 6,
      "fec3": "2024-06-01",
      "fec4": "2024-06-30"
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [ ... ],
    "message": ""
  }
  ```

## Stored Procedures
- **sp_estad_pagosyadeudos:** Devuelve la estadística detallada por mercado.
- **sp_estad_pagosyadeudos_resumen:** Devuelve el resumen global por tipo (pagados, capturados, adeudos).

## Seguridad
- El endpoint debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar y sanitizar todos los parámetros recibidos.

## Consideraciones de Migración
- Todas las consultas SQL y lógica de agregación se trasladan a stored procedures.
- El frontend no debe tener lógica de negocio, solo presentación y validación básica.
- El backend solo expone el endpoint unificado y delega la lógica a los SP.

## Extensibilidad
- Se pueden agregar nuevas acciones al endpoint `/api/execute` para otros reportes o catálogos.
- El frontend puede ser extendido para exportar a Excel o PDF usando bibliotecas JS.

## Estructura de Carpetas
- `app/Http/Controllers/EstadPagosyAdeudosController.php`
- `resources/js/pages/EstadPagosyAdeudosPage.vue`
- `database/migrations/` y `database/procedures/` para los SP

#


## Casos de Uso

# Casos de Uso - RptEstadPagosyAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística de Pagos y Adeudos por Mercado

**Descripción:** El usuario desea obtener la estadística de pagos, capturas y adeudos de todos los mercados de la recaudadora Centro para el mes de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona 'Centro' como recaudadora.
3. Selecciona el año 2024 y mes 6.
4. Selecciona el rango de fechas del 2024-06-01 al 2024-06-30.
5. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los mercados de la recaudadora Centro y sus totales de pagos, capturas y adeudos.

**Datos de prueba:**
{ "id_rec": 1, "axo": 2024, "mes": 6, "fec3": "2024-06-01", "fec4": "2024-06-30" }

---

## Caso de Uso 2: Resumen Global de Pagos y Adeudos

**Descripción:** El usuario requiere un resumen global de pagos, capturas y adeudos para la recaudadora Olímpica en mayo de 2024.

**Precondiciones:**
El usuario tiene acceso y existen datos para la recaudadora Olímpica.

**Pasos a seguir:**
1. Accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona 'Olímpica' como recaudadora.
3. Selecciona año 2024, mes 5.
4. Selecciona fechas del 2024-05-01 al 2024-05-31.
5. Solicita el resumen global.

**Resultado esperado:**
Se muestra el resumen de locales, importes y periodos para pagos, capturas y adeudos.

**Datos de prueba:**
{ "id_rec": 2, "axo": 2024, "mes": 5, "fec3": "2024-05-01", "fec4": "2024-05-31" }

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar la estadística sin seleccionar recaudadora.

**Precondiciones:**
El usuario está autenticado pero no selecciona recaudadora.

**Pasos a seguir:**
1. Accede a la página.
2. Deja el campo recaudadora vacío.
3. Intenta consultar.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
{ "id_rec": null, "axo": 2024, "mes": 6, "fec3": "2024-06-01", "fec4": "2024-06-30" }

---



## Casos de Prueba

## Casos de Prueba para Estadística de Pagos y Adeudos

### Caso 1: Consulta exitosa de estadística por mercado
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: 1, axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: true
  - data: Array con al menos un mercado, campos localpag, pagospag, periodospag, etc.

### Caso 2: Resumen global correcto
- **Entrada:**
  - action: getResumenPorMercado
  - params: { id_rec: 2, axo: 2024, mes: 5, fec3: '2024-05-01', fec4: '2024-05-31' }
- **Esperado:**
  - success: true
  - data: Array con 3 filas (Pagados, Capturados, Adeudos), campos locales, importe, periodos.

### Caso 3: Parámetro obligatorio faltante
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: null, axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: false
  - message: 'Acción no soportada' o mensaje de validación.

### Caso 4: Fechas fuera de rango
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: 1, axo: 2024, mes: 6, fec3: '2025-01-01', fec4: '2025-01-31' }
- **Esperado:**
  - success: true
  - data: Array vacío

### Caso 5: SQL Injection attempt
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: "1; DROP TABLE ta_11_locales; --", axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: false
  - message: Error de validación o excepción controlada



