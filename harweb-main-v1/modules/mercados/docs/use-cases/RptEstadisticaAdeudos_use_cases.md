# Casos de Uso - RptEstadisticaAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta Global de Adeudos Vencidos

**Descripción:** El usuario desea obtener la estadística global de adeudos vencidos al periodo seleccionado, sin filtrar por importe.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2024) y el periodo (por ejemplo, 6).
3. Seleccionar 'Global' como tipo de reporte.
4. Dejar el campo 'Importe mínimo' en 0 o vacío.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con todos los adeudos vencidos al periodo 2024-6, agrupados por oficina, mercado y local, con el total de adeudo por cada uno.

**Datos de prueba:**
{ axo: 2024, periodo: 6, importe: 0, opc: 1 }

---

## Caso de Uso 2: Consulta de Adeudos Mayores a un Importe

**Descripción:** El usuario desea obtener sólo los adeudos cuyo importe total es mayor o igual a un valor específico.

**Precondiciones:**
El usuario tiene acceso al sistema y existen adeudos con importes mayores o iguales al valor ingresado.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2023) y el periodo (por ejemplo, 12).
3. Ingresar '5000' en el campo 'Importe mínimo'.
4. Seleccionar 'Sólo mayores o iguales a importe' como tipo de reporte.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los adeudos vencidos al periodo 2023-12 cuyo importe total es mayor o igual a $5,000, agrupados por oficina, mercado y local.

**Datos de prueba:**
{ axo: 2023, periodo: 12, importe: 5000, opc: 2 }

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario realiza una consulta para un periodo y un importe mínimo tan alto que no existen adeudos que cumplan el criterio.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página de Estadística de Adeudos.
2. Ingresar el año (por ejemplo, 2022) y el periodo (por ejemplo, 1).
3. Ingresar '9999999' en el campo 'Importe mínimo'.
4. Seleccionar 'Sólo mayores o iguales a importe' como tipo de reporte.
5. Hacer clic en 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados para los criterios seleccionados.

**Datos de prueba:**
{ axo: 2022, periodo: 1, importe: 9999999, opc: 2 }

---

