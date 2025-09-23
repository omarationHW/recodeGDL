# Casos de Prueba para RConsulta

## Caso 1: Consulta exitosa de local con adeudos y pagos
- **Input:** numero = 123, letra = 'A'
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestran los datos del local
  - Se muestran los adeudos vigentes
  - Se muestran los pagos realizados
  - El total a pagar es la suma de los importes en la tabla de totales

## Caso 2: Consulta de local inexistente
- **Input:** numero = 999, letra = 'Z'
- **Acción:** Buscar
- **Resultado esperado:**
  - Mensaje de error: 'No existe LOCAL con este dato, intentalo de nuevo'
  - No se muestran datos ni tablas

## Caso 3: Consulta de local suspendido/cancelado
- **Input:** numero = 456, letra = 'B'
- **Acción:** Buscar
- **Resultado esperado:**
  - Mensaje de error: 'LOCAL EN SUSPENSION O CANCELADO, intentalo de nuevo'
  - No se muestran datos ni tablas

## Caso 4: Validación de campo número vacío
- **Input:** numero = '', letra = ''
- **Acción:** Buscar
- **Resultado esperado:**
  - Mensaje de error: 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo'

## Caso 5: Validación de solo números en campo número
- **Input:** numero = 'abc', letra = 'A'
- **Acción:** Buscar
- **Resultado esperado:**
  - El campo no permite ingresar letras, solo números

## Caso 6: Consulta de local sin pagos realizados
- **Input:** numero = 321, letra = 'C'
- **Acción:** Buscar
- **Resultado esperado:**
  - Se muestran los datos y adeudos
  - La sección de pagos realizados no aparece
