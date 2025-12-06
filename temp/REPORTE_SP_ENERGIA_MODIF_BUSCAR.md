# REPORTE: sp_energia_modif_buscar
**Fecha:** 2025-12-05
**Módulo:** Mercados - Energía Modificación
**Estado:** ✅ COMPLETADO Y FUNCIONANDO
**Actualización:** Parámetros opcionales implementados

---

## PROBLEMA ORIGINAL

```
SQLSTATE[42883]: Undefined function: 7 ERROR:  function public.sp_energia_modif_buscar(unknown, unknown, unknown, unknown, unknown) does not exist
```

**Causa:** SP no desplegado en la base de datos `mercados`

---

## SOLUCIÓN

### SP Desplegado
**Archivo:** `RefactorX/Base/mercados/database/database/EnergiaModif_sp_energia_modif_buscar.sql`

```sql
CREATE OR REPLACE FUNCTION sp_energia_modif_buscar(
    p_oficina INTEGER,
    p_num_mercado INTEGER,
    p_categoria INTEGER,
    p_seccion VARCHAR,
    p_local INTEGER,
    p_letra_local VARCHAR DEFAULT NULL,  -- OPCIONAL
    p_bloque VARCHAR DEFAULT NULL         -- OPCIONAL
)
RETURNS TABLE (...)
```

### Parámetros

| # | Nombre | Tipo | Requerido | Descripción |
|---|--------|------|-----------|-------------|
| 1 | p_oficina | INTEGER | Sí | Recaudadora |
| 2 | p_num_mercado | INTEGER | Sí | Número de mercado |
| 3 | p_categoria | INTEGER | Sí | Categoría |
| 4 | p_seccion | VARCHAR | Sí | Sección |
| 5 | p_local | INTEGER | Sí | Número de local |
| 6 | p_letra_local | VARCHAR | **NO** | Letra del local (opcional) |
| 7 | p_bloque | VARCHAR | **NO** | Bloque (opcional) |

### Tablas Utilizadas
- **publico.ta_11_locales** (datos del local)
- **publico.ta_11_energia** (INNER JOIN - datos de energía)

---

## PRUEBAS REALIZADAS

### Test 1: Con 7 parámetros (letra=NULL, bloque=NULL)
```
✓ Encontrado: id_energia=1
```

### Test 2: Solo con 5 parámetros (omitiendo letra y bloque)
```
✓ Encontrado: id_energia=1
✓ cve_consumo: F
✓ cantidad: 962.15
```

### Test 3: Con 6 parámetros (con letra, sin bloque)
```
✓ Encontrado: id_energia=1
```

### Resumen de Pruebas ✅
- ✅ Con 5 parámetros (omitiendo letra y bloque)
- ✅ Con 6 parámetros (omitiendo bloque)
- ✅ Con 7 parámetros (todos incluidos)

---

## CAMPOS RETORNADOS

1. id_energia (INTEGER)
2. id_local (INTEGER)
3. cve_consumo (VARCHAR)
4. local_adicional (VARCHAR)
5. cantidad (NUMERIC)
6. vigencia (VARCHAR)
7. fecha_alta (DATE)
8. fecha_baja (DATE)
9. fecha_modificacion (TIMESTAMP)
10. id_usuario (INTEGER)

---

## COMPONENTE QUE USA ESTE SP

**EnergiaModif.vue**
- Ruta: `/energia-modif`
- Uso: Buscar registro de energía de un local para modificar
- Base: `mercados`

### Ejemplos de Uso

**Búsqueda con todos los parámetros:**
```javascript
Parametros: [
  { Nombre: 'p_oficina', Valor: 5 },
  { Nombre: 'p_num_mercado', Valor: 1 },
  { Nombre: 'p_categoria', Valor: 1 },
  { Nombre: 'p_seccion', Valor: 'EA' },
  { Nombre: 'p_local', Valor: 1 },
  { Nombre: 'p_letra_local', Valor: 'A' },
  { Nombre: 'p_bloque', Valor: '01' }
]
```

**Búsqueda sin letra ni bloque:**
```javascript
Parametros: [
  { Nombre: 'p_oficina', Valor: 5 },
  { Nombre: 'p_num_mercado', Valor: 1 },
  { Nombre: 'p_categoria', Valor: 1 },
  { Nombre: 'p_seccion', Valor: 'EA' },
  { Nombre: 'p_local', Valor: 1 }
  // p_letra_local y p_bloque se omiten o envían como null
]
```

---

## SIGUIENTE PASO

🔄 **Recarga el navegador** en:
**Mercados > Energía Modificación**

El módulo ahora funcionará correctamente para buscar y modificar registros de energía de locales.

---

**Estado: COMPLETADO ✅**
