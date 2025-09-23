# Casos de Uso - CargaTCultural

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos Correcta para Rango de Folios

**Descripción:** El usuario carga pagos para un rango de folios del Tianguis Cultural, todos los folios y operaciones son válidos.

**Precondiciones:**
El usuario está autenticado y tiene permisos de carga. Existen adeudos para los folios y periodo/año seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el rango de folios (ej: 100 a 110), periodo 2, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos.
5. El usuario ingresa los datos de pago (fecha, rec, caja, operación, partida) para cada folio.
6. Presiona 'Validar Folios'.
7. El sistema indica que todos los folios son válidos.
8. El usuario presiona 'Guardar Pagos'.
9. El sistema registra los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos quedan registrados, los adeudos eliminados, y se muestra mensaje de éxito.

**Datos de prueba:**
local_desde: 100, local_hasta: 110, periodo: 2, axo: 2024, pagos: [{id_local: 100, fecha_pago: '2024-04-15', rec: 1, caja: 'A', operacion: 12345, partida: 'P1', ...}, ...]

---

## Caso de Uso 2: Validación de Folios Erróneos

**Descripción:** El usuario intenta cargar pagos pero algunos folios no existen en ingresos o tienen datos incompletos.

**Precondiciones:**
El usuario está autenticado. Algunos folios del rango no tienen ingresos registrados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el rango de folios (ej: 200 a 205), periodo 3, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos.
5. El usuario deja algunos campos de pago vacíos o ingresa operaciones inexistentes.
6. Presiona 'Validar Folios'.
7. El sistema muestra los folios erróneos en pantalla.

**Resultado esperado:**
Se muestra la lista de folios erróneos y no se permite guardar hasta corregirlos.

**Datos de prueba:**
pagos: [{id_local: 200, fecha_pago: '', rec: '', caja: '', operacion: '', partida: ''}, {id_local: 201, fecha_pago: '2024-05-10', rec: 1, caja: 'B', operacion: 99999, partida: 'P2'}, ...]

---

## Caso de Uso 3: Aplicación de Descuento Automático

**Descripción:** El sistema aplica automáticamente el descuento correspondiente al pago si el folio tiene descuento.

**Precondiciones:**
El folio tiene un porcentaje de descuento registrado en la tabla cobrotrimestral.

**Pasos a seguir:**
1. El usuario accede a la página de Carga TCultural.
2. Ingresa el folio con descuento (ej: 150), periodo 1, año 2024.
3. Presiona 'Buscar'.
4. El sistema muestra el adeudo y el porcentaje de descuento.
5. El usuario ingresa los datos de pago y valida los folios.
6. Presiona 'Guardar Pagos'.
7. El sistema calcula el importe con descuento y lo registra.

**Resultado esperado:**
El pago se registra con el importe descontado y el adeudo se elimina.

**Datos de prueba:**
pagos: [{id_local: 150, fecha_pago: '2024-03-01', rec: 1, caja: 'C', operacion: 54321, partida: 'P3', descuento: 10, importe: 1000}]

---

