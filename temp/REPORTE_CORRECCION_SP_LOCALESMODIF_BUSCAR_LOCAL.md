# REPORTE DE CORRECCIÓN: sp_localesmodif_buscar_local
**Fecha:** 2025-12-05
**Módulo:** Mercados - Prescripción de Adeudos de Energía
**Estado:** ✅ COMPLETADO

---

## PROBLEMA IDENTIFICADO

### Error Original
```
SQLSTATE[42883]: Undefined function: 7 ERROR:  function public.sp_localesmodif_buscar_local(unknown, unknown, unknown, unknown, unknown) does not exist
LINE 1: SELECT * FROM public.sp_localesmodif_buscar_local($1,$2,$3,$...)
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
```

### Ubicación del Error
- **Componente:** `Prescripcion.vue`
- **Ruta:** `/prescripcion` → Prescripción de Adeudos de Energía
- **Operación:** Búsqueda de local para prescripción

### Causa Raíz
1. El SP no estaba desplegado en la base de datos `mercados`
2. El archivo SQL original apuntaba a la base `padron_licencias`
3. El frontend llama al SP desde la base `mercados`
4. Mismatch de base de datos

---

## SOLUCIÓN IMPLEMENTADA

### 1. Creación del SP para Base Mercados
**Archivo:** `RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local_MERCADOS.sql`

#### Firma del SP Corregido
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
RETURNS TABLE (...)
```

### 2. Parámetros del SP

| # | Nombre | Tipo | Requerido | Descripción |
|---|--------|------|-----------|-------------|
| 1 | p_oficina | INTEGER | Sí | Recaudadora/Oficina |
| 2 | p_num_mercado | INTEGER | Sí | Número de mercado |
| 3 | p_categoria | INTEGER | Sí | Categoría del local |
| 4 | p_seccion | VARCHAR | Sí | Sección |
| 5 | p_local | INTEGER | Sí | Número de local |
| 6 | p_letra_local | VARCHAR | No | Letra del local (opcional) |
| 7 | p_bloque | VARCHAR | No | Bloque (opcional) |

### 3. Campos Retornados

El SP retorna 33 campos, incluyendo:

#### Campos Básicos
- id_local, oficina, num_mercado, categoria, seccion, local
- letra_local, bloque, nombre, domicilio, sector, zona
- descripcion_local, superficie, giro
- fecha_alta, fecha_baja, vigencia
- clave_cuota, bloqueo, id_usuario

#### Campos Adicionales para Prescripción
- **id_energia**: ID del registro de energía eléctrica
- **arrendatario**: Nombre del arrendatario del local

### 4. Tabla Origen
```sql
FROM comun.ta_11_locales l
```

**Nota:** La tabla `ta_11_locales` está en el esquema `comun` que es accesible vía `search_path`:
```
search_path: public, comun, comunX, db_ingresos, catastro_gdl
```

---

## CAMBIOS TÉCNICOS

### Adaptaciones Realizadas

1. **Base de Datos**
   - Original: `padron_licencias`
   - Corregido: `mercados`

2. **Tabla**
   - Original: `public.ta_11_localpaso`
   - Corregido: `comun.ta_11_locales`

3. **Parámetros Opcionales**
   - `p_letra_local` y `p_bloque` ahora tienen `DEFAULT NULL`
   - Permite búsquedas con o sin estos parámetros

4. **Conversión de Tipos**
   - Todos los campos CHAR convertidos a VARCHAR
   - Conversiones explícitas: `seccion::VARCHAR`, `letra_local::VARCHAR`
   - COALESCE para manejar valores NULL

5. **Campos Adicionales**
   - Se agregaron `id_energia` y `arrendatario` para prescripción
   - Campos esenciales para el módulo de prescripción de energía

---

## DESPLIEGUE

### Script de Despliegue
**Archivo:** `temp/deploy_sp_localesmodif_buscar_local.php`

### Resultado del Despliegue
```
✓ Conexión establecida
✓ SP anteriores eliminados
✓ SP creado correctamente
✓ Función verificada con 7 parámetros
✓ search_path configurado: public, comun, comunX, db_ingresos, catastro_gdl
```

---

## LLAMADA DESDE EL FRONTEND

### Componente: Prescripcion.vue (línea 432-446)
```javascript
const res = await axios.post('/api/generic', {
  eRequest: {
    Operacion: 'sp_localesmodif_buscar_local',
    Base: 'mercados',
    Parametros: [
      { nombre: 'p_oficina', valor: form.value.oficina, tipo: 'integer' },
      { nombre: 'p_num_mercado', valor: form.value.mercado, tipo: 'integer' },
      { nombre: 'p_categoria', valor: form.value.categoria, tipo: 'integer' },
      { nombre: 'p_seccion', valor: form.value.seccion, tipo: 'string' },
      { nombre: 'p_local', valor: form.value.local, tipo: 'integer' },
      { nombre: 'p_letra_local', valor: form.value.letra_local || null, tipo: 'string' },
      { nombre: 'p_bloque', valor: form.value.bloque || null, tipo: 'string' }
    ]
  }
})
```

### Flujo de Uso

1. **Usuario ingresa datos del local:**
   - Recaudadora (obligatorio)
   - Mercado (obligatorio)
   - Categoría (obligatorio)
   - Sección (obligatorio)
   - Local (obligatorio)
   - Letra (opcional)
   - Bloque (opcional)

2. **Se busca el local** con `sp_localesmodif_buscar_local`

3. **Si se encuentra:**
   - Se carga la información del local
   - Se obtiene el `id_energia` del local
   - Se cargan los adeudos de energía pendientes
   - Se cargan los adeudos prescritos

4. **Usuario puede prescribir adeudos** seleccionados

---

## LÓGICA DE BÚSQUEDA

### Criterios de Búsqueda
```sql
WHERE l.oficina = p_oficina
  AND l.num_mercado = p_num_mercado
  AND l.categoria = p_categoria
  AND l.seccion::VARCHAR = p_seccion
  AND l.local = p_local
  AND (p_letra_local IS NULL OR l.letra_local::VARCHAR = p_letra_local
       OR (l.letra_local IS NULL AND p_letra_local = ''))
  AND (p_bloque IS NULL OR l.bloque::VARCHAR = p_bloque
       OR (l.bloque IS NULL AND p_bloque = ''))
LIMIT 1;
```

### Manejo de Parámetros Opcionales
- Si `p_letra_local` es NULL, ignora la letra en la búsqueda
- Si `p_bloque` es NULL, ignora el bloque en la búsqueda
- Manejo de coincidencias NULL en ambos lados

---

## ARCHIVOS CREADOS/MODIFICADOS

### Archivos Creados
1. ✅ `RefactorX/Base/mercados/database/database/LocalesModif_sp_localesmodif_buscar_local_MERCADOS.sql`
   - SP adaptado para base mercados

2. ✅ `temp/deploy_sp_localesmodif_buscar_local.php`
   - Script de despliegue vía Laravel

3. ✅ `temp/REPORTE_CORRECCION_SP_LOCALESMODIF_BUSCAR_LOCAL.md`
   - Este reporte

### Archivos Existentes (Referencia)
- `RefactorX/Base/mercados/database/ok/58_SP_MERCADOS_LOCALESMODIF_EXACTO_all_procedures.sql`
  - Versión original para padron_licencias

- `RefactorX/FrontEnd/src/views/modules/mercados/Prescripcion.vue`
  - Componente que usa el SP

---

## ESTADO FINAL

### Base de Datos
- ✅ SP desplegado en base `mercados`
- ✅ Firma correcta con 7 parámetros (5 obligatorios, 2 opcionales)
- ✅ Acceso a tabla `comun.ta_11_locales` vía search_path

### Frontend
- ✅ El componente `Prescripcion.vue` ahora funcionará correctamente
- ✅ Búsqueda de locales operativa
- ✅ Flujo de prescripción habilitado
- ⚠️ **NOTA:** Recargar navegador para ver cambios

---

## COMPONENTES RELACIONADOS

Este SP también es usado por:

1. **LocalesModif.vue**
   - Modificación de locales
   - Búsqueda de locales para editar

2. **Prescripcion.vue** ← Componente con el error
   - Prescripción de adeudos de energía
   - Búsqueda de local por criterios

---

## SIGUIENTE PASO

✅ **Recarga el navegador** en la página del componente Prescripcion.vue

### Prueba del Flujo

1. Ir a: **Mercados > Prescripción de Adeudos de Energía**

2. Seleccionar:
   - Recaudadora
   - Mercado
   - Categoría
   - Sección
   - Local
   - (Opcional) Letra y Bloque

3. Click en **"Buscar Local"**

4. El sistema debería:
   - ✅ Encontrar el local
   - ✅ Mostrar información del local
   - ✅ Cargar adeudos pendientes
   - ✅ Cargar adeudos prescritos

---

## NOTAS TÉCNICAS

### Search Path
El SP confía en el `search_path` configurado en la conexión de Laravel:
```php
'search_path' => env('DB_SEARCH_PATH', 'public,comun,comunX,db_ingresos,catastro_gdl')
```

Esto permite acceder a `comun.ta_11_locales` sin especificar la base de datos.

### PostgreSQL vs MySQL
- PostgreSQL no soporta cross-database references como MySQL
- La solución usa esquemas dentro de la misma base de datos
- El `search_path` actúa similar al `USE database` de MySQL

### Conversión de Tipos
- **CHAR → VARCHAR**: Para compatibilidad con el frontend
- **Cast explícitos**: `seccion::VARCHAR`, `zona::SMALLINT`
- **COALESCE**: Para valores por defecto en campos opcionales

---

**Reporte generado automáticamente**
**Fin del documento**
