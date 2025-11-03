# 🎯 Arquitectura de Endpoints - API Odoo

## ⚠️ IMPORTANTE: Evite Confusiones

Este documento aclara un punto **CRUCIAL** que puede generar confusión.

---

## ¿Cuántos Endpoints Tiene el API?

### Respuesta Simple:

**5 endpoints en total:**

```
1. POST   /api/odoo/auth/token      → Generar token JWT
2. POST   /api/odoo/auth/validate   → Validar token JWT
3. POST   /api/odoo/auth/refresh    → Refrescar token JWT
4. GET    /api/odoo/auth/info       → Info del sistema JWT
5. POST   /api/odoo                 → TODAS las operaciones de Odoo
```

---

## El Endpoint Único de Odoo

### ¿Por qué puede confundir?

El endpoint `POST /api/odoo` hace **18 operaciones diferentes**, pero es **UN SOLO ENDPOINT**.

### ¿Cómo funciona?

**NO es así (INCORRECTO):**
```
❌ POST /api/odoo/consulta
❌ POST /api/odoo/pago
❌ POST /api/odoo/cancelacion
❌ POST /api/odoo/adeudodetalle
```

**ES así (CORRECTO):**
```
✅ POST /api/odoo  → Con "Funcion": "Consulta"
✅ POST /api/odoo  → Con "Funcion": "Pago"
✅ POST /api/odoo  → Con "Funcion": "Cancelacion"
✅ POST /api/odoo  → Con "Funcion": "AdeudoDetalle"
```

### Estructura del Request

**Siempre igual:**

```json
{
  "eRequest": {
    "Funcion": "AQUI_CAMBIA",    ← Este campo define qué hacer
    "Token": "tu-token-jwt",      ← Siempre el mismo token
    "Parametros": {               ← Cambian según la función
      "Idinterfaz": 8,
      "cta_01": "12345678",
      ...
    }
  }
}
```

---

## Comparación Visual

### Autenticación JWT (4 endpoints diferentes)

```
Generar Token:
URL: POST /api/odoo/auth/token
Body:
{
  "client_id": "...",
  "client_secret": "..."
}

─────────────────────────────────

Validar Token:
URL: POST /api/odoo/auth/validate
Body:
{
  "token": "..."
}

─────────────────────────────────

Refrescar Token:
URL: POST /api/odoo/auth/refresh
Body:
{
  "token": "..."
}

─────────────────────────────────

Info del Sistema:
URL: GET /api/odoo/auth/info
Body: (no requiere)
```

### Operaciones Odoo (1 endpoint, múltiples funciones)

```
Consultar:
URL: POST /api/odoo              ← Mismo endpoint
Body:
{
  "eRequest": {
    "Funcion": "Consulta",       ← Cambia aquí
    "Token": "...",
    "Parametros": {...}
  }
}

─────────────────────────────────

Ver Adeudos:
URL: POST /api/odoo              ← Mismo endpoint
Body:
{
  "eRequest": {
    "Funcion": "AdeudoDetalle",  ← Cambia aquí
    "Token": "...",
    "Parametros": {...}
  }
}

─────────────────────────────────

Registrar Pago:
URL: POST /api/odoo              ← Mismo endpoint
Body:
{
  "eRequest": {
    "Funcion": "Pago",           ← Cambia aquí
    "Token": "...",
    "Parametros": {...}
  }
}

─────────────────────────────────

Cancelar Pago:
URL: POST /api/odoo              ← Mismo endpoint
Body:
{
  "eRequest": {
    "Funcion": "Cancelacion",    ← Cambia aquí
    "Token": "...",
    "Parametros": {...}
  }
}
```

---

## ¿Por Qué se Diseñó Así?

### Ventajas del Endpoint Único:

1. ✅ **Simplicidad de configuración**
   - Solo una URL para configurar en su sistema
   - No necesita actualizar URLs si agregamos funciones

2. ✅ **Autenticación unificada**
   - El mismo token sirve para todas las funciones
   - No necesita tokens diferentes por operación

3. ✅ **Estructura consistente**
   - Siempre el mismo formato de request
   - Fácil de implementar en cualquier lenguaje

4. ✅ **Escalabilidad**
   - Podemos agregar nuevas funciones sin cambiar la API
   - Solo se agregan nuevos valores al campo `Funcion`

### Patrón de Diseño:

Este patrón se llama **"Action Pattern"** o **"Command Pattern"**:
- Un solo endpoint recibe "comandos"
- El campo `Funcion` es el "comando" a ejecutar
- Los `Parametros` son los argumentos del comando

---

## Las 18 Funciones Disponibles

**Todas se ejecutan en:** `POST /api/odoo`

| # | Valor de "Funcion" | Qué Hace |
|---|-------------------|----------|
| 1 | `"Consulta"` | Consultar información general |
| 2 | `"DatosVarios"` | Obtener datos complementarios |
| 3 | `"AdeudoDetalle"` | Ver desglose de adeudos |
| 4 | `"AdeudoDetalleInmovilizadores"` | Adeudos con grúa |
| 5 | `"Pago"` | Registrar un pago |
| 6 | `"Cancelacion"` | Cancelar un pago |
| 7 | `"ConsCuenta"` | Consultar cuenta predial |
| 8 | `"CatDescuentos"` | Catálogo de descuentos |
| 9 | `"ListDescuentos"` | Lista descuentos aplicados |
| 10 | `"AltaDescuentos"` | Aplicar descuento |
| 11 | `"CancelDescuentos"` | Cancelar descuento |
| 12 | `"ConsDesctoTablet"` | Consulta descuentos (móvil) |
| 13 | `"AltaDesctoTablet"` | Alta descuentos (móvil) |
| 14 | `"FechasPendientesEl"` | Fechas pendientes |
| 15 | `"PendientesXIntegrar"` | Pendientes de integrar |
| 16 | `"DetallesXIntegrar"` | Detalles pendientes |
| 17 | `"ActualizarPendientes"` | Actualizar estado |
| 18 | `"LicenciaVisor"` | Codificar licencia |

---

## Ejemplo Práctico en Código

### PHP

```php
<?php
// UN SOLO ENDPOINT para todo
$url = 'https://api.guadalajara.gob.mx/api/odoo';
$token = 'eyJ0eXAiOiJKV1Q...';

// Función 1: Consultar
$request1 = [
    'eRequest' => [
        'Funcion' => 'Consulta',  // ← Solo esto cambia
        'Token' => $token,
        'Parametros' => [
            'Idinterfaz' => 8,
            'cta_01' => '12345678'
        ]
    ]
];
$response1 = http_post($url, $request1);

// Función 2: Ver adeudos (MISMO endpoint)
$request2 = [
    'eRequest' => [
        'Funcion' => 'AdeudoDetalle',  // ← Solo esto cambia
        'Token' => $token,
        'Parametros' => [
            'Idinterfaz' => 8,
            'cta_01' => '12345678'
        ]
    ]
];
$response2 = http_post($url, $request2); // Misma URL

// Función 3: Registrar pago (MISMO endpoint)
$request3 = [
    'eRequest' => [
        'Funcion' => 'Pago',  // ← Solo esto cambia
        'Token' => $token,
        'Parametros' => [
            'Idinterfaz' => 8,
            'referencia_pago' => 'REF-123',
            'monto_certificado' => 5000.00,
            // ... más parámetros
        ]
    ]
];
$response3 = http_post($url, $request3); // Misma URL
```

### Python

```python
import requests

# UN SOLO ENDPOINT
url = 'https://api.guadalajara.gob.mx/api/odoo'
token = 'eyJ0eXAiOiJKV1Q...'

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

# Función 1: Consultar
response1 = requests.post(url, headers=headers, json={
    'eRequest': {
        'Funcion': 'Consulta',  # ← Solo esto cambia
        'Parametros': {
            'Idinterfaz': 8,
            'cta_01': '12345678'
        }
    }
})

# Función 2: Ver adeudos (MISMO endpoint)
response2 = requests.post(url, headers=headers, json={
    'eRequest': {
        'Funcion': 'AdeudoDetalle',  # ← Solo esto cambia
        'Parametros': {
            'Idinterfaz': 8,
            'cta_01': '12345678'
        }
    }
})

# Función 3: Registrar pago (MISMO endpoint)
response3 = requests.post(url, headers=headers, json={
    'eRequest': {
        'Funcion': 'Pago',  # ← Solo esto cambia
        'Parametros': {
            'Idinterfaz': 8,
            'referencia_pago': 'REF-123',
            'monto_certificado': 5000.00,
            # ... más parámetros
        }
    }
})
```

---

## En Swagger UI

Cuando abra Swagger UI, verá:

```
▼ JWT Authentication
  ├─ POST /api/odoo/auth/token        ← Endpoint 1
  ├─ POST /api/odoo/auth/validate     ← Endpoint 2
  ├─ POST /api/odoo/auth/refresh      ← Endpoint 3
  └─ GET  /api/odoo/auth/info         ← Endpoint 4

▼ Odoo Integration
  └─ POST /api/odoo                    ← Endpoint 5 (hace todo)
      │
      └─ En el cuerpo del request selecciona:
         - "Funcion": "Consulta"
         - "Funcion": "Pago"
         - "Funcion": "Cancelacion"
         - etc... (18 opciones)
```

---

## Resumen Ultra Corto

**5 endpoints en total:**
- 4 para JWT (diferentes URLs)
- 1 para Odoo (18 funciones en la misma URL)

**El endpoint de Odoo:**
- URL: Siempre `POST /api/odoo`
- Cambia: El campo `"Funcion"`
- Parámetros: Dependen de la función elegida

**NO confundir:**
- ❌ 18 endpoints diferentes para Odoo
- ✅ 1 endpoint con 18 funciones

---

## Analogía Final

**Imagina una pizzería:**

### Modelo A (múltiples endpoints):
```
Pizzería con 18 ventanillas:
- Ventanilla 1: Pizza Hawaiana
- Ventanilla 2: Pizza Pepperoni
- Ventanilla 3: Pizza Vegetariana
... (18 ventanillas)

Para pedir, vas a la ventanilla específica.
```

### Modelo B (endpoint único - NUESTRO CASO):
```
Pizzería con 1 ventanilla:
- Ventanilla única

Para pedir, dices:
"Quiero una Pizza Hawaiana"
"Quiero una Pizza Pepperoni"
"Quiero una Pizza Vegetariana"

La misma ventanilla te atiende todos los pedidos.
```

**El API de Odoo usa el Modelo B:**
- Una ventanilla (endpoint): `/api/odoo`
- 18 tipos de pizza (funciones): "Consulta", "Pago", etc.
- Tú dices qué quieres (campo `Funcion`)

---

## Checklist de Comprensión

Después de leer este documento, debes poder responder:

- [ ] ¿Cuántos endpoints tiene el API de Odoo en total? (5)
- [ ] ¿Cuántos endpoints son para JWT? (4)
- [ ] ¿Cuántos endpoints son para operaciones Odoo? (1)
- [ ] ¿Cuál es el endpoint para consultar? (`POST /api/odoo`)
- [ ] ¿Cuál es el endpoint para pagar? (`POST /api/odoo`)
- [ ] ¿Qué cambia entre consultar y pagar? (El campo `"Funcion"`)
- [ ] ¿Dónde va el nombre de la función? (En `eRequest.Funcion`)
- [ ] ¿Cuántas funciones tiene el endpoint de Odoo? (18)

---

**Si aún tienes dudas, contacta:** soporte@guadalajara.gob.mx

---

**Creado:** 11 de febrero de 2025
**Versión:** 1.0
