# Documentación Técnica: Ingreso Captura (Migración Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Descripción General
Este módulo permite consultar el resumen de pagos capturados por fecha de pago, caja y operación para un mercado y oficina específicos. La migración implementa un endpoint API unificado, un componente Vue.js de página completa y la lógica SQL encapsulada en un stored procedure de PostgreSQL.

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js independiente, sin tabs, con navegación breadcrumb.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "getIngresoCaptura",
    "params": {
      "num_mercado": 34,
      "fecha_pago": "2024-06-01",
      "oficina_pago": 2,
      "caja_pago": "A",
      "operacion_pago": 12345
    }
  }
  ```
- **Response:**
  ```json
  {
    "success": true,
    "data": [
      {
        "fecha_pago": "2024-06-01",
        "caja_pago": "A",
        "operacion_pago": 12345,
        "pagos": 3,
        "importe": 1500.00
      }
    ],
    "message": ""
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_get_ingreso_captura`
- **Parámetros:**
  - `p_num_mercado` (integer)
  - `p_fecha_pago` (date)
  - `p_oficina_pago` (integer)
  - `p_caja_pago` (varchar)
  - `p_operacion_pago` (integer)
- **Retorna:** Tabla con columnas: fecha_pago, caja_pago, operacion_pago, pagos, importe

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Formulario para filtros (mercado, fecha, oficina, caja, operación).
- Tabla de resultados.
- Breadcrumb de navegación.
- Mensajes de error y loading.

## 6. Backend (Laravel)
- Controlador único: `IngresoCapturaController`
- Método `execute` recibe el action y params, despacha al stored procedure correspondiente.
- Validación de parámetros.

## 7. Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según la política del sistema.

## 8. Extensibilidad
- El endpoint `/api/execute` puede despachar múltiples acciones (otros formularios) usando el mismo patrón.
- Los stored procedures pueden ampliarse para lógica adicional.

## 9. Consideraciones de Migración
- Los nombres de tablas y campos deben coincidir con la estructura PostgreSQL.
- El frontend asume que el backend retorna los datos en el formato esperado.

## 10. Ejemplo de Uso
Ver sección de Casos de Uso y Casos de Prueba.
