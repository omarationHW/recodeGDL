# Casos de Uso - sqrp_publicos

**Categoría:** Form

## Caso de Uso 1: Visualización del reporte clasificado por Número

**Descripción:** El usuario accede a la página de Estacionamientos Públicos y visualiza el reporte ordenado por número.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla ta_15_publicos con estatus diferente de 'B'.

**Pasos a seguir:**
1. El usuario navega a la página de Estacionamientos Públicos.
2. El sistema carga el reporte con la opción 'Número' (opc=1) por defecto.
3. El usuario visualiza la tabla con los datos ordenados por número.

**Resultado esperado:**
La tabla muestra todos los estacionamientos públicos activos, ordenados por número, con todos los campos y clasificaciones calculadas.

**Datos de prueba:**
Registros en ta_15_publicos con diferentes valores de cve_numero, cve_sector, cve_categ, etc.

---

## Caso de Uso 2: Cambio de clasificación a 'Nombre'

**Descripción:** El usuario selecciona 'Nombre' en el selector de clasificación y el reporte se actualiza.

**Precondiciones:**
El usuario está en la página de Estacionamientos Públicos y existen registros con diferentes nombres.

**Pasos a seguir:**
1. El usuario selecciona 'Nombre' en el selector de clasificación.
2. El sistema envía la petición con opc=2.
3. El reporte se actualiza y muestra los datos ordenados por nombre.

**Resultado esperado:**
La tabla se actualiza y muestra los estacionamientos ordenados alfabéticamente por nombre.

**Datos de prueba:**
Registros en ta_15_publicos con nombres variados.

---

## Caso de Uso 3: Reporte sin resultados (todos los registros estatus 'B')

**Descripción:** El usuario accede al reporte pero todos los registros tienen estatus 'B'.

**Precondiciones:**
La tabla ta_15_publicos sólo contiene registros con estatus 'B'.

**Pasos a seguir:**
1. El usuario accede a la página de Estacionamientos Públicos.
2. El sistema consulta el reporte (cualquier opc).
3. No se encuentran registros activos.

**Resultado esperado:**
El sistema muestra el mensaje 'No hay datos para mostrar.'

**Datos de prueba:**
Todos los registros en ta_15_publicos tienen estatus = 'B'.

---

