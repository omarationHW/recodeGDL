# Casos de Prueba: Adeudos de Locales

## Caso 1: Consulta exitosa de adeudos
- **Entrada:** { axo: 2024, oficina: 1, periodo: 6 }
- **Acción:** POST /api/execute con action 'getAdeudosLocales'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene arreglo de adeudos

## Caso 2: Consulta con parámetros inválidos
- **Entrada:** { axo: '', oficina: 1, periodo: 6 }
- **Acción:** POST /api/execute con action 'getAdeudosLocales'
- **Resultado esperado:** eResponse.success = false, eResponse.message indica error de validación

## Caso 3: Exportación a Excel sin datos
- **Entrada:** action 'exportAdeudosLocalesExcel' sin haber consultado datos
- **Acción:** POST /api/execute
- **Resultado esperado:** eResponse.success = true, eResponse.message = 'Exportación en proceso' (o error si no implementado)

## Caso 4: Consulta de meses de adeudo
- **Entrada:** { id_local: 1234, axo: 2024, periodo: 6 }
- **Acción:** POST /api/execute con action 'getMesesAdeudo'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene arreglo de meses

## Caso 5: Consulta de renta de local
- **Entrada:** { axo: 2024, categoria: 1, seccion: 'PS', clave_cuota: 4 }
- **Acción:** POST /api/execute con action 'getRentaLocal'
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene importe_cuota
