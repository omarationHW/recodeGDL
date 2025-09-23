# Casos de Prueba TiposMntto

## Caso 1: Alta de Tipo válido
- **Entrada:** { "action": "create", "data": { "tipo": 10, "descripcion": "TIPO TEST" } }
- **Esperado:** status: success, data.tipo = 10, data.descripcion = 'TIPO TEST'

## Caso 2: Alta de Tipo con descripción vacía
- **Entrada:** { "action": "create", "data": { "tipo": 11, "descripcion": "" } }
- **Esperado:** status: error, message: 'The descripcion field is required.'

## Caso 3: Modificación de Tipo existente
- **Entrada:** { "action": "update", "data": { "tipo": 10, "descripcion": "TIPO MODIFICADO" } }
- **Esperado:** status: success, data.tipo = 10, data.descripcion = 'TIPO MODIFICADO'

## Caso 4: Consulta de todos los Tipos
- **Entrada:** { "action": "list", "data": {} }
- **Esperado:** status: success, data: [ ... ] (arreglo de tipos)

## Caso 5: Consulta de Tipo inexistente
- **Entrada:** { "action": "get", "data": { "tipo": 999 } }
- **Esperado:** status: success, data: null

## Caso 6: Modificación con tipo inexistente
- **Entrada:** { "action": "update", "data": { "tipo": 999, "descripcion": "NO EXISTE" } }
- **Esperado:** status: success, data: null (no error, pero no actualiza nada)
