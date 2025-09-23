## Casos de Prueba para Adeudos_OpcMult

### 1. Buscar contrato existente y listar adeudos
- **Entrada:** action: 'buscar_contrato', num_contrato: 12345, ctrol_aseo: 9
- **Esperado:** Responde con datos del contrato y status_vigencia = 'V'

### 2. Listar tipo de aseo y recaudadoras
- **Entrada:** action: 'listar_tipo_aseo'
- **Esperado:** Lista de tipos de aseo
- **Entrada:** action: 'listar_recaudadoras'
- **Esperado:** Lista de recaudadoras

### 3. Listar adeudos de contrato
- **Entrada:** action: 'listar_adeudos', control_contrato: 12345
- **Esperado:** Lista de adeudos vigentes

### 4. Ejecutar opción 'P' (Pagado) para varios adeudos
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 12345, periodo: '2024-06', ctrol_oper: 6}, ...], opcion: 'P', fecha: '2024-06-01', reca: 1, caja: 'A', operacion: 123456, folio_rcbo: 'RCB123', obs: 'Pago masivo', usuario: 1
- **Esperado:** Respuesta 'OK' para cada adeudo

### 5. Ejecutar opción 'S' (Condonar) para un adeudo
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 54321, periodo: '2024-06', ctrol_oper: 6}], opcion: 'S', fecha: '2024-06-02', reca: 2, caja: 'B', operacion: 0, folio_rcbo: 'COND001', obs: 'Condonación por convenio', usuario: 2
- **Esperado:** Respuesta 'OK'

### 6. Ejecutar opción 'C' (Cancelar) para varios adeudos
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 67890, periodo: '2024-06', ctrol_oper: 6}, ...], opcion: 'C', fecha: '2024-06-03', reca: 3, caja: 'C', operacion: 0, folio_rcbo: 'CANCEL01', obs: 'Cancelación administrativa', usuario: 3
- **Esperado:** Respuesta 'OK' para cada adeudo

### 7. Error: Intentar ejecutar opción sobre adeudo inexistente
- **Entrada:** action: 'ejecutar_opcion', rows: [{control_contrato: 99999, periodo: '2024-06', ctrol_oper: 6}], ...
- **Esperado:** Respuesta 'No existe adeudo vigente para el periodo'
