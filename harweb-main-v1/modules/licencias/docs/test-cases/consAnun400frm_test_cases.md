## Casos de Prueba para consAnun400frm

### Caso 1: Consulta exitosa de anuncio existente
- **Entrada:** { "eRequest": "getAnuncio400", "params": { "anuncio": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.data contiene los datos del anuncio, eResponse.error = null

### Caso 2: Consulta de pagos de anuncio existente
- **Entrada:** { "eRequest": "getPagosAnuncio400", "params": { "numanu": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, eResponse.error = null

### Caso 3: Consulta de anuncio inexistente
- **Entrada:** { "eRequest": "getAnuncio400", "params": { "anuncio": 999999 } }
- **Esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

### Caso 4: Consulta de pagos de anuncio inexistente
- **Entrada:** { "eRequest": "getPagosAnuncio400", "params": { "numanu": 999999 } }
- **Esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

### Caso 5: Parámetro faltante
- **Entrada:** { "eRequest": "getAnuncio400", "params": { } }
- **Esperado:** eResponse.success = false, eResponse.error contiene mensaje de parámetro requerido

### Caso 6: eRequest no soportado
- **Entrada:** { "eRequest": "unknownRequest", "params": { } }
- **Esperado:** eResponse.success = false, eResponse.error contiene mensaje de eRequest no soportado
