# RptEmisionLaser

## AnÃ¡lisis TÃ©cnico

# Documentación Técnica: RptEmisionLaser (Laravel + Vue.js + PostgreSQL)

## Descripción General
Este módulo corresponde a la migración del formulario Delphi `RptEmisionLaser` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos y lógica de negocio en stored procedures). El objetivo es permitir la emisión de reportes de adeudos de locales de mercados municipales, con cálculo de rentas, recargos, requerimientos y generación de reportes detallados.

## Arquitectura
- **Backend:** Laravel 10+, API RESTful, endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Vue.js 2/3 SPA, cada formulario es una página independiente, sin tabs.
- **Base de Datos:** PostgreSQL 13+, lógica de negocio en stored procedures.

## Flujo de Datos
1. El usuario accede a la página de emisión laser y selecciona los filtros (oficina, año, periodo, mercado).
2. El frontend envía una petición POST a `/api/execute` con el objeto `eRequest` especificando la acción y los parámetros.
3. El backend (Laravel) recibe la petición, despacha la acción al stored procedure correspondiente y retorna la respuesta en `eResponse`.
4. El frontend muestra los resultados y permite ver detalles de cada local (pagos, meses de adeudo, requerimientos).

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "getReport", // o cualquier acción soportada
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ... }
  }
  ```

## Acciones Soportadas
- `getReport`: Obtiene el reporte principal de emisión laser.
- `getLocales`: Lista de locales filtrados.
- `getPagos`: Pagos de un local.
- `getMesAdeudo`: Meses de adeudo de un local.
- `getRequerimientos`: Requerimientos de un local.
- `getRecargos`: Recargos de un año y mes.
- `getFecDes`: Fecha de descuento de un mes.
- `getSubT`: Subtotal de adeudo y recargos de un local.

## Seguridad
- Autenticación JWT o session-based (no incluida en este ejemplo, pero debe implementarse en producción).
- Validación de parámetros en backend.
- Manejo de errores y logging.

## Consideraciones de Migración
- Toda la lógica de negocio y cálculos SQL se migran a stored procedures PostgreSQL.
- El frontend Vue.js es desacoplado y consume la API vía Axios.
- El endpoint es único y flexible para facilitar integración y pruebas.

## Estructura de la Base de Datos
- Tablas principales: `ta_11_locales`, `ta_11_mercados`, `ta_11_cuo_locales`, `ta_11_adeudo_local`, `ta_11_pagos_local`, `ta_12_recargos`, `ta_15_apremios`, `ta_11_fecha_desc`.
- Los SPs devuelven datos en formato tabular para fácil consumo por el frontend.

## Extensibilidad
- Se pueden agregar nuevas acciones y stored procedures sin modificar el endpoint.
- El frontend puede consumir cualquier acción soportada por el backend.

# Notas
- El frontend debe manejar la paginación y filtrado si el volumen de datos es grande.
- Los cálculos de renta y recargos pueden ajustarse en los SPs o en el frontend según necesidades.



## Casos de Uso

# Casos de Uso - RptEmisionLaser

**Categoría:** Form

## Caso de Uso 1: Generar reporte de emisión laser para un mercado específico

**Descripción:** El usuario desea obtener el reporte de adeudos de locales para la oficina 2, año 2024, periodo 6 (junio), mercado 3.

**Precondiciones:**
El usuario tiene permisos de consulta y existen datos de adeudos para los parámetros seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de emisión laser.
2. Selecciona Oficina: 2, Año: 2024, Periodo: 6, Mercado: 3.
3. Hace clic en 'Generar Reporte'.
4. El sistema consulta el backend y muestra la tabla de locales con adeudo.

**Resultado esperado:**
Se muestra una tabla con los locales adeudores, sus rentas, recargos, subtotal y meses de adeudo.

**Datos de prueba:**
{ "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 3 }

---

## Caso de Uso 2: Consultar detalle de pagos y requerimientos de un local

**Descripción:** El usuario desea ver el detalle de pagos, meses de adeudo y requerimientos de un local específico desde el reporte.

**Precondiciones:**
El reporte de emisión laser ya fue generado y el local tiene pagos y requerimientos registrados.

**Pasos a seguir:**
1. El usuario hace clic en 'Detalle' en la fila del local deseado.
2. El sistema consulta los pagos, meses de adeudo y requerimientos vía API.
3. Se muestra un modal con la información detallada.

**Resultado esperado:**
El usuario visualiza los pagos realizados, los meses de adeudo y los requerimientos asociados al local.

**Datos de prueba:**
{ "id_local": 123, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Obtener fecha de descuento para un mes

**Descripción:** El usuario necesita saber la fecha límite de descuento para el mes de junio.

**Precondiciones:**
La tabla de fechas de descuento está actualizada.

**Pasos a seguir:**
1. El frontend solicita la fecha de descuento para el mes 6 vía API.
2. El backend retorna la fecha correspondiente.

**Resultado esperado:**
Se muestra la fecha de descuento y la fecha de recargos para el mes solicitado.

**Datos de prueba:**
{ "mes": 6 }

---



## Casos de Prueba

# Casos de Prueba: RptEmisionLaser

## Caso 1: Generar reporte con datos válidos
- **Entrada:** { "eRequest": { "action": "getReport", "params": { "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 3 } } }
- **Esperado:** eResponse.report contiene array de locales con campos id_local, nombre, descripcion_local, meses, rentaaxos, recargos, subtotal.

## Caso 2: Generar reporte con parámetros inexistentes
- **Entrada:** { "eRequest": { "action": "getReport", "params": { "oficina": 99, "axo": 2050, "periodo": 1, "mercado": 99 } } }
- **Esperado:** eResponse.report es array vacío o error indicando que no hay datos.

## Caso 3: Consultar pagos de un local existente
- **Entrada:** { "eRequest": { "action": "getPagos", "params": { "id_local": 123, "axo": 2024, "periodo": 6 } } }
- **Esperado:** eResponse.pagos contiene array de pagos con campos id_pago_local, fecha_pago, importe_pago, folio.

## Caso 4: Consultar meses de adeudo de un local
- **Entrada:** { "eRequest": { "action": "getMesAdeudo", "params": { "id_local": 123, "axo": 2024 } } }
- **Esperado:** eResponse.mes_adeudo contiene array de meses con campos id_adeudo_local, axo, periodo, importe.

## Caso 5: Consultar requerimientos de un local
- **Entrada:** { "eRequest": { "action": "getRequerimientos", "params": { "id_local": 123, "modulo": 11 } } }
- **Esperado:** eResponse.requerimientos contiene array de requerimientos con campos folio, importe_multa, importe_gastos.

## Caso 6: Obtener fecha de descuento
- **Entrada:** { "eRequest": { "action": "getFecDes", "params": { "mes": 6 } } }
- **Esperado:** eResponse.fec_des contiene array con campos fecha_descuento, fecha_recargos.

## Caso 7: Obtener subtotal de local
- **Entrada:** { "eRequest": { "action": "getSubT", "params": { "id_local": 123, "axo": 2024, "periodo": 6 } } }
- **Esperado:** eResponse.subtotal contiene array con campos adeudo, recargos, subtotalcalc.



