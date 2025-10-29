# Casos de Uso - psplash

**Categoría:** Form

## Caso de Uso 1: Visualización de la pantalla splash al iniciar la aplicación

**Descripción:** El usuario accede a la aplicación y se muestra la pantalla de bienvenida con la imagen, mensaje y versión.

**Precondiciones:**
El usuario accede a la ruta /psplash o la aplicación inicia.

**Pasos a seguir:**
1. El usuario abre la aplicación web.
2. El frontend Vue.js solicita a la API la información del splash (`psplash.getSplashInfo`).
3. La API responde con la URL de la imagen, versión y copyright.
4. El frontend muestra la imagen y los textos correspondientes.

**Resultado esperado:**
La pantalla splash se muestra correctamente con la imagen, mensaje de bienvenida y versión.

**Datos de prueba:**
No se requiere data específica, se usan los valores por defecto del stored procedure.

---

## Caso de Uso 2: Registro de visualización del splash (auditoría)

**Descripción:** El sistema registra que un usuario ha visualizado la pantalla splash.

**Precondiciones:**
El usuario está autenticado y la función de log está habilitada.

**Pasos a seguir:**
1. El usuario accede a la pantalla splash.
2. El frontend envía una petición a la API con `eRequest: 'psplash.logSplashView'` y el user_id.
3. La API ejecuta el stored procedure de log.
4. El registro queda almacenado en la tabla de logs.

**Resultado esperado:**
El evento de visualización queda registrado con user_id, IP y timestamp.

**Datos de prueba:**
{ "user_id": 123 }

---

## Caso de Uso 3: Error al solicitar información de splash con eRequest inválido

**Descripción:** El frontend envía un eRequest no soportado y la API responde con error.

**Precondiciones:**
El endpoint /api/execute está disponible.

**Pasos a seguir:**
1. El frontend envía una petición con `eRequest: 'psplash.invalidRequest'`.
2. La API detecta que el eRequest no es válido.
3. La API responde con success=false y un mensaje de error.

**Resultado esperado:**
La respuesta contiene success=false y un mensaje indicando eRequest inválido.

**Datos de prueba:**
{ "eRequest": "psplash.invalidRequest" }

---

