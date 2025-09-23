## Casos de Prueba para Conciliación Banorte

### Caso 1: Consulta por Folio - Éxito
- **Entrada:** axo=2023, folio=123456
- **Acción:** POST /api/execute { eRequest: 'searchConciliadosByFolio', params: { axo: 2023, folio: 123456 } }
- **Esperado:** eResponse.success=true, data contiene registros, stat calculado correctamente

### Caso 2: Consulta por Fecha - Sin Resultados
- **Entrada:** fecha='2024-01-01'
- **Acción:** POST /api/execute { eRequest: 'searchConciliadosByFecha', params: { fecha: '2024-01-01' } }
- **Esperado:** eResponse.success=true, data es array vacío

### Caso 3: Cambio de Placa - Éxito
- **Entrada:** control=789, idbanco=456, axo=2023, folio=123456, placa='ABC1234', id_usuario=1
- **Acción:** POST /api/execute { eRequest: 'cambiarPlaca', params: { control: 789, idbanco: 456, axo: 2023, folio: 123456, placa: 'ABC1234', id_usuario: 1 } }
- **Esperado:** eResponse.success=true, data.clave=0, message='Cambio realizado correctamente'

### Caso 4: Cambio de Folio - Error (Folio no existe)
- **Entrada:** control=789, idbanco=456, axo=2023, folio=999999, placa='ZZZ9999', id_usuario=1, opcion=2
- **Acción:** POST /api/execute { eRequest: 'cambiarFolio', params: { control: 789, idbanco: 456, axo: 2023, folio: 999999, placa: 'ZZZ9999', id_usuario: 1, opcion: 2 } }
- **Esperado:** eResponse.success=false, message indica error

### Caso 5: Validación de Parámetros Faltantes
- **Entrada:** axo=2023 (sin folio)
- **Acción:** POST /api/execute { eRequest: 'searchConciliadosByFolio', params: { axo: 2023 } }
- **Esperado:** eResponse.success=false, message='Año y folio son requeridos'
