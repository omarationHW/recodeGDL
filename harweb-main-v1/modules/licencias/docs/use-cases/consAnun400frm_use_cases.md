# Casos de Uso - consAnun400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos de un anuncio existente

**Descripción:** El usuario ingresa el número de un anuncio válido y consulta todos los datos asociados.

**Precondiciones:**
El anuncio debe existir en la tabla anuncio_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de anuncios.
2. Ingresa el número de anuncio (por ejemplo, 12345).
3. Presiona el botón 'Buscar'.
4. El sistema consulta el backend vía /api/execute con eRequest 'getAnuncio400'.
5. El backend ejecuta el stored procedure y retorna los datos.
6. El frontend muestra todos los campos del anuncio.

**Resultado esperado:**
Se muestran todos los datos del anuncio solicitado, sin errores.

**Datos de prueba:**
{ "anuncio": 12345 }

---

## Caso de Uso 2: Consulta de pagos asociados a un anuncio

**Descripción:** El usuario navega a la página de pagos de un anuncio y visualiza el historial de pagos.

**Precondiciones:**
El anuncio debe existir y tener pagos registrados en pago_anun_400.

**Pasos a seguir:**
1. El usuario consulta un anuncio y hace clic en 'Ver Pagos'.
2. El sistema navega a la página de pagos del anuncio.
3. El frontend solicita los pagos vía /api/execute con eRequest 'getPagosAnuncio400'.
4. El backend ejecuta el stored procedure y retorna los pagos.
5. El frontend muestra la tabla de pagos.

**Resultado esperado:**
Se muestra la lista de pagos asociados al anuncio.

**Datos de prueba:**
{ "numanu": 12345 }

---

## Caso de Uso 3: Manejo de error: anuncio inexistente

**Descripción:** El usuario ingresa un número de anuncio que no existe en la base de datos.

**Precondiciones:**
El número de anuncio no debe existir en anuncio_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de anuncios.
2. Ingresa un número de anuncio inexistente (por ejemplo, 999999).
3. Presiona 'Buscar'.
4. El sistema consulta el backend vía /api/execute.
5. El backend retorna un arreglo vacío o error.
6. El frontend muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje indicando que el anuncio no existe.

**Datos de prueba:**
{ "anuncio": 999999 }

---

