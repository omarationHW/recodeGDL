# Casos de Uso - RRep_Padron

**Categoría:** Form

## Caso de Uso 1: Consulta de Padrón de Concesiones Vigentes con Adeudos Vencidos

**Descripción:** El usuario desea obtener el reporte de todas las concesiones vigentes y sus adeudos vencidos al mes actual.

**Precondiciones:**
El usuario tiene acceso al sistema y existen concesiones vigentes en la base de datos.

**Pasos a seguir:**
1. Ingresar a la página 'Relación del Padrón de Concesiones'.
2. Seleccionar 'VIGENTES' en el filtro de Vigencia.
3. Seleccionar 'Periodos Vencidos' en el filtro de Adeudos.
4. Presionar el botón 'Previa'.

**Resultado esperado:**
Se muestra una tabla con todas las concesiones vigentes y, para cada una, el detalle de adeudos y recargos vencidos del mes actual.

**Datos de prueba:**
Vigencia: VIGENTES
Adeudo: Periodos Vencidos
Año: (año actual)
Mes: (mes actual)

---

## Caso de Uso 2: Consulta de Adeudos de Otro Periodo para Concesiones Canceladas

**Descripción:** El usuario requiere consultar los adeudos de un periodo específico (ej. marzo 2023) para concesiones canceladas.

**Precondiciones:**
Existen concesiones canceladas y registros de adeudos para el periodo solicitado.

**Pasos a seguir:**
1. Ingresar a la página 'Relación del Padrón de Concesiones'.
2. Seleccionar 'CANCELADOS' en el filtro de Vigencia.
3. Seleccionar 'Otro Periodo' en el filtro de Adeudos.
4. Ingresar '2023' en el campo Año.
5. Seleccionar '03' en el campo Mes.
6. Presionar el botón 'Previa'.

**Resultado esperado:**
Se muestra la tabla con concesiones canceladas y sus adeudos/recargos correspondientes a marzo 2023.

**Datos de prueba:**
Vigencia: CANCELADOS
Adeudo: Otro Periodo
Año: 2023
Mes: 03

---

## Caso de Uso 3: Validación de Año Obligatorio en Otro Periodo

**Descripción:** El usuario intenta consultar adeudos de 'Otro Periodo' sin ingresar el año.

**Precondiciones:**
El usuario accede a la página y selecciona 'Otro Periodo'.

**Pasos a seguir:**
1. Seleccionar 'Otro Periodo' en el filtro de Adeudos.
2. Dejar el campo Año vacío.
3. Presionar el botón 'Previa'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'Falta el dato del AÑO a consultar, intentalo de nuevo' y no realiza la consulta.

**Datos de prueba:**
Vigencia: cualquiera
Adeudo: Otro Periodo
Año: (vacío)
Mes: cualquiera

---

