<template>
  <div class="module-view estacionamiento-exclusivo-menu">
    <!-- Header del módulo con gradiente -->
    <div class="module-view-header header-gradient">
      <div class="module-view-icon icon-animated">
        <font-awesome-icon icon="parking" />
      </div>
      <div class="module-view-info">
        <h1>Estacionamiento Exclusivo</h1>
        <p>Sistema de Gestión de Apremios y Cobranza</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de información del usuario - Estilo Dashboard -->
      <div class="user-dashboard-panel">
        <div class="user-info-card">
          <div class="user-avatar">
            <font-awesome-icon icon="user-circle" />
          </div>
          <div class="user-details">
            <span class="user-label">Usuario</span>
            <span class="user-value">{{ userName }}</span>
          </div>
        </div>
        <div class="user-info-card">
          <div class="user-avatar ejercicio">
            <font-awesome-icon icon="calendar-alt" />
          </div>
          <div class="user-details">
            <span class="user-label">Ejercicio Fiscal</span>
            <select v-model="selectedEjercicio" class="ejercicio-select">
              <option v-for="ej in ejercicios" :key="ej" :value="ej">{{ ej }}</option>
            </select>
          </div>
        </div>
        <div class="user-info-card">
          <div class="user-avatar fecha">
            <font-awesome-icon icon="clock" />
          </div>
          <div class="user-details">
            <span class="user-label">Fecha Actual</span>
            <span class="user-value">{{ currentDate }}</span>
          </div>
        </div>
      </div>

      <!-- Sección de Accesos Rápidos -->
      <div class="quick-access-section">
        <div class="section-header">
          <h2>
            <font-awesome-icon icon="bolt" />
            Acceso Rápido
          </h2>
          <span class="badge-count">{{ quickAccessItems.length }} módulos frecuentes</span>
        </div>
        <div class="quick-access-grid">
          <button
            v-for="item in quickAccessItems"
            :key="item.path"
            class="quick-access-btn"
            @click="goTo(item.path)"
          >
            <div class="quick-icon" :class="item.color">
              <font-awesome-icon :icon="item.icon" />
            </div>
            <span>{{ item.name }}</span>
          </button>
        </div>
      </div>

      <!-- Menú Principal Categorizado -->
      <div class="main-menu-section">
        <div class="section-header">
          <h2>
            <font-awesome-icon icon="th-large" />
            Módulos del Sistema
          </h2>
          <div class="view-toggle">
            <button
              :class="{ active: viewMode === 'grid' }"
              @click="viewMode = 'grid'"
              title="Vista de cuadrícula"
            >
              <font-awesome-icon icon="th" />
            </button>
            <button
              :class="{ active: viewMode === 'list' }"
              @click="viewMode = 'list'"
              title="Vista de lista"
            >
              <font-awesome-icon icon="list" />
            </button>
          </div>
        </div>

        <!-- Categoría: Apremios SVN -->
        <div class="menu-category">
          <div class="category-header apremios">
            <font-awesome-icon icon="gavel" />
            <h3>Sistema de Apremios SVN</h3>
            <span class="category-count">6 módulos</span>
          </div>
          <div class="menu-grid" :class="viewMode">
            <button
              v-for="item in apremiosItems"
              :key="item.path"
              class="menu-card"
              @click="goTo(item.path)"
            >
              <div class="card-icon" :class="item.color">
                <font-awesome-icon :icon="item.icon" />
              </div>
              <div class="card-content">
                <h4>{{ item.name }}</h4>
                <p>{{ item.description }}</p>
              </div>
              <div class="card-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </button>
          </div>
        </div>

        <!-- Categoría: Consultas -->
        <div class="menu-category">
          <div class="category-header consultas">
            <font-awesome-icon icon="search" />
            <h3>Consultas y Búsquedas</h3>
            <span class="category-count">{{ consultasItems.length }} módulos</span>
          </div>
          <div class="menu-grid" :class="viewMode">
            <button
              v-for="item in consultasItems"
              :key="item.path"
              class="menu-card"
              @click="goTo(item.path)"
            >
              <div class="card-icon" :class="item.color">
                <font-awesome-icon :icon="item.icon" />
              </div>
              <div class="card-content">
                <h4>{{ item.name }}</h4>
                <p>{{ item.description }}</p>
              </div>
              <div class="card-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </button>
          </div>
        </div>

        <!-- Categoría: Listados y Reportes -->
        <div class="menu-category">
          <div class="category-header reportes">
            <font-awesome-icon icon="chart-bar" />
            <h3>Listados y Reportes</h3>
            <span class="category-count">{{ reportesItems.length }} módulos</span>
          </div>
          <div class="menu-grid" :class="viewMode">
            <button
              v-for="item in reportesItems"
              :key="item.path"
              class="menu-card"
              @click="goTo(item.path)"
            >
              <div class="card-icon" :class="item.color">
                <font-awesome-icon :icon="item.icon" />
              </div>
              <div class="card-content">
                <h4>{{ item.name }}</h4>
                <p>{{ item.description }}</p>
              </div>
              <div class="card-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </button>
          </div>
        </div>

        <!-- Categoría: Ejecutores -->
        <div class="menu-category">
          <div class="category-header ejecutores">
            <font-awesome-icon icon="user-tie" />
            <h3>Gestión de Ejecutores</h3>
            <span class="category-count">{{ ejecutoresItems.length }} módulos</span>
          </div>
          <div class="menu-grid" :class="viewMode">
            <button
              v-for="item in ejecutoresItems"
              :key="item.path"
              class="menu-card"
              @click="goTo(item.path)"
            >
              <div class="card-icon" :class="item.color">
                <font-awesome-icon :icon="item.icon" />
              </div>
              <div class="card-content">
                <h4>{{ item.name }}</h4>
                <p>{{ item.description }}</p>
              </div>
              <div class="card-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </button>
          </div>
        </div>

        <!-- Categoría: Operaciones -->
        <div class="menu-category">
          <div class="category-header operaciones">
            <font-awesome-icon icon="cogs" />
            <h3>Operaciones y Modificaciones</h3>
            <span class="category-count">{{ operacionesItems.length }} módulos</span>
          </div>
          <div class="menu-grid" :class="viewMode">
            <button
              v-for="item in operacionesItems"
              :key="item.path"
              class="menu-card"
              @click="goTo(item.path)"
            >
              <div class="card-icon" :class="item.color">
                <font-awesome-icon :icon="item.icon" />
              </div>
              <div class="card-content">
                <h4>{{ item.name }}</h4>
                <p>{{ item.description }}</p>
              </div>
              <div class="card-arrow">
                <font-awesome-icon icon="chevron-right" />
              </div>
            </button>
          </div>
        </div>
      </div>

      <!-- Panel de Estadísticas -->
      <div class="stats-dashboard">
        <div class="stats-card completados">
          <div class="stats-icon">
            <font-awesome-icon icon="check-double" />
          </div>
          <div class="stats-info">
            <span class="stats-number">68</span>
            <span class="stats-label">Módulos Activos</span>
          </div>
          <div class="stats-badge">100%</div>
        </div>
        <div class="stats-card procedures">
          <div class="stats-icon">
            <font-awesome-icon icon="database" />
          </div>
          <div class="stats-info">
            <span class="stats-number">180+</span>
            <span class="stats-label">Stored Procedures</span>
          </div>
        </div>
        <div class="stats-card performance">
          <div class="stats-icon">
            <font-awesome-icon icon="tachometer-alt" />
          </div>
          <div class="stats-info">
            <span class="stats-number">&lt;2s</span>
            <span class="stats-label">Tiempo Respuesta</span>
          </div>
        </div>
        <div class="stats-card tecnologia">
          <div class="stats-icon">
            <font-awesome-icon icon="code" />
          </div>
          <div class="stats-info">
            <span class="stats-number">Vue 3</span>
            <span class="stats-label">Composition API</span>
          </div>
        </div>
      </div>

    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Menu'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

// Router
const router = useRouter()

// Estados
const showDocumentation = ref(false)
const userName = ref('Usuario Sistema')
const selectedEjercicio = ref(new Date().getFullYear())
const ejercicios = ref([])
const viewMode = ref('grid')

// Datos de menú - Acceso Rápido
const quickAccessItems = ref([
  { name: 'Expedientes', path: '/estacionamiento-exclusivo/apremios-svn-expedientes', icon: 'folder-open', color: 'primary' },
  { name: 'Pagos', path: '/estacionamiento-exclusivo/apremios-svn-pagos', icon: 'dollar-sign', color: 'success' },
  { name: 'Reportes', path: '/estacionamiento-exclusivo/apremios-svn-reportes', icon: 'chart-bar', color: 'info' },
  { name: 'Listados', path: '/estacionamiento-exclusivo/listados', icon: 'list-alt', color: 'warning' },
  { name: 'Ejecutores', path: '/estacionamiento-exclusivo/ejecutores', icon: 'user-tie', color: 'purple' }
])

// Datos de menú - Apremios SVN
const apremiosItems = ref([
  { name: 'Expedientes', path: '/estacionamiento-exclusivo/apremios-svn-expedientes', icon: 'folder-open', color: 'primary', description: 'Gestión de expedientes' },
  { name: 'Control de Fases', path: '/estacionamiento-exclusivo/apremios-svn-fases', icon: 'tasks', color: 'info', description: 'Seguimiento de fases' },
  { name: 'Actuaciones', path: '/estacionamiento-exclusivo/apremios-svn-actuaciones', icon: 'clipboard-list', color: 'warning', description: 'Registro de actuaciones' },
  { name: 'Notificaciones SVN', path: '/estacionamiento-exclusivo/apremios-svn-notificaciones', icon: 'bell', color: 'danger', description: 'Control de notificaciones' },
  { name: 'Pagos SVN', path: '/estacionamiento-exclusivo/apremios-svn-pagos', icon: 'dollar-sign', color: 'success', description: 'Registro de pagos' },
  { name: 'Reportes SVN', path: '/estacionamiento-exclusivo/apremios-svn-reportes', icon: 'chart-pie', color: 'purple', description: 'Reportes del sistema' }
])

// Datos de menú - Consultas
const consultasItems = ref([
  { name: 'Consulta Individual', path: '/estacionamiento-exclusivo/individual', icon: 'search', color: 'primary', description: 'Búsqueda por expediente' },
  { name: 'Consulta por Folio', path: '/estacionamiento-exclusivo/individual-folio', icon: 'search-plus', color: 'primary', description: 'Búsqueda por folio' },
  { name: 'Consulta por Registro', path: '/estacionamiento-exclusivo/consulta-reg', icon: 'file-search', color: 'info', description: 'Búsqueda multicriterio' },
  { name: 'Historial', path: '/estacionamiento-exclusivo/cons-his', icon: 'history', color: 'purple', description: 'Consulta de historial' }
])

// Datos de menú - Listados y Reportes
const reportesItems = ref([
  { name: 'Listados Generales', path: '/estacionamiento-exclusivo/listados', icon: 'list', color: 'primary', description: 'Listado completo' },
  { name: 'Listados Adeudos', path: '/estacionamiento-exclusivo/listados-ade', icon: 'file-invoice-dollar', color: 'warning', description: 'Adeudos pendientes' },
  { name: 'Por Fecha', path: '/estacionamiento-exclusivo/list-x-fec', icon: 'calendar', color: 'info', description: 'Filtrar por fecha' },
  { name: 'Por Registro', path: '/estacionamiento-exclusivo/list-x-reg', icon: 'sort-alpha-down', color: 'primary', description: 'Ordenar por registro' },
  { name: 'Estado por Folio', path: '/estacionamiento-exclusivo/estad-x-folio', icon: 'chart-line', color: 'success', description: 'Estado de cuenta' },
  { name: 'Notificaciones', path: '/estacionamiento-exclusivo/notificaciones', icon: 'bell', color: 'warning', description: 'Lista de notificaciones' },
  { name: 'Notificaciones Mes', path: '/estacionamiento-exclusivo/notificaciones-mes', icon: 'calendar-alt', color: 'info', description: 'Por mes y año' },
  { name: 'Exportar Excel', path: '/estacionamiento-exclusivo/exportar-excel', icon: 'file-excel', color: 'success', description: 'Exportación masiva' }
])

// Datos de menú - Ejecutores
const ejecutoresItems = ref([
  { name: 'Catálogo Ejecutores', path: '/estacionamiento-exclusivo/ejecutores', icon: 'users', color: 'primary', description: 'Lista de ejecutores' },
  { name: 'ABC Ejecutores', path: '/estacionamiento-exclusivo/abc-ejec', icon: 'user-plus', color: 'success', description: 'Alta/Baja/Cambio' },
  { name: 'Lista por Ejecutor', path: '/estacionamiento-exclusivo/list-eje', icon: 'clipboard-list', color: 'info', description: 'Expedientes asignados' },
  { name: 'Gastos Cobranza', path: '/estacionamiento-exclusivo/lista-gastos-cob', icon: 'money-bill-wave', color: 'warning', description: 'Control de gastos' },
  { name: 'Prenómina', path: '/estacionamiento-exclusivo/prenomina', icon: 'file-invoice', color: 'purple', description: 'Cálculo prenómina' }
])

// Datos de menú - Operaciones
const operacionesItems = ref([
  { name: 'Modificar Registro', path: '/estacionamiento-exclusivo/modifcar', icon: 'edit', color: 'primary', description: 'Modificación individual' },
  { name: 'Modificar Bien', path: '/estacionamiento-exclusivo/modificar-bien', icon: 'tools', color: 'info', description: 'Bienes embargables' },
  { name: 'Modificación Masiva', path: '/estacionamiento-exclusivo/modif-masiva', icon: 'layer-group', color: 'warning', description: 'Cambios múltiples' },
  { name: 'Autorizar Descuentos', path: '/estacionamiento-exclusivo/autoriza-des', icon: 'percent', color: 'success', description: 'Autorización descuentos' },
  { name: 'Reasignación', path: '/estacionamiento-exclusivo/reasignacion', icon: 'exchange-alt', color: 'purple', description: 'Cambio de ejecutor' },
  { name: 'Requerimientos', path: '/estacionamiento-exclusivo/requerimientos', icon: 'file-signature', color: 'danger', description: 'Gestión requerimientos' },
  { name: 'Recuperación', path: '/estacionamiento-exclusivo/recuperacion', icon: 'undo', color: 'info', description: 'Recuperar expedientes' },
  { name: 'Facturación', path: '/estacionamiento-exclusivo/facturacion', icon: 'file-invoice-dollar', color: 'success', description: 'Emisión facturas' }
])

// Computed
const currentDate = computed(() => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  const date = new Date()
  return `${date.getDate()} de ${meses[date.getMonth()]} de ${date.getFullYear()}`
})

// Métodos
const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const goTo = (path) => {
  router.push(path)
}

const loadEjercicios = () => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let i = currentYear - 5; i <= currentYear + 1; i++) {
    years.push(i)
  }
  ejercicios.value = years
  selectedEjercicio.value = currentYear
}

// Lifecycle
onMounted(() => {
  loadEjercicios()

  // Obtener nombre de usuario si está en localStorage o session
  const storedUser = localStorage.getItem('userName') || sessionStorage.getItem('userName')
  if (storedUser) {
    userName.value = storedUser
  }
})
</script>

<style scoped>
/* ====== HEADER STYLES ====== */
.header-gradient {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  border-bottom: 3px solid #ea8215;
}

.icon-animated {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

/* ====== USER DASHBOARD PANEL ====== */
.user-dashboard-panel {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.user-info-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 12px;
  padding: 1.25rem;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  border: 1px solid #e9ecef;
  transition: all 0.3s ease;
}

.user-info-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
}

.user-avatar {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  background: linear-gradient(135deg, #ea8215 0%, #d4740f 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

.user-avatar.ejercicio {
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
}

.user-avatar.fecha {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.user-details {
  display: flex;
  flex-direction: column;
}

.user-label {
  font-size: 0.75rem;
  color: #6c757d;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
}

.user-value {
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a2e;
}

.ejercicio-select {
  border: none;
  background: transparent;
  font-size: 1rem;
  font-weight: 600;
  color: #1a1a2e;
  cursor: pointer;
  padding: 0;
}

.ejercicio-select:focus {
  outline: none;
}

/* ====== QUICK ACCESS SECTION ====== */
.quick-access-section {
  margin-bottom: 2rem;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.section-header h2 {
  font-size: 1.25rem;
  font-weight: 700;
  color: #1a1a2e;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
}

.section-header h2 svg {
  color: #ea8215;
}

.badge-count {
  background: #e9ecef;
  color: #495057;
  padding: 0.35rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.quick-access-grid {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.quick-access-btn {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.875rem 1.5rem;
  border: none;
  border-radius: 50px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  color: #1a1a2e;
}

.quick-access-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(234, 130, 21, 0.25);
}

.quick-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1rem;
}

.quick-icon.primary { background: linear-gradient(135deg, #0d6efd, #0a58ca); }
.quick-icon.success { background: linear-gradient(135deg, #198754, #146c43); }
.quick-icon.warning { background: linear-gradient(135deg, #ffc107, #e0a800); color: #1a1a2e; }
.quick-icon.info { background: linear-gradient(135deg, #0dcaf0, #0aa2c0); }
.quick-icon.purple { background: linear-gradient(135deg, #6f42c1, #5a32a3); }
.quick-icon.danger { background: linear-gradient(135deg, #dc3545, #bb2d3b); }

/* ====== VIEW TOGGLE ====== */
.view-toggle {
  display: flex;
  gap: 0.25rem;
  background: #e9ecef;
  padding: 0.25rem;
  border-radius: 8px;
}

.view-toggle button {
  padding: 0.5rem 0.75rem;
  border: none;
  background: transparent;
  border-radius: 6px;
  cursor: pointer;
  color: #6c757d;
  transition: all 0.2s ease;
}

.view-toggle button.active {
  background: white;
  color: #ea8215;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* ====== MENU CATEGORIES ====== */
.menu-category {
  margin-bottom: 2rem;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  border-radius: 12px;
  margin-bottom: 1rem;
  color: white;
}

.category-header.apremios {
  background: linear-gradient(135deg, #dc3545 0%, #bb2d3b 100%);
}

.category-header.consultas {
  background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
}

.category-header.reportes {
  background: linear-gradient(135deg, #0f3460 0%, #16213e 100%);
}

.category-header.ejecutores {
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
}

.category-header.operaciones {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}

.category-header svg {
  font-size: 1.25rem;
}

.category-header h3 {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  flex: 1;
}

.category-count {
  background: rgba(255, 255, 255, 0.2);
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
}

/* ====== MENU GRID ====== */
.menu-grid {
  display: grid;
  gap: 1rem;
}

.menu-grid.grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
}

.menu-grid.list {
  grid-template-columns: 1fr;
}

.menu-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
}

.menu-card:hover {
  border-color: #ea8215;
  box-shadow: 0 8px 25px rgba(234, 130, 21, 0.15);
  transform: translateX(5px);
}

.card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.25rem;
  flex-shrink: 0;
}

.card-icon.primary { background: linear-gradient(135deg, #0d6efd, #0a58ca); }
.card-icon.success { background: linear-gradient(135deg, #198754, #146c43); }
.card-icon.warning { background: linear-gradient(135deg, #ffc107, #e0a800); color: #1a1a2e; }
.card-icon.info { background: linear-gradient(135deg, #0dcaf0, #0aa2c0); }
.card-icon.purple { background: linear-gradient(135deg, #6f42c1, #5a32a3); }
.card-icon.danger { background: linear-gradient(135deg, #dc3545, #bb2d3b); }

.card-content {
  flex: 1;
  min-width: 0;
}

.card-content h4 {
  margin: 0 0 0.25rem 0;
  font-size: 0.95rem;
  font-weight: 600;
  color: #1a1a2e;
}

.card-content p {
  margin: 0;
  font-size: 0.8rem;
  color: #6c757d;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.card-arrow {
  color: #dee2e6;
  transition: all 0.3s ease;
}

.menu-card:hover .card-arrow {
  color: #ea8215;
  transform: translateX(5px);
}

/* ====== STATS DASHBOARD ====== */
.stats-dashboard {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1rem;
  margin-top: 2rem;
}

.stats-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 16px;
  color: white;
  position: relative;
  overflow: hidden;
}

.stats-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
}

.stats-card.completados {
  background: linear-gradient(135deg, #198754 0%, #146c43 100%);
}

.stats-card.procedures {
  background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);
}

.stats-card.performance {
  background: linear-gradient(135deg, #ea8215 0%, #d4740f 100%);
}

.stats-card.tecnologia {
  background: linear-gradient(135deg, #6f42c1 0%, #5a32a3 100%);
}

.stats-icon {
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.stats-info {
  flex: 1;
}

.stats-number {
  display: block;
  font-size: 1.75rem;
  font-weight: 700;
  line-height: 1.2;
}

.stats-label {
  display: block;
  font-size: 0.8rem;
  opacity: 0.9;
}

.stats-badge {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: rgba(255, 255, 255, 0.25);
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.75rem;
  font-weight: 600;
}

/* ====== RESPONSIVE ====== */
@media (max-width: 768px) {
  .user-dashboard-panel {
    grid-template-columns: 1fr;
  }

  .quick-access-grid {
    flex-direction: column;
  }

  .quick-access-btn {
    justify-content: center;
  }

  .menu-grid.grid {
    grid-template-columns: 1fr;
  }

  .stats-dashboard {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 480px) {
  .stats-dashboard {
    grid-template-columns: 1fr;
  }
}
</style>
