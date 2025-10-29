# Casos de Prueba para Prescripción

## Caso 1: Prescripción exitosa
- **Entrada:**
  - cvecuenta: 12345
  - axoini: 2018
  - bimini: 1
  - axofin: 2020
  - bimfin: 6
  - observacion: "Prescripción por antigüedad"
  - usuario: "admin"
- **Acción:** save
- **Esperado:**
  - success: true
  - message: "Prescripción registrada correctamente"
  - data.id: (entero)

## Caso 2: Búsqueda de saldos
- **Entrada:**
  - cvecuenta: 12345
  - axoini: 2018
  - bimini: 1
  - axofin: 2020
  - bimfin: 6
- **Acción:** search
- **Esperado:**
  - success: true
  - data: lista de saldos (array)

## Caso 3: Validación de campos requeridos
- **Entrada:**
  - cvecuenta: 12345
  - axoini: 2018
  - bimini: 1
  - axofin: 2020
  - bimfin: 6
  - observacion: "Prescripción por antigüedad"
  - usuario: ""
- **Acción:** save
- **Esperado:**
  - success: false
  - message: "El campo usuario es obligatorio"

## Caso 4: Listar prescripciones
- **Entrada:**
  - cvecuenta: 12345
- **Acción:** list
- **Esperado:**
  - success: true
  - data: lista de prescripciones (array)

## Caso 5: Error de base de datos
- **Simulación:** Forzar error en la base de datos (por ejemplo, cuenta inexistente)
- **Esperado:**
  - success: false
  - message: "Error ..."
