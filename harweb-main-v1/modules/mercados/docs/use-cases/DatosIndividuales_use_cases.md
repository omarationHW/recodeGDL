# Casos de Uso - DatosIndividuales

**Categoría:** Form

## Caso de Uso 1: Consulta de Datos Individuales de un Local

**Descripción:** El usuario consulta toda la información relevante de un local específico, incluyendo datos generales, adeudos, requerimientos y movimientos.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID del local.

**Pasos a seguir:**
1. El usuario accede a la página de consulta individual.
2. Ingresa el ID del local o navega desde una lista.
3. El sistema realiza una petición a /api/execute con action 'getDatosIndividuales' y el id_local.
4. El sistema carga y muestra los datos generales, adeudos, requerimientos y movimientos.

**Resultado esperado:**
Se muestran correctamente todos los datos del local, incluyendo tablas de adeudos, requerimientos y movimientos.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 2: Consulta de Adeudos de un Local

**Descripción:** El usuario desea ver el detalle de los adeudos de un local.

**Precondiciones:**
El usuario tiene acceso y el local tiene adeudos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de adeudos desde la página de datos individuales.
2. El sistema realiza una petición a /api/execute con action 'getAdeudos' y el id_local.
3. El sistema muestra la tabla de adeudos.

**Resultado esperado:**
Se muestra la lista de adeudos con año, mes, importe y recargos.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 3: Consulta de Requerimientos de un Local

**Descripción:** El usuario revisa los requerimientos fiscales asociados a un local.

**Precondiciones:**
El usuario tiene acceso y el local tiene requerimientos registrados.

**Pasos a seguir:**
1. El usuario accede a la sección de requerimientos desde la página de datos individuales.
2. El sistema realiza una petición a /api/execute con action 'getRequerimientos' y el id_local.
3. El sistema muestra la tabla de requerimientos.

**Resultado esperado:**
Se muestra la lista de requerimientos con folio, fecha, importe multa, importe gastos y vigencia.

**Datos de prueba:**
{ "id_local": 123 }

---

