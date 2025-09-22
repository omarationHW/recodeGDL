# Casos de Uso - ImpRecibofrm

**Categoría:** Form

## Caso de Uso 1: Imprimir recibo de certificación para licencia vigente

**Descripción:** El usuario busca una licencia vigente y genera el recibo de pago para certificación.

**Precondiciones:**
La licencia existe y está vigente en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 12345).
3. Selecciona 'Certificación'.
4. Presiona Enter o clic en 'Imprimir'.
5. El sistema consulta la licencia y muestra el recibo con los datos y monto correspondiente.

**Resultado esperado:**
Se muestra la vista previa del recibo con los datos de la licencia, el concepto 'CERTIFICACIÓN', el monto y la cantidad en letra.

**Datos de prueba:**
licencia: 12345, tipo: 'certificacion'

---

## Caso de Uso 2: Intentar imprimir recibo para licencia inexistente

**Descripción:** El usuario ingresa un número de licencia que no existe.

**Precondiciones:**
La licencia no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 99999).
3. Presiona Enter.
4. El sistema muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje 'No se encontró licencia con ese número' y no se habilita el botón de imprimir.

**Datos de prueba:**
licencia: 99999, tipo: 'certificacion'

---

## Caso de Uso 3: Imprimir recibo de constancia para licencia vigente

**Descripción:** El usuario busca una licencia vigente y genera el recibo de pago para constancia.

**Precondiciones:**
La licencia existe y está vigente en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de impresión de recibos.
2. Ingresa el número de licencia (ej: 54321).
3. Selecciona 'Constancia'.
4. Presiona Enter o clic en 'Imprimir'.
5. El sistema consulta la licencia y muestra el recibo con los datos y monto correspondiente.

**Resultado esperado:**
Se muestra la vista previa del recibo con los datos de la licencia, el concepto 'CONSTANCIA', el monto y la cantidad en letra.

**Datos de prueba:**
licencia: 54321, tipo: 'constancia'

---

