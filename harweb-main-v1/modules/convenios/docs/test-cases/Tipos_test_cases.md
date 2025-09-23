# Casos de Prueba para Tipos de Convenio

## 1. Alta exitosa
- **Input:** tipo=20, descripcion="PRUEBA TIPO"
- **Acción:** add_tipo
- **Esperado:** success=true, mensaje de éxito, tipo aparece en la lista

## 2. Alta duplicada
- **Input:** tipo=20, descripcion="DUPLICADO"
- **Acción:** add_tipo (tipo ya existe)
- **Esperado:** success=false, mensaje de error de duplicidad

## 3. Edición exitosa
- **Input:** tipo=20, descripcion="TIPO EDITADO"
- **Acción:** update_tipo
- **Esperado:** success=true, descripción actualizada

## 4. Edición de tipo inexistente
- **Input:** tipo=999, descripcion="NO EXISTE"
- **Acción:** update_tipo
- **Esperado:** success=false, mensaje de error

## 5. Eliminación exitosa
- **Input:** tipo=20
- **Acción:** delete_tipo
- **Esperado:** success=true, tipo ya no aparece en la lista

## 6. Eliminación de tipo inexistente
- **Input:** tipo=999
- **Acción:** delete_tipo
- **Esperado:** success=false, mensaje de error

## 7. Listado de tipos
- **Acción:** get_tipos
- **Esperado:** success=true, data es arreglo de tipos existentes
