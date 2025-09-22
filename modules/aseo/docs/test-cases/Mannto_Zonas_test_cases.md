# Casos de Prueba para Catálogo de Zonas

## 1. Alta de Zona Nueva
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur'
- **Acción:** ZONAS_CREATE
- **Esperado:** success=true, message='Zona creada correctamente', la zona aparece en la lista

## 2. Alta de Zona Duplicada
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur'
- **Acción:** ZONAS_CREATE
- **Esperado:** success=false, message='Ya existe la zona/sub-zona'

## 3. Edición de Zona
- **Entrada:** zona=20, sub_zona=2, descripcion='Zona Comercial Sur Actualizada'
- **Acción:** ZONAS_UPDATE
- **Esperado:** success=true, message='Zona actualizada correctamente', la descripción se actualiza

## 4. Eliminación de Zona sin Dependencias
- **Entrada:** ctrol_zona=8
- **Acción:** ZONAS_DELETE
- **Esperado:** success=true, message='Zona eliminada correctamente', la zona desaparece de la lista

## 5. Eliminación de Zona con Dependencias
- **Entrada:** ctrol_zona=5 (tiene empresas asociadas)
- **Acción:** ZONAS_DELETE
- **Esperado:** success=false, message='Existen empresas con esta zona. No se puede borrar.'

## 6. Validación de Campos Vacíos
- **Entrada:** zona='', sub_zona='', descripcion=''
- **Acción:** ZONAS_CREATE
- **Esperado:** success=false, message de validación indicando campos requeridos

## 7. Consulta de Empresas Dependientes
- **Entrada:** ctrol_zona=5
- **Acción:** ZONAS_EMPRESA_DEPENDENCY
- **Esperado:** success=true, data contiene lista de empresas con ctrol_zona=5
