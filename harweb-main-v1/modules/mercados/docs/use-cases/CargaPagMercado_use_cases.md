# Casos de Uso - CargaPagMercado

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos de Mercado Correcta

**Descripción:** El usuario carga pagos de varios locales de un mercado, todos los importes y partidas son válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos. Existen adeudos pendientes para el local seleccionado.

**Pasos a seguir:**
1. El usuario selecciona la recaudadora, mercado, sección y local.
2. El sistema muestra los adeudos pendientes.
3. El usuario ingresa los datos de pago (fecha, caja, operación, partidas).
4. El usuario presiona 'Grabar Pagos'.
5. El sistema valida los importes y partidas.
6. El sistema graba los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos se graban correctamente, los adeudos se eliminan, y el sistema muestra un mensaje de éxito.

**Datos de prueba:**
oficina: 1, mercado: 10, categoria: 2, seccion: 'A', local: 123, fecha_pago: '2024-06-10', oficina_pago: 1, caja: '01', operacion: 1001, usuario_id: 5, pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: 'P001'}]

---

## Caso de Uso 2: Intento de Carga con Importe Excedido

**Descripción:** El usuario intenta cargar pagos cuyo importe total supera el ingreso disponible de la operación de caja.

**Precondiciones:**
El ingreso de caja es menor al total de pagos a capturar.

**Pasos a seguir:**
1. El usuario selecciona los datos y adeudos.
2. Ingresa partidas y montos que suman más que el ingreso disponible.
3. Presiona 'Grabar Pagos'.

**Resultado esperado:**
El sistema rechaza la operación y muestra un mensaje de error indicando que el importe excede el ingreso disponible.

**Datos de prueba:**
oficina: 1, mercado: 10, categoria: 2, seccion: 'A', local: 123, fecha_pago: '2024-06-10', oficina_pago: 1, caja: '01', operacion: 1001, usuario_id: 5, pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 2000, partida: 'P001'}] (Ingreso disponible: 1000)

---

## Caso de Uso 3: Carga de Pagos con Partidas Vacías

**Descripción:** El usuario intenta grabar pagos dejando la partida vacía o en cero.

**Precondiciones:**
Existen adeudos pendientes.

**Pasos a seguir:**
1. El usuario selecciona los datos y adeudos.
2. Deja la columna 'Partida' vacía o en cero para algunos adeudos.
3. Presiona 'Grabar Pagos'.

**Resultado esperado:**
El sistema ignora los pagos sin partida válida y solo graba los que tienen partida distinta de vacío/cero.

**Datos de prueba:**
pagos: [{id_local: 123, axo: 2024, periodo: 6, importe: 1000, partida: ''}, {id_local: 124, axo: 2024, periodo: 6, importe: 800, partida: 'P002'}]

---

