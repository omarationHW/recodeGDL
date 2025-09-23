# Casos de Prueba para RptListaxRegPub

## Caso 1: Consulta general de registros vigentes
- **Entrada:**
  - vigencia: '1'
  - clave_practicado: 'todas'
  - numesta: 'todas'
  - usuario_id_rec: 1
- **Acción:** Ejecutar POST /api/execute con eRequest 'RptListaxRegPub.getReport' y los parámetros anteriores.
- **Resultado esperado:**
  - success: true
  - data: lista de registros con vigencia '1'
  - message: ''
  - Las sumas de importe_global, importe_multa, importe_recargo y importe_gastos son correctas.

## Caso 2: Filtrado por clave_practicado específica
- **Entrada:**
  - vigencia: 'todas'
  - clave_practicado: 'ABC123'
  - numesta: 'todas'
  - usuario_id_rec: 1
- **Acción:** Ejecutar POST /api/execute con eRequest 'RptListaxRegPub.getReport' y los parámetros anteriores.
- **Resultado esperado:**
  - success: true
  - data: solo registros con clave_practicado = 'ABC123'
  - message: ''

## Caso 3: Consulta por número de estacionamiento y vigencia pagada
- **Entrada:**
  - vigencia: '2'
  - clave_practicado: 'todas'
  - numesta: '57'
  - usuario_id_rec: 1
- **Acción:** Ejecutar POST /api/execute con eRequest 'RptListaxRegPub.getReport' y los parámetros anteriores.
- **Resultado esperado:**
  - success: true
  - data: solo registros con numesta = 57 y vigencia = '2' o 'P'
  - message: ''

## Caso 4: Error por usuario_id_rec faltante
- **Entrada:**
  - vigencia: '1'
  - clave_practicado: 'todas'
  - numesta: 'todas'
  - usuario_id_rec: null
- **Acción:** Ejecutar POST /api/execute con eRequest 'RptListaxRegPub.getRecaudadoraInfo'.
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'usuario_id_rec es requerido'

## Caso 5: Sin resultados para filtros inexistentes
- **Entrada:**
  - vigencia: '3'
  - clave_practicado: 'ZZZ999'
  - numesta: '9999'
  - usuario_id_rec: 1
- **Acción:** Ejecutar POST /api/execute con eRequest 'RptListaxRegPub.getReport' y los parámetros anteriores.
- **Resultado esperado:**
  - success: true
  - data: []
  - message: ''
