# Documentación Técnica: psplash

## Análisis Técnico

# Documentación Técnica: Migración Formulario Splash (psplash)

## Descripción General
Este módulo corresponde al formulario de splash de la aplicación de Licencias. Su función es mostrar la pantalla de bienvenida, versión, mensaje de carga y logotipo/imágenes institucionales.

La migración incluye:
- Backend Laravel con endpoint único `/api/execute` (patrón eRequest/eResponse)
- Stored Procedures en PostgreSQL para obtener datos de splash y versión
- Componente Vue.js como página completa independiente

## Arquitectura
- **Backend:** Laravel Controller `PsplashController` expone `/api/execute` para todas las acciones relacionadas al splash.
- **Frontend:** Componente Vue.js `PsplashPage` que consume la API y muestra la pantalla splash.
- **Base de Datos:** Stored Procedures PostgreSQL para encapsular la lógica de obtención de datos.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "get_version" | "get_splash_data"
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": { ...datos... }
  }
  ```

## Stored Procedures
- `psplash_get_version()`: Devuelve versión, nombre de app, copyright, compañía.
- `psplash_get_splash_data()`: Devuelve mensaje de carga, texto de efecto, imagen base64.

## Frontend (Vue.js)
- Página independiente `/splash` (o ruta definida en router)
- Muestra imagen, mensaje, versión y efecto visual
- No usa tabs ni componentes tabulares
- Incluye breadcrumb de navegación

## Backend (Laravel)
- Controlador `PsplashController` con método `execute(Request $request)`
- Llama a los stored procedures según la acción recibida
- Devuelve respuesta en formato eResponse

## Seguridad
- No requiere autenticación para el splash (público)
- No expone información sensible

## Extensibilidad
- Los SP pueden modificarse para leer datos de tablas de configuración
- El endpoint puede extenderse para otras acciones relacionadas al splash

## Notas de Migración
- El splash no requiere persistencia ni lógica de negocio compleja
- La imagen puede almacenarse en base64 en la base de datos o como archivo estático
- El frontend es completamente desacoplado y puede integrarse en cualquier SPA

## Casos de Prueba

## Casos de Prueba para Splash (psplash)

### Caso 1: Solicitud de versión
- **Entrada:**
  ```json
  { "eRequest": { "action": "get_version" } }
  ```
- **Esperado:**
  - Código HTTP 200
  - Respuesta contiene campos: version, app_name, copyright, company
  - version = '1.0.0.0'

### Caso 2: Solicitud de datos de splash
- **Entrada:**
  ```json
  { "eRequest": { "action": "get_splash_data" } }
  ```
- **Esperado:**
  - Código HTTP 200
  - Respuesta contiene campos: message, label_effect, image_base64
  - message = 'Cargando Aplicación'
  - label_effect = 'Padrón y Licencias'

### Caso 3: Acción no soportada
- **Entrada:**
  ```json
  { "eRequest": { "action": "invalid_action" } }
  ```
- **Esperado:**
  - Código HTTP 400
  - Respuesta contiene error: true y mensaje de acción no soportada

### Caso 4: Visualización en Frontend
- **Precondición:** Backend responde correctamente a los endpoints
- **Acción:** Navegar a /splash
- **Esperado:**
  - Se muestra la imagen (si existe), el mensaje y la versión
  - No hay errores en consola

### Caso 5: Error de base de datos
- **Precondición:** SP psplash_get_version() eliminado o con error
- **Entrada:**
  ```json
  { "eRequest": { "action": "get_version" } }
  ```
- **Esperado:**
  - Código HTTP 500
  - Respuesta contiene error: true y mensaje de error

## Casos de Uso

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
