# 📋 Ejemplos JWT - Copy & Paste Ready

## 🔑 1. Generar Token

### Request
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025"
}
```

### cURL
```bash
curl -X POST http://localhost:8000/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "odoo-client-001",
    "client_secret": "mi-super-secreto-produccion-2025"
  }'
```

### Response
```json
{
  "success": true,
  "message": "Token generado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDc2NTIyMDAsImV4cCI6MTcwNzczODYwMCwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDAwIiwiZGF0YSI6eyJjbGllbnRfaWQiOiJvZG9vLWNsaWVudC0wMDEiLCJjbGllbnRfbmFtZSI6IiIsInBlcm1pc3Npb25zIjpbXSwidHlwZSI6Im9kb29faW50ZWdyYXRpb24ifX0.XYZ123...",
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

---

## ✅ 2. Validar Token

### Request
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### cURL
```bash
curl -X POST http://localhost:8000/api/odoo/auth/validate \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }'
```

### Response (Válido)
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

### Response (Expirado)
```json
{
  "success": false,
  "message": "Token inválido o expirado"
}
```

---

## 🔄 3. Refrescar Token

### Request
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### cURL
```bash
curl -X POST http://localhost:8000/api/odoo/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }'
```

### Response
```json
{
  "success": true,
  "message": "Token refrescado exitosamente",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.NEW_TOKEN...",
  "type": "Bearer",
  "expires_in": 86400,
  "expires_at": "2025-02-13 10:30:00"
}
```

---

## ℹ️ 4. Información JWT

### cURL
```bash
curl -X GET http://localhost:8000/api/odoo/auth/info
```

### Response
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

## 🔐 5. Usar Token en Servicio Odoo

### Opción A: Con Header (Recomendado)

```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..." \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678",
        "referencia_pago": "REF123"
      }
    }
  }'
```

### Opción B: Con Token en Body

```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678"
      }
    }
  }'
```

---

## 📦 Postman Collection

### 1. Generar Token

**POST** `{{base_url}}/api/odoo/auth/token`

Headers:
```
Content-Type: application/json
```

Body (raw JSON):
```json
{
  "client_id": "odoo-client-001",
  "client_secret": "mi-super-secreto-produccion-2025"
}
```

Tests (guardar token):
```javascript
var jsonData = pm.response.json();
pm.environment.set("jwt_token", jsonData.token);
```

---

### 2. Usar Token en Consulta

**POST** `{{base_url}}/api/odoo`

Headers:
```
Content-Type: application/json
Authorization: Bearer {{jwt_token}}
```

Body (raw JSON):
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

## 🐍 Python Example

```python
import requests
import json

# Base URL
BASE_URL = "http://localhost:8000/api"

# 1. Generar token
token_response = requests.post(
    f"{BASE_URL}/odoo/auth/token",
    json={
        "client_id": "odoo-client-001",
        "client_secret": "mi-super-secreto-produccion-2025"
    }
)

token_data = token_response.json()
jwt_token = token_data['token']
print(f"Token: {jwt_token}")
print(f"Expira en: {token_data['expires_at']}")

# 2. Usar token en consulta
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {jwt_token}"
}

consulta_response = requests.post(
    f"{BASE_URL}/odoo",
    headers=headers,
    json={
        "eRequest": {
            "Funcion": "Consulta",
            "Parametros": {
                "Idinterfaz": 8,
                "cta_01": "12345678"
            }
        }
    }
)

print(consulta_response.json())

# 3. Refrescar token antes de que expire
refresh_response = requests.post(
    f"{BASE_URL}/odoo/auth/refresh",
    json={
        "token": jwt_token
    }
)

new_token = refresh_response.json()['token']
print(f"Nuevo token: {new_token}")
```

---

## 📱 JavaScript/Node.js Example

```javascript
const axios = require('axios');

const BASE_URL = 'http://localhost:8000/api';

async function main() {
  try {
    // 1. Generar token
    const tokenResponse = await axios.post(`${BASE_URL}/odoo/auth/token`, {
      client_id: 'odoo-client-001',
      client_secret: 'mi-super-secreto-produccion-2025'
    });

    const jwtToken = tokenResponse.data.token;
    console.log('Token generado:', jwtToken);
    console.log('Expira en:', tokenResponse.data.expires_at);

    // 2. Usar token en consulta
    const consultaResponse = await axios.post(
      `${BASE_URL}/odoo`,
      {
        eRequest: {
          Funcion: 'Consulta',
          Parametros: {
            Idinterfaz: 8,
            cta_01: '12345678'
          }
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${jwtToken}`
        }
      }
    );

    console.log('Resultado consulta:', consultaResponse.data);

    // 3. Refrescar token
    const refreshResponse = await axios.post(`${BASE_URL}/odoo/auth/refresh`, {
      token: jwtToken
    });

    const newToken = refreshResponse.data.token;
    console.log('Token refrescado:', newToken);

  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

main();
```

---

## ☕ PHP Example

```php
<?php

$baseUrl = 'http://localhost:8000/api';

// 1. Generar token
$ch = curl_init("$baseUrl/odoo/auth/token");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'client_id' => 'odoo-client-001',
    'client_secret' => 'mi-super-secreto-produccion-2025'
]));

$response = curl_exec($ch);
$tokenData = json_decode($response, true);
$jwtToken = $tokenData['token'];

echo "Token: $jwtToken\n";
echo "Expira: {$tokenData['expires_at']}\n";

curl_close($ch);

// 2. Usar token en consulta
$ch = curl_init("$baseUrl/odoo");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    "Authorization: Bearer $jwtToken"
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'eRequest' => [
        'Funcion' => 'Consulta',
        'Parametros' => [
            'Idinterfaz' => 8,
            'cta_01' => '12345678'
        ]
    ]
]));

$response = curl_exec($ch);
$consultaData = json_decode($response, true);

print_r($consultaData);

curl_close($ch);

// 3. Refrescar token
$ch = curl_init("$baseUrl/odoo/auth/refresh");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'token' => $jwtToken
]));

$response = curl_exec($ch);
$refreshData = json_decode($response, true);
$newToken = $refreshData['token'];

echo "Nuevo token: $newToken\n";

curl_close($ch);
?>
```

---

## 🔧 Configuración .env

```env
# JWT Configuration
JWT_SECRET=kJ8$mP2#xL9@qR5&wT3^nV7!bC1*fG4%hD6yN0-change-me
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# Clientes autorizados
ODOO_CLIENT_001_SECRET=mi-super-secreto-produccion-2025
ODOO_CLIENT_DEV_SECRET=secreto-desarrollo-xyz789
ODOO_CLIENT_TEST_SECRET=secreto-pruebas-abc123
```

---

## ⚡ Quick Commands

### Generar token
```bash
curl -X POST http://localhost:8000/api/odoo/auth/token \
  -H "Content-Type: application/json" \
  -d '{"client_id":"odoo-client-001","client_secret":"mi-super-secreto-produccion-2025"}'
```

### Validar token
```bash
curl -X POST http://localhost:8000/api/odoo/auth/validate \
  -H "Content-Type: application/json" \
  -d '{"token":"TU_TOKEN_AQUI"}'
```

### Refrescar token
```bash
curl -X POST http://localhost:8000/api/odoo/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"token":"TU_TOKEN_AQUI"}'
```

### Info JWT
```bash
curl -X GET http://localhost:8000/api/odoo/auth/info
```

---

**¡Listo para copiar y pegar!** 📋✅
