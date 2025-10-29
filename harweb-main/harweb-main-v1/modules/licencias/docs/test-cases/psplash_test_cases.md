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
