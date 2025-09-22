# Casos de Prueba: Traslado de Pagos de Cementerio Sin Afectar Adeudos

## Caso 1: Traslado exitoso de pagos
- **Entradas:**
  - folio_de: 1001
  - folio_a: 2002
  - pagos_ids: [30001, 30002]
  - usuario_id: 5
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 1001, folio_a: 2002 } }
  2. POST /api/execute { action: 'trasladarPagos', data: { folio_de: 1001, folio_a: 2002, pagos_ids: [30001, 30002], usuario_id: 5 } }
- **Esperado:**
  - Respuesta success: true, message: 'Los registros se han trasladado'
  - Los pagos 30001 y 30002 ahora pertenecen al folio 2002
  - axo_pagado de ambos folios actualizado

## Caso 2: Folios iguales
- **Entradas:**
  - folio_de: 1001
  - folio_a: 1001
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 1001, folio_a: 1001 } }
- **Esperado:**
  - Respuesta success: false, message: 'Los folios no deben ser iguales.'

## Caso 3: Sin selección de pagos
- **Entradas:**
  - folio_de: 1001
  - folio_a: 2002
  - pagos_ids: []
  - usuario_id: 5
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 1001, folio_a: 2002 } }
  2. POST /api/execute { action: 'trasladarPagos', data: { folio_de: 1001, folio_a: 2002, pagos_ids: [], usuario_id: 5 } }
- **Esperado:**
  - Respuesta success: false, message: 'Datos incompletos para traslado.'

## Caso 4: Folio DE no existe
- **Entradas:**
  - folio_de: 9999
  - folio_a: 2002
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 9999, folio_a: 2002 } }
- **Esperado:**
  - Respuesta success: false, message: 'No se encuentra Folio DE TRASLADO.'

## Caso 5: Folio A no existe
- **Entradas:**
  - folio_de: 1001
  - folio_a: 8888
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 1001, folio_a: 8888 } }
- **Esperado:**
  - Respuesta success: false, message: 'No se encuentra Folio A TRASLADAR.'

## Caso 6: Folio DE sin pagos
- **Entradas:**
  - folio_de: 1003 (sin pagos)
  - folio_a: 2002
- **Pasos:**
  1. POST /api/execute { action: 'verificaFolios', data: { folio_de: 1003, folio_a: 2002 } }
- **Esperado:**
  - Respuesta success: false, message: 'No se encuentran pagos con ese registro.'
