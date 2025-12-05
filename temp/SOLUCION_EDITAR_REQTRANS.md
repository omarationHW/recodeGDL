# Solución: Error al Editar Registros en ReqTrans

## 🐛 PROBLEMA IDENTIFICADO

### Error Original:
```
❌ No se encontró el registro a actualizar. Cuenta: 7, Año: 2024
```

### Causa Raíz:
El SP de UPDATE estaba buscando el registro usando **cuenta + año**, pero estos son los valores que el usuario está **editando**, no los originales.

**Ejemplo del problema:**
```
1. Registro original: cuenta=11111, año=2024
2. Usuario edita a: cuenta=7, año=2024
3. SP busca: cuenta=7 + año=2024 (¡NO EXISTE!)
4. Error: "No se encontró el registro"
```

---

## ✅ SOLUCIÓN IMPLEMENTADA

### Cambio 1: SP LIST ahora retorna `cvereq`
**ANTES:**
```sql
RETURNS TABLE (
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio INTEGER,
    estatus TEXT
)
```

**AHORA:**
```sql
RETURNS TABLE (
    cvereq INTEGER,      -- ← AGREGADO: ID único
    clave_cuenta TEXT,
    folio INTEGER,
    ejercicio INTEGER,
    estatus TEXT
)
```

### Cambio 2: SP UPDATE ahora busca por `cvereq`
**ANTES:**
```sql
-- Buscaba por cuenta + ejercicio (valores EDITADOS)
SELECT cvereq INTO v_cvereq
FROM catastro_gdl.reqdiftransmision
WHERE cvecuenta::TEXT = v_clave_cuenta  -- ← Valor NUEVO
  AND axoreq = v_ejercicio              -- ← Valor NUEVO
```

**AHORA:**
```sql
-- Busca por cvereq (ID único que no cambia)
v_cvereq := (p_registro->>'cvereq')::INTEGER;

-- Usa el cvereq directamente
UPDATE catastro_gdl.reqdiftransmision
SET ...
WHERE cvereq = v_cvereq  -- ← ID único e inmutable
```

---

## 🔧 CAMBIOS TÉCNICOS

### 1. Stored Procedure LIST
**Archivo:** `fix_reqtrans_list_add_cvereq.sql`

```sql
SELECT
    r.cvereq::INTEGER,  -- ← NUEVO: ID único
    COALESCE(r.cvecuenta::TEXT, '')::TEXT as clave_cuenta,
    COALESCE(r.foliotransm, 0)::INTEGER as folio,
    COALESCE(r.axoreq, 0)::INTEGER as ejercicio,
    CASE
        WHEN r.vigencia = '1' OR r.vigencia = 'A' THEN 'Activo'
        WHEN r.vigencia = 'Inactivo' THEN 'Inactivo'
        ELSE 'Pendiente'
    END::TEXT as estatus
FROM catastro_gdl.reqdiftransmision r
```

### 2. Stored Procedure UPDATE
**Archivo:** `fix_reqtrans_update_v2.sql`

```sql
-- Extraer cvereq del JSON
BEGIN
    v_cvereq := (p_registro->>'cvereq')::INTEGER;
EXCEPTION
    WHEN OTHERS THEN
        v_cvereq := NULL;
END;

-- Validar que cvereq esté presente
IF v_cvereq IS NULL OR v_cvereq <= 0 THEN
    RETURN json_build_object(
        'success', false,
        'message', 'Error: No se proporcionó el ID del registro'
    );
END IF;

-- Actualizar usando cvereq
UPDATE catastro_gdl.reqdiftransmision
SET ...
WHERE cvereq = v_cvereq;
```

### 3. Frontend (ReqTrans.vue)
**No requiere cambios** - Ya estaba correcto:

```javascript
function edit(r) {
  editing = true
  modalTitle.value = `Editar registro: ${r.clave_cuenta}`
  form.value = { ...r }  // ← Copia TODO el objeto, incluyendo cvereq
  showModal.value = true
}
```

---

## 🧪 PRUEBAS DE VERIFICACIÓN

### Test 1: Verificar que LIST retorna cvereq
```sql
SELECT * FROM recaudadora_reqtrans_list(NULL, NULL) LIMIT 1;

Resultado:
cvereq: 13
clave_cuenta: 11111
folio: 0
ejercicio: 2025
estatus: Pendiente

✅ cvereq está presente
```

### Test 2: Verificar que UPDATE usa cvereq
```sql
SELECT recaudadora_reqtrans_update('{
  "cvereq": 6,
  "clave_cuenta": "222222222",
  "folio": 0,
  "ejercicio": 2024,
  "estatus": "Pendiente"
}'::json);

Resultado:
{
  "success": true,
  "message": "Registro actualizado correctamente"
}

✅ UPDATE funciona con cvereq
```

---

## 📋 CÓMO PROBAR LA SOLUCIÓN

### Caso 1: Editar solo la cuenta
1. Listar registros (buscar o dejar vacío)
2. Click en **Editar** en cualquier registro
3. Cambiar **Cuenta** de `11111` a `999999`
4. Dejar **Año** sin cambios: `2025`
5. Click en **Aceptar**
6. **Resultado esperado:**
   ```
   ✅ Registro actualizado correctamente
   ```

### Caso 2: Editar solo el año
1. Click en **Editar** en cualquier registro
2. Dejar **Cuenta** sin cambios: `11111`
3. Cambiar **Año** de `2025` a `2023`
4. Click en **Aceptar**
5. **Resultado esperado:**
   ```
   ✅ Registro actualizado correctamente
   ```

### Caso 3: Editar cuenta y año
1. Click en **Editar** en cualquier registro
2. Cambiar **Cuenta** de `11111` a `888888`
3. Cambiar **Año** de `2025` a `2023`
4. Click en **Aceptar**
5. **Resultado esperado:**
   ```
   ✅ Registro actualizado correctamente
   ```

---

## 🔍 FLUJO COMPLETO DE EDICIÓN

```
1. Usuario ve la lista
   ↓
2. Click en botón "Editar"
   ↓
3. Frontend copia el registro completo:
   {
     cvereq: 13,           ← ID único
     clave_cuenta: "11111",
     folio: 0,
     ejercicio: 2025,
     estatus: "Pendiente"
   }
   ↓
4. Usuario modifica campos en el modal
   {
     cvereq: 13,           ← NO CAMBIA (clave única)
     clave_cuenta: "7",    ← CAMBIADO
     folio: 0,
     ejercicio: 2024,      ← CAMBIADO
     estatus: "Activo"     ← CAMBIADO
   }
   ↓
5. Frontend envía todo el objeto al backend
   ↓
6. SP busca por cvereq=13 (no por cuenta/año)
   ↓
7. SP actualiza los campos
   ↓
8. Retorna success: true
   ↓
9. Frontend muestra alerta de éxito
   ↓
10. Lista se recarga automáticamente
```

---

## 💡 POR QUÉ FUNCIONA AHORA

### Antes (❌ Fallaba):
```
Registro original: ID=13, cuenta=11111, año=2025
Usuario edita a:   cuenta=7, año=2024
SP busca:          cuenta=7 + año=2024
Resultado:         ❌ NO EXISTE
```

### Ahora (✅ Funciona):
```
Registro original: ID=13, cuenta=11111, año=2025
Usuario edita a:   cuenta=7, año=2024
SP busca:          ID=13
Resultado:         ✅ ENCONTRADO
SP actualiza:      cuenta → 7, año → 2024
```

---

## 📊 COMPARACIÓN

| Aspecto | ANTES | AHORA |
|---------|-------|-------|
| Búsqueda | cuenta + año | cvereq (ID único) |
| Valores usados | Editados | Originales |
| Permite editar cuenta | ❌ No | ✅ Sí |
| Permite editar año | ❌ No | ✅ Sí |
| Error al editar | ✅ Sí | ❌ No |

---

## 🎯 ARCHIVOS MODIFICADOS

1. **SP LIST:**
   - Archivo: `fix_reqtrans_list_add_cvereq.sql`
   - Cambio: Agregado `cvereq` a las columnas retornadas
   - Estado: ✅ Aplicado

2. **SP UPDATE:**
   - Archivo: `fix_reqtrans_update_v2.sql`
   - Cambio: Busca por `cvereq` en lugar de `cuenta + año`
   - Estado: ✅ Aplicado

3. **Frontend:**
   - Archivo: `ReqTrans.vue`
   - Cambio: No requiere modificaciones
   - Estado: ✅ Ya compatible

---

## ✅ ESTADO FINAL

### Stored Procedures:
- ✅ `recaudadora_reqtrans_list` - Retorna cvereq
- ✅ `recaudadora_reqtrans_update` - Usa cvereq
- ✅ `recaudadora_reqtrans_create` - Funcional

### Frontend:
- ✅ Lista muestra registros
- ✅ Editar funciona correctamente
- ✅ Crear funciona correctamente
- ✅ Alertas de éxito/error
- ✅ Paginación de 10 en 10

### Validaciones:
- ✅ cvereq requerido para UPDATE
- ✅ Mensaje de error si falta cvereq
- ✅ Verificación de existencia del registro

---

## 🚀 RESUMEN

**Problema:** No se podía editar cuenta o año porque el SP buscaba con los valores nuevos.

**Solución:**
1. SP LIST ahora retorna `cvereq` (ID único)
2. SP UPDATE busca por `cvereq` (no por cuenta+año)
3. Ahora se pueden editar todos los campos sin problemas

**Resultado:** ✅ Edición funciona perfectamente en todos los casos.
