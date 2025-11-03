# API de Integración Odoo

## 📋 Descripción

API REST moderna para integración con Odoo que migra los servicios SOAP legacy a una arquitectura REST con formato JSON puro.

## 🚀 Características

- ✅ **Endpoint único** para todas las funciones
- ✅ **Autenticación por token**
- ✅ **Validaciones automáticas** por función
- ✅ **Formato JSON puro** (request y response)
- ✅ **Documentación Swagger** integrada
- ✅ **Logging completo** de todas las operaciones
- ✅ **Manejo de errores** estandarizado
- ✅ **18 funciones** migradas del SOAP original

## 📍 Endpoint

```
POST /api/odoo
```

## 🔑 Autenticación

Todas las peticiones requieren un token de autenticación que puede ser enviado de dos formas:

1. **En el header** (recomendado):
```http
Authorization: Bearer odoo-token-2025
```

2. **En el request body**:
```json
{
  "eRequest": {
    "Token": "odoo-token-2025",
    ...
  }
}
```

## 📊 Estructura del Request

```json
{
  "eRequest": {
    "Funcion": "Nombre de la función",
    "Token": "odoo-token-2025",
    "Parametros": {
      // Parámetros específicos de cada función
    }
  }
}
```

## 📊 Estructura del Response

```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      // Datos específicos de cada función
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

## 📚 Funciones Disponibles

### 1. Consulta
**Descripción:** Consulta datos generales de una cuenta

**Request:**
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "cta_02": "",
      "cta_03": "",
      "cta_04": "",
      "cta_05": "",
      "cta_06": "",
      "referencia_pago": "REF123456789"
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

**Validaciones:**
- `Idinterfaz`: requerido, integer
- `cta_01`: opcional, string
- `referencia_pago`: opcional, string

---

### 2. DatosVarios
**Descripción:** Obtiene datos complementarios de la cuenta

**Request:**
```json
{
  "eRequest": {
    "Funcion": "DatosVarios",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123456789"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {"campo": "tipo_predio", "valor": "CASA HABITACION"},
      {"campo": "metros_construccion", "valor": "150"}
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

### 3. AdeudoDetalle
**Descripción:** Detalle de adeudos por concepto

**Request:**
```json
{
  "eRequest": {
    "Funcion": "AdeudoDetalle",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123456789"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": [
      {
        "cta_aplicacion": 1,
        "referencia_pago": "REF123456789",
        "descripcion": "IMPUESTO PREDIAL 2024",
        "importe": 5000.50,
        "acumulado": 5000.50
      },
      {
        "cta_aplicacion": 2,
        "referencia_pago": "REF123456789",
        "descripcion": "RECARGOS",
        "importe": 250.25,
        "acumulado": 5250.75
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

### 4. Pago
**Descripción:** Registra un pago realizado

**Request:**
```json
{
  "eRequest": {
    "Funcion": "Pago",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123456789",
      "monto_certificado": 5250.75,
      "monto_cartera": 5250.75,
      "monto_redondeo": 0.25,
      "id_cobro": 123456,
      "folio_recibo": "REC-2025-001234",
      "fecha_pago": "2025-02-11",
      "recaudadora": 1,
      "centro": 1,
      "caja": "CAJA01",
      "cc_lugar_pago": "GUADALAJARA",
      "cc_fecha_pago": "2025-02-11 10:30:00",
      "cc_referencia": "REF-BANCO-001",
      "cc_forma_pago": "EFECTIVO"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "codigo": 0,
      "mensaje": "PAGO REGISTRADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

**Validaciones:**
- `Idinterfaz`: requerido, integer
- `referencia_pago`: requerido, string
- `monto_certificado`: requerido, numeric
- `monto_cartera`: requerido, numeric
- `id_cobro`: requerido, integer
- `folio_recibo`: requerido, string
- `fecha_pago`: requerido, string (YYYY-MM-DD)
- `recaudadora`: requerido, integer
- `centro`: requerido, integer
- `caja`: requerido, string

---

### 5. Cancelacion
**Descripción:** Cancela un pago previamente registrado

**Request:**
```json
{
  "eRequest": {
    "Funcion": "Cancelacion",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "id_cobro": 123456,
      "folio_recibo": "REC-2025-001234"
    }
  }
}
```

**Response:**
```json
{
  "eResponse": {
    "success": true,
    "data": {
      "codigo": 0,
      "mensaje": "PAGO CANCELADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

### Otras Funciones

Las siguientes funciones están disponibles con sus respectivas validaciones:

- **ConsCuenta** - Consultar cuenta predial
- **CatDescuentos** - Catálogo de descuentos
- **ListDescuentos** - Listar descuentos aplicados
- **AltaDescuentos** - Registrar descuento
- **CancelDescuentos** - Cancelar descuento
- **ConsDesctoTablet** - Consulta para tablets
- **AltaDesctoTablet** - Alta desde tablet
- **FechasPendientesEl** - Fechas pendientes de integrar
- **PendientesXIntegrar** - Recibos pendientes
- **DetallesXIntegrar** - Detalle de pendientes
- **ActualizarPendientes** - Actualizar estado
- **LicenciaVisor** - Licencia codificada
- **AdeudoDetalleInmovilizadores** - Adeudos inmovilizadores

Para ejemplos completos de todas las funciones, ver el archivo:
```
storage/docs/odoo-api-examples.json
```

## 🔌 Interfaces Soportadas

| ID | Módulo | Descripción |
|----|--------|-------------|
| 8-15, 18-19, 22-23, 25, 30 | Informix | Predial, Licencias, Aseo (normalizados a 8) |
| 16 | Movilidad | Infracciones de tránsito |
| 17 | Obras | Licencias de construcción |
| 32 | Infracciones | Reglamentos municipales |
| 88 | SICAM | Predial nuevo |

## ⚠️ Códigos de Error

| Código | Descripción |
|--------|-------------|
| 0 | Operación exitosa |
| 400 | Petición inválida - Parámetros faltantes o inválidos |
| 401 | Token inválido o expirado |
| 500 | Error interno del servidor |
| 1001 | Error de negocio (cuenta no encontrada, referencia inválida, etc.) |

## 🔧 Configuración

### Variables de Entorno

Agregar en `.env`:

```env
# Tokens válidos (separados por coma)
ODOO_VALID_TOKENS=odoo-token-2025,odoo-prod-token

# Habilitar logging
ODOO_ENABLE_LOGGING=true

# Timeout de consultas (segundos)
ODOO_DB_TIMEOUT=30

# Modo mantenimiento
ODOO_MAINTENANCE_MODE=false
```

## 📝 Logs

Los logs se guardan en:
```
storage/logs/laravel.log
```

Cada operación registra:
- Request completo
- Parámetros enviados
- Query SQL ejecutado
- Response generado
- Errores (si los hay)

## 🧪 Testing con Postman

### Ejemplo de petición:

**URL:** `POST http://localhost:8000/api/odoo`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer odoo-token-2025
```

**Body:**
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123456789"
    }
  }
}
```

## 📖 Documentación Swagger

La documentación interactiva de Swagger está disponible en:
```
http://localhost:8000/api/documentation
```

## 🔄 Migración desde SOAP

Este API reemplaza los servicios SOAP ubicados en:
- `Doc/Odoo/wsODOO/wsgbOdoo.php`
- `Doc/Odoo/wsODOO/wsgbOdooTest.php`

### Mapeo de funciones SOAP a REST:

| Función SOAP | Función REST | Endpoint |
|--------------|--------------|----------|
| Consulta() | Consulta | POST /api/odoo |
| DatosVarios() | DatosVarios | POST /api/odoo |
| AdeudoDetalle() | AdeudoDetalle | POST /api/odoo |
| Pago() | Pago | POST /api/odoo |
| Cancelacion() | Cancelacion | POST /api/odoo |
| ... | ... | ... |

**Diferencias principales:**
1. SOAP → REST (JSON)
2. Múltiples endpoints → Endpoint único
3. WSDL → Swagger
4. Arrays XML → Arrays JSON
5. Sin autenticación → Token requerido

## 🛡️ Seguridad

- ✅ Validación de tokens
- ✅ Validación de parámetros
- ✅ Sanitización de inputs
- ✅ Prepared statements (PDO)
- ✅ Logging de operaciones
- ✅ Manejo seguro de errores

## 📞 Soporte

Para preguntas o problemas:
1. Revisar logs en `storage/logs/laravel.log`
2. Verificar configuración en `config/odoo.php`
3. Consultar ejemplos en `storage/docs/odoo-api-examples.json`

## 📄 Licencia

Propiedad de Gobierno de Guadalajara - RefactorX
