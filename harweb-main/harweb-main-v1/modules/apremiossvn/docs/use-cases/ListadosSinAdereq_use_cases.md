# Casos de Uso - ListadosSinAdereq

**Categoría:** Form

## Caso de Uso 1: Consulta de locales sin adeudo en un mercado específico

**Descripción:** El usuario desea obtener el listado de locales sin adeudo en el mercado 2 de la recaudadora 1, sección A, locales del 1 al 20.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página Listados Sin Adeudos.
2. Selecciona 'Mercados' como aplicación.
3. Selecciona recaudadora 1.
4. Selecciona mercado 2.
5. Selecciona sección 'A'.
6. Ingresa local desde 1 hasta 20.
7. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los locales sin adeudo que cumplen los filtros. El usuario puede ver bloqueos y último movimiento de cada local.

**Datos de prueba:**
{ "tipo": "mercado", "id_rec": 1, "num_mercado": 2, "seccion": "A", "local1": 1, "local2": 20 }

---

## Caso de Uso 2: Consulta de bloqueos de un local

**Descripción:** El usuario desea ver los bloqueos activos del local 123.

**Precondiciones:**
El usuario debe haber realizado una búsqueda previa y tener el id_local.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver' bloqueos en la fila del local 123.

**Resultado esperado:**
Se despliega una tabla con los bloqueos activos, fechas y observaciones.

**Datos de prueba:**
{ "id_local": 123 }

---

## Caso de Uso 3: Consulta del último movimiento de un local

**Descripción:** El usuario desea ver el último movimiento (folio) del local 123.

**Precondiciones:**
El usuario debe haber realizado una búsqueda previa y tener el id_local.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver' último movimiento en la fila del local 123.

**Resultado esperado:**
Se muestra la información del último folio, diligencia, importe, fecha y vigencia.

**Datos de prueba:**
{ "id_local": 123 }

---

