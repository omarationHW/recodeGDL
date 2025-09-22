## Casos de Prueba para Estadística de Pagos y Adeudos

### Caso 1: Consulta exitosa de estadística por mercado
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: 1, axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: true
  - data: Array con al menos un mercado, campos localpag, pagospag, periodospag, etc.

### Caso 2: Resumen global correcto
- **Entrada:**
  - action: getResumenPorMercado
  - params: { id_rec: 2, axo: 2024, mes: 5, fec3: '2024-05-01', fec4: '2024-05-31' }
- **Esperado:**
  - success: true
  - data: Array con 3 filas (Pagados, Capturados, Adeudos), campos locales, importe, periodos.

### Caso 3: Parámetro obligatorio faltante
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: null, axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: false
  - message: 'Acción no soportada' o mensaje de validación.

### Caso 4: Fechas fuera de rango
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: 1, axo: 2024, mes: 6, fec3: '2025-01-01', fec4: '2025-01-31' }
- **Esperado:**
  - success: true
  - data: Array vacío

### Caso 5: SQL Injection attempt
- **Entrada:**
  - action: getEstadisticaPagosyAdeudos
  - params: { id_rec: "1; DROP TABLE ta_11_locales; --", axo: 2024, mes: 6, fec3: '2024-06-01', fec4: '2024-06-30' }
- **Esperado:**
  - success: false
  - message: Error de validación o excepción controlada
