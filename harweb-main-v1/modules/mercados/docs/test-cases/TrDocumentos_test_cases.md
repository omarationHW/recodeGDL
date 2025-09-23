# Casos de Prueba: TrDocumentos

## Caso 1: Consulta de Cheques Existentes
- **Entrada**: fecha_elaboracion = '2024-06-01', cuenta = 1, tipo_doc = 'C'
- **Acción**: Buscar documentos
- **Esperado**: Se listan todos los cheques emitidos ese día para la cuenta seleccionada.

## Caso 2: Generación de Archivo de Transferencia (Bco. Pagador)
- **Entrada**: fecha_elaboracion = '2024-06-01', cuenta = 1, tipo_doc = 'P'
- **Acción**: Buscar y luego generar archivo
- **Esperado**: Se genera archivo .txt descargable con los datos de transferencia electrónica.

## Caso 3: Consulta sin Resultados
- **Entrada**: fecha_elaboracion = '2024-01-01', cuenta = 1, tipo_doc = 'O'
- **Acción**: Buscar documentos
- **Esperado**: Se muestra mensaje de 'No se encontraron documentos para los criterios seleccionados.'

## Caso 4: Error al Generar Archivo (sin cuenta de transferencia)
- **Entrada**: cuenta sin cuenta de transferencia asociada
- **Acción**: Intentar generar archivo
- **Esperado**: Se muestra mensaje de error 'No se encontró la cuenta de transferencia'.

## Caso 5: Validación de Parámetros
- **Entrada**: Campos vacíos o inválidos
- **Acción**: Buscar o generar archivo
- **Esperado**: El sistema rechaza la operación y muestra mensaje de error.