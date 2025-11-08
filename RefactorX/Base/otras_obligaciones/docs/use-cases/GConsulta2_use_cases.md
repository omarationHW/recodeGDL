# Casos de Uso - GConsulta2

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos por Control

**Descripción:** El usuario desea consultar los adeudos de un local específico usando el número de control.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el número de control.

**Pasos a seguir:**
1. Ingresa a la página de Consulta General.
2. Selecciona 'CONTROL' como tipo de búsqueda.
3. Escribe el número de control (ej: 'SP/1') y presiona Enter.
4. Selecciona el control de la lista de resultados.
5. Visualiza los datos principales, adeudos, totales y pagos realizados.

**Resultado esperado:**
Se muestran los datos del local, el detalle de adeudos, los totales y los pagos realizados.

**Datos de prueba:**
par_tab=3, tipo_busqueda=1, dato_busqueda='SP/1'

---

## Caso de Uso 2: Consulta por Nombre Comercial

**Descripción:** El usuario busca todos los locales cuyo nombre comercial contiene una palabra clave.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresa a la página de Consulta General.
2. Selecciona 'NOMBRE COMERCIAL' como tipo de búsqueda.
3. Escribe la palabra clave (ej: 'TORTILLERIA') y presiona Enter.
4. Selecciona un control de la lista.
5. Visualiza los datos y adeudos.

**Resultado esperado:**
Se listan todos los controles cuyo nombre comercial contiene la palabra clave, y al seleccionar uno se muestran sus datos y adeudos.

**Datos de prueba:**
par_tab=3, tipo_busqueda=4, dato_busqueda='TORTILLERIA'

---

## Caso de Uso 3: Visualización de Pagos Realizados

**Descripción:** El usuario consulta los pagos realizados para un local específico.

**Precondiciones:**
El usuario ha realizado una búsqueda y seleccionado un control.

**Pasos a seguir:**
1. Realiza una búsqueda y selecciona un control.
2. Haz clic en el botón 'Ver Pagados'.
3. Se despliega la tabla de pagos realizados.

**Resultado esperado:**
Se muestra la lista de pagos realizados para el control seleccionado.

**Datos de prueba:**
p_Control=12345 (id_datos de un local con pagos)

---

