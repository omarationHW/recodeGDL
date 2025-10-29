# Casos de Uso - DsDBGasto

**Categoría:** Form

## Caso de Uso 1: Autenticación exitosa y conexión a estación

**Descripción:** El usuario ingresa credenciales válidas de seguridad y se conecta exitosamente a la base de datos de estación.

**Precondiciones:**
El usuario 'admin' con contraseña 'admin123' existe en 'seguridad_usuarios'. El usuario 'estacion' con contraseña '3st4c10n' existe en 'estacion_usuarios'.

**Pasos a seguir:**
1. El usuario accede a la página de conexión de gasto.
2. Ingresa usuario: 'admin', contraseña: 'admin123'.
3. Presiona 'Conectar'.
4. El sistema valida las credenciales de seguridad.
5. El sistema valida la conexión a estación.
6. Se muestra mensaje de éxito.

**Resultado esperado:**
Mensaje: '¡Conexión exitosa a ambas bases de datos!'

**Datos de prueba:**
Usuario: admin, Contraseña: admin123

---

## Caso de Uso 2: Fallo de autenticación de seguridad

**Descripción:** El usuario ingresa credenciales incorrectas de seguridad.

**Precondiciones:**
El usuario 'admin' existe, pero la contraseña ingresada es incorrecta.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa usuario: 'admin', contraseña: 'wrongpass'.
3. Presiona 'Conectar'.
4. El sistema rechaza la autenticación.

**Resultado esperado:**
Mensaje de error: 'Usuario o contraseña incorrectos'

**Datos de prueba:**
Usuario: admin, Contraseña: wrongpass

---

## Caso de Uso 3: Fallo de conexión a estación

**Descripción:** El usuario de seguridad es válido, pero el usuario 'estacion' no existe en la base de datos de estación.

**Precondiciones:**
El usuario 'admin'/'admin123' existe en seguridad. El usuario 'estacion' NO existe en 'estacion_usuarios'.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa usuario: 'admin', contraseña: 'admin123'.
3. Presiona 'Conectar'.
4. El sistema valida seguridad.
5. El sistema intenta conectar a estación y falla.

**Resultado esperado:**
Mensaje de error: 'No se pudo conectar a estación'

**Datos de prueba:**
Usuario: admin, Contraseña: admin123

---

