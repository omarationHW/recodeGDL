# 📋 Ejemplos JSON - API Odoo

## Copy & Paste Ready - Todos los Request/Response

---

## 1. Consulta

### Request
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

### Response
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

---

## 2. DatosVarios

### Request
```json
{
  "eRequest": {
    "Funcion": "DatosVarios",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "cta_02": "",
      "referencia_pago": "REF123456789"
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "campo": "tipo_predio",
        "valor": "CASA HABITACION"
      },
      {
        "campo": "metros_construccion",
        "valor": "150"
      },
      {
        "campo": "metros_terreno",
        "valor": "200"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 3. AdeudoDetalle

### Request
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

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
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

## 4. AdeudoDetalleInmovilizadores

### Request
```json
{
  "eRequest": {
    "Funcion": "AdeudoDetalleInmovilizadores",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 16,
      "cta_01": "ABC123XYZ",
      "referencia_pago": "INF987654"
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "cta_aplicacion": 1,
        "referencia_pago": "INF987654",
        "descripcion": "INFRACCION ESTACIONAMIENTO",
        "importe": 1500.00,
        "acumulado": 1500.00
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 5. Pago

### Request
```json
{
  "eRequest": {
    "Funcion": "Pago",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "cta_02": "",
      "cta_03": "",
      "cta_04": "",
      "cta_05": "",
      "cta_06": "",
      "referencia_pago": "REF123456789",
      "pago_tarjeta": "1234567890123456",
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
      "cc_forma_pago": "EFECTIVO",
      "adicional_1": ""
    }
  }
}
```

### Response
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

---

## 6. Cancelacion

### Request
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

### Response
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

---

## 7. ConsCuenta

### Request
```json
{
  "eRequest": {
    "Funcion": "ConsCuenta",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idcuenta": 123456
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "recaudadora": 1,
      "tipo": "P",
      "cuenta": 12345678
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 8. CatDescuentos

### Request
```json
{
  "eRequest": {
    "Funcion": "CatDescuentos",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idcuenta": 123456
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "IdDescuento": 1,
        "descripcion": "DESCUENTO ADULTO MAYOR",
        "porcentaje": "50"
      },
      {
        "IdDescuento": 2,
        "descripcion": "DESCUENTO PERSONAS CON DISCAPACIDAD",
        "porcentaje": "100"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 9. ListDescuentos

### Request
```json
{
  "eRequest": {
    "Funcion": "ListDescuentos",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idcuenta": 123456
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "IdDescuento": 1,
        "descripcion": "DESCUENTO ADULTO MAYOR",
        "bimini": "2024-01",
        "bimfin": "2024-06",
        "fechaAlta": "2024-01-15",
        "propietario": "JUAN PEREZ GARCIA",
        "folioDescto": "DCTO-2024-001"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 10. AltaDescuentos

### Request
```json
{
  "eRequest": {
    "Funcion": "AltaDescuentos",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idcuenta": 123456,
      "IdDescuento": 1,
      "bimini": "2025-01",
      "bimfin": "2025-06",
      "propietario": "JUAN PEREZ GARCIA",
      "solicitante": "JUAN PEREZ GARCIA",
      "recaudadora": "1",
      "folioDescto": "DCTO-2025-001",
      "identificacion": "INE123456789",
      "fechaNacimiento": "1950-05-20"
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "DESCUENTO REGISTRADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 11. CancelDescuentos

### Request
```json
{
  "eRequest": {
    "Funcion": "CancelDescuentos",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idcuenta": 123456,
      "IdDescuento": 1
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "DESCUENTO CANCELADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 12. ConsDesctoTablet

### Request
```json
{
  "eRequest": {
    "Funcion": "ConsDesctoTablet",
    "Token": "odoo-token-2025",
    "Parametros": {
      "recaudadora": 1,
      "tipo": "P",
      "cuenta": 12345678
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "IdDescuento": 1,
      "descripcion": "DESCUENTO ADULTO MAYOR",
      "Idcuenta": 123456,
      "rfc": "PEGJ800101XXX",
      "curp": "PEGJ800101HJCRNS01",
      "codigo": 0,
      "mensaje": "OK"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 13. AltaDesctoTablet

### Request
```json
{
  "eRequest": {
    "Funcion": "AltaDesctoTablet",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Id_descto_actual": 100,
      "Idcuenta": 123456,
      "IdDescto_Nvo": 2,
      "rfc": "PEGJ800101XXX",
      "curp": "PEGJ800101HJCRNS01",
      "usuario": "USUARIO01",
      "reca": 1
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "DESCUENTO ACTUALIZADO DESDE TABLET"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 14. FechasPendientesEl

### Request
```json
{
  "eRequest": {
    "Funcion": "FechasPendientesEl",
    "Token": "odoo-token-2025",
    "Parametros": {}
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "fecha": "2025-02-10",
        "tipoCartera": "PREDIAL",
        "modulo": 1,
        "lugarPago": "CENTRO",
        "idLugarPago": 1,
        "registros": 150
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 15. PendientesXIntegrar

### Request
```json
{
  "eRequest": {
    "Funcion": "PendientesXIntegrar",
    "Token": "odoo-token-2025",
    "Parametros": {
      "fecha": "2025-02-10",
      "lugarPago": 1,
      "modulo": 1
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "idRegistro": 1001,
        "operacion": 1,
        "importe": 5250.75,
        "interfase": 8,
        "nombre": "JUAN PEREZ GARCIA",
        "concepto": "PREDIAL"
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 16. DetallesXIntegrar

### Request
```json
{
  "eRequest": {
    "Funcion": "DetallesXIntegrar",
    "Token": "odoo-token-2025",
    "Parametros": {
      "idRegistro": 1001
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": [
      {
        "concepto": "IMPUESTO PREDIAL",
        "cuenta": 1,
        "importe": 5000.50
      },
      {
        "concepto": "RECARGOS",
        "cuenta": 2,
        "importe": 250.25
      }
    ],
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 17. ActualizarPendientes

### Request
```json
{
  "eRequest": {
    "Funcion": "ActualizarPendientes",
    "Token": "odoo-token-2025",
    "Parametros": {
      "idRegistro": 1001,
      "operacion": 1,
      "folio_recibo": "REC-2025-001234"
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "codigo": 0,
      "mensaje": "REGISTRO ACTUALIZADO EXITOSAMENTE"
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 18. LicenciaVisor

### Request
```json
{
  "eRequest": {
    "Funcion": "LicenciaVisor",
    "Token": "odoo-token-2025",
    "Parametros": {
      "licencia": 123456
    }
  }
}
```

### Response
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "licencia_codificada": "TElDRU5DSUEtQ09ESUZJQ0FEQS0xMjM0NTY="
    },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 🔄 Plantilla Base

Use esta plantilla para cualquier función:

```json
{
  "eRequest": {
    "Funcion": "[NOMBRE_FUNCION]",
    "Token": "odoo-token-2025",
    "Parametros": {
      // Agregar parámetros aquí
    }
  }
}
```

---

## 📞 Endpoint

```
POST http://localhost:8000/api/odoo
```

Headers:
```
Content-Type: application/json
```

---

**¡Listo para copiar y pegar!** 📋
