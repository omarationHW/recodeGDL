# Casos de Uso - RConsulta

**Categoría:** Form

## Caso de Uso 1: Consulta de Local Existente con Adeudos y Pagos

**Descripción:** El usuario consulta un local existente, visualiza sus datos, adeudos actuales y pagos realizados.

**Precondiciones:**
El local existe en la base de datos y tiene adeudos y pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Ingresa el número de local y letra.
3. Presiona 'Buscar'.
4. El sistema muestra los datos del local, tabla de adeudos, totales y pagos realizados.

**Resultado esperado:**
Se muestran correctamente los datos del local, los adeudos vigentes y los pagos realizados.

**Datos de prueba:**
{ "numero": "123", "letra": "A" }

---

## Caso de Uso 2: Consulta de Local Inexistente

**Descripción:** El usuario intenta consultar un local que no existe.

**Precondiciones:**
El local no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Ingresa un número de local y letra inexistentes.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el local no existe.

**Datos de prueba:**
{ "numero": "999", "letra": "Z" }

---

## Caso de Uso 3: Consulta de Local Suspendido o Cancelado

**Descripción:** El usuario consulta un local que existe pero está en estado suspendido o cancelado.

**Precondiciones:**
El local existe pero su campo cve_stat es distinto de 'V'.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Ingresa el número de local y letra.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el local está suspendido o cancelado.

**Datos de prueba:**
{ "numero": "456", "letra": "B" }

---

