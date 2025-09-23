# Casos de Uso - Unit1

**Categoría:** Form

## Caso de Uso 1: Generar reporte de folios para una fecha/hora específica

**Descripción:** El usuario desea obtener el listado de folios emitidos para una fecha/hora determinada.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la base de datos para la fecha/hora seleccionada.

**Pasos a seguir:**
1. Ingresar a la página de reporte de folios.
2. Seleccionar la fecha y hora deseada en el formulario.
3. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los folios, placas, estado, clave e importe correspondientes a la fecha/hora seleccionada.

**Datos de prueba:**
fechora: '2024-06-01T10:00'

---

## Caso de Uso 2: Intentar generar reporte sin seleccionar fecha/hora

**Descripción:** El usuario intenta generar el reporte sin ingresar la fecha/hora requerida.

**Precondiciones:**
El usuario accede a la página de reporte.

**Pasos a seguir:**
1. Dejar el campo de fecha/hora vacío.
2. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la fecha/hora es obligatoria.

**Datos de prueba:**
fechora: ''

---

## Caso de Uso 3: Generar reporte para una fecha/hora sin registros

**Descripción:** El usuario selecciona una fecha/hora para la cual no existen folios registrados.

**Precondiciones:**
No existen registros en la base de datos para la fecha/hora seleccionada.

**Pasos a seguir:**
1. Seleccionar una fecha/hora sin registros.
2. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje informando que no se encontraron resultados.

**Datos de prueba:**
fechora: '2023-01-01T00:00'

---

