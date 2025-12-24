<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta General de Locales</h1>
        <p>Inicio > Consultas > General</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="locales.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="locales.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Búsqueda de Local
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <!-- Filtros en dos filas -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select v-model="form.oficina" class="municipal-form-control" required @change="cargarMercados">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                   {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select v-model="form.num_mercado" class="municipal-form-control" required :disabled="!form.oficina">
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select v-model="form.categoria" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.id" :value="cat.id">
                    {{ cat.nombre }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select v-model="form.seccion" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input v-model="form.local" type="number" class="municipal-form-control" required
                  placeholder="Número de local">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input v-model="form.letra_local" type="text" class="municipal-form-control" maxlength="1"
                  placeholder="A-Z">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="1" placeholder="1-9">
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary me-2">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                  <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros">
                    <font-awesome-icon icon="eraser" />
                    Limpiar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla: Resultados de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="locales.length > 0">
              {{ formatNumber(locales.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de error -->
          <div v-if="errorLocales" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorLocales }}
          </div>

          <!-- Tabla con paginación -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Nombre</th>
                  <th>Arrendatario</th>
                  <th>Giro</th>
                  <th>Superficie</th>
                  <th>Vigencia</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0 && !searchPerformed">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar locales</p>
                  </td>
                </tr>
                <tr v-else-if="locales.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="loc in paginatedLocales" :key="loc.id_local" @click="selectedLocal = loc"
                  :class="{ 'table-row-selected': selectedLocal?.id_local === loc.id_local }" class="row-hover">
                  <td><strong class="text-primary">{{ loc.id_local }}</strong></td>
                  <td>{{ loc.nombre }}</td>
                  <td>{{ loc.arrendatario }}</td>
                  <td>{{ loc.giro }}</td>
                  <td>{{ loc.superficie }}</td>
                  <td>{{ loc.vigencia }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="verDetalle(loc)">
                      <font-awesome-icon icon="eye" />
                      Ver Detalle
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div v-if="locales.length > 0" class="pagination-container">
              <div class="pagination-info">
                Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ locales.length }} registros
              </div>
              <div class="pagination-controls">
                <button class="btn-pagination" @click="previousPage" :disabled="currentPage === 1">
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <button v-for="page in displayedPages" :key="page" class="btn-pagination"
                  :class="{ active: currentPage === page }" @click="goToPage(page)">
                  {{ page }}
                </button>
                <button class="btn-pagination" @click="nextPage" :disabled="currentPage === totalPages">
                  <font-awesome-icon icon="chevron-right" />
                </button>
              </div>
              <div class="pagination-size">
                <select v-model.number="pageSize" class="page-size-select" @change="resetToFirstPage">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
                <span>por página</span>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de detalle usando componente Modal.vue -->
    <Modal :show="showModal" title="Detalle del Local" size="xl" @close="cerrarModal">
      <template #default>
        <!-- Información del local -->
        <div class="row">
          <div class="col-md-6">
            <table class="table table-sm table-bordered">
              <tr>
                <th class="table-light" style="width: 40%">Mercado</th>
                <td>{{ detalle.nombre_mercado }}</td>
              </tr>
              <tr>
                <th class="table-light">Control</th>
                <td>{{ detalle.id_local }}</td>
              </tr>
              <tr>
                <th class="table-light">Nombre</th>
                <td>{{ detalle.nombre }}</td>
              </tr>
              <tr>
                <th class="table-light">Arrendatario</th>
                <td>{{ detalle.arrendatario }}</td>
              </tr>
              <tr>
                <th class="table-light">Giro</th>
                <td>{{ detalle.giro }}</td>
              </tr>
              <tr>
                <th class="table-light">Superficie</th>
                <td>{{ detalle.superficie }}</td>
              </tr>
            </table>
          </div>
          <div class="col-md-6">
            <table class="table table-sm table-bordered">
              <tr>
                <th class="table-light" style="width: 40%">Fecha Alta</th>
                <td>{{ detalle.fecha_alta }}</td>
              </tr>
              <tr>
                <th class="table-light">Fecha Baja</th>
                <td>{{ detalle.fecha_baja || '-' }}</td>
              </tr>
              <tr>
                <th class="table-light">Vigencia</th>
                <td>{{ detalle.vigencia }}</td>
              </tr>
              <tr>
                <th class="table-light">Usuario</th>
                <td>{{ detalle.id_usuario || '-' }}</td>
              </tr>
              <tr>
                <th class="table-light">Sector</th>
                <td>{{ detalle.sector || '-' }}</td>
              </tr>
              <tr>
                <th class="table-light">Descripción</th>
                <td>{{ detalle.descripcion_local || '-' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Tabs de información adicional -->
        <ul class="nav nav-tabs-custom mt-4">
          <li class="nav-item">
            <button class="nav-link-custom tab-adeudos" :class="{ active: tab === 'adeudos' }" @click="tab = 'adeudos'">
              <font-awesome-icon icon="exclamation-circle" class="tab-icon" />
              <span class="tab-label">Adeudos</span>
              <span class="tab-badge badge-danger">{{ adeudos.length }}</span>
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link-custom tab-pagos" :class="{ active: tab === 'pagos' }" @click="tab = 'pagos'">
              <font-awesome-icon icon="money-bill-wave" class="tab-icon" />
              <span class="tab-label">Pagos</span>
              <span class="tab-badge badge-success">{{ pagos.length }}</span>
            </button>
          </li>
          <li class="nav-item">
            <button class="nav-link-custom tab-requerimientos" :class="{ active: tab === 'requerimientos' }"
              @click="tab = 'requerimientos'">
              <font-awesome-icon icon="file-invoice" class="tab-icon" />
              <span class="tab-label">Requerimientos</span>
              <span class="tab-badge badge-warning">{{ requerimientos.length }}</span>
            </button>
          </li>
        </ul>

        <!-- Contenido de tabs -->
        <div class="tab-content-custom">
          <!-- Tab Adeudos -->
          <div v-if="tab === 'adeudos'" class="tab-pane-custom fade-in">
            <div v-if="loadingTab" class="text-center py-5">
              <div class="spinner-border text-danger" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-3 text-muted">Cargando adeudos...</p>
            </div>
            <div v-else>
              <div v-if="adeudos.length > 0" class="table-responsive">
                <table class="table-custom table-adeudos">
                  <thead>
                    <tr>
                      <th>Año</th>
                      <th>Periodo</th>
                      <th class="text-end">Importe</th>
                      <th class="text-end">Recargos</th>
                      <th class="text-end">Total</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(a, idx) in adeudos" :key="idx" class="table-row-hover">
                      <td><span class="badge-year">{{ a.axo }}</span></td>
                      <td><span class="badge-period">Periodo {{ a.periodo }}</span></td>
                      <td class="text-end">
                        <span class="amount-danger">{{ formatCurrency(a.importe) }}</span>
                      </td>
                      <td class="text-end">
                        <span class="amount-warning">{{ formatCurrency(a.recargos) }}</span>
                      </td>
                      <td class="text-end">
                        <span class="amount-total">{{ formatCurrency(parseFloat(a.importe || 0) + parseFloat(a.recargos
                          || 0)) }}</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div v-else class="empty-state">
                <font-awesome-icon icon="check-circle" size="3x" class="empty-icon-success" />
                <h5>Sin adeudos pendientes</h5>
                <p class="text-muted">Este local no tiene adeudos registrados</p>
              </div>
            </div>
          </div>

          <!-- Tab Pagos -->
          <div v-if="tab === 'pagos'" class="tab-pane-custom fade-in">
            <div v-if="loadingTab" class="text-center py-5">
              <div class="spinner-border text-success" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-3 text-muted">Cargando pagos...</p>
            </div>
            <div v-else>
              <div v-if="pagos.length > 0" class="table-responsive">
                <table class="table-custom table-pagos">
                  <thead>
                    <tr>
                      <th>Año</th>
                      <th>Periodo</th>
                      <th>Fecha Pago</th>
                      <th class="text-end">Importe</th>
                      <th>Folio</th>
                      <th>Usuario</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(p, idx) in pagos" :key="idx" class="table-row-hover">
                      <td><span class="badge-year">{{ p.axo }}</span></td>
                      <td><span class="badge-period">Periodo {{ p.periodo }}</span></td>
                      <td>
                        <font-awesome-icon icon="calendar-alt" class="icon-small text-muted" />
                        {{ p.fecha_pago }}
                      </td>
                      <td class="text-end">
                        <span class="amount-success">{{ formatCurrency(p.importe_pago) }}</span>
                      </td>
                      <td>
                        <span class="folio-badge">{{ p.folio || 'N/A' }}</span>
                      </td>
                      <td>
                        <font-awesome-icon icon="user" class="icon-small text-muted" />
                        {{ p.usuario || 'N/A' }}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div v-else class="empty-state">
                <font-awesome-icon icon="receipt" size="3x" class="empty-icon-info" />
                <h5>Sin pagos registrados</h5>
                <p class="text-muted">Este local no tiene pagos registrados</p>
              </div>
            </div>
          </div>

          <!-- Tab Requerimientos -->
          <div v-if="tab === 'requerimientos'" class="tab-pane-custom fade-in">
            <div v-if="loadingTab" class="text-center py-5">
              <div class="spinner-border text-warning" role="status">
                <span class="visually-hidden">Cargando...</span>
              </div>
              <p class="mt-3 text-muted">Cargando requerimientos...</p>
            </div>
            <div v-else>
              <div v-if="requerimientos.length > 0" class="table-responsive">
                <table class="table-custom table-requerimientos">
                  <thead>
                    <tr>
                      <th>Folio</th>
                      <th>Fecha Emisión</th>
                      <th class="text-end">Importe Multa</th>
                      <th class="text-end">Importe Gastos</th>
                      <th class="text-end">Total</th>
                      <th>Vigencia</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(r, idx) in requerimientos" :key="idx" class="table-row-hover">
                      <td>
                        <span class="folio-badge-primary">{{ r.folio }}</span>
                      </td>
                      <td>
                        <font-awesome-icon icon="calendar-alt" class="icon-small text-muted" />
                        {{ r.fecha_emision }}
                      </td>
                      <td class="text-end">
                        <span class="amount-warning">{{ formatCurrency(r.importe_multa) }}</span>
                      </td>
                      <td class="text-end">
                        <span class="amount-info">{{ formatCurrency(r.importe_gastos) }}</span>
                      </td>
                      <td class="text-end">
                        <span class="amount-total">{{ formatCurrency(parseFloat(r.importe_multa || 0) +
                          parseFloat(r.importe_gastos || 0)) }}</span>
                      </td>
                      <td>
                        <span class="badge-vigencia">{{ r.vigencia }}</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div v-else class="empty-state">
                <font-awesome-icon icon="check-circle" size="3x" class="empty-icon-success" />
                <h5>Sin requerimientos pendientes</h5>
                <p class="text-muted">Este local no tiene requerimientos registrados</p>
              </div>
            </div>
          </div>
        </div>
      
  <DocumentationModal :show="showAyuda" :component-name="'ConsultaGeneral'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ConsultaGeneral'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ConsultaGeneral'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ConsultaGeneral'" @close="showDocumentacion = false" />
</template>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, onMounted, computed, watch } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { withLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const loadingTab = ref(false)
const showModal = ref(false)
const tab = ref('adeudos')

// Watcher para debug
watch(showModal, (newVal, oldVal) => {
  console.log('🔷 WATCH showModal cambió:', { oldVal, newVal })
})

// Errores
const errorLocales = ref('')

// Estado de búsqueda
const searchPerformed = ref(false)
const selectedLocal = ref(null)

// Catálogos
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const categorias = ref([
  { id: 1, nombre: 'Categoría 1' },
  { id: 2, nombre: 'Categoría 2' },
  { id: 3, nombre: 'Categoría 3' }
])

// Formulario
const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: ''
})

// Datos
const locales = ref([])
const detalle = ref({})
const adeudos = ref([])
const pagos = ref([])
const requerimientos = ref([])

// Watcher para debug de detalle
watch(detalle, (newVal) => {
  console.log('🔶 WATCH detalle cambió:', newVal)
}, { deep: true })

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const totalPages = computed(() => {
  return Math.ceil(locales.value.length / pageSize.value)
})

const startIndex = computed(() => {
  return (currentPage.value - 1) * pageSize.value
})

const endIndex = computed(() => {
  const end = startIndex.value + pageSize.value
  return end > locales.value.length ? locales.value.length : end
})

const paginatedLocales = computed(() => {
  return locales.value.slice(startIndex.value, endIndex.value)
})

const displayedPages = computed(() => {
  const pages = []
  const maxDisplayed = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxDisplayed / 2))
  let endPage = Math.min(totalPages.value, startPage + maxDisplayed - 1)

  if (endPage - startPage < maxDisplayed - 1) {
    startPage = Math.max(1, endPage - maxDisplayed + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const resetToFirstPage = () => {
  currentPage.value = 1
}

// Métodos de UI
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ingrese los datos del local para buscar su información general. Los campos marcados con (*) son obligatorios.', 'info')
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return 'N/A'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return 'N/A'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Lifecycle
onMounted(() => {
  console.log('🟣 ConsultaGeneral montado')
  console.log('🟣 showModal inicial:', showModal.value)
  cargarRecaudadoras()
  cargarSecciones()
})

const cargarRecaudadoras = async () => {
  await withLoading(async () => {
    errorLocales.value = ''
    try {
      const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )

      if (res.success) {
        recaudadoras.value = res.data.result || []
        if (recaudadoras.value.length > 0) {
          showToast(`Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`, 'success')
        }
      } else {
        errorLocales.value = res.message || 'Error al cargar recaudadoras'
        showToast(errorLocales.value, 'error')
      }
    } catch (err) {
      errorLocales.value = 'Error de conexión al cargar recaudadoras'
      console.error('Error al cargar recaudadoras:', err)
      showToast(errorLocales.value, 'error')
    }
  })
}

const cargarMercados = async () => {
  mercados.value = []
  form.value.num_mercado = ''
  form.value.seccion = ''

  if (!form.value.oficina) return

  await withLoading(async () => {
    errorLocales.value = ''
    try {
      const nivelUsuario = 1 // TODO: Obtener del store de usuario
      const oficinaParam = form.value.oficina || null

      const res = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [
            { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
            { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
          ],
          '',
          null,
          'publico'
        )

      if (res.success) {
        mercados.value = res.data.result || []
        if (mercados.value.length > 0) {
          showToast(`Se cargaron ${mercados.value.length} mercados`, 'success')
        } else {
          showToast('No se encontraron mercados para esta oficina', 'info')
        }
      } else {
        errorLocales.value = res.message || 'Error al cargar mercados'
        showToast(errorLocales.value, 'error')
      }
    } catch (err) {
      errorLocales.value = 'Error de conexión al cargar mercados'
      console.error('Error al cargar mercados:', err)
      showToast(errorLocales.value, 'error')
    }
  })
}

const cargarSecciones = async () => {
  secciones.value = []
  form.value.seccion = ''

  await withLoading(async () => {
    errorLocales.value = ''
    try {
      const res = await apiService.execute(
          'sp_get_secciones',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
      if (res.success) {
        secciones.value = res.data.result || []
        if (secciones.value.length > 0) {
          showToast(`Se cargaron ${secciones.value.length} secciones`, 'success')
        }
      } else {
        errorLocales.value = res.message || 'Error al cargar secciones'
        showToast(errorLocales.value, 'error')
      }
    } catch (error) {
      errorLocales.value = 'Error de conexión al cargar secciones'
      console.error('Error al cargar secciones:', error)
      showToast(errorLocales.value, 'error')
    }
  })
}

const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
    errorLocales.value = 'Debe completar todos los campos obligatorios'
    showToast(errorLocales.value, 'warning')
    return
  }

  await withLoading(async () => {
    errorLocales.value = ''
    locales.value = []
    selectedLocal.value = null
    searchPerformed.value = true
    currentPage.value = 1

    try {
      const response = await apiService.execute(
          'sp_consulta_general_buscar',
          'mercados',
          [
            { nombre: 'p_oficina', valor: parseInt(form.value.oficina) },
            { nombre: 'p_num_mercado', valor: parseInt(form.value.num_mercado) },
            { nombre: 'p_categoria', valor: parseInt(form.value.categoria) || 1 },
            { nombre: 'p_seccion', valor: form.value.seccion },
            { nombre: 'p_local', valor: parseInt(form.value.local) },
            { nombre: 'p_letra_local', valor: form.value.letra_local || null },
            { nombre: 'p_bloque', valor: form.value.bloque || null }
          ],
          '',
          null,
          'publico'
        )
      if (response && response.success === true) {
        locales.value = response.data.result || []
        if (locales.value.length === 0) {
          showToast('No se encontraron locales con los criterios especificados', 'info')
        } else {
          showToast(`Se encontraron ${locales.value.length} locales`, 'success')
          showFilters.value = false
        }
      } else {
        errorLocales.value = response?.message || 'Error en la búsqueda'
        showToast(errorLocales.value, 'error')
      }
    } catch (error) {
      errorLocales.value = error.response?.message || 'Error al buscar locales'
      console.error('Error al buscar locales:', error)
      showToast(errorLocales.value, 'error')
    }
  })
}

const limpiarFiltros = () => {
  form.value.oficina = ''
  form.value.num_mercado = ''
  form.value.categoria = ''
  form.value.seccion = ''
  form.value.local = ''
  form.value.letra_local = ''
  form.value.bloque = ''
  mercados.value = []
  locales.value = []
  selectedLocal.value = null
  errorLocales.value = ''
  searchPerformed.value = false
  currentPage.value = 1
  // Recargar secciones
  cargarSecciones()
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (locales.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

const imprimir = () => {
  if (locales.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  // TODO: Implementar impresión
  showToast('Funcionalidad de impresión en desarrollo', 'info')
}

const verDetalle = async (local) => {
  console.log('🔵 [1] verDetalle - INICIO', { local, id_local: local.id_local })

  adeudos.value = []
  pagos.value = []
  requerimientos.value = []
  tab.value = 'adeudos'

  console.log('🔵 [2] verDetalle - Arrays limpiados, llamando cargarDetalleCompleto...')

  // Cargar detalle completo del local y datos de tabs
  await cargarDetalleCompleto(local.id_local)

  console.log('🔵 [3] verDetalle - cargarDetalleCompleto completado')
  console.log('🔵 [4] verDetalle - detalle.value:', detalle.value)
  console.log('🔵 [5] verDetalle - adeudos.length:', adeudos.value.length)
  console.log('🔵 [6] verDetalle - pagos.length:', pagos.value.length)
  console.log('🔵 [7] verDetalle - requerimientos.length:', requerimientos.value.length)

  // Mostrar modal DESPUÉS de cargar datos
  console.log('🔵 [8] verDetalle - Cambiando showModal a true...')
  showModal.value = true
  console.log('🔵 [9] verDetalle - showModal.value:', showModal.value)
  console.log('🔵 [10] verDetalle - FIN')
}

const cargarDetalleCompleto = async (idLocal) => {
  console.log('🟢 [A] cargarDetalleCompleto - INICIO', { idLocal })
  loadingTab.value = true

  try {
    console.log('🟢 [B] cargarDetalleCompleto - Llamando sp_get_datos_individuales...')

    // Cargar detalle completo del local
    const resDetalle = await apiService.execute(
          'sp_get_datos_individuales',
          'mercados',
          [
          { nombre: 'p_id_local', valor: idLocal }
        ],
          '',
          null,
          'publico'
        )

    console.log('🟢 [C] cargarDetalleCompleto - Respuesta recibida:', resDetalle.data)

    if (resDetalle.success) {
      const result = resDetalle.data.result
      console.log('🟢 [D] cargarDetalleCompleto - Result:', result)

      if (result && result.length > 0) {
        detalle.value = result[0]
        console.log('🟢 [E] cargarDetalleCompleto - detalle.value asignado:', detalle.value)

        // Agregar nombre del mercado si está disponible
        // Intentar buscar por num_mercado_nvo primero, luego por num_mercado
        let mercado = null
        if (detalle.value.num_mercado_nvo) {
          mercado = mercados.value.find(m => m.num_mercado_nvo === detalle.value.num_mercado_nvo)
        }

        // Si no se encontró por num_mercado_nvo, intentar por num_mercado
        if (!mercado && detalle.value.num_mercado) {
          mercado = mercados.value.find(m =>
            m.oficina === detalle.value.oficina &&
            m.num_mercado_nvo === detalle.value.num_mercado
          )
        }

        console.log('🟢 [F] cargarDetalleCompleto - Mercado encontrado:', mercado)

        if (mercado) {
          detalle.value.nombre_mercado = mercado.descripcion
        } else {
          // Si no se encuentra el mercado, mostrar "-" en lugar de "Mercado null"
          detalle.value.nombre_mercado = '-'
        }
        console.log('🟢 [G] cargarDetalleCompleto - nombre_mercado asignado:', detalle.value.nombre_mercado)
      } else {
        console.warn('⚠️ cargarDetalleCompleto - Result vacío o undefined')
      }
    } else {
      console.error("Error en respuesta:", )
    }

    // Cargar datos de tabs
    console.log('🟢 [H] cargarDetalleCompleto - Llamando cargarDatosDetalle...')
    await cargarDatosDetalle(idLocal)
    console.log('🟢 [I] cargarDetalleCompleto - cargarDatosDetalle completado')

  } catch (error) {
    console.error('❌ cargarDetalleCompleto - ERROR:', error)
    showToast('Error al cargar detalle del local', 'error')
    loadingTab.value = false
  }

  console.log('🟢 [J] cargarDetalleCompleto - FIN')
}

const cargarDatosDetalle = async (idLocal) => {
  console.log('🟡 [1] cargarDatosDetalle - INICIO', { idLocal })
  loadingTab.value = true

  try {
    console.log('🟡 [2] cargarDatosDetalle - Cargando adeudos...')

    // Cargar adeudos
    const resAdeudos = await apiService.execute(
          'sp_consulta_general_adeudos',
          'mercados',
          [
          { nombre: 'p_id_local', valor: idLocal }
        ],
          '',
          null,
          'publico'
        )

    console.log('🟡 [3] cargarDatosDetalle - Respuesta adeudos:', resAdeudos.data)

    if (resAdeudos.success) {
      adeudos.value = resAdeudos.data.result || []
      console.log('🟡 [4] cargarDatosDetalle - Adeudos cargados:', adeudos.value.length)
    }

    console.log('🟡 [5] cargarDatosDetalle - Cargando pagos...')

    // Cargar pagos
    const resPagos = await apiService.execute(
          'sp_consulta_general_pagos',
          'mercados',
          [
          { nombre: 'p_id_local', valor: idLocal }
        ],
          '',
          null,
          'publico'
        )

    console.log('🟡 [6] cargarDatosDetalle - Respuesta pagos:', resPagos.data)

    if (resPagos.success) {
      pagos.value = resPagos.data.result || []
      console.log('🟡 [7] cargarDatosDetalle - Pagos cargados:', pagos.value.length)
    }

    console.log('🟡 [8] cargarDatosDetalle - Cargando requerimientos...')

    // Cargar requerimientos
    const resReq = await apiService.execute(
          'sp_consulta_general_requerimientos',
          'mercados',
          [
          { nombre: 'p_id_local', valor: idLocal }
        ],
          '',
          null,
          'publico'
        )

    console.log('🟡 [9] cargarDatosDetalle - Respuesta requerimientos:', resReq.data)

    if (resReq.success) {
      requerimientos.value = resReq.data.result || []
      console.log('🟡 [10] cargarDatosDetalle - Requerimientos cargados:', requerimientos.value.length)
    }

    console.log('🟡 [11] cargarDatosDetalle - Todos los datos cargados exitosamente')

  } catch (error) {
    console.error('❌ cargarDatosDetalle - ERROR:', error)
    showToast('Error al cargar detalles', 'error')
  } finally {
    loadingTab.value = false
    console.log('🟡 [12] cargarDatosDetalle - FIN (loadingTab = false)')
  }
}

const cerrarModal = () => {
  console.log('🔴 cerrarModal - Cerrando modal')
  showModal.value = false
}
</script>
