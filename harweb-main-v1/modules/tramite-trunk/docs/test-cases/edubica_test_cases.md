# Casos de Prueba para Formulario Edubica

## Caso 1: Registro exitoso de nueva ubicación
- **Entrada:**
  - cvecuenta: 123456
  - cvecalle: 101
  - cvecolonia: 55
  - noexterior: "000123"
  - interior: "A"
  - obsinter: "Cambio por subdivisión"
  - axoefec: 2024
  - bimefec: 2
  - usuario: "jlopez"
  - catastro_asiento: 10
  - catastro_cvemov: 40
- **Acción:** POST /api/execute { action: 'saveUbicacion', params: ... }
- **Resultado esperado:**
  - success: true
  - message: "La edición ha sido registrada."
  - Se crea un nuevo registro en ubicacion (vigente 'V') y se actualiza catastro.

## Caso 2: Validación de campos obligatorios
- **Entrada:**
  - cvecuenta: 123456
  - cvecalle: 101
  - cvecolonia: 55
  - noexterior: ""
  - interior: ""
  - obsinter: ""
  - axoefec: 1899
  - bimefec: 2
  - usuario: "jlopez"
- **Acción:** POST /api/execute { action: 'saveUbicacion', params: ... }
- **Resultado esperado:**
  - success: false
  - message: "El campo noexterior es obligatorio" o "El año de efectos debe ser mayor o igual a 1900"

## Caso 3: Consulta de catálogo de calles
- **Entrada:**
  - action: 'getCalles'
- **Acción:** POST /api/execute { action: 'getCalles' }
- **Resultado esperado:**
  - success: true
  - data: [ { cvecalle: ..., calle: ... }, ... ]

## Caso 4: Consulta de catálogo de colonias
- **Entrada:**
  - action: 'getColonias'
- **Acción:** POST /api/execute { action: 'getColonias' }
- **Resultado esperado:**
  - success: true
  - data: [ { cvecolonia: ..., colonia: ... }, ... ]

## Caso 5: Consulta de ubicación vigente por cuenta
- **Entrada:**
  - action: 'getUbicacionByCuenta', params: { cvecuenta: 123456 }
- **Acción:** POST /api/execute { action: 'getUbicacionByCuenta', params: { cvecuenta: 123456 } }
- **Resultado esperado:**
  - success: true
  - data: [ { ...ubicacion... } ]
