# Casos de Uso - PadronAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Adeudos por Recaudadora

**Descripción:** El usuario desea consultar todos los convenios vigentes de una recaudadora específica para verificar el estado de pagos y adeudos.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar el padrón.

**Pasos a seguir:**
1. El usuario accede a la página 'Padrón de Adeudos'.
2. El sistema muestra la lista de recaudadoras.
3. El usuario selecciona la recaudadora 'ZC1'.
4. El usuario pulsa el botón 'Buscar'.
5. El sistema muestra la tabla con los convenios vigentes y sus datos.

**Resultado esperado:**
Se muestra una tabla con los convenios vigentes de la recaudadora seleccionada, incluyendo nombre, convenio, pagos realizados, adeudos, etc.

**Datos de prueba:**
rec_id: 1 (ZC1)

---

## Caso de Uso 2: Exportación a Excel del Padrón de Adeudos

**Descripción:** El usuario requiere exportar el padrón de adeudos de una recaudadora a un archivo Excel para análisis externo.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario pulsa el botón 'Exportar Excel'.
2. El sistema genera el archivo Excel y lo descarga automáticamente.

**Resultado esperado:**
El usuario obtiene un archivo Excel con los mismos datos mostrados en la tabla.

**Datos de prueba:**
rec_id: 2 (ZO2)

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar el padrón sin seleccionar una recaudadora válida.

**Precondiciones:**
El usuario accede a la página pero no selecciona recaudadora.

**Pasos a seguir:**
1. El usuario pulsa 'Buscar' sin seleccionar recaudadora.
2. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
rec_id: '' (vacío o nulo)

---

