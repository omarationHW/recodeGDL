# Casos de Prueba: ReporteAnunExcel

## Caso 1: Consulta básica de anuncios vigentes sin adeudo
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 1, tipoRep: 0, fechaCons: '2024-06-01', adeudo: 1 } }`
- **Esperado**: Respuesta status=success, data con anuncios vigentes y sin adeudo

## Caso 2: Exportar reporte con adeudo desde año
- **Entrada**: `{ action: 'exportReporteAnuncios', params: { vigencia: 0, tipoRep: 0, fechaCons: '2024-06-01', adeudo: 2, axoIni: 2022 } }`
- **Esperado**: status=success, data.url contiene enlace a archivo Excel

## Caso 3: Filtro por grupo y rango de fechas
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 0, tipoRep: 1, fechaIni: '2024-01-01', fechaFin: '2024-06-01', grupoAnunId: 3 } }`
- **Esperado**: status=success, data contiene solo anuncios del grupo 3 y fechas en rango

## Caso 4: Error por parámetros inválidos
- **Entrada**: `{ action: 'getReporteAnuncios', params: { vigencia: 1, tipoRep: 0 } }` (falta fechaCons)
- **Esperado**: status=error, message indica parámetro faltante

## Caso 5: Exportar Excel sin resultados
- **Entrada**: `{ action: 'exportReporteAnuncios', params: { vigencia: 1, tipoRep: 0, fechaCons: '1900-01-01', adeudo: 1 } }`
- **Esperado**: status=success, data.url generado, pero archivo vacío o con encabezados únicamente
