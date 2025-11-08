# Casos de Prueba para Cuotas de Energía Eléctrica

## 1. Alta de cuota válida
- **Entrada:** axo=2024, periodo=6, importe=123.456789
- **Acción:** create
- **Esperado:** success=true, cuota aparece en listado

## 2. Alta de cuota con importe cero
- **Entrada:** axo=2024, periodo=6, importe=0
- **Acción:** create
- **Esperado:** success=false, message indica error de validación

## 3. Modificación de cuota existente
- **Entrada:** id_kilowhatts=3, axo=2024, periodo=6, importe=321.654987
- **Acción:** update
- **Esperado:** success=true, importe actualizado

## 4. Eliminación de cuota
- **Entrada:** id_kilowhatts=4
- **Acción:** delete
- **Esperado:** success=true, cuota ya no aparece en listado

## 5. Consulta de cuota inexistente
- **Entrada:** id_kilowhatts=9999
- **Acción:** get
- **Esperado:** success=true, data=null

## 6. Listado general
- **Entrada:**
- **Acción:** list
- **Esperado:** success=true, data es array de cuotas

## 7. Validación de usuario no autenticado
- **Entrada:** create sin sesión
- **Esperado:** success=false, message de autenticación
