# Casos de Prueba para ABC_Tipos_Emp

## 1. Alta exitosa
- **Acción:** create_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "X", "descripcion": "Experimental" }
- **Resultado esperado:** success=true, message='Tipo de empresa creado correctamente', el registro aparece en el listado.

## 2. Alta duplicada
- **Acción:** create_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "X", "descripcion": "Experimental" }
- **Resultado esperado:** success=false, message='Ya existe un tipo de empresa con ese control'.

## 3. Edición exitosa
- **Acción:** update_tipos_emp
- **Payload:** { "ctrol_emp": 20, "tipo_empresa": "Y", "descripcion": "Experimental Modificado" }
- **Resultado esperado:** success=true, message='Tipo de empresa actualizado correctamente', el registro se actualiza.

## 4. Eliminación exitosa (sin empresas asociadas)
- **Acción:** delete_tipos_emp
- **Payload:** { "ctrol_emp": 20 }
- **Resultado esperado:** success=true, message='Tipo de empresa eliminado correctamente', el registro desaparece del listado.

## 5. Eliminación fallida (con empresas asociadas)
- **Acción:** delete_tipos_emp
- **Payload:** { "ctrol_emp": 9 }
- **Resultado esperado:** success=false, message='No se puede eliminar: existen empresas asociadas a este tipo'.

## 6. Consulta individual
- **Acción:** get_tipos_emp
- **Payload:** { "ctrol_emp": 10 }
- **Resultado esperado:** success=true, data contiene el registro correspondiente.

## 7. Listado general
- **Acción:** list_tipos_emp
- **Payload:** { }
- **Resultado esperado:** success=true, data contiene todos los tipos de empresa ordenados por ctrol_emp.
