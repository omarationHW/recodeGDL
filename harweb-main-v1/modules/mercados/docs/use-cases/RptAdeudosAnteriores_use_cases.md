# Casos de Uso - RptAdeudosAnteriores

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Anteriores por Año y Oficina

**Descripción:** El usuario desea obtener el listado de adeudos de años anteriores a 1996 para una oficina y año específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de Adeudos Anteriores'.
2. Ingresa el año (ej. 1994), la oficina (ej. 2), y el periodo (ej. 7).
3. Presiona el botón 'Consultar'.
4. El sistema muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los locales, datos, meses adeudados, renta y adeudo total para los parámetros seleccionados.

**Datos de prueba:**
{ "axo": 1994, "oficina": 2, "periodo": 7 }

---

## Caso de Uso 2: Detalle de Meses de Adeudo de un Local

**Descripción:** El usuario desea ver los meses específicos de adeudo para un local en el año consultado.

**Precondiciones:**
El usuario ya realizó una consulta general y tiene el ID del local.

**Pasos a seguir:**
1. El usuario hace clic en el botón de detalle de meses (o similar) en la fila de un local.
2. El frontend envía un request con action 'get_mes_adeudo' y los parámetros correspondientes.
3. El sistema retorna los meses y montos adeudados.

**Resultado esperado:**
Se muestra un listado de los meses y montos adeudados para el local seleccionado.

**Datos de prueba:**
{ "id_local": 123, "axo": 1994 }

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar el reporte con parámetros inválidos (ej. año vacío o texto).

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario deja el campo año vacío o ingresa un texto no numérico.
2. Presiona 'Consultar'.
3. El sistema valida y retorna un mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el año es obligatorio y debe ser numérico.

**Datos de prueba:**
{ "axo": "", "oficina": 2, "periodo": 7 }

---

