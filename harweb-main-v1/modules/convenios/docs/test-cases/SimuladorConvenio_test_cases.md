## Casos de Prueba para Simulador de Convenios

### Caso 1: Simulación Predial - Registro Existente
- **Entrada:**
  - action: buscarRegistro
  - modulo: 5
  - p1: 1
  - p2: 'U'
  - p3: 123456
- **Esperado:**
  - status: ok
  - registro: contiene id_registro y datos

### Caso 2: Simulación Predial - Registro Inexistente
- **Entrada:**
  - action: buscarRegistro
  - modulo: 5
  - p1: 99
  - p2: 'X'
  - p3: 999999
- **Esperado:**
  - status: not_found
  - message: 'No se encontró el registro.'

### Caso 3: Simulación Licencias - Cálculo Correcto
- **Entrada:**
  - action: simularConvenio
  - modulo: 9
  - id_registro: 321
- **Esperado:**
  - status: ok
  - totales: contiene importe, recargos, total, etc.

### Caso 4: Listar Periodos
- **Entrada:**
  - action: listarPeriodos
  - id_control: 123
- **Esperado:**
  - status: ok
  - periodos: lista de periodos

### Caso 5: Error de Acción No Soportada
- **Entrada:**
  - action: 'accionInvalida'
- **Esperado:**
  - status: error
  - message: 'Acción no soportada: accionInvalida'
