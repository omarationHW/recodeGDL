# Casos de Prueba

## Caso 1: Buscar pago existente
- **Entrada:** recaud='001', folio='12345', caja='A1', fecha='2024-06-01', importe=1500.00
- **Acción:** Buscar pago
- **Esperado:** Se muestra el pago y requerimientos asociados.

## Caso 2: Buscar pago inexistente
- **Entrada:** recaud='999', folio='00000', caja='ZZ', fecha='2024-01-01', importe=9999.99
- **Acción:** Buscar pago
- **Esperado:** Mensaje de 'Pago no encontrado'.

## Caso 3: Aplicar traslado a futuros pagos
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** tipo_aplicacion='futuros', usuario='admin'
- **Acción:** Aplicar traslado
- **Esperado:** Mensaje de éxito 'Traslado aplicado correctamente.'

## Caso 4: Aplicar traslado con tipo inválido
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** tipo_aplicacion='otro', usuario='admin'
- **Acción:** Aplicar traslado
- **Esperado:** Mensaje de error 'Tipo de aplicación no válido'.

## Caso 5: Liquidar pago
- **Precondición:** Pago buscado y encontrado (id=1001)
- **Entrada:** usuario='admin'
- **Acción:** Liquidar
- **Esperado:** Mensaje de éxito 'Pago liquidado correctamente.'
