# Casos de Uso - reqctascanfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de cuentas canceladas en Zona Centro para un rango de fechas

**Descripción:** El usuario desea obtener el listado de cuentas canceladas en la recaudadora 'Zona Centro' entre el 1 y el 31 de enero de 2024.

**Precondiciones:**
Existen cuentas canceladas en la base de datos para la recaudadora 1 (Zona Centro) en el rango de fechas especificado.

**Pasos a seguir:**
1. El usuario accede a la página 'Listado de folios de requerimiento de cuentas canceladas'.
2. Selecciona 'Zona Centro' como recaudadora.
3. Ingresa '2024-01-01' como fecha inicial y '2024-01-31' como fecha final.
4. Hace clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las cuentas canceladas en ese rango, cada una con sus folios vigentes.

**Datos de prueba:**
recaud: 1, fini: '2024-01-01', ffin: '2024-01-31'

---

## Caso de Uso 2: Validación de campos obligatorios

**Descripción:** El usuario intenta consultar sin seleccionar recaudadora o sin ingresar fechas.

**Precondiciones:**
El usuario accede al formulario.

**Pasos a seguir:**
1. El usuario deja la recaudadora sin seleccionar y/o deja vacías las fechas.
2. Hace clic en 'Imprimir'.

**Resultado esperado:**
El sistema muestra mensajes de error indicando los campos obligatorios.

**Datos de prueba:**
recaud: '', fini: '', ffin: ''

---

## Caso de Uso 3: Consulta de folios para una cuenta específica

**Descripción:** El sistema debe mostrar los folios vigentes y no cancelados para una cuenta seleccionada.

**Precondiciones:**
Existe una cuenta con cvecuenta=12345 y folios vigentes en la base de datos.

**Pasos a seguir:**
1. El usuario realiza una consulta general.
2. El sistema, para cada cuenta, consulta los folios usando el stored procedure correspondiente.

**Resultado esperado:**
En la tabla de resultados, la columna 'Folios' muestra los folios vigentes para la cuenta 12345.

**Datos de prueba:**
cvecuenta: 12345

---

