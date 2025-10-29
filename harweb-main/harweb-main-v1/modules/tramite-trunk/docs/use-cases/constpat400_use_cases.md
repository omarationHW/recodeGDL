# Casos de Uso - constpat400

**Categoría:** Form

## Caso de Uso 1: Consulta por Fecha y Recaudadora

**Descripción:** El usuario desea consultar todos los pagos y transmisiones patrimoniales realizados en una fecha específica y por una recaudadora determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en las tablas para la fecha y recaudadora consultadas.

**Pasos a seguir:**
1. Ingresar la fecha de pago (por ejemplo, 20240101).
2. Ingresar el número de recaudadora (por ejemplo, 5).
3. Dejar los campos 'Caja' y 'Operación' vacíos.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestran en las tablas los pagos y transmisiones patrimoniales correspondientes a la fecha y recaudadora seleccionadas.

**Datos de prueba:**
{ "fecha": 20240101, "recaud": 5, "operacion": null, "caja": null }

---

## Caso de Uso 2: Consulta por Operación y Caja

**Descripción:** El usuario busca un pago y transmisión patrimonial específicos usando el número de operación y la caja.

**Precondiciones:**
El usuario conoce el número de operación y la caja. Existen registros coincidentes.

**Pasos a seguir:**
1. Ingresar el número de operación (por ejemplo, 12345).
2. Ingresar el identificador de caja (por ejemplo, 'B').
3. Dejar los campos 'Fecha' y 'Recaudadora' vacíos.
4. Hacer clic en 'Buscar'.

**Resultado esperado:**
Se muestran los registros que coinciden exactamente con la operación y la caja indicadas.

**Datos de prueba:**
{ "fecha": null, "recaud": null, "operacion": 12345, "caja": "B" }

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario realiza una consulta con filtros que no coinciden con ningún registro.

**Precondiciones:**
No existen registros en la base de datos que cumplan con los filtros ingresados.

**Pasos a seguir:**
1. Ingresar una fecha inexistente (por ejemplo, 20991231).
2. Ingresar una recaudadora inexistente (por ejemplo, 99).
3. Hacer clic en 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se localizaron pagos de transmisiones patrimoniales en el AS400.

**Datos de prueba:**
{ "fecha": 20991231, "recaud": 99, "operacion": null, "caja": null }

---

