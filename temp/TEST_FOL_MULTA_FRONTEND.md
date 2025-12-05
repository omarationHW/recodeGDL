# PRUEBAS PARA FOL_MULTA - FRONTEND

## ✅ CORRECCIONES APLICADAS

### 1. Formato de Parámetros Corregido
**ANTES (incorrecto):**
```javascript
{name: 'clave_cuenta', type: 'C', value: '586'}
```

**AHORA (correcto):**
```javascript
{nombre: 'p_clave_cuenta', tipo: 'string', valor: '586'}
```

### 2. Palabra "null" Eliminada
**ANTES:** `result=ref(null)` - mostraba "null" al inicio
**AHORA:** `result=ref('')` - muestra vacío al inicio

---

## 📝 3 EJEMPLOS PARA PROBAR

### **EJEMPLO 1: Multa PAGADA** ✅
**Formulario:**
- **Cuenta:** `586`
- **Año:** `2002`

**Click en:** "Generar Folio"

**Resultado Esperado:**
```json
[
  {
    "folio": 1,
    "id_control": 1,
    "axo_acta": 2002,
    "numero_acta": 586,
    "nombre": "AL PROPIETARIO",
    "domicilio": "ABASCAL Y SOUZA 491",
    "actividad_giro": "",
    "importe_inicial": "200.00",
    "importe_pagar": "200.00",
    "vigencia": "P",
    "fecha_recepcion": "2002-02-07",
    "fecha_alta": "2002-01-23",
    "fecha_pago": "2002-02-04",
    "numero_licencia": 0,
    "sector": "J",
    "numero_zona": 1,
    "sub_zona": 999,
    "recaudadora": 1,
    "operacion": 6065,
    "importe_pago": "200.00",
    "estado": "PAGADO"
  }
]
```

---

### **EJEMPLO 2: Multa ACTIVA (sin pagar)** ⚠️
**Formulario:**
- **Cuenta:** `616`
- **Año:** `2002`

**Click en:** "Generar Folio"

**Resultado Esperado:**
```json
[
  {
    "folio": 2,
    "id_control": 2,
    "axo_acta": 2002,
    "numero_acta": 616,
    "nombre": "EMPRESAS DEPORTIVAS UNIDAS S.A",
    "domicilio": "ALVARO OBREGON 299",
    "actividad_giro": "",
    "importe_inicial": "1000.00",
    "importe_pagar": "1000.00",
    "vigencia": "A",
    "fecha_recepcion": "2002-03-14",
    "fecha_alta": "2002-01-10",
    "fecha_pago": null,
    "numero_licencia": 0,
    "sector": "R",
    "numero_zona": 1,
    "sub_zona": 5,
    "recaudadora": 0,
    "operacion": 0,
    "importe_pago": "0.00",
    "estado": "ACTIVO"
  }
]
```

---

### **EJEMPLO 3: Multa ACTIVA (importe alto)** ⚠️
**Formulario:**
- **Cuenta:** `619`
- **Año:** `2002`

**Click en:** "Generar Folio"

**Resultado Esperado:**
```json
[
  {
    "folio": 5,
    "id_control": 5,
    "axo_acta": 2002,
    "numero_acta": 619,
    "nombre": "FARMACIA GUADALAJARA",
    "domicilio": "ESTEBAN LOERA 201",
    "actividad_giro": "",
    "importe_inicial": "6210.00",
    "importe_pagar": "6210.00",
    "vigencia": "A",
    "fecha_recepcion": "2002-03-14",
    "fecha_alta": "2002-01-23",
    "fecha_pago": null,
    "numero_licencia": 0,
    "sector": "L",
    "numero_zona": 5,
    "sub_zona": 5,
    "recaudadora": 0,
    "operacion": 0,
    "importe_pago": "0.00",
    "estado": "ACTIVO"
  }
]
```

---

## 🎯 PASOS PARA PROBAR

1. **Recargar** la página del navegador (F5) para cargar los cambios
2. Abrir: http://localhost:3000/multas_reglamentos/FolMulta
3. Ingresar uno de los ejemplos arriba
4. Click en "Generar Folio"
5. Ver el resultado en el panel inferior

---

## 📊 CAMPOS IMPORTANTES

| Campo | Descripción |
|-------|-------------|
| `folio` | Número de folio único (id_control) |
| `numero_acta` | Número de acta de la multa |
| `nombre` | Nombre del contribuyente |
| `importe_pagar` | Cantidad a pagar |
| `estado` | PAGADO / ACTIVO / CANCELADO / PENDIENTE |
| `fecha_pago` | Fecha de pago (null si no está pagada) |

---

## ✨ CAMBIOS TÉCNICOS

### Frontend (FolMulta.vue)
```javascript
// Parámetros corregidos
const params=[
  {nombre:'p_clave_cuenta', tipo:'string', valor:String(form.value.clave_cuenta||'')},
  {nombre:'p_ejercicio', tipo:'integer', valor:Number(form.value.ejercicio||0)}
];

// Resultado inicializado vacío (no null)
const result=ref('')
```

### Backend (GenericController.php)
```php
// Schema db_ingresos agregado a allowed_schemas
'allowed_schemas' => ['public', 'comun', 'multas_reglamentos', 'db_ingresos']
```

### Database (SP desplegado)
```sql
-- Función en schema db_ingresos
db_ingresos.recaudadora_fol_multa(p_clave_cuenta VARCHAR, p_ejercicio INTEGER)
```

---

## 🚨 SOLUCIÓN DE PROBLEMAS

### Si sigue mostrando error:
1. Verificar que Vite recompilara (ver consola del terminal)
2. Hacer hard refresh: Ctrl+Shift+R (Windows) o Cmd+Shift+R (Mac)
3. Abrir DevTools (F12) → Console para ver errores
4. Verificar que el backend esté corriendo en puerto 8000

### Si no muestra resultados:
1. Verificar que la cuenta exista en la BD
2. Probar con los 3 ejemplos proporcionados (datos reales)
3. Revisar logs del backend: `tail -f storage/logs/laravel.log`
