# Casos de Uso - PadronLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Locales por Recaudadora

**Descripción:** El usuario desea visualizar el padrón de locales activos de una recaudadora específica.

**Precondiciones:**
El usuario tiene acceso al sistema y existen recaudadoras y locales activos en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página 'Padron de Locales'.
2. Selecciona una recaudadora del combo.
3. Presiona el botón 'Generar Padron'.
4. El sistema consulta el padrón vía API y muestra la tabla.

**Resultado esperado:**
Se muestra la lista de locales activos de la recaudadora seleccionada, con todos los campos y la renta calculada.

**Datos de prueba:**
Recaudadora: 1 (ZONA CENTRO)

---

## Caso de Uso 2: Exportación del Padrón de Locales a Excel

**Descripción:** El usuario desea exportar el padrón de locales a un archivo Excel.

**Precondiciones:**
El usuario ya visualizó el padrón de una recaudadora.

**Pasos a seguir:**
1. El usuario hace clic en 'Exportar a Excel'.
2. El sistema envía la petición al backend.
3. El backend prepara los datos para exportación (simulado).
4. El usuario recibe confirmación (o descarga el archivo si está implementado).

**Resultado esperado:**
El usuario puede descargar el archivo Excel con los datos del padrón.

**Datos de prueba:**
Recaudadora: 2 (ZONA OLIMPICA)

---

## Caso de Uso 3: Validación de Parámetro Obligatorio

**Descripción:** El usuario intenta generar el padrón sin seleccionar recaudadora.

**Precondiciones:**
El usuario accede a la página pero no selecciona recaudadora.

**Pasos a seguir:**
1. El usuario deja el combo de recaudadora vacío.
2. Presiona 'Generar Padron'.
3. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema muestra el mensaje 'Seleccione una recaudadora' y no realiza la consulta.

**Datos de prueba:**
Recaudadora: (vacío)

---

