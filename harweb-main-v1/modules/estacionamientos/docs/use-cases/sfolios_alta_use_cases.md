# Casos de Uso - sfolios_alta

**Categoría:** Form

## Caso de Uso 1: Alta de Folio Nuevo con Placa y Folio Válidos

**Descripción:** El usuario ingresa un folio y una placa válidos, y da de alta un nuevo folio de adeudo.

**Precondiciones:**
El folio no existe en ta14_folios_adeudo ni en ta14_folios_histo. La placa existe en ta_padron.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Folios.
2. Selecciona la fecha, vigilante, clave, estado, zona, espacio y hora.
3. Ingresa un folio no existente y una placa válida.
4. El sistema valida que el folio no existe y muestra los datos del vehículo y calcomanía.
5. El usuario presiona 'Aceptar'.
6. El sistema inserta el folio y muestra mensaje de éxito.

**Resultado esperado:**
El folio se inserta correctamente y se muestra el mensaje 'Ultimo folio Grabado: [folio] Placa: [placa]'.

**Datos de prueba:**
folio: 1234567, placa: ABC1234, fecha: 2024-06-10, vigilante: 1, clave: 1, estado: 1, zona: 1, espacio: 1, hora: 08:00

---

## Caso de Uso 2: Intento de Alta con Folio Existente

**Descripción:** El usuario intenta dar de alta un folio que ya existe en ta14_folios_adeudo.

**Precondiciones:**
El folio ya existe en ta14_folios_adeudo.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Folios.
2. Ingresa un folio existente y una placa válida.
3. El sistema valida y muestra mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Folio ya está capturado vigente...' y no permite grabar.

**Datos de prueba:**
folio: 1000001, placa: XYZ9876, fecha: 2024-06-10, vigilante: 2, clave: 2, estado: 2, zona: 2, espacio: 2, hora: 09:00

---

## Caso de Uso 3: Intento de Alta con Folio Pagado o Sin Efecto

**Descripción:** El usuario intenta dar de alta un folio que existe en ta14_folios_histo con codigo_movto <> 1.

**Precondiciones:**
El folio existe en ta14_folios_histo con codigo_movto <> 1.

**Pasos a seguir:**
1. El usuario accede a la página de Alta de Folios.
2. Ingresa un folio que está en histórico y una placa válida.
3. El sistema valida y muestra mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Folio Pagado o sin efecto...' y no permite grabar.

**Datos de prueba:**
folio: 2000002, placa: DEF5678, fecha: 2024-06-10, vigilante: 3, clave: 3, estado: 3, zona: 3, espacio: 3, hora: 10:00

---

