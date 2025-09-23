# Casos de Prueba para DatosConvenio

## Caso 1: Consulta exitosa de datos generales
- **Entrada:**
  - eRequest: getDatosConvenio
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los campos: nombre, calle, num_exterior, etc.

## Caso 2: Consulta exitosa de parcialidades
- **Entrada:**
  - eRequest: getParcialidadesConvenio
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array con al menos un objeto con campos: parcial, impuesto_adeudo, periodos, etc.

## Caso 3: Consulta de pago de parcialidad existente
- **Entrada:**
  - eRequest: getPagoParcialidad
  - params: { control: 123, parcial: 2 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los campos: id_conv_resto, pago_parcial, fecha_pago, etc.

## Caso 4: Consulta con control inexistente
- **Entrada:**
  - eRequest: getDatosConvenio
  - params: { control: 999999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array vacío

## Caso 5: Consulta con parámetros faltantes
- **Entrada:**
  - eRequest: getPagoParcialidad
  - params: { control: 123 }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica parámetros requeridos

## Caso 6: eRequest no soportado
- **Entrada:**
  - eRequest: getSomethingElse
  - params: {}
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'eRequest no soportado'
