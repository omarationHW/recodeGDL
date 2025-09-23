# Casos de Uso - ActualizaCont

**Categoría:** Form

## Caso de Uso 1: Caso de Uso 1: Visualizar Diferencias de Contratos

**Descripción:** El usuario desea ver qué contratos de desarrollo social no existen en el catálogo de calles.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en ta_17_paso_cont que no están en ta_17_calles.

**Pasos a seguir:**
1. El usuario accede a la página 'Actualiza Contratos'.
2. El sistema muestra automáticamente la tabla de diferencias (colonia, calle, contratos).

**Resultado esperado:**
Se visualiza una lista de diferencias con la cantidad de contratos por colonia y calle.

**Datos de prueba:**
ta_17_paso_cont: colonia=101, calle=5, ...; ta_17_calles: sin registro colonia=101, calle=5

---

## Caso de Uso 2: Caso de Uso 2: Ejecutar Actualización Masiva de Contratos

**Descripción:** El usuario ejecuta la actualización para migrar los contratos desde la tabla temporal al catálogo principal.

**Precondiciones:**
El usuario está autenticado y existen diferencias detectadas.

**Pasos a seguir:**
1. El usuario hace clic en 'Actualizar Contratos'.
2. El sistema ejecuta el stored procedure de actualización.
3. Se muestran los totales de la operación.

**Resultado esperado:**
Se muestran los totales: adicionados, modificados, inconsistencias, total general, descuentos.

**Datos de prueba:**
ta_17_paso_cont: 3 registros nuevos, 2 existentes, 1 inconsistente (error de datos).

---

## Caso de Uso 3: Caso de Uso 3: Consultar Totales de la Última Actualización

**Descripción:** El usuario consulta los totales de la última actualización ejecutada.

**Precondiciones:**
El usuario ha ejecutado al menos una actualización.

**Pasos a seguir:**
1. El usuario accede a la sección de totales.
2. El sistema consulta y muestra los totales de la última ejecución.

**Resultado esperado:**
Se muestran los valores de adicionados, modificados, inconsistencias, total y descuentos.

**Datos de prueba:**
Totales almacenados en la última ejecución: 5 adicionados, 2 modificados, 1 inconsistencia, 8 total, 1 descuento.

---

