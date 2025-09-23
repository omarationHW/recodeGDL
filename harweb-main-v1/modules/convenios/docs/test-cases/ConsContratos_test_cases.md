# Casos de Prueba: Consulta de Contratos

## Caso 1: Búsqueda por Contrato (Colonia, Calle, Folio)
- **Entrada:** colonia=1, calle=2, folio=100
- **Acción:** POST /api/execute { action: 'searchByContrato', params: { colonia:1, calle:2, folio:100 } }
- **Resultado esperado:** Lista de contratos con esos datos, tabla no vacía si existen.

## Caso 2: Búsqueda por Nombre
- **Entrada:** nombre='JUAN PEREZ'
- **Acción:** POST /api/execute { action: 'searchByNombre', params: { nombre:'JUAN PEREZ' } }
- **Resultado esperado:** Lista de contratos cuyo nombre contiene 'JUAN PEREZ'.

## Caso 3: Búsqueda por Domicilio
- **Entrada:** desc_calle='AV. INDEPENDENCIA', numero='123'
- **Acción:** POST /api/execute { action: 'searchByDomicilio', params: { desc_calle:'AV. INDEPENDENCIA', numero:'123' } }
- **Resultado esperado:** Lista de contratos cuyo domicilio y número coinciden.

## Caso 4: Detalle Individual
- **Entrada:** id_convenio=123
- **Acción:** POST /api/execute { action: 'getContratoDetalle', params: { id_convenio:123 } }
- **Resultado esperado:** Objeto con todos los campos del contrato.

## Caso 5: Validación de campos vacíos
- **Entrada:** Sin parámetros
- **Acción:** POST /api/execute { action: 'searchByContrato', params: {} }
- **Resultado esperado:** Error o lista vacía, sin excepción.

## Caso 6: SQL Injection
- **Entrada:** nombre="' OR 1=1 --"
- **Acción:** POST /api/execute { action: 'searchByNombre', params: { nombre: "' OR 1=1 --" } }
- **Resultado esperado:** No retorna todos los contratos, no hay inyección.
