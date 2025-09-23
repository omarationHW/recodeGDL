# Casos de Prueba ListadoMultiple

## Caso 1: Consulta de Convenios de Empresas por Año
- **Entrada**: year=2024, fecha=2024-06-01
- **Acción**: POST /api/execute { action: 'getConveniosEmpresas', params: { year: 2024, fecha: '2024-06-01' } }
- **Resultado esperado**: HTTP 200, JSON con lista de convenios (campos: cvecuenta, cuenta, folioreq, ...)

## Caso 2: Consulta de Pagos de Convenios por Empresa y Rango de Fechas
- **Entrada**: ejecutor=123, ftrab=2024-06-01, fpagod=2024-06-01, fpagoh=2024-06-30
- **Acción**: POST /api/execute { action: 'getPagosConveniosEmpresas', params: { ejecutor: 123, ftrab: '2024-06-01', fpagod: '2024-06-01', fpagoh: '2024-06-30' } }
- **Resultado esperado**: HTTP 200, JSON con lista de pagos (campos: cvecuenta, cuenta, foliorecibo, ...)

## Caso 3: Exportación de Convenios a Excel
- **Precondición**: Hay resultados en la tabla de convenios
- **Acción**: Click en 'Exportar a Excel'
- **Resultado esperado**: Descarga de archivo Excel con los datos mostrados

## Caso 4: Validación de Parámetros Faltantes
- **Entrada**: POST /api/execute { action: 'getPagosConveniosEmpresas', params: { ejecutor: null } }
- **Resultado esperado**: HTTP 400, JSON { success: false, message: 'Acción no soportada' }

## Caso 5: Seguridad - Usuario no autenticado
- **Entrada**: Sin token de autenticación
- **Resultado esperado**: HTTP 401 Unauthorized
