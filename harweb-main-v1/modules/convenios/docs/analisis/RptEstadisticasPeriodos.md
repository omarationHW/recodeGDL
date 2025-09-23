# Documentación Técnica: Estadísticas de Periodos (RptEstadisticasPeriodos)

## Descripción General
Este módulo permite consultar y exportar estadísticas de adeudos mayores o iguales a un monto dado, agrupados por periodo de año de obra, plazo y año de firma. El reporte muestra totales por plazo y año, así como detalles de cada contrato si se requiere.

## Arquitectura
- **Backend**: Laravel Controller (API RESTful, endpoint único `/api/execute`)
- **Frontend**: Vue.js (componente de página independiente)
- **Base de Datos**: PostgreSQL (Stored Procedure `spd_17_est_periodo`)
- **API Pattern**: eRequest/eResponse

## Flujo de Datos
1. El usuario ingresa los parámetros (año de obra, adeudo mínimo, detalle).
2. El frontend envía un POST a `/api/execute` con `eRequest.action = getEstadisticasPeriodos` y los parámetros.
3. El backend ejecuta el stored procedure `spd_17_est_periodo` con los parámetros recibidos.
4. El resultado se retorna en `eResponse.data`.
5. El frontend muestra la tabla de resultados.
6. Para exportar, se usa `eRequest.action = exportEstadisticasPeriodos`.

## Parámetros de Entrada
- `axo` (integer): Año de obra a consultar (obligatorio)
- `adeudo` (float): Monto mínimo de adeudo (opcional, default 0)
- `opc` (integer): 1=Mostrar detalle, 2=Solo totales (default 1)

## Respuesta
- `success`: true/false
- `data`: array de objetos con los campos del reporte
- `message`: mensaje de error o éxito

## Stored Procedure: spd_17_est_periodo
- Recibe: año de obra, adeudo mínimo
- Devuelve: lista de contratos agrupados por plazo, año de firma, con totales y detalle

## Seguridad
- El endpoint `/api/execute` debe estar protegido por autenticación JWT o session según la política del sistema.
- Validar que el usuario tenga permisos para consultar reportes.

## Consideraciones
- El frontend no usa tabs ni subcomponentes: es una página completa.
- El backend puede ser extendido para paginación si el volumen de datos es alto.
- El export a Excel puede ser implementado con una librería como Laravel Excel o similar.

## Errores Comunes
- Si no se envía el año de obra, retorna error.
- Si la consulta no arroja resultados, retorna array vacío.

## Ejemplo de eRequest
```json
{
  "eRequest": {
    "action": "getEstadisticasPeriodos",
    "params": {
      "axo": 2024,
      "adeudo": 10000,
      "opc": 1
    }
  }
}
```

## Ejemplo de eResponse
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "plazo": 12,
        "cve_plazo": "M",
        "axo_obra": 2024,
        "axo_firma": 2024,
        "saldo_real": 15000.00,
        "desc_plazo": "MENSUAL",
        "num_cve_pzo": 2,
        "plazocorte": 122,
        "costo": 20000.00,
        "parc_pagos": 24,
        "estado": "VIGENTE",
        "colonia": 101,
        "calle": 5,
        "folio": 12345
      }
    ],
    "message": "Consulta exitosa."
  }
}
```

## Exportación
- El endpoint `exportEstadisticasPeriodos` retorna una URL de descarga o base64 del archivo Excel.

## Extensibilidad
- Se pueden agregar filtros adicionales (colonia, estado, etc.) en el stored procedure y el frontend.
- El endpoint puede ser reutilizado para otros reportes siguiendo el patrón eRequest/eResponse.
