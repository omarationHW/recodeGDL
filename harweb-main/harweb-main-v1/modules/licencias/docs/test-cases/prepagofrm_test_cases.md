# Casos de Prueba para Formulario Prepago

## Caso 1: Consulta de Adeudo y Descuentos
- **Entrada**: cvecuenta = 123456
- **Acción**: Buscar cuenta
- **Verificar**:
  - Se muestran nombre, calle, noexterior, interior
  - Se muestra tabla de detalle de adeudo
  - Al mostrar descuentos, la tabla de descuentos aparece
  - No hay errores

## Caso 2: Liquidación Parcial
- **Entrada**: cvecuenta = 123456, asalf = 2024, bsalf = 4
- **Acción**: Liquidación parcial
- **Verificar**:
  - Se muestra resultado JSON con detalle y totales
  - Los totales corresponden al periodo solicitado

## Caso 3: Recalcular DPP
- **Entrada**: cvecuenta = 123456
- **Acción**: Recalcular DPP
- **Verificar**:
  - El sistema retorna 'OK' o mensaje de éxito
  - No hay errores

## Caso 4: Eliminar DPP
- **Entrada**: cvecuenta = 123456
- **Acción**: Eliminar DPP
- **Verificar**:
  - El sistema retorna 'OK' o mensaje de éxito

## Caso 5: Calcular Descuento Predial
- **Entrada**: cvecuenta = 123456
- **Acción**: Calcular Descuento Predial
- **Verificar**:
  - El sistema retorna 'OK' o mensaje de éxito

## Caso 6: Error por cuenta inexistente
- **Entrada**: cvecuenta = 999999
- **Acción**: Buscar cuenta
- **Verificar**:
  - El sistema retorna error indicando que la cuenta no existe
