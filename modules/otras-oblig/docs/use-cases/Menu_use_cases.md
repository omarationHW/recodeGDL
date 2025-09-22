# Casos de Uso - Menu

**Categoría:** Form

## Caso de Uso 1: Inicio de Sesión y Carga de Menú

**Descripción:** El usuario accede al sistema, ingresa sus credenciales y visualiza el menú correspondiente a su nivel.

**Precondiciones:**
El usuario existe en la tabla ta_12_passwords y tiene permisos activos.

**Pasos a seguir:**
1. El usuario ingresa usuario y contraseña en la pantalla de login.
2. El sistema envía la petición a /api/execute con operación 'login'.
3. El backend valida las credenciales y retorna los datos del usuario.
4. El frontend solicita el menú con operación 'getMenu'.
5. El backend retorna el menú según el nivel del usuario.
6. El frontend muestra el menú y los ejercicios disponibles.

**Resultado esperado:**
El usuario ve el menú y puede navegar según sus permisos.

**Datos de prueba:**
{ "usuario": "admin", "password": "secreto" }

---

## Caso de Uso 2: Cambio de Ejercicio

**Descripción:** El usuario cambia el ejercicio fiscal y el sistema actualiza el contexto.

**Precondiciones:**
El usuario ya está autenticado y el menú está cargado.

**Pasos a seguir:**
1. El usuario selecciona un ejercicio diferente en el combo de ejercicios.
2. El frontend actualiza el valor de ejercicio y lo propaga a los formularios hijos.

**Resultado esperado:**
El sistema utiliza el nuevo ejercicio para todas las operaciones posteriores.

**Datos de prueba:**
{ "ejercicio": 2024 }

---

## Caso de Uso 3: Verificación de Nueva Versión

**Descripción:** El sistema verifica si existe una nueva versión del sistema para el usuario.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El frontend envía una petición a /api/execute con operación 'checkVersion' y los parámetros de proyecto y versión actual.
2. El backend consulta la tabla ta_versiones y responde si hay una versión más reciente.

**Resultado esperado:**
El frontend muestra un mensaje si hay una nueva versión disponible.

**Datos de prueba:**
{ "proyecto": "Aseo.exe", "version": "1.0.0.0" }

---

