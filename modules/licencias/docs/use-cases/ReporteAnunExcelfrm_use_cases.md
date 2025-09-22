# Casos de Uso - ReporteAnunExcelfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de anuncios vigentes sin adeudo a la fecha

**Descripción:** El usuario desea obtener un listado de todos los anuncios vigentes (vigente = 'V') que no tienen adeudo, a la fecha actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen anuncios vigentes en la base de datos.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'A la Fecha' como tipo de reporte
- Seleccionar 'Vigentes (V)' como vigencia
- Seleccionar 'Sin Adeudo' como filtro de adeudo
- Ingresar la fecha de consulta (por defecto hoy)
- Presionar 'Consultar'

**Resultado esperado:**
Se muestra una tabla con los anuncios vigentes sin adeudo, con todas las columnas relevantes.

**Datos de prueba:**
Anuncios con vigente = 'V' y sin adeudo en detsal_lic.

---

## Caso de Uso 2: Exportar reporte de anuncios con adeudo desde año específico

**Descripción:** El usuario requiere exportar a Excel todos los anuncios que tienen adeudo desde el año 2022.

**Precondiciones:**
Existen anuncios con adeudo desde 2022.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'A la Fecha' como tipo de reporte
- Seleccionar 'Todas' como vigencia
- Seleccionar 'Con Adeudo desde' como filtro de adeudo
- Ingresar año 2022
- Presionar 'Exportar a Excel'

**Resultado esperado:**
Se descarga un archivo Excel con los anuncios filtrados por adeudo desde 2022.

**Datos de prueba:**
Anuncios con registros en detsal_lic con cvepago=0 y axo=2022.

---

## Caso de Uso 3: Filtrar anuncios por grupo y rango de fechas

**Descripción:** El usuario desea ver anuncios de un grupo específico en un rango de fechas de otorgamiento.

**Precondiciones:**
Existen grupos de anuncios y anuncios asociados.

**Pasos a seguir:**
- Acceder a la página de Reporte de Anuncios
- Seleccionar 'Rango de Fechas' como tipo de reporte
- Ingresar fechas de inicio y fin
- Seleccionar un grupo de anuncios
- Presionar 'Consultar'

**Resultado esperado:**
Se muestran solo los anuncios del grupo seleccionado y en el rango de fechas indicado.

**Datos de prueba:**
Anuncios asociados a un grupo y con fecha_otorgamiento dentro del rango.

---

