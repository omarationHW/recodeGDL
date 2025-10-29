## Casos de Prueba para Descuentos Predial

### 1. Alta de Descuento Correcta
- **Entrada:** Datos válidos, cuenta sin descuento vigente.
- **Acción:** create
- **Resultado esperado:** status=success, descuento creado, estado=Vigente.

### 2. Alta de Descuento Duplicado
- **Entrada:** Datos válidos, pero ya existe descuento vigente para el mismo periodo.
- **Acción:** create
- **Resultado esperado:** status=error, mensaje de duplicidad.

### 3. Baja de Descuento
- **Entrada:** ID de descuento vigente, motivo.
- **Acción:** delete
- **Resultado esperado:** status=success, estado=Cancelado, motivo registrado.

### 4. Reactivación de Descuento
- **Entrada:** ID de descuento cancelado.
- **Acción:** reactivate
- **Resultado esperado:** status=success, estado=Vigente.

### 5. Edición de Descuento
- **Entrada:** ID de descuento vigente, nuevos datos válidos.
- **Acción:** update
- **Resultado esperado:** status=success, datos actualizados.

### 6. Consulta de Catálogos
- **Entrada:** action=catalogs
- **Resultado esperado:** status=success, catálogos de tipos e instituciones.

### 7. Listado de Descuentos
- **Entrada:** action=list, cvecuenta existente
- **Resultado esperado:** status=success, array de descuentos.

### 8. Consulta de Descuento por ID
- **Entrada:** action=get, id existente
- **Resultado esperado:** status=success, datos del descuento.

### 9. Baja de Descuento ya Cancelado
- **Entrada:** ID de descuento ya cancelado
- **Acción:** delete
- **Resultado esperado:** status=error, mensaje de que ya está cancelado.

### 10. Alta con datos incompletos
- **Entrada:** Faltan campos requeridos
- **Acción:** create
- **Resultado esperado:** status=error, mensaje de validación.
