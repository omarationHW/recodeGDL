# Casos de Uso - Reportes_Folios

**Categoría:** Form

## Caso de Uso 1: Consulta de Folios de Adeudos para una Infracción Específica

**Descripción:** El usuario desea obtener el reporte de folios de adeudos para la infracción clave 5 en el mes de mayo 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y existen folios de adeudos para la infracción 5 en el periodo.

**Pasos a seguir:**
1. Ingresar a la página Reportes Folios.
2. Seleccionar '01 .- Folios de Adeudos' en Tipo de Solicitud.
3. Seleccionar '05 - [Descripción]' en Clave Infracción.
4. Ingresar fecha inicio: 2024-05-01.
5. Ingresar fecha fin: 2024-05-31.
6. Presionar 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los folios de adeudos para la infracción 5 en el rango de fechas seleccionado.

**Datos de prueba:**
{ tipo_solicitud: 1, cve_infraccion: 5, fecha_inicio: '2024-05-01', fecha_fin: '2024-05-31' }

---

## Caso de Uso 2: Reporte de Descuentos Otorgados en un Periodo

**Descripción:** El usuario requiere la relación de descuentos otorgados entre el 1 y 15 de junio 2024.

**Precondiciones:**
Existen descuentos otorgados en ese periodo.

**Pasos a seguir:**
1. Ingresar a la página Reportes Folios.
2. Seleccionar '06 .- Relación de Descuentos Otorgados' en Tipo de Solicitud.
3. Los campos de infracción se ocultan.
4. Ingresar fecha inicio: 2024-06-01.
5. Ingresar fecha fin: 2024-06-15.
6. Presionar 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con los descuentos otorgados en el periodo seleccionado.

**Datos de prueba:**
{ tipo_solicitud: 6, fecha_inicio: '2024-06-01', fecha_fin: '2024-06-15' }

---

## Caso de Uso 3: Consulta de Todos los Folios Pagados

**Descripción:** El usuario desea ver todos los folios pagados, sin filtrar por infracción, en el día actual.

**Precondiciones:**
Existen folios pagados en la fecha actual.

**Pasos a seguir:**
1. Ingresar a la página Reportes Folios.
2. Seleccionar '02 .- Folios Pagados' en Tipo de Solicitud.
3. Seleccionar '00 - Todos' en Clave Infracción.
4. Ingresar fecha inicio y fin con la fecha de hoy.
5. Presionar 'Ejecutar'.

**Resultado esperado:**
Se muestra una tabla con todos los folios pagados en la fecha actual.

**Datos de prueba:**
{ tipo_solicitud: 2, cve_infraccion: 0, fecha_inicio: '2024-06-10', fecha_fin: '2024-06-10' }

---

