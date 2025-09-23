## Casos de Prueba para Autorización de Descuentos Predial

### 1. Alta de Descuento Correcto
- **Entrada:** Todos los campos obligatorios llenos, bimestre inicial <= final, sin traslape de periodos.
- **Acción:** create
- **Resultado esperado:** status=ok, mensaje 'Descuento creado correctamente', registro visible en tabla.

### 2. Alta con Bimestre Inicial Mayor que Final
- **Entrada:** bimini=6, bimfin=1
- **Acción:** create
- **Resultado esperado:** status=error, mensaje 'Error en el rango de bimestres'.

### 3. Alta con Traslape de Periodos
- **Entrada:** Ya existe descuento vigente para bimini=1, bimfin=6. Se intenta crear otro para bimini=3, bimfin=4.
- **Acción:** create
- **Resultado esperado:** status=error, mensaje 'Ya existe un descuento vigente sobre este periodo'.

### 4. Cancelación de Descuento Vigente
- **Entrada:** id de descuento vigente
- **Acción:** cancel
- **Resultado esperado:** status=ok, mensaje 'Descuento cancelado correctamente', status='C' en tabla.

### 5. Reactivación de Descuento Cancelado
- **Entrada:** id de descuento cancelado
- **Acción:** reactivate
- **Resultado esperado:** status=ok, mensaje 'Descuento reactivado correctamente', status='V' en tabla.

### 6. Edición de Descuento
- **Entrada:** id de descuento vigente, nuevos datos válidos
- **Acción:** update
- **Resultado esperado:** status=ok, mensaje 'Descuento actualizado correctamente', datos actualizados en tabla.

### 7. Catálogos
- **Entrada:** acción catalogs
- **Acción:** catalogs
- **Resultado esperado:** status=ok, data con descTypes e institutions.
