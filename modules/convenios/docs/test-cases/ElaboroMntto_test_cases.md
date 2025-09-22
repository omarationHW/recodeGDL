# Casos de Prueba para ElaboroMntto

## 1. Alta exitosa
- **Entrada:** Todos los campos válidos
- **Acción:** create
- **Resultado esperado:** success=true, mensaje 'Registro creado', data=ID generado

## 2. Alta con campos vacíos
- **Entrada:** Falta id_usu_titular
- **Acción:** create
- **Resultado esperado:** success=false, mensaje de error indicando campo faltante

## 3. Consulta de titular_info con IDs válidos
- **Entrada:** id_rec, id_usu_titular, id_usu_elaboro válidos
- **Acción:** titular_info
- **Resultado esperado:** success=true, data contiene nombres y recaudadora

## 4. Consulta de titular_info con IDs inexistentes
- **Entrada:** id_rec=999, id_usu_titular=999, id_usu_elaboro=999
- **Acción:** titular_info
- **Resultado esperado:** success=true, data vacía

## 5. Edición exitosa
- **Entrada:** id_control existente, nuevos valores de iniciales
- **Acción:** update
- **Resultado esperado:** success=true, mensaje 'Registro actualizado', data=1

## 6. Eliminación exitosa
- **Entrada:** id_control existente
- **Acción:** delete
- **Resultado esperado:** success=true, mensaje 'Registro eliminado', data=1

## 7. Eliminación de registro inexistente
- **Entrada:** id_control=99999
- **Acción:** delete
- **Resultado esperado:** success=true, data=1 (o success=false si se fuerza validación de existencia)

## 8. Listado general
- **Entrada:** acción list
- **Resultado esperado:** success=true, data es array de registros
