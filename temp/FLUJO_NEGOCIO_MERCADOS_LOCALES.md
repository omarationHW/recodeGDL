# Flujo de Negocio Completo: Gestión de Locales en Mercados

## 📋 Índice
1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Diagrama de Flujo](#diagrama-de-flujo)
3. [Procesos Detallados](#procesos-detallados)
4. [Tablas Involucradas](#tablas-involucradas)
5. [Datos de Prueba](#datos-de-prueba)

---

## Resumen Ejecutivo

Este documento describe el **flujo completo del ciclo de vida de un local en mercados municipales**, desde su alta inicial hasta la consulta de pagos y reportes. El flujo involucra **8 procesos principales** y abarca las operaciones de:

- ✅ Alta y mantenimiento de locales
- 📊 Consulta del padrón
- 📝 Emisión de adeudos
- 💰 Consulta de adeudos pendientes
- 💳 Carga de pagos
- 📈 Consulta de pagos aplicados
- 📄 Reportes administrativos
- 🔍 Consulta de datos del local

**Tablas Principales:**
- `comun.ta_11_locales`: 13,321 locales registrados
- `comun.ta_11_adeudo_local`: 223,515 adeudos generados
- `comun.ta_11_pagos_local`: 3,644,595 pagos aplicados

---

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CICLO DE VIDA DE UN LOCAL EN MERCADOS                │
└─────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────┐
    │  1. ALTA LOCAL   │ ◄── Inicio del flujo
    │  LocalesMtto.vue │
    └────────┬─────────┘
             │ Crea registro en ta_11_locales
             ▼
    ┌──────────────────┐
    │ 2. PADRÓN LOCAL  │
    │PadronLocales.vue │ ◄── Consulta y verificación
    └────────┬─────────┘
             │ Consulta locales activos con cálculo de renta
             ▼
    ┌──────────────────┐
    │ 3. EMISIÓN       │
    │EmisionLocales.vue│ ◄── Generación de adeudos periódicos
    └────────┬─────────┘
             │ Genera adeudos en ta_11_adeudo_local
             ▼
    ┌──────────────────┐
    │ 4. ADEUDOS       │
    │AdeudosLocales.vue│ ◄── Consulta de pendientes
    └────────┬─────────┘
             │ Muestra adeudos pendientes por periodo
             ▼
    ┌──────────────────┐
    │ 5. CARGA PAGOS   │
    │CargaPagLocales.vue│◄── Registro de pagos
    └────────┬─────────┘
             │ Registra pagos en ta_11_pagos_local
             ▼
    ┌──────────────────┐
    │ 6. CONSULTA      │
    │  PAGOS LOCALES   │ ◄── Verificación de pagos
    │ConsPagosLocales  │
    └────────┬─────────┘
             │ Historial completo de pagos
             ▼
    ┌──────────────────┐
    │ 7. REPORTES      │
    │RptPagosLocales   │ ◄── Reportes administrativos
    │RptPadronLocales  │
    │RptAdeudosLocales │
    └────────┬─────────┘
             │ Reportes para auditoría y gestión
             ▼
    ┌──────────────────┐
    │ 8. CONSULTA      │
    │   DATOS LOCAL    │ ◄── Información detallada
    │ConsultaDatos.vue │
    └──────────────────┘
```

---

## Procesos Detallados

### 📍 PROCESO 1: Alta de Locales (LocalesMtto.vue)

**Objetivo:** Registrar nuevos locales en el sistema de mercados municipales.

**Archivo Vue:** `RefactorX/Base/mercados/vue/LocalesMtto.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/59_SP_MERCADOS_LOCALESMTTO_EXACTO_all_procedures.sql`

#### Stored Procedures Involucrados:
1. **`get_recaudadoras()`** - Catálogo de recaudadoras
2. **`get_secciones()`** - Catálogo de secciones
3. **`get_zonas()`** - Catálogo de zonas
4. **`get_cuotas()`** - Catálogo de claves de cuota
5. **`buscar_local(...)`** - Verifica si el local ya existe
6. **`alta_local(...)`** - Crea el nuevo local
7. **`update_local(...)`** - Actualiza datos del local

#### Datos de Entrada:
```javascript
{
  oficina: integer,          // Recaudadora (ej: 5)
  num_mercado: integer,      // Número de mercado (ej: 1)
  categoria: integer,        // Categoría (ej: 1)
  seccion: varchar(2),       // Sección (ej: "EA")
  local: integer,            // Número de local (ej: 12)
  letra_local: varchar(1),   // Opcional (ej: "A")
  bloque: varchar(1),        // Opcional (ej: "D")
  nombre: varchar(30),       // Nombre del arrendatario
  giro: integer,             // Tipo de negocio
  sector: varchar(1),        // J/R/L/H
  domicilio: varchar(50),    // Dirección
  zona: integer,             // Zona del mercado
  descripcion_local: varchar,// Descripción del local
  superficie: numeric,       // Metros cuadrados
  fecha_alta: date,          // Fecha de alta
  clave_cuota: integer,      // Tipo de cuota a aplicar
  numero_memo: integer,      // Número de memorándum
  vigencia: varchar(1),      // 'A' = Activo, 'B' = Baja
  id_usuario: integer        // Usuario que registra
}
```

#### Operaciones en Base de Datos:
```sql
-- 1. Inserción en ta_11_locales
INSERT INTO comun.ta_11_locales (
    oficina, num_mercado, categoria, seccion, local, letra_local, bloque,
    nombre, domicilio, sector, zona, descripcion_local, superficie, giro,
    fecha_alta, clave_cuota, vigencia, bloqueo, arrendatario,
    id_contribuy_prop, id_contribuy_renta
) VALUES (...);

-- 2. Registro en ta_11_movimientos (historial)
INSERT INTO comun.ta_11_movimientos (
    id_local, tipo_mov, fecha_mov, id_usuario, numero_memo, axo
) VALUES (...);

-- 3. Generación automática de adeudos iniciales (si aplica)
INSERT INTO comun.ta_11_adeudo_local (
    id_local, axo, periodo, importe, fecha_alta, id_usuario
) VALUES (...);
```

#### Validaciones:
- ✅ El local no debe existir previamente
- ✅ La recaudadora debe ser válida
- ✅ La sección debe existir en el catálogo
- ✅ La superficie debe ser mayor a 0
- ✅ La clave de cuota debe existir

---

### 📍 PROCESO 2: Padrón de Locales (PadronLocales.vue)

**Objetivo:** Consultar el padrón de locales activos con cálculo de renta.

**Archivo Vue:** `RefactorX/Base/mercados/vue/PadronLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/64_SP_MERCADOS_PADRONLOCALES_EXACTO_all_procedures.sql`

#### Stored Procedure Principal:
**`sp_get_padron_locales(p_recaudadora INTEGER)`**

#### Query Ejecutado:
```sql
SELECT
    a.id_local,
    a.oficina,
    a.num_mercado,
    a.categoria,
    a.seccion,
    a.local,
    a.letra_local,
    a.bloque,
    a.nombre,
    a.superficie,
    a.clave_cuota,
    b.descripcion AS mercado,
    CASE
        WHEN a.seccion = 'PS' THEN a.superficie * c.importe_cuota * 30
        ELSE a.superficie * c.importe_cuota
    END AS renta
FROM comun.ta_11_locales a
JOIN comun.ta_11_mercados b
    ON a.oficina = b.oficina
    AND a.num_mercado = b.num_mercado_nvo
LEFT JOIN comun.ta_11_cuo_locales c
    ON c.axo = EXTRACT(YEAR FROM CURRENT_DATE)
    AND c.categoria = a.categoria
    AND c.seccion = a.seccion
    AND c.clave_cuota = a.clave_cuota
WHERE a.oficina = p_recaudadora
  AND a.vigencia = 'A'
ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion,
         a.local, a.letra_local, a.bloque;
```

#### Datos de Salida:
```javascript
{
  id_local: integer,
  oficina: smallint,
  num_mercado: smallint,
  categoria: smallint,
  seccion: varchar(2),
  local: smallint,
  letra_local: varchar(1),
  bloque: varchar(1),
  nombre: varchar(30),
  superficie: numeric,
  clave_cuota: smallint,
  descripcion: varchar(30),  // Nombre del mercado
  renta: numeric             // Cálculo según sección
}
```

#### Lógica de Negocio:
- **Sección "PS" (Piso Semi-fijo):** `renta = superficie * importe_cuota * 30`
- **Otras secciones:** `renta = superficie * importe_cuota`
- Solo muestra locales con `vigencia = 'A'` (Activos)

---

### 📍 PROCESO 3: Emisión de Adeudos (EmisionLocales.vue)

**Objetivo:** Generar adeudos periódicos para los locales del mercado.

**Archivo Vue:** `RefactorX/Base/mercados/vue/EmisionLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/48_SP_MERCADOS_EMISIONLOCALES_EXACTO_all_procedures.sql`

#### Stored Procedures Involucrados:
1. **`sp_emisionlocales_listar_mercados(p_oficina)`** - Lista mercados activos
2. **`sp_emisionlocales_emitir_recibos(...)`** - Genera lista de locales a emitir
3. **`sp_emisionlocales_grabar_emision(...)`** - Graba adeudos en BD
4. **`sp_emisionlocales_calcular_importe(...)`** - Calcula importe según cuota
5. **`sp_emisionlocales_verificar_emision(...)`** - Verifica emisión previa

#### Proceso de Emisión:

**Paso 1: Listar locales a emitir**
```sql
SELECT
    l.id_local,
    l.local,
    l.nombre,
    l.descripcion_local,
    l.superficie,
    CASE
        WHEN l.seccion = 'PS' AND c.clave_cuota = 4
            THEN l.superficie * c.importe_cuota
        WHEN l.seccion = 'PS'
            THEN (c.importe_cuota * l.superficie) * 30
        ELSE l.superficie * c.importe_cuota
    END AS renta
FROM comun.ta_11_locales l
JOIN comun.ta_11_mercados m
    ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
JOIN comun.ta_11_cuo_locales c
    ON c.axo = p_axo
    AND l.categoria = c.categoria
    AND l.seccion = c.seccion
    AND l.clave_cuota = c.clave_cuota
WHERE l.oficina = p_oficina
  AND l.num_mercado = p_mercado
  AND l.vigencia = 'A'
  AND l.bloqueo < 4
  -- No debe tener pago para este periodo
  AND l.id_local NOT IN (
    SELECT id_local FROM comun.ta_11_pagos_local
    WHERE id_local = l.id_local
      AND axo = p_axo
      AND periodo = p_periodo
  )
  -- No debe tener condonación para este periodo
  AND l.id_local NOT IN (
    SELECT id_local FROM comun.ta_11_ade_loc_canc
    WHERE id_local = l.id_local
      AND axo = p_axo
      AND periodo = p_periodo
  );
```

**Paso 2: Grabar emisión**
```sql
INSERT INTO comun.ta_11_adeudo_local (
    id_local,
    axo,
    periodo,
    importe,
    fecha_alta,
    id_usuario
)
SELECT
    id_local,
    p_axo,
    p_periodo,
    renta_calculada,
    CURRENT_TIMESTAMP,
    p_usuario_id
FROM locales_a_emitir;
```

#### Datos de Entrada:
```javascript
{
  oficina: integer,      // Recaudadora
  mercado: integer,      // Mercado específico
  axo: integer,          // Año de emisión (ej: 2025)
  periodo: integer,      // Periodo/mes (1-12)
  usuario_id: integer    // Usuario que emite
}
```

#### Validaciones:
- ✅ No emitir si ya existe pago para el periodo
- ✅ No emitir si ya existe condonación
- ✅ Local debe estar vigente (vigencia = 'A')
- ✅ Local no debe estar bloqueado (bloqueo < 4)

---

### 📍 PROCESO 4: Consulta de Adeudos (AdeudosLocales.vue)

**Objetivo:** Consultar adeudos pendientes de pago por local.

**Archivo Vue:** `RefactorX/Base/mercados/vue/AdeudosLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/06_SP_MERCADOS_ADEUDOSLOCALES_EXACTO_all_procedures.sql`

#### Stored Procedures Involucrados:
1. **`sp_get_adeudos_locales(p_axo, p_oficina, p_periodo)`** - Lista adeudos
2. **`sp_adeudos_locales(...)`** - Alias del anterior
3. **`sp_get_meses_adeudo(p_id_local, p_axo)`** - Detalle mensual
4. **`sp_get_total_adeudos(p_oficina, p_axo, p_periodo)`** - Totales

#### Query Principal:
```sql
SELECT
    l.id_local,
    l.oficina,
    l.num_mercado,
    l.categoria,
    l.seccion,
    l.letra_local,
    l.bloque,
    l.nombre,
    l.superficie,
    l.clave_cuota,
    COALESCE(SUM(a.importe), 0) AS adeudo,
    COALESCE(r.recaudadora, 'SIN NOMBRE') AS recaudadora,
    COALESCE(m.descripcion, 'SIN DESCRIPCION') AS descripcion,
    l.local
FROM comun.ta_11_localpaso l
LEFT JOIN comun.ta_11_adeudo_local a
    ON a.id_local = l.id_local
    AND a.axo = p_axo
    AND a.periodo <= p_periodo
LEFT JOIN comun.ta_12_recaudadoras r
    ON r.id_rec = l.oficina
LEFT JOIN comun.ta_11_mercados m
    ON m.oficina = l.oficina
    AND m.num_mercado_nvo = l.num_mercado
WHERE l.oficina = p_oficina
  AND l.vigencia = 'A'
GROUP BY l.id_local, l.oficina, l.num_mercado, l.categoria,
         l.seccion, l.local, l.letra_local, l.bloque, l.nombre,
         l.superficie, l.clave_cuota, r.recaudadora, m.descripcion
HAVING COALESCE(SUM(a.importe), 0) > 0
ORDER BY l.oficina, l.num_mercado, l.categoria,
         l.seccion DESC, l.local, l.letra_local, l.bloque;
```

#### Datos de Salida:
```javascript
{
  id_local: integer,
  oficina: smallint,
  num_mercado: smallint,
  categoria: smallint,
  seccion: varchar(2),
  local: smallint,
  letra_local: varchar,
  bloque: varchar,
  nombre: varchar(30),
  superficie: float,
  clave_cuota: smallint,
  adeudo: numeric,        // Total adeudado
  recaudadora: varchar(50),
  descripcion: varchar(30),
}
```

#### Lógica de Negocio:
- Suma **todos los adeudos del año** hasta el periodo indicado
- Excluye locales con adeudo = 0
- Solo muestra locales vigentes

---

### 📍 PROCESO 5: Carga de Pagos (CargaPagLocales.vue / CargaPagMercado.vue)

**Objetivo:** Registrar pagos realizados por los arrendatarios de locales.

**Archivo Vue:** `RefactorX/Base/mercados/vue/CargaPagLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/14_SP_MERCADOS_CARGAPAGMERCADO_EXACTO_all_procedures.sql`

#### Stored Procedures Involucrados:
1. **`sp_get_mercados(p_oficina)`** - Lista mercados
2. **`sp_get_adeudos_local(...)`** - Adeudos del local
3. **`sp_get_ingreso_operacion(...)`** - Valida ingreso de caja
4. **`sp_registrar_pago_local(...)`** - Registra el pago
5. **`sp_actualizar_adeudo(...)`** - Actualiza adeudo
6. **`sp_validar_operacion_caja(...)`** - Valida operación

#### Proceso de Carga de Pago:

**Paso 1: Obtener adeudos del local**
```sql
SELECT
    c.id_local, c.oficina, c.num_mercado, c.categoria,
    c.seccion, c.local, c.letra_local, c.bloque,
    a.axo, a.periodo, a.importe, a.fecha_alta,
    b.usuario
FROM comun.ta_11_adeudo_local a
JOIN comun.ta_12_passwords b ON a.id_usuario = b.id_usuario
JOIN comun.ta_11_locales c ON a.id_local = c.id_local
WHERE c.oficina = p_oficina
  AND c.num_mercado = p_mercado
  AND c.categoria = p_categoria
  AND c.seccion = p_seccion
  AND c.local = p_local
  AND c.vigencia = 'A'
  AND c.bloqueo < 4
ORDER BY c.oficina, c.num_mercado, c.categoria, c.seccion,
         c.local, c.letra_local, c.bloque, a.axo, a.periodo;
```

**Paso 2: Validar operación de caja**
```sql
SELECT
    num_mercado_nvo,
    cuenta_ingreso,
    cta_aplicacion,
    importe
FROM comun.ta_11_mercados m
JOIN comun.ta_12_operaciones o
    ON o.fecha_ingreso = p_fecha_ingreso
    AND o.id_rec = p_oficina
    AND o.caja = p_caja
    AND o.operacion = p_operacion
WHERE m.oficina = p_oficina_mercado
  AND m.num_mercado_nvo = p_mercado
  AND m.cuenta_ingreso = o.cuenta_ingreso;
```

**Paso 3: Registrar pago**
```sql
INSERT INTO comun.ta_11_pagos_local (
    id_local,
    axo,
    periodo,
    importe,
    fecha_pago,
    fecha_ingreso,
    oficina,
    caja,
    operacion,
    id_usuario,
    cuenta_ingreso
) VALUES (
    p_id_local,
    p_axo,
    p_periodo,
    p_importe,
    CURRENT_TIMESTAMP,
    p_fecha_ingreso,
    p_oficina,
    p_caja,
    p_operacion,
    p_id_usuario,
    p_cuenta_ingreso
);
```

**Paso 4: Eliminar adeudo**
```sql
DELETE FROM comun.ta_11_adeudo_local
WHERE id_local = p_id_local
  AND axo = p_axo
  AND periodo = p_periodo;
```

#### Datos de Entrada:
```javascript
{
  id_local: integer,
  axo: integer,
  periodo: integer,
  importe: numeric,
  fecha_ingreso: date,
  oficina: integer,
  caja: varchar,
  operacion: integer,
  id_usuario: integer,
  cuenta_ingreso: integer
}
```

#### Validaciones:
- ✅ Debe existir el adeudo a pagar
- ✅ La operación de caja debe ser válida
- ✅ El importe debe coincidir con el adeudo
- ✅ La cuenta de ingreso debe corresponder al mercado
- ✅ No debe existir ya un pago para ese periodo

---

### 📍 PROCESO 6: Consulta de Pagos (ConsPagosLocales.vue)

**Objetivo:** Consultar el historial de pagos realizados por los locales.

**Archivo Vue:** `RefactorX/Base/mercados/vue/ConsPagosLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/28_SP_MERCADOS_CONSPAGOSLOCALES_EXACTO_all_procedures.sql`

#### Stored Procedures Involucrados:
1. **`get_recaudadoras()`** - Catálogo de recaudadoras
2. **`get_secciones()`** - Catálogo de secciones
3. **`get_mercados_by_oficina(p_oficina)`** - Mercados por oficina
4. **`get_cajas_by_oficina(p_oficina)`** - Cajas por oficina
5. **`buscar_pagos_locales_por_local(...)`** - Búsqueda por local
6. **`buscar_pagos_locales_por_fecha(...)`** - Búsqueda por fecha

#### Query de Búsqueda por Local:
```sql
SELECT
    l.id_local,
    l.oficina,
    l.num_mercado,
    l.categoria,
    l.seccion,
    l.local,
    l.letra_local,
    l.bloque,
    l.nombre,
    l.arrendatario,
    p.axo,
    p.periodo,
    p.importe,
    p.fecha_pago,
    p.fecha_ingreso,
    p.caja,
    p.operacion,
    u.usuario,
    m.descripcion AS mercado
FROM comun.ta_11_pagos_local p
JOIN comun.ta_11_locales l ON p.id_local = l.id_local
LEFT JOIN comun.ta_12_passwords u ON p.id_usuario = u.id_usuario
LEFT JOIN comun.ta_11_mercados m
    ON l.oficina = m.oficina
    AND l.num_mercado = m.num_mercado_nvo
WHERE l.oficina = p_oficina
  AND l.num_mercado = p_num_mercado
  AND l.categoria = p_categoria
  AND l.seccion = p_seccion
  AND l.local = p_local
  AND (l.letra_local = p_letra_local OR p_letra_local IS NULL)
  AND (l.bloque = p_bloque OR p_bloque IS NULL)
ORDER BY p_orden
LIMIT p_limit OFFSET p_offset;
```

#### Datos de Salida:
```javascript
{
  id_local: integer,
  oficina: smallint,
  num_mercado: smallint,
  categoria: smallint,
  seccion: varchar,
  local: integer,
  letra_local: varchar,
  bloque: varchar,
  nombre: varchar,
  arrendatario: varchar,
  axo: smallint,
  periodo: smallint,
  importe: numeric,
  fecha_pago: timestamp,
  fecha_ingreso: date,
  caja: varchar,
  operacion: integer,
  usuario: varchar,
  mercado: varchar
}
```

#### Opciones de Búsqueda:
- **Por Local:** oficina, mercado, categoría, sección, local, letra, bloque
- **Por Fecha:** rango de fechas de ingreso
- **Por Caja:** específica de una oficina
- **Por Año/Periodo:** periodo fiscal específico

---

### 📍 PROCESO 7: Reportes Administrativos

**Objetivo:** Generar reportes para auditoría, gestión y análisis.

#### 7.1 Reporte de Pagos (RptPagosLocales.vue)

**Archivo Vue:** `RefactorX/Base/mercados/vue/RptPagosLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/98_SP_MERCADOS_RPTPAGOSLOCALES_EXACTO_all_procedures.sql`

**Tipos de Reportes:**
- Pagos por periodo
- Pagos por mercado
- Pagos por caja
- Estadísticas de recaudación

#### 7.2 Reporte de Padrón (RptPadronLocales.vue)

**Archivo Vue:** `RefactorX/Base/mercados/vue/RptPadronLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/97_SP_MERCADOS_RPTPADRONLOCALES_EXACTO_all_procedures.sql`

**Incluye:**
- Listado completo de locales
- Datos de arrendatarios
- Superficies y cuotas
- Cálculo de rentas

#### 7.3 Reporte de Adeudos (RptAdeudosLocales.vue)

**Archivo Vue:** `RefactorX/Base/mercados/vue/RptAdeudosLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/80_SP_MERCADOS_RPTADEUDOSLOCALES_EXACTO_all_procedures.sql`

**Contenido:**
- Adeudos pendientes por local
- Antigüedad de adeudos
- Totales por mercado
- Locales en morosidad

#### 7.4 Reporte de Emisión (RptEmisionLocales.vue)

**Archivo Vue:** `RefactorX/Base/mercados/vue/RptEmisionLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/88_SP_MERCADOS_RPTEMISIONLOCALES_EXACTO_all_procedures.sql`

**Detalle:**
- Recibos emitidos por periodo
- Importes proyectados
- Locales incluidos en emisión
- Resumen por mercado

---

### 📍 PROCESO 8: Consulta de Datos del Local (ConsultaDatosLocales.vue)

**Objetivo:** Obtener información completa y detallada de un local específico.

**Archivo Vue:** `RefactorX/Base/mercados/vue/ConsultaDatosLocales.vue`
**Archivo SQL:** `RefactorX/Base/mercados/database/ok/31_SP_MERCADOS_CONSULTADATOSLOCALES_EXACTO_all_procedures.sql`

#### Información Mostrada:
```sql
SELECT
    l.*,
    m.descripcion AS mercado,
    r.recaudadora,
    -- Adeudos actuales
    (SELECT COUNT(*) FROM comun.ta_11_adeudo_local
     WHERE id_local = l.id_local) AS total_adeudos,
    (SELECT SUM(importe) FROM comun.ta_11_adeudo_local
     WHERE id_local = l.id_local) AS monto_adeudos,
    -- Pagos históricos
    (SELECT COUNT(*) FROM comun.ta_11_pagos_local
     WHERE id_local = l.id_local) AS total_pagos,
    (SELECT SUM(importe) FROM comun.ta_11_pagos_local
     WHERE id_local = l.id_local) AS monto_pagos,
    -- Último pago
    (SELECT MAX(fecha_pago) FROM comun.ta_11_pagos_local
     WHERE id_local = l.id_local) AS ultimo_pago,
    -- Último movimiento
    (SELECT MAX(fecha_mov) FROM comun.ta_11_movimientos
     WHERE id_local = l.id_local) AS ultimo_movimiento
FROM comun.ta_11_locales l
LEFT JOIN comun.ta_11_mercados m
    ON l.oficina = m.oficina AND l.num_mercado = m.num_mercado_nvo
LEFT JOIN comun.ta_12_recaudadoras r ON l.oficina = r.id_rec
WHERE l.id_local = p_id_local;
```

#### Secciones del Detalle:
1. **Datos Generales:** Ubicación, nombre, superficie, giro
2. **Datos Fiscales:** Cuota, renta mensual, vigencia
3. **Estado Financiero:** Adeudos, pagos, saldo
4. **Historial:** Movimientos, cambios, actualizaciones

---

## Tablas Involucradas

### Tabla Principal: `comun.ta_11_locales`

**Descripción:** Almacena la información de todos los locales de mercados municipales.

**Registros:** 13,321 locales

**Estructura:**
```sql
CREATE TABLE comun.ta_11_locales (
    id_local SERIAL PRIMARY KEY,
    oficina SMALLINT NOT NULL,              -- Recaudadora
    num_mercado SMALLINT NOT NULL,          -- Número de mercado
    categoria SMALLINT NOT NULL,            -- Categoría del local
    seccion VARCHAR(2) NOT NULL,            -- Sección (EA, PS, etc)
    local SMALLINT NOT NULL,                -- Número de local
    letra_local VARCHAR(1),                 -- Letra identificadora
    bloque VARCHAR(1),                      -- Bloque del local
    nombre VARCHAR(30),                     -- Nombre/Razón social
    domicilio VARCHAR(50),                  -- Dirección del local
    sector VARCHAR(1),                      -- J/R/L/H
    zona SMALLINT,                          -- Zona del mercado
    descripcion_local VARCHAR(50),          -- Descripción
    superficie NUMERIC(8,2),                -- Metros cuadrados
    giro SMALLINT,                          -- Tipo de negocio
    fecha_alta DATE,                        -- Fecha de registro
    fecha_baja DATE,                        -- Fecha de baja
    clave_cuota SMALLINT,                   -- Tipo de cuota
    vigencia VARCHAR(1),                    -- A=Activo, B=Baja
    bloqueo SMALLINT DEFAULT 0,             -- Nivel de bloqueo
    arrendatario VARCHAR(40),               -- Arrendatario actual
    id_contribuy_prop INTEGER,              -- Propietario
    id_contribuy_renta INTEGER,             -- Arrendatario registrado

    UNIQUE(oficina, num_mercado, categoria, seccion, local, letra_local, bloque)
);
```

**Índices:**
```sql
CREATE INDEX idx_locales_oficina ON comun.ta_11_locales(oficina);
CREATE INDEX idx_locales_mercado ON comun.ta_11_locales(oficina, num_mercado);
CREATE INDEX idx_locales_vigencia ON comun.ta_11_locales(vigencia);
```

---

### Tabla de Adeudos: `comun.ta_11_adeudo_local`

**Descripción:** Almacena los adeudos generados por emisión mensual.

**Registros:** 223,515 adeudos

**Estructura:**
```sql
CREATE TABLE comun.ta_11_adeudo_local (
    id_adeudo SERIAL PRIMARY KEY,
    id_local INTEGER NOT NULL REFERENCES comun.ta_11_locales(id_local),
    axo SMALLINT NOT NULL,                  -- Año del adeudo
    periodo SMALLINT NOT NULL,              -- Mes (1-12)
    importe NUMERIC(10,2) NOT NULL,         -- Monto adeudado
    fecha_alta TIMESTAMP DEFAULT NOW(),     -- Fecha de generación
    id_usuario INTEGER,                     -- Usuario que emitió

    UNIQUE(id_local, axo, periodo)
);
```

**Índices:**
```sql
CREATE INDEX idx_adeudo_local ON comun.ta_11_adeudo_local(id_local);
CREATE INDEX idx_adeudo_periodo ON comun.ta_11_adeudo_local(axo, periodo);
```

---

### Tabla de Pagos: `comun.ta_11_pagos_local`

**Descripción:** Registra todos los pagos realizados por los locales.

**Registros:** 3,644,595 pagos

**Estructura:**
```sql
CREATE TABLE comun.ta_11_pagos_local (
    id_pago SERIAL PRIMARY KEY,
    id_local INTEGER NOT NULL REFERENCES comun.ta_11_locales(id_local),
    axo SMALLINT NOT NULL,                  -- Año del pago
    periodo SMALLINT NOT NULL,              -- Mes pagado
    importe NUMERIC(10,2) NOT NULL,         -- Monto pagado
    fecha_pago TIMESTAMP DEFAULT NOW(),     -- Fecha de registro
    fecha_ingreso DATE,                     -- Fecha de ingreso a caja
    oficina SMALLINT,                       -- Recaudadora
    caja VARCHAR(2),                        -- Caja receptora
    operacion INTEGER,                      -- Número de operación
    id_usuario INTEGER,                     -- Usuario que registró
    cuenta_ingreso INTEGER,                 -- Cuenta contable

    UNIQUE(id_local, axo, periodo)
);
```

**Índices:**
```sql
CREATE INDEX idx_pago_local ON comun.ta_11_pagos_local(id_local);
CREATE INDEX idx_pago_fecha ON comun.ta_11_pagos_local(fecha_ingreso);
CREATE INDEX idx_pago_caja ON comun.ta_11_pagos_local(oficina, caja, operacion);
```

---

### Tablas Auxiliares

#### `comun.ta_11_mercados`
**Descripción:** Catálogo de mercados municipales.
```sql
CREATE TABLE comun.ta_11_mercados (
    oficina SMALLINT,
    num_mercado_nvo SMALLINT,
    categoria SMALLINT,
    descripcion VARCHAR(30),
    cuenta_ingreso INTEGER,
    tipo_emision VARCHAR(1),
    PRIMARY KEY (oficina, num_mercado_nvo)
);
```

#### `comun.ta_11_cuo_locales`
**Descripción:** Cuotas/tarifas vigentes por año.
```sql
CREATE TABLE comun.ta_11_cuo_locales (
    axo SMALLINT,
    categoria SMALLINT,
    seccion VARCHAR(2),
    clave_cuota SMALLINT,
    importe_cuota NUMERIC(10,4),
    PRIMARY KEY (axo, categoria, seccion, clave_cuota)
);
```

#### `comun.ta_12_recaudadoras`
**Descripción:** Catálogo de recaudadoras.
```sql
CREATE TABLE comun.ta_12_recaudadoras (
    id_rec SMALLINT PRIMARY KEY,
    recaudadora VARCHAR(50)
);
```

#### `comun.ta_11_secciones`
**Descripción:** Catálogo de secciones de mercados.
```sql
CREATE TABLE comun.ta_11_secciones (
    seccion VARCHAR(2) PRIMARY KEY,
    descripcion VARCHAR(30)
);
```

---

## Datos de Prueba

### Local con Mayor Actividad

Basado en el análisis de la base de datos, el siguiente local tiene datos completos para pruebas:

```javascript
{
  // Identificación del Local
  oficina: 5,
  num_mercado: 1,
  categoria: 1,
  seccion: "EA",
  local: 12,
  letra_local: null,
  bloque: null,

  // Datos del Local
  nombre: "TRANS. DE ABASTOS, S.A. C.V.",
  superficie: 100.00,

  // Estadísticas
  total_condonaciones: 10335,
  monto_condonado: 3843591.70,

  // Para Pruebas de Procesos
  giro: 1,
  sector: "J",
  domicilio: "Centro Abastos",
  zona: 1,
  descripcion_local: "Local comercial grande",
  clave_cuota: 1,
  vigencia: "A"
}
```

### Otros Locales con Datos

| Nombre | Oficina | Mercado | Sec | Local | Actividad |
|--------|---------|---------|-----|-------|-----------|
| CASTAÑEDA RAMOS MARIA | 5 | 1 | EA | 14 | 7,540 registros |
| AMARAL BALBUENA FCO | 5 | 1 | EA | 32 | 6,045 registros |
| GUZMAN GONZALEZ JOSE | 5 | 1 | EA | 2 | 3,534 registros |
| DROGUERIA LEVY S.A. | 5 | 1 | EA | 6 | 3,380 registros |

### Escenarios de Prueba

#### Escenario 1: Alta de Nuevo Local
```javascript
// POST /api/execute
{
  action: 'alta_local',
  params: {
    oficina: 5,
    num_mercado: 1,
    categoria: 1,
    seccion: "01",
    local: 999,
    letra_local: "A",
    bloque: null,
    nombre: "LOCAL DE PRUEBA S.A.",
    giro: 1,
    sector: "J",
    domicilio: "Prueba 123",
    zona: 1,
    descripcion_local: "Local de prueba",
    superficie: 50.00,
    fecha_alta: "2025-01-25",
    clave_cuota: 1,
    numero_memo: 12345,
    vigencia: "A",
    id_usuario: 1,
    axo: 2025
  }
}
```

#### Escenario 2: Emisión de Adeudos
```javascript
// Llamada al SP
sp_emisionlocales_emitir_recibos(
  5,     // oficina
  1,     // mercado
  2025,  // axo
  1,     // periodo (Enero)
  1      // usuario_id
)
```

#### Escenario 3: Consulta de Adeudos
```javascript
// Llamada al SP
sp_get_adeudos_locales(
  2025,  // axo
  5,     // oficina
  3      // periodo (hasta Marzo)
)
```

#### Escenario 4: Carga de Pago
```javascript
// POST /api/execute
{
  action: 'registrar_pago_local',
  params: {
    id_local: 123,
    axo: 2025,
    periodo: 1,
    importe: 1500.00,
    fecha_ingreso: "2025-01-25",
    oficina: 5,
    caja: "01",
    operacion: 12345,
    id_usuario: 1,
    cuenta_ingreso: 100
  }
}
```

#### Escenario 5: Consulta de Pagos
```javascript
// Llamada al SP
buscar_pagos_locales_por_local(
  5,     // oficina
  1,     // num_mercado
  1,     // categoria
  "EA",  // seccion
  12,    // local
  null,  // letra_local
  null,  // bloque
  "fecha_pago DESC",  // orden
  50,    // limit
  0      // offset
)
```

---

## Resumen de Archivos del Flujo

### Archivos Vue (Frontend)
```
RefactorX/Base/mercados/vue/
├── LocalesMtto.vue              (1. Alta de locales)
├── PadronLocales.vue            (2. Padrón)
├── EmisionLocales.vue           (3. Emisión)
├── AdeudosLocales.vue           (4. Adeudos)
├── CargaPagLocales.vue          (5. Carga pagos)
├── ConsPagosLocales.vue         (6. Consulta pagos)
├── RptPagosLocales.vue          (7a. Reporte pagos)
├── RptPadronLocales.vue         (7b. Reporte padrón)
├── RptAdeudosLocales.vue        (7c. Reporte adeudos)
├── RptEmisionLocales.vue        (7d. Reporte emisión)
└── ConsultaDatosLocales.vue     (8. Consulta datos)
```

### Archivos SQL (Backend)
```
RefactorX/Base/mercados/database/ok/
├── 59_SP_MERCADOS_LOCALESMTTO_EXACTO_all_procedures.sql
├── 64_SP_MERCADOS_PADRONLOCALES_EXACTO_all_procedures.sql
├── 48_SP_MERCADOS_EMISIONLOCALES_EXACTO_all_procedures.sql
├── 06_SP_MERCADOS_ADEUDOSLOCALES_EXACTO_all_procedures.sql
├── 14_SP_MERCADOS_CARGAPAGMERCADO_EXACTO_all_procedures.sql
├── 28_SP_MERCADOS_CONSPAGOSLOCALES_EXACTO_all_procedures.sql
├── 98_SP_MERCADOS_RPTPAGOSLOCALES_EXACTO_all_procedures.sql
├── 97_SP_MERCADOS_RPTPADRONLOCALES_EXACTO_all_procedures.sql
├── 80_SP_MERCADOS_RPTADEUDOSLOCALES_EXACTO_all_procedures.sql
├── 88_SP_MERCADOS_RPTEMISIONLOCALES_EXACTO_all_procedures.sql
└── 31_SP_MERCADOS_CONSULTADATOSLOCALES_EXACTO_all_procedures.sql
```

---

## Diagramas de Relación

### Modelo de Datos Simplificado
```
┌──────────────────────┐
│  ta_12_recaudadoras  │
│  - id_rec (PK)       │
│  - recaudadora       │
└──────────┬───────────┘
           │
           │ 1:N
           ▼
┌──────────────────────┐       ┌──────────────────────┐
│  ta_11_mercados      │       │  ta_11_secciones     │
│  - oficina (PK)      │       │  - seccion (PK)      │
│  - num_mercado (PK)  │       │  - descripcion       │
│  - categoria         │       └──────────────────────┘
│  - descripcion       │                │
│  - cuenta_ingreso    │                │ 1:N
└──────────┬───────────┘                │
           │ 1:N                        │
           ▼                            ▼
┌──────────────────────────────────────────────┐
│         ta_11_locales (Principal)            │
│  - id_local (PK)                             │
│  - oficina, num_mercado (FK)                 │
│  - categoria, seccion (FK)                   │
│  - local, letra_local, bloque                │
│  - nombre, arrendatario                      │
│  - superficie, giro, clave_cuota             │
│  - vigencia, bloqueo                         │
└──────────┬───────────────────────────────────┘
           │
           ├─────────────────┬─────────────────┐
           │ 1:N             │ 1:N             │ 1:N
           ▼                 ▼                 ▼
┌────────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ ta_11_adeudo_local │ │ ta_11_pagos_local│ │ ta_11_movimientos│
│ - id_adeudo (PK)   │ │ - id_pago (PK)   │ │ - id_mov (PK)    │
│ - id_local (FK)    │ │ - id_local (FK)  │ │ - id_local (FK)  │
│ - axo, periodo     │ │ - axo, periodo   │ │ - tipo_mov       │
│ - importe          │ │ - importe        │ │ - fecha_mov      │
│ - fecha_alta       │ │ - fecha_pago     │ │ - id_usuario     │
│ - id_usuario       │ │ - caja, operacion│ │ - numero_memo    │
└────────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## Conclusiones

Este flujo completo de **8 procesos interconectados** permite:

1. ✅ **Gestionar el ciclo de vida completo** de un local de mercado municipal
2. 📊 **Controlar adeudos y pagos** de manera sistemática y auditable
3. 💼 **Generar reportes** para toma de decisiones y auditoría
4. 🔄 **Mantener trazabilidad** de todas las operaciones financieras
5. 📈 **Analizar históricos** para proyecciones y estadísticas

**Total de Stored Procedures:** ~45 SPs distribuidos en 11 archivos
**Total de Vistas Vue:** 11 componentes principales
**Datos en Producción:**
- 13,321 locales activos
- 223,515 adeudos pendientes
- 3,644,595 pagos históricos

---

**Fecha de documentación:** 2025-01-25
**Versión:** 1.0
**Autor:** Sistema de Análisis de Procesos
