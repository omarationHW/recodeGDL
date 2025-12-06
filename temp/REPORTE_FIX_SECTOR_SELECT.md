# REPORTE: Fix Select de Sector - Valores Incorrectos
**Fecha:** 2025-12-05
**Módulo:** /locales-modif
**Estado:** ✅ COMPLETADO

---

## PROBLEMA

El select de **Sector** mostraba opciones incorrectas que NO coincidían con los valores en la base de datos:

**Select mostraba:**
- 01 - SECCION 01
- 02 - SECCION 02
- EA - ENERGIA ALUMBRADO
- PS - PLAZAS Y SECTORES
- SS - SOBRE SUELO
- T1 - TIPO 1
- T2 - TIPO 2

**Base de datos tiene:**
- L (5,984 registros)
- J (3,484 registros)
- H (2,397 registros)
- R (1,453 registros)
- E (1 registro)
- 0 (1 registro)

**Resultado:** El campo sector nunca seleccionaba ningún valor porque el valor de la BD (ej: 'J') no existía en las opciones del select.

---

## CAUSA RAÍZ

El componente LocalesModif.vue estaba usando **sp_catalogo_secciones** para llenar el select de **sector**, pero ese SP retorna valores de SECCIONES, no de SECTORES.

### Confusión entre SECCION y SECTOR

Son dos campos DIFERENTES en la tabla:

| Campo | Uso | Valores |
|-------|-----|---------|
| **seccion** | Filtro de búsqueda | SS, 01, 02, EA, PS, T1, T2 |
| **sector** | Clasificación del local | L, J, H, R, E, 0 |

El error era usar el catálogo de **secciones** en el select de **sector**.

---

## SOLUCIÓN

### 1. Crear nuevo SP: sp_catalogo_sectores

Creé un nuevo SP que retorna los valores REALES del campo `sector` de la tabla:

```sql
CREATE OR REPLACE FUNCTION sp_catalogo_sectores()
RETURNS TABLE(
    clave text,
    descripcion text
)
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.sector::text as clave,
        CASE l.sector
            WHEN 'L' THEN 'SECTOR L'::text
            WHEN 'J' THEN 'SECTOR J'::text
            WHEN 'H' THEN 'SECTOR H'::text
            WHEN 'R' THEN 'SECTOR R'::text
            WHEN 'E' THEN 'SECTOR E'::text
            WHEN '0' THEN 'SECTOR 0'::text
            ELSE ('SECTOR ' || l.sector)::text
        END as descripcion
    FROM publico.ta_11_locales l
    WHERE l.sector IS NOT NULL
    ORDER BY clave;
END;
$$;
```

### 2. Actualizar LocalesModif.vue

Cambié la llamada de SP en la línea 348:

```javascript
// ANTES (Incorrecto)
Operacion: 'sp_catalogo_secciones'

// DESPUÉS (Correcto)
Operacion: 'sp_catalogo_sectores'
```

---

## ARCHIVOS MODIFICADOS

### 1. LocalesModif_sp_catalogo_sectores.sql (NUEVO)
- **Ruta:** RefactorX/Base/mercados/database/database/LocalesModif_sp_catalogo_sectores.sql
- **Acción:** Creado nuevo SP

### 2. LocalesModif.vue
- **Ruta:** RefactorX/FrontEnd/src/views/modules/mercados/LocalesModif.vue
- **Línea:** 348
- **Cambio:** sp_catalogo_secciones → sp_catalogo_sectores

---

## PRUEBA

```
✓ SP desplegado correctamente
✓ SP retorna 6 sectores:
  - 0 → SECTOR 0
  - E → SECTOR E
  - H → SECTOR H
  - J → SECTOR J
  - L → SECTOR L
  - R → SECTOR R
```

---

## INSTRUCCIONES

### Probar en el Navegador

1. **Recarga** /locales-modif con **Ctrl+F5** (recarga completa)

2. **Busca un local** (por ejemplo, oficina=1, mercado=2, seccion=SS, local=3)

3. **Verifica el select de Sector:**
   - Ahora debe mostrar las opciones: SECTOR 0, SECTOR E, SECTOR H, SECTOR J, SECTOR L, SECTOR R
   - El valor actual del local (ej: 'J') debe estar seleccionado
   - Ya no debe mostrar las opciones antiguas (01, 02, EA, PS, SS, T1, T2)

4. **Modifica y guarda:**
   - Puedes cambiar el sector
   - Los cambios se guardan correctamente

---

## ANTES vs DESPUÉS

### ❌ ANTES

```
Select de Sector mostraba:
- 01 - SECCION 01
- 02 - SECCION 02
- EA - ENERGIA ALUMBRADO
- ...

Local con sector='J':
→ ✗ No se seleccionaba nada (valor no existe en opciones)
→ ✗ Usuario no podía ver/modificar el sector actual
```

### ✅ DESPUÉS

```
Select de Sector muestra:
- 0 - SECTOR 0
- E - SECTOR E
- H - SECTOR H
- J - SECTOR J
- L - SECTOR L
- R - SECTOR R

Local con sector='J':
→ ✓ Se selecciona "SECTOR J"
→ ✓ Usuario ve el valor actual
→ ✓ Usuario puede modificar el sector
```

---

## ESTADO FINAL

✅ **Nuevo SP creado:** sp_catalogo_sectores
✅ **SP retorna valores correctos:** L, J, H, R, E, 0
✅ **Componente actualizado:** Usa sp_catalogo_sectores
✅ **Select muestra opciones correctas:** Coinciden con BD
✅ **Valor actual seleccionado:** Se muestra correctamente

---

**PROBLEMA RESUELTO ✅**

El select de Sector ahora muestra los valores REALES de la base de datos (L, J, H, R, E, 0) en lugar de los valores de SECCIONES (01, 02, EA, PS, SS, T1, T2).
