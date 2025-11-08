# Casos de Uso - GirosDconAdeudofrm

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte para año con adeudos existentes

**Descripción:** El usuario desea obtener el reporte de giros restringidos con adeudos para un año en el que existen registros.

**Precondiciones:**
El usuario tiene acceso al sistema y existen licencias con adeudo en el año 2022.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de giros restringidos con adeudos.
2. Ingresa el año '2022' en el campo correspondiente.
3. Presiona el botón 'Imprimir'.
4. El sistema consulta el reporte y muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con las licencias, nombres, ubicaciones, giros y el total de giros con adeudo desde 2022.

**Datos de prueba:**
year: 2022

---

## Caso de Uso 2: Consulta de reporte para año sin adeudos

**Descripción:** El usuario consulta el reporte para un año en el que no existen licencias con adeudo.

**Precondiciones:**
El usuario tiene acceso al sistema y no existen licencias con adeudo en el año 1999.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Ingresa el año '1999'.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra el mensaje 'No se encontraron licencias...'.

**Datos de prueba:**
year: 1999

---

## Caso de Uso 3: Validación de año inválido

**Descripción:** El usuario intenta consultar el reporte ingresando un año inválido (por ejemplo, 1800).

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Ingresa el año '1800'.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el año es inválido.

**Datos de prueba:**
year: 1800

---

