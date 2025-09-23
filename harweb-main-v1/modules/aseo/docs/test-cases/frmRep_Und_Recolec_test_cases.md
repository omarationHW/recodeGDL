## Casos de Prueba para Unidades de Recolección

### 1. Consulta básica
- **Entrada:** ejercicio=2024, order=1
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2024, order: 1 } }
- **Esperado:** Respuesta success=true, data con lista ordenada por ctrol_recolec

### 2. Consulta ordenada por descripción
- **Entrada:** ejercicio=2024, order=3
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2024, order: 3 } }
- **Esperado:** Respuesta success=true, data ordenada por descripción ascendente

### 3. Alta de unidad duplicada
- **Entrada:** ejercicio=2024, cve='A', descripcion='Unidad A', costo_unidad=100, costo_exed=120
- **Acción:** POST /api/execute { action: 'und_recolec_create', params: { ... } }
- **Esperado:** Respuesta success=true, data=['YA EXISTE']

### 4. Baja de unidad referenciada
- **Entrada:** ctrol=101 (referenciado en contratos)
- **Acción:** POST /api/execute { action: 'und_recolec_delete', params: { ctrol: 101 } }
- **Esperado:** Respuesta success=true, data=['NO SE PUEDE BORRAR: EXISTEN CONTRATOS']

### 5. Modificación de unidad
- **Entrada:** ctrol=102, descripcion='Modificada', costo_unidad=200, costo_exed=250
- **Acción:** POST /api/execute { action: 'und_recolec_update', params: { ... } }
- **Esperado:** Respuesta success=true, data=['OK']

### 6. Consulta sin resultados
- **Entrada:** ejercicio=2099, order=1
- **Acción:** POST /api/execute { action: 'und_recolec_report', params: { ejercicio: 2099, order: 1 } }
- **Esperado:** Respuesta success=true, data=[]
