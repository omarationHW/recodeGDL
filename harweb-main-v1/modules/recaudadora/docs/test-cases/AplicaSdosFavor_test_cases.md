# Casos de Prueba para AplicaSdosFavor

## Caso 1: Buscar solicitud existente
- **Input:** folio=12345, axofol=2024
- **Acción:** buscarSolicitud
- **Esperado:** Devuelve datos de la solicitud, cuenta y contribuyente

## Caso 2: Buscar solicitud inexistente
- **Input:** folio=99999, axofol=2024
- **Acción:** buscarSolicitud
- **Esperado:** Error 'No se encuentra la inconformidad'

## Caso 3: Alta de saldo a favor
- **Input:** id_solic=1, cvecuenta=1001, importe=1500.00, usuario='admin'
- **Acción:** altaSaldoFavor
- **Esperado:** Mensaje de éxito y registro en sdosfavor

## Caso 4: Aplicar saldo a favor insuficiente
- **Input:** id_solic=1, cvecuenta=1001, bimi=1, axoi=2024, bimf=3, axof=2024, importe=99999.00, usuario='admin'
- **Acción:** aplicarSaldoFavor
- **Esperado:** Error 'Saldo a favor insuficiente'

## Caso 5: Aplicar saldo a favor correcto
- **Input:** id_solic=1, cvecuenta=1001, bimi=1, axoi=2024, bimf=3, axof=2024, importe=1200.00, usuario='admin'
- **Acción:** aplicarSaldoFavor
- **Esperado:** Mensaje de éxito y actualización de saldos

## Caso 6: Consulta de detalle de saldos
- **Input:** cvecuenta=1001
- **Acción:** consultarDetalleSaldos
- **Esperado:** Lista de bimestres/años con adeudo, impuestos y recargos
