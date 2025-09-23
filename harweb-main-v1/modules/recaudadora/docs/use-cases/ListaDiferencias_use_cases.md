# Casos de Uso - ListaDiferencias

**Categoría:** Form

## Caso de Uso 1: Consulta de diferencias por rango de fechas y todas las vigencias

**Descripción:** El usuario desea obtener el listado completo de diferencias de transmisiones patrimoniales para un rango de fechas determinado, sin filtrar por vigencia.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en la base de datos para el rango de fechas seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de Diferencias'.
2. Selecciona 'Fecha Desde' = '2024-06-01' y 'Fecha Hasta' = '2024-06-30'.
3. Deja el filtro 'Vigencia' en 'Todas'.
4. Pulsa el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los registros de diferencias entre las fechas seleccionadas, sin filtrar por vigencia. Se muestra el total de registros y la suma total.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: ''

---

## Caso de Uso 2: Consulta de diferencias solo vigentes

**Descripción:** El usuario desea ver únicamente las diferencias con vigencia 'Vigentes' en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso y existen registros con vigencia 'V' en el rango de fechas.

**Pasos a seguir:**
1. Accede a la página 'Listado de Diferencias'.
2. Selecciona 'Fecha Desde' = '2024-06-01', 'Fecha Hasta' = '2024-06-30'.
3. Selecciona 'Vigencia' = 'Vigentes'.
4. Pulsa 'Buscar'.

**Resultado esperado:**
Se muestran solo los registros con vigencia 'V' (Vigentes) en la tabla.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: 'V'

---

## Caso de Uso 3: Exportación de diferencias a Excel

**Descripción:** El usuario desea exportar el listado de diferencias filtrado a un archivo Excel.

**Precondiciones:**
El usuario ha realizado una búsqueda y existen resultados.

**Pasos a seguir:**
1. Realiza una búsqueda con cualquier filtro.
2. Pulsa el botón 'Exportar Excel'.

**Resultado esperado:**
El sistema genera y descarga un archivo Excel con los resultados filtrados.

**Datos de prueba:**
fecha1: '2024-06-01', fecha2: '2024-06-30', vigencia: 'P'

---

