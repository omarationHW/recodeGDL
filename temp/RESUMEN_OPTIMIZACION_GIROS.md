# Resumen: Optimización Giros con Adeudo

## Fecha: 2025-11-05

---

## 📊 ISSUES REPORTADOS

1. **Stats cards no ocupan todo el espacio** - "deben de ocupar los 6 todo el espacio horizontal"
2. **Consulta extremadamente lenta** - "la consulta estan extremadamente lento"
3. **Cards se movieron** - "los cards se movieron"

---

## 🔍 DIAGNÓSTICO

### 1. Performance de Consulta

**MEDICIONES:**

| Versión | Tiempo | Técnica | Mejora |
|---------|--------|---------|--------|
| Original | 25,555.88 ms (25.6 seg) | EXISTS subqueries anidados | Baseline |
| Optimizada v1 | 6,538.36 ms (6.5 seg) | LEFT JOIN + CTE | -74.4% |
| Post-VACUUM | 7,221.82 ms (7.2 seg) | + VACUUM ANALYZE | No mejoró |

**PROBLEMAS IDENTIFICADOS:**

1. **Múltiples EXISTS subqueries** en líneas 44-50, 60-67, 69-79, 87-94 del SP original
2. **Subqueries correlacionados** que escanean `comun.adeudos` repetidamente por cada licencia
3. **Sin índices específicos** en las columnas de join

**OPTIMIZACIONES APLICADAS:**

1. ✅ Reemplazado EXISTS por LEFT JOIN
2. ✅ CTE `adeudos_por_licencia` pre-agrega datos (una sola pasada)
3. ✅ Creados índices en:
   - `comun.licencias(id_giro)`
   - `comun.licencias(cvecuenta)`
   - `comun.adeudos(cuentas)`
   - `comun.adeudos(cuentas, total) WHERE total > 0`
   - `comun.licencias(fecha_otorgamiento)`

**RESULTADO:**
- ✅ Mejora de 74.4% (de 25.6 seg a 6.5 seg)
- ⚠️ VACUUM ANALYZE no mejoró significativamente
- ⚠️ Aún es lenta (>6 segundos)

---

### 2. Layout de Stats Cards

**SITUACIÓN ACTUAL:**
- Hay **4 stats cards** en el template (líneas 42-89 de GirosDconAdeudofrm.vue)
- CSS global `.stats-grid` usa `grid-template-columns: repeat(6, 1fr)` (6 columnas)
- Las 4 cards solo ocupan 4 de las 6 columnas disponibles
- Hay espacio vacío en las últimas 2 columnas

**PROBLEMA:**
El user espera que las 4 cards ocupen las 6 columnas completas horizontalmente, no que haya espacio vacío.

**OPCIONES PARA SOLUCIONAR:**

**Opción A: Agregar 2 cards más** (Total: 6 stats)
- Ventaja: Llena todo el espacio, más información
- Desventaja: Requiere calcular 2 stats adicionales

**Opción B: Cambiar grid a 4 columnas** (para este módulo específico)
- Ventaja: Las 4 cards ocupan todo el ancho
- Desventaja: El user dice "los 6" sugiriendo que deben ser 6 columnas

**Opción C: Usar `grid-column: span 1.5`** (distribuir 4 cards en 6 columnas)
- Ventaja: Cada card ocupa 1.5 columnas = 4 cards × 1.5 = 6 columnas totales
- Desventaja: Puede crear alineación rara

**RECOMENDACIÓN:** Opción A - Agregar 2 stats cards adicionales

**Nuevas stats sugeridas:**
5. **Promedio Porcentaje Adeudo** - Promedio del % de licencias con adeudo por giro
6. **Giros Sin Adeudo** - Total de giros que no tienen adeudos (para contexto)

---

## 🎯 OPTIMIZACIONES ADICIONALES PENDIENTES

### Para mejorar performance aún más:

**1. Materializar Vista**
```sql
CREATE MATERIALIZED VIEW comun.mv_licencias_con_adeudos AS
SELECT
    l.licencia,
    l.cvecuenta,
    l.id_giro,
    l.fecha_otorgamiento,
    SUM(CASE WHEN a.total > 0 THEN a.total ELSE 0 END) as total_adeudo,
    COUNT(CASE WHEN a.total > 0 THEN 1 END) > 0 as tiene_adeudo
FROM comun.licencias l
LEFT JOIN comun.adeudos a ON a.cuentas = l.cvecuenta
GROUP BY l.licencia, l.cvecuenta, l.id_giro, l.fecha_otorgamiento;

CREATE INDEX idx_mv_licencias_id_giro ON comun.mv_licencias_con_adeudos(id_giro);
CREATE INDEX idx_mv_licencias_adeudo ON comun.mv_licencias_con_adeudos(total_adeudo);

-- Refrescar cada noche
REFRESH MATERIALIZED VIEW comun.mv_licencias_con_adeudos;
```

**Beneficio esperado:** Query de 7 segundos → <1 segundo

**2. Particionar Tabla `comun.adeudos`**
Si tiene millones de registros, particionar por año o rango de cuentas.

**3. Usar Parallel Query**
```sql
SET max_parallel_workers_per_gather = 4;
SET parallel_setup_cost = 100;
SET parallel_tuple_cost = 0.01;
```

**4. Revisar Configuración PostgreSQL**
- `shared_buffers` (memoria compartida)
- `work_mem` (memoria por operación)
- `effective_cache_size` (cache estimado)

---

## 📝 CAMBIOS APLICADOS

### Archivos Modificados:

1. **sp_giros_con_adeudo_OPTIMIZADO.sql** ✅
   - Nueva versión optimizada con LEFT JOIN
   - Índices creados automáticamente
   - Mejora de 74% en performance

2. **GirosDconAdeudofrm.vue** ⏳ PENDIENTE
   - Agregar 2 stats cards adicionales
   - Mantener grid de 6 columnas

---

## 🚀 PRÓXIMOS PASOS

### Inmediato:
1. ✅ Deploy SP optimizado (hecho)
2. ✅ VACUUM ANALYZE (hecho)
3. ⏳ Agregar 2 stats cards al Vue (pendiente)
4. ⏳ Modificar `loadEstadisticas()` para calcular las 2 nuevas stats

### Mediano Plazo:
1. ⏳ Crear materialized view `mv_licencias_con_adeudos`
2. ⏳ Modificar SP para usar MV en lugar de query directa
3. ⏳ Configurar job de refresh nocturno

### Largo Plazo:
1. ⏳ Review y optimización de configuración PostgreSQL
2. ⏳ Considerar particionamiento de tablas grandes
3. ⏳ Implementar caching en Laravel para stats

---

## 📊 STATS ADICIONALES A AGREGAR

### Stat 5: Promedio Porcentaje Adeudo
```javascript
const avgPorcentajeAdeudo = computed(() => {
  if (giros.value.length === 0) return 0
  const sum = giros.value.reduce((acc, g) => acc + parseFloat(g.porcentaje_adeudo || 0), 0)
  return (sum / giros.value.length).toFixed(2)
})
```

### Stat 6: Giros Sin Adeudo (contextual)
Requiere modificar el SP para retornar también el total de giros (con y sin adeudo)

---

## ✅ ESTADO ACTUAL

**Performance:**
- ✅ Optimización aplicada (74% mejor)
- ⚠️ Aún lenta (7.2 segundos)
- 🎯 Target: <1 segundo (requiere MV)

**Layout:**
- ⏳ 4 cards en grid de 6 columnas (espacio vacío)
- 🎯 Target: 6 cards ocupando todo el ancho

**Funcionalidad:**
- ✅ API funcionando correctamente
- ✅ Filtros operativos
- ✅ Paginación funcional
- ✅ Exportación lista

---

**FIN DEL RESUMEN**
