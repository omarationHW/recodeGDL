# Solución: Error en DatosRequerimientos - sp_get_locales

## Error Original
```
SQLSTATE[42P01]: Undefined table: 7 ERROR:  relation "ta_11_locales" does not exist
LINE 2:     FROM ta_11_locales a
```

## Causa del Problema
El SP `sp_get_locales` estaba accediendo a la tabla `ta_11_locales` sin especificar el schema `public.`.

## Correcciones Aplicadas

### 1. Archivo Individual Corregido
📁 `RefactorX/Base/mercados/database/database/DatosRequerimientos_sp_get_locales.sql`

**Cambio:** Agregado schema `public.` y alias `a` a la tabla

```sql
-- ANTES:
FROM ta_11_locales
WHERE id_local = p_id_local;

-- DESPUÉS:
FROM public.ta_11_locales a
WHERE a.id_local = p_id_local;
```

### 2. Archivo Consolidado Corregido
📁 `RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql`

**Cambios:**
1. Base de datos corregida: `padron_licencias` → `ingresos`
2. Agregado alias `a` a la consulta de `sp_get_locales`

## Comando de Despliegue

Para aplicar la corrección, ejecuta desde el servidor:

```bash
# Opción 1: Ejecutar script PHP de despliegue
php temp/deploy_sp_get_locales_fix.php

# Opción 2: Ejecutar SQL directamente con psql
psql -h 192.168.20.31 -p 5432 -U postgres -d ingresos -f RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql
```

## Verificación

Después del despliegue, verifica que funcione:

```bash
# 1. Verificar que el SP existe
psql -h 192.168.20.31 -U postgres -d ingresos -c "\df sp_get_locales"

# 2. Probar el SP con un ID de local válido
psql -h 192.168.20.31 -U postgres -d ingresos -c "SELECT * FROM sp_get_locales(1)"
```

## Archivos Modificados

✅ `DatosRequerimientos_sp_get_locales.sql` - Schema agregado
✅ `45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql` - Base de datos y schema corregidos
📄 `temp/deploy_sp_get_locales_fix.php` - Script de despliegue creado

## Estado
- [x] Archivos corregidos
- [ ] Despliegue pendiente (requiere acceso al servidor)
- [ ] Verificación pendiente

Una vez desplegado, el error en DatosRequerimientos debe resolverse y la búsqueda funcionará correctamente.
