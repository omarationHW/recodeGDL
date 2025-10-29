# Casos de Prueba: Catálogo de Tipos de Empresa

## 1. Alta exitosa
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.create', params: { tipo_empresa: 'D', descripcion: 'Distribuidor' } }
- **Esperado:** success=true, message='Tipo de empresa creado correctamente', el registro aparece en la lista

## 2. Alta duplicada
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.create', params: { tipo_empresa: 'D', descripcion: 'Distribuidor' } }
- **Esperado:** success=false, message='Ya existe el tipo de empresa'

## 3. Edición exitosa
- **Entrada:** tipo_empresa='D', descripcion='Distribuidor Mayorista'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.update', params: { tipo_empresa: 'D', descripcion: 'Distribuidor Mayorista' } }
- **Esperado:** success=true, message='Tipo de empresa actualizado correctamente'

## 4. Edición de tipo inexistente
- **Entrada:** tipo_empresa='Z', descripcion='Zoológico'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.update', params: { tipo_empresa: 'Z', descripcion: 'Zoológico' } }
- **Esperado:** success=false, message='No existe el tipo de empresa'

## 5. Eliminación exitosa
- **Precondición:** No existen empresas asociadas a ctrol_emp=10
- **Entrada:** ctrol_emp=10
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.delete', params: { ctrol_emp: 10 } }
- **Esperado:** success=true, message='Tipo de empresa eliminado correctamente'

## 6. Eliminación con empresas asociadas
- **Precondición:** Existen empresas con ctrol_emp=2
- **Entrada:** ctrol_emp=2
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.delete', params: { ctrol_emp: 2 } }
- **Esperado:** success=false, message='No se puede eliminar: existen empresas asociadas.'

## 7. Consulta de todos los tipos
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.list' }
- **Esperado:** success=true, data=array de tipos de empresa

## 8. Consulta de tipo específico
- **Entrada:** tipo_empresa='A'
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.get', params: { tipo_empresa: 'A' } }
- **Esperado:** success=true, data=registro correspondiente

## 9. Validación de eliminación permitida
- **Entrada:** ctrol_emp=99 (sin empresas asociadas)
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.canDelete', params: { ctrol_emp: 99 } }
- **Esperado:** success=true, data.can_delete=true

## 10. Validación de eliminación NO permitida
- **Entrada:** ctrol_emp=1 (con empresas asociadas)
- **Acción:** POST /api/execute { eRequest: 'TiposEmp.canDelete', params: { ctrol_emp: 1 } }
- **Esperado:** success=true, data.can_delete=false
