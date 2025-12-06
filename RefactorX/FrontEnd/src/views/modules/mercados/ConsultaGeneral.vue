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
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="locales.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="locales.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
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
                <select v-model="form.num_mercado" class="municipal-form-control" required
                  :disabled="!form.oficina">
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
                <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="1"
                  placeholder="1-9">
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
                <tr v-else v-for="loc in paginatedLocales" :key="loc.id_local"
                  @click="selectedLocal = loc"
                  :class="{ 'table-row-selected': selectedLocal?.id_local === loc.id_local }"
                  class="row-hover">
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
                <button
                  class="btn-pagination"
                  @click="previousPage"
                  :disabled="currentPage === 1"
                >
                  <font-awesome-icon icon="chevron-left" />
                </button>
                <button
                  v-for="page in displayedPages"
                  :key="page"
                  class="btn-pagination"
                  :class="{ active: currentPage === page }"
                  @click="goToPage(page)"
                >
                  {{ page }}
                </button>
                <button
                  class="btn-pagination"
                  @click="nextPage"
                  :disabled="currentPage === totalPages"
                >
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
    <Modal
      v-if="showModal"
      title="Detalle del Local"
      size="xl"
      @close="cerrarModal"
    >
      <template #body>
        <!-- Información del local -->
        <div class="row">
          <div class="col-md-6">
            <table class="table table-sm table-bordered">
              <tr><th class="table-light" style="width: 40%">Mercado</th><td>{{ detalle.nombre_mercado }}</td></tr>
              <tr><th class="table-light">Control</th><td>{{ detalle.id_local }}</td></tr>
              <tr><th class="table-light">Nombre</th><td>{{ detalle.nombre }}</td></tr>
              <tr><th class="table-light">Arrendatario</th><td>{{ detalle.arrendatario }}</td></tr>
              <tr><th class="table-light">Giro</th><td>{{ detalle.giro }}</td></tr>
              <tr><th class="table-light">Superficie</th><td>{{ detalle.superficie }}</td></tr>
            </table>
          </div>
          <div class="col-md-6">
            <table class="table table-sm table-bordered">
              <tr><th class="table-light" style="width: 40%">Fecha Alta</th><td>{{ detalle.fecha_alta }}</td></tr>
              <tr><th class="table-light">Fecha Baja</th><td>{{ detalle.fecha_baja || '-' }}</td></tr>
              <tr><th class="table-light">Vigencia</th><td>{{ detalle.vigencia }}</td></tr>
              <tr><th class="table-light">Usuario</th><td>{{ detalle.usuario }}</td></tr>
              <tr><th class="table-light">Bloqueo</th><td>{{ detalle.bloqueo || '-' }}</td></tr>
              <tr><th class="table-light">Observación</th><td>{{ detalle.observacion || '-' }}</td></tr>
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
            <button class="nav-link-custom tab-requerimientos" :class="{ active: tab === 'requerimientos' }" @click="tab = 'requerimientos'">
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
                        <span class="amount-total">{{ formatCurrency(parseFloat(a.importe || 0) + parseFloat(a.recargos || 0)) }}</span>
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
                        <span class="amount-total">{{ formatCurrency(parseFloat(r.importe_multa || 0) + parseFloat(r.importe_gastos || 0)) }}</span>
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
              </td>
            </div>
          </div>
        </div>
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
import { ref, onMounted, computed } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/shared/Modal.vue'

// Composables
const { withLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const loadingTab = ref(false)
const showModal = ref(false)
const tab = ref('adeudos')

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
  showToast('info', 'Ingrese los datos del local para buscar su información general. Los campos marcados con (*) son obligatorios.')
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
  cargarRecaudadoras()
  cargarSecciones()
})

const cargarRecaudadoras = async () => {
  await withLoading(async () => {
    errorLocales.value = ''
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_recaudadoras',
          Base: 'padron_licencias',
          Parametros: []
        }
      })

      if (res.data.eResponse.success === true) {
        recaudadoras.value = res.data.eResponse.data.result || []
        if (recaudadoras.value.length > 0) {
          showToast('success', `Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`)
        }
      } else {
        errorLocales.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
        showToast('error', errorLocales.value)
      }
    } catch (err) {
      errorLocales.value = 'Error de conexión al cargar recaudadoras'
      console.error('Error al cargar recaudadoras:', err)
      showToast('error', errorLocales.value)
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

      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_catalogo_mercados',
          Base: 'padron_licencias',
          Parametros: [
            { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
            { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
          ]
        }
      })

      if (res.data.eResponse && res.data.eResponse.success === true) {
        mercados.value = res.data.eResponse.data.result || []
        if (mercados.value.length > 0) {
          showToast('success', `Se cargaron ${mercados.value.length} mercados`)
        } else {
          showToast('info', 'No se encontraron mercados para esta oficina')
        }
      } else {
        errorLocales.value = res.data.eResponse?.message || 'Error al cargar mercados'
        showToast('error', errorLocales.value)
      }
    } catch (err) {
      errorLocales.value = 'Error de conexión al cargar mercados'
      console.error('Error al cargar mercados:', err)
      showToast('error', errorLocales.value)
    }
  })
}

const cargarSecciones = async () => {
  secciones.value = []
  form.value.seccion = ''

  await withLoading(async () => {
    errorLocales.value = ''
    try {
      const res = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_get_secciones',
          Base: 'padron_licencias',
          Parametros: []
        }
      })
      if (res.data.eResponse && res.data.eResponse.success === true) {
        secciones.value = res.data.eResponse.data.result || []
        if (secciones.value.length > 0) {
          showToast('success', `Se cargaron ${secciones.value.length} secciones`)
        }
      } else {
        errorLocales.value = res.data.eResponse?.message || 'Error al cargar secciones'
        showToast('error', errorLocales.value)
      }
    } catch (error) {
      errorLocales.value = 'Error de conexión al cargar secciones'
      console.error('Error al cargar secciones:', error)
      showToast('error', errorLocales.value)
    }
  })
}

const buscarLocal = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
    errorLocales.value = 'Debe completar todos los campos obligatorios'
    showToast('warning', errorLocales.value)
    return
  }

  await withLoading(async () => {
    errorLocales.value = ''
    locales.value = []
    selectedLocal.value = null
    searchPerformed.value = true
    currentPage.value = 1

    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_general_buscar',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
            { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
            { Nombre: 'p_categoria', Valor: parseInt(form.value.categoria) || 1 },
            { Nombre: 'p_seccion', Valor: form.value.seccion },
            { Nombre: 'p_local', Valor: parseInt(form.value.local) },
            { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
            { Nombre: 'p_bloque', Valor: form.value.bloque || null }
          ]
        }
      })
      if (response.data.eResponse && response.data.eResponse.success === true) {
        locales.value = response.data.eResponse.data.result || []
        if (locales.value.length === 0) {
          showToast('info', 'No se encontraron locales con los criterios especificados')
        } else {
          showToast('success', `Se encontraron ${locales.value.length} locales`)
          showFilters.value = false
        }
      } else {
        errorLocales.value = response.data.eResponse?.message || 'Error en la búsqueda'
        showToast('error', errorLocales.value)
      }
    } catch (error) {
      errorLocales.value = error.response?.data?.eResponse?.message || 'Error al buscar locales'
      console.error('Error al buscar locales:', error)
      showToast('error', errorLocales.value)
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
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (locales.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('info', 'Funcionalidad de exportación en desarrollo')
}

const imprimir = () => {
  if (locales.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  // TODO: Implementar impresión
  showToast('info', 'Funcionalidad de impresión en desarrollo')
}

const verDetalle = async (local) => {
  detalle.value = local
  adeudos.value = []
  pagos.value = []
  requerimientos.value = []
  tab.value = 'adeudos'
  showModal.value = true

  // Cargar datos de los tabs
  await cargarDatosDetalle(local.id_local)
}

const cargarDatosDetalle = async (idLocal) => {
  await withLoading(async () => {
    loadingTab.value = true
    try {
      // Cargar adeudos
      const resAdeudos = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_general_adeudos',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: idLocal }
          ]
        }
      })
      if (resAdeudos.data.eResponse && resAdeudos.data.eResponse.success === true) {
        adeudos.value = resAdeudos.data.eResponse.data.result || []
      }

      // Cargar pagos
      const resPagos = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_general_pagos',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: idLocal }
          ]
        }
      })
      if (resPagos.data.eResponse && resPagos.data.eResponse.success === true) {
        pagos.value = resPagos.data.eResponse.data.result || []
      }

      // Cargar requerimientos
      const resReq = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_general_requerimientos',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: idLocal }
          ]
        }
      })
      if (resReq.data.eResponse && resReq.data.eResponse.success === true) {
        requerimientos.value = resReq.data.eResponse.data.result || []
      }
    } catch (error) {
      showToast('error', 'Error al cargar detalles')
    } finally {
      loadingTab.value = false
    }
  })
}

const cerrarModal = () => {
  showModal.value = false
}
</script>

<style scoped>
/* ==================== TABS PERSONALIZADAS ==================== */
.nav-tabs-custom {
  display: flex;
  gap: 0;
  border-bottom: 2px solid #e9ecef;
  padding: 0;
  list-style: none;
  margin: 0;
}

.nav-tabs-custom .nav-item {
  flex: 1;
}

.nav-link-custom {
  width: 100%;
  background: #f8f9fa;
  border: none;
  border-bottom: 3px solid transparent;
  padding: 1rem 1.5rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  font-size: 0.95rem;
  font-weight: 500;
  color: #6c757d;
  transition: all 0.3s ease;
  position: relative;
}

.nav-link-custom:hover {
  background: #e9ecef;
  color: #495057;
}

.nav-link-custom.active {
  background: white;
  color: #2c3e50;
  font-weight: 600;
  border-bottom-color: currentColor;
}

/* Tab Adeudos */
.tab-adeudos.active {
  color: #dc3545;
  border-bottom-color: #dc3545;
}

.tab-adeudos:hover {
  color: #c82333;
}

/* Tab Pagos */
.tab-pagos.active {
  color: #28a745;
  border-bottom-color: #28a745;
}

.tab-pagos:hover {
  color: #218838;
}

/* Tab Requerimientos */
.tab-requerimientos.active {
  color: #ffc107;
  border-bottom-color: #ffc107;
}

.tab-requerimientos:hover {
  color: #e0a800;
}

/* Iconos de tabs */
.tab-icon {
  font-size: 1.2rem;
}

.tab-label {
  font-size: 0.95rem;
}

/* Badges en tabs */
.tab-badge {
  padding: 0.25rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  color: white;
}

.badge-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.badge-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%);
}

.badge-warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
  color: #212529;
}

/* ==================== CONTENIDO DE TABS ==================== */
.tab-content-custom {
  background: white;
  border: 2px solid #e9ecef;
  border-top: none;
  border-radius: 0 0 8px 8px;
  min-height: 300px;
}

.tab-pane-custom {
  padding: 1.5rem;
}

.fade-in {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ==================== TABLAS PERSONALIZADAS ==================== */
.table-custom {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 0.9rem;
}

.table-custom thead {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
}

.table-custom thead th {
  padding: 0.75rem 1rem;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
  text-transform: uppercase;
  font-size: 0.8rem;
  letter-spacing: 0.5px;
}

.table-custom tbody td {
  padding: 0.9rem 1rem;
  border-bottom: 1px solid #f1f3f5;
  vertical-align: middle;
}

.table-row-hover {
  transition: all 0.2s ease;
}

.table-row-hover:hover {
  background-color: #f8f9fa;
  transform: translateX(4px);
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

/* Estilos específicos por tipo de tabla */
.table-adeudos tbody tr {
  border-left: 3px solid transparent;
}

.table-adeudos tbody tr:hover {
  border-left-color: #dc3545;
}

.table-pagos tbody tr {
  border-left: 3px solid transparent;
}

.table-pagos tbody tr:hover {
  border-left-color: #28a745;
}

.table-requerimientos tbody tr {
  border-left: 3px solid transparent;
}

.table-requerimientos tbody tr:hover {
  border-left-color: #ffc107;
}

/* ==================== BADGES Y ETIQUETAS ==================== */
.badge-year {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
}

.badge-period {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.8rem;
  display: inline-block;
}

.badge-vigencia {
  background: #e3f2fd;
  color: #1976d2;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.8rem;
  display: inline-block;
}

/* ==================== MONTOS ==================== */
.amount-danger {
  color: #dc3545;
  font-weight: 700;
  font-size: 1.05rem;
  font-family: 'Courier New', monospace;
}

.amount-warning {
  color: #ffc107;
  font-weight: 700;
  font-size: 1.05rem;
  font-family: 'Courier New', monospace;
}

.amount-success {
  color: #28a745;
  font-weight: 700;
  font-size: 1.05rem;
  font-family: 'Courier New', monospace;
}

.amount-info {
  color: #17a2b8;
  font-weight: 700;
  font-size: 1.05rem;
  font-family: 'Courier New', monospace;
}

.amount-total {
  color: #2c3e50;
  font-weight: 800;
  font-size: 1.1rem;
  font-family: 'Courier New', monospace;
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  display: inline-block;
}

/* ==================== FOLIOS ==================== */
.folio-badge {
  background: #e3f2fd;
  color: #1565c0;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.8rem;
  font-family: 'Courier New', monospace;
  display: inline-block;
}

.folio-badge-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  font-family: 'Courier New', monospace;
  display: inline-block;
}

/* ==================== ICONOS ==================== */
.icon-small {
  font-size: 0.85rem;
  margin-right: 0.35rem;
}

/* ==================== ESTADOS VACÍOS ==================== */
.empty-state {
  text-align: center;
  padding: 3rem 2rem;
}

.empty-state h5 {
  margin-top: 1.5rem;
  margin-bottom: 0.5rem;
  color: #495057;
  font-weight: 600;
}

.empty-state p {
  color: #6c757d;
  margin-bottom: 0;
}

.empty-icon-success {
  color: #28a745;
  opacity: 0.6;
}

.empty-icon-info {
  color: #17a2b8;
  opacity: 0.6;
}

/* Estados empty originales */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.text-center {
  text-align: center;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

/* Filas de tabla */
.table-row-selected {
  background-color: #fff3cd !important;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

.required {
  color: #dc3545;
}

/* Override para columnas numéricas */
.municipal-table td.text-end,
.municipal-table th.text-end {
  text-align: right;
}

.municipal-table td.text-center,
.municipal-table th.text-center {
  text-align: center;
}
</style>
