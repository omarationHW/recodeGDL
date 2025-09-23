# Casos de Prueba para Formulario muestradupfrm

## Caso 1: Consulta exitosa de duplicados
- **Entrada:**
  - action: 'list'
  - params: { cvecond: 12345 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array con al menos un registro

## Caso 2: Consulta con condominio inexistente
- **Entrada:**
  - action: 'list'
  - params: { cvecond: 99999 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array vacío

## Caso 3: Eliminación de cuenta duplicada
- **Entrada:**
  - action: 'delete'
  - params: { cvecuenta: 56789 }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.estado = 'D'

## Caso 4: Integración con suma de indivisos incorrecta
- **Entrada:**
  - action: 'process'
  - params: { cvecond: 12345, usuario: 'testuser' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.resultado = 'ERROR'
  - eResponse.data.mensaje contiene 'La suma de indivisos no es 100%'

## Caso 5: Integración exitosa
- **Entrada:**
  - action: 'process'
  - params: { cvecond: 12345, usuario: 'testuser' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.resultado = 'OK'
  - eResponse.data.mensaje = 'Integración aplicada correctamente'
