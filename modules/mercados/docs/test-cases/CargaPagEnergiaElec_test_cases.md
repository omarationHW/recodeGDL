# Casos de Prueba: Carga de Pagos de Energía Eléctrica

## Caso 1: Carga exitosa de pagos
- **Precondición:** Existen adeudos para el local.
- **Acción:** El usuario selecciona adeudos, captura partida y datos de pago, y ejecuta la carga.
- **Esperado:** Los pagos se insertan y los adeudos se eliminan. Mensaje de éxito.

## Caso 2: Consulta de pagos realizados
- **Precondición:** Existen pagos registrados para el local.
- **Acción:** El usuario consulta los pagos realizados para un id_energia.
- **Esperado:** Se muestra la lista de pagos realizados.

## Caso 3: Intento de carga sin seleccionar adeudos
- **Precondición:** Hay adeudos listados.
- **Acción:** El usuario intenta cargar pagos sin seleccionar ningún adeudo o sin capturar la partida.
- **Esperado:** El sistema muestra un mensaje de error y no realiza ninguna operación.

## Caso 4: Error de base de datos
- **Precondición:** La base de datos está inaccesible.
- **Acción:** El usuario intenta cargar pagos.
- **Esperado:** El sistema muestra un mensaje de error y no realiza ninguna operación.

## Caso 5: Validación de campos obligatorios
- **Precondición:** El usuario deja campos obligatorios vacíos (fecha de pago, oficina, caja, operación).
- **Acción:** El usuario intenta cargar pagos.
- **Esperado:** El sistema muestra un mensaje de error indicando los campos faltantes.
