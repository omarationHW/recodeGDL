## Casos de Prueba para Catálogo de Condueños

### 1. Alta exitosa de condueño persona física
- **Entrada:** Datos completos válidos, suma de porcentajes = 100, RFC único.
- **Esperado:** Registro creado, aparece en la lista, suma de porcentajes correcta.

### 2. Alta de condueño con RFC duplicado
- **Entrada:** RFC ya existente en otro contribuyente.
- **Esperado:** Error de validación, no se guarda el registro.

### 3. Alta de condueño con suma de porcentajes ≠ 100
- **Entrada:** Suma de porcentajes de todos los condueños ≠ 100.
- **Esperado:** Error visual en frontend, no permite guardar hasta corregir.

### 4. Eliminación lógica de condueño
- **Entrada:** Solicitud de eliminación de un condueño vigente.
- **Esperado:** Registro marcado como cancelado, desaparece de la lista principal.

### 5. Restauración de condueño cancelado
- **Entrada:** Solicitud de restauración de un condueño con vigencia 'C'.
- **Esperado:** Registro vuelve a estar vigente y aparece en la lista.

### 6. Consulta de historial de cambios
- **Entrada:** Solicitud de historial para una cuenta catastral.
- **Esperado:** Lista de todos los cambios (altas, bajas, modificaciones) con fecha y usuario.

### 7. Agregar nueva colonia
- **Entrada:** Nombre de colonia, cvepoblacion, codpos, usuario.
- **Esperado:** Colonia agregada al catálogo y disponible en el formulario.
