# Resumen de Corrección - sp_padron_global

**Fecha:** 2025-12-03
**Base de Datos:** mercados (PostgreSQL)
**Host:** 192.168.6.146:5432
**Schema:** publico

---

## Problema Original

El stored procedure `sp_padron_global` tenía un **error de tipos de datos**:

- **Columna retornada:** `descripcion_local` como `CHARACTER VARYING(60)`
- **Tipo real en tabla:** `descripcion_local` es `CHARACTER(20)`
- **Error:** Mismatch de tipos causaba fallo al ejecutar el SP

### Otros problemas encontrados:
1. Campo `bloque` definido como `VARCHAR(5)` pero en la tabla es `VARCHAR(2)`
2. Campo `superficie` definido como `NUMERIC(7,2)` pero en la tabla es `NUMERIC` (sin precisión)
3. Ambigüedad en columna `id_local` en subquery de adeudos

---

## Solución Implementada

### 1. Verificación de Estructura Real de Tablas

#### publico.ta_11_locales
```
Columnas clave:
  - id_local: INTEGER (PRIMARY KEY)
  - oficina: SMALLINT
  - num_mercado: SMALLINT
  - categoria: SMALLINT
  - seccion: CHARACTER(2)
  - local: INTEGER
  - letra_local: CHARACTER VARYING(3)
  - bloque: CHARACTER VARYING(2)          ← Corregido de VARCHAR(5)
  - nombre: CHARACTER VARYING(60)
  - descripcion_local: CHARACTER(20)      ← CAMPO CLAVE CORREGIDO
  - superficie: NUMERIC                   ← Corregido de NUMERIC(7,2)
  - vigencia: CHARACTER(1)
  - clave_cuota: SMALLINT
```

#### publico.ta_11_mercados
```
  - oficina: SMALLINT
  - num_mercado_nvo: SMALLINT
  - descripcion: CHARACTER VARYING(30)
```

#### publico.ta_11_adeudo_local
```
  - id_adeudo_local: INTEGER
  - id_local: INTEGER                     ← Causa ambigüedad si no se califica
  - axo: SMALLINT
  - periodo: SMALLINT
  - importe: NUMERIC
```

#### publico.ta_11_cuo_locales
```
  - id_cuotas: INTEGER
  - axo: SMALLINT
  - categoria: SMALLINT
  - seccion: CHARACTER(2)
  - clave_cuota: SMALLINT
  - importe_cuota: NUMERIC
```

### 2. Cambios Realizados en el SP

**RETURNS TABLE actualizado con tipos correctos:**

```sql
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(2),            -- Corregido
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER(20),        -- Corregido (CLAVE)
    superficie NUMERIC,                     -- Corregido
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
```

**Subquery de adeudos corregido (ambigüedad):**

```sql
-- ANTES (causaba error de ambigüedad):
LEFT JOIN (
    SELECT id_local, COUNT(*)::INTEGER AS adeudos
    FROM publico.ta_11_adeudo_local
    WHERE (axo = p_year AND periodo <= p_month) OR (axo < p_year)
    GROUP BY id_local
) a ON a.id_local = l.id_local

-- DESPUÉS (calificado con alias):
LEFT JOIN (
    SELECT al.id_local, COUNT(*)::INTEGER AS adeudos
    FROM publico.ta_11_adeudo_local al
    WHERE (al.axo = p_year AND al.periodo <= p_month) OR (al.axo < p_year)
    GROUP BY al.id_local
) a ON a.id_local = l.id_local
```

### 3. Lógica de Negocio del SP

El SP calcula el padrón global de locales con:

**Parámetros de entrada:**
- `p_year` (INTEGER): Año del periodo
- `p_month` (INTEGER): Mes del periodo
- `p_status` (VARCHAR): Vigencia ('A', 'B', 'C', 'D', o 'T' para todos)

**Cálculo de renta:**
```sql
CASE
    -- PS con clave_cuota 4
    WHEN seccion = 'PS' AND clave_cuota = 4 THEN
        superficie * importe_cuota

    -- PS otros
    WHEN seccion = 'PS' THEN
        (importe_cuota * superficie) * 30

    -- Mercado 214
    WHEN num_mercado = 214 THEN
        superficie * importe_cuota * sabadosacum

    -- Default
    ELSE
        superficie * importe_cuota
END
```

**Determinación de adeudos:**
- Cuenta registros en `ta_11_adeudo_local` para el año/mes actual o anteriores
- Si >= 1 adeudo: "Local con Adeudo" (flag = 1)
- Si = 0 adeudos: "Local al Corriente de Pagos" (flag = 0)

**Joins realizados:**
1. `INNER JOIN ta_11_mercados` - Información del mercado
2. `LEFT JOIN ta_11_cuo_locales` - Cuotas del periodo
3. `LEFT JOIN (subquery adeudos)` - Conteo de adeudos
4. `LEFT JOIN ta_11_fecha_desc` - Factor de descuento/sábados

**Filtros:**
- Vigencia según parámetro `p_status` ('T' retorna todos)

**Ordenamiento:**
```
vigencia, oficina, num_mercado, categoria, seccion, local, letra_local, bloque
```

---

## Resultado de las Pruebas

**Configuración de prueba:**
- Año: 2025
- Mes: 12 (Diciembre)
- Vigencia: 'A'

**Resultados:**
✓ SP creado exitosamente
✓ SP ejecutado sin errores
✓ **12,945 registros** retornados con vigencia 'A'
✓ **13,320 registros** totales (vigencia 'T')

### Ejemplos de Registros Retornados:

**Registro 1:**
```
ID Local: 11256
Oficina: 1
Mercado: 2 - MEXICALTZINGO
Categoría: 1
Sección: SS
Local: 1A
Nombre: RODRIGUEZ LIRA DIANA PATRICIA
Descripción Local: [1-A                 ]  ← CHARACTER(20) correcto
Superficie: 16.25 m²
Vigencia: A
Clave Cuota: 9
Renta: $1,121.25
Adeudo: Local con Adeudo (1)
Registro: 1 2 1 SS 1 A
```

**Registro 2:**
```
ID Local: 11257
Oficina: 1
Mercado: 2 - MEXICALTZINGO
Local: 1B
Nombre: SANCHEZ BARRETO RICARDO
Descripción Local: [1-B                 ]  ← CHARACTER(20) correcto
Superficie: 22.67 m²
Renta: $1,564.23
Adeudo: Local con Adeudo (1)
```

**Registro 3:**
```
ID Local: 11258
Oficina: 1
Mercado: 2 - MEXICALTZINGO
Local: 2
Nombre: CASILLAS PLASCENCIA ISRAEL
Descripción Local: [2                   ]  ← CHARACTER(20) correcto
Superficie: 33.40 m²
Renta: $2,304.60
Adeudo: Local con Adeudo (1)
```

---

## Archivos Generados

1. **sp_padron_global_CORREGIDO.sql**
   Archivo SQL con el stored procedure corregido y documentado

2. **fix_sp_padron_global.js**
   Script Node.js que:
   - Verifica estructura de tablas
   - Elimina SP anterior
   - Crea SP corregido
   - Ejecuta pruebas
   - Muestra ejemplos de resultados

3. **fix_sp_padron_global.sql**
   Script SQL directo (para ejecutar con psql)

4. **fix_sp_padron_global.bat**
   Script batch para Windows (requiere psql en PATH)

5. **check_adeudo_table.js**
   Script auxiliar para verificar estructura de tablas de adeudos

---

## Comandos de Prueba

### Obtener todos los registros con vigencia 'A':
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'A');
```

### Obtener todos los registros (todas las vigencias):
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'T');
```

### Contar registros por vigencia:
```sql
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'A');  -- 12,945
SELECT COUNT(*) FROM publico.sp_padron_global(2025, 12, 'T');  -- 13,320
```

### Ver primeros 10 registros:
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'T') LIMIT 10;
```

### Ver locales con adeudos:
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'T')
WHERE adeudo = 1;
```

### Ver locales al corriente:
```sql
SELECT * FROM publico.sp_padron_global(2025, 12, 'T')
WHERE adeudo = 0;
```

---

## Verificación del Tipo de Datos

Para verificar que el SP retorna el tipo correcto:

```sql
SELECT
    column_name,
    data_type,
    character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'publico'
AND table_name = 'ta_11_locales'
AND column_name = 'descripcion_local';

-- Resultado:
-- descripcion_local | character | 20
```

---

## Conclusión

✅ **SP corregido exitosamente**
✅ **Tipos de datos coinciden exactamente con las tablas**
✅ **Ambigüedad de columnas resuelta**
✅ **Probado con datos reales**
✅ **Retorna 12,945 registros con vigencia 'A'**
✅ **Listo para producción**

### Estado Final:
- **Stored Procedure:** publico.sp_padron_global(INTEGER, INTEGER, VARCHAR)
- **Estado:** FUNCIONAL
- **Última actualización:** 2025-12-03
- **Registros de prueba:** 12,945 (vigencia 'A'), 13,320 (todas)

---

## Notas Técnicas

1. El campo `descripcion_local` es `CHARACTER(20)` con relleno de espacios
2. Todos los tipos deben coincidir EXACTAMENTE con la estructura de la tabla
3. PostgreSQL es estricto con los tipos, no hace conversión automática
4. El subquery de adeudos debe usar alias para evitar ambigüedad
5. El schema es `publico` (no `public`) - verificar nomenclatura

---

## Ejecución desde la línea de comandos

### Con Node.js (recomendado):
```bash
cd C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp
node fix_sp_padron_global.js
```

### Con psql (si está disponible):
```bash
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f sp_padron_global_CORREGIDO.sql
```

---

**FIN DEL RESUMEN**
