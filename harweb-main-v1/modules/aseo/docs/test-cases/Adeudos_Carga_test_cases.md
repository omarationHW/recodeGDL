# Casos de Prueba: Carga de Adeudos

## Caso 1: Carga exitosa de adeudos
- **Entrada:** ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - Se insertan 12 pagos por contrato

## Caso 2: Ejercicio inválido
- **Entrada:** ejercicio=1999, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 422
  - eResponse.success = false
  - Mensaje de error sobre el ejercicio

## Caso 3: Usuario no autenticado
- **Entrada:** ejercicio=2024, usuario_id=null
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Esperado:**
  - Código HTTP 422
  - eResponse.success = false
  - Mensaje de error sobre usuario_id

## Caso 4: Pagos ya existen para algunos contratos
- **Entrada:** ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute con eRequest.action='carga_adeudos'
- **Precondición:** Algunos pagos ya existen en ta_16_pagos
- **Esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - Solo se insertan los pagos faltantes

## Caso 5: Acción no soportada
- **Entrada:** action='otro_proceso', ejercicio=2024, usuario_id=23
- **Acción:** POST /api/execute
- **Esperado:**
  - Código HTTP 400
  - eResponse.success = false
  - Mensaje de acción no soportada
