# Casos de Uso - ConsRemesas

**Categoría:** Form

## Caso de Uso 1: Consulta de remesas del estado (Tipo A)

**Descripción:** El usuario accede a la página de Consulta de Remesas y visualiza todas las remesas del estado (tipo 'A').

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen remesas de tipo 'A' en la base de datos.

**Pasos a seguir:**
1. El usuario navega a la página 'Consulta de Remesas'.
2. Por defecto, la opción 'Del Estado' está seleccionada.
3. El sistema consulta y muestra la lista de remesas de tipo 'A'.

**Resultado esperado:**
Se muestra una tabla con todas las remesas de tipo 'A', ordenadas por número de remesa descendente.

**Datos de prueba:**
Remesas en ta14_bitacora con tipo = 'A'.

---

## Caso de Uso 2: Consulta de detalle de una remesa del estado

**Descripción:** El usuario consulta el detalle de una remesa específica del estado.

**Precondiciones:**
Existen remesas de tipo 'A' y registros relacionados en ta14_datos_edo.

**Pasos a seguir:**
1. El usuario visualiza la lista de remesas del estado.
2. El usuario hace doble clic sobre una remesa.
3. El sistema consulta y muestra el detalle de la remesa desde ta14_datos_edo.

**Resultado esperado:**
Se muestra una tabla con el detalle de la remesa seleccionada. Si no hay registros, se muestra un mensaje de advertencia.

**Datos de prueba:**
Remesa con num_remesa = 1001, registros en ta14_datos_edo con remesa = 'dti_est_r1001'.

---

## Caso de Uso 3: Consulta de remesas de pagos en Banorte (Tipo D)

**Descripción:** El usuario selecciona la opción 'Pgos. en Banorte' y visualiza las remesas correspondientes.

**Precondiciones:**
Existen remesas de tipo 'D' en la base de datos.

**Pasos a seguir:**
1. El usuario navega a la página 'Consulta de Remesas'.
2. El usuario selecciona la opción 'Pgos. en Banorte'.
3. El sistema consulta y muestra la lista de remesas de tipo 'D'.

**Resultado esperado:**
Se muestra una tabla con todas las remesas de tipo 'D', ordenadas por número de remesa descendente.

**Datos de prueba:**
Remesas en ta14_bitacora con tipo = 'D'.

---

