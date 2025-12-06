# REPORTE FINAL: sp_localesmodif_buscar_local
**Fecha:** 2025-12-05
**Módulo:** Mercados - Prescripción de Adeudos de Energía
**Estado:** ✅ COMPLETADO Y FUNCIONANDO

---

## RESUMEN EJECUTIVO

El SP `sp_localesmodif_buscar_local` ha sido corregido y desplegado exitosamente en la base de datos `mercados`. El error original se debía a que el SP no estaba desplegado en la base correcta y estaba usando referencias a tablas incorrectas.

---

## PROBLEMA ORIGINAL

```
SQLSTATE[42883]: Undefined function: 7 ERROR:  function public.sp_localesmodif_buscar_local(unknown, unknown, unknown, unknown, unknown) does not exist
```

### Causa Raíz
- SP no desplegado en base `mercados`
- Archivos SQL originales apuntaban a `padron_licencias`
- Frontend llama al SP desde base `mercados`

---

## SOLUCIÓN FINAL

### Tabla Correcta
- **Esquema:** `publico`
- **Tabla Principal:** `publico.ta_11_locales`
- **Tabla Relacionada:** `public.ta_11_energia` (para campo `id_energia`)
- **Relación:** LEFT JOIN en `id_local`

### Estructura del SP

```sql
CREATE OR REPLACE FUNCTION sp_localesmodif_buscar_local(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR DEFAULT NULL,
    p_bloque VARCHAR DEFAULT NULL
)
RETURNS TABLE (33 campos...)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        ... (otros campos),
        e.id_energia,  -- De ta_11_energia vía JOIN
        COALESCE(l.arrendatario, '')::VARCHAR
    FROM publico.ta_11_locales l
    LEFT JOIN public.ta_11_energia e ON l.id_local = e.id_local
    WHERE ...
    LIMIT 1;
END;
$$