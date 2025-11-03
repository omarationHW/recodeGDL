# 🔐 Autenticación JWT - API Odoo

## ✅ Implementación Completa

El API de Odoo ahora usa **JWT (JSON Web Tokens)** para autenticación segura con:

✅ **Generación de tokens** con expiración configurable (24h por defecto)
✅ **Validación automática** de tokens en cada request
✅ **Refresh tokens** para renovar sin re-autenticar
✅ **Client credentials** (client_id + client_secret)
✅ **Retrocompatibilidad** con tokens estáticos

---

## 🚀 Quick Start (3 pasos)

### 1️⃣ Configurar variables de entorno

Agregar en `.env`:

```env
# JWT Secret (cambiar en producción - mínimo 32 caracteres)
JWT_SECRET=your-super-secret-key-at-least-32-chars-long-for-security

# Tiempo de expiración (en horas)
JWT_EXPIRATION_HOURS=24

# Algoritmo de firma
JWT_ALGORITHM=HS256

# Credenciales de clientes
ODOO_CLIENT_001_SECRET=mi-super-secreto-produccion-2025
ODOO_CLIENT_DEV_SECRET=secreto-desarrollo
ODOO_CLIENT_TEST_SECRET=secreto-pruebas
```

### 2️⃣ Instalar dependencia JWT

```bash
composer require firebase/php-jwt
```

### 3️⃣ Generar tu primer token

**Request:**
```bash
curl -X POST http://localhost:8000/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "odoo-client-001",
    "client_secret": "mi-super-secreto-produccion-2025"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Token generado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2MjM...",
  "type": "Bearer",
  "expires_in": 86400,
  "expires_at": "2025-02-12 10:30:00",
  "issued_at": "2025-02-11 10:30:00"
}
```

---

## 🔑 Endpoints de Autenticación

### 1. Generar Token

**Endpoint:** `POST /api/odoo/auth/token`

**Request:**
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025",
  "client_name": "Odoo Production",
  "permissions": ["consulta", "pago", "cancelacion"]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Token generado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "type": "Bearer",
  "expires_in": 86400,
  "expires_at": "2025-02-12 10:30:00",
  "issued_at": "2025-02-11 10:30:00",
  "instructions": {
    "use_header": "Authorization: Bearer {token}",
    "or_use_body": "eRequest.Token: {token}"
  }
}
```

**Parámetros:**
- `client_id` (requerido): ID del cliente configurado
- `client_secret` (requerido): Secreto del cliente
- `client_name` (opcional): Nombre descriptivo
- `permissions` (opcional): Array de permisos

---

### 2. Validar Token

**Endpoint:** `POST /api/odoo/auth/validate`

**Request:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (token válido):**
```json
{
  "success": true,
  "message": "Token válido",
  "client_id": "odoo-client-001",
  "client_name": "Odoo Production",
  "permissions": ["consulta", "pago"],
  "expires_at": "2025-02-12 10:30:00",
  "time_left": "23h 45m"
}
```

**Response (token expirado):**
```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

---

### 3. Refrescar Token

**Endpoint:** `POST /api/odoo/auth/refresh`

**Request:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Token refrescado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc... (nuevo token)",
  "type": "Bearer",
  "expires_in": 86400,
  "expires_at": "2025-02-13 10:30:00"
}
```

---

### 4. Información JWT

**Endpoint:** `GET /api/odoo/auth/info`

**Response:**
```json
{
  "success": true,
  "jwt_info": {
    "algorithm": "HS256",
    "expiration_hours": 24,
    "expiration_seconds": 86400,
    "issuer": "http://localhost:8000"
  },
  "endpoints": {
    "generate_token": "http://localhost:8000/api/odoo/auth/token",
    "validate_token": "http://localhost:8000/api/odoo/auth/validate",
    "refresh_token": "http://localhost:8000/api/odoo/auth/refresh"
  },
  "usage": {
    "step_1": "POST /api/odoo/auth/token con client_id y client_secret",
    "step_2": "Usar el token en Authorization: Bearer {token}",
    "step_3": "Refrescar antes de que expire con /api/odoo/auth/refresh"
  }
}
```

---

## 🔐 Usar el Token en Servicios

### Opción 1: Header (Recomendado)

```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678"
      }
    }
  }'
```

### Opción 2: Body

```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678"
      }
    }
  }'
```

---

## ⚙️ Configuración de Clientes

### Editar `config/odoo.php`

```php
'jwt_clients' => [
    'odoo-client-001' => [
        'secret' => env('ODOO_CLIENT_001_SECRET', 'change-this-secret'),
        'name' => 'Odoo Production',
        'permissions' => ['*'] // Todos los permisos
    ],
    'odoo-client-dev' => [
        'secret' => env('ODOO_CLIENT_DEV_SECRET', 'dev-secret'),
        'name' => 'Odoo Development',
        'permissions' => ['consulta', 'adeudo'] // Solo consultas
    ],
    'mi-nuevo-cliente' => [
        'secret' => env('MI_NUEVO_CLIENTE_SECRET', 'otro-secreto'),
        'name' => 'Mi Cliente Personalizado',
        'permissions' => ['pago', 'cancelacion']
    ],
],
```

### Variables de Entorno (.env)

```env
# Cliente de Producción
ODOO_CLIENT_001_SECRET=secreto-produccion-muy-seguro-123456

# Cliente de Desarrollo
ODOO_CLIENT_DEV_SECRET=secreto-desarrollo-456789

# Cliente Personalizado
MI_NUEVO_CLIENTE_SECRET=mi-secreto-personalizado-789012
```

---

## 🕐 Configurar Tiempo de Expiración

### Por defecto: 24 horas

En `.env`:
```env
JWT_EXPIRATION_HOURS=24
```

### Ejemplos de configuración:

```env
# 1 hora
JWT_EXPIRATION_HOURS=1

# 12 horas
JWT_EXPIRATION_HOURS=12

# 24 horas (recomendado)
JWT_EXPIRATION_HOURS=24

# 48 horas
JWT_EXPIRATION_HOURS=48

# 7 días (168 horas)
JWT_EXPIRATION_HOURS=168
```

---

## 🔄 Flujo Completo

### Paso 1: Generar Token

```bash
curl -X POST http://localhost:8000/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "odoo-client-001",
    "client_secret": "mi-super-secreto-produccion-2025"
  }'
```

**Guardar el token:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "expires_at": "2025-02-12 10:30:00"
}
```

### Paso 2: Usar Token en Servicios

```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678"
      }
    }
  }'
```

### Paso 3: Refrescar Token (antes de que expire)

```bash
curl -X POST http://localhost:8000/api/odoo/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }'
```

**Nuevo token:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9... (nuevo)",
  "expires_at": "2025-02-13 10:30:00"
}
```

---

## 🛡️ Seguridad

### ✅ Mejores Prácticas

1. **JWT_SECRET debe ser único y complejo**
   ```env
   # ❌ Malo
   JWT_SECRET=123456

   # ✅ Bueno
   JWT_SECRET=kJ8$mP2#xL9@qR5&wT3^nV7!bC1*fG4%hD6
   ```

2. **Cambiar secretos en producción**
   - Nunca usar los valores por defecto
   - Usar generadores de passwords seguros
   - Mínimo 32 caracteres

3. **Rotar secretos periódicamente**
   - Cada 6 meses en producción
   - Planificar rotación sin downtime

4. **Configurar expiración adecuada**
   - APIs públicas: 1-2 horas
   - APIs internas: 24 horas
   - Servicios batch: 7 días

5. **Usar HTTPS en producción**
   - Nunca enviar tokens por HTTP
   - Configurar SSL/TLS

### ⚠️ Errores Comunes

| Error | Solución |
|-------|----------|
| "JWT_SECRET no está configurado" | Agregar `JWT_SECRET` en `.env` |
| "Token inválido o expirado" | Generar nuevo token |
| "Credenciales inválidas" | Verificar `client_id` y `client_secret` |
| "Class JwtService not found" | Ejecutar `composer dump-autoload` |
| "firebase/php-jwt not found" | Ejecutar `composer require firebase/php-jwt` |

---

## 📊 Estructura del Token JWT

### Token Decodificado

```json
{
  "iat": 1707652200,              // Issued At (timestamp)
  "exp": 1707738600,              // Expiration (timestamp)
  "iss": "http://localhost:8000", // Issuer
  "data": {
    "client_id": "odoo-client-001",
    "client_name": "Odoo Production",
    "permissions": ["*"],
    "type": "odoo_integration"
  }
}
```

### Header

```json
{
  "typ": "JWT",
  "alg": "HS256"
}
```

---

## 🧪 Testing con Postman

### 1. Generar Token

**POST** `http://localhost:8000/api/odoo/auth/token`

**Body (raw JSON):**
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025"
}
```

**Guardar token en variable:** `{{jwt_token}}`

### 2. Usar Token

**POST** `http://localhost:8000/api/odoo`

**Headers:**
```
Authorization: Bearer {{jwt_token}}
Content-Type: application/json
```

**Body:**
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678"
    }
  }
}
```

---

## 📝 Logs

Los logs de JWT se guardan en `storage/logs/laravel.log`:

```
[2025-02-11 10:30:00] 🔑 JWT generado
[2025-02-11 10:30:15] ✅ Token JWT válido
[2025-02-11 10:30:30] ⏰ JWT expirado
[2025-02-11 10:30:45] 🚫 JWT con firma inválida
```

---

## 🔄 Migración de Tokens Estáticos a JWT

### Retrocompatibilidad

El sistema soporta **ambos métodos** durante la migración:

✅ **Tokens JWT** (recomendado)
✅ **Tokens estáticos** (deprecated, para migración)

### Plan de Migración

1. **Fase 1: Implementar JWT** (actual)
   - Ambos sistemas funcionan
   - Nuevos clientes usan JWT
   - Clientes legacy usan tokens estáticos

2. **Fase 2: Migrar clientes**
   - Notificar a clientes
   - Proporcionar credenciales JWT
   - Dar plazo de migración (30 días)

3. **Fase 3: Deprecar tokens estáticos**
   - Desactivar tokens estáticos
   - Solo JWT activo

---

## 📚 Recursos

- **RFC 7519:** https://tools.ietf.org/html/rfc7519
- **JWT.io:** https://jwt.io (decodificar tokens)
- **firebase/php-jwt:** https://github.com/firebase/php-jwt

---

## ✅ Checklist de Implementación

- [ ] Instalar `composer require firebase/php-jwt`
- [ ] Configurar `JWT_SECRET` en `.env` (mínimo 32 caracteres)
- [ ] Configurar `JWT_EXPIRATION_HOURS` (por defecto 24)
- [ ] Configurar secretos de clientes en `.env`
- [ ] Generar primer token de prueba
- [ ] Probar validación de token
- [ ] Probar refresh de token
- [ ] Configurar HTTPS en producción
- [ ] Documentar credenciales para clientes

---

**¡Autenticación JWT completamente funcional!** 🔐
