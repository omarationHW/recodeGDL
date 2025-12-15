<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-certificate" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Certificaciones</h1>
        <p>Padrón de Licencias - Administración de certificaciones oficiales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo">
          <font-awesome-icon icon="plus" />
          Nueva Certificación
        </button>
        <button class="btn-municipal-primary" @click="cargarCertificaciones">
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
      <!-- Stats grid -->
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

      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="`${stat.categoria}-${stat.descripcion}`" :class="`stat-${getCategoryClass(stat.categoria, stat.descripcion)}`">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getStatIcon(stat.categoria, stat.descripcion)" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.axo"
                placeholder="Año"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.folio"
                placeholder="Folio"
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
              <label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="filtros.tipo">
                <option value="">Todos</option>
                <option value="L">Licencia</option>
                <option value="A">Anuncio</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigente</label>
              <select class="municipal-form-control" v-model="filtros.vigente">
                <option value="">Todos</option>
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                Fecha Desde
                <small class="text-muted" style="font-weight: normal; margin-left: 0.5rem;">(últimos 6 meses)</small>
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                Fecha Hasta
                <small class="text-muted" style="font-weight: normal; margin-left: 0.5rem;">(hoy)</small>
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_hasta"
              />
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarCertificaciones">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="times" />
              Limpiar Filtros
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Certificaciones Registradas
            </h5>
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros totales
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table" style="min-width: 1200px;">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 70px;">Año</th>
                  <th style="width: 80px;">Folio</th>
                  <th style="width: 100px;">Tipo</th>
                  <th style="width: 120px;">Licencia</th>
                  <th style="width: 120px;">Partida Pago</th>
                  <th style="width: 280px;">Observación</th>
                  <th style="width: 90px;">Vigente</th>
                  <th style="width: 110px;">Fecha</th>
                  <th style="width: 150px;" class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="certificaciones.length === 0 && !primeraBusqueda">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros para buscar certificaciones o crea una nueva</p>
                  </td>
                </tr>
                <tr v-else-if="certificaciones.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron certificaciones con los filtros especificados</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="cert in certificaciones"
                  :key="`${cert.axo}-${cert.folio}`"
                  @click="certificacionSeleccionada = cert"
                  style="cursor: pointer;"
                >
                  <td>
                    <div class="folio-display">
                      <span class="folio-year">{{ cert.axo }}</span>
                    </div>
                  </td>
                  <td>
                    <div class="folio-display">
                      <span class="folio-number">#{{ cert.folio }}</span>
                    </div>
                  </td>
                  <td>
                    <span class="badge" :class="cert.tipo === 'L' ? 'badge-primary' : 'badge-warning'">
                      <font-awesome-icon :icon="cert.tipo === 'L' ? 'file-contract' : 'bullhorn'" />
                      {{ cert.tipo === 'L' ? 'Licencia' : 'Anuncio' }}
                    </span>
                  </td>
                  <td>
                    <div class="licencia-badge-container">
                      <span v-if="cert.id_licencia" class="badge badge-purple licencia-badge">
                        <font-awesome-icon icon="file-contract" />
                        Lic. {{ cert.id_licencia }}
                      </span>
                      <span v-else class="badge badge-secondary licencia-badge">
                        <font-awesome-icon icon="times-circle" />
                        Sin licencia
                      </span>
                    </div>
                  </td>
                  <td>{{ cert.partidapago }}</td>
                  <td>
                    <div class="text-truncate" :title="cert.observacion">
                      {{ cert.observacion || 'N/A' }}
                    </div>
                  </td>
                  <td>
                    <span class="badge" :class="cert.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                      {{ cert.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                    </span>
                  </td>
                  <td>{{ formatDate(cert.feccap) }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="verDetalle(cert)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="editarCertificacion(cert)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="cert.vigente === 'V'"
                        class="btn-municipal-danger btn-sm"
                        @click.stop="eliminarCertificacion(cert)"
                        title="Cancelar"
                      >
                        <font-awesome-icon icon="ban" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-controls" v-if="totalResultados > itemsPerPage">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
                de {{ totalResultados }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                v-model="itemsPerPage"
                @change="changePageSize"
                style="width: auto; display: inline-block;"
              >
                <option :value="10">10</option>
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="cambiarPagina(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="cambiarPagina(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="cambiarPagina(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="cambiarPagina(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="cambiarPagina(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ver Detalle -->
    <Modal
      :show="modalDetalleVisible"
      @close="modalDetalleVisible = false"
      size="xl"
      class="modal-certificacion-detalle"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="file-certificate" class="me-2" />
          Detalle de Certificación
        </h5>
      </template>
      <div v-if="certificacionSeleccionada" class="detail-grid">
        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="info-circle" class="me-2" />
            Información General
          </h6>
          <div class="detail-row">
            <span class="detail-label">Año:</span>
            <span class="detail-value">{{ certificacionSeleccionada.axo }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Folio:</span>
            <span class="detail-value">{{ certificacionSeleccionada.folio }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Tipo:</span>
            <span class="detail-value">
              <span class="badge" :class="certificacionSeleccionada.tipo === 'L' ? 'badge-primary' : 'badge-warning'">
                {{ certificacionSeleccionada.tipo === 'L' ? 'Licencia' : 'Anuncio' }}
              </span>
            </span>
          </div>
          <div class="detail-row">
            <span class="detail-label">ID Licencia:</span>
            <span class="detail-value">{{ certificacionSeleccionada.id_licencia || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Licencia:</span>
            <span class="detail-value">{{ certificacionSeleccionada.licencia || 'N/A' }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Propietario:</span>
            <span class="detail-value">{{ certificacionSeleccionada.propietario || 'N/A' }}</span>
          </div>
        </div>

        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="file-alt" class="me-2" />
            Datos de la Certificación
          </h6>
          <div class="detail-row">
            <span class="detail-label">Partida Pago:</span>
            <span class="detail-value">{{ certificacionSeleccionada.partidapago }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Observación:</span>
            <span class="detail-value">{{ certificacionSeleccionada.observacion }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Vigencia:</span>
            <span class="detail-value">
              <span class="badge" :class="certificacionSeleccionada.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                {{ certificacionSeleccionada.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
              </span>
            </span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Fecha Captura:</span>
            <span class="detail-value">{{ formatDate(certificacionSeleccionada.feccap) }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Capturista:</span>
            <span class="detail-value">{{ certificacionSeleccionada.capturista }}</span>
          </div>
        </div>
      </div>

      <template #footer>
        <button class="btn-municipal-secondary" @click="modalDetalleVisible = false">
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal Crear/Editar -->
    <Modal
      :show="modalFormVisible"
      @close="cerrarModalForm"
      size="xl"
      class="modal-certificacion-form"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="file-certificate" class="me-2" />
          {{ modoEdicion ? 'Editar Certificación' : 'Nueva Certificación' }}
        </h5>
      </template>
      <form @submit.prevent="modoEdicion ? actualizarCertificacion() : crearCertificacion()">
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="file-alt" class="me-2" />
            Datos de la Certificación
          </h6>
          <div class="form-row">
            <div class="form-group col-4">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.axo"
                placeholder="2025"
                required
                min="2000"
                :max="new Date().getFullYear()"
                :disabled="modoEdicion"
              />
            </div>

            <div class="form-group col-4">
              <label class="municipal-form-label">Folio <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.folio"
                placeholder="Folio"
                required
                :disabled="modoEdicion"
              />
            </div>

            <div class="form-group col-4">
              <label class="municipal-form-label">Tipo <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="formData.tipo" required>
                <option value="">Seleccione...</option>
                <option value="L">Licencia</option>
                <option value="A">Anuncio</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">ID Licencia <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.id_licencia"
                placeholder="ID de la licencia"
                required
              />
            </div>

            <div class="form-group col-6">
              <label class="municipal-form-label">Partida Pago</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.partidapago"
                placeholder="Número de partida de pago"
                maxlength="25"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-12">
              <label class="municipal-form-label">Observación</label>
              <textarea
                class="municipal-form-control"
                v-model="formData.observacion"
                placeholder="Observaciones adicionales"
                rows="3"
                maxlength="200"
              ></textarea>
            </div>
          </div>
        </div>
      </form>

      <template #footer>
        <button class="btn-municipal-secondary" @click="cerrarModalForm" type="button">
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="modoEdicion ? actualizarCertificacion() : crearCertificacion()"
          type="button"
        >
          <font-awesome-icon :icon="modoEdicion ? 'save' : 'plus'" />
          {{ modoEdicion ? 'Guardar Cambios' : 'Crear Certificación' }}
        </button>
      </template>
    </Modal>

    <!-- Toast -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const certificaciones = ref([])
const certificacionSeleccionada = ref(null)
const estadisticas = ref([])
const loadingEstadisticas = ref(false)
const showFilters = ref(false)
const primeraBusqueda = ref(false)

// Modales
const modalDetalleVisible = ref(false)
const modalFormVisible = ref(false)
const modoEdicion = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalResultados = ref(0)

// Obtener fechas por defecto (últimos 6 meses)
const obtenerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  return {
    fecha_desde: seisMesesAtras.toISOString().split('T')[0],
    fecha_hasta: hoy.toISOString().split('T')[0]
  }
}

const fechasDefault = obtenerFechasPorDefecto()

// Filtros
const filtros = ref({
  axo: null,
  folio: null,
  id_licencia: null,
  tipo: '',
  vigente: '',
  fecha_desde: fechasDefault.fecha_desde,
  fecha_hasta: fechasDefault.fecha_hasta
})

// Formulario
const formData = ref({
  axo: new Date().getFullYear(),
  folio: null,
  id_licencia: null,
  partidapago: '',
  observacion: '',
  tipo: ''
})

// Computed
const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const cargarCertificaciones = async () => {
  showLoading('Cargando certificaciones...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false

  try {
    const params = [
      { nombre: 'p_axo', valor: filtros.value.axo || null, tipo: 'integer' },
      { nombre: 'p_folio', valor: filtros.value.folio || null, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: filtros.value.id_licencia || null, tipo: 'integer' },
      { nombre: 'p_tipo', valor: filtros.value.tipo || null, tipo: 'string' },
      { nombre: 'p_vigente', valor: filtros.value.vigente || null, tipo: 'string' },
      { nombre: 'p_fecha_desde', valor: filtros.value.fecha_desde || null, tipo: 'date' },
      { nombre: 'p_fecha_hasta', valor: filtros.value.fecha_hasta || null, tipo: 'date' },
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
    ]

    const response = await execute(
      'certificaciones_list',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result) {
      certificaciones.value = response.result
      if (certificaciones.value.length > 0) {
        totalResultados.value = parseInt(certificaciones.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const buscarCertificaciones = () => {
  currentPage.value = 1
  showFilters.value = false
  cargarCertificaciones()
}

const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(
      'certificaciones_estadisticas',
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

const limpiarFiltros = () => {
  const fechasDefault = obtenerFechasPorDefecto()
  filtros.value = {
    axo: null,
    folio: null,
    id_licencia: null,
    tipo: '',
    vigente: '',
    fecha_desde: fechasDefault.fecha_desde,
    fecha_hasta: fechasDefault.fecha_hasta
  }
  certificaciones.value = []
  primeraBusqueda.value = false
  totalResultados.value = 0
}

const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value && page !== currentPage.value) {
    currentPage.value = page
    cargarCertificaciones()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  cargarCertificaciones()
}

const verDetalle = (cert) => {
  certificacionSeleccionada.value = cert
  modalDetalleVisible.value = true
}

const abrirModalNuevo = async () => {
  modoEdicion.value = false
  formData.value = {
    axo: new Date().getFullYear(),
    folio: null,
    id_licencia: null,
    partidapago: '',
    observacion: '',
    tipo: ''
  }

  // Abrir modal inmediatamente
  modalFormVisible.value = true

  // Cargar folio en segundo plano
  try {
    const response = await execute(
      'certificaciones_get_next_folio',
      'padron_licencias',
      [{ nombre: 'p_axo', valor: new Date().getFullYear(), tipo: 'integer' }],
      'padron_licencias',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      formData.value.folio = response.result[0].next_folio
    }
  } catch (error) {
    showError('No se pudo obtener el siguiente folio. Por favor, ingréselo manualmente.')
  }
}

const editarCertificacion = (cert) => {
  modoEdicion.value = true
  formData.value = {
    axo: cert.axo,
    folio: cert.folio,
    id_licencia: cert.id_licencia,
    partidapago: cert.partidapago,
    observacion: cert.observacion,
    tipo: cert.tipo
  }
  modalFormVisible.value = true
}

const crearCertificacion = async () => {
  const errores = []

  if (!formData.value.axo) errores.push('• Año es requerido')
  if (!formData.value.folio) errores.push('• Folio es requerido')
  if (!formData.value.id_licencia) errores.push('• ID de Licencia es requerido')
  if (!formData.value.tipo) errores.push('• Tipo es requerido')

  if (errores.length > 0) {
    await Swal.fire({
      title: 'Campos requeridos incompletos',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 1rem; color: #6c757d;">Por favor complete los siguientes campos:</p>
          <ul style="color: #dc3545; font-weight: 500; line-height: 1.8;">
            ${errores.join('<br>')}
          </ul>
        </div>
      `,
      icon: 'warning',
      confirmButtonColor: '#ea8215',
      confirmButtonText: 'Entendido'
    })
    return
  }

  showLoading('Creando certificación...', 'Guardando en base de datos')

  try {
    const params = [
      { nombre: 'p_axo', valor: formData.value.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: formData.value.folio, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: formData.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_partidapago', valor: formData.value.partidapago, tipo: 'string' },
      { nombre: 'p_observacion', valor: formData.value.observacion, tipo: 'string' },
      { nombre: 'p_tipo', valor: formData.value.tipo, tipo: 'string' },
      { nombre: 'p_capturista', valor: 'sistema', tipo: 'string' }
    ]

    const response = await execute(
      'certificaciones_create',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.success) {
        showToast('Certificación creada exitosamente', 'success')
        cerrarModalForm()
        cargarCertificaciones()
        cargarEstadisticas()
      } else {
        showToast(result.message, 'error')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const actualizarCertificacion = async () => {
  const errores = []

  if (!formData.value.axo) errores.push('• Año es requerido')
  if (!formData.value.folio) errores.push('• Folio es requerido')
  if (!formData.value.id_licencia) errores.push('• ID de Licencia es requerido')
  if (!formData.value.tipo) errores.push('• Tipo es requerido')

  if (errores.length > 0) {
    await Swal.fire({
      title: 'Campos requeridos incompletos',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 1rem; color: #6c757d;">Por favor complete los siguientes campos:</p>
          <ul style="color: #dc3545; font-weight: 500; line-height: 1.8;">
            ${errores.join('<br>')}
          </ul>
        </div>
      `,
      icon: 'warning',
      confirmButtonColor: '#ea8215',
      confirmButtonText: 'Entendido'
    })
    return
  }

  showLoading('Actualizando certificación...', 'Guardando cambios')

  try {
    const params = [
      { nombre: 'p_axo', valor: formData.value.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: formData.value.folio, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: formData.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_partidapago', valor: formData.value.partidapago, tipo: 'string' },
      { nombre: 'p_observacion', valor: formData.value.observacion, tipo: 'string' },
      { nombre: 'p_tipo', valor: formData.value.tipo, tipo: 'string' }
    ]

    const response = await execute(
      'certificaciones_update',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.success) {
        showToast('Certificación actualizada exitosamente', 'success')
        cerrarModalForm()
        cargarCertificaciones()
      } else {
        showToast(result.message, 'error')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const eliminarCertificacion = async (cert) => {
  const result = await Swal.fire({
    title: '¿Eliminar certificación?',
    html: `
      <p>¿Está seguro de cancelar la certificación <strong>${cert.axo}-${cert.folio}</strong>?</p>
      <p class="text-muted">Esta acción marcará la certificación como cancelada.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, mantener'
  })

  if (!result.isConfirmed) return

  showLoading('Cancelando certificación...', 'Actualizando estado')

  try {
    const params = [
      { nombre: 'p_axo', valor: cert.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: cert.folio, tipo: 'integer' }
    ]

    const response = await execute(
      'certificaciones_delete',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultData = response.result[0]
      if (resultData.success) {
        showToast('Certificación cancelada exitosamente', 'success')
        cargarCertificaciones()
        cargarEstadisticas()
      } else {
        showToast(resultData.message, 'error')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const cerrarModalForm = () => {
  modalFormVisible.value = false
  formData.value = {
    axo: new Date().getFullYear(),
    folio: null,
    id_licencia: null,
    partidapago: '',
    observacion: '',
    tipo: ''
  }
}

const openDocumentation = () => {
  window.open('/docs/padron_licencias/certificacionesfrm.md', '_blank')
}

// Helpers
const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const getCategoryClass = (categoria, descripcion) => {
  if (categoria === 'Vigencia') {
    if (descripcion.includes('Vigente')) return 'V'
    if (descripcion.includes('Cancelado')) return 'C'
    return 'O'
  }
  if (categoria === 'Tipo') {
    if (descripcion.includes('Licencia')) return 'L'
    if (descripcion.includes('Anuncio')) return 'A'
    return 'O'
  }
  return 'default'
}

const getStatIcon = (categoria, descripcion) => {
  if (categoria === 'Vigencia') {
    if (descripcion.includes('Vigente')) return 'check-circle'
    if (descripcion.includes('Cancelado')) return 'times-circle'
    return 'question-circle'
  }
  if (categoria === 'Tipo') {
    if (descripcion.includes('Licencia')) return 'file-contract'
    if (descripcion.includes('Anuncio')) return 'bullhorn'
    return 'file-alt'
  }
  return 'chart-bar'
}

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
  // NO cargar certificaciones automáticamente
  // El usuario debe hacer clic en "Actualizar" o "Buscar"
})
</script>

<!-- Sin estilos scoped - Usa estilos globales de municipal-theme.css -->
