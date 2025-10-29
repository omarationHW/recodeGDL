# Casos de Prueba: Cancelación de Cuenta

## Caso 1: Cancelación exitosa
- **Entrada:**
  - cvecuenta: 12345
  - motivo: 'Duplicidad'
  - observacion: 'Cuenta duplicada por error de captura'
  - usuario: 'admin'
- **Acción:** confirm_cancel
- **Esperado:**
  - eResponse.success = true
  - convcta.vigente = 'C'
  - Nuevo registro en catastro con cvemov=11 y vigente='C'
  - reqpredial.vigencia = 'C' para registros vigentes
  - detsaldos.impvir = impade, recvir = recfac para saldo>0

## Caso 2: Cancelar cuenta ya cancelada
- **Entrada:**
  - cvecuenta: 54321 (vigente='C')
- **Acción:** confirm_cancel
- **Esperado:**
  - eResponse.success = false
  - Mensaje: 'La cuenta no está vigente'

## Caso 3: Cancelación con requerimientos vigentes
- **Entrada:**
  - cvecuenta: 67890 (con reqpredial vigentes)
  - motivo: 'Inactividad'
  - observacion: 'Cuenta sin movimiento desde 2010'
  - usuario: 'admin'
- **Acción:** confirm_cancel
- **Esperado:**
  - eResponse.success = true
  - reqpredial.vigencia = 'C', feccan actualizado
  - detsaldos y saldos recalculados

## Caso 4: Cancelación sin motivo
- **Entrada:**
  - cvecuenta: 12345
  - motivo: ''
  - observacion: '...' 
  - usuario: 'admin'
- **Acción:** confirm_cancel
- **Esperado:**
  - eResponse.success = false
  - Mensaje: 'Motivo es obligatorio'

## Caso 5: Cancelación por usuario sin permisos
- **Entrada:**
  - cvecuenta: 12345
  - motivo: 'Error'
  - observacion: '...' 
  - usuario: 'user_sin_permiso'
- **Acción:** confirm_cancel
- **Esperado:**
  - eResponse.success = false
  - Mensaje: 'No tiene permisos para cancelar cuentas'
