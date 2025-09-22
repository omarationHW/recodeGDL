## Casos de Prueba para Autorización de Transmisión Patrimonial

### Caso 1: Registro exitoso
- **Entrada:**
  - folio: 10001
  - exento: 'N'
  - documentos_otros: 'Test legal justification'
  - justificacion: 'Obs test'
  - tasa_preferencial: 'S'
  - usuario: 'tester'
- **Acción:** save
- **Esperado:** success=true, registro guardado, status='A'

### Caso 2: Falta campo obligatorio
- **Entrada:**
  - folio: (vacío)
  - exento: 'N'
  - documentos_otros: 'Test legal justification'
  - justificacion: 'Obs test'
  - tasa_preferencial: 'S'
  - usuario: 'tester'
- **Acción:** save
- **Esperado:** success=false, mensaje de error 'Folio requerido'

### Caso 3: Autorizar registro existente
- **Entrada:**
  - folio: 10001
  - usuario: 'tester'
- **Acción:** authorize
- **Esperado:** success=true, status='P'

### Caso 4: Cerrar registro
- **Entrada:**
  - folio: 10001
  - usuario: 'tester'
- **Acción:** close
- **Esperado:** success=true, status='C'

### Caso 5: Reabrir registro
- **Entrada:**
  - folio: 10001
  - usuario: 'tester'
- **Acción:** reopen
- **Esperado:** success=true, status='A'

### Caso 6: Listar registros
- **Entrada:**
  - filters: {}
- **Acción:** list
- **Esperado:** success=true, lista de registros

### Caso 7: Catálogo de tasas preferenciales
- **Entrada:**
  - catalog: 'tasa_preferencial'
- **Acción:** catalog
- **Esperado:** success=true, lista de tasas preferenciales vigentes
