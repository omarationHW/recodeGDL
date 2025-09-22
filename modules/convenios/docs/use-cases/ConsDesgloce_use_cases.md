# Casos de Uso - ConsDesgloce

**Categoría:** Form

## Caso de Uso 1: Consulta de desgloce de cuentas para un adeudo existente

**Descripción:** El usuario desea ver el desgloce de cuentas de aplicación para un adeudo específico.

**Precondiciones:**
El usuario conoce el ID del adeudo y tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Desgloce.
2. Ingresa el ID de adeudo en el formulario.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla con el desgloce de cuentas.

**Resultado esperado:**
Se muestra una tabla con las parcialidades, importes, cuentas y descripciones asociadas al adeudo.

**Datos de prueba:**
id_adeudo: 12345

---

## Caso de Uso 2: Consulta de desgloce con ID de adeudo inexistente

**Descripción:** El usuario intenta consultar un desgloce para un ID de adeudo que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta Desgloce.
2. Ingresa un ID de adeudo inexistente (por ejemplo, 999999).
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de 'No hay datos para mostrar.' o error amigable.

**Datos de prueba:**
id_adeudo: 999999

---

## Caso de Uso 3: Consulta del catálogo de cuentas de aplicación para el año actual

**Descripción:** El usuario requiere el catálogo de cuentas de aplicación para el año en curso.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El frontend envía una petición con action 'getCuentasAplicacion' y el año actual.
2. El backend retorna el catálogo de cuentas.

**Resultado esperado:**
Se obtiene una lista de cuentas y descripciones para el año solicitado.

**Datos de prueba:**
year: 2024

---

