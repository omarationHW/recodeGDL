## Casos de Prueba para ABC_Tipos_Aseo

### 1. Alta exitosa
- **Entrada:** tipo_aseo='Z', descripcion='Aseo Zona Z', cta_aplicacion=100001, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=true, mensaje de éxito, registro aparece en la lista

### 2. Alta duplicada
- **Entrada:** tipo_aseo='O', descripcion='Aseo Ordinario', cta_aplicacion=100001, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=false, mensaje 'Ya existe el tipo de aseo'

### 3. Alta con cuenta de aplicación inexistente
- **Entrada:** tipo_aseo='Y', descripcion='Aseo Y', cta_aplicacion=999999, usuario=1
- **Acción:** tipos_aseo.create
- **Esperado:** success=false, mensaje 'La cuenta de aplicación no existe'

### 4. Edición exitosa
- **Entrada:** ctrol_aseo=3, tipo_aseo='H', descripcion='Aseo Hospitalario Mod', cta_aplicacion=100002, usuario=1
- **Acción:** tipos_aseo.update
- **Esperado:** success=true, mensaje de éxito, datos actualizados

### 5. Edición con cuenta de aplicación inexistente
- **Entrada:** ctrol_aseo=3, tipo_aseo='H', descripcion='Aseo Hospitalario Mod', cta_aplicacion=999999, usuario=1
- **Acción:** tipos_aseo.update
- **Esperado:** success=false, mensaje 'La cuenta de aplicación no existe'

### 6. Eliminación exitosa
- **Entrada:** ctrol_aseo=12, usuario=1 (sin contratos asociados)
- **Acción:** tipos_aseo.delete
- **Esperado:** success=true, mensaje de éxito

### 7. Eliminación fallida por contratos asociados
- **Entrada:** ctrol_aseo=2, usuario=1 (con contratos asociados)
- **Acción:** tipos_aseo.delete
- **Esperado:** success=false, mensaje 'Existen contratos con este tipo de aseo. No se puede borrar.'

### 8. Consulta de lista
- **Acción:** tipos_aseo.list
- **Esperado:** success=true, data es arreglo de registros

### 9. Consulta individual
- **Entrada:** ctrol_aseo=2
- **Acción:** tipos_aseo.get
- **Esperado:** success=true, data es el registro solicitado
