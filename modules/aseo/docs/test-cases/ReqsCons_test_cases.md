# Casos de Prueba para ReqsCons

## Caso 1: Consulta de Requerimientos Existente
- **Input:** contrato=12345, ctrol_aseo=9
- **Acción:** Buscar
- **Esperado:** Lista de apremios mostrada, sin errores

## Caso 2: Consulta de Contrato Inexistente
- **Input:** contrato=99999, ctrol_aseo=9
- **Acción:** Buscar
- **Esperado:** Mensaje de error 'No existe contrato con este dato, intentalo de nuevo'

## Caso 3: Pago de Apremio Correcto
- **Input:** contrato=12345, ctrol_aseo=9, apremio_id=1001, pago={fecha: '2024-06-01', id_rec: 1, caja: '01', operacion: 123, folio_rcbo: 'RCB123', importe_gastos: 500.00}
- **Acción:** Ejecutar Pago
- **Esperado:** Mensaje 'Se dio de PAGADO correctamente el Apremio', apremio actualizado

## Caso 4: Pago de Apremio con Datos Incompletos
- **Input:** Falta campo 'operacion'
- **Acción:** Ejecutar Pago
- **Esperado:** Mensaje de error 'Todos los campos son obligatorios'

## Caso 5: Consulta de Convenio
- **Input:** contrato=54321, ctrol_aseo=8
- **Acción:** Buscar
- **Esperado:** Se muestra convenio si existe, o mensaje 'Convenio de Contrato NO encontrado'
