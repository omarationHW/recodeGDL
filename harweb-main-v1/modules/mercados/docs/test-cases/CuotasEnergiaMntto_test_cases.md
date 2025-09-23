# Casos de Prueba: Cuotas de Energía Eléctrica

## Caso 1: Alta exitosa de cuota
- **Entrada:** axo=2024, periodo=6, importe=150.00, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=true, message='Cuota insertada correctamente.'
- **Validación:** La cuota aparece en el listado.

## Caso 2: Modificación exitosa de cuota
- **Entrada:** id_kilowhatts=10, axo=2024, periodo=6, importe=175.00, id_usuario=1
- **Acción:** updateCuota
- **Esperado:** success=true, message='Cuota actualizada correctamente.'
- **Validación:** El importe de la cuota cambia en el listado.

## Caso 3: Validación de importe vacío/cero
- **Entrada:** axo=2024, periodo=6, importe=0, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El importe debe ser mayor a cero.'
- **Validación:** No se inserta la cuota, mensaje de error visible.

## Caso 4: Listado filtrado por año y periodo
- **Entrada:** axo=2024, periodo=6
- **Acción:** listCuotas
- **Esperado:** success=true, data contiene sólo cuotas de ese año y periodo.

## Caso 5: Consulta de cuota por ID
- **Entrada:** id_kilowhatts=10
- **Acción:** getCuota
- **Esperado:** success=true, data contiene los datos de la cuota solicitada.

## Caso 6: Error por año fuera de rango
- **Entrada:** axo=1999, periodo=6, importe=100, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El año debe ser mayor o igual a 2002.'

## Caso 7: Error por periodo fuera de rango
- **Entrada:** axo=2024, periodo=13, importe=100, id_usuario=1
- **Acción:** insertCuota
- **Esperado:** success=false, message='El periodo debe estar entre 1 y 12.'
