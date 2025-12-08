# 📘 INSTRUCCIONES DE DEPLOY - SESIÓN 2025-11-20

## 🎯 RESUMEN

Esta sesión implementó **40 stored procedures** distribuidos en **7 componentes** del módulo `padron_licencias`:

| Componente | SPs | Schema | Descripción |
|------------|-----|--------|-------------|
| consultausuariosfrm | 9 | comun | Gestión de usuarios con bcrypt |
| dictamenfrm | 4 | comun | Dictámenes de uso de suelo |
| constanciafrm | 6 | public | Constancias con auto-folio |
| repestado | 6 | comun | Reportes de estado de trámites |
| repdoc | 4 | comun | Reportes de documentos/requisitos |
| certificacionesfrm | 7 | public | Certificaciones con auto-folio |
| DetalleLicencia | 4 | comun | Gestión financiera de licencias |
| **TOTAL** | **40** | - | - |

---

## 🚀 OPCIÓN 1: DEPLOY RÁPIDO (RECOMENDADO)

### Usando el script consolidado

```bash
# 1. Navegar al directorio
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\ok

# 2. Ejecutar deploy consolidado
psql -U postgres -d guadalajara -f DEPLOY_SESION_2025-11-20_CONSOLIDADO.sql

# 3. Verificar deployment
psql -U postgres -d guadalajara -f VERIFICACION_DEPLOY_2025-11-20.sql
```

**Tiempo estimado:** 2-3 minutos

---

## 🔧 OPCIÓN 2: DEPLOY MANUAL POR COMPONENTE

Si prefieres desplegar uno por uno para verificar cada componente:

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\ok

# BATCH 1 - Primera Fase (19 SPs)
psql -U postgres -d guadalajara -f CONSULTAUSUARIOS_all_procedures_IMPLEMENTED.sql
psql -U postgres -d guadalajara -f DICTAMENFRM_all_procedures_IMPLEMENTED.sql
psql -U postgres -d guadalajara -f CONSTANCIAFRM_all_procedures_IMPLEMENTED.sql

# BATCH 2 - Segunda Fase (21 SPs)
psql -U postgres -d guadalajara -f REPESTADO_all_procedures_IMPLEMENTED.sql
psql -U postgres -d guadalajara -f REPDOC_all_procedures_IMPLEMENTED.sql
psql -U postgres -d guadalajara -f CERTIFICACIONESFRM_all_procedures_IMPLEMENTED.sql
psql -U postgres -d guadalajara -f DETALLELICENCIA_all_procedures_IMPLEMENTED.sql
```

**Tiempo estimado:** 5-7 minutos

---

## ✅ VERIFICACIÓN POST-DEPLOY

### 1. Verificación Automatizada

```bash
psql -U postgres -d guadalajara -f VERIFICACION_DEPLOY_2025-11-20.sql
```

Este script verifica:
- ✓ Que los 40 SPs estén desplegados
- ✓ Que estén en los schemas correctos (comun/public)
- ✓ Que sean FUNCTIONS (no PROCEDURES)
- ✓ Que la extensión pgcrypto esté instalada

### 2. Verificación Manual

```sql
-- Contar SPs desplegados
SELECT COUNT(*) as total_sps
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('comun', 'public')
  AND p.proname IN (
      -- consultausuariosfrm
      'sp_get_all_usuarios', 'sp_buscar_usuario', 'sp_buscar_usuario_por_nombre',
      'sp_buscar_usuario_por_depto', 'sp_crear_usuario', 'sp_actualizar_usuario',
      'sp_eliminar_usuario', 'sp_get_departamentos', 'sp_get_dependencias',
      -- dictamenfrm
      'sp_dictamenes_estadisticas', 'sp_dictamenes_list',
      'sp_dictamenes_create', 'sp_dictamenes_update',
      -- constanciafrm
      'sp_constancias_list', 'sp_constancias_get', 'sp_constancias_create',
      'sp_constancias_update', 'sp_constancias_cancel', 'sp_constancias_get_next_folio',
      -- repestado
      'sp_repestado_get_tramite_estado', 'sp_repestado_get_tramite_revisiones',
      'sp_repestado_get_revision_detalle', 'sp_repestado_get_dependencia',
      'sp_repestado_get_giro', 'sp_repestado_get_estado_completo',
      -- repdoc
      'sp_repdoc_get_giros', 'sp_repdoc_get_requisitos_by_giro',
      'sp_repdoc_print_requisitos', 'sp_repdoc_print_permisos_eventuales',
      -- certificacionesfrm
      'sp_certificaciones_list', 'sp_certificaciones_get', 'sp_certificaciones_create',
      'sp_certificaciones_update', 'sp_certificaciones_cancel',
      'sp_certificaciones_search', 'sp_certificaciones_print',
      -- DetalleLicencia
      'sp_get_saldo_licencia', 'sp_get_detalle_licencia',
      'sp_get_historial_pagos', 'sp_calcular_adeudo_licencia'
  );

-- Debe retornar: 40
```

---

## 🧪 PRUEBAS FUNCIONALES

### 1. Ejecutar Suite de Tests (consultausuariosfrm)

```bash
psql -U postgres -d guadalajara -f CONSULTAUSUARIOS_PRUEBAS.sql
```

Este archivo contiene tests completos para el componente más crítico.

### 2. Pruebas Manuales Rápidas

```sql
-- Probar consultausuariosfrm
SELECT * FROM comun.sp_get_all_usuarios(10, 0);

-- Probar dictamenfrm
SELECT * FROM comun.sp_dictamenes_estadisticas();

-- Probar constanciafrm
SELECT * FROM public.sp_constancias_get_next_folio(2024);

-- Probar repestado (requiere ID válido de trámite)
-- SELECT * FROM comun.sp_repestado_get_tramite_estado(1);

-- Probar repdoc
SELECT * FROM comun.sp_repdoc_get_giros(10, 0, NULL::JSONB);

-- Probar certificacionesfrm
SELECT * FROM public.sp_certificaciones_list(NULL, 10, 0);

-- Probar DetalleLicencia (requiere número de licencia válido)
-- SELECT * FROM comun.sp_get_saldo_licencia('LIC-001');
```

---

## 🔌 INTEGRACIÓN CON LARAVEL/VUE

### 1. Iniciar Servidor Laravel

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\BackEnd
php artisan serve
```

### 2. Probar desde Vue (Ejemplo)

```javascript
// En cualquier componente Vue con access a execute()
import { execute } from '@/composables/useDatabase';

// Ejemplo: Listar usuarios
const response = await execute(
  'sp_get_all_usuarios',
  'padron_licencias',
  [
    { nombre: 'p_limit', valor: 10, tipo: 'integer' },
    { nombre: 'p_offset', valor: 0, tipo: 'integer' }
  ],
  'guadalajara',
  null,
  'comun'
);

console.log(response.data);

// Ejemplo: Crear constancia
const responseCreate = await execute(
  'sp_constancias_create',
  'padron_licencias',
  [
    { nombre: 'p_axo', valor: 2024, tipo: 'integer' },
    { nombre: 'p_folio', valor: 123, tipo: 'integer' },
    { nombre: 'p_id_licencia', valor: 456, tipo: 'integer' },
    { nombre: 'p_solicita', valor: 'Juan Pérez', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'public'
);

console.log(responseCreate.data);
```

### 3. Probar desde API REST

```bash
# Endpoint genérico
POST http://localhost:8000/api/generic/execute

# Body (JSON)
{
  "sp_name": "sp_get_all_usuarios",
  "module": "padron_licencias",
  "params": [
    { "nombre": "p_limit", "valor": 10, "tipo": "integer" },
    { "nombre": "p_offset", "valor": 0, "tipo": "integer" }
  ],
  "database": "guadalajara",
  "schema": "comun"
}
```

---

## ⚠️ PREREQUISITOS

### 1. Extensión pgcrypto

**Requerida para:** consultausuariosfrm (bcrypt password hashing)

```sql
-- Verificar si está instalada
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

-- Si no está, instalarla
CREATE EXTENSION pgcrypto;
```

### 2. Tablas Requeridas

#### Schema `comun`:
- `usuarios` - Para consultausuariosfrm
- `dictamenes` - Para dictamenfrm
- `tramites` - Para repestado
- `licencias` - Para repestado, DetalleLicencia
- `empresas` - Para repestado
- `c_giros` - Para repestado, repdoc
- `requisitos` - Para repdoc
- `liga_giro_requisito` - Para repdoc
- `adeudos_licencia` - Para DetalleLicencia
- `pagos_licencia` - Para DetalleLicencia

#### Schema `public`:
- `constancias` - Para constanciafrm
- `certificaciones` - Para certificacionesfrm
- `parametros_lic` - Para certificacionesfrm (auto-folio)

### 3. Permisos de Usuario PostgreSQL

El usuario debe tener permisos de:
- `CREATE FUNCTION` en schemas `comun` y `public`
- `SELECT, INSERT, UPDATE` en las tablas mencionadas

---

## 🐛 TROUBLESHOOTING

### Error: "relation does not exist"

**Causa:** Falta una tabla requerida

**Solución:**
```sql
-- Verificar qué tablas existen
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname IN ('comun', 'public')
ORDER BY schemaname, tablename;

-- Crear las tablas faltantes o ajustar los SPs
```

### Error: "extension pgcrypto does not exist"

**Causa:** Extensión no instalada

**Solución:**
```sql
CREATE EXTENSION pgcrypto;
```

### Error: "function already exists"

**Causa:** Deploy duplicado

**Solución:** Los archivos SQL usan `CREATE OR REPLACE`, así que NO debería pasar. Si pasa:
```sql
-- Ver versión existente
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'nombre_del_sp';

-- Si es necesario, eliminar y recrear
DROP FUNCTION IF EXISTS schema.nombre_del_sp;
```

### Error: "could not execute query"

**Causa:** Sintaxis SQL incorrecta o falta parámetro

**Solución:**
```sql
-- Ver logs de PostgreSQL
-- En Windows: C:\Program Files\PostgreSQL\XX\data\log\

-- Ver definición del SP
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'nombre_del_sp';
```

---

## 📊 MONITOREO POST-DEPLOY

### Ver SPs más utilizados

```sql
SELECT
    schemaname,
    funcname,
    calls,
    total_time,
    self_time
FROM pg_stat_user_functions
WHERE schemaname IN ('comun', 'public')
ORDER BY calls DESC
LIMIT 20;
```

### Ver SPs más lentos

```sql
SELECT
    schemaname,
    funcname,
    calls,
    total_time / calls as avg_time_ms
FROM pg_stat_user_functions
WHERE schemaname IN ('comun', 'public')
  AND calls > 0
ORDER BY avg_time_ms DESC
LIMIT 20;
```

---

## 🔄 ROLLBACK (Si es necesario)

### Eliminar todos los SPs de esta sesión

```sql
-- ADVERTENCIA: Esto eliminará los 40 SPs
-- Solo usar si necesitas hacer rollback completo

DROP FUNCTION IF EXISTS comun.sp_get_all_usuarios;
DROP FUNCTION IF EXISTS comun.sp_buscar_usuario;
DROP FUNCTION IF EXISTS comun.sp_buscar_usuario_por_nombre;
DROP FUNCTION IF EXISTS comun.sp_buscar_usuario_por_depto;
DROP FUNCTION IF EXISTS comun.sp_crear_usuario;
DROP FUNCTION IF EXISTS comun.sp_actualizar_usuario;
DROP FUNCTION IF EXISTS comun.sp_eliminar_usuario;
DROP FUNCTION IF EXISTS comun.sp_get_departamentos;
DROP FUNCTION IF EXISTS comun.sp_get_dependencias;

DROP FUNCTION IF EXISTS comun.sp_dictamenes_estadisticas;
DROP FUNCTION IF EXISTS comun.sp_dictamenes_list;
DROP FUNCTION IF EXISTS comun.sp_dictamenes_create;
DROP FUNCTION IF EXISTS comun.sp_dictamenes_update;

DROP FUNCTION IF EXISTS public.sp_constancias_list;
DROP FUNCTION IF EXISTS public.sp_constancias_get;
DROP FUNCTION IF EXISTS public.sp_constancias_create;
DROP FUNCTION IF EXISTS public.sp_constancias_update;
DROP FUNCTION IF EXISTS public.sp_constancias_cancel;
DROP FUNCTION IF EXISTS public.sp_constancias_get_next_folio;

DROP FUNCTION IF EXISTS comun.sp_repestado_get_tramite_estado;
DROP FUNCTION IF EXISTS comun.sp_repestado_get_tramite_revisiones;
DROP FUNCTION IF EXISTS comun.sp_repestado_get_revision_detalle;
DROP FUNCTION IF EXISTS comun.sp_repestado_get_dependencia;
DROP FUNCTION IF EXISTS comun.sp_repestado_get_giro;
DROP FUNCTION IF EXISTS comun.sp_repestado_get_estado_completo;

DROP FUNCTION IF EXISTS comun.sp_repdoc_get_giros;
DROP FUNCTION IF EXISTS comun.sp_repdoc_get_requisitos_by_giro;
DROP FUNCTION IF EXISTS comun.sp_repdoc_print_requisitos;
DROP FUNCTION IF EXISTS comun.sp_repdoc_print_permisos_eventuales;

DROP FUNCTION IF EXISTS public.sp_certificaciones_list;
DROP FUNCTION IF EXISTS public.sp_certificaciones_get;
DROP FUNCTION IF EXISTS public.sp_certificaciones_create;
DROP FUNCTION IF EXISTS public.sp_certificaciones_update;
DROP FUNCTION IF EXISTS public.sp_certificaciones_cancel;
DROP FUNCTION IF EXISTS public.sp_certificaciones_search;
DROP FUNCTION IF EXISTS public.sp_certificaciones_print;

DROP FUNCTION IF EXISTS comun.sp_get_saldo_licencia;
DROP FUNCTION IF EXISTS comun.sp_get_detalle_licencia;
DROP FUNCTION IF EXISTS comun.sp_get_historial_pagos;
DROP FUNCTION IF EXISTS comun.sp_calcular_adeudo_licencia;
```

---

## 📋 CHECKLIST DE DEPLOY

- [ ] Backup de la base de datos realizado
- [ ] Extensión pgcrypto instalada
- [ ] Tablas requeridas verificadas
- [ ] Permisos de usuario verificados
- [ ] Deploy ejecutado (OPCIÓN 1 o 2)
- [ ] Verificación ejecutada (40 SPs confirmados)
- [ ] Tests funcionales ejecutados
- [ ] Servidor Laravel iniciado
- [ ] Pruebas desde Vue/API exitosas
- [ ] Logs de PostgreSQL sin errores
- [ ] Documentación revisada
- [ ] Equipo notificado del deploy

---

## 📞 CONTACTO Y SOPORTE

### Archivos de Referencia

- **Resumen Consolidado:** `docs/RESUMEN_CONSOLIDADO_SESION_2025-11-20.md`
- **Documentación Detallada:** `docs/IMPLEMENTACION_SPS_SESION_2025-11-20.md`
- **Documentación consultausuariosfrm:** `docs/CONSULTAUSUARIOS_DOCUMENTACION.md`
- **Tests:** `database/ok/CONSULTAUSUARIOS_PRUEBAS.sql`

### Comandos Útiles

```bash
# Ver logs de PostgreSQL en tiempo real
tail -f "C:\Program Files\PostgreSQL\XX\data\log\postgresql-YYYY-MM-DD_HHMMSS.log"

# Conectar a la BD
psql -U postgres -d guadalajara

# Ver funciones de un schema
\df comun.sp_*
\df public.sp_*

# Ver definición de una función
\sf comun.sp_get_all_usuarios

# Ejecutar tests
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/CONSULTAUSUARIOS_PRUEBAS.sql
```

---

## 🎉 SIGUIENTE PASO

Una vez completado el deploy y pruebas exitosas:

1. ✅ Marcar esta sesión como completada
2. 🚀 Continuar con la implementación de los 68 componentes restantes
3. 📊 Monitorear performance en producción
4. 📝 Documentar casos de uso específicos del negocio

---

**Generado:** 2025-11-20
**Versión:** 1.0
**Estado:** ✅ LISTO PARA DEPLOY
**Total SPs:** 40
**Componentes:** 7

---

**FIN DE LAS INSTRUCCIONES DE DEPLOY**
