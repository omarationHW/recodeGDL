## Casos de Prueba para Modificación Masiva

### Caso 1: Modificación masiva de predial exitosa
- **Entrada:**
  - action: modificar_predial
  - params: { recaud: 1, folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_modificados > 0

### Caso 2: Cancelación masiva de multas exitosa
- **Entrada:**
  - action: cancelar_multa
  - params: { recaud: 2, folio_ini: 2000, folio_fin: 2100, fecha: '2024-06-02' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_cancelados > 0

### Caso 3: Modificación masiva de licencias con folios inexistentes
- **Entrada:**
  - action: modificar_licencia
  - params: { recaud: 99, folio_ini: 9999, folio_fin: 10010, fecha: '2024-06-03' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: success
  - eResponse.data[0].folios_modificados = 0

### Caso 4: Error por parámetros faltantes
- **Entrada:**
  - action: modificar_predial
  - params: { folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: error
  - eResponse.message contiene 'recaud'

### Caso 5: Acción no soportada
- **Entrada:**
  - action: accion_invalida
  - params: { recaud: 1, folio_ini: 1000, folio_fin: 1100, fecha: '2024-06-01' }
  - user: admin
- **Resultado esperado:**
  - eResponse.status: error
  - eResponse.message contiene 'Acción no soportada.'
