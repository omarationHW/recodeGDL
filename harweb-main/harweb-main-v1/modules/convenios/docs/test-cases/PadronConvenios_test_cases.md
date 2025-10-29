# Casos de Prueba: Padrón de Convenios

## 1. Consulta básica de convenios
- **Entrada:** tipo=3, subtipo=1, vigencia='A', recaudadora=null, anio_desde=2022, anio_hasta=2024
- **Acción:** POST /api/execute con eRequest.action='getPadronConvenios'
- **Esperado:** Lista de convenios vigentes, campos completos, sin error.

## 2. Consulta de folios de convenio
- **Entrada:** id_conv_resto=123, modulo=9, id_referencia=456, fecha_inicio='2023-01-01', fecha_venc='2023-12-31'
- **Acción:** POST /api/execute con eRequest.action='getPadronConveniosFolios'
- **Esperado:** Lista de folios (parcialidades) con campos: folio, ejecutor, fechas, periodos, etc.

## 3. Exportación a Excel
- **Entrada:** Resultados de consulta anterior
- **Acción:** Click en 'Exportar Excel'
- **Esperado:** Descarga de archivo CSV con los datos mostrados.

## 4. Validación de filtros vacíos
- **Entrada:** Todos los filtros vacíos
- **Acción:** POST /api/execute con eRequest.action='getPadronConvenios'
- **Esperado:** Lista completa de convenios (o error si no permitido).

## 5. Error en parámetros
- **Entrada:** tipo='abc' (no numérico)
- **Acción:** POST /api/execute con eRequest.action='getPadronConvenios'
- **Esperado:** Error de validación o mensaje de error en eResponse.message.

## 6. Consulta de catálogos
- **Entrada:** eRequest.action='getTipos', 'getSubtipos', 'getRecaudadoras', 'getVigencias'
- **Acción:** POST /api/execute
- **Esperado:** Listas de catálogos correspondientes.
