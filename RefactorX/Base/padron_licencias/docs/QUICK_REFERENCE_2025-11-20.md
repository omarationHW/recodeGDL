# ⚡ QUICK REFERENCE - SESIÓN 2025-11-20

## 📊 NÚMEROS CLAVE

```
40 SPs implementados
7 componentes completados
~5,500 líneas de código SQL
~2,500 líneas de documentación
~900 líneas de tests
28.4% del módulo padron_licencias completado
```

---

## 🚀 DEPLOY EN 30 SEGUNDOS

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\ok
psql -U postgres -d guadalajara -f DEPLOY_SESION_2025-11-20_CONSOLIDADO.sql
psql -U postgres -d guadalajara -f VERIFICACION_DEPLOY_2025-11-20.sql
```

---

## 📦 COMPONENTES IMPLEMENTADOS

| # | Componente | SPs | Schema | Highlights |
|---|------------|-----|--------|------------|
| 1 | consultausuariosfrm | 9 | comun | bcrypt passwords, soft delete |
| 2 | dictamenfrm | 4 | comun | estadísticas, paginación |
| 3 | constanciafrm | 6 | public | auto-folio por año |
| 4 | repestado | 6 | comun | 50+ campos, JSON bonus |
| 5 | repdoc | 4 | comun | filtros JSONB, CTEs |
| 6 | certificacionesfrm | 7 | public | auto-folio, 7 filtros |
| 7 | DetalleLicencia | 4 | comun | cálculo recargos 2% |

---

## 🧪 PRUEBAS RÁPIDAS

```sql
-- Verificar 40 SPs desplegados
SELECT COUNT(*) FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('comun', 'public')
  AND p.proname LIKE 'sp_%';
-- Debe retornar: 40

-- Probar cada componente
SELECT * FROM comun.sp_get_all_usuarios(10, 0);
SELECT * FROM comun.sp_dictamenes_estadisticas();
SELECT * FROM public.sp_constancias_get_next_folio(2024);
SELECT * FROM comun.sp_repdoc_get_giros(10, 0, NULL::JSONB);
```

---

## 📂 ARCHIVOS IMPORTANTES

### Implementación (database/ok/)
- `CONSULTAUSUARIOS_all_procedures_IMPLEMENTED.sql` - 9 SPs usuarios
- `DICTAMENFRM_all_procedures_IMPLEMENTED.sql` - 4 SPs dictámenes
- `CONSTANCIAFRM_all_procedures_IMPLEMENTED.sql` - 6 SPs constancias
- `REPESTADO_all_procedures_IMPLEMENTED.sql` - 6 SPs reportes
- `REPDOC_all_procedures_IMPLEMENTED.sql` - 4 SPs docs/requisitos
- `CERTIFICACIONESFRM_all_procedures_IMPLEMENTED.sql` - 7 SPs certificaciones
- `DETALLELICENCIA_all_procedures_IMPLEMENTED.sql` - 4 SPs financiero

### Deployment
- `DEPLOY_SESION_2025-11-20_CONSOLIDADO.sql` - Deploy todo
- `VERIFICACION_DEPLOY_2025-11-20.sql` - Verificar todo

### Documentación (docs/)
- `RESUMEN_CONSOLIDADO_SESION_2025-11-20.md` - Resumen completo
- `INSTRUCCIONES_DEPLOY_2025-11-20.md` - Instrucciones detalladas
- `CONSULTAUSUARIOS_DOCUMENTACION.md` - Doc específica usuarios

### Tests
- `CONSULTAUSUARIOS_PRUEBAS.sql` - Suite completa tests

---

## 🎯 PATRÓN ESTÁNDAR

### SQL
```sql
CREATE OR REPLACE FUNCTION schema.sp_nombre(
    p_param1 TYPE DEFAULT NULL
)
RETURNS TABLE(col1 TYPE, col2 TYPE) AS $$
BEGIN
    RETURN QUERY SELECT ... FROM tabla;
END;
$$ LANGUAGE plpgsql;
```

### Vue
```javascript
await execute(
  'sp_nombre',
  'padron_licencias',
  [{ nombre: 'p_param1', valor: val, tipo: 'integer' }],
  'guadalajara',
  null,
  'public' // o 'comun'
)
```

---

## ⚠️ PREREQUISITOS

```sql
-- Instalar pgcrypto (para bcrypt)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar tablas requeridas
SELECT COUNT(*) FROM comun.usuarios;     -- consultausuariosfrm
SELECT COUNT(*) FROM comun.dictamenes;   -- dictamenfrm
SELECT COUNT(*) FROM public.constancias; -- constanciafrm
SELECT COUNT(*) FROM comun.tramites;     -- repestado
SELECT COUNT(*) FROM comun.c_giros;      -- repdoc
SELECT COUNT(*) FROM public.certificaciones; -- certificacionesfrm
SELECT COUNT(*) FROM comun.adeudos_licencia; -- DetalleLicencia
```

---

## 🔥 FEATURES DESTACADAS

### consultausuariosfrm (9 SPs)
- ✅ bcrypt con factor 8: `crypt(pass, gen_salt('bf', 8))`
- ✅ Soft delete con fecbaj
- ✅ CRUD completo + catálogos

### dictamenfrm (4 SPs)
- ✅ Estadísticas por estado (APROBADO, NEGADO, etc.)
- ✅ Paginación con `COUNT(*) OVER()`
- ✅ Filtros múltiples

### constanciafrm (6 SPs)
- ✅ Composite PK (axo, folio)
- ✅ Auto-folio: `MAX(folio) + 1 WHERE axo = 2024`
- ✅ LEFT JOIN con licencias

### repestado (6 SPs)
- ✅ 50+ campos en estado completo
- ✅ Función BONUS JSON consolidado
- ✅ Historial de revisiones

### repdoc (4 SPs)
- ✅ Filtros JSONB: `{"tipo": "comercial"}`
- ✅ CTEs para queries complejas
- ✅ Reports en JSON estructurado

### certificacionesfrm (7 SPs)
- ✅ Auto-folio desde parametros_lic
- ✅ Búsqueda con 7 filtros simultáneos
- ✅ Print function retorna JSON

### DetalleLicencia (4 SPs)
- ✅ Cálculo automático recargos 2% mensual
- ✅ Actualización 1.5% anual
- ✅ Función AGE() para meses vencidos
- ✅ Modo consulta vs actualización BD

---

## 📊 PROGRESO MÓDULO

```
Total componentes: 95
Completados previos: 20 (Batches 1-4)
Esta sesión: 7
TOTAL: 27/95 (28.4%)

[█████░░░░░░░░░░░░░░░] 28.4%

Pendientes: 68 componentes (~260-280 SPs)
```

---

## 🚀 PRÓXIMOS COMPONENTES SUGERIDOS

Prioridad ALTA (con buenas referencias):
- privilegios (14 SPs)
- doctosfrm (11 SPs)
- tipobloqueofrm (3 SPs)
- dependenciasfrm (4 SPs)
- formatosEcologiafrm (3 SPs)

**Estimado:** 35 SPs adicionales

---

## 🐛 TROUBLESHOOTING RÁPIDO

### Error: relation does not exist
```sql
-- Verificar tablas
SELECT schemaname, tablename FROM pg_tables
WHERE schemaname IN ('comun', 'public');
```

### Error: extension pgcrypto
```sql
CREATE EXTENSION pgcrypto;
```

### Error: function already exists
Los archivos usan `CREATE OR REPLACE`, NO debería pasar.

---

## 📞 COMANDOS ÚTILES

```bash
# Deploy
psql -U postgres -d guadalajara -f DEPLOY_SESION_2025-11-20_CONSOLIDADO.sql

# Verificar
psql -U postgres -d guadalajara -f VERIFICACION_DEPLOY_2025-11-20.sql

# Tests
psql -U postgres -d guadalajara -f CONSULTAUSUARIOS_PRUEBAS.sql

# Conectar BD
psql -U postgres -d guadalajara

# Ver funciones
\df comun.sp_*
\df public.sp_*

# Ver definición
\sf comun.sp_get_all_usuarios

# Iniciar Laravel
cd RefactorX/BackEnd && php artisan serve
```

---

## 📈 STATS DE PERFORMANCE

```sql
-- SPs más utilizados
SELECT schemaname, funcname, calls, total_time
FROM pg_stat_user_functions
WHERE schemaname IN ('comun', 'public')
ORDER BY calls DESC LIMIT 10;

-- SPs más lentos
SELECT schemaname, funcname, total_time / calls as avg_ms
FROM pg_stat_user_functions
WHERE schemaname IN ('comun', 'public') AND calls > 0
ORDER BY avg_ms DESC LIMIT 10;
```

---

## ✅ CHECKLIST

- [ ] Backup BD realizado
- [ ] pgcrypto instalada
- [ ] Tablas verificadas
- [ ] Deploy ejecutado
- [ ] 40 SPs confirmados
- [ ] Tests pasados
- [ ] Laravel iniciado
- [ ] Vue probado
- [ ] Logs OK

---

## 📚 DOCUMENTACIÓN COMPLETA

- **Resumen:** `RESUMEN_CONSOLIDADO_SESION_2025-11-20.md`
- **Instrucciones:** `INSTRUCCIONES_DEPLOY_2025-11-20.md`
- **Implementación:** `IMPLEMENTACION_SPS_SESION_2025-11-20.md`
- **Quick Ref:** `QUICK_REFERENCE_2025-11-20.md` (este archivo)

---

**Fecha:** 2025-11-20
**Estado:** ✅ COMPLETADO
**SPs:** 40
**Componentes:** 7
**Progreso:** 28.4%

---

**¡LISTO PARA DEPLOY!** 🚀
