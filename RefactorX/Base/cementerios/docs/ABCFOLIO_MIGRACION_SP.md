# DOCUMENTACIÓN DE MIGRACIÓN A SP - ABCFolio.vue

**Módulo:** Cementerios
**Componente:** ABCFolio.vue
**Fecha:** 2025-11-24
**Estado:** ✅ FUNCIONAL con Queries SQL directas
**Migración a SP:** ⏳ PENDIENTE

---

## 📋 RESUMEN

ABCFolio.vue actualmente usa **queries SQL directas** (como el Pascal original) debido a que **NO EXISTEN** los SP necesarios en:
- ❌ `RefactorX/Base/cementerios/database/ok/`
- ❌ `RefactorX/Base/db/sp/`

**Restricción aplicada:** No crear SP que no existan en las rutas permitidas.

---

## ✅ SP QUE SÍ EXISTEN Y SE USAN

| SP | Archivo | Uso en ABCFolio.vue |
|----|---------|---------------------|
| **sp_13_historia** | `01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql` | ✅ Línea 664, 837 - Guardar histórico |
| **spd_abc_adercm** | `01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql` | ✅ Línea 775, 873 - Recalcular adeudos |

**Base:** padron_licencias.public
**Opciones de spd_abc_adercm:**
- `par_opc = 1` → Alta (genera adeudos)
- `par_opc = 2` → Baja (marca adeudos como baja)
- `par_opc = 3` → Modificación (actualiza adeudos)

---

## ❌ SP FALTANTES (A CREAR EN EL FUTURO)

### 1. sp_get_cementerios_list

**Propósito:** Listar todos los cementerios activos
**Uso en Vue:** Línea 471 (`cargarCementerios()`)
**Query Pascal original:** ABCFolio.dfm línea 1479
```sql
SELECT * FROM tc_13_cementerios
```

**Especificación del SP:**
```sql
-- Base: cementerio.public (según postgreok.csv: tc_13_cementerios → cementerio.public)
CREATE OR REPLACE FUNCTION sp_get_cementerios_list()
RETURNS TABLE (
    cementerio VARCHAR,
    nombre VARCHAR,
    domicilio VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT cementerio, nombre, domicilio
    FROM tc_13_cementerios
    ORDER BY cementerio;
END;
$$;
```

**Implementación actual en Vue (línea 479-490):**
```javascript
const response = await execute(
  'SELECT',
  'cementerio',
  {
    table: 'tc_13_cementerios',
    fields: ['cementerio', 'nombre', 'domicilio'],
    orderBy: 'cementerio'
  },
  '',
  null,
  'public'
)
```

---

### 2. sp_abcf_get_folio

**Propósito:** Obtener datos completos de un folio con información de usuario
**Uso en Vue:** Línea 501 (`buscarFolio()`)
**Query Pascal original:** ABCFolio.dfm línea 1335-1337
```sql
SELECT a.*, c.nombre, c.id_rec
FROM ta_13_datosrcm a, ta_12_passwords c
WHERE control_rcm=:control AND a.usuario = c.id_usuario
```

**Especificación del SP:**
```sql
-- Base: padron_licencias.comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
CREATE OR REPLACE FUNCTION sp_abcf_get_folio(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    cementerio VARCHAR,
    clase SMALLINT,
    clase_alfa VARCHAR,
    seccion SMALLINT,
    seccion_alfa VARCHAR,
    linea SMALLINT,
    linea_alfa VARCHAR,
    fosa SMALLINT,
    fosa_alfa VARCHAR,
    axo_pagado INTEGER,
    metros FLOAT,
    nombre VARCHAR,
    domicilio VARCHAR,
    exterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    observaciones VARCHAR,
    usuario INTEGER,
    fecha_mov DATE,
    tipo VARCHAR,
    fecha_alta DATE,
    vigencia VARCHAR,
    usuario_nombre VARCHAR,
    id_rec SMALLINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.control_rcm, a.cementerio, a.clase, a.clase_alfa,
        a.seccion, a.seccion_alfa, a.linea, a.linea_alfa,
        a.fosa, a.fosa_alfa, a.axo_pagado, a.metros,
        a.nombre, a.domicilio, a.exterior, a.interior,
        a.colonia, a.observaciones, a.usuario, a.fecha_mov,
        a.tipo, a.fecha_alta, a.vigencia,
        c.nombre AS usuario_nombre, c.id_rec
    FROM comun.ta_13_datosrcm a
    LEFT JOIN comun.ta_12_passwords c ON a.usuario = c.id_usuario
    WHERE a.control_rcm = p_folio;
END;
$$;
```

**Implementación actual en Vue (línea 520-542):**
```javascript
const responsePrincipal = await execute(
  'SELECT',
  'padron_licencias',
  {
    table: 'ta_13_datosrcm a',
    fields: [
      'a.control_rcm', 'a.cementerio', 'a.clase', 'a.clase_alfa',
      // ... todos los campos ...
      'c.nombre as usuario_nombre', 'c.id_rec'
    ],
    joins: [
      { type: 'LEFT', table: 'ta_12_passwords c', on: 'a.usuario = c.id_usuario' }
    ],
    where: { 'a.control_rcm': folioBuscar.value }
  },
  '',
  null,
  'comun'
)
```

---

### 3. sp_abcf_get_adicional

**Propósito:** Obtener datos adicionales de un folio
**Uso en Vue:** Línea 584 (`buscarFolio()`)
**Query Pascal original:** ABCFolio.dfm línea 1619
```sql
SELECT * FROM ta_13_datosrcmadic WHERE control_rcm=:control_rcm
```

**Especificación del SP:**
```sql
-- Base: cementerio.public (según postgreok.csv: ta_13_datosrcmadic → cementerio.public)
CREATE OR REPLACE FUNCTION sp_abcf_get_adicional(p_folio INTEGER)
RETURNS TABLE (
    control_rcm INTEGER,
    rfc VARCHAR,
    curp VARCHAR,
    telefono VARCHAR,
    clave_ife VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT control_rcm, rfc, curp, telefono, clave_ife
    FROM public.ta_13_datosrcmadic
    WHERE control_rcm = p_folio;
END;
$$;
```

**Implementación actual en Vue (línea 592-603):**
```javascript
const responseAdicional = await execute(
  'SELECT',
  'cementerio',
  {
    table: 'ta_13_datosrcmadic',
    fields: ['control_rcm', 'rfc', 'curp', 'telefono', 'clave_ife'],
    where: { control_rcm: folioBuscar.value }
  },
  '',
  null,
  'public'
)
```

---

### 4. sp_abcf_update_folio

**Propósito:** Actualizar datos principales de un folio
**Uso en Vue:** Línea 632 (`guardarCambios()`)
**Query Pascal original:** ABCFolio.pas línea 197-228
```sql
UPDATE ta_13_datosrcm SET
    cementerio=..., clase=..., clase_alfa=..., seccion=...,
    [+20 campos más]
WHERE control_rcm=...
```

**Especificación del SP:**
```sql
-- Base: padron_licencias.comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
-- IMPORTANTE: Debe llamar internamente a sp_13_historia ANTES del UPDATE
CREATE OR REPLACE FUNCTION sp_abcf_update_folio(
    p_folio INTEGER,
    p_cementerio VARCHAR,
    p_clase SMALLINT,
    p_clase_alfa VARCHAR,
    p_seccion SMALLINT,
    p_seccion_alfa VARCHAR,
    p_linea SMALLINT,
    p_linea_alfa VARCHAR,
    p_fosa SMALLINT,
    p_fosa_alfa VARCHAR,
    p_axo_pagado INTEGER,
    p_metros FLOAT,
    p_nombre VARCHAR,
    p_domicilio VARCHAR,
    p_exterior VARCHAR,
    p_interior VARCHAR,
    p_colonia VARCHAR,
    p_observaciones VARCHAR,
    p_tipo VARCHAR,
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado VARCHAR,
    mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Guardar histórico ANTES de actualizar
    PERFORM sp_13_historia(p_folio);

    -- 2. Actualizar datos principales
    UPDATE comun.ta_13_datosrcm SET
        cementerio = p_cementerio,
        clase = p_clase,
        clase_alfa = p_clase_alfa,
        seccion = p_seccion,
        seccion_alfa = p_seccion_alfa,
        linea = p_linea,
        linea_alfa = p_linea_alfa,
        fosa = p_fosa,
        fosa_alfa = p_fosa_alfa,
        axo_pagado = p_axo_pagado,
        metros = p_metros,
        nombre = p_nombre,
        domicilio = p_domicilio,
        exterior = p_exterior,
        interior = p_interior,
        colonia = p_colonia,
        observaciones = p_observaciones,
        tipo = p_tipo,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;

    -- 3. Recalcular adeudos (opción 3 = modificación)
    PERFORM spd_abc_adercm(p_folio, 3, p_usuario);

    RETURN QUERY SELECT 'S'::VARCHAR, 'Folio actualizado correctamente'::VARCHAR;
END;
$$;
```

**Implementación actual en Vue (línea 664-786):**
```javascript
// 1. Guardar histórico
await execute('sp_13_historia', 'padron_licencias', { par_control: ... }, '', null, 'public')

// 2. UPDATE
await execute('UPDATE', 'padron_licencias', { table: 'ta_13_datosrcm', data: {...}, where: {...} }, '', null, 'comun')

// 3. INSERT/UPDATE adicionales
// ...

// 4. Recalcular adeudos
await execute('spd_abc_adercm', 'padron_licencias', { par_control, par_opc: 3, par_usu }, '', null, 'public')
```

---

### 5. sp_abcf_update_adicional

**Propósito:** Actualizar o insertar datos adicionales de un folio
**Uso en Vue:** Línea 712 (`guardarCambios()`)
**Query Pascal original:** ABCFolio.pas línea 249-277
```sql
-- Si no existe:
INSERT INTO ta_13_datosrcmadic VALUES(...)
-- Si existe:
UPDATE ta_13_datosrcmadic SET rfc=..., curp=..., telefono=..., clave_ife=... WHERE control_rcm=...
```

**Especificación del SP:**
```sql
-- Base: cementerio.public (según postgreok.csv: ta_13_datosrcmadic → cementerio.public)
CREATE OR REPLACE FUNCTION sp_abcf_update_adicional(
    p_folio INTEGER,
    p_rfc VARCHAR,
    p_curp VARCHAR,
    p_telefono VARCHAR,
    p_clave_ife VARCHAR
)
RETURNS TABLE (
    resultado VARCHAR,
    mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Verificar si ya existe
    SELECT EXISTS(SELECT 1 FROM public.ta_13_datosrcmadic WHERE control_rcm = p_folio) INTO v_exists;

    IF v_exists THEN
        -- UPDATE
        UPDATE public.ta_13_datosrcmadic SET
            rfc = p_rfc,
            curp = p_curp,
            telefono = p_telefono,
            clave_ife = p_clave_ife
        WHERE control_rcm = p_folio;
    ELSE
        -- INSERT
        INSERT INTO public.ta_13_datosrcmadic (control_rcm, rfc, curp, telefono, clave_ife)
        VALUES (p_folio, p_rfc, p_curp, p_telefono, p_clave_ife);
    END IF;

    RETURN QUERY SELECT 'S'::VARCHAR, 'Datos adicionales actualizados correctamente'::VARCHAR;
END;
$$;
```

**Implementación actual en Vue (línea 721-772):**
```javascript
// 1. Verificar si existe
const existeAdicional = await execute('SELECT', 'cementerio', { table: 'ta_13_datosrcmadic', fields: ['control_rcm'], where: {...} }, '', null, 'public')

if (existeAdicional?.result?.length > 0) {
  // UPDATE
  await execute('UPDATE', 'cementerio', { table: 'ta_13_datosrcmadic', data: {...}, where: {...} }, '', null, 'public')
} else {
  // INSERT
  await execute('INSERT', 'cementerio', { table: 'ta_13_datosrcmadic', data: {...} }, '', null, 'public')
}
```

---

### 6. sp_abcf_baja_folio

**Propósito:** Dar de baja lógica un folio (vigencia='B')
**Uso en Vue:** Línea 821 (`darDeBaja()`)
**Query Pascal original:** ABCFolio.pas línea 299-341
```sql
UPDATE ta_13_datosrcm SET vigencia='B', usuario=..., fecha_mov=TODAY WHERE control_rcm=...
```

**Especificación del SP:**
```sql
-- Base: padron_licencias.comun (según postgreok.csv: ta_13_datosrcm → padron_licencias.comun)
-- IMPORTANTE: Debe llamar internamente a sp_13_historia ANTES del UPDATE
CREATE OR REPLACE FUNCTION sp_abcf_baja_folio(
    p_folio INTEGER,
    p_usuario INTEGER
)
RETURNS TABLE (
    resultado VARCHAR,
    mensaje VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Guardar histórico ANTES de la baja
    PERFORM sp_13_historia(p_folio);

    -- 2. Actualizar vigencia a 'B'
    UPDATE comun.ta_13_datosrcm SET
        vigencia = 'B',
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE control_rcm = p_folio;

    -- 3. Actualizar adeudos (opción 2 = baja)
    PERFORM spd_abc_adercm(p_folio, 2, p_usuario);

    RETURN QUERY SELECT 'S'::VARCHAR, 'Folio dado de baja correctamente'::VARCHAR;
END;
$$;
```

**Implementación actual en Vue (línea 837-884):**
```javascript
// 1. Guardar histórico
await execute('sp_13_historia', 'padron_licencias', { par_control: ... }, '', null, 'public')

// 2. UPDATE vigencia
await execute('UPDATE', 'padron_licencias', { table: 'ta_13_datosrcm', data: { vigencia: 'B', ... }, where: {...} }, '', null, 'comun')

// 3. Actualizar adeudos
await execute('spd_abc_adercm', 'padron_licencias', { par_control, par_opc: 2, par_usu }, '', null, 'public')
```

---

## 📊 ESQUEMAS SEGÚN postgreok.csv

| Tabla | Base de Datos | Esquema | sistemas_uso |
|-------|---------------|---------|--------------|
| `ta_12_passwords` | padron_licencias | comun | SI |
| `ta_13_datosrcm` | padron_licencias | comun | SI |
| `ta_13_datosrcmadic` | cementerio | public | SI |
| `tc_13_cementerios` | cementerio | public | SI |
| `ta_13_adeudosrcm` | cementerio | public | SI |

---

## 🔄 PROCESO DE MIGRACIÓN FUTURO

Cuando los 6 SP estén creados y disponibles en `/ok/`:

1. **Instalar SP en las bases de datos correspondientes**
2. **Actualizar ABCFolio.vue** reemplazando las queries SQL directas:
   - Buscar `// TODO FUTURO: Migrar a SP`
   - Reemplazar el bloque de `execute('SELECT'|'UPDATE'|'INSERT', ...)` por `execute('sp_nombre', ...)`
3. **Probar funcionalidad completa**
4. **Eliminar comentarios de implementación actual**
5. **Marcar en CONTROL_IMPLEMENTACION_VUE.md** como migrado a SP

---

## 📝 REFERENCIAS

- **Pascal original:** `C:\Sistemas\RecodeFactory\recodeGDL\cementerios\ABCFolio.pas`
- **DFM original:** `C:\Sistemas\RecodeFactory\recodeGDL\cementerios\ABCFolio.dfm`
- **CSV configuración:** `RefactorX/Base/db/res/postgreok.csv`
- **SP existentes:** `RefactorX/Base/cementerios/database/ok/01_SP_CEMENTERIOS_ABCFOLIO_EXACTO_all_procedures.sql`

---

**Última actualización:** 2025-11-24
**Responsable:** Claude Code - Agente SP
**Estado:** 📄 DOCUMENTADO
