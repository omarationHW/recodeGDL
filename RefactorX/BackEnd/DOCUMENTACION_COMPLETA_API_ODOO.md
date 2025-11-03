# 📘 Documentación Completa - API de Integración Odoo

## Guía Definitiva para Integración con Sistemas Externos

**Versión:** 1.0
**Fecha:** Febrero 2025
**Audiencia:** Clientes, Partners, Desarrolladores Externos
**Gobierno Municipal de Guadalajara**

---

## 📑 Tabla de Contenidos

1. [Introducción](#introducción)
2. [¿Qué es un API?](#qué-es-un-api)
3. [¿Para qué sirve este API?](#para-qué-sirve-este-api)
4. [Arquitectura del Sistema](#arquitectura-del-sistema)
5. [Conceptos Básicos](#conceptos-básicos)
6. [Autenticación y Seguridad](#autenticación-y-seguridad)
7. [Primeros Pasos](#primeros-pasos)
8. [Endpoints Disponibles](#endpoints-disponibles)
9. [Funciones del API](#funciones-del-api)
10. [Ejemplos Completos](#ejemplos-completos)
11. [Códigos de Respuesta](#códigos-de-respuesta)
12. [Swagger UI - Interfaz Visual](#swagger-ui---interfaz-visual)
13. [Casos de Uso Reales](#casos-de-uso-reales)
14. [Integración con Odoo](#integración-con-odoo)
15. [Troubleshooting](#troubleshooting)
16. [Glosario de Términos](#glosario-de-términos)
17. [Preguntas Frecuentes](#preguntas-frecuentes)
18. [Contacto y Soporte](#contacto-y-soporte)

---

## Introducción

### Bienvenido al API de Integración Odoo

Este documento contiene **toda la información necesaria** para que pueda integrar su sistema con los servicios del Gobierno Municipal de Guadalajara a través de nuestro **API REST de Odoo**.

**No necesita conocimientos técnicos avanzados** para entender este documento. Hemos preparado explicaciones claras y ejemplos prácticos que le guiarán paso a paso.

### ¿A quién está dirigido este documento?

- ✅ **Clientes** que necesitan conectar su sistema Odoo con nuestros servicios
- ✅ **Empresas de software** que desarrollan integraciones
- ✅ **Desarrolladores** que implementarán la conexión
- ✅ **Personal administrativo** que necesita entender el proceso
- ✅ **Partners tecnológicos** del Gobierno Municipal

### ¿Qué incluye esta documentación?

- ✅ Explicación simple de conceptos técnicos
- ✅ Guías paso a paso con ejemplos reales
- ✅ Código listo para copiar y usar
- ✅ Explicación de cada función disponible
- ✅ Casos de uso prácticos
- ✅ Solución a problemas comunes
- ✅ Acceso a herramientas visuales (Swagger UI)

---

## ¿Qué es un API?

### Explicación Simple

Imagine que el API es como un **mesero en un restaurante**:

1. **Usted (el cliente)** hace un **pedido** al mesero
2. El **mesero** lleva su pedido a la **cocina**
3. La **cocina** prepara su comida
4. El **mesero** le trae su **pedido listo**

En términos técnicos:

1. **Su sistema** envía una **petición** al API
2. El **API** procesa la petición en nuestros **servidores**
3. Los **servidores** ejecutan la operación solicitada
4. El **API** devuelve una **respuesta** con los resultados

### ¿Por qué usar un API?

**Ventajas:**

✅ **Automatización:** Su sistema puede hacer operaciones automáticamente sin intervención humana
✅ **Tiempo real:** Obtiene información actualizada al instante
✅ **Eficiencia:** Procesa miles de operaciones sin errores
✅ **Integración:** Conecta diferentes sistemas sin problemas
✅ **Disponibilidad:** Funciona 24/7 los 365 días del año

**Sin API (método tradicional):**
- ❌ Captura manual de datos
- ❌ Llamadas telefónicas
- ❌ Correos electrónicos
- ❌ Archivos Excel
- ❌ Procesos lentos y propensos a errores

**Con API (método moderno):**
- ✅ Automático
- ✅ Instantáneo
- ✅ Sin errores
- ✅ Escalable
- ✅ Seguro

---

## ¿Para qué sirve este API?

### Servicios Disponibles

Nuestro API le permite realizar las siguientes operaciones con el Gobierno Municipal de Guadalajara:

#### 1. **Consultas de Información**
Obtener datos sobre:
- Licencias municipales
- Infracciones de tránsito
- Permisos de construcción
- Cuentas prediales
- Estado de trámites
- Adeudos pendientes

#### 2. **Registro de Pagos**
Notificar pagos realizados de:
- Licencias comerciales
- Multas de tránsito
- Derechos de construcción
- Impuestos municipales
- Servicios públicos

#### 3. **Gestión de Trámites**
Realizar operaciones como:
- Cancelación de pagos
- Aplicación de descuentos
- Consulta de catálogos
- Actualización de estados

#### 4. **Integración con Odoo**
Conectar directamente su sistema Odoo ERP con:
- Módulo de Contabilidad
- Módulo de Ventas
- Módulo de Facturación
- Módulo de Cobranza

---

## Arquitectura del Sistema

### ¿Cómo funciona todo el sistema?

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│                 │         │                  │         │                 │
│   SU SISTEMA    │ ──────► │   API ODOO      │ ──────► │   BASES DE      │
│   (Odoo ERP)    │  HTTPS  │   (Middleware)   │   SQL   │   DATOS GMG     │
│                 │ ◄────── │                  │ ◄────── │                 │
└─────────────────┘         └──────────────────┘         └─────────────────┘
      Cliente                    Servidor API              Bases de Datos
```

### Componentes del Sistema

#### 1. **Su Sistema (Cliente)**
- Es su aplicación Odoo, software propio, o cualquier sistema que desarrolle
- Envía peticiones HTTP al API
- Recibe respuestas en formato JSON

#### 2. **API Odoo (Middleware)**
- Es nuestro servidor que procesa las peticiones
- Valida la autenticación (tokens JWT)
- Ejecuta las operaciones solicitadas
- Devuelve los resultados

#### 3. **Bases de Datos GMG**
- Contienen toda la información del Gobierno Municipal
- Incluyen datos de:
  - Licencias (padron_licencias)
  - Movilidad (padron_movilidad)
  - Obras (padron_obras)
  - Infracciones (padron_infracciones)
  - Predial (padron_sicam)

### Flujo de una Operación Completa

**Ejemplo: Consultar adeudos de una licencia**

```
1. Su Sistema → Genera un token JWT
                (Autenticación)
                ↓
2. Su Sistema → Envía petición de consulta
                con el token
                ↓
3. API Odoo   → Valida el token
                ↓
4. API Odoo   → Consulta la base de datos
                ↓
5. API Odoo   → Devuelve los adeudos
                ↓
6. Su Sistema → Recibe y muestra los datos
```

**Tiempo total:** 1-2 segundos

---

## Conceptos Básicos

### Términos que debe conocer

#### 1. **HTTP / HTTPS**
**¿Qué es?**
Es el "lenguaje" que usan los navegadores y sistemas para comunicarse en internet.

**Diferencia:**
- **HTTP:** No encriptado (NO USAR para producción)
- **HTTPS:** Encriptado y seguro (USAR siempre en producción)

**Analogía:** HTTPS es como enviar una carta en un sobre sellado vs. HTTP es como enviar una postal que todos pueden leer.

#### 2. **REST API**
**¿Qué es?**
Es un estilo de arquitectura para crear APIs que usa HTTP.

**Características:**
- Usa URLs para identificar recursos
- Usa métodos HTTP (GET, POST, PUT, DELETE)
- Intercambia datos en formato JSON

#### 3. **JSON**
**¿Qué es?**
Es un formato de texto para intercambiar datos entre sistemas.

**Ejemplo:**
```json
{
  "nombre": "Juan Pérez",
  "edad": 35,
  "ciudad": "Guadalajara"
}
```

**Analogía:** Es como un formulario estructurado que las computadoras pueden leer fácilmente.

#### 4. **Endpoint**
**¿Qué es?**
Es una URL específica donde se hace una petición.

**Ejemplo:**
```
https://api.guadalajara.gob.mx/api/odoo
```

**Analogía:** Es como la dirección específica de una oficina en un edificio grande.

#### 5. **Token JWT**
**¿Qué es?**
Es una "credencial digital" que demuestra que usted tiene permiso para usar el API.

**Características:**
- Tiene fecha de expiración (24 horas por defecto)
- Se genera con sus credenciales (client_id + client_secret)
- Debe enviarse en cada petición

**Analogía:** Es como un gafete de visitante en un edificio que expira al final del día.

#### 6. **Request (Petición)**
**¿Qué es?**
Es lo que usted envía al API pidiendo que haga algo.

**Componentes:**
- **URL:** Dónde se envía
- **Método:** Qué tipo de operación (POST, GET, etc.)
- **Headers:** Información adicional (autenticación)
- **Body:** Los datos que envía

#### 7. **Response (Respuesta)**
**¿Qué es?**
Es lo que el API le devuelve después de procesar su petición.

**Componentes:**
- **Status Code:** Código que indica si tuvo éxito (200, 400, 500, etc.)
- **Body:** Los datos de respuesta en formato JSON

---

## Autenticación y Seguridad

### ¿Por qué necesita autenticarse?

La autenticación es necesaria para:

1. ✅ **Seguridad:** Solo usuarios autorizados pueden usar el API
2. ✅ **Identificación:** Sabemos quién hace cada operación
3. ✅ **Control:** Podemos limitar el uso según permisos
4. ✅ **Auditoría:** Registramos todas las operaciones

### Sistema de Autenticación JWT

**JWT = JSON Web Token**

#### ¿Cómo funciona?

```
Paso 1: Obtener Credenciales
─────────────────────────────
El Gobierno Municipal le proporciona:
- client_id: "su-identificador-unico"
- client_secret: "su-contraseña-secreta"

Paso 2: Generar Token
─────────────────────────────
Su sistema envía las credenciales al API
API valida las credenciales
API genera un token JWT válido por 24 horas

Paso 3: Usar el Token
─────────────────────────────
Su sistema incluye el token en cada petición
API valida que el token sea válido
API procesa la petición

Paso 4: Refrescar el Token
─────────────────────────────
Antes de que expire (24h), puede solicitar
un nuevo token sin volver a enviar credenciales
```

### Credenciales del Cliente

**¿Qué son?**

Son sus "llaves de acceso" al API:

**client_id:**
- Es su identificador único
- Es público (puede compartirse)
- Ejemplo: `"odoo-client-guadalajara-001"`

**client_secret:**
- Es su contraseña secreta
- NUNCA debe compartirse
- Debe guardarse de forma segura
- Ejemplo: `"kJ8$mP2#xL9@qR5&wT3^nV7!bC1*fG4%hD6"`

**⚠️ IMPORTANTE:**
- ❌ NO incluir el client_secret en código público
- ❌ NO compartir el client_secret por email o chat
- ❌ NO almacenar el client_secret en bases de datos sin encriptar
- ✅ Guardar en variables de entorno
- ✅ Cambiar periódicamente (cada 6 meses)
- ✅ Usar diferentes credenciales por ambiente (desarrollo, producción)

### Obtener sus Credenciales

**Proceso:**

1. **Solicitud Formal**
   - Enviar correo a: soporte@guadalajara.gob.mx
   - Asunto: "Solicitud de Acceso API Odoo"
   - Incluir:
     - Nombre de la empresa
     - Contacto técnico
     - Propósito de la integración
     - Ambiente (desarrollo/producción)

2. **Validación**
   - El equipo técnico revisará su solicitud
   - Puede requerir documentación adicional
   - Tiempo de respuesta: 3-5 días hábiles

3. **Recepción de Credenciales**
   - Recibirá por canal seguro:
     - client_id
     - client_secret
     - URLs del API (desarrollo y producción)
     - Documentación adicional

4. **Configuración**
   - Configure las credenciales en su sistema
   - Realice pruebas en ambiente de desarrollo
   - Solicite paso a producción cuando esté listo

---

## Primeros Pasos

### Tutorial Paso a Paso para Principiantes

Esta sección le guiará desde cero hasta hacer su primera petición exitosa al API.

### Paso 1: Verificar Requisitos

**¿Qué necesita?**

✅ **Credenciales del API**
- client_id
- client_secret

✅ **Herramienta para hacer peticiones HTTP**

Opciones (elija una):

**Opción A: Swagger UI (Recomendado para principiantes)**
- ✅ Interfaz visual
- ✅ No requiere programación
- ✅ Incluye ejemplos
- URL: `http://localhost:8000/api/documentation`

**Opción B: Postman (Para desarrolladores)**
- ✅ Herramienta profesional
- ✅ Permite guardar colecciones
- Descarga: https://www.postman.com/downloads/

**Opción C: cURL (Para línea de comandos)**
- ✅ Viene instalado en Linux/Mac
- ✅ Disponible en Windows 10+

**Opción D: Código en su lenguaje favorito**
- PHP, Python, JavaScript, Java, etc.

### Paso 2: Generar su Primer Token

#### Usando Swagger UI (Más Fácil)

**1. Abrir Swagger UI**
```
http://localhost:8000/api/documentation
```

**2. Buscar el endpoint de autenticación**
- Expandir la sección "JWT Authentication"
- Buscar `POST /api/odoo/auth/token`
- Hacer clic para expandir

**3. Probar el endpoint**
- Clic en "Try it out"
- Verá un formulario pre-llenado
- Modificar los valores:

```json
{
  "client_id": "su-client-id-aqui",
  "client_secret": "su-client-secret-aqui"
}
```

- Clic en "Execute"

**4. Ver la respuesta**

Si todo salió bien, verá algo como:

```json
{
  "success": true,
  "message": "Token generado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDc2NTIyMDAsImV4cCI6MTcwNzczODYwMCwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDAwIiwiZGF0YSI6eyJjbGllbnRfaWQiOiJvZG9vLWNsaWVudC0wMDEiLCJjbGllbnRfbmFtZSI6Ik9kb28gUHJvZHVjdGlvbiIsInBlcm1pc3Npb25zIjpbIioiXSwidHlwZSI6Im9kb29faW50ZWdyYXRpb24ifX0.XYZ123ABC456...",
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

**5. Guardar el token**

Copie el valor completo del campo `"token"`. Lo necesitará para todas las siguientes peticiones.

El token se ve así:
```
eyJ0eXAiOiJKV1QiLCJhbGc...
```

#### Usando Postman

**1. Crear nueva petición**
- Clic en "New" > "HTTP Request"
- Método: **POST**
- URL: `http://localhost:8000/api/odoo/auth/token`

**2. Configurar el Body**
- Seleccionar pestaña "Body"
- Seleccionar "raw"
- Seleccionar "JSON"
- Pegar este código:

```json
{
  "client_id": "su-client-id-aqui",
  "client_secret": "su-client-secret-aqui"
}
```

**3. Enviar**
- Clic en "Send"
- Ver la respuesta en la parte inferior

**4. Guardar el token**
- Copiar el valor del campo "token"
- Puede guardarlo como variable de entorno en Postman

#### Usando cURL (Línea de Comandos)

**En Windows (PowerShell):**
```powershell
curl -X POST http://localhost:8000/api/odoo/auth/token `
  -H "Content-Type: application/json" `
  -d '{\"client_id\":\"su-client-id\",\"client_secret\":\"su-client-secret\"}'
```

**En Linux/Mac (Terminal):**
```bash
curl -X POST http://localhost:8000/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "su-client-id",
    "client_secret": "su-client-secret"
  }'
```

### Paso 3: Hacer su Primera Consulta

Ahora que tiene un token, puede hacer consultas reales.

#### Ejemplo: Consultar información de una cuenta

**Datos que necesita:**
- El token que acaba de generar
- Un número de cuenta válido (ejemplo: "12345678")
- El ID de interfaz (ejemplo: 8 para Licencias)

#### Usando Swagger UI

**1. Autenticar en Swagger**
- En la parte superior derecha, clic en el botón "Authorize" (candado verde)
- En el campo "Value", ingresar: `Bearer su-token-aqui`
- Clic en "Authorize"
- Clic en "Close"

**2. Buscar el endpoint de Odoo**
- Expandir la sección "Odoo Integration"
- Buscar `POST /api/odoo`
- Hacer clic para expandir

**3. Configurar la petición**
- Clic en "Try it out"
- Modificar el JSON:

```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "su-token-aqui",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": ""
    }
  }
}
```

**4. Ejecutar**
- Clic en "Execute"
- Ver la respuesta

**5. Interpretar la respuesta**

Si la cuenta existe, verá:

```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "nombre": "JUAN PEREZ GARCIA",
      "domicilio": "AV REVOLUCION 123",
      "no_ext": "123",
      "no_int": "A",
      "colonia": "CENTRO",
      "municipio": "GUADALAJARA",
      "estado": "JALISCO",
      "rfc": "PEGJ800101XXX",
      "curp": "PEGJ800101HJCRNS01",
      "observacion": "Cuenta activa",
      "estatus": 0,
      "mensaje_est": "OK"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**¿Qué significa cada campo?**

- `success: true` → La operación fue exitosa
- `message` → Mensaje descriptivo
- `data` → Los datos de la cuenta consultada
  - `nombre` → Nombre del titular
  - `domicilio` → Dirección
  - `estatus: 0` → Cuenta válida (0 = OK, >0 = Error)
  - `mensaje_est: "OK"` → Estado de la cuenta

#### Usando Postman

**1. Crear nueva petición**
- Método: **POST**
- URL: `http://localhost:8000/api/odoo`

**2. Configurar Headers**
- Pestaña "Headers"
- Agregar:
  - Key: `Content-Type` | Value: `application/json`
  - Key: `Authorization` | Value: `Bearer su-token-aqui`

**3. Configurar Body**
- Pestaña "Body"
- Seleccionar "raw" y "JSON"
- Pegar:

```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "su-token-aqui",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": ""
    }
  }
}
```

**4. Enviar**
- Clic en "Send"
- Ver respuesta

### Paso 4: Interpretar Respuestas

#### Respuesta Exitosa (200 OK)

```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": { ... }
  }
}
```

**Significado:**
✅ La operación se completó correctamente
✅ Los datos están en el campo `data`
✅ Puede proceder con la información

#### Respuesta con Error (400/401/500)

```json
{
  "eResponse": {
    "success": false,
    "message": "Token inválido o expirado",
    "data": null
  }
}
```

**Significado:**
❌ Hubo un problema
❌ Leer el `message` para saber qué pasó
❌ El campo `data` será `null`

**Acciones a tomar:**
1. Leer el mensaje de error
2. Verificar sus datos
3. Consultar la sección de Troubleshooting
4. Contactar soporte si persiste

---

## Endpoints Disponibles

### ⚠️ IMPORTANTE: Cómo Funciona el API

**El API tiene DOS tipos de endpoints:**

#### **Tipo 1: Endpoints de Autenticación JWT (4 endpoints diferentes)**

Cada uno es una URL diferente:

```
POST   /api/odoo/auth/token      → Generar token
POST   /api/odoo/auth/validate   → Validar token
POST   /api/odoo/auth/refresh    → Refrescar token
GET    /api/odoo/auth/info       → Información del sistema
```

#### **Tipo 2: Endpoint Único de Odoo (1 solo endpoint para TODO)**

```
POST   /api/odoo   → ÚNICO ENDPOINT que hace TODAS las operaciones
```

**¿Cómo funciona este endpoint único?**

En el mismo endpoint `/api/odoo`, usted especifica QUÉ quiere hacer usando el campo **`Funcion`**:

```json
{
  "eRequest": {
    "Funcion": "Consulta",    ← Esto define la operación
    "Token": "...",
    "Parametros": { ... }
  }
}
```

**18 funciones disponibles en el mismo endpoint:**
- `"Consulta"` → Consultar información
- `"Pago"` → Registrar un pago
- `"Cancelacion"` → Cancelar un pago
- `"AdeudoDetalle"` → Ver adeudos
- `"DatosVarios"` → Datos adicionales
- Y 13 funciones más...

**Analogía:**
- Es como un restaurante con **UN SOLO mesero** (endpoint)
- Pero ese mesero puede traerle **18 platillos diferentes** (funciones)
- Usted le dice al mesero qué platillo quiere (campo `Funcion`)

### Resumen de Endpoints

El API tiene **2 grupos principales** de endpoints:

```
1. JWT Authentication (Autenticación) - 4 endpoints
   ├── POST /api/odoo/auth/token
   ├── POST /api/odoo/auth/validate
   ├── POST /api/odoo/auth/refresh
   └── GET  /api/odoo/auth/info

2. Odoo Integration (Servicios Principales) - 1 endpoint
   └── POST /api/odoo
       ├── Funcion: "Consulta"
       ├── Funcion: "Pago"
       ├── Funcion: "Cancelacion"
       ├── Funcion: "AdeudoDetalle"
       └── ... (18 funciones en total)
```

### 1. JWT Authentication

Endpoints para manejar la autenticación.

#### POST /api/odoo/auth/token
**Generar Token JWT**

**Propósito:** Obtener un token de acceso para usar el API.

**Cuándo usar:**
- Al iniciar sesión
- Cuando su token expira (cada 24 horas)
- Para obtener credenciales de acceso

**Request:**
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025",
  "client_name": "Odoo Production",
  "permissions": ["consulta", "pago", "cancelacion"]
}
```

**Campos:**
- `client_id` (obligatorio) → Su identificador único
- `client_secret` (obligatorio) → Su contraseña secreta
- `client_name` (opcional) → Nombre descriptivo
- `permissions` (opcional) → Permisos específicos

**Response Exitoso:**
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

**Información importante:**
- Token válido por 24 horas (86400 segundos)
- Debe guardarse de forma segura
- Usar en todas las peticiones siguientes

---

#### POST /api/odoo/auth/validate
**Validar Token JWT**

**Propósito:** Verificar si un token es válido y cuánto tiempo le queda.

**Cuándo usar:**
- Para verificar si su token sigue siendo válido
- Para saber cuánto tiempo queda antes de expirar
- Para depurar problemas de autenticación

**Request:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response Exitoso:**
```json
{
  "success": true,
  "message": "Token válido",
  "client_id": "odoo-client-001",
  "client_name": "Odoo Production",
  "permissions": ["*"],
  "expires_at": "2025-02-12 10:30:00",
  "time_left": "23h 45m"
}
```

**Response Error (Token Inválido):**
```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

---

#### POST /api/odoo/auth/refresh
**Refrescar Token JWT**

**Propósito:** Obtener un nuevo token sin volver a enviar credenciales.

**Cuándo usar:**
- Antes de que expire su token actual (recomendado 1 hora antes)
- Para mantener su sesión activa
- Para evitar interrupciones en el servicio

**Request:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response Exitoso:**
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

**Recomendación:**
Configure su sistema para refrescar automáticamente el token cuando queden 2-3 horas de vigencia.

---

#### GET /api/odoo/auth/info
**Información de Configuración JWT**

**Propósito:** Obtener información sobre la configuración del sistema JWT.

**Cuándo usar:**
- Para verificar configuración
- Para conocer endpoints disponibles
- Para depuración

**Request:** No requiere body, solo hacer GET

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

### 2. Odoo Integration

**Endpoint principal:** `POST /api/odoo`

Este es el endpoint **más importante** del API. Maneja todas las operaciones principales a través de diferentes funciones.

**Estructura del Request:**

```json
{
  "eRequest": {
    "Funcion": "NombreDeLaFuncion",
    "Token": "su-token-jwt",
    "Parametros": {
      "parametro1": "valor1",
      "parametro2": "valor2"
    }
  }
}
```

**Componentes:**
- `eRequest` → Objeto contenedor (siempre requerido)
- `Funcion` → Nombre de la operación a ejecutar
- `Token` → Su token JWT de autenticación
- `Parametros` → Objeto con los parámetros específicos de la función

**Autenticación:**

Puede enviar el token de **dos formas**:

**Opción 1: Header HTTP (Recomendado)**
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

**Opción 2: En el body del request**
```json
{
  "eRequest": {
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    ...
  }
}
```

---

## Funciones del API

### ⚠️ RECORDATORIO: Un Solo Endpoint, Muchas Funciones

**Todas estas funciones se ejecutan en el MISMO endpoint:**

```
POST /api/odoo
```

**Lo único que cambia es el valor del campo `Funcion` dentro de `eRequest`:**

```json
{
  "eRequest": {
    "Funcion": "aqui-va-el-nombre",  ← Cambia según lo que quieras hacer
    "Token": "tu-token-jwt",
    "Parametros": { ... }
  }
}
```

### Lista Completa de 18 Funciones

**TODAS usan el mismo endpoint:** `POST /api/odoo`

| Función | Descripción | Casos de Uso |
|---------|-------------|--------------|
| **Consulta** | Consulta datos generales de una cuenta | Ver información de licencias, permisos, cuentas |
| **DatosVarios** | Consulta datos complementarios | Obtener información adicional |
| **AdeudoDetalle** | Detalle de adeudos por concepto | Ver desglose de deudas, montos por período |
| **AdeudoDetalleInmovilizadores** | Adeudos específicos de inmovilizadores | Infracciones con grúa |
| **Pago** | Registra un pago realizado | Notificar pagos desde Odoo |
| **Cancelacion** | Cancela un pago registrado | Revertir transacciones erróneas |
| **ConsCuenta** | Consulta cuenta predial por ID | Verificar cuentas de impuesto predial |
| **CatDescuentos** | Catálogo de descuentos disponibles | Ver descuentos aplicables |
| **ListDescuentos** | Lista descuentos aplicados | Consultar descuentos activos |
| **AltaDescuentos** | Registra un nuevo descuento | Aplicar descuentos autorizados |
| **CancelDescuentos** | Cancela un descuento | Revertir descuentos aplicados |
| **ConsDesctoTablet** | Consulta descuentos desde tablet | Validación móvil |
| **AltaDesctoTablet** | Alta de descuentos desde tablet | Registro móvil |
| **FechasPendientesEl** | Fechas pendientes electrónicas | Seguimiento de trámites |
| **PendientesXIntegrar** | Operaciones pendientes de integrar | Sincronización con Odoo |
| **DetallesXIntegrar** | Detalles de operaciones pendientes | Desglose de pendientes |
| **ActualizarPendientes** | Actualiza estado de pendientes | Marcar como procesados |
| **LicenciaVisor** | Codificación de licencia para visor | Generar QR/Códigos |

---

### Interfaz de Datos (Idinterfaz)

Muchas funciones requieren el parámetro `Idinterfaz` que indica qué base de datos consultar:

| ID | Módulo | Base de Datos | Descripción |
|----|--------|---------------|-------------|
| **8-15, 18-19, 22-23, 25, 30** | Licencias | padron_licencias | Licencias municipales, permisos comerciales |
| **16** | Movilidad | padron_movilidad | Infracciones de tránsito, multas viales |
| **17** | Obras | padron_obras | Licencias de construcción, permisos de obra |
| **32** | Infracciones | padron_infracciones | Multas administrativas |
| **88** | SICAM | padron_sicam | Impuesto predial, catastro |

**Nota:** Las interfaces 8-15, 18-19, 22-23, 25 y 30 están normalizadas internamente a la interfaz 8.

---

### Ejemplo Visual: Cómo Funcionan las Funciones

**Todas estas peticiones van al MISMO endpoint, solo cambia el campo `Funcion`:**

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  SIEMPRE la misma URL:                                 │
│  POST http://localhost:8000/api/odoo                   │
│                                                         │
└─────────────────────────────────────────────────────────┘

Ejemplo 1: CONSULTAR               Ejemplo 2: VER ADEUDOS
┌──────────────────────────┐       ┌──────────────────────────┐
│ {                        │       │ {                        │
│   "eRequest": {          │       │   "eRequest": {          │
│     "Funcion": "Consulta"│       │     "Funcion": "AdeudoDetalle" │
│     "Token": "...",      │       │     "Token": "...",      │
│     "Parametros": {...}  │       │     "Parametros": {...}  │
│   }                      │       │   }                      │
│ }                        │       │ }                        │
└──────────────────────────┘       └──────────────────────────┘

Ejemplo 3: REGISTRAR PAGO          Ejemplo 4: CANCELAR PAGO
┌──────────────────────────┐       ┌──────────────────────────┐
│ {                        │       │ {                        │
│   "eRequest": {          │       │   "eRequest": {          │
│     "Funcion": "Pago"    │       │     "Funcion": "Cancelacion" │
│     "Token": "...",      │       │     "Token": "...",      │
│     "Parametros": {...}  │       │     "Parametros": {...}  │
│   }                      │       │   }                      │
│ }                        │       │ }                        │
└──────────────────────────┘       └──────────────────────────┘
```

**Resumen:**
- ✅ Mismo endpoint: `POST /api/odoo`
- ✅ Mismo token
- ✅ Misma estructura `eRequest`
- ❗ Solo cambia: `"Funcion": "NombreDeLaFuncion"`

---

### Función: Consulta

**Endpoint:** `POST /api/odoo` (mismo para todas)

**Propósito:** Obtener información general de una cuenta/licencia/trámite.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idinterfaz | integer | ✅ Sí | ID de la interfaz (ver tabla arriba) |
| cta_01 | string | ⚠️ Depende | Cuenta/Número de licencia/Placa |
| cta_02 | string | ❌ No | Campo adicional 2 |
| cta_03 | string | ❌ No | Campo adicional 3 |
| cta_04 | string | ❌ No | Campo adicional 4 |
| cta_05 | string | ❌ No | Campo adicional 5 |
| cta_06 | string | ❌ No | Campo adicional 6 |
| referencia_pago | string | ❌ No | Referencia de pago |

**Request Ejemplo - Consulta de Licencia:**
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "cta_02": "",
      "cta_03": "",
      "referencia_pago": "REF-2025-001"
    }
  }
}
```

**Response Ejemplo:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "nombre": "COMERCIAL EL BUEN GUSTO SA DE CV",
      "domicilio": "AV REVOLUCION 1234",
      "no_ext": "1234",
      "no_int": "LOCAL A",
      "colonia": "CENTRO",
      "municipio": "GUADALAJARA",
      "estado": "JALISCO",
      "rfc": "CBG850101XYZ",
      "curp": "",
      "observacion": "Licencia vigente",
      "estatus": 0,
      "mensaje_est": "OK"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Interpretación de Respuesta:**

- `estatus: 0` → ✅ Consulta exitosa, cuenta encontrada
- `estatus: 1001` → ❌ Cuenta no encontrada
- `estatus: 1002` → ❌ Error en parámetros
- `mensaje_est` → Descripción del estado

**Casos de Uso:**
1. Validar existencia de una licencia
2. Obtener datos del contribuyente
3. Verificar estado de una cuenta
4. Consultar información antes de un pago

---

### Función: DatosVarios

**Propósito:** Obtener datos complementarios de una cuenta (información adicional que no viene en Consulta).

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idinterfaz | integer | ✅ Sí | ID de la interfaz |
| cta_01 | string | ✅ Sí | Número de cuenta |
| cta_02 | string | ❌ No | Campo adicional |
| referencia_pago | string | ❌ No | Referencia |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "DatosVarios",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": ""
    }
  }
}
```

**Response Ejemplo:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "campo": "tipo_establecimiento",
        "valor": "RESTAURANTE"
      },
      {
        "campo": "giro_comercial",
        "valor": "ALIMENTOS Y BEBIDAS"
      },
      {
        "campo": "superficie_m2",
        "valor": "150"
      },
      {
        "campo": "fecha_apertura",
        "valor": "2023-01-15"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Casos de Uso:**
1. Obtener características específicas del establecimiento
2. Consultar datos históricos
3. Ver información técnica adicional

---

### Función: AdeudoDetalle

**Propósito:** Obtener el desglose detallado de adeudos de una cuenta.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idinterfaz | integer | ✅ Sí | ID de la interfaz |
| cta_01 | string | ✅ Sí | Número de cuenta |
| referencia_pago | string | ❌ No | Referencia |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "AdeudoDetalle",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF-2025-001"
    }
  }
}
```

**Response Ejemplo:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "cta_aplicacion": 1,
        "referencia_pago": "REF-2025-001",
        "descripcion": "LICENCIA COMERCIAL 2024",
        "importe": 3500.00,
        "acumulado": 3500.00
      },
      {
        "cta_aplicacion": 2,
        "referencia_pago": "REF-2025-001",
        "descripcion": "RECARGOS",
        "importe": 350.00,
        "acumulado": 3850.00
      },
      {
        "cta_aplicacion": 3,
        "referencia_pago": "REF-2025-001",
        "descripcion": "ACTUALIZACION",
        "importe": 150.00,
        "acumulado": 4000.00
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Interpretación:**
- Cada elemento del array es un concepto de adeudo
- `cta_aplicacion` → Orden del concepto
- `importe` → Monto de ese concepto
- `acumulado` → Suma acumulada hasta ese concepto
- **Total a pagar** = último valor de `acumulado` (4000.00 en este ejemplo)

**Casos de Uso:**
1. Mostrar desglose de adeudos al usuario
2. Calcular total a pagar
3. Generar recibos detallados
4. Aplicar pagos parciales

---

### Función: Pago

**Propósito:** Registrar un pago que fue realizado en su sistema.

**⚠️ IMPORTANTE:** Esta función NO procesa el pago. Solo registra que el pago YA fue realizado en su sistema (Odoo, punto de venta, etc.).

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idinterfaz | integer | ✅ Sí | ID de la interfaz |
| cta_01 | string | ⚠️ Depende | Número de cuenta |
| referencia_pago | string | ✅ Sí | Referencia del adeudo |
| pago_tarjeta | string | ❌ No | Últimos 4 dígitos de tarjeta |
| monto_certificado | number | ✅ Sí | Monto del certificado/recibo |
| monto_cartera | number | ✅ Sí | Monto aplicado a cartera |
| monto_redondeo | number | ❌ No | Centavos de redondeo |
| id_cobro | integer | ✅ Sí | ID único del cobro en su sistema |
| folio_recibo | string | ✅ Sí | Folio del recibo generado |
| fecha_pago | string | ✅ Sí | Fecha del pago (YYYY-MM-DD) |
| recaudadora | integer | ✅ Sí | ID de recaudadora (1 = predeterminado) |
| centro | integer | ✅ Sí | ID de centro de cobro |
| caja | string | ✅ Sí | ID de la caja |
| cc_lugar_pago | string | ❌ No | Lugar donde se realizó el pago |
| cc_fecha_pago | string | ❌ No | Fecha/hora del pago |
| cc_referencia | string | ❌ No | Referencia bancaria |
| cc_forma_pago | string | ❌ No | EFECTIVO, TARJETA, TRANSFERENCIA |
| adicional_1 | string | ❌ No | Campo adicional |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "Pago",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF-2025-001",
      "pago_tarjeta": "4532",
      "monto_certificado": 4000.00,
      "monto_cartera": 4000.00,
      "monto_redondeo": 0.00,
      "id_cobro": 789012,
      "folio_recibo": "REC-2025-001234",
      "fecha_pago": "2025-02-11",
      "recaudadora": 1,
      "centro": 1,
      "caja": "CAJA01",
      "cc_lugar_pago": "GUADALAJARA",
      "cc_fecha_pago": "2025-02-11 10:30:00",
      "cc_referencia": "REF-BANCO-001",
      "cc_forma_pago": "TARJETA"
    }
  }
}
```

**Response Exitoso:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "PAGO REGISTRADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Response con Error:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 1001,
      "mensaje": "REFERENCIA YA PAGADA"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Códigos de Respuesta:**
- `codigo: 0` → ✅ Pago registrado exitosamente
- `codigo: 1001` → ❌ Referencia inválida o no encontrada
- `codigo: 1002` → ❌ Pago duplicado
- `codigo: 1003` → ❌ Monto incorrecto

**Flujo Recomendado:**
1. Consultar adeudos con `AdeudoDetalle`
2. Mostrar al usuario el total a pagar
3. Procesar el pago en su sistema (Odoo)
4. Si el pago es exitoso, llamar a esta función `Pago`
5. Guardar el `id_cobro` y `folio_recibo` para referencia
6. Mostrar comprobante al usuario

**⚠️ Validaciones Importantes:**
- El `id_cobro` debe ser único en su sistema
- El `folio_recibo` debe ser único y secuencial
- El `monto_certificado` debe coincidir con el total del adeudo
- La `fecha_pago` debe ser válida
- No se puede registrar dos veces el mismo pago

---

### Función: Cancelacion

**Propósito:** Cancelar un pago que fue registrado previamente.

**⚠️ IMPORTANTE:** Solo se pueden cancelar pagos del mismo día. Pagos de días anteriores requieren autorización especial.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idinterfaz | integer | ✅ Sí | ID de la interfaz |
| id_cobro | integer | ✅ Sí | ID del cobro a cancelar |
| folio_recibo | string | ✅ Sí | Folio del recibo a cancelar |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "Cancelacion",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idinterfaz": 8,
      "id_cobro": 789012,
      "folio_recibo": "REC-2025-001234"
    }
  }
}
```

**Response Exitoso:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "PAGO CANCELADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Response con Error:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 1004,
      "mensaje": "PAGO NO ENCONTRADO O YA CANCELADO"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Códigos de Respuesta:**
- `codigo: 0` → ✅ Cancelación exitosa
- `codigo: 1004` → ❌ Pago no encontrado
- `codigo: 1005` → ❌ Pago ya cancelado previamente
- `codigo: 1006` → ❌ No se puede cancelar (pago de días anteriores)

**Casos de Uso:**
1. Error en el monto registrado
2. Pago aplicado a cuenta incorrecta
3. Devolución solicitada por el cliente
4. Corrección de errores administrativos

---

### Función: ConsCuenta

**Propósito:** Consultar cuenta predial por su ID interno.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idcuenta | integer | ✅ Sí | ID interno de la cuenta |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "ConsCuenta",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idcuenta": 123456
    }
  }
}
```

**Response Ejemplo:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "id_cuenta": 123456,
        "cuenta_catastral": "01-02-123-456",
        "propietario": "JUAN PEREZ GARCIA",
        "direccion": "AV REVOLUCION 123",
        "colonia": "CENTRO",
        "valor_catastral": 2500000.00,
        "tipo_predio": "CASA HABITACION"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

### Función: CatDescuentos

**Propósito:** Obtener el catálogo de descuentos disponibles para una cuenta.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idcuenta | integer | ✅ Sí | ID de la cuenta |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "CatDescuentos",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idcuenta": 123456
    }
  }
}
```

**Response Ejemplo:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "id_descuento": 1,
        "nombre": "DESCUENTO ADULTO MAYOR",
        "porcentaje": 50.00,
        "descripcion": "Aplica a personas mayores de 60 años",
        "vigente": true
      },
      {
        "id_descuento": 2,
        "nombre": "PAGO ANTICIPADO",
        "porcentaje": 15.00,
        "descripcion": "Pago del año completo en enero-febrero",
        "vigente": true
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

### Función: AltaDescuentos

**Propósito:** Aplicar un descuento autorizado a una cuenta.

**Parámetros:**

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| Idcuenta | integer | ✅ Sí | ID de la cuenta |
| IdDescuento | integer | ✅ Sí | ID del descuento a aplicar |
| bimini | string | ✅ Sí | Bimestre inicial (AAAA-B) |
| bimfin | string | ✅ Sí | Bimestre final (AAAA-B) |
| propietario | string | ❌ No | Nombre del propietario |
| solicitante | string | ❌ No | Nombre del solicitante |
| recaudadora | string | ❌ No | Recaudadora |
| folioDescto | string | ❌ No | Folio de autorización |
| identificacion | string | ❌ No | Identificación oficial |
| fechaNacimiento | string | ❌ No | Fecha de nacimiento |

**Request Ejemplo:**
```json
{
  "eRequest": {
    "Funcion": "AltaDescuentos",
    "Token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "Parametros": {
      "Idcuenta": 123456,
      "IdDescuento": 1,
      "bimini": "2025-1",
      "bimfin": "2025-6",
      "propietario": "JUAN PEREZ GARCIA",
      "solicitante": "JUAN PEREZ GARCIA",
      "recaudadora": "SISTEMA_ODOO",
      "folioDescto": "DESC-2025-001",
      "identificacion": "INE123456789",
      "fechaNacimiento": "1950-05-15"
    }
  }
}
```

**Response Exitoso:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "DESCUENTO APLICADO EXITOSAMENTE",
      "id_descuento_aplicado": 789
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## Ejemplos Completos

### Caso Completo 1: Consultar y Pagar una Licencia

**Escenario:** Un contribuyente quiere pagar su licencia comercial desde Odoo.

#### Paso 1: Autenticarse

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "odoo-cliente-001",
    "client_secret": "mi-secreto-seguro-123"
  }'
```

**Respuesta:**
```json
{
  "success": true,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "expires_at": "2025-02-12 10:30:00"
}
```

**→ Guardar el token**

---

#### Paso 2: Consultar información de la licencia

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "LIC-2025-12345"
      }
    }
  }'
```

**Respuesta:**
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "nombre": "RESTAURANTE EL BUEN SABOR SA",
      "domicilio": "AV CHAPULTEPEC 456",
      "rfc": "RBS850101ABC",
      "estatus": 0,
      "mensaje_est": "OK"
    }
  }
}
```

**→ Licencia encontrada y activa**

---

#### Paso 3: Consultar adeudos

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "AdeudoDetalle",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "LIC-2025-12345",
        "referencia_pago": "REF-LIC-12345-2025"
      }
    }
  }'
```

**Respuesta:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "cta_aplicacion": 1,
        "descripcion": "LICENCIA FUNCIONAMIENTO 2025",
        "importe": 8500.00,
        "acumulado": 8500.00
      },
      {
        "cta_aplicacion": 2,
        "descripcion": "DERECHOS SANITARIOS",
        "importe": 1200.00,
        "acumulado": 9700.00
      }
    ]
  }
}
```

**→ Total a pagar: $9,700.00**

---

#### Paso 4: Procesar pago en Odoo

**(Este paso se hace en su sistema Odoo, no en el API)**

1. Mostrar al usuario el total: $9,700.00
2. Procesar el pago (tarjeta, efectivo, transferencia)
3. Generar factura en Odoo
4. Obtener folio de pago: "ODOO-FAC-2025-789"

---

#### Paso 5: Registrar el pago en el API

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "Pago",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "LIC-2025-12345",
        "referencia_pago": "REF-LIC-12345-2025",
        "monto_certificado": 9700.00,
        "monto_cartera": 9700.00,
        "id_cobro": 2025789,
        "folio_recibo": "ODOO-FAC-2025-789",
        "fecha_pago": "2025-02-11",
        "recaudadora": 1,
        "centro": 1,
        "caja": "ODOO_CAJA_01",
        "cc_forma_pago": "TARJETA",
        "pago_tarjeta": "4532"
      }
    }
  }'
```

**Respuesta:**
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "codigo": 0,
      "mensaje": "PAGO REGISTRADO EXITOSAMENTE"
    }
  }
}
```

**→ Pago registrado. Proceso completado exitosamente.**

---

### Caso Completo 2: Aplicar Descuento de Adulto Mayor

**Escenario:** Un adulto mayor solicita descuento en su impuesto predial.

#### Paso 1: Autenticarse (mismo que caso anterior)

#### Paso 2: Consultar descuentos disponibles

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "CatDescuentos",
      "Parametros": {
        "Idcuenta": 456789
      }
    }
  }'
```

**Respuesta:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "id_descuento": 1,
        "nombre": "ADULTO MAYOR",
        "porcentaje": 50.00,
        "descripcion": "Mayores de 60 años"
      }
    ]
  }
}
```

---

#### Paso 3: Aplicar el descuento

```bash
curl -X POST http://api.guadalajara.gob.mx/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -d '{
    "eRequest": {
      "Funcion": "AltaDescuentos",
      "Parametros": {
        "Idcuenta": 456789,
        "IdDescuento": 1,
        "bimini": "2025-1",
        "bimfin": "2025-6",
        "propietario": "MARIA LOPEZ HERNANDEZ",
        "identificacion": "INE987654321",
        "fechaNacimiento": "1950-03-20"
      }
    }
  }'
```

**Respuesta:**
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "codigo": 0,
      "mensaje": "DESCUENTO APLICADO EXITOSAMENTE"
    }
  }
}
```

**→ Descuento del 50% aplicado para todo el año 2025**

---

## Códigos de Respuesta

### HTTP Status Codes

| Código | Nombre | Significado | Acción |
|--------|--------|-------------|--------|
| **200** | OK | ✅ Operación exitosa | Procesar datos normalmente |
| **400** | Bad Request | ❌ Petición mal formada | Verificar formato JSON y campos obligatorios |
| **401** | Unauthorized | ❌ Token inválido o expirado | Generar nuevo token |
| **404** | Not Found | ❌ Endpoint no existe | Verificar URL |
| **500** | Internal Server Error | ❌ Error en el servidor | Contactar soporte |

### Códigos de Aplicación

Dentro del campo `data.codigo` en las respuestas:

| Código | Significado | Función | Solución |
|--------|-------------|---------|----------|
| **0** | ✅ Éxito | Todas | Operación completada correctamente |
| **1001** | ❌ Referencia inválida | Pago, Cancelacion | Verificar que la referencia existe |
| **1002** | ❌ Pago duplicado | Pago | No se puede registrar dos veces |
| **1003** | ❌ Monto incorrecto | Pago | Verificar que el monto coincide con el adeudo |
| **1004** | ❌ No encontrado | Cancelacion | Verificar id_cobro y folio_recibo |
| **1005** | ❌ Ya cancelado | Cancelacion | El pago ya fue cancelado previamente |
| **1006** | ❌ No cancelable | Cancelacion | Pago de días anteriores, requiere autorización |

---

## Swagger UI - Interfaz Visual

### ¿Qué es Swagger UI?

Swagger UI es una **herramienta visual** que le permite:

✅ Ver todos los endpoints disponibles
✅ Leer la documentación de cada función
✅ **Probar el API directamente desde el navegador**
✅ Ver ejemplos de requests y responses
✅ No requiere programación

**Es como un "simulador" del API donde puede practicar sin escribir código.**

### Acceder a Swagger UI

**URL (Desarrollo):**
```
http://localhost:8000/api/documentation
```

**URL (Producción):**
```
https://api.guadalajara.gob.mx/api/documentation
```

### Guía Visual de Swagger UI

#### Pantalla Principal

Cuando abra Swagger UI verá:

```
┌─────────────────────────────────────────────────┐
│  API de Integración Odoo - v1.0                │
│  Gobierno Municipal de Guadalajara             │
├─────────────────────────────────────────────────┤
│                                                 │
│  [🔓 Authorize]  ← Botón para autenticar      │
│                                                 │
│  ▼ JWT Authentication                          │
│    └─ POST /api/odoo/auth/token               │
│    └─ POST /api/odoo/auth/validate            │
│    └─ POST /api/odoo/auth/refresh             │
│    └─ GET  /api/odoo/auth/info                │
│                                                 │
│  ▼ Odoo Integration                            │
│    └─ POST /api/odoo                           │
│                                                 │
│  ▼ Generic API                                 │
│    └─ POST /api/generic                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Paso a Paso: Usar Swagger UI

**1. Generar Token**

1.1. Hacer clic en "JWT Authentication" para expandir
1.2. Hacer clic en `POST /api/odoo/auth/token`
1.3. Hacer clic en el botón "Try it out"
1.4. Modificar el JSON con sus credenciales:

```json
{
  "client_id": "su-client-id",
  "client_secret": "su-client-secret"
}
```

1.5. Hacer clic en "Execute"
1.6. Ver la respuesta abajo
1.7. Copiar el valor del campo "token"

**2. Autenticar en Swagger**

2.1. Hacer clic en el botón verde "Authorize" (arriba derecha)
2.2. Se abrirá una ventana emergente
2.3. En el campo "Value" escribir: `Bearer {su-token}`
     Ejemplo: `Bearer eyJ0eXAiOiJKV1QiLCJhbGc...`
2.4. Hacer clic en "Authorize"
2.5. Hacer clic en "Close"

**Ahora todas las peticiones incluirán automáticamente su token.**

**3. Probar una Consulta**

3.1. Expandir "Odoo Integration"
3.2. Hacer clic en `POST /api/odoo`
3.3. Hacer clic en "Try it out"
3.4. Ver el ejemplo pre-llenado
3.5. Modificar el JSON según lo que quiera consultar:

```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "numero-de-cuenta"
    }
  }
}
```

3.6. Hacer clic en "Execute"
3.7. Ver la respuesta abajo

**4. Interpretar la Respuesta**

Swagger muestra:

- **Status Code:** 200, 400, 401, etc.
- **Response body:** El JSON de respuesta
- **Response headers:** Información técnica

Si el status es 200 y `success: true`, todo salió bien.

### Ventajas de Usar Swagger UI

**Para No Desarrolladores:**
- ✅ No necesita instalar nada
- ✅ No necesita escribir código
- ✅ Interfaz visual amigable
- ✅ Puede probar inmediatamente

**Para Desarrolladores:**
- ✅ Documentación siempre actualizada
- ✅ Ejemplos en tiempo real
- ✅ Puede exportar a Postman
- ✅ Genera código automáticamente

### Exportar desde Swagger

Puede descargar la especificación OpenAPI:

**Formato JSON:**
```
http://localhost:8000/docs/api-docs.json
```

**Importar en Postman:**
1. Abrir Postman
2. Clic en "Import"
3. Pegar la URL del JSON
4. Postman creará toda la colección automáticamente

---

## Casos de Uso Reales

### Caso 1: Integración con Odoo ERP - Módulo de Ventas

**Empresa:** Tienda departamental con 15 sucursales
**Necesidad:** Vender licencias municipales en sus puntos de venta
**Solución:** Integración con API Odoo

**Flujo:**

1. **Cliente llega a caja**
   - Proporciona número de licencia
   - Cajero ingresa en sistema Odoo

2. **Odoo consulta adeudos** (API)
   ```
   Funcion: Consulta + AdeudoDetalle
   → Obtiene datos y monto a pagar
   ```

3. **Cliente paga**
   - Odoo procesa pago (efectivo/tarjeta)
   - Genera factura electrónica
   - Imprime recibo

4. **Odoo notifica al gobierno** (API)
   ```
   Funcion: Pago
   → Registra el pago realizado
   ```

5. **Sincronización**
   - Sistema del gobierno actualiza estado
   - Licencia queda pagada en tiempo real

**Beneficios:**
- ✅ Proceso en 2-3 minutos
- ✅ Sin filas en oficinas de gobierno
- ✅ Factura inmediata
- ✅ Registro automático

---

### Caso 2: Módulo de Cobranza Automatizada

**Empresa:** Software de cobranza municipal
**Necesidad:** Enviar notificaciones de adeudos
**Solución:** Consultas programadas al API

**Flujo:**

1. **Tarea programada** (diariamente a las 6:00 AM)
   - Sistema genera token JWT
   - Itera lista de contribuyentes

2. **Por cada contribuyente:**
   ```
   Funcion: AdeudoDetalle
   → Obtiene adeudos actualizados
   ```

3. **Si hay adeudos:**
   - Genera notificación por email/SMS
   - Incluye monto y referencia
   - Adjunta liga de pago

4. **Contribuyente paga en línea**
   - Sistema recibe webhook de pago
   - Llama a API:
   ```
   Funcion: Pago
   → Registra el pago
   ```

**Beneficios:**
- ✅ Cobranza proactiva
- ✅ Actualización en tiempo real
- ✅ Reducción de morosidad
- ✅ Automatización 100%

---

### Caso 3: Aplicación Móvil para Ciudadanos

**Gobierno:** App móvil "Guadalajara Digital"
**Necesidad:** Consulta de trámites desde celular
**Solución:** API REST consumida desde app

**Funcionalidades:**

1. **Mis Licencias**
   ```
   Funcion: Consulta
   → Lista licencias del usuario
   ```

2. **Adeudos Pendientes**
   ```
   Funcion: AdeudoDetalle
   → Muestra desglose de adeudos
   ```

3. **Pago en Línea**
   - Integración con pasarela de pago
   - Al confirmar pago:
   ```
   Funcion: Pago
   → Registra transacción
   ```

4. **Historial**
   - Consulta pagos realizados
   - Descarga recibos
   - Tracking en tiempo real

**Beneficios:**
- ✅ Disponible 24/7
- ✅ Acceso desde cualquier lugar
- ✅ Trámites sin filas
- ✅ Transparencia total

---

### Caso 4: Punto de Venta Físico

**Ubicación:** Módulos de atención ciudadana
**Necesidad:** Recibir pagos en ventanilla
**Solución:** Software con integración al API

**Pantalla del cajero:**

```
┌─────────────────────────────────────┐
│  SISTEMA DE COBRANZA MUNICIPAL     │
├─────────────────────────────────────┤
│  Ingrese número de cuenta:         │
│  [12345678____________]  [Buscar]  │
│                                     │
│  Nombre: JUAN PEREZ GARCIA         │
│  Licencia: COMERCIAL               │
│                                     │
│  ADEUDOS:                          │
│  └─ Licencia 2025......$8,500.00  │
│  └─ Derechos...........$1,200.00  │
│  ─────────────────────────────────  │
│  TOTAL:............... $9,700.00  │
│                                     │
│  [Pagar Efectivo] [Pagar Tarjeta] │
└─────────────────────────────────────┘
```

**Proceso:**
1. Buscar cuenta → `Funcion: Consulta`
2. Mostrar adeudos → `Funcion: AdeudoDetalle`
3. Procesar pago → Local
4. Registrar → `Funcion: Pago`
5. Imprimir recibo

---

## Integración con Odoo

### Arquitectura de Integración

```
┌──────────────────────────────────────────────┐
│           ODOO ERP (Su Sistema)              │
├──────────────────────────────────────────────┤
│                                              │
│  ┌─────────────┐     ┌──────────────┐      │
│  │   Ventas    │     │  Facturación │      │
│  │             │     │              │      │
│  │ - Cotizar   │     │ - Generar    │      │
│  │ - Vender    │◄────┤   facturas   │      │
│  │ - Cobrar    │     │ - Timbrar    │      │
│  └──────┬──────┘     └──────────────┘      │
│         │                                    │
│         ▼                                    │
│  ┌─────────────────────────────────────┐   │
│  │  MÓDULO PERSONALIZADO               │   │
│  │  "Integración Gobierno Guadalajara"│   │
│  │                                     │   │
│  │  - Consultar adeudos                │   │
│  │  - Registrar pagos                  │   │
│  │  - Aplicar descuentos               │   │
│  │  - Generar reportes                 │   │
│  └──────────────┬──────────────────────┘   │
│                 │                            │
└─────────────────┼────────────────────────────┘
                  │
                  │ HTTPS/REST
                  │ (JSON)
                  ▼
┌──────────────────────────────────────────────┐
│      API ODOO - GOBIERNO GUADALAJARA         │
│                                              │
│  - Autenticación JWT                        │
│  - Validación de tokens                     │
│  - Procesamiento de peticiones              │
│  - Respuestas en tiempo real                │
└──────────────────┬───────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────┐
│      BASES DE DATOS GUBERNAMENTALES         │
│                                              │
│  - Licencias                                │
│  - Infracciones                             │
│  - Predial                                  │
│  - Otros servicios                          │
└──────────────────────────────────────────────┘
```

### Módulo Odoo Personalizado

Para integrar con Odoo, necesita desarrollar un módulo personalizado que:

**1. Configuración**
```python
# __manifest__.py
{
    'name': 'Integración Gobierno Guadalajara',
    'version': '1.0',
    'category': 'Accounting',
    'depends': ['account', 'sale'],
    'data': [
        'views/licencia_views.xml',
        'security/ir.model.access.csv',
    ],
}
```

**2. Modelo de Datos**
```python
# models/licencia_municipal.py
from odoo import models, fields, api
import requests

class LicenciaMunicipal(models.Model):
    _name = 'guadalajara.licencia'

    name = fields.Char('Número de Licencia')
    partner_id = fields.Many2one('res.partner', 'Cliente')
    tipo_licencia = fields.Selection([
        ('comercial', 'Comercial'),
        ('alcoholes', 'Alcoholes'),
    ])
    estado = fields.Selection([
        ('vigente', 'Vigente'),
        ('vencida', 'Vencida'),
        ('suspendida', 'Suspendida'),
    ])
    adeudo_total = fields.Float('Adeudo Total')

    @api.model
    def consultar_adeudo(self):
        # Generar token
        token = self._generar_token_jwt()

        # Consultar API
        response = requests.post(
            'https://api.guadalajara.gob.mx/api/odoo',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            },
            json={
                'eRequest': {
                    'Funcion': 'AdeudoDetalle',
                    'Parametros': {
                        'Idinterfaz': 8,
                        'cta_01': self.name
                    }
                }
            }
        )

        if response.status_code == 200:
            data = response.json()
            if data['eResponse']['success']:
                adeudos = data['eResponse']['data']
                total = sum([a['importe'] for a in adeudos])
                self.adeudo_total = total
                return total

        return 0.0

    def registrar_pago(self, monto, folio):
        token = self._generar_token_jwt()

        response = requests.post(
            'https://api.guadalajara.gob.mx/api/odoo',
            headers={
                'Authorization': f'Bearer {token}',
                'Content-Type': 'application/json'
            },
            json={
                'eRequest': {
                    'Funcion': 'Pago',
                    'Parametros': {
                        'Idinterfaz': 8,
                        'cta_01': self.name,
                        'referencia_pago': f'REF-{self.name}',
                        'monto_certificado': monto,
                        'monto_cartera': monto,
                        'id_cobro': int(folio),
                        'folio_recibo': f'ODOO-{folio}',
                        'fecha_pago': fields.Date.today().strftime('%Y-%m-%d'),
                        'recaudadora': 1,
                        'centro': 1,
                        'caja': 'ODOO_PRINCIPAL'
                    }
                }
            }
        )

        return response.json()
```

**3. Vista en Odoo**
```xml
<!-- views/licencia_views.xml -->
<odoo>
    <record id="view_licencia_form" model="ir.ui.view">
        <field name="name">guadalajara.licencia.form</field>
        <field name="model">guadalajara.licencia</field>
        <field name="arch" type="xml">
            <form>
                <sheet>
                    <group>
                        <field name="name"/>
                        <field name="partner_id"/>
                        <field name="tipo_licencia"/>
                        <field name="estado"/>
                        <field name="adeudo_total"/>
                    </group>
                    <footer>
                        <button name="consultar_adeudo"
                                type="object"
                                string="Consultar Adeudo"
                                class="btn-primary"/>
                    </footer>
                </sheet>
            </form>
        </field>
    </record>
</odoo>
```

### Flujo de Pago en Odoo

**1. Crear cotización/pedido:**
```python
# En el módulo de ventas
sale_order = self.env['sale.order'].create({
    'partner_id': partner.id,
    'order_line': [(0, 0, {
        'product_id': producto_licencia.id,
        'price_unit': adeudo_total,
        'product_uom_qty': 1
    })]
})
```

**2. Confirmar pedido y generar factura:**
```python
sale_order.action_confirm()
invoice = sale_order._create_invoices()
invoice.action_post()  # Timbrar factura
```

**3. Registrar pago:**
```python
payment = self.env['account.payment'].create({
    'payment_type': 'inbound',
    'partner_type': 'customer',
    'partner_id': partner.id,
    'amount': adeudo_total,
    'journal_id': journal.id,
})
payment.action_post()

# Conciliar pago con factura
(payment.move_id.line_ids + invoice.line_ids).filtered(
    lambda l: l.account_type == 'asset_receivable'
).reconcile()
```

**4. Notificar al gobierno:**
```python
licencia.registrar_pago(
    monto=adeudo_total,
    folio=payment.name
)
```

---

## Troubleshooting

### Problemas Comunes y Soluciones

#### Error 1: "Token inválido o expirado"

**Síntoma:**
```json
{
  "eResponse": {
    "success": false,
    "message": "Token inválido o expirado"
  }
}
```

**Causas posibles:**
1. El token expiró (> 24 horas)
2. Token mal copiado (falta algún carácter)
3. Token de desarrollo usado en producción
4. Credenciales incorrectas

**Soluciones:**
1. Generar nuevo token
2. Verificar que copió el token completo
3. Usar credenciales correctas según ambiente
4. Implementar refresh automático de token

**Código de ejemplo (auto-refresh):**
```python
import time

class APIClient:
    def __init__(self):
        self.token = None
        self.token_expires = 0

    def get_token(self):
        # Si el token expira en menos de 1 hora, refrescar
        if time.time() > (self.token_expires - 3600):
            self.refresh_token()
        return self.token

    def refresh_token(self):
        # Llamar a /api/odoo/auth/token
        # Actualizar self.token y self.token_expires
        pass
```

---

#### Error 2: "Referencia no encontrada"

**Síntoma:**
```json
{
  "data": {
    "codigo": 1001,
    "mensaje": "REFERENCIA INVALIDA"
  }
}
```

**Causas:**
1. Número de cuenta incorrecto
2. Referencia de pago mal formada
3. Cuenta no existe en el sistema

**Soluciones:**
1. Verificar el número de cuenta con el cliente
2. Consultar primero con `Funcion: Consulta`
3. Validar formato de referencia

**Flujo recomendado:**
```
1. Consultar → Si existe, continuar
2. Si no existe → Mostrar error al usuario
3. No intentar pagar sin consultar primero
```

---

#### Error 3: "Pago duplicado"

**Síntoma:**
```json
{
  "data": {
    "codigo": 1002,
    "mensaje": "PAGO YA REGISTRADO"
  }
}
```

**Causas:**
1. Intentando registrar el mismo pago dos veces
2. `id_cobro` duplicado
3. `folio_recibo` duplicado

**Soluciones:**
1. Verificar que el pago no se haya registrado antes
2. Usar `id_cobro` único por transacción
3. Implementar tabla de control de pagos enviados
4. No reintentar si ya se registró

**Tabla de control recomendada:**
```sql
CREATE TABLE pagos_enviados (
    id_cobro INT PRIMARY KEY,
    folio_recibo VARCHAR(50) UNIQUE,
    fecha_envio DATETIME,
    respuesta_api TEXT,
    estado VARCHAR(20)  -- 'pendiente', 'exitoso', 'error'
);
```

---

#### Error 4: Timeout de conexión

**Síntoma:**
- La petición tarda más de 30 segundos
- Error "Connection timeout"
- No hay respuesta

**Causas:**
1. Problemas de red
2. Servidor API caído
3. Consulta muy pesada
4. Timeout configurado muy corto

**Soluciones:**
1. Implementar reintentos con backoff exponencial
2. Aumentar timeout a 60 segundos
3. Verificar estado del servicio
4. Contactar soporte si persiste

**Código con reintentos:**
```python
import time

def llamar_api_con_reintentos(url, data, max_intentos=3):
    for intento in range(max_intentos):
        try:
            response = requests.post(
                url,
                json=data,
                timeout=60
            )
            return response
        except requests.Timeout:
            if intento < max_intentos - 1:
                # Esperar 2^intento segundos
                time.sleep(2 ** intento)
            else:
                raise
```

---

#### Error 5: "Monto incorrecto"

**Síntoma:**
```json
{
  "data": {
    "codigo": 1003,
    "mensaje": "MONTO NO COINCIDE"
  }
}
```

**Causas:**
1. El monto enviado no coincide con el adeudo consultado
2. Se consultó en un momento y se pagó más tarde (adeudo cambió)
3. Redondeos de centavos

**Soluciones:**
1. Siempre consultar adeudo justo antes de pagar
2. No guardar adeudos en caché por mucho tiempo
3. Usar campo `monto_redondeo` para centavos

**Flujo correcto:**
```
1. Consultar adeudo → Obtener total: $9,700.50
2. Inmediatamente procesar pago por: $9,700.50
3. Registrar con monto_certificado: 9700.50
4. Si redondeo a $9,700.00:
   - monto_certificado: 9700.00
   - monto_cartera: 9700.00
   - monto_redondeo: 0.50
```

---

#### Error 6: SSL/HTTPS no funciona

**Síntoma:**
- "SSL certificate problem"
- "HTTPS not supported"

**Causas:**
1. Certificados SSL no instalados
2. Usando HTTP en lugar de HTTPS
3. Certificado auto-firmado en desarrollo

**Soluciones:**

**Para desarrollo:**
```python
# Solo para desarrollo, NO en producción
import urllib3
urllib3.disable_warnings()

response = requests.post(
    url,
    json=data,
    verify=False  # ⚠️ Solo en desarrollo
)
```

**Para producción:**
```python
# Usar certificados válidos
response = requests.post(
    url,
    json=data,
    verify=True,
    cert='/path/to/client-cert.pem'
)
```

---

### Logs y Depuración

**Ver logs del API:**
```bash
# Laravel logs
tail -f storage/logs/laravel.log
```

**Activar modo debug:**
```env
# En .env
APP_DEBUG=true
LOG_LEVEL=debug
```

**Logs en su sistema:**

Implemente logging detallado:
```python
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='api_odoo.log'
)

logger = logging.getLogger(__name__)

# Antes de cada petición
logger.info(f"Enviando petición: {funcion}")
logger.debug(f"Datos: {json.dumps(parametros)}")

# Después de recibir respuesta
logger.info(f"Respuesta recibida: {response.status_code}")
logger.debug(f"Body: {response.text}")
```

---

### Contacto para Soporte Técnico

**Email:** soporte@guadalajara.gob.mx

**Horario:** Lunes a Viernes, 9:00 AM - 6:00 PM (hora del centro)

**Información a incluir al reportar un problema:**

1. ✅ Descripción detallada del problema
2. ✅ Endpoint que está usando
3. ✅ Request enviado (sin credenciales sensibles)
4. ✅ Response recibido
5. ✅ Código de error
6. ✅ Timestamp de la petición
7. ✅ Ambiente (desarrollo/producción)
8. ✅ Su client_id

**Tiempos de respuesta:**
- Urgente (servicio caído): 2 horas
- Alta (error bloquean te): 4 horas
- Media (dudas técnicas): 24 horas
- Baja (mejoras, sugerencias): 5 días

---

## Glosario de Términos

| Término | Definición |
|---------|------------|
| **API** | Application Programming Interface - Interfaz que permite que dos sistemas se comuniquen |
| **REST** | Representational State Transfer - Estilo de arquitectura para APIs web |
| **JSON** | JavaScript Object Notation - Formato de texto para intercambiar datos |
| **JWT** | JSON Web Token - Estándar para crear tokens de acceso |
| **Token** | Credencial digital que prueba su autorización para usar el API |
| **Endpoint** | URL específica donde se realiza una operación del API |
| **Request** | Petición que envía al API solicitando una operación |
| **Response** | Respuesta que el API devuelve después de procesar su petición |
| **Header** | Información adicional enviada en una petición HTTP |
| **Body** | Contenido principal de una petición o respuesta |
| **Status Code** | Código numérico que indica el resultado de una operación HTTP |
| **Bearer Token** | Método de autenticación que usa "Bearer" + token en el header |
| **Timeout** | Tiempo máximo de espera para una respuesta |
| **SSL/TLS** | Protocolos de seguridad para encriptar comunicaciones HTTPS |
| **Idinterfaz** | Identificador de la base de datos/módulo a consultar |
| **Stored Procedure** | Procedimiento almacenado en la base de datos |
| **Middleware** | Software intermediario entre su sistema y las bases de datos |
| **Swagger** | Herramienta para documentar y probar APIs |
| **OpenAPI** | Especificación estándar para describir APIs REST |
| **Client ID** | Su identificador único en el sistema |
| **Client Secret** | Su contraseña secreta para autenticarse |
| **Refresh Token** | Renovar un token sin volver a autenticar |
| **Webhook** | Notificación automática de un evento |

---

## Preguntas Frecuentes

### Generales

**P: ¿Necesito ser programador para usar el API?**
R: No necesariamente. Puede usar herramientas visuales como Swagger UI. Sin embargo, para integración completa con su sistema, necesitará un desarrollador.

**P: ¿Cuánto cuesta usar el API?**
R: El uso del API es gratuito para trámites del Gobierno Municipal de Guadalajara.

**P: ¿Hay límite de peticiones?**
R: No hay límite definido actualmente. Sin embargo, se recomienda no exceder 1000 peticiones por minuto para evitar sobrecarga.

**P: ¿El API está disponible 24/7?**
R: Sí, el API está disponible 24 horas, 7 días a la semana. Ocasionalmente puede haber mantenimientos programados que se notifican con anticipación.

### Autenticación

**P: ¿Cuánto dura mi token?**
R: 24 horas por defecto. Puede verificar el campo `expires_at` en la respuesta.

**P: ¿Qué pasa si mi token expira mientras estoy trabajando?**
R: Recibirá error 401. Debe generar un nuevo token o usar la función de refresh.

**P: ¿Puedo tener múltiples tokens activos?**
R: Sí, puede generar varios tokens. Todos serán válidos hasta su expiración individual.

**P: ¿Dónde guardo mi client_secret de forma segura?**
R: Use variables de entorno, nunca en código fuente. Considere usar servicios como HashiCorp Vault para producción.

### Operaciones

**P: ¿Puedo cancelar un pago del mes pasado?**
R: No directamente por API. Solo pagos del mismo día. Para otros casos, contacte soporte.

**P: ¿El API procesa pagos con tarjeta?**
R: No. El API solo REGISTRA pagos que ya procesó su sistema. No hace cargos.

**P: ¿Puedo hacer pagos parciales?**
R: Sí, registrando pagos por conceptos específicos usando `cta_aplicacion`.

**P: ¿Cómo sé si un pago se registró correctamente?**
R: El campo `codigo` debe ser 0 (cero). Además, guarde el response completo para auditoría.

### Técnicas

**P: ¿Qué lenguajes de programación puedo usar?**
R: Cualquiera que soporte HTTP/HTTPS: PHP, Python, Java, JavaScript, C#, etc.

**P: ¿Necesito instalar librerías especiales?**
R: Solo una librería HTTP (como cURL, requests, axios, etc.) que ya viene en la mayoría de lenguajes.

**P: ¿Puedo usar Postman?**
R: Sí, es perfectamente compatible. Puede importar la especificación OpenAPI.

**P: ¿Hay SDK o librería oficial?**
R: Actualmente no. Está en planes futuros. Por ahora use peticiones HTTP directas.

### Errores

**P: Recibo error 500, ¿qué hago?**
R: Error 500 es del servidor. Reintente en unos minutos. Si persiste, contacte soporte con los detalles.

**P: ¿Puedo reintentar automáticamente si hay error?**
R: Sí, excepto errores 400 (validación). Implemente backoff exponencial.

**P: ¿Dónde veo los logs de mis peticiones?**
R: Debe implementar logging en su sistema. El API no guarda logs de peticiones de clientes.

---

## Contacto y Soporte

### Soporte Técnico

**Email Principal:**
soporte@guadalajara.gob.mx

**Asunto del email:**
"API Odoo - [Breve descripción del problema]"

**Horario de Atención:**
Lunes a Viernes: 9:00 AM - 6:00 PM (GMT-6)

**Teléfono (solo urgencias):**
+52 (33) 1234-5678

### Solicitud de Credenciales

**Email:**
acceso-api@guadalajara.gob.mx

**Documentos requeridos:**
1. Formato de solicitud (descargar en portal)
2. Identificación oficial del representante legal
3. Comprobante de domicilio
4. Cédula fiscal (empresas)
5. Propósito de integración (descripción)

### Reportar Errores

**Template de reporte:**

```
Asunto: [API Odoo] Error en [función]

Descripción:
[Descripción detallada del problema]

Ambiente:
- Desarrollo / Producción
- Fecha y hora: [timestamp]

Endpoint:
[URL del endpoint]

Request:
[JSON del request - sin credenciales]

Response:
[JSON del response]

Código de error:
[Status code y mensaje]

client_id:
[Su client_id]

Pasos para reproducir:
1. ...
2. ...
3. ...
```

### Comunidad y Recursos

**Portal de Documentación:**
https://api.guadalajara.gob.mx/docs

**Swagger UI (pruebas):**
https://api.guadalajara.gob.mx/api/documentation

**Status del Servicio:**
https://status.guadalajara.gob.mx

**Changelog (cambios y actualizaciones):**
https://api.guadalajara.gob.mx/changelog

### Feedback y Sugerencias

**Email:**
feedback-api@guadalajara.gob.mx

Sus comentarios nos ayudan a mejorar el servicio.

---

## Apéndice A: Quick Reference

### Checklist de Inicio Rápido

- [ ] Solicitar credenciales (client_id + client_secret)
- [ ] Recibir credenciales por canal seguro
- [ ] Configurar en ambiente de desarrollo
- [ ] Generar primer token JWT
- [ ] Probar consulta simple en Swagger UI
- [ ] Implementar código en su sistema
- [ ] Probar en desarrollo con datos reales
- [ ] Solicitar paso a producción
- [ ] Configurar credenciales de producción
- [ ] Monitorear logs de producción

### URLs de Referencia Rápida

| Ambiente | URL Base |
|----------|----------|
| **Desarrollo** | http://localhost:8000/api |
| **Staging** | https://staging-api.guadalajara.gob.mx/api |
| **Producción** | https://api.guadalajara.gob.mx/api |

### Endpoints Más Usados

**⚠️ IMPORTANTE: Solo hay 1 endpoint para Odoo, cambia el campo `Funcion`**

| Operación | Endpoint | Campo Funcion |
|-----------|----------|---------------|
| Autenticar | POST /odoo/auth/token | N/A (endpoint diferente) |
| Consultar | POST /odoo | `"Funcion": "Consulta"` |
| Ver adeudos | POST /odoo | `"Funcion": "AdeudoDetalle"` |
| Registrar pago | POST /odoo | `"Funcion": "Pago"` |
| Cancelar pago | POST /odoo | `"Funcion": "Cancelacion"` |

**Nota:** Todos usan el mismo endpoint `/api/odoo`, solo cambia el valor de `Funcion` en el request.

### Códigos de Error Comunes

| Código | Significado | Solución |
|--------|-------------|----------|
| 200 | OK | Todo correcto |
| 400 | Bad Request | Verificar JSON |
| 401 | Unauthorized | Generar nuevo token |
| 500 | Server Error | Contactar soporte |

---

## Apéndice B: Ejemplos de Código

### PHP

```php
<?php

class OdooAPIClient {
    private $baseUrl;
    private $clientId;
    private $clientSecret;
    private $token;

    public function __construct($baseUrl, $clientId, $clientSecret) {
        $this->baseUrl = $baseUrl;
        $this->clientId = $clientId;
        $this->clientSecret = $clientSecret;
        $this->generateToken();
    }

    private function generateToken() {
        $ch = curl_init($this->baseUrl . '/odoo/auth/token');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'client_id' => $this->clientId,
            'client_secret' => $this->clientSecret
        ]));

        $response = curl_exec($ch);
        $data = json_decode($response, true);
        $this->token = $data['token'];
        curl_close($ch);
    }

    public function consultar($idInterfaz, $cuenta) {
        $ch = curl_init($this->baseUrl . '/odoo');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $this->token
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'eRequest' => [
                'Funcion' => 'Consulta',
                'Parametros' => [
                    'Idinterfaz' => $idInterfaz,
                    'cta_01' => $cuenta
                ]
            ]
        ]));

        $response = curl_exec($ch);
        curl_close($ch);
        return json_decode($response, true);
    }
}

// Uso
$client = new OdooAPIClient(
    'https://api.guadalajara.gob.mx/api',
    'mi-client-id',
    'mi-client-secret'
);

$resultado = $client->consultar(8, '12345678');
print_r($resultado);
```

### Python

```python
import requests
from datetime import datetime, timedelta

class OdooAPIClient:
    def __init__(self, base_url, client_id, client_secret):
        self.base_url = base_url
        self.client_id = client_id
        self.client_secret = client_secret
        self.token = None
        self.token_expires = None
        self.generate_token()

    def generate_token(self):
        response = requests.post(
            f"{self.base_url}/odoo/auth/token",
            json={
                "client_id": self.client_id,
                "client_secret": self.client_secret
            }
        )
        data = response.json()
        self.token = data['token']
        self.token_expires = datetime.now() + timedelta(hours=24)

    def _get_headers(self):
        if datetime.now() >= self.token_expires:
            self.generate_token()

        return {
            'Content-Type': 'application/json',
            'Authorization': f'Bearer {self.token}'
        }

    def consultar(self, id_interfaz, cuenta):
        response = requests.post(
            f"{self.base_url}/odoo",
            headers=self._get_headers(),
            json={
                "eRequest": {
                    "Funcion": "Consulta",
                    "Parametros": {
                        "Idinterfaz": id_interfaz,
                        "cta_01": cuenta
                    }
                }
            }
        )
        return response.json()

    def adeudo_detalle(self, id_interfaz, cuenta, referencia):
        response = requests.post(
            f"{self.base_url}/odoo",
            headers=self._get_headers(),
            json={
                "eRequest": {
                    "Funcion": "AdeudoDetalle",
                    "Parametros": {
                        "Idinterfaz": id_interfaz,
                        "cta_01": cuenta,
                        "referencia_pago": referencia
                    }
                }
            }
        )
        return response.json()

# Uso
client = OdooAPIClient(
    'https://api.guadalajara.gob.mx/api',
    'mi-client-id',
    'mi-client-secret'
)

resultado = client.consultar(8, '12345678')
print(resultado)
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

class OdooAPIClient {
    constructor(baseUrl, clientId, clientSecret) {
        this.baseUrl = baseUrl;
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.token = null;
        this.tokenExpires = null;
    }

    async generateToken() {
        const response = await axios.post(
            `${this.baseUrl}/odoo/auth/token`,
            {
                client_id: this.clientId,
                client_secret: this.clientSecret
            }
        );

        this.token = response.data.token;
        this.tokenExpires = new Date(response.data.expires_at);
    }

    async getHeaders() {
        if (!this.token || new Date() >= this.tokenExpires) {
            await this.generateToken();
        }

        return {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.token}`
        };
    }

    async consultar(idInterfaz, cuenta) {
        const headers = await this.getHeaders();

        const response = await axios.post(
            `${this.baseUrl}/odoo`,
            {
                eRequest: {
                    Funcion: 'Consulta',
                    Parametros: {
                        Idinterfaz: idInterfaz,
                        cta_01: cuenta
                    }
                }
            },
            { headers }
        );

        return response.data;
    }

    async registrarPago(params) {
        const headers = await this.getHeaders();

        const response = await axios.post(
            `${this.baseUrl}/odoo`,
            {
                eRequest: {
                    Funcion: 'Pago',
                    Parametros: params
                }
            },
            { headers }
        );

        return response.data;
    }
}

// Uso
(async () => {
    const client = new OdooAPIClient(
        'https://api.guadalajara.gob.mx/api',
        'mi-client-id',
        'mi-client-secret'
    );

    const resultado = await client.consultar(8, '12345678');
    console.log(resultado);
})();
```

---

## Conclusión

Este documento le ha proporcionado **toda la información necesaria** para integrar exitosamente su sistema con el API de Odoo del Gobierno Municipal de Guadalajara.

### Próximos Pasos Recomendados

1. ✅ **Solicitar credenciales** si aún no las tiene
2. ✅ **Explorar Swagger UI** para familiarizarse con el API
3. ✅ **Hacer pruebas en desarrollo** con ejemplos de este documento
4. ✅ **Implementar en su sistema** usando los ejemplos de código
5. ✅ **Contactar soporte** si tiene dudas

### Recursos de Apoyo

- 📖 **Esta documentación** - Referencia completa
- 💻 **Swagger UI** - Pruebas visuales
- 📧 **Soporte técnico** - Asistencia personalizada
- 🔧 **Ejemplos de código** - Implementaciones listas

### Manténgase Actualizado

El API evoluciona constantemente con nuevas funciones y mejoras.

**Suscríbase a actualizaciones:**
actualizaciones-api@guadalajara.gob.mx

---

**¡Gracias por usar el API de Integración Odoo!**

**Gobierno Municipal de Guadalajara**
**Dirección de Tecnologías de la Información**
**Febrero 2025**

---

*Este documento fue generado con Claude Code y contiene información actualizada al 11 de febrero de 2025. Para la versión más reciente, visite: https://api.guadalajara.gob.mx/docs*
