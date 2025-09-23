# Casos de Prueba: Pagos_Cons_ContAsc

| Caso | Entrada | Acción | Resultado Esperado |
|------|---------|--------|--------------------|
| 1 | contrato=1803, ctrol_aseo=8 | Buscar contratos, ver pagos | Lista de pagos mostrada correctamente |
| 2 | contrato=999999, ctrol_aseo=8 | Buscar contratos | Mensaje de error: 'No se encontraron contratos' |
| 3 | contrato=1804, ctrol_aseo=8 | Buscar contratos, ver pagos | Mensaje de error: 'No se encontraron pagos' |
| 4 | contrato vacío | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 5 | contrato=1803, ctrol_aseo vacío | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 6 | contrato=abc, ctrol_aseo=8 | Buscar contratos | Mensaje de error: 'Debe ingresar el número de contrato y tipo de aseo' |
| 7 | contrato=1803, ctrol_aseo=8 | Buscar contratos, seleccionar contrato, ver pagos | Pagos mostrados, columnas: Periodo, Operación, Exed., Importe, Status, Fecha Pago, Ofna, Caja, Consec. Operación, Folio Rcbo |
