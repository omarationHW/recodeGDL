# Casos de Prueba para AdeEnergiaGrl

## Caso 1: Consulta exitosa de adeudos
- **Entrada:**
  - id_rec: 1
  - num_mercado_nvo: 5
  - axo: 2024
  - mes: 6
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: true
  - data: Array de objetos con campos id_local, oficina, num_mercado, ...
  - message: ""

## Caso 2: Filtros incompletos
- **Entrada:**
  - id_rec: null
  - num_mercado_nvo: null
  - axo: 2024
  - mes: 6
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: false
  - message: 'El campo id_rec es obligatorio.' o similar

## Caso 3: Exportación a Excel (no implementada)
- **Acción:** Click en botón 'Excel' sin datos
- **Resultado esperado:**
  - Mensaje: 'Funcionalidad de exportación a Excel no implementada.'

## Caso 4: Navegación y renderizado
- **Acción:** Acceder a la ruta de la página AdeEnergiaGrl
- **Resultado esperado:**
  - Se renderiza la página con los campos de filtro y tabla vacía

## Caso 5: Validación de año y mes fuera de rango
- **Entrada:**
  - axo: 1800
  - mes: 13
- **Acción:** POST /api/execute con action=getAdeudosEnergiaGrl
- **Resultado esperado:**
  - success: false
  - message: 'El campo axo debe ser mayor o igual a 1995.' o similar
