## Casos de Prueba para RptReq_Pba_Aseo

### Caso 1: Reporte con datos válidos
- **Entrada:** id_rec=1, tipo_aseo='ORDINARIO', fecha_corte='2024-06-01'
- **Acción:** POST /api/execute con eRequest correspondiente
- **Esperado:** Respuesta eResponse.success=true, data contiene al menos un registro, los campos importe, recargos, gastos y total son numéricos y correctos.

### Caso 2: Reporte sin resultados
- **Entrada:** id_rec=999, tipo_aseo='ORDINARIO', fecha_corte='2024-06-01' (oficina inexistente)
- **Acción:** POST /api/execute
- **Esperado:** eResponse.success=true, data es array vacío

### Caso 3: Validación de gastos mínimos y máximos
- **Entrada:** Contrato con importe bajo y otro con importe alto, fecha_corte='2024-06-01'
- **Acción:** POST /api/execute
- **Esperado:** Para importe bajo, gastos >= gtos_requer; para importe alto, gastos <= gtos_requer_anual

### Caso 4: Error de parámetros
- **Entrada:** Falta parámetro id_rec
- **Acción:** POST /api/execute
- **Esperado:** eResponse.success=false, message indica error de parámetros

### Caso 5: Filtros de tipo de aseo
- **Entrada:** tipo_aseo='ESPECIAL', id_rec=1, fecha_corte='2024-06-01'
- **Acción:** POST /api/execute
- **Esperado:** Solo se muestran registros con tipo_aseo='ESPECIAL'
