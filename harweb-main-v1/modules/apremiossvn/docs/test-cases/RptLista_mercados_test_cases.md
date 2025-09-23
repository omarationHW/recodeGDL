# Casos de Prueba para RptLista_mercados

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta básica de adeudos de mercados | { vofna: 1, vmerc1: 1, vmerc2: 2, vlocal1: 1, vlocal2: 9999, vsecc: 'todas' } | Lista de adeudos de mercados 1 y 2, con recargos y gastos calculados |
| TC02 | Consulta filtrando por sección | { vofna: 1, vmerc1: 1, vmerc2: 1, vlocal1: 1, vlocal2: 9999, vsecc: 'A' } | Solo adeudos de sección 'A' del mercado 1 |
| TC03 | Consulta sin resultados | { vofna: 99, vmerc1: 99, vmerc2: 99, vlocal1: 1, vlocal2: 9999, vsecc: 'todas' } | Tabla vacía, sin errores |
| TC04 | Exportación a CSV | Consulta válida con resultados | Archivo CSV descargado con los datos |
| TC05 | Error de parámetros (faltante) | { vofna: 1, vmerc1: 1 } | Mensaje de error en pantalla |
| TC06 | Consulta con locales fuera de rango | { vofna: 1, vmerc1: 1, vmerc2: 1, vlocal1: 9999, vlocal2: 10000, vsecc: 'todas' } | Tabla vacía |
