# Casos de Prueba para CargaPagEspecial

## Caso 1: Carga masiva de pagos especiales
- **Precondición:** Existen adeudos históricos para el local 123 en el mercado 10.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. Capturar partida 'P-001' para adeudo 2004-8.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El pago se inserta y el adeudo se elimina.

## Caso 2: Intento de cargar pagos sin partida
- **Precondición:** Existen adeudos históricos para el local 123 en el mercado 10.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. No capturar partida.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El sistema muestra error: 'Debe seleccionar al menos un adeudo y capturar la partida.'

## Caso 3: Carga de pago con descuento automático
- **Precondición:** Existe adeudo para local 123, mercado 10, axo=2005, periodo=10, importe=1000.
- **Pasos:**
  1. Seleccionar mercado 10, local 123.
  2. Buscar adeudos.
  3. Capturar partida 'P-002' para adeudo 2005-10.
  4. Seleccionar el adeudo y cargar pagos.
- **Esperado:** El pago se inserta con importe 900 (1000 - 10%).

## Caso 4: Error de conexión a base de datos
- **Precondición:** La base de datos está caída.
- **Pasos:**
  1. Intentar buscar mercados o cargar pagos.
- **Esperado:** El sistema muestra mensaje de error de conexión.

## Caso 5: Validación de campos obligatorios
- **Precondición:** El usuario no llena todos los campos del formulario.
- **Pasos:**
  1. Dejar vacío el campo 'local' y presionar 'Buscar Adeudos'.
- **Esperado:** El sistema muestra mensaje de error indicando el campo obligatorio.