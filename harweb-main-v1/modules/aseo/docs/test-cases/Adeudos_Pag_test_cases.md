## Casos de Prueba para Adeudos_Pag

### Caso 1: Consulta de Adeudos Existentes
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6
- **Acción:** ver_adeudos
- **Esperado:** Respuesta con datos de cuota normal y/o excedencias, status_vigencia='V' o 'P'.

### Caso 2: Pago Correcto de Cuota Normal
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1001, folio_rcbo='RCB123', fecha_pagado='2024-06-15', id_rec=2, caja='A', usuario_id=1, pagar_cn=true, importe_cn=500.00, pagar_exe=false
- **Acción:** ejecutar_pago
- **Esperado:** success=true, message='Pago realizado correctamente.'

### Caso 3: Pago Correcto de Excedencias
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1001, folio_rcbo='RCB123', fecha_pagado='2024-06-15', id_rec=2, caja='A', usuario_id=1, pagar_cn=false, pagar_exe=true, importe_exe=150.00
- **Acción:** ejecutar_pago
- **Esperado:** success=true, message='Pago realizado correctamente.'

### Caso 4: Intento de Pago de Adeudo Ya Pagado
- **Entrada:** contrato=12345, tipo_aseo=4, aso=2024, mes=6, consec_oper=1002, folio_rcbo='RCB124', fecha_pagado='2024-06-16', id_rec=2, caja='A', usuario_id=1, pagar_cn=true, pagar_exe=false, importe_cn=500.00
- **Acción:** ejecutar_pago
- **Esperado:** success=false, message='No se encontró adeudo de cuota normal vigente para pagar.'

### Caso 5: Consulta de Adeudos Inexistentes
- **Entrada:** contrato=99999, tipo_aseo=4, aso=2024, mes=6
- **Acción:** ver_adeudos
- **Esperado:** success=false, message='No existen adeudos para el periodo seleccionado.'

### Caso 6: Validación de Parámetros Faltantes
- **Entrada:** contrato=, tipo_aseo=, aso=, mes=
- **Acción:** ver_adeudos
- **Esperado:** success=false, message='El campo contrato es obligatorio.'
