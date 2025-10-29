# Casos de Prueba para Formulario Cartografía Predial

## Caso 1: Consulta exitosa de predio por clave catastral
- **Entrada:** cvecatnva = 'A1234567', subpredio = 0
- **Acción:** getPredioByClaveCatastral
- **Esperado:** Devuelve datos completos del predio (cuenta, propietario, ubicación, valores, etc.)

## Caso 2: Consulta de predio inexistente
- **Entrada:** cvecatnva = 'ZZZZZZZZ', subpredio = 0
- **Acción:** getPredioByClaveCatastral
- **Esperado:** eResponse.error indica 'No se encontró el predio.'

## Caso 3: Consulta de cartografía predial
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getCartografia
- **Esperado:** Devuelve JSON con layers ['predios', 'construcciones', 'calles', 'numeros_oficiales'] y status 'ok'

## Caso 4: Consulta de números oficiales
- **Entrada:** cvemanz = 'A1234567'
- **Acción:** getNumerosOficiales
- **Esperado:** Devuelve lista de números oficiales asociados a la manzana

## Caso 5: Consulta de condominio
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getCondominio
- **Esperado:** Devuelve datos del condominio si existe, o lista vacía si no existe

## Caso 6: Consulta de avalúo
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getAvaluo
- **Esperado:** Devuelve datos de avalúo (superficie, valores, etc.)

## Caso 7: Consulta de construcciones
- **Entrada:** cvecatnva = 'A1234567'
- **Acción:** getConstrucciones
- **Esperado:** Devuelve lista de construcciones asociadas al predio
