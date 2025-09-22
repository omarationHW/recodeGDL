## Casos de Prueba - ListadosSinAdereq

### Caso 1: Consulta exitosa de locales sin adeudo
- **Input:**
  - tipo: mercado
  - id_rec: 1
  - num_mercado: 2
  - seccion: 'A'
  - local1: 1
  - local2: 20
- **Acción:** POST /api/execute con action=getListadosSinAdereq
- **Resultado esperado:**
  - HTTP 200
  - JSON con success=true y array de locales
  - Cada local tiene campos id_local, oficina, num_mercado, ...

### Caso 2: Consulta de bloqueos de local existente
- **Input:**
  - id_local: 123
- **Acción:** POST /api/execute con action=getBloqueos
- **Resultado esperado:**
  - HTTP 200
  - JSON con success=true y array de bloqueos (puede estar vacío)

### Caso 3: Consulta de último movimiento de local existente
- **Input:**
  - id_local: 123
- **Acción:** POST /api/execute con action=getUltimoMovimiento
- **Resultado esperado:**
  - HTTP 200
  - JSON con success=true y array con un solo objeto (o vacío si no hay movimientos)

### Caso 4: Acción no soportada
- **Input:**
  - action: 'noExiste'
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - HTTP 400
  - JSON con success=false y error

### Caso 5: Error interno (por ejemplo, DB caída)
- **Input:**
  - action: getListadosSinAdereq, params válidos
- **Simulación:** DB caída
- **Resultado esperado:**
  - HTTP 500
  - JSON con success=false y error
