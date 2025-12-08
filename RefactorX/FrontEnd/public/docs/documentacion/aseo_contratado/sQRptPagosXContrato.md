# Documentación Técnica: sQRptPagosXContrato

## Análisis

# Documentación Técnica: Migración de Formulario sQRptPagosXContrato

## 1. Descripción General
Este desarrollo migra el formulario de reporte de pagos por contrato (sQRptPagosXContrato) de Delphi a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend SPA) y PostgreSQL (base de datos y lógica de negocio).

## 2. Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica de reporte encapsulada en stored procedure.

## 3. Flujo de Datos
1. El usuario accede a la página "Pagos por Contrato".
2. Ingresa los parámetros requeridos (control_contrato, contrato, ctrol_aseo) y envía la consulta.
3. El frontend realiza un POST a `/api/execute` con `eRequest: getPagosPorContrato` y los parámetros.
4. El backend ejecuta el stored procedure `rpt_pagos_por_contrato` y retorna los datos y sumatorias.
5. El frontend muestra la tabla de resultados y los totales agrupados.

## 4. Endpoint API
- **URL:** `/api/execute`
- **Método:** POST
- **Body:**
```json
{
  "eRequest": "getPagosPorContrato",
  "params": {
    "control": 123,
    "contrato": 123,
    "ctrol_aseo": 4
  }
}
```
- **Respuesta:**
```json
{
  "eResponse": "success",
  "data": [ ... ],
  "summary": { ... },
  "contrato": 123,
  "aseo_label": "HOSPITALARIO"
}
```

## 5. Stored Procedure
- **Nombre:** `rpt_pagos_por_contrato`
- **Entradas:**
  - `p_control_contrato` (integer)
  - `p_contrato` (integer, solo para referencia en frontend)
  - `p_ctrol_aseo` (integer, solo para referencia en frontend)
- **Salida:** Tabla con los campos requeridos para el reporte.
- **Lógica:**
  - Filtra por `control_contrato` y `status_vigencia = 'P'`.
  - Une con operaciones y recaudadoras.
  - Ordena por contrato, periodo y operación.

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para parámetros.
- Tabla de resultados y sumatorias.
- Breadcrumb de navegación.
- Manejo de errores y estados de carga.

## 7. Resumen de Sumatorias
- Total de registros y total de importe.
- Totales por tipo de adeudo: CUOTA NORMAL, EXCEDENTE, CONTENEDORES.
- Etiqueta de tipo de aseo según parámetro.

## 8. Seguridad
- Validación de parámetros en backend.
- El stored procedure solo retorna datos permitidos.

## 9. Pruebas
- Casos de uso y escenarios de prueba incluidos en este documento.

## 10. Extensibilidad
- El endpoint `/api/execute` permite agregar nuevos eRequest fácilmente.
- El frontend puede extenderse para otros reportes siguiendo el mismo patrón.


## Casos de Uso

# Casos de Uso - sQRptPagosXContrato

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por contrato hospitalario

**Descripción:** El usuario desea consultar todos los pagos realizados para un contrato específico con tipo de aseo hospitalario.

**Precondiciones:**
El contrato con control_contrato = 1001 existe y tiene pagos registrados con status_vigencia = 'P'.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '1001' en Control Contrato.
3. Ingresa '1001' en Contrato.
4. Selecciona 'HOSPITALARIO' (ctrol_aseo = 4).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los pagos realizados para el contrato 1001, sumatorias correctas y la etiqueta 'HOSPITALARIO'.

**Datos de prueba:**
{ "control": 1001, "contrato": 1001, "ctrol_aseo": 4 }

---

## Caso de Uso 2: Consulta de pagos por contrato ordinario sin resultados

**Descripción:** El usuario consulta un contrato que no tiene pagos registrados.

**Precondiciones:**
El contrato con control_contrato = 9999 no tiene pagos con status_vigencia = 'P'.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '9999' en Control Contrato.
3. Ingresa '9999' en Contrato.
4. Selecciona 'ORDINARIO' (ctrol_aseo = 8).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
{ "control": 9999, "contrato": 9999, "ctrol_aseo": 8 }

---

## Caso de Uso 3: Consulta de pagos por contrato zona centro con varios tipos de adeudo

**Descripción:** El usuario consulta un contrato con pagos de diferentes tipos de adeudo (CUOTA NORMAL, EXCEDENTE, CONTENEDORES).

**Precondiciones:**
El contrato con control_contrato = 2002 tiene pagos de los tres tipos de adeudo.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos por Contrato'.
2. Ingresa '2002' en Control Contrato.
3. Ingresa '2002' en Contrato.
4. Selecciona 'ZONA CENTRO' (ctrol_aseo = 9).
5. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra la tabla con los pagos, y las sumatorias por tipo de adeudo reflejan correctamente los importes y cantidades.

**Datos de prueba:**
{ "control": 2002, "contrato": 2002, "ctrol_aseo": 9 }

---



## Casos de Prueba

# Casos de Prueba: Pagos por Contrato

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta exitosa con pagos hospitalarios | control: 1001, contrato: 1001, ctrol_aseo: 4 | Tabla con pagos, sumatorias correctas, etiqueta 'HOSPITALARIO' |
| 2 | Consulta sin resultados | control: 9999, contrato: 9999, ctrol_aseo: 8 | Mensaje 'No se encontraron registros' |
| 3 | Consulta con varios tipos de adeudo | control: 2002, contrato: 2002, ctrol_aseo: 9 | Tabla con pagos de CUOTA NORMAL, EXCEDENTE y CONTENEDORES, sumatorias correctas, etiqueta 'ZONA CENTRO' |
| 4 | Parámetros faltantes | control: null, contrato: 1001, ctrol_aseo: 4 | Error 422, mensaje de parámetros faltantes |
| 5 | Parámetro ctrol_aseo inválido | control: 1001, contrato: 1001, ctrol_aseo: 99 | Tabla vacía o etiqueta de aseo vacía |
| 6 | Consulta con contrato con pagos solo de un tipo | control: 3003, contrato: 3003, ctrol_aseo: 8 | Tabla con pagos solo de CUOTA NORMAL, sumatorias correctas |


