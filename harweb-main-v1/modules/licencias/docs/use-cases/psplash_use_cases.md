# Casos de Uso - psplash

**Categoría:** Form

## Caso de Uso 1: Visualización del Splash al iniciar la aplicación

**Descripción:** El usuario accede a la aplicación y se muestra la pantalla de splash con el mensaje de carga, versión y logotipo.

**Precondiciones:**
El backend y frontend están desplegados y accesibles.

**Pasos a seguir:**
1. El usuario navega a la ruta /splash
2. El componente Vue solicita los datos de splash y versión vía /api/execute
3. El backend responde con los textos y la imagen
4. El frontend muestra la pantalla splash con los datos recibidos

**Resultado esperado:**
El usuario ve la pantalla splash con el mensaje 'Cargando Aplicación', el texto 'Padrón y Licencias', la versión y la imagen institucional.

**Datos de prueba:**
No requiere datos de entrada, usa los valores por defecto de los SP.

---

## Caso de Uso 2: Obtención de la versión de la aplicación vía API

**Descripción:** Un sistema externo o el frontend solicita la versión actual de la aplicación para mostrarla o validarla.

**Precondiciones:**
El endpoint /api/execute está disponible.

**Pasos a seguir:**
1. Realizar una petición POST a /api/execute con { "eRequest": { "action": "get_version" } }
2. El backend ejecuta el SP y responde con la versión y metadatos.

**Resultado esperado:**
La respuesta contiene la versión, nombre de la app y metadatos.

**Datos de prueba:**
{ "eRequest": { "action": "get_version" } }

---

## Caso de Uso 3: Carga de datos de splash personalizados

**Descripción:** El administrador ha personalizado el mensaje de splash y la imagen en la base de datos.

**Precondiciones:**
El SP psplash_get_splash_data() ha sido modificado para devolver los nuevos valores.

**Pasos a seguir:**
1. El usuario accede a /splash
2. El frontend solicita los datos de splash
3. El backend responde con los valores personalizados
4. El frontend muestra el mensaje e imagen personalizados

**Resultado esperado:**
El splash muestra el mensaje y la imagen personalizados.

**Datos de prueba:**
SP modificado para devolver 'Bienvenido al Sistema' y una imagen base64 diferente.

---

