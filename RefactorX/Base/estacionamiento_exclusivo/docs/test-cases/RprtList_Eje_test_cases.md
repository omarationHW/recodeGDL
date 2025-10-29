## Casos de Prueba para RprtList_Eje

### Caso 1: Consulta básica de vigentes
- **Entrada:**
  - varios: "1,2,3"
  - vvig: "1"
  - vrec: ""
  - vopc: 1
  - vfec1: "2024-01-01"
  - vfec2: "2024-01-31"
  - vrecaudadora: 0
  - vfecP1: null
  - vfecP2: null
  - vnombre: ""
  - v90d: "N"
- **Acción:** POST /api/execute
- **Esperado:**
  - success: true
  - data: lista de registros con vigencia '1' y ejecutores 1,2,3 en el periodo

### Caso 2: Consulta pagados por zona
- **Entrada:**
  - varios: "2,5"
  - vvig: "2"
  - vrec: "3"
  - vopc: 1
  - vfec1: "2024-02-01"
  - vfec2: "2024-02-28"
  - vrecaudadora: 3
  - vfecP1: null
  - vfecP2: null
  - vnombre: ""
  - v90d: "N"
- **Acción:** POST /api/execute
- **Esperado:**
  - success: true
  - data: registros pagados en zona 3

### Caso 3: Solo registros con diaspas < 91
- **Entrada:**
  - varios: "1,2"
  - vvig: "1"
  - vrec: ""
  - vopc: 1
  - vfec1: "2024-03-01"
  - vfec2: "2024-03-31"
  - vrecaudadora: 0
  - vfecP1: null
  - vfecP2: null
  - vnombre: ""
  - v90d: "S"
- **Acción:** POST /api/execute
- **Esperado:**
  - success: true
  - data: solo registros donde diaspas < 91

### Caso 4: Error por parámetros inválidos
- **Entrada:**
  - varios: ""
  - vvig: "1"
  - vrec: ""
  - vopc: 1
  - vfec1: "2024-01-01"
  - vfec2: "2024-01-31"
  - vrecaudadora: 0
  - vfecP1: null
  - vfecP2: null
  - vnombre: ""
  - v90d: "N"
- **Acción:** POST /api/execute
- **Esperado:**
  - success: false
  - message: error indicando que 'varios' es requerido

### Caso 5: Consulta con fechas fuera de rango
- **Entrada:**
  - varios: "1"
  - vvig: "1"
  - vrec: ""
  - vopc: 1
  - vfec1: "2023-01-01"
  - vfec2: "2023-01-31"
  - vrecaudadora: 0
  - vfecP1: null
  - vfecP2: null
  - vnombre: ""
  - v90d: "N"
- **Acción:** POST /api/execute
- **Esperado:**
  - success: true
  - data: lista vacía si no hay registros en ese rango
