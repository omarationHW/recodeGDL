# Documentación Técnica: Notificaciones por Mes

## Descripción General
Este módulo permite consultar y exportar un reporte estadístico de notificaciones emitidas, practicadas, canceladas y pagadas por mes, agrupadas por módulo y ejecutor, en un rango de años y fechas de pago.

## Arquitectura
- **Backend:** Laravel Controller (NotificacionesMesController) expone un endpoint unificado `/api/execute` que recibe acciones tipo eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y exportación a Excel.
- **Base de Datos:** Toda la lógica de agregación se realiza en un stored procedure PostgreSQL (`spd_15_notif_mes`).

## Flujo de Datos
1. El usuario ingresa los parámetros (año de practicado, año de emisión, fecha de pago desde/hasta) y consulta.
2. El frontend envía un POST a `/api/execute` con `{ action: 'getNotificacionesMes', params: { ... } }`.
3. El backend ejecuta el stored procedure y retorna los datos agregados.
4. El usuario puede exportar los resultados a Excel (CSV) desde el frontend.

## API
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "action": "getNotificacionesMes",
    "params": {
      "axo_pract": 2024,
      "axo_emi": 2024,
      "fecha_desde": "2024-01-01",
      "fecha_hasta": "2024-12-31"
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [
      {
        "modulo": "11",
        "mes": 1,
        "axo": 2024,
        "ejecutor": 123,
        "asignados": 10,
        "practicados": 8,
        "cancelados": 1,
        "pagados": 5,
        "recaudado": 15000.00
      },
      ...
    ]
  }
  ```

## Stored Procedure
- **Nombre:** `spd_15_notif_mes`
- **Parámetros:**
  - `p_axo_pract` (INTEGER): Año de practicado
  - `p_axo_emi` (INTEGER): Año de emisión
  - `p_fecha_desde` (DATE): Fecha de pago desde
  - `p_fecha_hasta` (DATE): Fecha de pago hasta
- **Retorna:** Tabla con columnas: modulo, mes, axo, ejecutor, asignados, practicados, cancelados, pagados, recaudado

## Validaciones
- Todos los campos son obligatorios y deben tener formato correcto.
- El rango de fechas debe ser válido.

## Seguridad
- El endpoint debe estar protegido por autenticación (middleware Laravel).
- El stored procedure no permite SQL injection (parámetros tipados).

## Exportación a Excel
- El frontend genera un archivo CSV con los datos mostrados.
- No se realiza exportación en backend.

## Consideraciones
- El frontend es una página independiente, no usa tabs ni comparte estado con otros formularios.
- El backend puede ser extendido para otros reportes usando el mismo patrón eRequest/eResponse.
