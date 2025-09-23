# Casos de Uso - ModuloDb

**Categoría:** Form

## Caso de Uso 1: Login de usuario válido

**Descripción:** Un usuario ingresa su usuario y contraseña correctos y accede al sistema.

**Precondiciones:**
El usuario existe en la tabla ta_12_passwords, está activo (estado='A') y la contraseña es correcta.

**Pasos a seguir:**
1. El usuario ingresa su usuario y contraseña en el formulario.
2. El sistema envía eRequest 'getUserByCredentials' con los datos.
3. El backend ejecuta el SP y retorna los datos del usuario.

**Resultado esperado:**
El usuario es autenticado y se muestran sus datos (nombre, nivel, recaudadora, etc).

**Datos de prueba:**
{ "username": "juan", "password": "1234" }

---

## Caso de Uso 2: Conversión de fecha a letras

**Descripción:** El usuario ingresa una fecha y el sistema la muestra en letras.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una fecha en el formulario.
2. El sistema envía eRequest 'dateToWords' con la fecha.
3. El backend ejecuta el SP y retorna la fecha en letras.

**Resultado esperado:**
La fecha se muestra en formato '15 de Marzo de 2024'.

**Datos de prueba:**
{ "date": "2024-03-15" }

---

## Caso de Uso 3: Verificación de nueva versión

**Descripción:** El sistema verifica si hay una nueva versión para el proyecto.

**Precondiciones:**
La tabla ta_versiones contiene registros de versiones.

**Pasos a seguir:**
1. El usuario ingresa el nombre del proyecto y la versión actual.
2. El sistema envía eRequest 'checkNewVersion' con los datos.
3. El backend ejecuta el SP y retorna si hay o no nueva versión.

**Resultado esperado:**
El sistema indica si la versión está actualizada o si hay una nueva versión.

**Datos de prueba:**
{ "proyecto": "BasePHP", "version": "1.0.0" }

---

