# CONTEXTO DEL PROYECTO REFACTORX - GUADALAJARA

**Fecha:** 2025-11-21
**Objetivo:** Migración de sistema 4GL Informix a Laravel + Vue.js + PostgreSQL

---

## 1. ESTRUCTURA DEL PROYECTO

```
C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\
├── RefactorX/
│   ├── BackEnd/           # Laravel API
│   │   ├── app/
│   │   │   ├── Http/Controllers/API/GenericController.php  # API Genérica
│   │   │   └── Services/
│   │   ├── .env           # Configuración BD
│   │   └── routes/api.php
│   │
│   ├── Base/
│   │   └── padron_licencias/
│   │       ├── database/
│   │       │   ├── ok/               # 66 archivos SQL desplegados
│   │       │   ├── database/         # 6 archivos SQL adicionales
│   │       │   ├── deploy/           # Scripts de despliegue
│   │       │   └── *.sql             # 7 archivos SQL
│   │       └── docs/                 # Documentación por batch
│   │
│   └── FrontEnd/          # Vue.js Application
│       └── src/
│           └── modules/
│               └── padron_licencias/
│                   └── views/        # Componentes Vue
│
├── temp/                  # Scripts temporales de verificación
└── ENTREGABLES_PROYECTO_REFACTORX/  # Documentación Word
```

---

## 2. CONEXIÓN A BASE DE DATOS

### Credenciales PostgreSQL
```
Host: 192.168.6.146
Port: 5432
Database: padron_licencias
Username: refact
Password: FF)-BQk2
```

### Schemas Disponibles
- **comun**: 327 funciones (shared entre módulos)
- **public**: 1,495 funciones (específicas del módulo)
- **db_ingresos**: 476 tablas
- **catastro_gdl**: 1,031 tablas
- **comunX**: 1,350 tablas

---

## 3. MÓDULO PADRON_LICENCIAS

### Estado: 100% COMPLETADO

### Métricas
- **95 componentes** implementados
- **423+ stored procedures** creados
- **79 archivos SQL** generados
- **16 batches** en sesión 2025-11-21

### Componentes Principales
| Componente | SPs | Funcionalidad |
|------------|-----|---------------|
| ConsultaUsuarios | 5 | bcrypt authentication |
| Dictamen | 27 | Gestión de dictámenes |
| Bloqueos (5 tipos) | 54 | Sistema completo de bloqueos |
| Semaforo | 11 | Indicadores visuales |
| SGCv2 | 11 | Gestión catastral |
| WebBrowser | 10 | Navegación/bookmarks |
| Firma/ChgFirma | 23 | Firma electrónica SHA256 |
| ChgPass | 9 | Cambio contraseña bcrypt |

---

## 4. API GENÉRICA LARAVEL

### Endpoint Principal
```
POST /api/generic/{schema}/{procedureName}
```

### Ejemplo de Uso
```javascript
// Llamar SP desde Vue.js
const response = await axios.post('/api/generic/comun/sp_semaforo_get_stats', {
    p_fecha_inicio: '2025-01-01',
    p_fecha_fin: '2025-12-31'
});
```

### GenericController Features
- Soporta schemas: `public`, `comun`
- Conversión automática a minúsculas
- Búsqueda inteligente en múltiples schemas
- Validación de existencia de SPs
- Logging detallado para debugging

---

## 5. CONVENCIONES DE CÓDIGO

### Stored Procedures PostgreSQL
```sql
CREATE OR REPLACE FUNCTION schema.nombre_sp(
    p_parametro1 VARCHAR,        -- p_ para parámetros
    p_parametro2 INTEGER DEFAULT NULL
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    data JSONB
) AS $$
DECLARE
    v_variable VARCHAR;          -- v_ para variables locales
BEGIN
    -- Lógica aquí
    RETURN QUERY SELECT TRUE, 'OK'::TEXT, '{}'::JSONB;
END;
$$ LANGUAGE plpgsql;
```

### Patrones Comunes
- **Autenticación**: bcrypt con `pgcrypto`
- **Firmas**: SHA256 con `encode(digest(), 'hex')`
- **Soft Delete**: `deleted_at`, `deleted_by`
- **Auditoría**: Tablas `bitacora_*`
- **JSONB**: Para estructuras complejas
- **SECURITY DEFINER**: Para funciones sensibles

---

## 6. ARCHIVOS SQL PRINCIPALES

### Directorio: database/ok/ (Batches 1-13)
```
CONSULTAUSUARIOS_all_procedures_IMPLEMENTED.sql
DICTAMENFRM_all_procedures_IMPLEMENTED.sql
CONSTANCIAFRM_all_procedures_IMPLEMENTED.sql
BLOQUEARLICENCIAFRM_all_procedures_IMPLEMENTED.sql
BLOQUEARTRAMITEFRM_all_procedures_IMPLEMENTED.sql
... (66 archivos total)
```

### Directorio: database/ (Batches 14-16)
```
SEMAFORO_all_procedures_IMPLEMENTED.sql
SGCV2_all_procedures_IMPLEMENTED.sql
TDMCONECTION_all_procedures_IMPLEMENTED.sql
GIROSVIGENTESCTEXGIROFRM_all_procedures_IMPLEMENTED.sql
WEBBROWSER_all_procedures_IMPLEMENTED.sql
SFRM_CHGPASS_all_procedures_IMPLEMENTED.sql
REGHFRM_all_procedures_IMPLEMENTED.sql
```

### Directorio: database/database/
```
MODLICADEUDOFRM_all_procedures_IMPLEMENTED.sql
REPESTADISTICOSLICFRM_all_procedures_IMPLEMENTED.sql
SFRM_CHGFIRMA_all_procedures_IMPLEMENTED.sql
REPSUSPENDIDASFRM_all_procedures_IMPLEMENTED.sql
TIPOBLOQUEOFRM_all_procedures_IMPLEMENTED.sql
FECHASEGFRM_all_procedures_IMPLEMENTED.sql
```

---

## 7. SCRIPTS DE VERIFICACIÓN

### PHP: verificar_sps.php
```bash
cd RefactorX/Base/padron_licencias/database
php verificar_sps.php
```

### SQL: VERIFICAR_TODOS_SPS.sql
```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICAR_TODOS_SPS.sql
```

### Verificación Rápida por PHP
```php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=padron_licencias", "refact", "FF)-BQk2");
$stmt = $pdo->query("SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname IN ('public','comun')");
echo $stmt->fetchColumn(); // Debe ser > 1800
```

---

## 8. MAPEO DE TABLAS (postgreok.csv)

### Archivo de Referencia
```
RefactorX/Base/db/res/postgreok.csv
```
Contiene el mapeo de tablas Informix a PostgreSQL con schema destino.

### Tablas Principales en `comun`
| Tabla | Schema | Uso |
|-------|--------|-----|
| licencias | comun | Padrón de licencias |
| anuncios | comun | Padrón de anuncios |
| tramites | comun | Gestión de trámites |
| usuarios | comun | Usuarios del sistema |
| c_giros | comun | Catálogo de giros |
| detsal_lic | comun | Detalle saldos licencias |
| licencias_400 | comun | Licencias AS/400 |

### Columnas Reales de detsal_lic
```sql
id_licencia, id_anuncio, axo, forma, derechos, derechos2,
recargos, desc_derechos, desc_recargos, desc_forma,
actualizacion, saldo, cvepago
```

### Columnas Reales de licencias
```sql
id_licencia, licencia, empresa, recaud, id_giro, x, y,
zona, subzona, tipo_registro, actividad, cvecuenta,
fecha_otorgamiento, propietario, primer_ap, segundo_ap,
rfc, curp, domicilio, numext_prop
```

---

## 9. PROBLEMAS CONOCIDOS Y SOLUCIONES

### A) Archivos con comandos psql (\c, \echo)
Algunos archivos SQL contienen comandos psql que fallan en PDO.

**Archivos afectados**:
- DETALLELICENCIA, REPDOC, DEPENDENCIAS, FORMATOSECOLOGIAFRM
- REACTIVATRAMITE, IMPLICENCIAREGLAMENTADA, LICENCIASVIGENTES
- BAJALICENCIA, GIROSDCONADEUDO, PROPUESTATAB, CARGADATOS
- CARGA, 02_SP_BUSQUE, CRUCES, CARGA_IMAGEN, FIRMAUSUARIO, MODTRAMITE

**Solución**: Remover líneas que empiezan con `\c` o `\echo` antes de ejecutar

### B) Referencias a schema incorrecto
Algunos SPs usan `public.tabla` cuando debe ser `comun.tabla`

**Corrección automática**:
```php
$sql = str_replace('public.detsal_lic', 'comun.detsal_lic', $sql);
$sql = str_replace('public.licencias', 'comun.licencias', $sql);
$sql = str_replace('public.anuncios', 'comun.anuncios', $sql);
$sql = str_replace('public.tramites', 'comun.tramites', $sql);
```

### C) Columnas no coinciden con estructura real
Algunos SPs fueron generados con estructura hipotética.
**Requieren ajuste manual** para coincidir con columnas reales.

### D) Tablas que no existen
- `comun.historial_tramites` (crear o adaptar SP)
- `comun.tramitedoc` (crear o adaptar SP)

---

## 10. COMANDOS ÚTILES

### Conectar a PostgreSQL
```bash
psql -h 192.168.6.146 -U refact -d padron_licencias
```

### Listar funciones por schema
```sql
SELECT n.nspname, COUNT(*)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('public','comun')
GROUP BY n.nspname;
```

### Buscar función por nombre
```sql
SELECT proname, n.nspname
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE proname LIKE '%semaforo%';
```

### Ejecutar SP de prueba
```sql
SELECT * FROM comun.sp_semaforo_get_stats('2025-01-01', '2025-12-31');
SELECT * FROM comun.sp_tipo_bloqueo_list(TRUE);
SELECT * FROM comun.sp_webbrowser_get_bookmarks(1, NULL);
```

---

## 11. FLUJO DE TRABAJO RECOMENDADO

1. **Identificar componente** a implementar
2. **Analizar código original** en 4GL/Informix
3. **Crear archivo SQL** con patrón: `{COMPONENTE}_all_procedures_IMPLEMENTED.sql`
4. **Desplegar a BD**: `psql -f archivo.sql`
5. **Verificar con** `verificar_sps.php`
6. **Documentar en** `docs/RESUMEN_BATCH_X.md`

---

## 12. PRÓXIMOS PASOS SUGERIDOS

1. **Corregir SPs con columnas incorrectas** - Ajustar a estructura real de tablas
2. **Limpiar archivos SQL** - Remover comandos `\c`, `\echo` de psql
3. **Verificar schema correcto** - Usar `comun.*` según postgreok.csv
4. **Implementar tests de integración** Vue-API-BD
5. **Crear scripts de migración** de datos Informix a PostgreSQL

### SPs Pendientes de Ajuste (33 archivos)
Los siguientes archivos requieren revisión y ajuste de columnas:
- CONSULTALICENCIAFRM, CANCELATRAMITEFRM, CONSLIC400FRM
- CONSANUN400FRM, REGISTROSOLICITUD, BAJAANUNCIOFRM
- DETALLELICENCIA, REPDOC, PRIVILEGIOS, DOCTOSFRM
- DEPENDENCIAS, TIPOBLOQUEOFRM (ok/), FORMATOSECOLOGIAFRM
- REACTIVATRAMITE, IMPLICENCIAREGLAMENTADAFRM
- LICENCIASVIGENTESFRM, BAJALICENCIAFRM, BLOQUEODOMICILIOSFRM
- GIROSDCONADEUDOFRM, PROPUESTATAB, CARGADATOSFRM, CARGA
- BUSQUE (ok/), 02_SP_BUSQUE, CRUCES, CARGA_IMAGEN
- EMPRESASFRM, FIRMAUSUARIO, LIGAANUNCIOFRM, MODTRAMITEFRM
- SFRM_CHGPASS (ok/), REGHFRM, CATALOGOACTIVIDADES

---

## 13. CONTACTO Y REFERENCIAS

- **Documentación por Batch**: `RefactorX/Base/padron_licencias/docs/`
- **Scripts de Verificación**: `RefactorX/Base/padron_licencias/database/`
- **API Backend**: `RefactorX/BackEnd/`
- **Frontend Vue**: `RefactorX/FrontEnd/src/modules/padron_licencias/`

---

**Generado**: 2025-11-23
**Última actualización**: 2025-11-23
**Total SPs**: 1,903 funciones en BD (comun: 327, public: 1,576)

---

## 14. SCRIPTS DE DEPLOY CORREGIDOS

Los siguientes scripts SQL contienen SPs corregidos con la estructura real de tablas:

```
RefactorX/Base/padron_licencias/database/deploy/
├── DEPLOY_SPS_CORREGIDOS.sql        # 15 SPs principales
├── DEPLOY_SPS_CORREGIDOS_PARTE2.sql # 20 SPs adicionales
└── DEPLOY_SPS_CORREGIDOS_PARTE3.sql # 20 SPs más
```

### SPs Principales Corregidos:
- `sp_consulta_licencia_get_adeudos` - Adeudos por licencia/anuncio
- `sp_consulta_licencia_buscar` - Búsqueda de licencias
- `sp_estadisticas_licencias` - Estadísticas generales
- `sp_catalogo_giros_list/buscar` - Catálogo de giros
- `sp_usuario_validar` - Validación de usuarios
- `sp_busque_licencia/anuncio/tramite` - Búsquedas generales
- `sp_baja_licencia/anuncio` - Procesos de baja
- `sp_detalle_licencia_saldos` - Detalle de saldos
- `sp_imp_licencia_reglamentada` - Licencias reglamentadas

---

## 15. MÓDULOS DEL SISTEMA Y ESTADO ACTUAL

### Estructura de Módulos Frontend
```
RefactorX/FrontEnd/src/views/modules/
├── padron_licencias/        # 95 componentes - 100% COMPLETADO
├── estacionamiento_exclusivo/  # 69 componentes - 100% COMPLETADO
├── estacionamiento_publico/    # 47 componentes - 97.87% COMPLETADO
└── otras_obligaciones/         # Pendiente de auditoría
```

### Estado por Módulo

| Módulo | Componentes | SPs BD | Estilos CSS | API | Estado |
|--------|-------------|--------|-------------|-----|--------|
| **padron_licencias** | 95 | 100% | 100% | 100% | COMPLETADO |
| **estacionamiento_exclusivo** | 69 | 90.32% | 100% | 100% | COMPLETADO |
| **estacionamiento_publico** | 47 | 93.1% | 100% | 97.87% | COMPLETADO |
| **otras_obligaciones** | ? | ? | ? | ? | PENDIENTE |

---

## 16. SESIÓN 2025-11-22/23 - AUDITORÍA DE ESTILOS

### Objetivo
Eliminar todos los estilos inline y bloques `<style>` de los componentes Vue, centralizando en `municipal-theme.css`.

### Reglas de Estilos
1. **NO estilos inline** (`style="..."`) en templates Vue
2. **NO bloques `<style>`** en archivos .vue
3. **TODO centralizado** en `RefactorX/FrontEnd/src/styles/municipal-theme.css`
4. Usar clases utilitarias Bootstrap-like (`.mt-2`, `.mb-3`, etc.)

### Correcciones Realizadas

#### Estacionamiento Exclusivo (7 archivos)
| Archivo | Corrección |
|---------|------------|
| Prenomina.vue | `OP_QUERY` → `OP_REPORT` (error API) |
| Ejecutores.vue | `OP_QUERY` → `OP_LIST` (error API) |
| ConsultaReg.vue | Eliminado bloque `<style scoped>` (40 líneas) |
| EstadxFolio.vue | Eliminado bloque `<style scoped>` |
| Individual.vue | Eliminado bloque `<style scoped>` |
| Individual_Folio.vue | Eliminado bloque `<style scoped>` |
| ApremiosSvnPagos.vue | `style="font-size: 1.2em"` → `class="text-larger"` |

#### Estacionamiento Público (5 archivos)
| Archivo | Corrección |
|---------|------------|
| index.vue | `style="margin-top: 12px"` → `class="mt-3"` |
| ConsultaPublicos.vue | 3 estilos inline → clases CSS + error crítico corregido |
| MetrometersPublicos.vue | estilos img → `class="img-responsive img-bordered"` |
| SolicRepFoliosPublicos.vue | `style="margin-top:8px"` → `class="mt-2"` |

#### Error Crítico Corregido
**ConsultaPublicos.vue** - Variable `detailTab` estaba declarada FUERA del tag `</script>`:
```javascript
// ANTES (INCORRECTO - línea 342):
</script>
const detailTab = ref('info')

// DESPUÉS (CORRECTO - línea 339):
const detailTab = ref('info')
onMounted(loadData)
</script>
```

### Clases Agregadas a municipal-theme.css
```css
/* Utility Classes */
.mt-2 { margin-top: 0.5rem; }
.mt-3 { margin-top: 1rem; }
.mb-2 { margin-bottom: 0.5rem; }
.mb-3 { margin-bottom: 1rem; }
.invisible { visibility: hidden; }

/* Tab Navigation */
.tab-nav { display: flex; gap: 8px; margin-bottom: 12px; }

/* Image Utilities */
.img-responsive { max-width: 100%; height: auto; }
.img-bordered { border: 1px solid #ddd; }

/* Result Tabs */
.result-tabs { display: flex; gap: 0.5rem; margin-bottom: 1rem; }
.structured-view { padding: 1rem 0; }
.json-view { padding: 1rem; background: var(--slate-100); }
.text-larger { font-size: 1.2em; }
```

---

## 17. COMMITS DE LA SESIÓN

```
ec579f4 Fix: Estilos inline eliminados - Estacionamiento Exclusivo y Público
67bb950 Fix: Error crítico en ConsultaPublicos.vue - Variable fuera de script
```

---

## 18. PENDIENTES PRÓXIMA SESIÓN

### Prioridad Alta
1. **Deploy de 4 SPs faltantes** en estacionamiento_publico:
   - `sp_sfrm_baja_pub`
   - `spget_lic_detalles`
   - `spget_lic_grales`
   - `spubreports`

2. **Auditoría módulo otras_obligaciones**:
   - Revisar estilos (eliminar inline)
   - Verificar integración API
   - Validar SPs en BD

### Prioridad Media
1. Auditar 70 SPs huérfanos en estacionamiento_publico
2. Testing funcional de componentes corregidos
3. Revisar AdminPublicos.vue (pendiente integración API)

---

## 19. REPORTES GENERADOS

| Archivo | Módulo | Contenido |
|---------|--------|-----------|
| `REPORTE_AUDITORIA_ESTACIONAMIENTO_EXCLUSIVO_2025-11-22.md` | Exclusivo | Auditoría completa |
| `REPORTE_AUDITORIA_ESTACIONAMIENTO_PUBLICO_2025-11-22.md` | Público | Auditoría completa |

---

## 20. CONEXIÓN BASE DE DATOS POR MÓDULO

| Módulo | Database | Schema |
|--------|----------|--------|
| padron_licencias | gdl | public, comun |
| estacionamiento_exclusivo | gdl | estacionamiento_exclusivo |
| estacionamiento_publico | gdl | estacionamiento_publico |

### Credenciales
```
Host: 192.168.6.146
Port: 5432
Database: gdl
Username: refact
Password: FF)-BQk2
```

---

## 21. PATRÓN DE INTEGRACIÓN API VUE

### Patrón Estándar (useApi)
```javascript
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_publico'
const OP_LIST = 'sp_nombre_list'
const OP_SEARCH = 'sp_nombre_search'

const { loading, execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const cargar = async () => {
  try {
    const result = await execute(OP_LIST, BASE_DB, [])
    datos.value = result
  } catch (e) {
    handleApiError(e)
  }
}
```

### Patrón Alternativo (apiService)
```javascript
import apiService from '@/services/apiService'

const resp = await apiService.execute(
  'sp_nombre',           // Nombre del SP
  'estacionamiento_publico',  // Schema
  parametros,            // Array de parámetros
  '',                    // String vacío
  pagination             // Paginación (opcional)
)
```

---

**FIN DEL DOCUMENTO DE CONTEXTO**
**Próxima tarea sugerida:** Auditoría del módulo otras_obligaciones
