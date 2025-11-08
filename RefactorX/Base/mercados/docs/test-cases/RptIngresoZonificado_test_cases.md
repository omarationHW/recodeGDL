# Casos de Prueba: Ingreso Zonificado

## Caso 1: Consulta exitosa
- **Input**: { "action": "getIngresoZonificado", "params": { "fecdesde": "2024-01-01", "fechasta": "2024-01-31" } }
- **Resultado esperado**: HTTP 200, success=true, data es un array de zonas con campos id_zona, zona, pagado, message vacío.

## Caso 2: Fechas inválidas
- **Input**: { "action": "getIngresoZonificado", "params": { "fecdesde": "", "fechasta": "" } }
- **Resultado esperado**: HTTP 200, success=false, data=null, message contiene 'Fechas requeridas'.

## Caso 3: Exportar PDF
- **Input**: { "action": "exportIngresoZonificadoPDF", "params": { "fecdesde": "2024-01-01", "fechasta": "2024-01-31" } }
- **Resultado esperado**: HTTP 200, success=true, data.url contiene la URL del PDF generado.

## Caso 4: Acción no soportada
- **Input**: { "action": "accionInexistente", "params": {} }
- **Resultado esperado**: HTTP 200, success=false, message='Acción no soportada'.

## Caso 5: Seguridad
- **Input**: Sin autenticación
- **Resultado esperado**: HTTP 401 Unauthorized.
