# Casos de Uso - repmultampalfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de multas por dependencia y rango de fechas

**Descripción:** El usuario desea obtener un reporte de todas las multas de una dependencia específica en un rango de fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de multas para la dependencia seleccionada.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Dependencia' y seleccionar la dependencia deseada.
3. Seleccionar 'Rango de fechas' como tipo de fecha.
4. Ingresar la fecha de inicio y fin.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas de la dependencia seleccionada dentro del rango de fechas especificado.

**Datos de prueba:**
Dependencia: 'Tránsito'
Fecha inicio: 2024-01-01
Fecha fin: 2024-06-30

---

## Caso de Uso 2: Búsqueda de multas por nombre de contribuyente y año

**Descripción:** El usuario busca todas las multas de un contribuyente específico en un año determinado.

**Precondiciones:**
El usuario tiene acceso y existen multas registradas para el contribuyente y año indicados.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Nombre' e ingresar el nombre del contribuyente.
3. Seleccionar 'Año' como tipo de fecha e ingresar el año.
4. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas del contribuyente en el año especificado.

**Datos de prueba:**
Nombre: 'MARIA LOPEZ'
Año: 2023

---

## Caso de Uso 3: Consulta de multas vigentes por infracción y domicilio

**Descripción:** El usuario desea ver todas las multas vigentes de una infracción específica y domicilio que comiencen con un texto dado.

**Precondiciones:**
El usuario tiene acceso y existen multas vigentes para la infracción y domicilio indicados.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Multas Municipales.
2. Activar el filtro 'Infracción' y seleccionar la infracción.
3. Activar el filtro 'Domicilio' e ingresar el texto inicial del domicilio.
4. Seleccionar 'Vigente' como estado.
5. Hacer clic en 'Imprimir / Consultar'.

**Resultado esperado:**
Se muestra una tabla con todas las multas vigentes que cumplen con los filtros de infracción y domicilio.

**Datos de prueba:**
Infracción: 'ESTACIONARSE EN LUGAR PROHIBIDO'
Domicilio: 'AVENIDA PRINCIPAL'

---

