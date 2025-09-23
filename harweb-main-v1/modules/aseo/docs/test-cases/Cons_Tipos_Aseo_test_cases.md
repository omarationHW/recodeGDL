# Casos de Prueba: Cons_Tipos_Aseo

## Caso 1: Consulta por defecto
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'ctrol_aseo'
- **Esperado:** eResponse.success = true, eResponse.data contiene todos los registros ordenados por ctrol_aseo

## Caso 2: Consulta por descripción
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'descripcion'
- **Esperado:** eResponse.success = true, eResponse.data ordenado alfabéticamente por descripción

## Caso 3: Orden inválido
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'hack'
- **Esperado:** eResponse.success = true, eResponse.data ordenado por ctrol_aseo (fallback seguro)

## Caso 4: Exportación a Excel
- **Entrada:** eRequest.action = 'cons_tipos_aseo_export_excel', params.order = 'tipo_aseo'
- **Esperado:** eResponse.success = true, eResponse.message indica que la exportación fue generada

## Caso 5: Acción no soportada
- **Entrada:** eRequest.action = 'no_existente'
- **Esperado:** eResponse.success = false, eResponse.message = 'Acción no soportada'

## Caso 6: Sin registros
- **Precondición:** Tabla ta_16_tipo_aseo vacía
- **Entrada:** eRequest.action = 'cons_tipos_aseo_list', params.order = 'ctrol_aseo'
- **Esperado:** eResponse.success = true, eResponse.data = []
