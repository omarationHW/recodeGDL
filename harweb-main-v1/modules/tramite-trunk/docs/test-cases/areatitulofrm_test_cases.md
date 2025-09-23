# Casos de Prueba: Área según Título

## Caso 1: Actualización exitosa para subpredio
- **Entrada:**
  - cvecuenta: 12345 (subpredio > 0)
  - areatitulo: 85.5
  - observacion: "Actualización por subdivisión"
- **Acción:** update
- **Resultado esperado:** success = true, mensaje de éxito

## Caso 2: Actualización exitosa para cuenta sin subpredio, diferencia < 10%
- **Entrada:**
  - cvecuenta: 54321 (subpredio = 0, supterr = 110)
  - areatitulo: 100.0
  - observacion: "Corrección menor"
- **Acción:** update
- **Resultado esperado:** success = true, mensaje de éxito

## Caso 3: Rechazo por diferencia > 10%
- **Entrada:**
  - cvecuenta: 54321 (subpredio = 0, supterr = 110)
  - areatitulo: 50.0
  - observacion: "Intento de reducción excesiva"
- **Acción:** update
- **Resultado esperado:** success = false, mensaje de error

## Caso 4: Rechazo por falta de avalúo
- **Entrada:**
  - cvecuenta: 99999 (sin avalúo)
  - areatitulo: 100.0
  - observacion: "Prueba sin avalúo"
- **Acción:** update
- **Resultado esperado:** success = false, mensaje de error

## Caso 5: Consulta de cuenta inexistente
- **Entrada:**
  - cvecuenta: 88888 (no existe)
- **Acción:** get
- **Resultado esperado:** success = false, mensaje de error
