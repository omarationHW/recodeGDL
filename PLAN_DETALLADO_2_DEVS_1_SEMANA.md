# 📋 Plan Detallado 2 Desarrolladores - 1 Semana Frontend
## Integración Frontend Vue.js con Backend Existente

---

## 📊 Resumen Ejecutivo

| Aspecto | Detalle |
|---------|---------|
| **Duración** | 5 días (Lunes a Viernes) |
| **Horario** | 8:00 AM - 8:00 PM (12 horas/día) |
| **Equipo** | 2 desarrolladores + Claude Code |
| **Backend** | ✅ Completo y funcional (Laravel) |
| **Base de Datos** | Scripts SQL en carpeta `base/` |
| **Total Sistemas** | 9 módulos |
| **Total Formularios** | 470 componentes Vue |
| **Stack Frontend** | Vue 3, Pinia, Axios, PrimeVue/Vuetify |

---

## 🎯 Distribución de Sistemas

### Developer 1 (Dev1) - Sistemas 1-5
| Sistema | Forms | Complejidad | Día |
|---------|-------|-------------|-----|
| 1. Distribución | 15 | Baja | Lunes AM |
| 2. Cementerios | 20 | Baja | Lunes PM |
| 3. Aseo Contratado | 25 | Media | Lunes PM |
| 4. Mercados | 35 | Media | Martes |
| 5. Otras Obligaciones | 40 | Media | Martes |
| **TOTAL DEV1** | **135** | | |

### Developer 2 (Dev2) - Sistemas 6-9
| Sistema | Forms | Complejidad | Día |
|---------|-------|-------------|-----|
| 6. Padrón Licencias | 60 | Alta | Miércoles |
| 7. Multas y Reglamentos | 90 | Muy Alta | Jueves |
| 8. Estacionamiento Exclusivo | 65 | Alta | Jueves |
| 9. Estacionamiento Público | 120 | Muy Alta | Viernes |
| **TOTAL DEV2** | **335** | | |

**NOTA:** Dev1 ayuda a Dev2 en sistemas grandes desde Miércoles

---

# 📅 DÍA 1 - LUNES: Setup + 3 Sistemas Simples

## 🌅 Mañana: 8:00 AM - 12:00 PM

### 8:00 - 8:30 AM | Setup Conjunto (Ambos devs)

**Dev1 y Dev2 juntos:**

```bash
# 1. Verificar git y clonar si es necesario
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL
git pull origin main
git checkout -b feature/frontend-week1

# 2. Verificar backend funcionando
curl http://localhost:8000/api/health
# Debe responder: {"status": "ok"}

# 3. Instalar dependencias frontend
cd frontend
npm install

# 4. Verificar .env configurado
cat .env.local
# Debe tener: VITE_API_URL=http://localhost:8000/api

# 5. Iniciar dev server
npm run dev
# Debe abrir http://localhost:5173
```

**Checklist Setup:**
- [ ] Git configurado y branch creada
- [ ] Backend Laravel respondiendo
- [ ] Frontend npm install completado
- [ ] Vite dev server corriendo
- [ ] Claude Code instalado y funcionando
- [ ] Postman/Insomnia con colección de APIs

---

### 8:30 - 9:30 AM | Base de Datos (Dev1) + Estructura Base (Dev2)

#### Dev1: Ejecutar Scripts SQL

```bash
# Navegar a carpeta con scripts
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base

# Conectar a PostgreSQL
psql -U postgres -d guadalajara_db

# Ejecutar scripts en orden
\i 01_tablas_base.sql
\i 02_stored_procedures.sql
\i 03_datos_iniciales.sql
\i 04_catalogos.sql

# Verificar tablas creadas
\dt
\q
```

**Script verificación rápida:**
```sql
-- Verificar tablas principales
SELECT COUNT(*) FROM usuarios;
SELECT COUNT(*) FROM licencias;
SELECT COUNT(*) FROM multas;
-- Deben retornar 0 o datos iniciales
```

#### Dev2: Crear Estructura Base Frontend

```bash
cd frontend/src

# Crear estructura de carpetas
mkdir -p modules/{distribucion,cementerios,aseo_contratado,mercados,otras_obligaciones,padron_licencias,multas_reglamentos,estacionamiento_exclusivo,estacionamiento_publico}

mkdir -p components/common
mkdir -p services
mkdir -p stores
mkdir -p composables
mkdir -p utils
```

**Usar Claude Code para componentes base:**

```
PROMPT CLAUDE CODE:

Crea los siguientes componentes Vue 3 base reutilizables con Composition API:

1. components/common/FormBase.vue
- Props: title, loading, error
- Slots: default, actions
- Emits: submit, cancel

2. components/common/TableBase.vue
- Props: columns, data, loading, pagination
- Features: ordenamiento, paginación
- Emits: sort, page-change, row-click

3. components/common/SearchBar.vue
- Props: placeholder, filters
- Debounce en búsqueda
- Emits: search, filter-change

4. components/common/ModalBase.vue
- Props: title, visible, size
- Slots: default, footer
- Emits: close, confirm

5. components/common/LoadingSpinner.vue
- Props: size, message
- Overlay opcional

Requisitos:
- TypeScript con interfaces
- PrimeVue para UI
- Responsive
- Documentación JSDoc
```

**Crear servicio API base:**

```javascript
// services/api.js
import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Interceptor para token JWT
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// Interceptor para errores
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      // Redirect a login
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
```

---

### 9:30 - 12:00 PM | Sistema 1: DISTRIBUCIÓN (15 formularios)

#### Dev1: Componentes Forms 1-8

**Paso 1: Analizar archivos Delphi**

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\distribucion

# Listar todos los archivos
ls *.pas *.dfm
```

**Usar Claude Code:**

```
PROMPT CLAUDE CODE:

Analiza estos archivos Delphi del módulo Distribución:

[PEGAR CONTENIDO DE TODOS LOS .PAS Y .DFM]

Identifica:
1. Formularios principales y secundarios
2. Campos de cada formulario
3. Grids/tablas utilizados
4. Botones y acciones
5. Validaciones de negocio
6. Tablas de BD usadas

Genera lista priorizada de componentes Vue a crear.
```

**Paso 2: Crear servicio API**

```javascript
// services/distribucion.service.js
import api from './api'

export const distribucionService = {
  // GET /api/distribucion
  getAll: async (params = {}) => {
    const response = await api.get('/distribucion', { params })
    return response.data
  },

  // GET /api/distribucion/:id
  getById: async (id) => {
    const response = await api.get(`/distribucion/${id}`)
    return response.data
  },

  // POST /api/distribucion
  create: async (data) => {
    const response = await api.post('/distribucion', data)
    return response.data
  },

  // PUT /api/distribucion/:id
  update: async (id, data) => {
    const response = await api.put(`/distribucion/${id}`, data)
    return response.data
  },

  // DELETE /api/distribucion/:id
  delete: async (id) => {
    const response = await api.delete(`/distribucion/${id}`)
    return response.data
  },

  // Endpoints específicos según backend
  buscar: async (criterio) => {
    const response = await api.post('/distribucion/buscar', criterio)
    return response.data
  },

  getReporte: async (filtros) => {
    const response = await api.post('/distribucion/reporte', filtros)
    return response.data
  }
}
```

**Paso 3: Convertir formularios principales con Claude Code**

```
PROMPT CLAUDE CODE:

Convierte estos formularios Delphi a Vue 3:

[PEGAR FormPrincipalDistribucion.pas y .dfm]

Genera:
1. DistribucionList.vue - Lista con tabla
2. DistribucionForm.vue - Formulario alta/edición
3. DistribucionSearch.vue - Búsqueda avanzada

Requisitos:
- <script setup> con Composition API
- Usar distribucionService para API calls
- Validaciones con VeeValidate
- PrimeVue DataTable para grids
- Responsive design
- Comentar endpoints del backend usados
- Manejo de loading y errores
```

**Estructura esperada:**

```vue
<!-- modules/distribucion/views/DistribucionList.vue -->
<template>
  <div class="distribucion-list">
    <div class="header">
      <h1>Distribución</h1>
      <Button label="Nuevo" @click="openForm" />
    </div>

    <SearchBar @search="handleSearch" />

    <TableBase
      :columns="columns"
      :data="items"
      :loading="loading"
      :pagination="pagination"
      @row-click="editItem"
      @page-change="loadPage"
    />

    <ModalBase
      v-model:visible="showForm"
      title="Distribución"
      size="lg"
    >
      <DistribucionForm
        :item="selectedItem"
        @save="handleSave"
        @cancel="showForm = false"
      />
    </ModalBase>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { distribucionService } from '@/services/distribucion.service'
import TableBase from '@/components/common/TableBase.vue'
import SearchBar from '@/components/common/SearchBar.vue'
import ModalBase from '@/components/common/ModalBase.vue'
import DistribucionForm from '../components/DistribucionForm.vue'
import { useToast } from 'primevue/usetoast'

const toast = useToast()
const items = ref([])
const loading = ref(false)
const showForm = ref(false)
const selectedItem = ref(null)
const pagination = ref({
  page: 1,
  perPage: 20,
  total: 0
})

const columns = [
  { field: 'id', header: 'ID', sortable: true },
  { field: 'nombre', header: 'Nombre', sortable: true },
  { field: 'direccion', header: 'Dirección', sortable: true },
  { field: 'fecha', header: 'Fecha', sortable: true },
  { field: 'estatus', header: 'Estatus', sortable: true }
]

const loadItems = async () => {
  loading.value = true
  try {
    const response = await distribucionService.getAll({
      page: pagination.value.page,
      perPage: pagination.value.perPage
    })
    items.value = response.data
    pagination.value.total = response.total
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: 'Error al cargar datos',
      life: 3000
    })
  } finally {
    loading.value = false
  }
}

const openForm = () => {
  selectedItem.value = null
  showForm.value = true
}

const editItem = (item) => {
  selectedItem.value = { ...item }
  showForm.value = true
}

const handleSave = async (data) => {
  try {
    if (data.id) {
      await distribucionService.update(data.id, data)
      toast.add({
        severity: 'success',
        summary: 'Éxito',
        detail: 'Registro actualizado',
        life: 3000
      })
    } else {
      await distribucionService.create(data)
      toast.add({
        severity: 'success',
        summary: 'Éxito',
        detail: 'Registro creado',
        life: 3000
      })
    }
    showForm.value = false
    loadItems()
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: error.response?.data?.message || 'Error al guardar',
      life: 3000
    })
  }
}

const handleSearch = async (criteria) => {
  loading.value = true
  try {
    const response = await distribucionService.buscar(criteria)
    items.value = response.data
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: 'Error en búsqueda',
      life: 3000
    })
  } finally {
    loading.value = false
  }
}

const loadPage = (page) => {
  pagination.value.page = page
  loadItems()
}

onMounted(() => {
  loadItems()
})
</script>

<style scoped>
.distribucion-list {
  padding: 2rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

@media (max-width: 768px) {
  .distribucion-list {
    padding: 1rem;
  }
}
</style>
```

#### Dev2: Componentes Forms 9-15 + Rutas

**Crear componentes secundarios:**

```
PROMPT CLAUDE CODE:

Convierte estos formularios secundarios de Distribución:

[PEGAR archivos de reportes, búsquedas, etc.]

Genera:
- DistribucionReporte.vue
- DistribucionEstadisticas.vue
- DistribucionConsulta.vue

Con integración a backend existente.
```

**Configurar rutas:**

```javascript
// modules/distribucion/routes.js
export default [
  {
    path: '/distribucion',
    component: () => import('./views/DistribucionLayout.vue'),
    children: [
      {
        path: '',
        name: 'distribucion-list',
        component: () => import('./views/DistribucionList.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'nuevo',
        name: 'distribucion-create',
        component: () => import('./views/DistribucionForm.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: ':id/editar',
        name: 'distribucion-edit',
        component: () => import('./views/DistribucionForm.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'reportes',
        name: 'distribucion-reportes',
        component: () => import('./views/DistribucionReporte.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]
```

**Registrar en router principal:**

```javascript
// router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import distribucionRoutes from '@/modules/distribucion/routes'

const routes = [
  {
    path: '/',
    redirect: '/dashboard'
  },
  ...distribucionRoutes,
  // Más rutas...
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
```

---

### 12:00 - 1:00 PM | ALMUERZO 🍽️

**Checkpoint Mañana:**
- [ ] Base de datos configurada
- [ ] Estructura frontend creada
- [ ] Componentes base listos
- [ ] Sistema Distribución iniciado (50%)
- [ ] Servicios API configurados

---

## 🌆 Tarde: 1:00 PM - 8:00 PM

### 1:00 - 3:00 PM | Completar Distribución + Iniciar Cementerios

#### Dev1: Finalizar Distribución (15 forms)

**Testing básico:**

```bash
# Probar componente en navegador
npm run dev

# Abrir http://localhost:5173/distribucion
# Verificar:
# - Lista carga datos del backend
# - Formulario de alta funciona
# - Búsqueda funciona
# - Validaciones aparecen
```

**Testing con Claude Code:**

```
PROMPT CLAUDE CODE:

Genera tests Vitest para DistribucionList.vue:

- Test renderizado correcto
- Test carga de datos desde API (mock)
- Test apertura de formulario
- Test búsqueda
- Test manejo de errores

Usa @testing-library/vue
```

**Commit:**

```bash
git add .
git commit -m "Add: Frontend Distribución completo (15 components)"
git push origin feature/frontend-week1
```

#### Dev2: Iniciar Cementerios

Repetir proceso similar para Cementerios (20 forms)

---

### 3:00 - 5:00 PM | Sistema 2: CEMENTERIOS (20 formularios)

**Ambos devs trabajando en paralelo:**

**Dev1:** Forms 1-10 Cementerios
- Gestión de lotes
- Registro de servicios
- Asignación de nichos

**Dev2:** Forms 11-20 Cementerios
- Consultas
- Reportes
- Búsquedas

**Usar misma metodología:**
1. Analizar Delphi con Claude Code
2. Crear servicio cementerios.service.js
3. Generar componentes Vue
4. Configurar rutas
5. Testing básico

---

### 5:00 - 7:30 PM | Sistema 3: ASEO CONTRATADO (25 formularios)

**División:**
- **Dev1:** Forms 1-13
- **Dev2:** Forms 14-25

**Componentes clave:**
- Contratos
- Cobranza
- Pagos
- Adeudos
- Reportes

---

### 7:30 - 8:00 PM | Testing y Commit Día 1

```bash
# Testing conjunto
npm run build
# Debe compilar sin errores

# Commit final
git add .
git commit -m "Add: Frontend Día 1 - Distribución, Cementerios, Aseo (60 forms)"
git push origin feature/frontend-week1
```

**Checklist Fin Día 1:**
- [ ] 3 sistemas completos (60 formularios)
- [ ] Base de datos funcionando
- [ ] Componentes base reutilizables
- [ ] Build sin errores
- [ ] Git pushed

---

# 📅 DÍA 2 - MARTES: Sistemas Medios

## 🌅 Mañana: 8:00 AM - 12:00 PM

### 8:00 - 8:15 AM | Standup y Planning

**Revisar:**
- Progreso día 1
- Issues encontrados
- Plan día 2

---

### 8:00 AM - 1:00 PM | Sistema 4: MERCADOS (35 formularios)

**División:**
- **Dev1:** Forms 1-18 (Gestión puestos, comerciantes)
- **Dev2:** Forms 19-35 (Pagos, reportes, consultas)

**Módulos principales:**

```javascript
// services/mercados.service.js
export const mercadosService = {
  // Puestos
  getPuestos: async () => {...},
  crearPuesto: async (data) => {...},

  // Comerciantes
  getComerciantes: async () => {...},
  registrarComerciante: async (data) => {...},

  // Asignaciones
  asignarPuesto: async (data) => {...},

  // Pagos
  registrarPago: async (data) => {...},
  getAdeudos: async (comercianteId) => {...},

  // Reportes
  getReporteOcupacion: async (filters) => {...},
  getReporteIngresos: async (filters) => {...}
}
```

**Componentes Vue a generar:**

```
modules/mercados/
├── views/
│   ├── MercadosList.vue
│   ├── PuestosManagement.vue
│   ├── ComerciantesManagement.vue
│   ├── AsignacionPuestos.vue
│   ├── CobranzaMercados.vue
│   └── ReportesMercados.vue
├── components/
│   ├── PuestoCard.vue
│   ├── ComercianteForm.vue
│   ├── PagoMercadoForm.vue
│   └── EstadisticasMercado.vue
└── routes.js
```

---

### 12:00 - 1:00 PM | ALMUERZO 🍽️

---

## 🌆 Tarde: 1:00 PM - 8:00 PM

### 1:00 PM - 8:00 PM | Sistema 5: OTRAS OBLIGACIONES (40 formularios)

**Sistema más complejo con 2 módulos:**

#### Módulo Giros (20 forms)
- GNuevos.vue
- GConsulta.vue
- GActualiza.vue
- GBaja.vue
- GAdeudos.vue
- GFacturacion.vue
- Etc.

#### Módulo Rubros (20 forms)
- RNuevos.vue
- RConsulta.vue
- RActualiza.vue
- RBaja.vue
- RAdeudos.vue
- RFacturacion.vue
- Etc.

**División:**
- **Dev1:** Módulo Giros completo (20 forms)
- **Dev2:** Módulo Rubros completo (20 forms)

**Servicio API:**

```javascript
// services/otras-obligaciones.service.js
export const otrasObligacionesService = {
  // GIROS
  giros: {
    getAll: async (params) => {...},
    crear: async (data) => {...},
    actualizar: async (id, data) => {...},
    eliminar: async (id) => {...},
    getAdeudos: async (giroId) => {...},
    calcularAdeudo: async (giroId, periodo) => {...},
    facturar: async (data) => {...}
  },

  // RUBROS
  rubros: {
    getAll: async (params) => {...},
    crear: async (data) => {...},
    actualizar: async (id, data) => {...},
    eliminar: async (id) => {...},
    getAdeudos: async (rubroId) => {...},
    calcularAdeudo: async (rubroId, periodo) => {...},
    facturar: async (data) => {...}
  },

  // COMPARTIDO
  getCatalogos: async () => {...},
  getReportes: async (tipo, filtros) => {...}
}
```

**Store Pinia para estado compartido:**

```javascript
// stores/otras-obligaciones.store.js
import { defineStore } from 'pinia'
import { otrasObligacionesService } from '@/services/otras-obligaciones.service'

export const useOtrasObligacionesStore = defineStore('otras-obligaciones', {
  state: () => ({
    giros: [],
    rubros: [],
    catalogos: {},
    loading: false
  }),

  actions: {
    async loadGiros() {
      this.loading = true
      try {
        this.giros = await otrasObligacionesService.giros.getAll()
      } finally {
        this.loading = false
      }
    },

    async loadRubros() {
      this.loading = true
      try {
        this.rubros = await otrasObligacionesService.rubros.getAll()
      } finally {
        this.loading = false
      }
    },

    async loadCatalogos() {
      this.catalogos = await otrasObligacionesService.getCatalogos()
    }
  }
})
```

---

### 7:30 - 8:00 PM | Testing y Commit Día 2

```bash
npm run build
git add .
git commit -m "Add: Frontend Día 2 - Mercados y Otras Obligaciones (75 forms)"
git push origin feature/frontend-week1
```

**Checklist Fin Día 2:**
- [ ] 5 sistemas completos (135 formularios acumulados)
- [ ] Mercados funcional
- [ ] Otras Obligaciones (Giros + Rubros) funcional
- [ ] Build sin errores

**PROGRESO TOTAL: 135/470 = 29% ✅**

---

# 📅 DÍA 3 - MIÉRCOLES: Padrón de Licencias

## Sistema 6: PADRÓN DE LICENCIAS (60 formularios)

**SISTEMA MÁS IMPORTANTE - Ambos devs trabajando juntos**

### 8:00 - 9:00 AM | Análisis y Arquitectura

**Análisis con Claude Code:**

```
PROMPT CLAUDE CODE:

Analiza el sistema completo de Padrón de Licencias (60 formularios):

[PEGAR TODOS LOS ARCHIVOS de RefactorX/Base/padron_licencias/]

Identifica:
1. Entidades principales (Licencias, Anuncios, Trámites, Giros)
2. Relaciones entre entidades
3. Flujos de trabajo críticos
4. Tablas de BD involucradas
5. Stored procedures usados
6. Reportes principales

Propón:
7. Arquitectura de componentes Vue
8. Estructura de stores Pinia
9. Servicios API necesarios
10. Orden de implementación
```

**División de trabajo:**

#### Dev1 - Módulos Core (30 forms)
1. **Licencias** (10 forms)
   - Alta licencias
   - Consulta licencias
   - Modificación licencias
   - Renovación
   - Suspensión

2. **Trámites** (10 forms)
   - Wizard de nuevo trámite
   - Consulta trámites
   - Seguimiento
   - Documentos requeridos
   - Pagos de trámites

3. **Anuncios** (10 forms)
   - Alta anuncios
   - Consulta anuncios
   - Modificación
   - Zonas de anuncios
   - Tipos de anuncios

#### Dev2 - Módulos Soporte (30 forms)
4. **Consultas y Búsquedas** (10 forms)
   - Búsqueda avanzada licencias
   - Búsqueda anuncios
   - Consulta de estatus
   - Historial de cambios
   - Auditoría

5. **Pagos y Facturación** (10 forms)
   - Pagos de licencias
   - Aplicación de descuentos
   - Consulta de adeudos
   - Facturación electrónica
   - Recibos

6. **Catálogos y Reportes** (10 forms)
   - Catálogo de giros
   - Catálogo SCIAN
   - Zonas y ubicaciones
   - Reportes estadísticos
   - Dashboard licencias

---

### 9:00 AM - 1:00 PM | Implementación Core

#### Dev1: Módulo de Licencias

**Servicio API:**

```javascript
// services/licencias.service.js
export const licenciasService = {
  // CRUD Licencias
  getAll: async (filters) => {
    const response = await api.get('/licencias', { params: filters })
    return response.data
  },

  getById: async (id) => {
    const response = await api.get(`/licencias/${id}`)
    return response.data
  },

  crear: async (data) => {
    const response = await api.post('/licencias', data)
    return response.data
  },

  actualizar: async (id, data) => {
    const response = await api.put(`/licencias/${id}`, data)
    return response.data
  },

  eliminar: async (id) => {
    const response = await api.delete(`/licencias/${id}`)
    return response.data
  },

  // Operaciones específicas
  renovar: async (id, data) => {
    const response = await api.post(`/licencias/${id}/renovar`, data)
    return response.data
  },

  suspender: async (id, motivo) => {
    const response = await api.post(`/licencias/${id}/suspender`, { motivo })
    return response.data
  },

  reactivar: async (id) => {
    const response = await api.post(`/licencias/${id}/reactivar`)
    return response.data
  },

  validarDatos: async (data) => {
    const response = await api.post('/licencias/validar', data)
    return response.data
  },

  buscar: async (criterios) => {
    const response = await api.post('/licencias/buscar', criterios)
    return response.data
  },

  getHistorial: async (id) => {
    const response = await api.get(`/licencias/${id}/historial`)
    return response.data
  }
}
```

**Componente principal:**

```vue
<!-- modules/padron_licencias/views/LicenciasList.vue -->
<template>
  <div class="licencias-container">
    <!-- Header con acciones -->
    <div class="header">
      <h1>Padrón de Licencias Municipales</h1>
      <div class="actions">
        <Button
          label="Nueva Licencia"
          icon="pi pi-plus"
          @click="openForm"
        />
        <Button
          label="Búsqueda Avanzada"
          icon="pi pi-search"
          class="p-button-outlined"
          @click="showSearchDialog = true"
        />
        <Button
          label="Reportes"
          icon="pi pi-file-pdf"
          class="p-button-outlined"
          @click="showReportesDialog = true"
        />
      </div>
    </div>

    <!-- Filtros rápidos -->
    <div class="filters">
      <div class="p-inputgroup">
        <span class="p-inputgroup-addon">
          <i class="pi pi-search"></i>
        </span>
        <InputText
          v-model="quickSearch"
          placeholder="Buscar por número, nombre o RFC..."
          @input="handleQuickSearch"
        />
      </div>

      <Dropdown
        v-model="filtroEstatus"
        :options="estatusOptions"
        optionLabel="label"
        optionValue="value"
        placeholder="Estatus"
        @change="loadLicencias"
      />

      <Dropdown
        v-model="filtroGiro"
        :options="girosOptions"
        optionLabel="nombre"
        optionValue="id"
        placeholder="Giro"
        filter
        @change="loadLicencias"
      />
    </div>

    <!-- Tabla de licencias -->
    <DataTable
      :value="licencias"
      :loading="loading"
      :paginator="true"
      :rows="20"
      :totalRecords="totalRecords"
      :lazy="true"
      @page="onPage"
      @sort="onSort"
      :sortField="sortField"
      :sortOrder="sortOrder"
      responsiveLayout="scroll"
      stripedRows
      class="p-datatable-sm"
    >
      <Column field="numero" header="Número" sortable>
        <template #body="{ data }">
          <router-link :to="`/licencias/${data.id}`">
            {{ data.numero }}
          </router-link>
        </template>
      </Column>

      <Column field="razon_social" header="Razón Social" sortable></Column>

      <Column field="nombre_comercial" header="Nombre Comercial" sortable></Column>

      <Column field="giro" header="Giro">
        <template #body="{ data }">
          <Tag :value="data.giro.nombre" />
        </template>
      </Column>

      <Column field="direccion" header="Dirección">
        <template #body="{ data }">
          {{ formatDireccion(data.direccion) }}
        </template>
      </Column>

      <Column field="estatus" header="Estatus">
        <template #body="{ data }">
          <Tag
            :value="data.estatus"
            :severity="getEstatusSeverity(data.estatus)"
          />
        </template>
      </Column>

      <Column field="vigencia" header="Vigencia" sortable>
        <template #body="{ data }">
          <span :class="{ 'text-danger': isVencida(data.vigencia) }">
            {{ formatDate(data.vigencia) }}
          </span>
        </template>
      </Column>

      <Column header="Acciones" :exportable="false">
        <template #body="{ data }">
          <Button
            icon="pi pi-eye"
            class="p-button-rounded p-button-text"
            @click="verDetalle(data)"
            v-tooltip="'Ver detalle'"
          />
          <Button
            icon="pi pi-pencil"
            class="p-button-rounded p-button-text"
            @click="editarLicencia(data)"
            v-tooltip="'Editar'"
          />
          <Button
            icon="pi pi-refresh"
            class="p-button-rounded p-button-text"
            @click="renovarLicencia(data)"
            v-tooltip="'Renovar'"
          />
          <Button
            icon="pi pi-times"
            class="p-button-rounded p-button-text p-button-danger"
            @click="suspenderLicencia(data)"
            v-tooltip="'Suspender'"
          />
        </template>
      </Column>
    </DataTable>

    <!-- Modal de formulario -->
    <Dialog
      v-model:visible="showFormDialog"
      :header="formTitle"
      :modal="true"
      :style="{ width: '80vw' }"
      :maximizable="true"
    >
      <LicenciaForm
        :licencia="selectedLicencia"
        @save="handleSave"
        @cancel="showFormDialog = false"
      />
    </Dialog>

    <!-- Dialogo de búsqueda avanzada -->
    <Dialog
      v-model:visible="showSearchDialog"
      header="Búsqueda Avanzada"
      :modal="true"
      :style="{ width: '50vw' }"
    >
      <LicenciaSearchAdvanced
        @search="handleAdvancedSearch"
        @close="showSearchDialog = false"
      />
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { licenciasService } from '@/services/licencias.service'
import { useLicenciasStore } from '@/stores/licencias.store'
import { useToast } from 'primevue/usetoast'
import { useConfirm } from 'primevue/useconfirm'
import LicenciaForm from '../components/LicenciaForm.vue'
import LicenciaSearchAdvanced from '../components/LicenciaSearchAdvanced.vue'

const router = useRouter()
const toast = useToast()
const confirm = useConfirm()
const licenciasStore = useLicenciasStore()

// State
const licencias = ref([])
const loading = ref(false)
const totalRecords = ref(0)
const quickSearch = ref('')
const filtroEstatus = ref(null)
const filtroGiro = ref(null)
const sortField = ref('numero')
const sortOrder = ref(-1)
const currentPage = ref(0)
const showFormDialog = ref(false)
const showSearchDialog = ref(false)
const showReportesDialog = ref(false)
const selectedLicencia = ref(null)

// Options
const estatusOptions = [
  { label: 'Todos', value: null },
  { label: 'Vigente', value: 'VIGENTE' },
  { label: 'Suspendida', value: 'SUSPENDIDA' },
  { label: 'Cancelada', value: 'CANCELADA' },
  { label: 'Vencida', value: 'VENCIDA' }
]

const girosOptions = computed(() => licenciasStore.giros)

// Computed
const formTitle = computed(() =>
  selectedLicencia.value?.id ? 'Editar Licencia' : 'Nueva Licencia'
)

// Methods
const loadLicencias = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value + 1,
      perPage: 20,
      sortBy: sortField.value,
      sortOrder: sortOrder.value === 1 ? 'asc' : 'desc',
      search: quickSearch.value,
      estatus: filtroEstatus.value,
      giroId: filtroGiro.value
    }

    const response = await licenciasService.getAll(params)
    licencias.value = response.data
    totalRecords.value = response.total
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: 'Error al cargar licencias',
      life: 3000
    })
  } finally {
    loading.value = false
  }
}

const handleQuickSearch = debounce(() => {
  loadLicencias()
}, 500)

const onPage = (event) => {
  currentPage.value = event.page
  loadLicencias()
}

const onSort = (event) => {
  sortField.value = event.sortField
  sortOrder.value = event.sortOrder
  loadLicencias()
}

const openForm = () => {
  selectedLicencia.value = null
  showFormDialog.value = true
}

const verDetalle = (licencia) => {
  router.push(`/licencias/${licencia.id}`)
}

const editarLicencia = (licencia) => {
  selectedLicencia.value = { ...licencia }
  showFormDialog.value = true
}

const renovarLicencia = async (licencia) => {
  confirm.require({
    message: `¿Desea renovar la licencia ${licencia.numero}?`,
    header: 'Confirmar Renovación',
    icon: 'pi pi-refresh',
    accept: async () => {
      try {
        await licenciasService.renovar(licencia.id, {
          vigencia: new Date().getFullYear() + 1
        })
        toast.add({
          severity: 'success',
          summary: 'Éxito',
          detail: 'Licencia renovada correctamente',
          life: 3000
        })
        loadLicencias()
      } catch (error) {
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: error.response?.data?.message || 'Error al renovar',
          life: 3000
        })
      }
    }
  })
}

const suspenderLicencia = async (licencia) => {
  confirm.require({
    message: `¿Desea suspender la licencia ${licencia.numero}?`,
    header: 'Confirmar Suspensión',
    icon: 'pi pi-exclamation-triangle',
    acceptClass: 'p-button-danger',
    accept: async () => {
      try {
        await licenciasService.suspender(licencia.id, 'Suspensión manual')
        toast.add({
          severity: 'success',
          summary: 'Éxito',
          detail: 'Licencia suspendida',
          life: 3000
        })
        loadLicencias()
      } catch (error) {
        toast.add({
          severity: 'error',
          summary: 'Error',
          detail: 'Error al suspender licencia',
          life: 3000
        })
      }
    }
  })
}

const handleSave = async (data) => {
  try {
    if (data.id) {
      await licenciasService.actualizar(data.id, data)
      toast.add({
        severity: 'success',
        summary: 'Éxito',
        detail: 'Licencia actualizada',
        life: 3000
      })
    } else {
      await licenciasService.crear(data)
      toast.add({
        severity: 'success',
        summary: 'Éxito',
        detail: 'Licencia creada',
        life: 3000
      })
    }
    showFormDialog.value = false
    loadLicencias()
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: error.response?.data?.message || 'Error al guardar',
      life: 3000
    })
  }
}

const handleAdvancedSearch = async (criteria) => {
  loading.value = true
  try {
    const response = await licenciasService.buscar(criteria)
    licencias.value = response.data
    totalRecords.value = response.total
    showSearchDialog.value = false
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: 'Error en búsqueda',
      life: 3000
    })
  } finally {
    loading.value = false
  }
}

// Utility methods
const formatDireccion = (direccion) => {
  if (!direccion) return '-'
  return `${direccion.calle} ${direccion.numero}, ${direccion.colonia}`
}

const formatDate = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const getEstatusSeverity = (estatus) => {
  const severity = {
    'VIGENTE': 'success',
    'SUSPENDIDA': 'warning',
    'CANCELADA': 'danger',
    'VENCIDA': 'danger'
  }
  return severity[estatus] || 'info'
}

const isVencida = (vigencia) => {
  if (!vigencia) return false
  return new Date(vigencia) < new Date()
}

// Debounce helper
function debounce(fn, delay) {
  let timeoutId
  return (...args) => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn(...args), delay)
  }
}

// Lifecycle
onMounted(async () => {
  await licenciasStore.loadGiros()
  loadLicencias()
})
</script>

<style scoped>
.licencias-container {
  padding: 2rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.header h1 {
  font-size: 1.75rem;
  color: #2c3e50;
}

.actions {
  display: flex;
  gap: 1rem;
}

.filters {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.text-danger {
  color: #e74c3c;
}

@media (max-width: 768px) {
  .filters {
    grid-template-columns: 1fr;
  }

  .actions {
    flex-direction: column;
  }
}
</style>
```

Este es solo el INICIO del plan detallado. ¿Quieres que continúe con:
- El resto del Día 3 (Licencias completo)
- Día 4 (Multas + Est. Exclusivo)
- Día 5 (Est. Público + Deploy)

¿O prefieres ajustar algo de lo que ya documenté?