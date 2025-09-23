# Casos de Uso - Estad_adeudo

**Categoría:** Form

## Caso de Uso 1: Consulta de Resumen de Adeudos

**Descripción:** El usuario desea ver un resumen de los adeudos agrupados por cementerio y año.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la tabla de datos de cementerios.

**Pasos a seguir:**
1. El usuario accede a la página de Estadísticos y Listados de Adeudos.
2. Selecciona la opción 'Resumen'.
3. Hace clic en 'Procesar Información'.

**Resultado esperado:**
Se muestra una tabla con columnas Cementerio, Último Año de Pago y Total Registros, agrupando los registros correctamente.

**Datos de prueba:**
Registros en ta_13_datosrcm con diferentes valores de cementerio y axo_pagado.

---

## Caso de Uso 2: Consulta de Listado de Adeudos > 3 años

**Descripción:** El usuario desea ver el listado detallado de registros con adeudos mayores a 3 años.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros con axo_pagado <= 4.

**Pasos a seguir:**
1. El usuario accede a la página de Estadísticos y Listados de Adeudos.
2. Selecciona la opción 'Listado de adeudos'.
3. Selecciona 'Con adeudos > 3 años'.
4. Hace clic en 'Procesar Información'.

**Resultado esperado:**
Se muestra una tabla detallada con los registros cuyo axo_pagado <= 4.

**Datos de prueba:**
Registros en ta_13_datosrcm con axo_pagado = 2, 3, 4, 5.

---

## Caso de Uso 3: Error por parámetro faltante en Listado

**Descripción:** El usuario intenta consultar el listado sin enviar el parámetro axop.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El frontend envía una petición a /api/execute con action 'getListado' pero sin el parámetro axop.

**Resultado esperado:**
El backend responde con success=false y un mensaje de error indicando que axop es requerido.

**Datos de prueba:**
Petición POST sin el campo axop en params.

---

