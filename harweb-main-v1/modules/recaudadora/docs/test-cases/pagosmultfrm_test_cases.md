# Casos de Prueba: pagosmultfrm

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|-------------------|
| 1 | Buscar pagos de multas por fecha | { "fecha": "2024-06-01" } | Lista de pagos de multas para esa fecha |
| 2 | Buscar pagos por recaudadora y caja | { "recaud": "2", "caja": "A" } | Lista de pagos filtrados por recaudadora y caja |
| 3 | Buscar pagos por folio inexistente | { "folio": "999999" } | Lista vacía, mensaje de 'No existen recibos de multas con este criterio.' |
| 4 | Buscar pagos por nombre de contribuyente | { "nombre": "MARIA" } | Lista de pagos donde el contribuyente contiene 'MARIA' |
| 5 | Ver detalle de multa con descuentos | { "id_multa": 1001 } | Detalle de multa con tabla de descuentos |
| 6 | Ver detalle de multa sin descuentos | { "id_multa": 1002 } | Detalle de multa, tabla de descuentos vacía |
| 7 | Buscar pagos por número de acta | { "num_acta": "456" } | Lista de pagos asociados al número de acta 456 |
| 8 | Buscar pagos sin ningún filtro | { } | Lista de todos los pagos de multas (puede ser paginada o limitada) |
