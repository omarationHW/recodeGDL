## Casos de Prueba para RprtListaxRegEstacionometro

### Caso 1: Consulta básica por colonia y vigencia
- **Entrada:**
  - vigencia: '1'
  - clave_practicado: 'todas'
  - colonia: 'INSURGENTES'
  - oficina: 2
- **Acción:** POST /api/execute con action=getEstacionometroReport
- **Resultado esperado:**
  - success: true
  - data: Array con registros de la colonia 'INSURGENTES' y vigencia '1'
  - Totales correctos

### Caso 2: Consulta por clave_practicado y vigencia pagada
- **Entrada:**
  - vigencia: '2'
  - clave_practicado: 'ABC123'
  - colonia: 'CENTRO'
  - oficina: 2
- **Acción:** POST /api/execute con action=getEstacionometroReport
- **Resultado esperado:**
  - success: true
  - data: Solo registros con clave_practicado 'ABC123' y vigencia '2' o 'P' en 'CENTRO'

### Caso 3: Consulta por oficina específica
- **Entrada:**
  - vigencia: 'todas'
  - clave_practicado: 'todas'
  - colonia: 'OBRERA'
  - oficina: 3
- **Acción:** POST /api/execute con action=getEstacionometroReport
- **Resultado esperado:**
  - success: true
  - data: Registros de 'OBRERA' asociados a oficina 3

### Caso 4: Consulta sin resultados
- **Entrada:**
  - vigencia: '1'
  - clave_practicado: 'ZZZZZ'
  - colonia: 'NOEXISTE'
  - oficina: 2
- **Acción:** POST /api/execute con action=getEstacionometroReport
- **Resultado esperado:**
  - success: true
  - data: []

### Caso 5: Error por parámetro faltante
- **Entrada:**
  - vigencia: '1'
  - clave_practicado: 'todas'
  - colonia: ''
  - oficina: 2
- **Acción:** POST /api/execute con action=getEstacionometroReport
- **Resultado esperado:**
  - success: false
  - message: Error indicando que colonia es requerida
