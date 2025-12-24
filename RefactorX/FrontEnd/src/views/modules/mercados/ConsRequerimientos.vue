<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Requerimientos</h1>
        <p>Inicio > Consultas > Requerimientos</p>
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
        
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="loading || requerimientos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || requerimientos.length === 0">
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
          <form @submit.prevent="buscarLocales">
            <!-- Filtros en una sola fila -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select v-model="form.oficina" class="municipal-form-control" required @change="cargarMercados" :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                   {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select v-model="form.num_mercado" class="municipal-form-control" required
                  :disabled="!form.oficina || loading">
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select v-model="form.categoria" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select v-model="form.seccion" class="municipal-form-control" required :disabled="loading">
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }}
                  </option>
                </select>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input v-model="form.local" type="number" class="municipal-form-control" required :disabled="loading"
                  placeholder="Número de local">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Letra</label>
                <input v-model="form.letra_local" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" placeholder="A-Z">
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Bloque</label>
                <input v-model="form.bloque" type="text" class="municipal-form-control" maxlength="1"
                  :disabled="loading" placeholder="1-9">
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary me-2" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                  <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                    <font-awesome-icon icon="eraser" />
                    Limpiar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla: Locales Encontrados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Encontrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="locales.length > 0">
              {{ formatNumber(locales.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingLocales" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorLocales" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorLocales }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0 && !searchPerformed">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar locales</p>
                  </td>
                </tr>
                <tr v-else-if="locales.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="l in locales" :key="l.id_local"
                  @click="selectedLocal = l"
                  :class="{ 'table-row-selected': selectedLocal?.id_local === l.id_local }"
                  class="row-hover">
                  <td><strong class="text-primary">{{ l.id_local }}</strong></td>
                  <td>{{ l.oficina }}</td>
                  <td>{{ l.num_mercado }}</td>
                  <td>{{ l.categoria }}</td>
                  <td>{{ l.seccion }}</td>
                  <td><strong>{{ l.local }}</strong></td>
                  <td>{{ l.letra_local }}</td>
                  <td>{{ l.bloque }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="seleccionarLocal(l)">
                      <font-awesome-icon icon="file-alt" />
                      Ver Requerimientos
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tabla: Requerimientos del Local -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="file-invoice" />
            Requerimientos del Local {{ selectedLocal?.id_local }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="requerimientos.length > 0">
              {{ formatNumber(requerimientos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingRequerimientos" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando requerimientos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorRequerimientos" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorRequerimientos }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Fecha Emisión</th>
                  <th>Vigencia</th>
                  <th>Diligencia</th>
                  <th>Practicado</th>
                  <th class="text-end">Importe Global</th>
                  <th class="text-end">Importe Multa</th>
                  <th class="text-end">Importe Recargo</th>
                  <th class="text-end">Importe Gastos</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="requerimientos.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron requerimientos para este local</p>
                  </td>
                </tr>
                <tr v-else v-for="r in paginatedRequerimientos" :key="r.id_control"
                  @click="selectedReq = r"
                  :class="{ 'table-row-selected': selectedReq?.id_control === r.id_control }"
                  class="row-hover">
                  <td><strong class="text-primary">{{ r.folio }}</strong></td>
                  <td>{{ r.fecha_emision }}</td>
                  <td>{{ r.vigencia }}</td>
                  <td>{{ r.diligencia }}</td>
                  <td>{{ r.clave_practicado }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(r.importe_global) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(r.importe_multa) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(r.importe_recargo) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-info">{{ formatCurrency(r.importe_gastos) }}</strong>
                  </td>
                  <td class="text-center">
                    <button class="btn-municipal-primary btn-sm" @click.stop="verPeriodos(r)">
                      <font-awesome-icon icon="calendar-alt" />
                      Ver Periodos
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación para requerimientos -->
          <div v-if="requerimientos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPageReq - 1) * itemsPerPageReq) + 1 }}
                a {{ Math.min(currentPageReq * itemsPerPageReq, requerimientos.length) }}
                de {{ requerimientos.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPageReq"
                @change="changePageSizeReq($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPageReq(1)"
                :disabled="currentPageReq === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPageReq(currentPageReq - 1)"
                :disabled="currentPageReq === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePagesReq"
                :key="page"
                class="btn-sm"
                :class="page === currentPageReq ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPageReq(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPageReq(currentPageReq + 1)"
                :disabled="currentPageReq === totalPagesReq"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPageReq(totalPagesReq)"
                :disabled="currentPageReq === totalPagesReq"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla: Periodos del Requerimiento -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="calendar-check" />
            Periodos del Requerimiento - Folio: {{ selectedReq?.folio }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="periodos.length > 0">
              {{ formatNumber(periodos.length) }} periodos
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading && loadingPeriodos" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando periodos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="errorPeriodos" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorPeriodos }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="periodos.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron periodos para este requerimiento</p>
                  </td>
                </tr>
                <tr v-else v-for="(p, idx) in paginatedPeriodos" :key="idx" class="row-hover">
                  <td><strong>{{ p.axo }}</strong></td>
                  <td>{{ p.periodo }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(p.importe) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(p.recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-primary">{{ formatCurrency(parseFloat(p.importe || 0) + parseFloat(p.recargos || 0)) }}</strong>
                  </td>
                </tr>
                <tr v-if="periodos.length > 0" class="table-footer-total">
                  <td colspan="2"><strong>TOTAL</strong></td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(totalPeriodos.importe) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-warning">{{ formatCurrency(totalPeriodos.recargos) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-primary">{{ formatCurrency(totalPeriodos.total) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación para periodos -->
          <div v-if="periodos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPagePer - 1) * itemsPerPagePer) + 1 }}
                a {{ Math.min(currentPagePer * itemsPerPagePer, periodos.length) }}
                de {{ periodos.length }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPagePer"
                @change="changePageSizePer($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPagePer(1)"
                :disabled="currentPagePer === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPagePer(currentPagePer - 1)"
                :disabled="currentPagePer === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePagesPer"
                :key="page"
                class="btn-sm"
                :class="page === currentPagePer ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPagePer(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPagePer(currentPagePer + 1)"
                :disabled="currentPagePer === totalPagesPer"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPagePer(totalPagesPer)"
                :disabled="currentPagePer === totalPagesPer"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'ConsRequerimientos'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ConsRequerimientos'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ConsRequerimientos'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ConsRequerimientos'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const loading = ref(false)
const loadingLocales = ref(false)
const loadingRequerimientos = ref(false)
const loadingPeriodos = ref(false)

// Errores
const errorLocales = ref('')
const errorRequerimientos = ref('')
const errorPeriodos = ref('')

// Estado de búsqueda
const searchPerformed = ref(false)

// Catálogos
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const categorias = ref([])

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
const requerimientos = ref([])
const periodos = ref([])
const selectedLocal = ref(null)
const selectedReq = ref(null)

// Paginación para requerimientos
const currentPageReq = ref(1)
const itemsPerPageReq = ref(10)

// Paginación para periodos
const currentPagePer = ref(1)
const itemsPerPagePer = ref(10)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos de UI
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ingrese los datos del local para buscar sus requerimientos. Los campos marcados con (*) son obligatorios.', 'info')
}

const showToast = (message, type) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
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

const totalPeriodos = computed(() => {
  const importe = periodos.value.reduce((sum, p) => sum + parseFloat(p.importe || 0), 0)
  const recargos = periodos.value.reduce((sum, p) => sum + parseFloat(p.recargos || 0), 0)
  return { importe, recargos, total: importe + recargos }
})

// Paginación para requerimientos
const totalPagesReq = computed(() => Math.ceil(requerimientos.value.length / itemsPerPageReq.value))
const paginatedRequerimientos = computed(() => {
  const start = (currentPageReq.value - 1) * itemsPerPageReq.value
  const end = start + itemsPerPageReq.value
  return requerimientos.value.slice(start, end)
})
const visiblePagesReq = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPageReq.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPagesReq.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

// Paginación para periodos
const totalPagesPer = computed(() => Math.ceil(periodos.value.length / itemsPerPagePer.value))
const paginatedPeriodos = computed(() => {
  const start = (currentPagePer.value - 1) * itemsPerPagePer.value
  const end = start + itemsPerPagePer.value
  return periodos.value.slice(start, end)
})
const visiblePagesPer = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPagePer.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPagesPer.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

const goToPageReq = (page) => {
  if (page >= 1 && page <= totalPagesReq.value) {
    currentPageReq.value = page
  }
}

const changePageSizeReq = (newSize) => {
  itemsPerPageReq.value = parseInt(newSize)
  currentPageReq.value = 1
}

const goToPagePer = (page) => {
  if (page >= 1 && page <= totalPagesPer.value) {
    currentPagePer.value = page
  }
}

const changePageSizePer = (newSize) => {
  itemsPerPagePer.value = parseInt(newSize)
  currentPagePer.value = 1
}

// Cargar categorías
const cargarCategorias = async () => {
  try {
    const res = await apiService.execute(
          'sp_categoria_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      categorias.value = res.data.result || []
    }
  } catch (error) {
    console.error('Error al cargar categorías:', error)
  }
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Consulta de Requerimientos', 'Preparando catálogos del sistema...')
  try {
    await cargarRecaudadoras()
    await cargarSecciones()
    await cargarCategorias()
  } finally {
    hideLoading()
  }
})

const cargarRecaudadoras = async () => {
  loading.value = true
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
  } finally {
    loading.value = false
  }
}

const cargarMercados = async () => {
  mercados.value = []
  form.value.num_mercado = ''
  form.value.seccion = ''

  if (!form.value.oficina) return

  loading.value = true
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
  } finally {
    loading.value = false
  }
}

const cargarSecciones = async () => {
  secciones.value = []
  form.value.seccion = ''

  loading.value = true
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
  } finally {
    loading.value = false
  }
}

const buscarLocales = async () => {
  if (!form.value.oficina || !form.value.num_mercado || !form.value.seccion || !form.value.local) {
    errorLocales.value = 'Debe completar todos los campos obligatorios'
    showToast(errorLocales.value, 'warning')
    return
  }

  loading.value = true
  loadingLocales.value = true
  errorLocales.value = ''
  locales.value = []
  requerimientos.value = []
  periodos.value = []
  selectedLocal.value = null
  selectedReq.value = null
  searchPerformed.value = true

  try {
    // Limpiar valores vacíos para enviar null - convertir cualquier string vacío o con solo espacios a null
    const letraLocal = (form.value.letra_local && form.value.letra_local.trim() !== '')
      ? form.value.letra_local.trim()
      : null
    const bloque = (form.value.bloque && form.value.bloque.trim() !== '')
      ? form.value.bloque.trim()
      : null

    const params = [
      { nombre: 'p_oficina', valor: parseInt(form.value.oficina), tipo: 'integer' },
      { nombre: 'p_num_mercado', valor: parseInt(form.value.num_mercado), tipo: 'integer' },
      { nombre: 'p_categoria', valor: 1, tipo: 'integer' },
      { nombre: 'p_seccion', valor: form.value.seccion, tipo: 'string' },
      { nombre: 'p_local', valor: parseInt(form.value.local), tipo: 'integer' },
      { nombre: 'p_letra_local', valor: letraLocal, tipo: 'string' },
      { nombre: 'p_bloque', valor: bloque, tipo: 'string' }
    ]

    const response = await apiService.execute('sp_get_locales_by_mercado', 'mercados', params, '', null, 'publico')

    console.log('Respuesta completa del API:', response.data)

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
    errorLocales.value = error.response?.data?.message || 'Error al buscar locales'
    console.error('Error al buscar locales:', error)
    showToast(errorLocales.value, 'error')
  } finally {
    loading.value = false
    loadingLocales.value = false
  }
}

const seleccionarLocal = async (local) => {
  selectedLocal.value = local
  requerimientos.value = []
  periodos.value = []
  selectedReq.value = null

  loading.value = true
  loadingRequerimientos.value = true
  errorRequerimientos.value = ''

  try {
    const response = await apiService.execute(
          'sp_get_requerimientos_by_local',
          'mercados',
          [
          { nombre: 'p_modulo', valor: 11 },  // 11 = módulo de mercados
          { nombre: 'p_control_otr', valor: local.id_local }
        ],
          '',
          null,
          'publico'
        )
    if (response && response.success === true) {
      requerimientos.value = response.data.result || []
      if (requerimientos.value.length === 0) {
        showToast('No se encontraron requerimientos para este local', 'info')
      } else {
        showToast(`Se encontraron ${requerimientos.value.length} requerimientos`, 'success')
      }
    } else {
      errorRequerimientos.value = response?.message || 'Error al obtener requerimientos'
      showToast(errorRequerimientos.value, 'error')
    }
  } catch (error) {
    errorRequerimientos.value = 'Error de conexión al cargar requerimientos'
    console.error('Error al cargar requerimientos:', error)
    showToast(errorRequerimientos.value, 'error')
  } finally {
    loading.value = false
    loadingRequerimientos.value = false
  }
}

const verPeriodos = async (requerimiento) => {
  selectedReq.value = requerimiento
  periodos.value = []

  loading.value = true
  loadingPeriodos.value = true
  errorPeriodos.value = ''

  try {
    const response = await apiService.execute(
          'sp_get_periodos_by_requerimiento',
          'mercados',
          [
          { nombre: 'p_control_otr', valor: requerimiento.control_otr }
        ],
          '',
          null,
          'publico'
        )
    if (response && response.success === true) {
      periodos.value = response.data.result || []
      if (periodos.value.length === 0) {
        showToast('No se encontraron periodos para este requerimiento', 'info')
      } else {
        showToast(`Se encontraron ${periodos.value.length} periodos`, 'success')
      }
    } else {
      errorPeriodos.value = response?.message || 'Error al obtener periodos'
      showToast(errorPeriodos.value, 'error')
    }
  } catch (error) {
    errorPeriodos.value = 'Error de conexión al cargar periodos'
    console.error('Error al cargar periodos:', error)
    showToast(errorPeriodos.value, 'error')
  } finally {
    loading.value = false
    loadingPeriodos.value = false
  }
}

const limpiarFiltros = () => {
  form.value.oficina = ''
  form.value.num_mercado = ''
  form.value.seccion = ''
  form.value.local = ''
  form.value.letra_local = ''
  form.value.bloque = ''
  mercados.value = []
  locales.value = []
  requerimientos.value = []
  periodos.value = []
  selectedLocal.value = null
  selectedReq.value = null
  errorLocales.value = ''
  errorRequerimientos.value = ''
  errorPeriodos.value = ''
  searchPerformed.value = false
  // Recargar secciones
  cargarSecciones()
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (requerimientos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

const imprimir = () => {
  if (requerimientos.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  // TODO: Implementar impresión
  showToast('Funcionalidad de impresión en desarrollo', 'info')
}
</script>
