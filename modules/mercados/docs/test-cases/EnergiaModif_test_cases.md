# Casos de Prueba: EnergiaModif

## Caso 1: Modificación exitosa de cantidad
- **Entrada:**
  - Local existente, movimiento 'C', cantidad válida (>0)
- **Pasos:**
  1. Buscar local existente y vigente
  2. Modificar cantidad a un valor válido
  3. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Registro actualizado en BD
  - Historial actualizado

## Caso 2: Error por cantidad vacía o cero
- **Entrada:**
  - Local existente, cantidad = 0
- **Pasos:**
  1. Buscar local
  2. Modificar cantidad a 0
  3. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success false, mensaje de error 'La cantidad de kilowhatts/cuota fija no tiene información'

## Caso 3: Baja total sin periodo de baja
- **Entrada:**
  - Movimiento 'B', periodo_baja_axo o periodo_baja_mes vacío
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Baja Total'
  3. No ingresar periodo de baja
  4. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success false, mensaje de error 'Falta capturar el periodo de baja'

## Caso 4: Baja total exitosa
- **Entrada:**
  - Movimiento 'B', periodo_baja_axo y periodo_baja_mes válidos
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Baja Total'
  3. Ingresar periodo de baja
  4. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Adeudos posteriores eliminados

## Caso 5: Cambio de cuota actualiza adeudos
- **Entrada:**
  - Movimiento 'D', periodo_baja_axo y periodo_baja_mes válidos, cantidad nueva
- **Pasos:**
  1. Buscar local
  2. Seleccionar movimiento 'Cambio de Cuota'
  3. Ingresar periodo de baja
  4. Cambiar cantidad
  5. Enviar acción 'modificar'
- **Esperado:**
  - Respuesta success true, mensaje de éxito
  - Adeudos en rango actualizados
