# Documentación Técnica: RptAdeudoCorteManzanaSaldoAnt

## Descripción General
Este módulo corresponde al formulario de reporte de corte por manzana con saldo anterior para convenios de regularización de predios. Permite consultar, visualizar y exportar información agrupada por manzana, mostrando el saldo anterior, pagos realizados y saldo actual de cada predio.

## Arquitectura
- **Backend:** Laravel Controller expuesto en `/api/execute` usando el patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, independiente, sin tabs.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.
- **API:** Único endpoint `/api/execute` que recibe un objeto `eRequest` con acción y parámetros, y responde con `eResponse`.

## Flujo de Datos
1. El usuario accede a la página del reporte.
2. El frontend solicita los subtipos disponibles (por defecto tipo 14).
3. El usuario selecciona subtipo, fechas, estado y tipo de reporte.
4. Al consultar, el frontend envía un eRequest con acción `getReportData` y los parámetros.
5. El backend ejecuta el stored procedure `sp_rpt_adeudo_corte_manzana_saldo_ant` y retorna los datos.
6. El frontend muestra la tabla con los resultados.

## API Detalle
### Endpoint
`POST /api/execute`

#### Entrada (eRequest)
```json
{
  "eRequest": {
    "action": "getReportData",
    "params": {
      "subtipo": 1,
      "fechadsd": "2024-01-01",
      "fechahst": "2024-06-30",
      "rep": 2,
      "est": "A"
    }
  }
}
```

#### Salida (eResponse)
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "id_conv_predio": 123,
        "manzana": "MZ-01",
        "lote": 5,
        "letracomp": "BIS",
        ...
      }
    ]
  }
}
```

### Acciones Disponibles
- `getReportData`: Obtiene el reporte principal.
- `getSubtipos`: Lista los subtipos disponibles para tipo 14.
- `getSaldoAnterior`: Obtiene el saldo anterior de un predio.

## Stored Procedures
- `sp_rpt_adeudo_corte_manzana_saldo_ant`: Devuelve el reporte agrupado por manzana, con saldo anterior calculado.
- `sp_saldo_anterior_predio`: Devuelve el saldo anterior de un predio antes de una fecha dada.

## Validaciones
- Todos los parámetros son requeridos y validados en backend.
- Fechas deben ser válidas y en formato ISO.
- El subtipo debe existir en la tabla de subtipos.

## Seguridad
- El endpoint debe estar protegido por autenticación Laravel (middleware `auth:api`).
- Los parámetros son validados y sanitizados.

## Errores
- Si falta un parámetro, se retorna `success: false` y mensaje de error.
- Si ocurre un error de base de datos, se retorna el mensaje de excepción.

## Extensibilidad
- El endpoint y el patrón eRequest/eResponse permiten agregar nuevas acciones fácilmente.
- Los stored procedures pueden ser reutilizados por otros reportes.

## Exportación
- El frontend puede exportar la tabla a Excel usando bibliotecas JS (no incluido aquí).

# Esquema de Base de Datos (relevante)
- `ta_17_con_reg_pred`: Predios regularizados.
- `ta_17_conv_d_resto`: Detalle de convenios por predio.
- `ta_17_conv_pagos`: Pagos realizados.
- `ta_17_subtipo_conv`: Catálogo de subtipos.

# Seguridad y Buenas Prácticas
- Uso de stored procedures para evitar SQL injection.
- Validación estricta de parámetros en el backend.
- El frontend nunca expone lógica de negocio ni queries directos.

# Pruebas y Casos de Uso
Ver secciones correspondientes.
