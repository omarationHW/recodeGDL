# 📘 CONTEXTO DE MIGRACIÓN - RefactorX Guadalajara

**Última actualización:** 2025-11-07
**Progreso actual:** 33/598 componentes (5.52%)

---

## 🎯 OBJETIVO DEL PROYECTO

Migrar el sistema municipal de Guadalajara de **Visual Basic + Informix** a **Laravel + Vue.js 3 + PostgreSQL**

- **Total de componentes:** 598
- **Componentes completados:** 33 (5.52%)
- **Componentes pendientes:** 565 (94.48%)

---

## 🏗️ ARQUITECTURA

### Base de Datos
- **Servidor:** 192.168.6.146
- **Base principal:** `padron_licencias`
- **Esquemas:**
  - `comun` - Tablas principales (tramites, licencias, anuncios, c_giros)
  - `public` - Tablas de grupos (lic_grupos, anun_grupos, etc.)

### Backend
- **Framework:** Laravel
- **Controlador único:** `GenericController.php`
- **Ruta:** `RefactorX/BackEnd/app/Http/Controllers/Api/GenericController.php`
- **Endpoint único:** `POST /api/execute`

### Frontend
- **Framework:** Vue.js 3 (Composition API con `<script setup>`)
- **Ruta base:** `RefactorX/FrontEnd/src/views/modules/padron_licencias/`
- **Composables:**
  - `useApi` - Llamadas al backend
  - `useGlobalLoading` - Loading global
  - `useLicenciasErrorHandler` - Manejo de errores y toasts
- **CSS Global:** `RefactorX/FrontEnd/src/styles/municipal-theme.css`

---

## ⚠️ REGLAS CRÍTICAS

### 🚫 NUNCA HACER:
1. **NUNCA crear tablas nuevas** - Solo usar tablas existentes
2. **NUNCA inventar SPs** - Solo copiar de `RefactorX/Base/padron_licencias/database/database/`
3. **NUNCA usar inline styles** - Todo en `municipal-theme.css`
4. **NUNCA crear nuevos servicios API** - Solo usar `GenericController`
5. **NUNCA modificar SPs originales** - Copiar tal cual
6. **NUNCA usar esquema incorrecto** - Verificar en Base si es `comun` o `public`

### ✅ SIEMPRE HACER:
1. **SIEMPRE buscar SPs en Base/** - Buscar archivos `{componente}_*.sql`
2. **SIEMPRE usar tablas existentes** - Verificar con script PHP en temp/
3. **SIEMPRE seguir el patrón** - Usar GirosDconAdeudofrm.vue como ejemplo
4. **SIEMPRE usar estilos globales** - Reutilizar clases de municipal-theme.css
5. **SIEMPRE crear script de despliegue** - En `temp/deploy_{componente}_sps.php`
6. **SIEMPRE documentar** - Actualizar COMPONENTES_OPTIMIZADOS.md

---

## 📋 PATRÓN ESTÁNDAR DE COMPONENTE

### Estructura Base (GirosDconAdeudofrm.vue)

```vue
<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ICONO" />
      </div>
      <div class="module-view-info">
        <h1>Título del Módulo</h1>
        <p>Padrón de Licencias - Descripción</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" v-if="necesario">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="loadData">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros con header clickable -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div class="municipal-card-body" v-show="showFilters">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Campo</label>
              <input type="text" class="municipal-form-control" v-model="filters.campo" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="searchData">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="clearFilters">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="totalRecords > 0">
              {{ formatNumber(totalRecords) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 30%;">
                    <font-awesome-icon icon="layer-group" class="me-2" />
                    Columna
                  </th>
                  <th style="width: 10%; text-align: center;">
                    <font-awesome-icon icon="building" class="me-1" />
                    Total
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in items" :key="index" class="clickable-row" @click="viewItem(item)">
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="store" class="giro-icon text-primary" />
                      <span class="giro-text">{{ item.nombre }}</span>
                    </div>
                  </td>
                  <td style="text-align: center;">{{ item.total }}</td>
                </tr>
                <tr v-if="items.length === 0">
                  <td colspan="2" class="text-center">
                    <div class="empty-state-content">
                      <div class="empty-state-icon">
                        <font-awesome-icon icon="inbox" />
                      </div>
                      <p class="empty-state-text">No hay registros</p>
                      <p class="empty-state-hint">Use los filtros para buscar</p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <Modal :show="showDocumentation" @close="closeDocumentation">
      <template #header>
        <h5>
          <font-awesome-icon icon="question-circle" class="me-2" />
          Ayuda - Módulo
        </h5>
      </template>
      <template #body>
        <h6>Descripción del Módulo</h6>
        <p>Contenido de ayuda...</p>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="closeDocumentation">
          Cerrar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleError, showToast } = useLicenciasErrorHandler()

// Estado
const items = ref([])
const filters = ref({ campo: '' })
const showFilters = ref(true)
const showDocumentation = ref(false)
const totalRecords = computed(() => items.value.length)

// Métodos
const loadData = async () => {
  showLoading('Cargando datos...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'SP_NOMBRE',
      'padron_licencias',
      [
        { nombre: 'p_parametro', valor: filters.value.campo, tipo: 'string' }
      ],
      'comun' // o 'public' según corresponda
    )

    if (response && response.result) {
      items.value = response.result

      const endTime = performance.now()
      const duration = endTime - startTime
      const durationText = duration < 1000
        ? `${Math.round(duration)}ms`
        : `${(duration / 1000).toFixed(2)}s`

      showToast('success', `Se encontraron ${formatNumber(items.value.length)} registros`, durationText)
    }
  } catch (error) {
    console.error('Error:', error)
    handleError(error)
  } finally {
    hideLoading()
  }
}

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
```

---

## 🎨 CLASES CSS ESTÁNDAR

### Headers y Cards
- `module-view` - Contenedor principal
- `module-view-header` - Header del módulo
- `module-view-icon` - Icono del header
- `module-view-info` - Título y descripción
- `municipal-card` - Tarjeta estándar
- `municipal-card-header` - Header de tarjeta
- `municipal-card-body` - Cuerpo de tarjeta
- `clickable-header` - Header clickable para toggle
- `header-with-badge` - Header con badge a la derecha
- `header-right` - Contenedor derecho del header

### Botones
- `btn-municipal-primary` - Botón naranja principal (#ea8215)
- `btn-municipal-secondary` - Botón dorado secundario (#cc9f52)
- `btn-municipal-success` - Botón verde (#6cca98)
- `btn-municipal-danger` - Botón rojo (#dc3545)
- `btn-municipal-purple` - Botón púrpura (#9264cc)
- `button-group` - Grupo de botones
- `ms-auto` - Margen start auto (alinear derecha)

### Formularios
- `form-row` - Fila de formulario (grid)
- `form-group` - Grupo de campo
- `municipal-form-label` - Etiqueta de campo
- `municipal-form-control` - Input/Select/Textarea

### Tablas
- `table-container` - Contenedor de tabla
- `table-responsive` - Tabla responsive
- `municipal-table` - Tabla estándar
- `municipal-table-header` - Header de tabla
- `clickable-row` - Fila clickable (cursor pointer + hover)
- `giro-name` - Contenedor de celda con icono+texto
- `giro-icon` - Icono de celda
- `giro-text` - Texto de celda

### Badges
- `badge-purple` - Badge púrpura para contadores
- `badge-success` - Badge verde
- `badge-danger` - Badge rojo
- `badge-warning` - Badge amarillo
- `badge-secondary` - Badge gris

### Empty States
- `empty-state-content` - Contenedor de estado vacío
- `empty-state-icon` - Icono grande del empty state
- `empty-state-text` - Texto principal
- `empty-state-hint` - Texto secundario/hint

### Utilidades
- `text-center` - Alinear texto centro
- `text-right` - Alinear texto derecha
- `me-1`, `me-2` - Margin end (derecha)
- `ms-2` - Margin start (izquierda)
- `mt-3`, `mt-4` - Margin top
- `mb-0` - Margin bottom 0

---

## 🔄 PROCESO DE MIGRACIÓN DE COMPONENTE

### 1. Buscar SPs Existentes
```bash
# Buscar archivos SQL del componente
Glob: RefactorX/Base/padron_licencias/database/database/{componenteName}_*.sql
```

### 2. Crear Script de Despliegue
```php
// temp/deploy_{componente}_sps.php
<?php
require __DIR__ . '/../RefactorX/BackEnd/vendor/autoload.php';
$app = require_once __DIR__ . '/../RefactorX/BackEnd/bootstrap/app.php';
$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

DB::purge('pgsql');
config(['database.connections.pgsql.database' => 'padron_licencias']);
DB::reconnect('pgsql');

// Desplegar SPs aquí...
DB::statement("CREATE OR REPLACE FUNCTION...");
?>
```

### 3. Leer Componente Original
```bash
Read: RefactorX/Base/padron_licencias/vue/{componenteName}.vue
```

### 4. Crear Componente Optimizado
- Seguir patrón de GirosDconAdeudofrm.vue
- Usar `<script setup>`
- Importar composables
- Sin inline styles

### 5. Actualizar CSS si es necesario
- Agregar nuevas clases a `municipal-theme.css`
- Solo si NO existen clases reutilizables

### 6. Documentar en COMPONENTES_OPTIMIZADOS.md
```markdown
## N. {componenteName}.vue (Título) ✅

**Fecha:** 2025-XX-XX
**Módulo:** Padrón de Licencias
**Tipo:** Tipo de componente
**Prioridad:** P1/P2/P3/P4

- **Funcionalidad:** Descripción
- **Características Implementadas:**
  - ✅ Lista de características
- **SPs Desplegados (N):**
  - ✅ sp_nombre(params)
- **Tablas EXISTENTES:**
  - ✅ esquema.tabla
- **Módulo API:** 'padron_licencias' con esquema 'comun/public'
- **Testing:** ✅/⏳ Estado
- **Estilos CSS:** ✅ N clases nuevas/reutilizadas
```

---

## 📊 PRIORIDADES

### P1 - CRÍTICA (7 pendientes)
1. modtramitefrm
2. modlicfrm
3. bajaLicenciafrm
4. bajaAnunciofrm
5. TramiteBajaLic
6. TramiteBajaAnun
7. ~~cancelaTramitefrm~~ ✅

### P2 - ALTA (6 pendientes)
8. dictamenusodesuelo
9. constanciafrm
10. certificacionesfrm
11. modlicAdeudofrm
12. ReactivaTramite
13. girosVigentesCteXgirofrm

Ver archivo completo: `LISTA_PRIORIDADES_PADRON_LICENCIAS.md`

---

## 🛠️ COMANDOS ÚTILES

### Buscar SPs de un componente
```bash
Glob: RefactorX/Base/padron_licencias/database/database/{nombre}_*.sql
```

### Verificar tablas existentes
```php
// Crear script en temp/verificar_tablas_{nombre}.php
$result = DB::select("
  SELECT table_schema, table_name
  FROM information_schema.tables
  WHERE table_name = ?
", ['nombre_tabla']);
```

### Desplegar SPs
```
http://127.0.0.1:8000/temp/deploy_{componente}_sps.php
```

---

## 📁 ESTRUCTURA DE ARCHIVOS

```
RefactorX/
├── BackEnd/
│   ├── app/Http/Controllers/Api/
│   │   └── GenericController.php (NO modificar)
│   └── vendor/
├── FrontEnd/
│   ├── src/
│   │   ├── views/modules/padron_licencias/
│   │   │   ├── GirosDconAdeudofrm.vue (PATRÓN BASE)
│   │   │   ├── cancelaTramitefrm.vue
│   │   │   └── ...otros componentes
│   │   ├── composables/
│   │   │   ├── useApi.js
│   │   │   ├── useGlobalLoading.js
│   │   │   └── useLicenciasErrorHandler.js
│   │   ├── components/common/
│   │   │   └── Modal.vue
│   │   └── styles/
│   │       └── municipal-theme.css (CSS GLOBAL)
│   └── ...
├── Base/
│   └── padron_licencias/
│       ├── database/database/ (SPs ORIGINALES)
│       └── vue/ (Componentes VB originales)
├── temp/ (Scripts de despliegue)
│   ├── deploy_cancelatramite_sps.php
│   └── ...otros
├── COMPONENTES_OPTIMIZADOS.md
├── LISTA_PRIORIDADES_PADRON_LICENCIAS.md
└── CONTEXTO_MIGRACION.md (este archivo)
```

---

## 🎯 OBJETIVOS A CORTO PLAZO

1. **Completar P1 (7 componentes)** → 7-10 días
   - Sistema básico 100% operativo

2. **Completar P2 (6 componentes)** → 6-8 días adicionales
   - Sistema productivo completo
   - 80% del trabajo diario cubierto

3. **Completar P3 (8 componentes)** → 8-10 días adicionales
   - Funcionalidades de soporte completas

**Total P1+P2+P3:** ~25 días → Sistema funcional completo

---

## 💡 LECCIONES APRENDIDAS

1. **SIEMPRE verificar esquema** - `comun` vs `public` causa errores
2. **NO inventar tablas** - Usar solo las existentes en Base
3. **Reutilizar estilos** - 90% del CSS ya existe en municipal-theme.css
4. **Copiar SPs tal cual** - No modificar lógica original
5. **Performance timing** - Formato inteligente ms/s mejora UX
6. **Modal de ayuda** - Los usuarios lo agradecen
7. **Empty states** - Mejorar experiencia cuando no hay datos
8. **Validaciones en frontend** - Antes de llamar backend

---

## 🚀 SIGUIENTE SESIÓN

**Componente sugerido:** modtramitefrm (P1 - Crítico)
- Modificar/Editar trámites existentes
- Operación diaria clave
- Impacto: ALTO

**Comando para iniciar:**
```
Buscar SPs: RefactorX/Base/padron_licencias/database/database/modtramitefrm_*.sql
```

---

**Última actualización:** 2025-11-07
**Autor:** Claude Code
**Progreso:** 33/598 componentes (5.52%)
