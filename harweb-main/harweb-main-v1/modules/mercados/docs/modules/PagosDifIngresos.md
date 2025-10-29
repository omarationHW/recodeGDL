# Documentación Técnica: Inconsistencias de Pagos (PagosDifIngresos)

## Descripción General
Este módulo permite consultar y exportar inconsistencias en los pagos registrados en el sistema de mercados municipales, específicamente:

- **Pagos con renta errónea**: Pagos cuyo importe no coincide con la renta esperada según la configuración del local.
- **Pagos con datos diferentes en ingresos**: Pagos donde la cuenta, caja o número de operación no corresponde con la configuración del mercado.

## Arquitectura
- **Backend**: Laravel (PHP) + PostgreSQL
- **Frontend**: Vue.js (SPA, página independiente)
- **API**: Endpoint único `/api/execute` usando patrón eRequest/eResponse
- **Base de Datos**: PostgreSQL, lógica principal en stored procedures

## Flujo de Datos
1. El usuario accede a la página de inconsistencias de pagos.
2. Selecciona la recaudadora y el rango de fechas.
3. Selecciona el tipo de inconsistencia a consultar (renta errónea o datos erróneos).
4. El frontend envía la petición a `/api/execute` con el action correspondiente.
5. El backend ejecuta el stored procedure adecuado y retorna los resultados.
6. El usuario puede exportar los resultados a Excel (CSV).

## API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "getPagosRentaErronea", // o "getPagosDiferentes"
      "params": {
        "rec": 1,
        "fpadsd": "2024-01-01",
        "fpahst": "2024-01-31"
      }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "message": ""
    }
  }
  ```

## Stored Procedures
- **spd_11_dif_pagos**: Devuelve pagos con datos diferentes en ingresos.
- **spd_11_dif_renta**: Devuelve pagos con renta errónea.

## Seguridad
- El endpoint requiere autenticación (middleware Laravel, si aplica).
- Los parámetros son validados en backend.

## Exportación
- El frontend genera el archivo CSV a partir de los datos recibidos.

## Consideraciones
- El frontend es una página independiente, sin tabs.
- El backend es desacoplado y solo expone el endpoint unificado.
- Los stored procedures pueden ser reutilizados por otros módulos.

# Estructura de la Página Vue
- Formulario de selección de recaudadora y fechas.
- Selección de tipo de inconsistencia.
- Tabla de resultados dinámica.
- Botón de exportar a Excel (CSV).

# Casos de Uso
Ver sección `use_cases`.

# Casos de Prueba
Ver sección `test_cases`.
