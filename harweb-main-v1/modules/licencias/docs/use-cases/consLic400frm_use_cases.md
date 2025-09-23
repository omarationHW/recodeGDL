# Casos de Uso - consLic400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos de una licencia existente

**Descripción:** El usuario ingresa el número de una licencia válida y obtiene todos los datos asociados a esa licencia.

**Precondiciones:**
La licencia debe existir en la tabla lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de licencias (/lic400/datos).
2. Ingresa el número de licencia (por ejemplo, 12345) y presiona 'Buscar'.
3. El sistema envía una petición POST a /api/execute con eRequest 'getLic400' y el parámetro 'licencia'.
4. El backend ejecuta el SP get_lic_400 y retorna los datos.
5. El frontend muestra los datos en la tabla.

**Resultado esperado:**
Se muestran todos los campos de la licencia consultada.

**Datos de prueba:**
licencia: 12345

---

## Caso de Uso 2: Consulta de pagos de una licencia existente

**Descripción:** El usuario consulta los pagos asociados a una licencia válida.

**Precondiciones:**
La licencia debe existir y tener pagos registrados en pago_lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de pagos (/lic400/pagos).
2. Ingresa el número de licencia (por ejemplo, 12345) y presiona 'Buscar Pagos'.
3. El sistema envía una petición POST a /api/execute con eRequest 'getPagoLic400' y el parámetro 'numlic'.
4. El backend ejecuta el SP get_pago_lic_400 y retorna los pagos.
5. El frontend muestra la tabla de pagos.

**Resultado esperado:**
Se muestran todos los pagos asociados a la licencia.

**Datos de prueba:**
numlic: 12345

---

## Caso de Uso 3: Consulta de licencia inexistente

**Descripción:** El usuario intenta consultar una licencia que no existe en la base de datos.

**Precondiciones:**
La licencia no debe existir en lic_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de licencias (/lic400/datos).
2. Ingresa un número de licencia inexistente (por ejemplo, 999999) y presiona 'Buscar'.
3. El sistema envía la petición al backend.
4. El backend retorna un arreglo vacío.
5. El frontend muestra un mensaje de 'No se encontró la licencia.'

**Resultado esperado:**
Se muestra un mensaje de error indicando que la licencia no existe.

**Datos de prueba:**
licencia: 999999

---

