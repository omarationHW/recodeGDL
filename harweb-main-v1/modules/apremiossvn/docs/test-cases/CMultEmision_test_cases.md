# Casos de Prueba: Consulta Múltiple por Fecha de Emisión

## Caso 1: Consulta exitosa de folios
- **Entrada:** modulo=11, zona=2, fecha_emision='2024-06-01'
- **Acción:** Buscar folios
- **Resultado esperado:** Lista de folios con datos principales

## Caso 2: Visualización de detalle de folio
- **Entrada:** id_control=12345
- **Acción:** Ver detalle
- **Resultado esperado:** Se muestra el detalle completo del folio

## Caso 3: Validación de parámetros obligatorios
- **Entrada:** modulo=11, zona=2, fecha_emision=''
- **Acción:** Buscar folios
- **Resultado esperado:** Mensaje de error 'El campo fecha_emision es obligatorio.'

## Caso 4: Sin resultados
- **Entrada:** modulo=16, zona=5, fecha_emision='1999-01-01'
- **Acción:** Buscar folios
- **Resultado esperado:** Mensaje 'No se encontraron folios.'

## Caso 5: Error de base de datos
- **Simulación:** Desconectar la base de datos
- **Acción:** Buscar folios
- **Resultado esperado:** Mensaje de error técnico controlado