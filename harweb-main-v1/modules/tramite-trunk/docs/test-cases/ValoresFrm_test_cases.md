# Casos de Prueba para Formulario Valores

## Caso 1: Alta de nuevo valor
- **Entrada**: cvecuenta=1001, axoefec=2024, bimefec=1, valfiscal=150000, tasa=0.002, axosobre=0, estado='N', observacion='Valor inicial 2024'
- **Acción**: insertValor, luego applyValores
- **Esperado**: El valor aparece en valoradeudo y catastro se actualiza

## Caso 2: Modificación de valor existente
- **Entrada**: id=5, valfiscal=200000, tasa=0.002, axosobre=0, estado='M', observacion='Corrección por error de captura'
- **Acción**: updateValor, luego applyValores
- **Esperado**: El valor fiscal se actualiza en valoradeudo

## Caso 3: Eliminación de valor temporal
- **Entrada**: id=7
- **Acción**: deleteValor
- **Esperado**: El valor desaparece de tmp_valadeudo

## Caso 4: Validación de campos obligatorios
- **Entrada**: axoefec vacío
- **Acción**: insertValor
- **Esperado**: Error de validación, mensaje adecuado

## Caso 5: Aplicar cambios sin iniciar transacción
- **Acción**: applyValores sin haber iniciado transacción
- **Esperado**: Error, no se aplican cambios
