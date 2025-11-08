## Casos de Prueba para Dictamen de Anuncio

### Caso 1: Consulta Exitosa de Anuncio
- **Entrada:** anuncio = 12345
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { anuncio: 12345 } }
- **Resultado esperado:** success = true, data contiene los campos del anuncio, error = null

### Caso 2: Consulta de Anuncio Inexistente
- **Entrada:** anuncio = 99999
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { anuncio: 99999 } }
- **Resultado esperado:** success = false, data = null, error = 'No se encontró el anuncio' o similar

### Caso 3: Generación de Reporte PDF
- **Entrada:** anuncio = 12345, tipo = 1
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.printReport', params: { anuncio: 12345, tipo: 1 } }
- **Resultado esperado:** success = true, data.pdf_url contiene la URL del PDF, error = null

### Caso 4: Error por Falta de Parámetro
- **Entrada:** anuncio = null
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.getAnuncio', params: { } }
- **Resultado esperado:** success = false, error = 'El parámetro anuncio es requerido'

### Caso 5: eRequest No Soportado
- **Entrada:** eRequest = 'dictamenfrm.unknown'
- **Acción:** POST /api/execute { eRequest: 'dictamenfrm.unknown', params: { anuncio: 12345 } }
- **Resultado esperado:** success = false, error = 'eRequest no soportado: dictamenfrm.unknown'
