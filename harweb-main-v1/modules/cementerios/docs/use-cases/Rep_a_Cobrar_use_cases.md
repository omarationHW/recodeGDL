# Casos de Uso - Rep_a_Cobrar

**Categoría:** Form

## Caso de Uso 1: Generar reporte de cementerios a cobrar para un mes

**Descripción:** El usuario desea obtener el reporte de mantenimiento y recargos de cementerios para su recaudadora en un mes específico.

**Precondiciones:**
El usuario está autenticado y tiene asignado un id_rec válido.

**Pasos a seguir:**
1. El usuario accede a la página de 'Reporte de Cementerios a Cobrar'.
2. Selecciona el mes deseado en el formulario.
3. Presiona el botón 'Generar Reporte'.
4. El sistema consulta el backend y muestra la tabla de resultados.

**Resultado esperado:**
Se muestra una tabla con los años, montos de mantenimiento, recargos y total para cada año.

**Datos de prueba:**
{ "mes": 3, "id_rec": 1 }

---

## Caso de Uso 2: Visualizar datos de la recaudadora

**Descripción:** El usuario necesita ver el nombre y zona de su recaudadora antes de generar el reporte.

**Precondiciones:**
El usuario está autenticado y tiene un id_rec válido.

**Pasos a seguir:**
1. El usuario accede a la página del reporte.
2. El sistema automáticamente consulta y muestra el nombre y zona de la recaudadora.

**Resultado esperado:**
El campo 'Recaudadora' muestra el nombre y zona correspondiente.

**Datos de prueba:**
{ "id_rec": 1 }

---

## Caso de Uso 3: Intentar generar reporte sin seleccionar mes

**Descripción:** El usuario intenta generar el reporte sin seleccionar un mes.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario deja el campo 'Mes' vacío.
2. Presiona 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el mes es requerido.

**Datos de prueba:**
{ "mes": null, "id_rec": 1 }

---

