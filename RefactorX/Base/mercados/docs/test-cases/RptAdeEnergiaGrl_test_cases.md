# Casos de Prueba: Adeudos Globales de Energía Eléctrica

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|--------------------|
| TC01 | Consulta exitosa de adeudos | office_id=1, market_id=5, year=2024, month=6 | Lista de adeudos mostrada, total correcto |
| TC02 | Exportación a Excel | office_id=2, market_id=10, year=2023, month=12 | Archivo Excel descargado con datos correctos |
| TC03 | Filtros incompletos | office_id='', market_id='', year='', month='' | Mensaje de error: 'Todos los filtros son obligatorios' |
| TC04 | Mercado sin adeudos | office_id=3, market_id=99, year=2022, month=1 | Tabla vacía, mensaje 'No hay adeudos' |
| TC05 | Error de conexión | (Simular caída de DB) | Mensaje de error amigable en frontend |
