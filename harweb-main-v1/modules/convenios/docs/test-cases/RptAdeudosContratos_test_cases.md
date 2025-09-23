## Casos de Prueba para RptAdeudosContratos

### Caso 1: Consulta exitosa de contratos con adeudos
- **Entrada:** colonia=101, calle=202, rep=1
- **Acción:** POST /api/execute con eRequest='RptAdeudosContratos' y params anteriores
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con concepto='ADE'
  - Totales correctos

### Caso 2: Consulta de contratos con saldo a favor
- **Entrada:** colonia=101, calle=202, rep=2
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - Todos los registros tienen concepto='SAF'

### Caso 3: Consulta de contratos liquidados
- **Entrada:** colonia=101, calle=202, rep=3
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - Todos los registros tienen concepto='LIQ' o 'SAF' (saldo <= 0)

### Caso 4: Parámetros faltantes
- **Entrada:** colonia=null, calle=202, rep=1
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica error de parámetros

### Caso 5: Sin resultados
- **Entrada:** colonia=9999, calle=8888, rep=1 (IDs inexistentes)
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array vacío

### Caso 6: SQL Injection attempt
- **Entrada:** colonia="101; DROP TABLE ta_17_convenios;--", calle=202, rep=1
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica error de parámetros o sintaxis

### Caso 7: Consulta con gran volumen de datos
- **Entrada:** colonia=101, calle=202, rep=1 (muchos contratos)
- **Acción:** POST /api/execute
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene todos los registros sin errores de performance
