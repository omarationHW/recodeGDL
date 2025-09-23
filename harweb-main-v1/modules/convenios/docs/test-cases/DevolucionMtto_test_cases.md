# Casos de Prueba para DevolucionMtto

## 1. Alta de devolución válida
- **Input:** Todos los campos requeridos llenos y válidos
- **Acción:** create_devolucion
- **Esperado:** success=true, devolución creada, aparece en list_devoluciones

## 2. Alta con campos faltantes
- **Input:** Falta remesa/oficio/folio/importe
- **Acción:** create_devolucion
- **Esperado:** success=false, mensaje de error de validación

## 3. Modificación de devolución
- **Input:** id_devolucion existente, nuevos datos válidos
- **Acción:** update_devolucion
- **Esperado:** success=true, datos actualizados

## 4. Eliminación de devolución
- **Input:** id_devolucion existente
- **Acción:** delete_devolucion
- **Esperado:** success=true, devolución ya no aparece en list_devoluciones

## 5. Búsqueda de contrato inexistente
- **Input:** colonia/calle/folio no existentes
- **Acción:** get_contrato
- **Esperado:** success=false, mensaje 'Contrato no encontrado o cancelado'

## 6. Validación de importe negativo
- **Input:** importe < 0
- **Acción:** create_devolucion
- **Esperado:** success=false, mensaje de error

## 7. Listado de devoluciones
- **Input:** id_convenio válido
- **Acción:** list_devoluciones
- **Esperado:** success=true, data es array de devoluciones
