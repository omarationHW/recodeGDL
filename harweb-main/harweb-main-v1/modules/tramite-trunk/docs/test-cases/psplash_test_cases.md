## Casos de Prueba para psplash

### Caso 1: Carga exitosa de la pantalla splash
- **Precondición:** El endpoint /api/execute está disponible.
- **Acción:**
  - Enviar POST a /api/execute con `{ "eRequest": "psplash.getSplashInfo" }`
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: contiene image_url, version, copyright

### Caso 2: Registro de visualización del splash
- **Precondición:** Tabla psplash_log existe y el usuario está autenticado.
- **Acción:**
  - Enviar POST a /api/execute con `{ "eRequest": "psplash.logSplashView", "params": { "user_id": 1 } }`
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: logged=true, log_time actual

### Caso 3: eRequest inválido
- **Precondición:** El endpoint /api/execute está disponible.
- **Acción:**
  - Enviar POST a /api/execute con `{ "eRequest": "psplash.invalidRequest" }`
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: contiene 'Invalid eRequest'
  - errors: contiene información del error

### Caso 4: Imagen no encontrada
- **Precondición:** El archivo /assets/splash.jpg no existe.
- **Acción:**
  - Acceder a la pantalla splash en el frontend.
- **Resultado esperado:**
  - La imagen no se muestra o muestra un placeholder.
  - El resto de la información se muestra correctamente.

### Caso 5: Error de base de datos
- **Precondición:** El stored procedure psplash_get_splash_info no existe.
- **Acción:**
  - Enviar POST a /api/execute con `{ "eRequest": "psplash.getSplashInfo" }`
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: contiene mensaje de error de base de datos
