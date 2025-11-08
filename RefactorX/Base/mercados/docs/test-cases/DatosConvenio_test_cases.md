# Casos de Prueba: DatosConvenio

## 1. Consulta de Convenio Existente
- **Entrada:** id_conv=123
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: objeto con todos los campos del convenio
  - Los campos calculados (estado, tipodesc, periodos, peradeudos, convenio) son correctos

## 2. Consulta de Parcialidades
- **Entrada:** id_conv=123
- **Acción:** POST /api/execute { action: 'getConvenioParciales', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de parcialidades con campos: pago_parcial_1, descparc, importe, peradeudos, fecha_pago, oficina_pago, caja_pago, operacion_pago

## 3. Consulta de Convenio Inexistente
- **Entrada:** id_conv=9999
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 9999 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: null
  - message: '' o 'No encontrado'

## 4. Validación de Campos Calculados
- **Entrada:** id_conv=124 (vigencia='B', tipo_pago='Q', etc)
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 124 } }
- **Resultado esperado:**
  - Los campos calculados muestran los valores correctos:
    - estado: 'BAJA'
    - tipodesc: 'QUINCENAL'
    - periodos: 'mes_desde/axo_desde - mes_hasta/axo_hasta'
    - peradeudos: 'mes_desde_1/axo_desde_1 - mes_hasta_1/axo_hasta_1'
    - convenio: 'letras_exp/numero_exp/axo_exp'

## 5. Seguridad: Acceso sin Autenticación
- **Entrada:** Sin token JWT
- **Acción:** POST /api/execute { action: 'getConvenioById', params: { id_conv: 123 } }
- **Resultado esperado:**
  - HTTP 401 Unauthorized (si la autenticación está implementada)
