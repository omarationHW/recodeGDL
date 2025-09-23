# Casos de Prueba para Mannto_Operaciones

## 1. Alta de Clave de Operación
- **Entrada**: { "action": "create", "data": { "cve_operacion": "X", "descripcion": "PRUEBA X" } }
- **Esperado**: Respuesta success true, mensaje 'Clave creada', la clave aparece en el listado.

## 2. Alta de Clave Duplicada
- **Entrada**: { "action": "create", "data": { "cve_operacion": "X", "descripcion": "OTRA" } }
- **Esperado**: Respuesta success false, mensaje 'Ya existe la clave de operación'.

## 3. Edición de Descripción
- **Entrada**: { "action": "update", "data": { "cve_operacion": "X", "descripcion": "NUEVA DESCRIPCION" } }
- **Esperado**: Respuesta success true, mensaje 'Clave actualizada', la descripción cambia en el listado.

## 4. Eliminación con Pagos Asociados
- **Precondición**: Existen pagos con ctrol_operacion = X.
- **Entrada**: { "action": "delete", "data": { "ctrol_operacion": X } }
- **Esperado**: Respuesta success false, mensaje 'No se puede eliminar: existen pagos asociados'.

## 5. Eliminación sin Pagos Asociados
- **Precondición**: No existen pagos con ctrol_operacion = Y.
- **Entrada**: { "action": "delete", "data": { "ctrol_operacion": Y } }
- **Esperado**: Respuesta success true, mensaje 'Clave eliminada'.

## 6. Listado de Claves
- **Entrada**: { "action": "list" }
- **Esperado**: Respuesta success true, data es arreglo de claves existentes.
