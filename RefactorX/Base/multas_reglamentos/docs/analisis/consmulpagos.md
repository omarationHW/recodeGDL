# Documentación Técnica: Consulta de Pagos de Multas (consmulpagos)

## Descripción General
Este módulo permite consultar, filtrar y visualizar los pagos realizados por concepto de multas municipales. Incluye:
- Listado general de pagos de multas
- Filtros por fecha, recaudadora, caja, folio, nombre y número de acta
- Visualización de detalle de cada pago
- Reporte agrupado por fecha

## Arquitectura
- **Backend:** Laravel Controller (ConsMulPagosController) con endpoint único `/api/execute` usando patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con tabla de resultados y modal de detalle.
- **Base de Datos:** PostgreSQL, lógica SQL en stored procedures.
- **API:** Todas las acciones (listar, filtrar, detalle, reporte) se ejecutan vía `/api/execute`.

## Endpoints
- **POST /api/execute**
  - Entrada: `{ eRequest: { action: 'list|filter|detail|report', params: { ... } } }`
  - Salida: `{ eResponse: { result: ..., error: ... } }`

## Stored Procedures
- `sp_list_pagos_multas()`: Lista todos los pagos de multas.
- `sp_filter_pagos_multas(...)`: Filtra pagos por criterios.
- `sp_detail_pago_multa(p_cvepago)`: Detalle de un pago específico.
- `sp_report_pagos_multas(p_fecha_ini, p_fecha_fin)`: Reporte agrupado por fecha.

## Seguridad
- Validación de parámetros en el backend.
- El endpoint puede protegerse con middleware de autenticación Laravel.

## Integración Vue.js
- El componente Vue hace peticiones POST a `/api/execute` con el objeto eRequest.
- Los resultados se muestran en una tabla, y el detalle en un modal.

## Consideraciones
- Cada formulario es una página independiente.
- No se usan tabs ni componentes tabulares.
- El frontend es completamente desacoplado del backend.

## Ejemplo de eRequest/eResponse
```json
{
  "eRequest": {
    "action": "filter",
    "params": {
      "fecha": "2024-06-01",
      "recaud": 1,
      "caja": "A"
    }
  }
}
```

Respuesta:
```json
{
  "eResponse": {
    "result": [ ... ],
    "error": null
  }
}
```

## Errores
- Si ocurre un error, el campo `error` en eResponse contendrá el mensaje.

## Extensibilidad
- Se pueden agregar más acciones (exportar, imprimir, etc.) usando el mismo patrón.

# Esquema de Base de Datos (relevante)
- **pagos**: cvepago, fecha, recaud, caja, folio, importe, cajero, cveconcepto
- **multas**: cvepago, contribuyente, domicilio, num_acta, axo_acta, id_dependencia, multa, calificacion, total, observacion

# Seguridad y Validación
- Validar que los parámetros sean del tipo correcto.
- El endpoint puede protegerse con autenticación Laravel.

# Pruebas
- Ver sección de casos de uso y casos de prueba.
