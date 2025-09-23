# Casos de Prueba: Rep_Tipos_Emp

## Caso 1: Consulta por Control
- **Input:** { action: 'getTiposEmpReport', params: { order: 1 } }
- **Resultado esperado:** Lista de tipos de empresa ordenados por ctrol_emp ascendente.
- **Validación:** El primer registro debe tener el menor ctrol_emp.

## Caso 2: Consulta por Tipo
- **Input:** { action: 'getTiposEmpReport', params: { order: 2 } }
- **Resultado esperado:** Lista ordenada alfabéticamente por tipo_empresa.
- **Validación:** El primer registro debe tener el tipo_empresa alfabéticamente menor.

## Caso 3: Consulta por Descripción
- **Input:** { action: 'getTiposEmpReport', params: { order: 3 } }
- **Resultado esperado:** Lista ordenada alfabéticamente por descripcion.
- **Validación:** El primer registro debe tener la descripcion alfabéticamente menor.

## Caso 4: Parámetro inválido
- **Input:** { action: 'getTiposEmpReport', params: { order: 99 } }
- **Resultado esperado:** El sistema retorna la lista ordenada por ctrol_emp (default) o un error controlado.
- **Validación:** No debe haber error fatal, debe manejarse la excepción.

## Caso 5: Sin datos
- **Input:** { action: 'getTiposEmpReport', params: { order: 1 } } (con tabla vacía)
- **Resultado esperado:** El sistema retorna una lista vacía y mensaje informativo.
- **Validación:** El frontend muestra 'No hay datos para mostrar.'
