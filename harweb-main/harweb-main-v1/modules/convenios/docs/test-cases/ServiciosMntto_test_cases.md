## Casos de Prueba para ServiciosMntto

### 1. Alta de Servicio (Exitoso)
- **Entrada:**
  - servicio: 200
  - descripcion: 'DRENAJE'
  - serv_obra94: 15
- **Acción:** servicios_create
- **Esperado:**
  - Código 200, success=true, data contiene el servicio creado.
  - El registro aparece en la consulta general.

### 2. Alta de Servicio (Falla por descripción vacía)
- **Entrada:**
  - servicio: 201
  - descripcion: ''
  - serv_obra94: 16
- **Acción:** servicios_create
- **Esperado:**
  - Código 200, success=false, message='The descripcion field is required.'

### 3. Edición de Servicio (Exitoso)
- **Precondición:** Existe servicio 200
- **Entrada:**
  - servicio: 200
  - descripcion: 'DRENAJE SANITARIO'
  - serv_obra94: 15
- **Acción:** servicios_update
- **Esperado:**
  - Código 200, success=true, data contiene el servicio actualizado.

### 4. Eliminación de Servicio (Exitoso)
- **Precondición:** Existe servicio 200
- **Entrada:**
  - servicio: 200
- **Acción:** servicios_delete
- **Esperado:**
  - Código 200, success=true
  - El registro ya no aparece en la consulta general.

### 5. Consulta de Servicios
- **Acción:** servicios_list
- **Esperado:**
  - Código 200, success=true, data es un array de servicios.

### 6. Consulta de Servicio por ID
- **Entrada:**
  - servicio: 101
- **Acción:** servicios_get
- **Esperado:**
  - Código 200, success=true, data contiene el servicio solicitado.
