# Casos de Uso - SFRM_REPORTES_EXEC

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte por Clasificación y Número de Exclusivo

**Descripción:** El usuario desea obtener un listado de todos los estacionamientos exclusivos agrupados por clasificación y ordenados por número de exclusivo.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas ex_contrato, ex_propietario, ex_clasificacion, ex_ubicacion.

**Pasos a seguir:**
1. El usuario ingresa a la página de reportes.
2. Selecciona 'Por Clasificación y Número de Exclusivo' en el selector de tipo de reporte.
3. Hace clic en 'Generar Reporte'.
4. El sistema envía un eRequest con operation 'get_reportes_exec', order_by 'clasificacion', group_by 'no_exclusivo'.
5. El backend ejecuta el SP correspondiente y retorna los datos.
6. El frontend muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con los estacionamientos exclusivos agrupados y ordenados correctamente.

**Datos de prueba:**
ex_contrato: registros con diferentes clasificaciones y números de exclusivo.

---

## Caso de Uso 2: Consulta de Estado de Cuenta por Número de Exclusivo

**Descripción:** El usuario desea consultar el estado de cuenta de un estacionamiento exclusivo específico.

**Precondiciones:**
El usuario conoce el número de exclusivo y existen datos relacionados.

**Pasos a seguir:**
1. El usuario ingresa a la página de reportes.
2. Selecciona 'Estado de Cuenta (por No. Exclusivo)'.
3. Ingresa el número de exclusivo (por ejemplo, 1234).
4. Hace clic en 'Generar Reporte'.
5. El sistema envía un eRequest con operation 'get_estado_cuenta', no_exclusivo=1234.
6. El backend ejecuta el SP correspondiente y retorna los datos.
7. El frontend muestra el estado de cuenta.

**Resultado esperado:**
Se muestra el estado de cuenta detallado del exclusivo solicitado.

**Datos de prueba:**
no_exclusivo: 1234 (debe existir en ex_contrato).

---

## Caso de Uso 3: Reporte de Adeudos de Estacionamientos Exclusivos

**Descripción:** El usuario desea obtener el reporte de adeudos de todos los estacionamientos exclusivos.

**Precondiciones:**
Existen registros con adeudos en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa a la página de reportes.
2. Selecciona 'Reporte de Adeudos'.
3. Hace clic en 'Generar Reporte'.
4. El sistema envía un eRequest con operation 'get_adeudos_exec'.
5. El backend ejecuta el SP correspondiente y retorna los datos.
6. El frontend muestra la tabla con los adeudos.

**Resultado esperado:**
Se muestra una tabla con los adeudos de todos los exclusivos.

**Datos de prueba:**
Registros en ex_contrato con adeudos calculados por las funciones fn_exc_axomin, fn_exc_mesmin, etc.

---

