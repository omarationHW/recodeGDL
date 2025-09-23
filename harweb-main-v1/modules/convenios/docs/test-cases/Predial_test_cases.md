## Casos de Prueba para Formulario Predial

### Caso 1: Búsqueda de Cuenta Existente
- **Entrada:** recaud=1, urbrus='U', cuenta=123456
- **Acción:** buscarCuenta
- **Esperado:** Devuelve datos del contribuyente y cuenta

### Caso 2: Búsqueda de Cuenta Inexistente
- **Entrada:** recaud=99, urbrus='Z', cuenta=999999
- **Acción:** buscarCuenta
- **Esperado:** Mensaje de error 'Cuenta no encontrada'

### Caso 3: Cálculo de Liquidación
- **Entrada:** cvecuenta=123456, asal=1900, bsal=1, asalf=2024, bsalf=6
- **Acción:** calcularLiquidacion
- **Esperado:** Devuelve detalle de liquidación con campos correctos

### Caso 4: Confirmar Pago Efectivo
- **Entrada:** cvecuenta=123456, usuario_id=1, forma_pago='efectivo', importe=1000, detalle=[...]
- **Acción:** confirmarPago
- **Esperado:** Pago registrado correctamente, folio generado

### Caso 5: Confirmar Pago con Cheque
- **Entrada:** cvecuenta=654321, usuario_id=2, forma_pago='cheque', importe=1500, detalle=[...], cheque={banco:'BANAMEX', numero:'1234567', importe:1500}
- **Acción:** confirmarPago
- **Esperado:** Pago registrado correctamente, folio generado

### Caso 6: Mostrar Descuentos
- **Entrada:** cvecuenta=123456, asal=1900, bsal=1, asalf=2024, bsalf=6
- **Acción:** mostrarDescuentos
- **Esperado:** Lista de descuentos aplicada

### Caso 7: Imprimir Recibo
- **Entrada:** cvepago=10001
- **Acción:** imprimirRecibo
- **Esperado:** Devuelve datos para impresión del recibo
