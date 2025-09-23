# Casos de Uso - spublicosnewfrm

**Categoría:** Form

## Caso de Uso 1: Alta de Estacionamiento Público con datos válidos

**Descripción:** El usuario da de alta un nuevo estacionamiento público con todos los datos correctos.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el RFC y la clave predial válidos.

**Pasos a seguir:**
1. Ingresa al formulario de Alta de Estacionamiento Público.
2. Escribe al menos 4 caracteres del RFC y presiona 'Buscar'.
3. Selecciona el propietario correcto de la lista.
4. Ingresa la clave predial y presiona 'Buscar'.
5. Verifica que los datos del predio se llenen automáticamente.
6. Completa los campos restantes (categoría, cajones, teléfono, licencia, fechas, etc).
7. Presiona 'Dar de Alta'.

**Resultado esperado:**
El sistema muestra mensaje de éxito y el estacionamiento queda registrado.

**Datos de prueba:**
{ "rfc": "GOMC800101XXX", "cvepredial": "12345678901", "pubcategoria_id": 2, "cupo": 20, "telefono": "3312345678", "numesta": 101, ... }

---

## Caso de Uso 2: Intento de alta con clave predial inexistente

**Descripción:** El usuario intenta dar de alta un estacionamiento con una clave predial que no existe.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresa al formulario.
2. Escribe un RFC válido y selecciona propietario.
3. Ingresa una clave predial inexistente y presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra mensaje de error: 'Cuenta Predial Incorrecta o Cancelada'.

**Datos de prueba:**
{ "rfc": "GOMC800101XXX", "cvepredial": "00000000000" }

---

## Caso de Uso 3: Búsqueda de propietario con menos de 4 caracteres en RFC

**Descripción:** El usuario intenta buscar un propietario ingresando menos de 4 caracteres en el RFC.

**Precondiciones:**
El usuario está en el formulario de alta.

**Pasos a seguir:**
1. Ingresa 3 caracteres en el campo RFC.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra mensaje: 'Ingrese al menos 4 caracteres para buscar RFC'.

**Datos de prueba:**
{ "rfc": "GOM" }

---

