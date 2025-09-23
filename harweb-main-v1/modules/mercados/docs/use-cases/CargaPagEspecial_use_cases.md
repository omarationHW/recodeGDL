# Casos de Uso - CargaPagEspecial

**Categoría:** Form

## Caso de Uso 1: Carga masiva de pagos especiales para un local con adeudos de años anteriores

**Descripción:** El usuario regulariza los pagos de un local con adeudos históricos, seleccionando los adeudos y cargando los pagos correspondientes.

**Precondiciones:**
El usuario tiene permisos para cargar pagos especiales. Existen adeudos históricos para el local seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y captura el número de local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra los adeudos históricos del local.
5. El usuario captura la partida para cada adeudo a pagar y selecciona los adeudos.
6. Presiona 'Cargar Pagos'.
7. El sistema inserta los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos se insertan correctamente y los adeudos seleccionados se eliminan. Se muestra un mensaje de éxito.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2004, "periodo": 8, "importe": 1000, "partida": "P-001" }] }

---

## Caso de Uso 2: Intento de cargar pagos sin capturar partida

**Descripción:** El usuario intenta cargar pagos sin capturar el número de partida para los adeudos seleccionados.

**Precondiciones:**
Existen adeudos históricos para el local seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra los adeudos.
5. El usuario no captura la partida y presiona 'Cargar Pagos'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe capturar la partida.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2004, "periodo": 8, "importe": 1000, "partida": "" }] }

---

## Caso de Uso 3: Carga de pago con descuento automático (2005-10)

**Descripción:** El usuario carga un pago para el periodo 2005-10, el sistema aplica automáticamente un descuento del 10%.

**Precondiciones:**
Existe un adeudo para el local en axo=2005, periodo=10.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos Especial.
2. Selecciona el mercado y local.
3. Presiona 'Buscar Adeudos'.
4. El sistema muestra el adeudo para 2005-10.
5. El usuario captura la partida y selecciona el adeudo.
6. Presiona 'Cargar Pagos'.

**Resultado esperado:**
El pago se inserta con el importe de la renta menos el 10% de descuento.

**Datos de prueba:**
{ "mercado": 10, "local": 123, "adeudos": [{ "axo": 2005, "periodo": 10, "importe": 1000, "partida": "P-002" }] }

---

