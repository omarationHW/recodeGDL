<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ad" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Anuncios</h1>
        <p>Padrón de Licencias - Búsqueda avanzada y consulta de anuncios publicitarios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-success"
          @click="nuevoAnuncio"
        >
          <font-awesome-icon icon="plus-circle" />
          Nuevo Anuncio
        </button>
        <button
          v-if="anuncios.length > 0"
          class="btn-municipal-success"
          @click="exportarExcel"
        >
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button
          v-if="anuncios.length > 0"
          class="btn-municipal-danger"
          @click="exportarPDF"
        >
          <font-awesome-icon icon="file-pdf" />
          PDF
        </button>
        <button
          class="btn-municipal-primary"
          @click="buscarAnuncios"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Estadísticas -->

      <!-- Loading skeleton para estadísticas -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
            <div class="skeleton-percentage"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.vigente" :class="`stat-${stat.vigente}`">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getVigenteIcon(stat.vigente)" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">No. Anuncio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.anuncio"
                placeholder="Número de anuncio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">ID Licencia</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_licencia"
                placeholder="ID de licencia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.propietario"
                placeholder="Nombre del propietario"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ubicación</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.ubicacion"
                placeholder="Calle o lugar"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.colonia"
                placeholder="Nombre de colonia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.zona"
                placeholder="Número de zona"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigente</label>
              <select class="municipal-form-control" v-model="filtros.vigente">
                <option value="">Todos</option>
                <option value="S">Vigente</option>
                <option value="N">No Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">ID Giro</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_giro"
                placeholder="ID de giro"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_hasta"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarAnuncios"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
            >
              <font-awesome-icon icon="eraser" />
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
            Resultados de Búsqueda
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros totales
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Anuncio</th>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>Ubicación</th>
                  <th>Colonia</th>
                  <th>Vigente</th>
                  <th>Fecha Otorg.</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="anuncios.length === 0 && !hasSearched">
                  <td colspan="8">
                    <div class="empty-state">
                      <div class="empty-state-icon">
                        <font-awesome-icon icon="search" size="3x" />
                      </div>
                      <h4>Consulta de Anuncios</h4>
                      <p>Utiliza los filtros de búsqueda para encontrar anuncios publicitarios</p>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="anuncios.length === 0 && hasSearched">
                  <td colspan="8">
                    <div class="empty-state">
                      <div class="empty-state-icon">
                        <font-awesome-icon icon="inbox" size="3x" />
                      </div>
                      <h4>Sin resultados</h4>
                      <p>No se encontraron anuncios con los criterios especificados</p>
                    </div>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="anuncio in anuncios"
                  :key="anuncio.id_anuncio"
                  @click="selectedRow = anuncio"
                  @dblclick="verDetalle(anuncio)"
                  :class="{ 'table-row-selected': selectedRow?.id_anuncio === anuncio.id_anuncio }"
                  class="row-hover"
                >
                  <td><strong class="text-primary">{{ anuncio.anuncio }}</strong></td>
                  <td>
                    <span v-if="anuncio.id_licencia" class="badge badge-purple">
                      <font-awesome-icon icon="file-alt" />
                      {{ anuncio.id_licencia }}
                    </span>
                    <span v-else class="text-muted">
                      <small>Sin licencia</small>
                    </span>
                  </td>
                  <td>{{ anuncio.propietario || 'Sin propietario' }}</td>
                  <td>
                    <small>{{ anuncio.ubicacion || anuncio.espubic || 'Sin ubicación' }}</small>
                  </td>
                  <td>{{ anuncio.colonia_ubic || 'N/A' }}</td>
                  <td>
                    <span
                      :class="{
                        'badge': true,
                        'badge-success': anuncio.vigente === 'S' || anuncio.vigente === 'V',
                        'badge-danger': anuncio.vigente === 'N',
                        'badge-warning': anuncio.vigente === 'C'
                      }"
                    >
                      <font-awesome-icon :icon="getVigenteIcon(anuncio.vigente)" />
                      {{ getVigenteDesc(anuncio.vigente) }}
                    </span>
                  </td>
                  <td>
                    <small>{{ formatDate(anuncio.fecha_otorgamiento) }}</small>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="verDetalle(anuncio)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-wrapper" v-if="totalResultados > itemsPerPage">
            <div class="pagination-controls">
              <button
                class="pagination-btn"
                :disabled="currentPage === 1"
                @click="cambiarPagina(1)"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="pagination-btn"
                :disabled="currentPage === 1"
                @click="cambiarPagina(currentPage - 1)"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <div class="pagination-numbers">
                <button
                  v-for="page in paginasVisibles"
                  :key="page"
                  class="pagination-btn"
                  :class="{ 'active': page === currentPage }"
                  @click="cambiarPagina(page)"
                >
                  {{ page }}
                </button>
              </div>

              <button
                class="pagination-btn"
                :disabled="currentPage === totalPaginas"
                @click="cambiarPagina(currentPage + 1)"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="pagination-btn"
                :disabled="currentPage === totalPaginas"
                @click="cambiarPagina(totalPaginas)"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>

            <div class="pagination-info">
              Página {{ currentPage }} de {{ totalPaginas }} ({{ formatNumber(totalResultados) }} registros)
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'consultaAnunciofrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Consulta de Anuncios'"
        @close="showDocModal = false"
      />
    </div>

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetalleModal"
      @close="showDetalleModal = false"
      size="xl"
      title="Detalle del Anuncio"
      :showDefaultFooter="false"
    >
      <div v-if="anuncioSeleccionado" class="tramite-details">
        <div class="details-grid">
          <!-- Información General -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Anuncio:</td>
                <td><strong class="text-primary">{{ anuncioSeleccionado.id_anuncio }}</strong></td>
              </tr>
              <tr>
                <td class="label">No. Anuncio:</td>
                <td><strong>{{ anuncioSeleccionado.anuncio }}</strong></td>
              </tr>
              <tr>
                <td class="label">ID Licencia:</td>
                <td>
                  <span v-if="anuncioSeleccionado.id_licencia" class="badge badge-purple">
                    <font-awesome-icon icon="file-alt" />
                    {{ anuncioSeleccionado.id_licencia }}
                  </span>
                  <span v-else class="text-muted">Sin licencia</span>
                </td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>{{ anuncioSeleccionado.giro_desc || 'Sin giro' }}</td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span
                    :class="{
                      'badge': true,
                      'badge-success': anuncioSeleccionado.vigente === 'S' || anuncioSeleccionado.vigente === 'V',
                      'badge-danger': anuncioSeleccionado.vigente === 'N',
                      'badge-warning': anuncioSeleccionado.vigente === 'C'
                    }"
                  >
                    <font-awesome-icon :icon="getVigenteIcon(anuncioSeleccionado.vigente)" />
                    {{ getVigenteDesc(anuncioSeleccionado.vigente) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Bloqueado:</td>
                <td>
                  <span :class="anuncioSeleccionado.bloqueado ? 'text-danger' : 'text-success'">
                    {{ anuncioSeleccionado.bloqueado ? 'Sí' : 'No' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>

          <!-- Datos del Propietario -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ anuncioSeleccionado.propietario || 'Sin propietario' }}</td>
              </tr>
              <tr>
                <td class="label">Licencia No.:</td>
                <td>{{ anuncioSeleccionado.licencia || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Ubicación -->
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Ubicación:</td>
              <td>{{ anuncioSeleccionado.espubic || anuncioSeleccionado.ubicacion || 'Sin ubicación' }}</td>
            </tr>
            <tr>
              <td class="label">Colonia:</td>
              <td>{{ anuncioSeleccionado.colonia_ubic || 'N/A' }}</td>
            </tr>
            <tr>
              <td class="label">No. Exterior:</td>
              <td>{{ anuncioSeleccionado.numext_ubic || 'N/A' }} {{ anuncioSeleccionado.letraext_ubic || '' }}</td>
            </tr>
            <tr>
              <td class="label">No. Interior:</td>
              <td>{{ anuncioSeleccionado.numint_ubic || 'N/A' }} {{ anuncioSeleccionado.letraint_ubic || '' }}</td>
            </tr>
            <tr>
              <td class="label">Zona / Subzona:</td>
              <td>{{ anuncioSeleccionado.zona || 'N/A' }} / {{ anuncioSeleccionado.subzona || 'N/A' }}</td>
            </tr>
            <tr>
              <td class="label">CP:</td>
              <td>{{ anuncioSeleccionado.cp || 'N/A' }}</td>
            </tr>
          </table>
        </div>

        <!-- Características -->
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="ad" />
            Características del Anuncio
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Texto:</td>
              <td>{{ anuncioSeleccionado.texto_anuncio || 'Sin texto' }}</td>
            </tr>
            <tr>
              <td class="label">Área:</td>
              <td>{{ anuncioSeleccionado.area_anuncio || '0' }} m²</td>
            </tr>
            <tr>
              <td class="label">Medidas:</td>
              <td>{{ anuncioSeleccionado.medidas1 || '0' }} x {{ anuncioSeleccionado.medidas2 || '0' }}</td>
            </tr>
            <tr>
              <td class="label">Número de caras:</td>
              <td>{{ anuncioSeleccionado.num_caras || '0' }}</td>
            </tr>
            <tr>
              <td class="label">Base impuesto:</td>
              <td><strong class="text-success">${{ anuncioSeleccionado.base_impuesto || '0' }}</strong></td>
            </tr>
            <tr>
              <td class="label">Misma forma:</td>
              <td>{{ anuncioSeleccionado.misma_forma === 'S' ? 'Sí' : 'No' }}</td>
            </tr>
            <tr>
              <td class="label">Asiento:</td>
              <td>{{ anuncioSeleccionado.asiento || 'N/A' }}</td>
            </tr>
          </table>
        </div>

        <!-- Fechas -->
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="calendar-alt" />
            Fechas
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Fecha otorgamiento:</td>
              <td>
                <font-awesome-icon icon="calendar-plus" class="text-success" />
                {{ formatDate(anuncioSeleccionado.fecha_otorgamiento) }}
              </td>
            </tr>
            <tr>
              <td class="label">Fecha baja:</td>
              <td>
                <font-awesome-icon icon="calendar-times" class="text-danger" />
                {{ formatDate(anuncioSeleccionado.fecha_baja) }}
              </td>
            </tr>
            <tr>
              <td class="label">Año baja:</td>
              <td>{{ anuncioSeleccionado.axo_baja || 'N/A' }}</td>
            </tr>
            <tr>
              <td class="label">Folio baja:</td>
              <td>{{ anuncioSeleccionado.folio_baja || 'N/A' }}</td>
            </tr>
          </table>
        </div>

        <!-- Acciones -->
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showDetalleModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button
            v-if="anuncioSeleccionado.id_licencia"
            class="btn-municipal-success"
            @click="verLicencia(anuncioSeleccionado.id_licencia)"
          >
            <font-awesome-icon icon="file-alt" />
            Ver Licencia
          </button>
          <button
            v-if="anuncioSeleccionado.vigente === 'S' || anuncioSeleccionado.vigente === 'V'"
            class="btn-municipal-primary"
            @click="modificarAnuncio(anuncioSeleccionado); showDetalleModal = false"
          >
            <font-awesome-icon icon="edit" />
            Modificar Anuncio
          </button>
        </div>
      </div>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useExcelExport } from '@/composables/useExcelExport'
import { usePdfExport } from '@/composables/usePdfExport'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { exportToExcel } = useExcelExport()
const { exportToPdf } = usePdfExport()

// Definición de columnas para exportación
const columnasExport = [
  { header: 'Anuncio', key: 'anuncio', width: 12 },
  { header: 'Licencia', key: 'id_licencia', width: 12 },
  { header: 'Propietario', key: 'propietario', width: 35 },
  { header: 'Tipo Anuncio', key: 'tipo_anuncio', width: 25 },
  { header: 'Medidas', key: 'medidas', width: 15 },
  { header: 'Área m²', key: 'area', type: 'number', width: 12 },
  { header: 'Caras', key: 'num_caras', type: 'integer', width: 8 },
  { header: 'Ubicación', key: 'ubicacion', width: 35 },
  { header: 'Colonia', key: 'colonia', width: 25 },
  { header: 'Zona', key: 'zona', width: 10 },
  { header: 'Fecha Otorg.', key: 'fecha_otorgamiento', type: 'date', width: 15 },
  { header: 'Estado', key: 'vigente_texto', width: 12 }
]

// Estado
const showFilters = ref(false)
const anuncios = ref([])
const estadisticas = ref([])
const totalResultados = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const primeraBusqueda = ref(false)
const showDetalleModal = ref(false)
const anuncioSeleccionado = ref({})
const loadingEstadisticas = ref(true)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const filtros = ref({
  anuncio: '',
  id_licencia: '',
  propietario: '',
  ubicacion: '',
  colonia: '',
  zona: '',
  vigente: '',
  fecha_desde: '',
  fecha_hasta: '',
  id_giro: ''
})

// Computadas
const totalPaginas = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

const paginasVisibles = computed(() => {
  const total = totalPaginas.value
  const current = currentPage.value
  const delta = 2
  const range = []
  const rangeWithDots = []

  for (let i = Math.max(2, current - delta); i <= Math.min(total - 1, current + delta); i++) {
    range.push(i)
  }

  if (current - delta > 2) {
    rangeWithDots.push(1, '...')
  } else {
    rangeWithDots.push(1)
  }

  rangeWithDots.push(...range)

  if (current + delta < total - 1) {
    rangeWithDots.push('...', total)
  } else if (total > 1) {
    rangeWithDots.push(total)
  }

  return rangeWithDots.filter(p => p !== '...' || range.length > 0)
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const establecerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  filtros.value.fecha_hasta = hoy.toISOString().split('T')[0]
  filtros.value.fecha_desde = seisMesesAtras.toISOString().split('T')[0]
}

const limpiarFiltros = () => {
  filtros.value = {
    anuncio: '',
    id_licencia: '',
    propietario: '',
    ubicacion: '',
    colonia: '',
    zona: '',
    vigente: '',
    fecha_desde: '',
    fecha_hasta: '',
    id_giro: ''
  }
  anuncios.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
  establecerFechasPorDefecto()
}

const buscarAnuncios = async () => {
  // Limpiar localStorage antes de nueva búsqueda
  localStorage.removeItem('anuncios_consulta')

  showLoading('Buscando anuncios...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null
  primeraBusqueda.value = true
  showFilters.value = false  // Contraer acordeón al buscar

  const startTime = performance.now()

  try {
    const params = [
      {
        nombre: 'p_id_anuncio',
        valor: filtros.value.anuncio || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_anuncio',
        valor: filtros.value.anuncio || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_id_licencia',
        valor: filtros.value.id_licencia || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_propietario',
        valor: filtros.value.propietario || null,
        tipo: 'string'
      },
      {
        nombre: 'p_ubicacion',
        valor: filtros.value.ubicacion || null,
        tipo: 'string'
      },
      {
        nombre: 'p_colonia',
        valor: filtros.value.colonia || null,
        tipo: 'string'
      },
      {
        nombre: 'p_zona',
        valor: filtros.value.zona || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_vigente',
        valor: filtros.value.vigente || null,
        tipo: 'string'
      },
      {
        nombre: 'p_fecha_desde',
        valor: filtros.value.fecha_desde || null,
        tipo: 'date'
      },
      {
        nombre: 'p_fecha_hasta',
        valor: filtros.value.fecha_hasta || null,
        tipo: 'date'
      },
      {
        nombre: 'p_id_giro',
        valor: filtros.value.id_giro || null,
        tipo: 'integer'
      },
      {
        nombre: 'p_page',
        valor: currentPage.value,
        tipo: 'integer'
      },
      {
        nombre: 'p_limit',
        valor: itemsPerPage.value,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'consulta_anuncios_list',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    hideLoading()

    if (response && response.result) {
      anuncios.value = response.result
      if (anuncios.value.length > 0) {
        totalResultados.value = parseInt(anuncios.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }

      // Guardar resultados en localStorage
      localStorage.setItem('anuncios_consulta', JSON.stringify(anuncios.value))

      // Formatear el mensaje con el tiempo
      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast(
        'success',
        `Consulta exitosa: ${formatNumber(totalResultados.value)} anuncios encontrados`,
        timeMessage
      )
    } else {
      anuncios.value = []
      totalResultados.value = 0
      showToast('info', 'No se encontraron anuncios con los criterios especificados')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const cargarEstadisticas = async () => {
  try {
    const response = await execute(
      'consulta_anuncios_estadisticas',
      'padron_licencias',
      [],
      'padron_licencias',
      null,
      'publico'
    )

    if (response && response.result) {
      estadisticas.value = response.result
    }
  } catch (error) {
  } finally {
    loadingEstadisticas.value = false
  }
}

const cambiarPagina = (pagina) => {
  if (pagina !== '...' && pagina >= 1 && pagina <= totalPaginas.value) {
    currentPage.value = pagina
    selectedRow.value = null
    buscarAnuncios()
  }
}

const verDetalle = (anuncio) => {
  anuncioSeleccionado.value = anuncio
  showDetalleModal.value = true
}

const verLicencia = (idLicencia) => {
  router.push({
    path: '/padron-licencias/consulta-licencias',
    query: { id_licencia: idLicencia }
  })
}

const nuevoAnuncio = () => {
  router.push('/padron-licencias/registro-solicitud')
}

const modificarAnuncio = (anuncio) => {
  const numeroAnuncio = anuncio?.anuncio || anuncio
  // Guardar el NÚMERO de anuncio en sessionStorage para pasarlo de forma segura
  sessionStorage.setItem('anuncio_a_modificar', numeroAnuncio.toString())
  // Navegar sin exponer el número en la URL
  router.push('/padron-licencias/modificacion-licencias')
}

const exportarExcel = async () => {
  if (anuncios.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  showLoading('Exportando a Excel...', 'Generando archivo')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con texto de vigencia
    const datosExport = anuncios.value.map(anun => ({
      ...anun,
      vigente_texto: anun.vigente === 'S' || anun.vigente === 'V' ? 'Vigente' :
                     anun.vigente === 'B' ? 'Baja' :
                     anun.vigente === 'C' ? 'Cancelado' : 'Desconocido',
      medidas: `${anun.medidas1 || 0} x ${anun.medidas2 || 0}`
    }))

    const success = exportToExcel(datosExport, columnasExport, 'Consulta_Anuncios')

    if (success) {
      showToast('success', `Excel generado con ${anuncios.value.length} anuncios`)
    } else {
      showToast('error', 'Error al generar Excel')
    }
  } catch (error) {
    showToast('error', 'Error al generar Excel')
  } finally {
    hideLoading()
  }
}

const exportarPDF = async () => {
  if (anuncios.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  showLoading('Exportando a PDF...', 'Generando documento')

  try {
    await new Promise(resolve => setTimeout(resolve, 100))

    // Preparar datos con texto de vigencia
    const datosExport = anuncios.value.map(anun => ({
      ...anun,
      vigente_texto: anun.vigente === 'S' || anun.vigente === 'V' ? 'Vigente' :
                     anun.vigente === 'B' ? 'Baja' :
                     anun.vigente === 'C' ? 'Cancelado' : 'Desconocido',
      medidas: `${anun.medidas1 || 0} x ${anun.medidas2 || 0}`
    }))

    const success = exportToPdf(datosExport, columnasExport, {
      title: 'Consulta de Anuncios',
      subtitle: `Generado el ${new Date().toLocaleDateString('es-MX')}`,
      orientation: 'landscape'
    })

    if (success) {
      showToast('success', 'PDF generado correctamente')
    } else {
      showToast('error', 'Error al generar PDF')
    }
  } catch (error) {
    showToast('error', 'Error al generar PDF')
  } finally {
    hideLoading()
  }
}

// Utilidades
const getVigenteIcon = (vigente) => {
  const icons = {
    'S': 'check-circle',
    'V': 'check-circle',
    'N': 'times-circle',
    'C': 'ban'
  }
  return icons[vigente] || 'question-circle'
}

const getVigenteDesc = (vigente) => {
  const desc = {
    'S': 'Vigente',
    'V': 'Vigente',
    'N': 'No Vigente',
    'C': 'Cancelado'
  }
  return desc[vigente] || vigente
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Lifecycle
onMounted(() => {
  establecerFechasPorDefecto()
  cargarEstadisticas()

  // Cargar resultados guardados desde localStorage si existen
  const anunciosGuardados = localStorage.getItem('anuncios_consulta')
  if (anunciosGuardados) {
    try {
      anuncios.value = JSON.parse(anunciosGuardados)
      if (anuncios.value.length > 0) {
        totalResultados.value = parseInt(anuncios.value[0].total_records) || anuncios.value.length
        primeraBusqueda.value = true
      }
    } catch (error) {
      localStorage.removeItem('anuncios_consulta')
    }
  }
})
</script>
