# Solución al Error en sp_cons_condonacion_energia

## Problema Reportado

```
SQLSTATE[42703]: Undefined column: 7 ERROR: column u.id_usuario does not exist
LINE 27: ...FT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuar...
```

## Causa Raíz

El stored procedure `sp_cons_condonacion_energia` está intentando hacer un JOIN con:
```sql
LEFT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuario
```

**El problema**: La tabla `catastro_gdl.usuarios` NO tiene la columna `id_usuario`.

## Schemas Correctos

Según el análisis del código y otros SPs funcionales, los schemas correctos son:

| Tabla | Schema Correcto | Schema Incorrecto |
|-------|----------------|-------------------|
| ta_11_locales | `comun` | ✓ |
| ta_11_energia | `"comunX"` | ✓ |
| ta_11_adeudo_energ | `"comunX"` | ✓ |
| ta_11_ade_ene_canc | `db_ingresos` | ✓ |
| usuarios | `public` | ✗ catastro_gdl |

## Solución Aplicada

Se corrigió la línea del JOIN:

**ANTES (Incorrecto):**
```sql
LEFT JOIN catastro_gdl.usuarios u ON c.id_usuario = u.id_usuario
```

**DESPUÉS (Correcto):**
```sql
LEFT JOIN public.usuarios u ON c.id_usuario = u.id_usuario
```

Además, se agregó un `COALESCE` para manejar el caso de usuarios nulos:
```sql
COALESCE(u.usuario, 'SISTEMA'::varchar) as usuario
```

## Archivos Generados

1. **fix_sp_cons_condonacion_energia_final.sql** - Script SQL con la corrección
2. **deploy_sp_cons_condonacion_fix.bat** - Script para desplegar automáticamente
3. **fix_sp_cons_condonacion_energia_final.php** - Script PHP para verificar y desplegar

## Cómo Desplegar

### Opción 1: Usando psql (Recomendado)

```bash
psql -h localhost -p 5432 -U postgres -d padron_licencias -f temp/fix_sp_cons_condonacion_energia_final.sql
```

### Opción 2: Usando el script .bat

```bash
temp\deploy_sp_cons_condonacion_fix.bat
```

### Opción 3: Usando PHP

```bash
php temp/fix_sp_cons_condonacion_energia_final.php
```

## Verificación

Después de desplegar, verifica que el SP funcione correctamente ejecutando:

```sql
-- Buscar un local con condonaciones
SELECT * FROM sp_cons_condonacion_energia(1, 1, 1, 'A', 1, NULL, NULL);
```

## Query Completo Corregido

```sql
SELECT
    c.id_cancelacion as id_condonacion,
    l.id_local,
    e.id_energia,
    l.oficina,
    l.num_mercado,
    l.categoria,
    l.seccion,
    l.local,
    l.letra_local,
    l.bloque,
    l.nombre as nombre_local,
    l.arrendatario,
    l.vigencia,
    c.axo,
    c.periodo,
    c.fecha_alta as fecha_condonacion,
    ae.importe as importe_original,
    c.importe as importe_condonado,
    c.clave_canc as motivo,
    c.observacion,
    COALESCE(u.usuario, 'SISTEMA'::varchar) as usuario
FROM comun.ta_11_locales l
INNER JOIN "comunX".ta_11_energia e ON l.id_local = e.id_local
INNER JOIN "comunX".ta_11_adeudo_energ ae ON e.id_energia = ae.id_energia
INNER JOIN db_ingresos.ta_11_ade_ene_canc c ON ae.id_energia = c.id_energia
LEFT JOIN public.usuarios u ON c.id_usuario = u.id_usuario  -- ← CORREGIDO
WHERE l.oficina = p_oficina
  AND l.num_mercado = p_num_mercado
  AND l.categoria = p_categoria
  AND l.seccion = p_seccion
  AND l.local = p_local
  AND (l.letra_local = p_letra_local OR (p_letra_local IS NULL AND l.letra_local IS NULL))
  AND (l.bloque = p_bloque OR (p_bloque IS NULL AND l.bloque IS NULL))
ORDER BY c.axo DESC, c.periodo DESC;
```

## Estado

- ⚠️ **PENDIENTE**: Despliegue de corrección (PostgreSQL no está corriendo actualmente)
- ✅ **LISTO**: Archivos de corrección generados
- ⏳ **SIGUIENTE**: Desplegar cuando PostgreSQL esté disponible

## Notas Importantes

1. Este error solo afecta a `sp_cons_condonacion_energia`
2. Otros SPs de condonaciones/pagos usan los schemas correctos
3. El cambio no afecta la lógica del negocio, solo corrige la referencia de schema
4. Si la tabla `public.usuarios` no tiene registros, se devolverá 'SISTEMA' como usuario
