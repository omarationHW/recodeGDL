# Casos de Prueba: Carga Diversos Especial

## Caso 1: Carga exitosa de pagos
- **Precondición:** Existen adeudos para la fecha 2024-06-01
- **Acción:**
  - Buscar adeudos para 2024-06-01
  - Ingresar partida '123' en el primer registro
  - Grabar
- **Esperado:**
  - El pago se graba y el adeudo se elimina
  - Respuesta: `{ success: true, data: { inserted: 1, errors: 0 } }`

## Caso 2: Intento de grabar sin partidas válidas
- **Precondición:** Existen adeudos para la fecha
- **Acción:**
  - Buscar adeudos
  - No ingresar ninguna partida
  - Grabar
- **Esperado:**
  - Mensaje de error: 'No hay pagos válidos para grabar.'

## Caso 3: Error por local inexistente
- **Precondición:** Se simula un pago para un local que no existe
- **Acción:**
  - Buscar adeudos
  - Editar el registro para poner MER: '99', CAT: '9', LOCAL: '9999'
  - Ingresar partida '999'
  - Grabar
- **Esperado:**
  - El sistema omite el pago y reporta error en el campo 'errors' de la respuesta

## Caso 4: Consulta de fechas de descuento
- **Acción:**
  - Llamar a la acción 'getFechasDescuento' con mes=6
- **Esperado:**
  - Se retorna la fecha de descuento correspondiente al mes 6

## Caso 5: Validación de integridad de datos
- **Acción:**
  - Enviar pagos con campos faltantes o tipos incorrectos
- **Esperado:**
  - El sistema retorna error de validación y no procesa la transacción
