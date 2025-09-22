# Casos de Prueba para RActualiza

## Caso 1: Actualización exitosa de concesionario
- **Entrada:**
  - número: 123
  - letra: A
  - nuevo concesionario: Nuevo Concesionario S.A.
- **Pasos:**
  1. Buscar local 123-A
  2. Seleccionar opción 'Concesionario'
  3. Ingresar 'Nuevo Concesionario S.A.'
  4. Aplicar cambio
- **Resultado esperado:** Mensaje de éxito, concesionario actualizado.

## Caso 2: Cambio de superficie con pagos existentes
- **Entrada:**
  - número: 456
  - letra: B
  - nueva superficie: 50.00
  - año inicio: 2023
  - mes inicio: 05
- **Pasos:**
  1. Buscar local 456-B
  2. Seleccionar opción 'Superficie'
  3. Ingresar nueva superficie, año y mes
  4. Aplicar cambio
- **Resultado esperado:** Si existen pagos posteriores, mensaje de error 'Existe pago(s) realizado(s) a partir de este periodo, intenta con otro'.

## Caso 3: Intento de actualización con datos iguales
- **Entrada:**
  - número: 789
  - letra: C
  - concesionario: Concesionario Actual
- **Pasos:**
  1. Buscar local 789-C
  2. Seleccionar opción 'Concesionario'
  3. Ingresar 'Concesionario Actual'
  4. Aplicar cambio
- **Resultado esperado:** Mensaje de error 'Para poder realizar un cambio es requisito que los datos sean diferentes, intenta con otro'.

## Caso 4: Validación de campos obligatorios
- **Entrada:**
  - número: (vacío)
  - letra: (vacío)
- **Pasos:**
  1. Intentar buscar sin ingresar número/letra
- **Resultado esperado:** Mensaje de error de campo obligatorio.

## Caso 5: Cambio de tipo de local
- **Entrada:**
  - número: 321
  - letra: D
  - nuevo tipo: EXTERNO
  - año inicio: 2024
  - mes inicio: 01
- **Pasos:**
  1. Buscar local 321-D
  2. Seleccionar opción 'Tipo de Local'
  3. Ingresar 'EXTERNO', año y mes
  4. Aplicar cambio
- **Resultado esperado:** Mensaje de éxito, tipo de local actualizado.
