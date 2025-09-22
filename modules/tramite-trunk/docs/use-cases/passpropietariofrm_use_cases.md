# Casos de Uso - passpropietariofrm

**Categoría:** Form

## Caso de Uso 1: Autorización exitosa de propietario

**Descripción:** El usuario ingresa su firma electrónica correctamente y es autorizado para continuar con la operación.

**Precondiciones:**
El usuario existe en la tabla restricciones y la firma electrónica es correcta.

**Pasos a seguir:**
1. El usuario accede a la página de autorización.
2. El sistema muestra su usuario (readonly).
3. El usuario ingresa su firma electrónica y presiona 'Aceptar'.
4. El sistema valida vía API y SP.
5. El sistema muestra mensaje de éxito y permite continuar.

**Resultado esperado:**
El usuario es autenticado correctamente y puede continuar.

**Datos de prueba:**
{ "usuario": "jdoe", "password": "firma123" }

---

## Caso de Uso 2: Firma electrónica incorrecta

**Descripción:** El usuario ingresa una firma electrónica incorrecta.

**Precondiciones:**
El usuario existe pero la firma electrónica no coincide.

**Pasos a seguir:**
1. El usuario accede a la página de autorización.
2. Ingresa una firma electrónica incorrecta y presiona 'Aceptar'.
3. El sistema valida y rechaza la autenticación.

**Resultado esperado:**
El sistema muestra mensaje de error 'Firma electrónica incorrecta'.

**Datos de prueba:**
{ "usuario": "jdoe", "password": "claveerronea" }

---

## Caso de Uso 3: Usuario no válido

**Descripción:** Se intenta autenticar con un usuario que no existe.

**Precondiciones:**
El usuario no existe en la tabla restricciones.

**Pasos a seguir:**
1. El usuario accede a la página de autorización.
2. Ingresa un usuario inexistente y cualquier firma electrónica.
3. El sistema valida y rechaza la autenticación.

**Resultado esperado:**
El sistema muestra mensaje de error 'Usuario no válido'.

**Datos de prueba:**
{ "usuario": "noexiste", "password": "cualquier" }

---

