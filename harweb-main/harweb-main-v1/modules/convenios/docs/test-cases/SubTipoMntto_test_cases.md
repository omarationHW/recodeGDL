# Casos de Prueba SubTipoMntto

## 1. Alta exitosa de SubTipo
- **Input:** tipo=1, subtipo=2, desc_subtipo="SUBTIPO TEST", cuenta_ingreso=12345, id_usuario=1
- **Acción:** create
- **Esperado:** success=true, message="SubTipo creado correctamente"

## 2. Alta duplicada
- **Input:** tipo=1, subtipo=2, desc_subtipo="DUPLICADO", cuenta_ingreso=11111, id_usuario=1
- **Acción:** create
- **Esperado:** success=false, message contiene "Ya existe"

## 3. Modificación exitosa
- **Input:** tipo=1, subtipo=2, desc_subtipo="SUBTIPO MODIFICADO", cuenta_ingreso=54321, id_usuario=1
- **Acción:** update
- **Esperado:** success=true, message="SubTipo actualizado correctamente"

## 4. Modificación de inexistente
- **Input:** tipo=99, subtipo=99, desc_subtipo="NO EXISTE", cuenta_ingreso=99999, id_usuario=1
- **Acción:** update
- **Esperado:** success=false, message contiene "No existe"

## 5. Listado de SubTipos
- **Acción:** list
- **Esperado:** success=true, data es array de registros

## 6. Catálogo de Tipos
- **Acción:** catalog_tipos
- **Esperado:** success=true, data es array de tipos

## 7. Catálogo de Cuentas
- **Acción:** catalog_cuentas
- **Esperado:** success=true, data es array de cuentas
