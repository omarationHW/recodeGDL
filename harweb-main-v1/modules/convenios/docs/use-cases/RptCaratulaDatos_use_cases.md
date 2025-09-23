# Casos de Uso - RptCaratulaDatos

**Categoría:** Form

## Caso de Uso 1: Consulta de Carátula de Contrato Vigente

**Descripción:** El usuario consulta la carátula de un contrato/convenio vigente, visualizando todos los datos principales, pagos y ampliaciones de plazo.

**Precondiciones:**
El contrato existe y está vigente en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Contrato'.
2. Ingresa el ID del contrato en el formulario y presiona 'Buscar'.
3. El sistema consulta el backend vía /api/execute con action 'getCaratulaDatos'.
4. El sistema muestra los datos principales, pagos detalle y ampliación de plazo (si existe).

**Resultado esperado:**
Se visualizan correctamente todos los datos del contrato, pagos y ampliación de plazo.

**Datos de prueba:**
ID Contrato: 12345 (vigente, con pagos y ampliación de plazo)

---

## Caso de Uso 2: Consulta de Contrato Inexistente

**Descripción:** El usuario intenta consultar un contrato/convenio que no existe.

**Precondiciones:**
El contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Contrato'.
2. Ingresa un ID de contrato inexistente y presiona 'Buscar'.
3. El sistema consulta el backend y no encuentra datos.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el contrato no existe.

**Datos de prueba:**
ID Contrato: 999999 (no existe)

---

## Caso de Uso 3: Consulta de Contrato Cancelado

**Descripción:** El usuario consulta la carátula de un contrato/convenio que está cancelado.

**Precondiciones:**
El contrato existe pero su campo vigencia es 'CANCELADO'.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Contrato'.
2. Ingresa el ID del contrato cancelado y presiona 'Buscar'.
3. El sistema consulta el backend y muestra los datos, indicando el estado cancelado.

**Resultado esperado:**
Se visualizan los datos del contrato y se indica claramente que está cancelado.

**Datos de prueba:**
ID Contrato: 54321 (vigencia = 'CANCELADO')

---

