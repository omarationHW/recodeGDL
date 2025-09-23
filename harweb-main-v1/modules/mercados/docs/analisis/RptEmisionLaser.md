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

