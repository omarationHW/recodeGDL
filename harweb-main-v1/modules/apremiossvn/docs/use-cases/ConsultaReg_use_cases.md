# Casos de Uso - ConsultaReg

**Categoría:** Form

## Caso de Uso 1: Consulta de Registro de Mercado Existente

**Descripción:** El usuario desea consultar un registro de mercado específico proporcionando los datos de oficina, mercado, sección, local, letra y bloque.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo ConsultaReg.

**Pasos a seguir:**
1. El usuario accede a la página ConsultaReg.
2. Selecciona 'Mercados' como tipo de aplicación.
3. Ingresa los datos: oficina=1, num_mercado=2, seccion='A', local=5, letra_local='B', bloque='C'.
4. Presiona 'Buscar'.
5. El sistema muestra los datos generales y el detalle de requerimientos.

**Resultado esperado:**
Se muestra la información del registro de mercado y su detalle de requerimientos.

**Datos de prueba:**
{ "tipo": 0, "oficina": 1, "num_mercado": 2, "seccion": "A", "local": 5, "letra_local": "B", "bloque": "C" }

---

## Caso de Uso 2: Consulta de Registro de Aseo Inexistente

**Descripción:** El usuario intenta consultar un registro de aseo con un número de contrato y tipo que no existen.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a ConsultaReg.
2. Selecciona 'Aseo'.
3. Ingresa contrato=99999, tipo_aseo='Z'.
4. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Registro no encontrado'.

**Datos de prueba:**
{ "tipo": 1, "contrato": 99999, "tipo_aseo": "Z" }

---

## Caso de Uso 3: Consulta de Estacionamiento Público y Navegación a Otro Registro

**Descripción:** El usuario consulta un estacionamiento público y luego decide consultar otro registro.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a ConsultaReg.
2. Selecciona 'Estacionamientos Públicos'.
3. Ingresa numesta=123.
4. Presiona 'Buscar'.
5. Visualiza los datos y presiona 'Otro Registro'.
6. El formulario se limpia y puede realizar otra consulta.

**Resultado esperado:**
Se muestra el registro público, y al presionar 'Otro Registro' el formulario se limpia.

**Datos de prueba:**
{ "tipo": 2, "numesta": 123 }

---

