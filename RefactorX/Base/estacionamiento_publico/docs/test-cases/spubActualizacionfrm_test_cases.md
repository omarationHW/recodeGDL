# Casos de Prueba

## 1. Modificación de Estacionamiento
- **Entrada:** Número de estacionamiento existente, cambio de teléfono
- **Acción:** updateEstacionamiento
- **Esperado:** Respuesta success=true, mensaje 'Actualización exitosa', datos reflejados en consulta posterior

## 2. Baja de Estacionamiento
- **Entrada:** ID de estacionamiento, folio, fecha de baja
- **Acción:** bajaEstacionamiento
- **Esperado:** Respuesta success=true, mensaje 'Baja exitosa', campo movto_cve='C' en base de datos

## 3. Aplicación de Pago a Adeudo
- **Entrada:** pubmain_id, axo, mes, tipo, fecha, reca, caja, operacion
- **Acción:** actualizaPubPago
- **Esperado:** Respuesta success=true, mensaje 'Pago aplicado correctamente', adeudo marcado como pagado

## 4. Consulta de Adeudos
- **Entrada:** pubid
- **Acción:** getAdeudos
- **Esperado:** Lista de adeudos pendientes para el estacionamiento

## 5. Eliminación de Adeudo
- **Entrada:** pubmain_id, axo, mes
- **Acción:** deleteAdeudo
- **Esperado:** Adeudos hasta el año/mes especificado eliminados, success=true

## 6. Incremento de Cajones
- **Entrada:** pubmain_id, cajones, fecha, oficio
- **Acción:** spPubMovtos (opc=1)
- **Esperado:** cupo incrementado en la base de datos, success=true

## 7. Cambio de Categoría
- **Entrada:** pubmain_id, categoria, fecha, oficio
- **Acción:** spPubMovtos (opc=2)
- **Esperado:** pubcategoria_id actualizado, success=true
