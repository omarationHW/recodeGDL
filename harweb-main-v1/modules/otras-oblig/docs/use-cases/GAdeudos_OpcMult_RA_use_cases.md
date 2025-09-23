# Casos de Uso - GAdeudos_OpcMult_RA

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudo por Número de Expediente

**Descripción:** El usuario desea consultar los datos de una concesión/adeudo utilizando el número de expediente.

**Precondiciones:**
El usuario tiene acceso a la página y conoce el número de expediente válido.

**Pasos a seguir:**
1. El usuario accede a la página de Re-activación de Adeudos.
2. Ingresa el número de expediente en el campo correspondiente.
3. Presiona Enter o hace clic en 'Buscar'.
4. El sistema consulta la API y muestra los datos generales de la concesión si existen.

**Resultado esperado:**
Se muestran los datos de la concesión, incluyendo status, concesionario, ubicación, fechas, etc.

**Datos de prueba:**
par_tab: 2
numExpN: '12345'
(Se asume que existe la concesión para ese expediente)

---

## Caso de Uso 2: Consulta de Adeudo por Número de Local y Letra

**Descripción:** El usuario desea consultar los datos de una concesión utilizando el número de local y letra.

**Precondiciones:**
El usuario tiene acceso a la página y conoce el número de local y letra válidos. La tabla corresponde a locales (glo_Tabla = 3).

**Pasos a seguir:**
1. El usuario accede a la página de Re-activación de Adeudos.
2. Ingresa el número de local y la letra en los campos correspondientes.
3. Presiona Enter o hace clic en 'Buscar'.
4. El sistema consulta la API y muestra los datos generales de la concesión si existen.

**Resultado esperado:**
Se muestran los datos de la concesión correspondiente al local y letra ingresados.

**Datos de prueba:**
glo_Tabla: 3
localNum: '10'
letra: 'B'
(Se asume que existe la concesión para ese local y letra)

---

## Caso de Uso 3: Manejo de Error: Expediente o Local No Existente

**Descripción:** El usuario intenta consultar un expediente o local que no existe en la base de datos.

**Precondiciones:**
El usuario tiene acceso a la página y proporciona un número de expediente o local inexistente.

**Pasos a seguir:**
1. El usuario accede a la página de Re-activación de Adeudos.
2. Ingresa un número de expediente o local inválido.
3. Presiona Enter o hace clic en 'Buscar'.
4. El sistema consulta la API y recibe status = -1.

**Resultado esperado:**
Se muestra un mensaje de error: 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo'.

**Datos de prueba:**
par_tab: 2
numExpN: '99999'
(Se asume que no existe la concesión para ese expediente)

---

