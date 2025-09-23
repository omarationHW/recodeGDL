## Casos de Prueba para Catálogo de Mercados

### 1. Alta de mercado válido
- **Entrada:** Todos los campos requeridos, mercado no existente
- **Acción:** insertCatalogo
- **Esperado:** success=true, message='Mercado insertado correctamente', aparece en listado

### 2. Alta de mercado duplicado
- **Entrada:** Clave compuesta (oficina, num_mercado_nvo) ya existente
- **Acción:** insertCatalogo
- **Esperado:** success=false, message='Ya existe un mercado con esa clave'

### 3. Alta de mercado sin cuenta de energía (pregunta='N')
- **Entrada:** cuenta_energia=null
- **Acción:** insertCatalogo
- **Esperado:** success=true, cuenta_energia en NULL en base de datos

### 4. Edición de mercado existente
- **Entrada:** Modificar nombre y/o cuenta_ingreso
- **Acción:** updateCatalogo
- **Esperado:** success=true, message='Mercado actualizado correctamente', datos actualizados

### 5. Edición de mercado inexistente
- **Entrada:** Clave compuesta no existente
- **Acción:** updateCatalogo
- **Esperado:** success=false, message='No se encontró el mercado para actualizar'

### 6. Listado de mercados
- **Acción:** getCatalogoList
- **Esperado:** success=true, data contiene lista de mercados

### 7. Validación de campos requeridos
- **Entrada:** Falta algún campo obligatorio
- **Acción:** insertCatalogo o updateCatalogo
- **Esperado:** success=false, message de validación
