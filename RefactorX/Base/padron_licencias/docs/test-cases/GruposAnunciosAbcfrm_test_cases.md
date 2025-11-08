## Casos de Prueba para Grupos de Anuncios

### 1. Alta de grupo válido
- **Acción:** Agregar grupo con descripción 'PUBLICIDAD EXTERIOR'.
- **Esperado:** Grupo creado, aparece en la lista, mensaje de éxito.

### 2. Alta de grupo con descripción vacía
- **Acción:** Intentar agregar grupo sin descripción.
- **Esperado:** Error de validación en frontend, no se envía petición.

### 3. Modificación de grupo existente
- **Acción:** Editar grupo id=2, cambiar descripción a 'ANUNCIOS DIGITALES'.
- **Esperado:** Grupo actualizado, mensaje de éxito.

### 4. Eliminación de grupo
- **Acción:** Eliminar grupo id=4.
- **Esperado:** Grupo eliminado, mensaje de éxito, ya no aparece en la lista.

### 5. Búsqueda parcial
- **Acción:** Buscar 'EXTERIOR' en filtro.
- **Esperado:** Sólo aparecen grupos que contienen 'EXTERIOR' en la descripción.

### 6. Edición cancelada
- **Acción:** Iniciar edición y luego cancelar.
- **Esperado:** No hay cambios, formulario se limpia.

### 7. Eliminación de grupo inexistente
- **Acción:** Intentar eliminar grupo con id=9999.
- **Esperado:** Mensaje de error, no afecta a la lista.

### 8. Duplicidad de descripción
- **Acción:** Agregar grupo con descripción igual a uno existente (si hay restricción).
- **Esperado:** Si hay restricción, error; si no, se permite duplicado.
