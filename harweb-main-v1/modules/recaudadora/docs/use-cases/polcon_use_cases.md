# Casos de Uso - polcon

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de póliza consolidada para un día específico

**Descripción:** El usuario desea obtener el reporte de póliza diaria consolidada para el día 2024-06-10.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas para la fecha indicada.

**Pasos a seguir:**
1. El usuario accede a la página de Póliza Diaria Consolidada.
2. Selecciona la fecha '2024-06-10' en ambos campos (Desde y Hasta).
3. Presiona el botón 'Imprimir'.
4. El sistema consulta el backend y muestra el reporte en pantalla.

**Resultado esperado:**
Se muestra una tabla con las cuentas de aplicación, descripción, total de partidas y suma de montos para el día seleccionado.

**Datos de prueba:**
date_from: '2024-06-10', date_to: '2024-06-10'

---

## Caso de Uso 2: Consulta de reporte para un rango de fechas sin resultados

**Descripción:** El usuario consulta un rango de fechas donde no existen registros.

**Precondiciones:**
El usuario tiene acceso al sistema. No existen registros en las tablas para el rango 2023-01-01 a 2023-01-05.

**Pasos a seguir:**
1. El usuario accede a la página de reporte.
2. Selecciona '2023-01-01' como Desde y '2023-01-05' como Hasta.
3. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron resultados.

**Datos de prueba:**
date_from: '2023-01-01', date_to: '2023-01-05'

---

## Caso de Uso 3: Validación de parámetros obligatorios

**Descripción:** El usuario intenta generar el reporte sin seleccionar una de las fechas.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario deja vacío el campo 'Hasta'.
2. Presiona 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que ambos campos de fecha son obligatorios.

**Datos de prueba:**
date_from: '2024-06-01', date_to: ''

---

