# Casos de Prueba para Impresión de Recibos

## Caso 1: Licencia vigente, certificación
- **Entrada:** licencia=12345, tipo=certificacion
- **Acción:** Buscar y generar recibo
- **Esperado:**
  - Se muestra recibo con datos correctos
  - Concepto: CERTIFICACIÓN
  - Monto igual a costo_certific
  - Cantidad en letra correcta

## Caso 2: Licencia inexistente
- **Entrada:** licencia=99999, tipo=certificacion
- **Acción:** Buscar
- **Esperado:**
  - Mensaje de error 'No se encontró licencia con ese número'
  - No se habilita botón de imprimir

## Caso 3: Licencia vigente, constancia
- **Entrada:** licencia=54321, tipo=constancia
- **Acción:** Buscar y generar recibo
- **Esperado:**
  - Se muestra recibo con datos correctos
  - Concepto: CONSTANCIA
  - Monto igual a costo_constancia
  - Cantidad en letra correcta

## Caso 4: Licencia no vigente
- **Entrada:** licencia=11111 (no vigente), tipo=certificacion
- **Acción:** Buscar
- **Esperado:**
  - Mensaje de error 'No se encontró licencia con ese número'
  - No se habilita botón de imprimir

## Caso 5: Error de conexión
- **Simulación:** API no responde
- **Acción:** Buscar o imprimir
- **Esperado:**
  - Mensaje de error 'Error de conexión'
