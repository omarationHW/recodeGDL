# Casos de Prueba: Parcialidades Vencidas Predios

## Caso 1: Consulta exitosa de predios vigentes
- **Entrada:** { "subtipo": 1, "fechahst": "2024-06-30", "est": "A" }
- **Acción:** POST /api/execute con action 'getParcialidadesVencidasPredios'
- **Resultado esperado:** status=success, data contiene lista de predios con campos correctos

## Caso 2: Parámetros faltantes
- **Entrada:** { "subtipo": 1 }
- **Acción:** POST /api/execute
- **Resultado esperado:** status=error, message indica parámetros requeridos

## Caso 3: Consulta de predios dados de baja
- **Entrada:** { "subtipo": 2, "fechahst": "2024-05-31", "est": "B" }
- **Acción:** POST /api/execute
- **Resultado esperado:** status=success, data contiene predios dados de baja

## Caso 4: Consulta de predios pagados
- **Entrada:** { "subtipo": 3, "fechahst": "2024-04-30", "est": "P" }
- **Acción:** POST /api/execute
- **Resultado esperado:** status=success, data contiene predios pagados

## Caso 5: Consulta con subtipo inexistente
- **Entrada:** { "subtipo": 999, "fechahst": "2024-06-30", "est": "A" }
- **Acción:** POST /api/execute
- **Resultado esperado:** status=success, data es lista vacía

## Caso 6: Validación de formato de fecha
- **Entrada:** { "subtipo": 1, "fechahst": "30-06-2024", "est": "A" }
- **Acción:** POST /api/execute
- **Resultado esperado:** status=error, message de error de formato de fecha
