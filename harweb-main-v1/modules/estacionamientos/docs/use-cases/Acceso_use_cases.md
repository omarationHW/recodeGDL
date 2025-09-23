# Casos de Uso - Acceso

**Categoría:** Form

## Caso de Uso 1: Inicio de sesión exitoso

**Descripción:** Un usuario válido ingresa sus credenciales y accede al sistema.

**Precondiciones:**
El usuario 'admin' existe en la tabla usuarios y está activo.

**Pasos a seguir:**
1. El usuario navega a /acceso.
2. Ingresa usuario: 'admin' y contraseña: '1234'.
3. Presiona 'Aceptar'.
4. El sistema envía la petición a /api/execute con action=login.
5. El backend valida y responde con éxito.

**Resultado esperado:**
El usuario es autenticado y redirigido al menú principal.

**Datos de prueba:**
{ "username": "admin", "password": "1234" }

---

## Caso de Uso 2: Intento de acceso con contraseña incorrecta

**Descripción:** Un usuario ingresa una contraseña incorrecta.

**Precondiciones:**
El usuario 'admin' existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. El usuario navega a /acceso.
2. Ingresa usuario: 'admin' y contraseña: 'wrongpass'.
3. Presiona 'Aceptar'.
4. El sistema envía la petición a /api/execute con action=login.
5. El backend responde con error.

**Resultado esperado:**
Se muestra mensaje 'Usuario o contraseña incorrectos'.

**Datos de prueba:**
{ "username": "admin", "password": "wrongpass" }

---

## Caso de Uso 3: Consulta de folios por año y placa

**Descripción:** Un usuario autenticado consulta los folios de un año y una placa específica.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de folios.
2. Ingresa año: 2024 y placa: 'ABC123'.
3. Presiona 'Consultar'.
4. El sistema envía la petición a /api/execute con action=getFoliosReport.
5. El backend responde con la lista de folios.

**Resultado esperado:**
Se muestra la lista de folios correspondientes.

**Datos de prueba:**
{ "year": 2024, "placa": "ABC123" }

---

