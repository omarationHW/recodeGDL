## Casos de Prueba para Empresas

### 1. Alta de Empresa Correcta
- **Entrada:**
  - ctrol_emp: 9
  - descripcion: "EMPRESA DE PRUEBA S.A. DE C.V."
  - representante: "JUAN PEREZ"
- **Acción:** empresas.create
- **Esperado:** success=true, message='Empresa creada correctamente', data.num_empresa > 0

### 2. Alta de Empresa Duplicada
- **Entrada:**
  - ctrol_emp: 9
  - descripcion: "EMPRESA DE PRUEBA S.A. DE C.V."
  - representante: "JUAN PEREZ"
- **Acción:** empresas.create (con datos ya existentes)
- **Esperado:** success=false, message contiene 'Ya existe'

### 3. Modificación de Empresa
- **Entrada:**
  - num_empresa: 10
  - ctrol_emp: 9
  - descripcion: "EMPRESA MODIFICADA S.A. DE C.V."
  - representante: "MARIA LOPEZ"
- **Acción:** empresas.update
- **Esperado:** success=true, message='Empresa actualizada correctamente'

### 4. Eliminación de Empresa con Contratos
- **Entrada:**
  - num_empresa: 12
  - ctrol_emp: 9
- **Acción:** empresas.delete
- **Precondición:** La empresa tiene contratos asociados
- **Esperado:** success=false, message contiene 'No se puede eliminar'

### 5. Eliminación de Empresa sin Contratos
- **Entrada:**
  - num_empresa: 11
  - ctrol_emp: 9
- **Acción:** empresas.delete
- **Precondición:** La empresa NO tiene contratos asociados
- **Esperado:** success=true, message='Empresa eliminada correctamente'

### 6. Listado de Empresas
- **Acción:** empresas.list
- **Esperado:** success=true, data es array de empresas

### 7. Consulta de Empresa por ID
- **Entrada:**
  - num_empresa: 10
  - ctrol_emp: 9
- **Acción:** empresas.get
- **Esperado:** success=true, data contiene la empresa solicitada
