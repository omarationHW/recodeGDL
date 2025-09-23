## Casos de Prueba para formabuscalle

### Caso 1: Búsqueda parcial
- **Descripción:** Buscar calles que contengan 'CENTRO'.
- **Pasos:**
  1. Ingresar 'CENTRO' en el campo de filtro.
  2. Verificar que la tabla muestre solo calles con 'CENTRO' en el nombre.
- **Resultado esperado:** Solo aparecen calles con 'CENTRO' en el nombre, excluyendo las ocultas.

### Caso 2: Listado completo
- **Descripción:** Mostrar todas las calles disponibles.
- **Pasos:**
  1. Dejar el campo de filtro vacío.
  2. Verificar que la tabla muestre todas las calles, excluyendo las ocultas.
- **Resultado esperado:** Se listan todas las calles activas.

### Caso 3: Selección y confirmación
- **Descripción:** Seleccionar una calle y confirmar.
- **Pasos:**
  1. Buscar 'REVOLUCIÓN'.
  2. Seleccionar la primera calle de la lista.
  3. Presionar 'Aceptar'.
- **Resultado esperado:** Se muestra el ID de la calle seleccionada.

### Caso 4: Sin resultados
- **Descripción:** Buscar una calle inexistente.
- **Pasos:**
  1. Ingresar 'ZZZZZZ' en el filtro.
  2. Verificar que la tabla muestre mensaje de 'No se encontraron calles'.
- **Resultado esperado:** La tabla está vacía y muestra el mensaje correspondiente.

### Caso 5: Calles ocultas
- **Descripción:** Verificar que las calles ocultas no aparecen.
- **Pasos:**
  1. Buscar una calle que está en `c_calles_escondidas` con vigente = 'V' y num_tag = 8000.
  2. Verificar que no aparece en la tabla.
- **Resultado esperado:** La calle oculta no aparece en los resultados.