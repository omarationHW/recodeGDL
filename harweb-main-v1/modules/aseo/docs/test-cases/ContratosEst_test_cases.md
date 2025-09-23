## Casos de Prueba para Estadístico de Contratos

### Caso 1: Consulta General de Contratos Vigentes
- **Entrada:**
  - vigencia: 'V'
  - oficina: 0
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 0
  - periodo_inicio: '2023-01'
  - periodo_fin: '2023-12'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con al menos una fila por tipo de aseo
  - Los totales de contratos y adeudos corresponden a los datos de la base

### Caso 2: Contratos Cancelados en Oficina Específica
- **Entrada:**
  - vigencia: 'C'
  - oficina: 1
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 2
  - periodo_inicio: null
  - periodo_fin: null
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con contratos cancelados en oficina 1

### Caso 3: Adeudos Pagados por Fecha
- **Entrada:**
  - vigencia: 'T'
  - oficina: 0
  - tipo_aseo: 999
  - vig_adeudos: 'P'
  - grupo_adeudos: 1
  - fecha_inicio: '2023-06-01'
  - fecha_fin: '2023-06-30'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array con totales de adeudos pagados en ese rango de fechas

### Caso 4: Sin Resultados
- **Entrada:**
  - vigencia: 'V'
  - oficina: 99 (oficina inexistente)
  - tipo_aseo: 999
  - vig_adeudos: 'T'
  - grupo_adeudos: 0
  - periodo_inicio: '2023-01'
  - periodo_fin: '2023-12'
  - adeudos_visual: 0
- **Esperado:**
  - Respuesta success=true
  - data: array vacío

### Caso 5: Error de Parámetros
- **Entrada:**
  - vigencia: null
  - oficina: null
- **Esperado:**
  - Respuesta success=false
  - message: 'Acción no soportada' o mensaje de error de validación
