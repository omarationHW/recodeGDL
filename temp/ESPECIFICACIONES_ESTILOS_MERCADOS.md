# ESPECIFICACIONES: Estandarización de Estilos - Módulo Mercados

## REFERENCIA
**Archivo ejemplo:** `RefactorX/FrontEnd/src/views/modules/padron_licencias/consultausuariosfrm.vue`

## REGLAS ESTRICTAS

### ❌ NO MODIFICAR
1. **NO cambiar lógica de negocio**
2. **NO modificar requests a /api** (solo identación si es necesario)
3. **NO agregar o quitar parámetros de APIs**
4. **NO cambiar nombres de variables reactivas**
5. **NO modificar funciones de negocio**

### ✅ SÍ MODIFICAR
1. **Estructura HTML del template**
2. **Clases CSS (usar las de municipal-theme.css)**
3. **Estilos scoped (migrarlos a municipal-theme.css si es necesario)**
4. **Loading states**
5. **Toast notifications**
6. **Modales y diálogos**
7. **Tablas (agregar paginación si falta)**

## ESTRUCTURA ESTÁNDAR

### 1. Module Header
```vue
<div class="module-view">
  <div class="module-view-header">
    <div class="module-view-icon">
      <font-awesome-icon icon="icon-name" />
    </div>
    <div class="module-view-info">
      <h1>Título del Módulo</h1>
      <p>Breadcrumb > Path > Actual</p>
    </div>
    <div class="button-group ms-auto">
      <!-- Botones de acción -->
    </div>
  </div>
  <div class="module-view-content">
    <!-- Contenido -->
  </div>
</div>
```

### 2. Cards
```vue
<div class="municipal-card">
  <div class="municipal-card-header">
    <h5>
      <font-awesome-icon icon="icon" />
      Título
    </h5>
  </div>
  <div class="municipal-card-body">
    <!-- Contenido -->
  </div>
</div>
```

### 3. Forms
```vue
<div class="form-row">
  <div class="form-group">
    <label class="municipal-form-label">Campo <span class="required">*</span></label>
    <input type="text" class="municipal-form-control" v-model="campo" />
  </div>
</div>
```

### 4. Buttons
```vue
<button class="btn-municipal-primary" :disabled="loading">
  <font-awesome-icon icon="icon" />
  Texto
</button>

<button class="btn-municipal-secondary" :disabled="loading">
  <font-awesome-icon icon="icon" />
  Texto
</button>

<button class="btn-municipal-purple">
  <font-awesome-icon icon="icon" />
  Texto
</button>
```

### 5. Tables
```vue
<div class="table-responsive">
  <table class="municipal-table">
    <thead class="municipal-table-header">
      <tr>
        <th>Columna 1</th>
        <th>Columna 2</th>
        <th class="text-center">Acciones</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="item in paginatedItems" :key="item.id">
        <td>{{ item.campo1 }}</td>
        <td>{{ item.campo2 }}</td>
        <td class="text-center">
          <button class="btn-icon" @click="ver(item)">
            <font-awesome-icon icon="eye" />
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</div>

<!-- Paginación -->
<div class="pagination-container">
  <div class="pagination-info">
    Mostrando {{ paginationStart }} a {{ paginationEnd }} de {{ totalItems }} registros
  </div>
  <div class="pagination-controls">
    <label class="me-2">Registros por página:</label>
    <select v-model.number="itemsPerPage" class="form-select form-select-sm">
      <option :value="10">10</option>
      <option :value="25">25</option>
      <option :value="50">50</option>
      <option :value="100">100</option>
    </select>
  </div>
  <div class="pagination-buttons">
    <button @click="prevPage" :disabled="currentPage === 1">
      <font-awesome-icon icon="chevron-left" />
    </button>
    <span>Página {{ currentPage }} de {{ totalPages }}</span>
    <button @click="nextPage" :disabled="currentPage === totalPages">
      <font-awesome-icon icon="chevron-right" />
    </button>
  </div>
</div>
```

### 6. Loading State
```vue
<div v-if="loading" class="text-center py-4">
  <div class="spinner-border text-primary" role="status">
    <span class="visually-hidden">Cargando...</span>
  </div>
</div>
```

### 7. Modals (para detalles)
```vue
<!-- Modal -->
<div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
  <div class="modal-municipal">
    <div class="modal-header-municipal">
      <h5>
        <font-awesome-icon icon="info-circle" />
        Detalles
      </h5>
      <button class="btn-close-modal" @click="cerrarModal">
        <font-awesome-icon icon="times" />
      </button>
    </div>
    <div class="modal-body-municipal">
      <!-- Contenido -->
    </div>
    <div class="modal-footer-municipal">
      <button class="btn-municipal-secondary" @click="cerrarModal">
        Cerrar
      </button>
    </div>
  </div>
</div>
```

### 8. Toast Notifications
```javascript
import { useToast } from 'vue-toastification'

const toast = useToast()

// Éxito
toast.success('Operación exitosa')

// Error
toast.error('Error en la operación')

// Advertencia
toast.warning('Advertencia')

// Info
toast.info('Información')
```

## PAGINACIÓN (Client-Side)

Agregar al script:

```javascript
const currentPage = ref(1)
const itemsPerPage = ref(10)

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return items.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(items.value.length / itemsPerPage.value)
})

const paginationStart = computed(() => {
  return items.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > items.value.length ? items.value.length : end
})

const totalItems = computed(() => items.value.length)

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

// Reset página al buscar
watch(items, () => {
  currentPage.value = 1
})
```

## COLORES INSTITUCIONALES (Ya definidos en municipal-theme.css)

- Primary: #2c5aa0 (azul institucional)
- Secondary: #6c757d (gris)
- Purple: #6f42c1 (morado para badges)
- Success: #28a745
- Danger: #dc3545
- Warning: #ffc107
- Info: #17a2b8

## CLASES CSS DISPONIBLES

### Botones
- `btn-municipal-primary`
- `btn-municipal-secondary`
- `btn-municipal-purple`
- `btn-municipal-success`
- `btn-municipal-danger`
- `btn-icon`
- `btn-close-modal`

### Cards
- `municipal-card`
- `municipal-card-header`
- `municipal-card-body`

### Forms
- `municipal-form-label`
- `municipal-form-control`
- `form-row`
- `form-group`

### Tables
- `municipal-table`
- `municipal-table-header`
- `table-responsive`
- `table-container`

### Badges
- `badge-purple`

### Headers
- `module-view`
- `module-view-header`
- `module-view-icon`
- `module-view-info`
- `module-view-content`

### Modals
- `modal-overlay`
- `modal-municipal`
- `modal-header-municipal`
- `modal-body-municipal`
- `modal-footer-municipal`

### Pagination
- `pagination-container`
- `pagination-info`
- `pagination-controls`
- `pagination-buttons`

## PROCESO DE MIGRACIÓN

1. **Leer el componente actual**
2. **Identificar estructura:** header, filtros, tablas, modales
3. **Aplicar clases estándar** según la estructura
4. **Agregar paginación** si hay tablas
5. **Agregar loading states** si faltan
6. **Migrar estilos scoped** a comentarios (no al CSS global, solo documentar)
7. **Verificar que no se modificó lógica**
8. **Probar que compile sin errores**

## VALIDACIONES

- ✅ Usa clases de municipal-theme.css
- ✅ Tiene loading states
- ✅ Tablas con paginación client-side (10 registros por defecto)
- ✅ Detalles en modal (si aplica)
- ✅ Toast para notificaciones
- ✅ No cambia lógica de negocio
- ✅ No modifica requests a /api
- ✅ Mantiene todas las funcionalidades originales
