# 📘 Guía de Uso - Swagger UI para API Odoo

## ✅ Swagger UI Implementado Exitosamente

Se ha implementado **documentación interactiva Swagger/OpenAPI** para el API de Odoo con:

✅ **Documentación completa** de todos los endpoints
✅ **Ejemplos interactivos** para probar el API
✅ **Autenticación JWT** integrada
✅ **Schemas detallados** de request/response
✅ **Interfaz visual** para explorar el API

---

## 🚀 Acceso Rápido

### URL de Swagger UI

Una vez que el servidor esté corriendo:

```
http://localhost:8000/api/documentation
```

**Producción:**
```
https://api.guadalajara.gob.mx/api/documentation
```

---

## 📖 ¿Qué es Swagger UI?

Swagger UI es una **interfaz visual interactiva** que permite:

1. **Explorar** todos los endpoints del API
2. **Probar** las peticiones directamente desde el navegador
3. **Ver ejemplos** de requests y responses
4. **Autenticar** con JWT tokens
5. **Validar** los datos antes de enviar

---

## 🎯 Cómo Usar Swagger UI

### Paso 1: Iniciar el Servidor

```bash
cd RefactorX/BackEnd
php artisan serve
```

El servidor iniciará en `http://localhost:8000`

### Paso 2: Abrir Swagger UI

Navegar a: `http://localhost:8000/api/documentation`

Verás la interfaz de Swagger con:
- **JWT Authentication** (endpoints de autenticación)
- **Odoo Integration** (endpoints principales de Odoo)
- **Generic API** (endpoint genérico para stored procedures)

### Paso 3: Generar Token JWT

1. **Expandir** la sección **"JWT Authentication"**
2. **Clic** en `POST /api/odoo/auth/token`
3. **Clic** en "Try it out"
4. **Ingresar** credenciales en el body:

```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025"
}
```

5. **Clic** en "Execute"
6. **Copiar** el token de la respuesta

### Paso 4: Autenticar en Swagger

1. **Clic** en el botón **"Authorize"** (candado verde arriba)
2. **Ingresar**: `Bearer {tu-token-aqui}`
3. **Clic** en "Authorize"
4. **Cerrar** el modal

Ahora todas las peticiones usarán este token automáticamente.

### Paso 5: Probar Endpoints de Odoo

#### Ejemplo: Consulta

1. **Expandir** la sección **"Odoo Integration"**
2. **Clic** en `POST /api/odoo`
3. **Clic** en "Try it out"
4. **Modificar** el request body:

```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "tu-token-jwt",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123"
    }
  }
}
```

5. **Clic** en "Execute"
6. **Ver** la respuesta en la sección "Responses"

---

## 🔐 Autenticación JWT en Swagger

### Opción 1: Usar el Botón "Authorize"

1. Generar token en `POST /api/odoo/auth/token`
2. Copiar el token de la respuesta
3. Clic en "Authorize" (candado verde)
4. Ingresar: `Bearer eyJ0eXAiOiJKV1QiLCJhbGc...`
5. Clic "Authorize"

Todas las peticiones subsecuentes incluirán automáticamente el header:
```
Authorization: Bearer {token}
```

### Opción 2: Incluir Token en el Body

También puedes incluir el token directamente en el request body:

```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {...}
  }
}
```

---

## 📝 Endpoints Disponibles en Swagger

### 1. JWT Authentication

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/odoo/auth/token` | POST | Generar token JWT |
| `/api/odoo/auth/validate` | POST | Validar token JWT |
| `/api/odoo/auth/refresh` | POST | Refrescar token JWT |
| `/api/odoo/auth/info` | GET | Información de configuración JWT |

### 2. Odoo Integration

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/odoo` | POST | Endpoint unificado para todas las funciones de Odoo |

**Funciones disponibles en `/api/odoo`:**
- `Consulta` - Consulta datos generales
- `DatosVarios` - Datos complementarios
- `AdeudoDetalle` - Detalle de adeudos
- `Pago` - Registrar pago
- `Cancelacion` - Cancelar pago
- `ConsCuenta` - Consultar cuenta predial
- `CatDescuentos` - Catálogo de descuentos
- `ListDescuentos` - Lista de descuentos
- `AltaDescuentos` - Registrar descuento
- Y más...

### 3. Generic API

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/generic` | POST | Ejecutar stored procedures genéricos |

---

## 💡 Ejemplos de Uso en Swagger

### Ejemplo 1: Generar Token

**Endpoint:** `POST /api/odoo/auth/token`

**Request Body:**
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Token generado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "expires_at": "2025-02-12 10:30:00"
}
```

### Ejemplo 2: Consulta

**Endpoint:** `POST /api/odoo`

**Request Body:**
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "nombre": "JUAN PEREZ GARCIA",
      "domicilio": "AV REVOLUCION 123",
      "colonia": "CENTRO",
      "municipio": "GUADALAJARA",
      "estado": "JALISCO",
      "rfc": "PEGJ800101XXX",
      "estatus": 0,
      "mensaje_est": "OK"
    }
  }
}
```

### Ejemplo 3: Registrar Pago

**Endpoint:** `POST /api/odoo`

**Request Body:**
```json
{
  "eRequest": {
    "Funcion": "Pago",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123",
      "monto_certificado": 5250.75,
      "monto_cartera": 5250.75,
      "id_cobro": 123456,
      "folio_recibo": "REC-2025-001234",
      "fecha_pago": "2025-02-11",
      "recaudadora": 1,
      "centro": 1,
      "caja": "CAJA01"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "PAGO REGISTRADO EXITOSAMENTE"
    }
  }
}
```

---

## 🔧 Funcionalidades de Swagger UI

### 1. Try it Out (Probar)

- Permite editar el request body
- Ejecuta la petición real contra el servidor
- Muestra la respuesta en tiempo real

### 2. Schema y Ejemplos

- **Model Tab**: Muestra la estructura esperada del JSON
- **Example Value**: Ejemplo pre-llenado que puedes usar

### 3. Responses

- Muestra los diferentes códigos de respuesta posibles
- Ejemplos de respuestas exitosas y errores
- Estructura de cada tipo de respuesta

### 4. Filtros y Búsqueda

- Barra de búsqueda para filtrar endpoints
- Agrupación por tags (JWT Authentication, Odoo Integration, etc.)

### 5. Autorización

- Botón "Authorize" para configurar autenticación
- Persistencia del token durante la sesión

---

## 🛠️ Regenerar Documentación Swagger

Si haces cambios en las anotaciones de los controladores:

### Desarrollo

Configurar en `.env`:
```env
L5_SWAGGER_GENERATE_ALWAYS=true
```

Con esto, la documentación se regenera en cada request.

### Manual

```bash
php artisan l5-swagger:generate
```

### Producción

Configurar en `.env`:
```env
L5_SWAGGER_GENERATE_ALWAYS=false
```

Y regenerar manualmente después de cada deploy:
```bash
php artisan l5-swagger:generate
```

---

## 📁 Archivos de Swagger

### Documentación Generada

```
storage/api-docs/api-docs.json
```

Este archivo JSON contiene toda la especificación OpenAPI generada.

### Configuración

```
config/l5-swagger.php
```

Configuración de Swagger UI (rutas, estilos, etc.)

### Anotaciones

Las anotaciones están en:
```
app/Http/Controllers/Api/OdooController.php
app/Http/Controllers/Api/JwtAuthController.php
app/Http/Controllers/Api/OdooSchemas.php
app/Http/Controllers/Api/GenericController.php
```

---

## 🎨 Personalización de Swagger UI

### Cambiar Título

Editar `config/l5-swagger.php`:

```php
'api' => [
    'title' => 'API de Integración Odoo',
],
```

### Modo Oscuro

En `.env`:
```env
L5_SWAGGER_UI_DARK_MODE=true
```

### Expansión de Documentación

```env
# Opciones: none, list, full
L5_SWAGGER_UI_DOC_EXPANSION=list
```

- `none`: Todo colapsado
- `list`: Solo tags expandidos
- `full`: Todo expandido

---

## 🐛 Troubleshooting

### Swagger UI no carga

**Solución:**
```bash
php artisan l5-swagger:generate
php artisan cache:clear
php artisan config:clear
```

### Error 404 en /api/documentation

**Verificar que:**
1. Swagger esté instalado: `composer show darkaonline/l5-swagger`
2. Configuración publicada: `php artisan l5-swagger:publish`
3. Documentación generada: `php artisan l5-swagger:generate`

### Cambios no se reflejan

**Solución:**
```bash
# En desarrollo
L5_SWAGGER_GENERATE_ALWAYS=true

# O manual
php artisan l5-swagger:generate
php artisan cache:clear
```

### Error de sintaxis en anotaciones

**Verificar:**
- Cierre correcto de todos los `@OA\Property()`
- Comillas escapadas correctamente: `\"`
- Referencias a schemas existentes

**Regenerar:**
```bash
php artisan l5-swagger:generate
```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- **L5 Swagger:** https://github.com/DarkaOnLine/L5-Swagger
- **Swagger PHP:** https://github.com/zircote/swagger-php
- **OpenAPI Spec:** https://swagger.io/specification/

### Ver Especificación JSON

Accede directamente al JSON generado:
```
http://localhost:8000/docs/api-docs.json
```

### Exportar Documentación

El JSON generado se puede importar en:
- **Postman** (Import > OpenAPI)
- **Insomnia** (Import > OpenAPI)
- **Swagger Editor** (https://editor.swagger.io/)

---

## ✅ Checklist de Verificación

- [ ] Servidor Laravel corriendo
- [ ] Swagger instalado (`composer show darkaonline/l5-swagger`)
- [ ] Documentación generada (`php artisan l5-swagger:generate`)
- [ ] Swagger UI accesible en `/api/documentation`
- [ ] JWT endpoints visibles en Swagger
- [ ] Odoo Integration endpoints visibles
- [ ] Botón "Authorize" funcional
- [ ] "Try it out" ejecuta peticiones reales

---

## 🎉 ¡Listo para Usar!

Swagger UI está **completamente funcional** y listo para:

1. **Explorar** el API de forma visual
2. **Probar** endpoints sin escribir código
3. **Documentar** automáticamente cambios en el API
4. **Compartir** con el equipo de desarrollo
5. **Integrar** con herramientas como Postman

**URL:** http://localhost:8000/api/documentation

---

**Implementado por:** Claude Code
**Fecha:** 11 de febrero de 2025
**Versión:** 1.0
