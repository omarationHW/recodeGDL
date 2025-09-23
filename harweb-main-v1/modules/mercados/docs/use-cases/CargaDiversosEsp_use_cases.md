# Casos de Uso - CargaDiversosEsp

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos Diversos para Fecha Específica

**Descripción:** El usuario desea cargar pagos realizados por diversos para una fecha específica, ingresando los números de partida correspondientes.

**Precondiciones:**
El usuario tiene permisos de acceso y existen adeudos pendientes para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página 'Carga Diversos Especial'.
2. Selecciona la fecha de pago (ejemplo: 2024-06-01).
3. Presiona 'Buscar'.
4. El sistema muestra la lista de adeudos pendientes.
5. El usuario ingresa el número de partida para cada pago que desea procesar.
6. Presiona 'Grabar'.
7. El sistema procesa los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos con partida válida se graban correctamente y los adeudos asociados se eliminan. Se muestra un mensaje de éxito.

**Datos de prueba:**
fecha_pago: 2024-06-01
pagos: [ { FECHA: '2024-06-01', REC: '5', ... , PARTIDA: '123' }, ... ]

---

## Caso de Uso 2: Intento de Carga sin Partidas Válidas

**Descripción:** El usuario intenta grabar pagos sin ingresar ningún número de partida.

**Precondiciones:**
Existen adeudos pendientes, pero el usuario no ingresa ningún número de partida.

**Pasos a seguir:**
1. El usuario accede a la página y busca adeudos.
2. No ingresa ningún número de partida.
3. Presiona 'Grabar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que no hay pagos válidos para grabar.

**Datos de prueba:**
fecha_pago: 2024-06-01
pagos: [ { FECHA: '2024-06-01', REC: '5', ... , PARTIDA: '' }, ... ]

---

## Caso de Uso 3: Validación de Local Inexistente

**Descripción:** El sistema intenta procesar un pago para un local que no existe en la base de datos.

**Precondiciones:**
El usuario ingresa una partida para un local que no existe.

**Pasos a seguir:**
1. El usuario busca adeudos y edita la información para simular un local inexistente.
2. Ingresa un número de partida y presiona 'Grabar'.

**Resultado esperado:**
El sistema omite el pago para el local inexistente y lo reporta como error en la respuesta.

**Datos de prueba:**
pagos: [ { FECHA: '2024-06-01', REC: '5', MER: '99', CAT: '9', LOCAL: '9999', PARTIDA: '999' } ]

---

