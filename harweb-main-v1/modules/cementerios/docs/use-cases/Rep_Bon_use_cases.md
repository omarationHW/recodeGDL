# Casos de Uso - Rep_Bon

**Categoría:** Form

## Caso de Uso 1: Consulta de Bonificaciones Pendientes por Recaudadora

**Descripción:** El usuario desea ver todos los oficios de bonificación pendientes para la recaudadora número 3.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros pendientes para la recaudadora 3.

**Pasos a seguir:**
1. Accede a la página 'Reporte de Oficios de Bonificación'.
2. Ingresa '3' en el campo Recaudadora.
3. Selecciona 'Pendientes'.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los oficios de bonificación pendientes para la recaudadora 3.

**Datos de prueba:**
{ "eRequest": { "action": "listar", "recaudadora": 3, "pendientes": true } }

---

## Caso de Uso 2: Impresión de Reporte de Todos los Oficios

**Descripción:** El usuario desea imprimir el reporte de todos los oficios (pendientes y aplicados) para la recaudadora 2.

**Precondiciones:**
El usuario tiene acceso y existen registros para la recaudadora 2.

**Pasos a seguir:**
1. Accede a la página 'Reporte de Oficios de Bonificación'.
2. Ingresa '2' en el campo Recaudadora.
3. Selecciona 'Todos'.
4. Presiona 'Imprimir'.

**Resultado esperado:**
Se genera el reporte (simulado) con todos los oficios de la recaudadora 2.

**Datos de prueba:**
{ "eRequest": { "action": "imprimir", "recaudadora": 2, "pendientes": false } }

---

## Caso de Uso 3: Validación de Error en Recaudadora

**Descripción:** El usuario ingresa un número de recaudadora inválido (10) y espera un mensaje de error.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página 'Reporte de Oficios de Bonificación'.
2. Ingresa '10' en el campo Recaudadora.
3. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra el mensaje 'Error en la Recaudadora'.

**Datos de prueba:**
{ "eRequest": { "action": "listar", "recaudadora": 10, "pendientes": true } }

---

