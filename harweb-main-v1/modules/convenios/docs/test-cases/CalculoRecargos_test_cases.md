## Casos de Prueba para CalculoRecargos

### Caso 1: Contrato vencido sin requerimientos
- **Entrada:** id_convenio=123, fecha_vencimiento=2023-01-01, pago_inicial=1000, pago_quincenal=500, pagos_parciales=10, pagos_a_realizar=2, requerimientos=[]
- **Acción:** Calcular recargos
- **Esperado:**
  - importe_a_pagar = 1000 + (500*2) = 2000
  - Si porcentaje_recargos <= 100, importerecargos = 2000 * porcentaje_recargos / 100
  - Si porcentaje_recargos > 100, importerecargos = 2000 * 100 / 100
  - label_porc = porcentaje aplicado

### Caso 2: Contrato vencido con requerimientos
- **Entrada:** id_convenio=456, fecha_vencimiento=2022-12-01, pago_inicial=0, pago_quincenal=600, pagos_parciales=8, pagos_a_realizar=3, requerimientos=[{...}]
- **Acción:** Calcular recargos
- **Esperado:**
  - importe_a_pagar = 0 + (600*3) = 1800
  - Si porcentaje_recargos <= 250, importerecargos = 1800 * porcentaje_recargos / 100
  - Si porcentaje_recargos > 250, importerecargos = 1800 * 250 / 100
  - label_porc = porcentaje aplicado

### Caso 3: Error por exceso de parcialidades
- **Entrada:** id_convenio=789, fecha_vencimiento=2023-05-01, pago_inicial=500, pago_quincenal=400, pagos_parciales=5, pagos_a_realizar=6, requerimientos=[]
- **Acción:** Calcular recargos
- **Esperado:**
  - Mensaje de error: 'Error... Los Pagos a Realizar Exceden de 5'

### Caso 4: Contrato vigente (no vencido)
- **Entrada:** fecha_actual < fecha_vencimiento
- **Acción:** Calcular recargos
- **Esperado:**
  - importerecargos = importe_a_pagar * porcentaje_recargos / 100
  - label_porc = porcentaje aplicado

### Caso 5: Validación de campos obligatorios
- **Entrada:** id_convenio vacío
- **Acción:** Calcular recargos
- **Esperado:**
  - Mensaje de error: 'Debe cargar un contrato válido.'
