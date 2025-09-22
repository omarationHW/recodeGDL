# Casos de Uso - Modulo

**Categoría:** Form

## Caso de Uso 1: Validación de Usuario Correcto

**Descripción:** Un usuario ingresa su usuario y clave correctos para acceder al sistema.

**Precondiciones:**
El usuario y clave existen y están activos en la base de datos.

**Pasos a seguir:**
- El usuario ingresa su usuario y clave en el formulario.
- Presiona el botón 'Validar'.
- El sistema envía la petición a /api/execute con action 'getUserByCredentials'.

**Resultado esperado:**
El sistema responde que el usuario es válido y muestra el ID del usuario.

**Datos de prueba:**
{ usuario: 'jdoe', clave: '1234' }

---

## Caso de Uso 2: Validación de Usuario Incorrecto

**Descripción:** Un usuario ingresa un usuario o clave incorrectos.

**Precondiciones:**
El usuario o clave no existen o el usuario está inactivo.

**Pasos a seguir:**
- El usuario ingresa usuario y clave incorrectos.
- Presiona 'Validar'.
- El sistema envía la petición a /api/execute.

**Resultado esperado:**
El sistema responde que el usuario o clave son incorrectos.

**Datos de prueba:**
{ usuario: 'jdoe', clave: 'wrongpass' }

---

## Caso de Uso 3: Verificación de Nueva Versión

**Descripción:** El usuario consulta si existe una nueva versión para su proyecto.

**Precondiciones:**
El proyecto y versión existen en la tabla ta_versiones.

**Pasos a seguir:**
- El usuario ingresa el nombre del proyecto y la versión actual.
- Presiona 'Verificar'.
- El sistema consulta si hay una nueva versión.

**Resultado esperado:**
El sistema indica si la versión está actualizada o si hay una nueva disponible.

**Datos de prueba:**
{ proyecto: 'BasePHP', version: '1.0.0' }

---

