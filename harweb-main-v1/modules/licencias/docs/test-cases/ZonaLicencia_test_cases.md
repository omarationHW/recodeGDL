## Casos de Prueba para ZonaLicencia

### 1. Consulta de Zona/Subzona/Recaudadora
- **Entrada:** licencia = 123456
- **Acción:** POST /api/execute { action: 'get_licencias_zona', params: { licencia: 123456 } }
- **Esperado:** Respuesta con los campos zona, subzona, recaud actuales.

### 2. Actualización Exitosa
- **Entrada:** licencia = 123456, zona = 2, subzona = 5, recaud = 3
- **Acción:** POST /api/execute { action: 'save_licencias_zona', params: { licencia: 123456, zona: 2, subzona: 5, recaud: 3 }
- **Esperado:** success: true, los datos quedan actualizados en la tabla licencias_zona.

### 3. Validación de Campos Vacíos
- **Entrada:** licencia = 123456, zona = '', subzona = '', recaud = ''
- **Acción:** POST /api/execute { action: 'save_licencias_zona', params: { licencia: 123456, zona: '', subzona: '', recaud: '' }
- **Esperado:** success: false, error: 'Todos los campos son obligatorios' (en frontend), no se realiza ningún cambio en la base de datos.

### 4. Licencia No Encontrada
- **Entrada:** licencia = 999999
- **Acción:** POST /api/execute { action: 'get_licencia', params: { licencia: 999999 } }
- **Esperado:** success: true, data: null

### 5. Listado de Zonas para Recaudadora
- **Entrada:** recaud = 2
- **Acción:** POST /api/execute { action: 'get_zonas', params: { recaud: 2 } }
- **Esperado:** success: true, data: [ ...zonas... ]

### 6. Listado de Subzonas para Zona y Recaudadora
- **Entrada:** cvezona = 2, recaud = 2
- **Acción:** POST /api/execute { action: 'get_subzonas', params: { cvezona: 2, recaud: 2 } }
- **Esperado:** success: true, data: [ ...subzonas... ]
