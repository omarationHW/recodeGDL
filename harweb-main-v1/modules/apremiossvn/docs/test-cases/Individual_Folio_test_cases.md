## Casos de Prueba para Individual Folio

### Caso 1: Consulta exitosa de folio
- **Entrada:** { "modulo": 11, "folio": 12345, "recaudadora": 1 }
- **Acción:** search
- **Esperado:** success=true, data contiene los campos del folio

### Caso 2: Consulta de folio inexistente
- **Entrada:** { "modulo": 16, "folio": 99999, "recaudadora": 2 }
- **Acción:** search
- **Esperado:** success=false, message='No existe Registro con esos datos'

### Caso 3: Historia de folio existente
- **Entrada:** { "id_control": 123 }
- **Acción:** history
- **Esperado:** success=true, data es un array con registros de historia

### Caso 4: Periodos de folio existente
- **Entrada:** { "id_control": 123 }
- **Acción:** periods
- **Esperado:** success=true, data es un array con registros de periodos

### Caso 5: Catálogo de aplicaciones
- **Entrada:** { "catalog": "aplicaciones" }
- **Acción:** catalogs
- **Esperado:** success=true, data contiene lista de aplicaciones

### Caso 6: Catálogo de recaudadoras
- **Entrada:** { "catalog": "recaudadoras" }
- **Acción:** catalogs
- **Esperado:** success=true, data contiene lista de recaudadoras
