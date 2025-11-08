# Documentación Técnica: Migración Formulario Multiplefecha (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario "Multiplefecha" permite consultar todos los pagos y títulos realizados en una fecha específica, filtrando por recaudadora y caja. El usuario puede ver el listado y consultar el detalle individual de cada registro.

## 2. Arquitectura
- **Backend:** Laravel (API RESTful, endpoint único `/api/execute`)
- **Frontend:** Vue.js (componente de página independiente)
- **Base de Datos:** PostgreSQL (toda la lógica SQL encapsulada en stored procedures)

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Cuerpo:**
  ```json
  {
    "action": "getPagosByFecha", // o "getPagoDetalle"
    "params": { ... }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 4. Stored Procedures
- **sp_multiple_fecha:** Devuelve todos los pagos y títulos de una fecha, recaudadora y caja.
- **sp_pago_detalle:** Devuelve el detalle individual de un registro por control_rcm.

## 5. Laravel Controller
- **Método principal:** `execute(Request $request)`
- **Acciones soportadas:**
  - `getPagosByFecha`: Llama a `sp_multiple_fecha`.
  - `getPagoDetalle`: Llama a `sp_pago_detalle`.
- **Validación:** Se valida la entrada antes de llamar a los SP.
- **Errores:** Se devuelven en el campo `message`.

## 6. Vue.js Component
- **Formulario de búsqueda:** Fecha, recaudadora, caja.
- **Tabla de resultados:** Muestra todos los campos relevantes.
- **Detalle individual:** Modal con información detallada.
- **UX:** Navegación breadcrumb, mensajes de error, loading spinner.

## 7. Seguridad
- **Validación de parámetros** en backend.
- **No expone SQL directo**; todo acceso es vía SP.
- **Autenticación:** Se recomienda JWT o session middleware (no incluido aquí).

## 8. Pruebas y Casos de Uso
- Ver sección de casos de uso y casos de prueba.

## 9. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- Los stored procedures pueden ser extendidos para incluir más lógica de negocio.

## 10. Notas de Migración
- El SP unifica la consulta de pagos y títulos, replicando la lógica del Delphi.
- El frontend es una página independiente, sin tabs ni componentes compartidos.
- El detalle individual se consulta bajo demanda.
