# Casos de Prueba Certificaciones

## Caso 1: Alta de Certificación
- **Entrada:** tipo='L', id_licencia=12345, observacion='Certificación para trámite externo', partidapago='123456'
- **Acción:** POST /api/execute { action: 'certificaciones.create', params: {...} }
- **Resultado esperado:** status 200, success true, folio asignado, registro en base de datos.

## Caso 2: Modificación de Observación
- **Entrada:** id=100, observacion='Nueva observación', partidapago='654321'
- **Acción:** POST /api/execute { action: 'certificaciones.update', params: {...} }
- **Resultado esperado:** status 200, success true, campo observacion actualizado.

## Caso 3: Cancelación de Certificación
- **Entrada:** id=100, motivo='Error en datos del propietario'
- **Acción:** POST /api/execute { action: 'certificaciones.cancel', params: {...} }
- **Resultado esperado:** status 200, success true, vigente='C', observacion actualizado.

## Caso 4: Búsqueda Avanzada
- **Entrada:** axo=2024, folio=10, tipo='A'
- **Acción:** POST /api/execute { action: 'certificaciones.search', params: {...} }
- **Resultado esperado:** status 200, listado solo con registros que cumplen filtros.

## Caso 5: Impresión de Certificación
- **Entrada:** id=100
- **Acción:** POST /api/execute { action: 'certificaciones.print', params: {id:100} }
- **Resultado esperado:** status 200, JSON con datos de certificación, licencia y pagos.
