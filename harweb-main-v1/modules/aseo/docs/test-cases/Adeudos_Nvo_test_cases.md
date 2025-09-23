## Casos de Prueba para Adeudos_Nvo

### Caso 1: Consulta Concentrada - Periodos Vencidos
- **Entrada:** contrato=12345, ctrol_aseo=8, vigencia=V
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:12345, ctrol_aseo:8, vigencia:'V' } } }
- **Esperado:** status=ok, data contiene al menos un objeto con campos concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_act

### Caso 2: Consulta Detallada - Otro Periodo
- **Entrada:** contrato=54321, ctrol_aseo=4, vigencia=O, anio=2023, mes=05
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuentaDetallado', params: { contrato:54321, ctrol_aseo:4, vigencia:'O', anio:'2023', mes:'05' } } }
- **Esperado:** status=ok, data contiene array de conceptos, cada uno con cant_recolec, importe_adeudos_multa, importe_recargos_gastos, importe_act

### Caso 3: Impresión F02
- **Entrada:** tipo=O, numero=12345, rep=V, pref=2024-06
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuentaF02', params: { tipo:'O', numero:12345, rep:'V', pref:'2024-06' } } }
- **Esperado:** status=ok, data contiene array con campos periodo, concepto, cant_recolec, importe_adeudos, importe_recargos, importe_multa, importe_gastos, actualizacion

### Caso 4: Contrato No Existente
- **Entrada:** contrato=99999, ctrol_aseo=1, vigencia=V
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:99999, ctrol_aseo:1, vigencia:'V' } } }
- **Esperado:** status=error, message indica que el contrato no existe

### Caso 5: Parámetros Faltantes
- **Entrada:** contrato=12345
- **Acción:** POST /api/execute { eRequest: { action: 'getEstadoCuenta', params: { contrato:12345 } } }
- **Esperado:** status=error, message indica parámetros faltantes
