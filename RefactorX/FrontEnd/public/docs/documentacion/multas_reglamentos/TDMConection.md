# Documentación: TDMConection

## Análisis Técnico

# Documentación Técnica: Migración TDMConection Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de conexión a base de datos originalmente desarrollada en Delphi (TDMConection) usando Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El flujo permite:
- Autenticación de usuario y contraseña contra la base de datos.
- Listado de bases de datos disponibles.
- Cierre de sesión/conexión (simulado, ya que la API es stateless).

## 2. Arquitectura
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs.
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` usando patrón eRequest/eResponse.
- **Base de Datos:** Stored Procedures en PostgreSQL para lógica de conexión y catálogo.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "eRequest": "test_connection|get_databases|close_connection",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": { ... },
      "message": "..."
    }
  }
  ```

## 4. Stored Procedures
- **sp_test_connection(user, password):** Verifica credenciales usando dblink (requiere extensión dblink).
- **sp_get_databases():** Devuelve lista de bases de datos.

## 5. Seguridad
- El procedimiento `sp_test_connection` debe ejecutarse con permisos de superusuario o con la extensión dblink instalada.
- Las credenciales no se almacenan, sólo se usan para autenticación en tiempo real.

## 6. Flujo de Usuario
1. El usuario ingresa usuario y contraseña.
2. El frontend llama a `/api/execute` con `eRequest: 'test_connection'`.
3. Si la conexión es exitosa, se muestra el mensaje y se listan las bases de datos.
4. El usuario puede cerrar la conexión (limpia el estado en frontend).

## 7. Consideraciones
- El cierre de conexión es simulado, ya que la API es stateless.
- Para ambientes productivos, se recomienda usar roles limitados y no exponer usuarios con privilegios elevados.

## 8. Dependencias
- Laravel 9+
- Vue.js 2/3
- PostgreSQL 12+
- Extensión dblink de PostgreSQL

## 9. Instalación de dblink
```sql
CREATE EXTENSION IF NOT EXISTS dblink;
```

## 10. Rutas Laravel
Agregar en `routes/api.php`:
```php
Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
```

## Casos de Uso

# Casos de Uso - TDMConection

**Categoría:** Form

## Caso de Uso 1: Conexión Exitosa con Usuario Válido

**Descripción:** El usuario ingresa credenciales válidas y se conecta exitosamente a la base de datos, visualizando el listado de bases de datos.

**Precondiciones:**
El usuario y contraseña existen en PostgreSQL y tienen permisos de conexión.

**Pasos a seguir:**
1. Ingresar usuario y contraseña válidos en el formulario.
2. Presionar el botón 'Conectar'.
3. Esperar la respuesta del sistema.

**Resultado esperado:**
El sistema muestra el mensaje 'Conexión exitosa.' y lista las bases de datos disponibles.

**Datos de prueba:**
{ "user": "cajero", "password": "c4j3r0" }

---

## Caso de Uso 2: Conexión Fallida por Contraseña Incorrecta

**Descripción:** El usuario ingresa una contraseña incorrecta y el sistema rechaza la conexión.

**Precondiciones:**
El usuario existe pero la contraseña es incorrecta.

**Pasos a seguir:**
1. Ingresar usuario válido y contraseña incorrecta.
2. Presionar 'Conectar'.

**Resultado esperado:**
El sistema muestra el mensaje 'Usuario o contraseña incorrectos.' y no lista bases de datos.

**Datos de prueba:**
{ "user": "cajero", "password": "incorrecta" }

---

## Caso de Uso 3: Cierre de Conexión

**Descripción:** El usuario cierra la conexión después de haberse conectado exitosamente.

**Precondiciones:**
El usuario está conectado.

**Pasos a seguir:**
1. Presionar el botón 'Cerrar Conexión'.

**Resultado esperado:**
El sistema limpia el estado, oculta el listado de bases de datos y muestra el mensaje 'Conexión cerrada.'

**Datos de prueba:**
N/A

---

## Casos de Prueba

## Casos de Prueba

### Caso 1: Conexión Exitosa
- **Entrada:** Usuario: cajero, Contraseña: c4j3r0
- **Acción:** Enviar eRequest: 'test_connection' con los datos.
- **Esperado:** eResponse.success = true, message = 'Conexión exitosa.', data contiene success=true.

### Caso 2: Usuario Incorrecto
- **Entrada:** Usuario: noexiste, Contraseña: cualquier
- **Acción:** Enviar eRequest: 'test_connection'.
- **Esperado:** eResponse.success = false, message = 'Usuario no existe.'

### Caso 3: Contraseña Incorrecta
- **Entrada:** Usuario: cajero, Contraseña: incorrecta
- **Acción:** Enviar eRequest: 'test_connection'.
- **Esperado:** eResponse.success = false, message = 'Usuario o contraseña incorrectos.'

### Caso 4: Listar Bases de Datos
- **Entrada:** eRequest: 'get_databases'
- **Acción:** Enviar petición sin parámetros.
- **Esperado:** eResponse.success = true, data es un array de bases de datos.

### Caso 5: Cerrar Conexión
- **Entrada:** eRequest: 'close_connection'
- **Acción:** Enviar petición.
- **Esperado:** eResponse.success = true, message = 'Connection closed (stateless API).'

## Arquitectura

> ⚠️ Pendiente de documentar

## Integración con Backend

> ⚠️ Pendiente de documentar

## Consideraciones de Migración

> ⚠️ Pendiente de documentar

