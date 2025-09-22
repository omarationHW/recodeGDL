## Casos de Prueba para IndividualDiversos

### Caso 1: Consulta exitosa por manzana/lote/letra
- **Entrada:** tipo=14, subtipo=1, manzana='MZ-123', lote=5, letra='A'
- **Acción:** Buscar convenio
- **Esperado:** Se retorna convenio con datos correctos, lista de adeudos y pagos no vacía

### Caso 2: Consulta exitosa por expediente
- **Entrada:** tipo=3, subtipo=1, letras_exp='ZC1', numero_exp=1234, axo_exp=2022
- **Acción:** Buscar convenio
- **Esperado:** Se retorna convenio, lista de adeudos y pagos

### Caso 3: Consulta de referencias
- **Entrada:** id_conv_resto=1001
- **Acción:** getReferencias
- **Esperado:** Se retorna arreglo de referencias con campos periodo, impuesto, recargos, gastos, multa

### Caso 4: Error por convenio inexistente
- **Entrada:** tipo=14, subtipo=1, manzana='NOEXISTE', lote=99, letra='Z'
- **Acción:** Buscar convenio
- **Esperado:** Error 'Predio no encontrado'

### Caso 5: Error por parámetros insuficientes
- **Entrada:** tipo=14, subtipo=1
- **Acción:** Buscar convenio
- **Esperado:** Error 'Parámetros insuficientes'

### Caso 6: Resumen de adeudos
- **Entrada:** id_conv_resto=1001
- **Acción:** getResumen
- **Esperado:** Se retorna objeto con total_adeudos, total_recargos, total_intereses, total_pagos, total
