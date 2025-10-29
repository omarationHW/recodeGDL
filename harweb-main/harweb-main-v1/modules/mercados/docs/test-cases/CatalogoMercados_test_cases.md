## Casos de Prueba para Catálogo de Mercados

### 1. Alta de Mercado - Datos Correctos
- **Entrada:** Todos los campos obligatorios llenos y válidos
- **Acción:** Enviar action 'create' con datos válidos
- **Esperado:** Respuesta success=true, el mercado aparece en la lista

### 2. Alta de Mercado - Campo Requerido Faltante
- **Entrada:** Falta 'descripcion'
- **Acción:** Enviar action 'create' sin descripción
- **Esperado:** Respuesta success=false, message indica campo requerido

### 3. Modificación de Mercado - Cambio de Descripción
- **Entrada:** Mercado existente, nueva descripción
- **Acción:** Enviar action 'update' con nueva descripción
- **Esperado:** Respuesta success=true, la descripción se actualiza

### 4. Eliminación de Mercado
- **Entrada:** Oficina y número de mercado válidos
- **Acción:** Enviar action 'delete'
- **Esperado:** Respuesta success=true, el mercado ya no aparece en la lista

### 5. Reporte de Mercados
- **Entrada:** action 'report', oficina=null
- **Acción:** Enviar petición
- **Esperado:** Respuesta success=true, data contiene todos los mercados

### 6. Error de Integridad
- **Entrada:** Crear mercado con oficina/núm. mercado duplicados
- **Acción:** Enviar action 'create' con datos ya existentes
- **Esperado:** Respuesta success=false, message de error de duplicidad

### 7. Seguridad - Usuario no autenticado
- **Entrada:** No autenticado
- **Acción:** Cualquier acción
- **Esperado:** HTTP 401 Unauthorized
