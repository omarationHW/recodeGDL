# Casos de Uso - RptCaratulaDatos

**Categoría:** Form

## Caso de Uso 1: Consulta de Carátula de Local con Adeudo Vigente

**Descripción:** El usuario consulta la carátula de un local con adeudos y recargos vigentes.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El local existe y tiene adeudos registrados.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Ingresa el ID del local y los importes de renta, adeudo, recargos, gastos, multa y total.
3. Presiona 'Consultar Carátula'.
4. El sistema consulta el backend vía /api/execute con action 'getRptCaratulaDatos'.
5. El backend ejecuta el stored procedure y retorna los datos completos del local y sus adeudos.

**Resultado esperado:**
Se muestra la información completa del local, incluyendo datos generales, adeudos por periodo, recargos calculados y leyenda de descuento si aplica.

**Datos de prueba:**
{ "id_local": 1001, "renta": 1200.00, "adeudo": 600.00, "recargos": 60.00, "gastos": 20.00, "multa": 0.00, "total": 680.00, "folios": "1234,1235,", "leyenda": "Desc. pronto pago" }

---

## Caso de Uso 2: Consulta de Local sin Adeudos

**Descripción:** El usuario consulta la carátula de un local que está al corriente de pagos.

**Precondiciones:**
El usuario está autenticado. El local existe y no tiene adeudos.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Ingresa el ID del local y deja los importes de adeudo, recargos, gastos y multa en cero.
3. Presiona 'Consultar Carátula'.
4. El sistema consulta el backend vía /api/execute.
5. El backend retorna los datos del local y un arreglo vacío de adeudos.

**Resultado esperado:**
Se muestra la información del local y un mensaje o tabla vacía indicando que no existen adeudos.

**Datos de prueba:**
{ "id_local": 2002, "renta": 900.00, "adeudo": 0.00, "recargos": 0.00, "gastos": 0.00, "multa": 0.00, "total": 900.00, "folios": "", "leyenda": "" }

---

## Caso de Uso 3: Consulta con Error de Parámetros

**Descripción:** El usuario intenta consultar la carátula sin ingresar el ID del local.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página 'Carátula de Locales'.
2. Deja el campo ID Local vacío y presiona 'Consultar Carátula'.
3. El frontend valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje de error indicando que el ID Local es requerido.

**Datos de prueba:**
{ "id_local": "", "renta": 0, "adeudo": 0, "recargos": 0, "gastos": 0, "multa": 0, "total": 0, "folios": "", "leyenda": "" }

---

