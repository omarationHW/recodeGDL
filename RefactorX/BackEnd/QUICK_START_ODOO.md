# 🚀 Quick Start - API Odoo

## ⚡ Inicio Rápido en 5 Minutos

### 1️⃣ Configurar Token (1 min)

Agregar en `.env`:
```env
ODOO_VALID_TOKENS=odoo-token-2025
```

### 2️⃣ Probar Endpoint (1 min)

**Con curl:**
```bash
curl -X POST http://localhost:8000/api/odoo \
  -H "Content-Type: application/json" \
  -d '{
    "eRequest": {
      "Funcion": "Consulta",
      "Token": "odoo-token-2025",
      "Parametros": {
        "Idinterfaz": 8,
        "cta_01": "12345678"
      }
    }
  }'
```

**Con Postman:**
1. Método: `POST`
2. URL: `http://localhost:8000/api/odoo`
3. Headers: `Content-Type: application/json`
4. Body (raw JSON):
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678"
    }
  }
}
```

### 3️⃣ Ver Respuesta

```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": { ... },
    "timestamp": "2025-02-11T10:30:00Z"
  }
}
```

---

## 📋 Funciones Más Usadas

### 1. Consultar Cuenta
```json
{
  "eRequest": {
    "Funcion": "Consulta",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678",
      "referencia_pago": "REF123"
    }
  }
}
```

### 2. Ver Adeudos
```json
{
  "eRequest": {
    "Funcion": "AdeudoDetalle",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "cta_01": "12345678"
    }
  }
}
```

### 3. Registrar Pago
```json
{
  "eRequest": {
    "Funcion": "Pago",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "referencia_pago": "REF123",
      "monto_certificado": 1000.00,
      "monto_cartera": 1000.00,
      "id_cobro": 12345,
      "folio_recibo": "REC-001",
      "fecha_pago": "2025-02-11",
      "recaudadora": 1,
      "centro": 1,
      "caja": "CAJA01"
    }
  }
}
```

### 4. Cancelar Pago
```json
{
  "eRequest": {
    "Funcion": "Cancelacion",
    "Token": "odoo-token-2025",
    "Parametros": {
      "Idinterfaz": 8,
      "id_cobro": 12345,
      "folio_recibo": "REC-001"
    }
  }
}
```

---

## 🔧 Debugging

### Ver logs en tiempo real:
```bash
tail -f storage/logs/laravel.log
```

### Limpiar logs:
```bash
echo "" > storage/logs/laravel.log
```

### Ver todas las funciones disponibles:
```bash
curl -X GET http://localhost:8000/api/odoo
```

---

## ⚠️ Troubleshooting

### Error: "Token inválido"
**Solución:** Verificar que el token en `.env` coincida con el del request.

### Error: "Función no encontrada"
**Solución:** Verificar el nombre exacto en el campo `Funcion`. Es case-sensitive.

### Error: "Parámetros inválidos"
**Solución:** Revisar validaciones en `storage/docs/odoo-api-examples.json`

### Error: "Stored Procedure no existe"
**Solución:** Verificar que el SP esté creado en la base de datos correcta.

---

## 📚 Documentación Completa

- **README completo:** `README_ODOO_API.md`
- **Ejemplos JSON:** `storage/docs/odoo-api-examples.json`
- **Resumen implementación:** `RESUMEN_IMPLEMENTACION_ODOO.md`

---

## 🎯 Interfaces Rápidas

| Interface | Uso |
|-----------|-----|
| 8 | Predial, Licencias, Aseo |
| 16 | Infracciones de Tránsito |
| 17 | Licencias de Obra |
| 32 | Reglamentos Municipales |
| 88 | Predial SICAM |

---

## ✅ Checklist de Implementación

- [ ] Configurar token en `.env`
- [ ] Crear stored procedures en PostgreSQL
- [ ] Probar función "Consulta"
- [ ] Probar función "Pago"
- [ ] Configurar logging
- [ ] Revisar documentación completa

---

**¡Listo para usar!** 🚀

Para más detalles, ver `README_ODOO_API.md`
