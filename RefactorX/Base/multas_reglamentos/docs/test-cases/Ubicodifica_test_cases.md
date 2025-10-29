# Casos de Prueba para Ubicodifica

## 1. Alta de Codificación Exitosa
- **Entrada:** cvecuenta válida sin codificación previa
- **Acción:** alta_ubicodifica
- **Resultado esperado:** Registro creado, estado 'Vigente', usuario y fecha correctos

## 2. Alta de Codificación Duplicada
- **Entrada:** cvecuenta ya existente en ubicacion_req
- **Acción:** alta_ubicodifica
- **Resultado esperado:** Error 409, mensaje 'Ya existe codificación para esta cuenta'

## 3. Actualización de Codificación Exitosa
- **Entrada:** cvecuenta existente, estado 'Cancelada'
- **Acción:** actualiza_ubicodifica
- **Resultado esperado:** Estado cambia a 'Vigente', fechas y usuario actualizados

## 4. Cancelación Exitosa
- **Entrada:** cvecuenta existente, estado 'Vigente'
- **Acción:** cancela_ubicodifica
- **Resultado esperado:** Estado cambia a 'Cancelada', fecha de baja y usuario registrados

## 5. Cancelación de Registro ya Cancelado
- **Entrada:** cvecuenta existente, estado 'Cancelada'
- **Acción:** cancela_ubicodifica
- **Resultado esperado:** Error 409, mensaje 'Ubicación ya está cancelada'

## 6. Listado de Cuentas sin Zona/Subzona
- **Entrada:** recaudadora, cuenta inicial y final válidos
- **Acción:** listado_ubicodifica
- **Resultado esperado:** Tabla con cuentas sin zona/subzona

## 7. Consulta de Datos de Cuenta Inexistente
- **Entrada:** cvecuenta inexistente
- **Acción:** get_ubicodifica_data
- **Resultado esperado:** Error 400 o 404, mensaje adecuado
