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
