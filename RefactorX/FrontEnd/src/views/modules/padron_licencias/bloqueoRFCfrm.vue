<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Bloqueo de RFC</h1>
        <p>Bloqueo de RFC por incumplimiento del programa de autoevaluación</p>
      </div>
      <div class="button-group ms-auto">
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
      <!-- Buscar y Crear Nuevo Bloqueo -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="plus-circle" />
            Registrar Nuevo Bloqueo de RFC
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Trámite:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="idTramiteBuscar"
                  placeholder="Ingrese ID del trámite"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">&nbsp;</label>
                <button
                  type="submit"
                  class="btn-municipal-primary w-100"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>
          </form>

          <!-- Información del trámite encontrado -->
          <div v-if="tramiteInfo" class="info-tramite-box">
            <h6 class="mb-3"><strong>Información del Trámite</strong></h6>
            <div class="row">
              <div class="col-md-6">
                <p class="mb-2"><strong>RFC:</strong> {{ tramiteInfo.rfc }}</p>
                <p class="mb-2"><strong>Propietario:</strong> {{ tramiteInfo.propietario_completo }}</p>
              </div>
              <div class="col-md-6">
                <p class="mb-2"><strong>Licencia:</strong> {{ tramiteInfo.id_licencia || 'N/A' }}</p>
                <p class="mb-2"><strong>Actividad:</strong> {{ tramiteInfo.actividad }}</p>
              </div>
            </div>
            <div class="form-row mt-3">
              <div class="form-group">
                <label class="municipal-form-label required">Motivo del Bloqueo:</label>
                <textarea
                  class="municipal-form-control"
                  v-model="nuevoBloqueo.observacion"
                  rows="2"
                  placeholder="Ingrese el motivo del bloqueo del RFC"
                  required
                ></textarea>
                <div class="char-counter">
                  {{ nuevoBloqueo.observacion.length }} caracteres
                </div>
              </div>
            </div>
            <div class="button-group mt-2">
              <button
                type="button"
                class="btn-municipal-danger"
                @click="crearBloqueo"
                :disabled="loading || !nuevoBloqueo.observacion"
              >
                <font-awesome-icon icon="lock" /> Registrar Bloqueo
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
              >
                <font-awesome-icon icon="eraser" /> Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Filtros -->
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
              <label class="municipal-form-label">Buscar por RFC:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.rfc"
                placeholder="RFC..."
                @keyup.enter="buscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia:</label>
              <select class="municipal-form-control" v-model="filtros.vigente">
                <option value="">Todos</option>
                <option value="vigente">Vigentes</option>
                <option value="cancelado">Cancelados</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscar"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Bloqueos RFC -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Bloqueos RFC
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
                  <th>RFC</th>
                  <th>Trámite</th>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>Actividad</th>
                  <th>Vigente</th>
                  <th>Fecha/Hora</th>
                  <th>Capturista</th>
                  <th>Observación</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="bloqueo in bloqueos" :key="`${bloqueo.rfc}-${bloqueo.id_tramite}`" class="clickable-row">
                  <td><strong>{{ bloqueo.rfc }}</strong></td>
                  <td>{{ bloqueo.id_tramite }}</td>
                  <td>{{ bloqueo.licencia || 'N/A' }}</td>
                  <td>{{ bloqueo.propietario_completo }}</td>
                  <td class="small">{{ bloqueo.actividad }}</td>
                  <td>
                    <span class="badge" :class="bloqueo.vig === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ bloqueo.vig === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td class="small">{{ formatDateTime(bloqueo.hora) }}</td>
                  <td>{{ bloqueo.capturista }}</td>
                  <td class="small">{{ bloqueo.observacion }}</td>
                  <td class="text-center">
                    <div class="btn-group">
                      <button
                        class="btn-action btn-info"
                        @click="verDetalle(bloqueo)"
                        :disabled="loading"
                        title="Ver detalle"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        v-if="bloqueo.vig === 'V'"
                        class="btn-action btn-success"
                        @click="confirmarDesbloqueo(bloqueo)"
                        :disabled="loading"
                        title="Desbloquear RFC"
                      >
                        <font-awesome-icon icon="unlock" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="bloqueos.length === 0">
                  <td colspan="10" class="empty-state">
                    <div class="empty-state-content">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p class="empty-state-text">No se encontraron bloqueos de RFC</p>
                      <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda</p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalRecords > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * pageSize) + 1 }}
            a {{ Math.min(currentPage * pageSize, totalRecords) }}
            de {{ totalRecords }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="pageSize" @change="cambiarTamañoPagina">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="cambiarPagina(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === currentPage }"
                @click="cambiarPagina(page)"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="cambiarPagina(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal Detalle Bloqueo RFC -->
  <Modal
    :show="mostrarModalDetalle"
    @close="cerrarModalDetalle"
    size="lg"
  >
    <template #header>
      <h5 class="modal-title">
        <font-awesome-icon icon="eye" class="me-2 text-info" />
        Detalle del Bloqueo - RFC {{ bloqueoSeleccionado?.rfc }}
      </h5>
    </template>

    <div v-if="bloqueoSeleccionado" class="modal-body-detail">
      <!-- Resumen superior con badges -->
      <div class="detail-summary-bar">
        <div class="summary-item">
          <span class="summary-label">RFC</span>
          <span class="badge badge-primary-modern">{{ bloqueoSeleccionado.rfc }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">Trámite</span>
          <span class="badge badge-purple-modern">#{{ bloqueoSeleccionado.id_tramite }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">Estado</span>
          <span class="badge" :class="bloqueoSeleccionado.vig === 'V' ? 'badge-success' : 'badge-secondary'">
            {{ bloqueoSeleccionado.vig === 'V' ? 'Vigente' : 'Cancelado' }}
          </span>
        </div>
      </div>

      <!-- Grid de detalles -->
      <div class="details-grid">
        <!-- Información del Contribuyente -->
        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="user" class="me-2" />
            Información del Contribuyente
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">RFC:</td>
              <td><strong class="text-primary">{{ bloqueoSeleccionado.rfc }}</strong></td>
            </tr>
            <tr>
              <td class="label">Propietario:</td>
              <td>{{ bloqueoSeleccionado.propietario_completo }}</td>
            </tr>
            <tr>
              <td class="label">Licencia:</td>
              <td>{{ bloqueoSeleccionado.licencia || 'N/A' }}</td>
            </tr>
            <tr>
              <td class="label">Actividad:</td>
              <td>{{ bloqueoSeleccionado.actividad }}</td>
            </tr>
          </table>
        </div>

        <!-- Datos del Bloqueo -->
        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="lock" class="me-2" />
            Datos del Bloqueo
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Trámite:</td>
              <td><strong>#{{ bloqueoSeleccionado.id_tramite }}</strong></td>
            </tr>
            <tr>
              <td class="label">Fecha/Hora:</td>
              <td>
                <font-awesome-icon icon="clock" class="me-1 text-muted" />
                {{ formatDateTime(bloqueoSeleccionado.hora) }}
              </td>
            </tr>
            <tr>
              <td class="label">Capturista:</td>
              <td>
                <font-awesome-icon icon="user-circle" class="me-1 text-muted" />
                {{ bloqueoSeleccionado.capturista }}
              </td>
            </tr>
            <tr>
              <td class="label">Vigencia:</td>
              <td>
                <span class="badge" :class="bloqueoSeleccionado.vig === 'V' ? 'badge-success' : 'badge-secondary'">
                  {{ bloqueoSeleccionado.vig === 'V' ? 'Vigente' : 'Cancelado' }}
                </span>
              </td>
            </tr>
          </table>
        </div>
      </div>

      <!-- Sección completa: Observaciones -->
      <div class="detail-section detail-section-full">
        <h6 class="detail-section-title">
          <font-awesome-icon icon="comment-alt" class="me-2" />
          Observaciones
        </h6>
        <div class="detail-observation-box">
          {{ bloqueoSeleccionado.observacion || 'Sin observaciones registradas' }}
        </div>
      </div>
    </div>

    <template #footer>
      <button
        type="button"
        class="btn-municipal-secondary"
        @click="cerrarModalDetalle"
      >
        <font-awesome-icon icon="times" />
        Cerrar
      </button>
      <button
        v-if="bloqueoSeleccionado?.vig === 'V'"
        type="button"
        class="btn-municipal-success"
        @click="confirmarDesbloqueo(bloqueoSeleccionado); cerrarModalDetalle()"
      >
        <font-awesome-icon icon="unlock" />
        Desbloquear RFC
      </button>
    </template>
  </Modal>

  <!-- Modal de Ayuda y Documentación -->
  <DocumentationModal
    :show="showDocModal"
    :componentName="'bloqueoRFCfrm'"
    :moduleName="'padron_licencias'"
    :docType="docType"
    :title="'Bloqueo de RFC'"
    @close="showDocModal = false"
  />
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
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

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const bloqueos = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)
const showFilters = ref(false)
const mostrarModalDetalle = ref(false)
const bloqueoSeleccionado = ref(null)

const idTramiteBuscar = ref(null)
const tramiteInfo = ref(null)

const nuevoBloqueo = ref({
  observacion: ''
})

const filtros = ref({
  rfc: '',
  vigente: 'vigente'
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / pageSize.value)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const cargarBloqueos = async () => {
  showLoading('Cargando bloqueos RFC...')
  showFilters.value = false
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_bloqueorfc_list',
      'licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
        { nombre: 'p_rfc', valor: filtros.value.rfc || null, tipo: 'string' },
        { nombre: 'p_tipo_bloqueo', valor: filtros.value.vigente || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      bloqueos.value = response.result
      if (response.result.length > 0) {
        totalRecords.value = parseInt(response.result[0].total_count)
      } else {
        totalRecords.value = 0
      }

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast(`${formatNumber(totalRecords.value)} bloqueos RFC cargados`, 'success', `${timeMessage}`)
    }
  } catch (error) {
    handleApiError(error, 'No se pudieron cargar los bloqueos de RFC')
  } finally {
    hideLoading()
  }
}

const buscar = () => {
  currentPage.value = 1
  cargarBloqueos()
}

const limpiarFiltros = () => {
  filtros.value = {
    rfc: '',
    vigente: 'vigente'
  }
  currentPage.value = 1
  cargarBloqueos()
}

const buscarTramite = async () => {
  if (!idTramiteBuscar.value) return

  showLoading('Buscando trámite...')
  try {
    const response = await execute(
      'sp_bloqueorfc_buscar_tramite',
      'licencias',
      [{ nombre: 'p_id_tramite', valor: idTramiteBuscar.value, tipo: 'integer' }],
      'guadalajara',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      // Mapear campos del SP al formato esperado por el componente
      tramiteInfo.value = {
        ...result,
        propietario_completo: result.propietario || ''
      }

      if (!tramiteInfo.value.rfc || tramiteInfo.value.rfc.trim() === '') {
        await Swal.fire({
          icon: 'warning',
          title: 'RFC no encontrado',
          text: 'El trámite no tiene RFC registrado',
          confirmButtonColor: '#9363CD'
        })
        tramiteInfo.value = null
      }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#9363CD'
      })
      tramiteInfo.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'No se pudo buscar el trámite')
  }
}

const crearBloqueo = async () => {
  if (!nuevoBloqueo.value.observacion.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Motivo requerido',
      text: 'Debe ingresar el motivo del bloqueo',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear RFC?',
    html: `
      <p>¿Está seguro de bloquear el RFC <strong>${tramiteInfo.value.rfc}</strong>?</p>
      <p><strong>Trámite:</strong> ${idTramiteBuscar.value}</p>
      <p><strong>Propietario:</strong> ${tramiteInfo.value.propietario_completo}</p>
      <p><strong>Motivo:</strong> ${nuevoBloqueo.value.observacion}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Registrando bloqueo...')
  try {
    const response = await execute(
      'sp_bloqueorfc_create',
      'licencias',
      [
        { nombre: 'p_rfc', valor: tramiteInfo.value.rfc, tipo: 'string' },
        { nombre: 'p_id_tramite', valor: idTramiteBuscar.value, tipo: 'integer' },
        { nombre: 'p_licencia', valor: tramiteInfo.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_observacion', valor: nuevoBloqueo.value.observacion, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'public'
    )

    // Primero ocultar el loading
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        // Luego mostrar el mensaje de éxito
        await Swal.fire({
          icon: 'success',
          title: 'Bloqueo Registrado',
          text: resultado.message,
          confirmButtonColor: '#9363CD',
          timer: 2000
        })

        limpiarFormulario()
        // NO recargar automáticamente
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#9363CD'
        })
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'No se pudo registrar el bloqueo')
  }
}

const verDetalle = (bloqueo) => {
  bloqueoSeleccionado.value = { ...bloqueo }
  mostrarModalDetalle.value = true
}

const cerrarModalDetalle = () => {
  mostrarModalDetalle.value = false
  bloqueoSeleccionado.value = null
}

const confirmarDesbloqueo = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Desbloquear RFC',
    html: `
      <p>¿Está seguro de desbloquear el RFC <strong>${bloqueo.rfc}</strong>?</p>
      <p><strong>Propietario:</strong> ${bloqueo.propietario_completo}</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo del desbloqueo..." rows="3"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, desbloquear',
    cancelButtonText: 'Cancelar',
    preConfirm: () => {
      const motivo = document.getElementById('swal-motivo').value
      if (!motivo || !motivo.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo del desbloqueo')
      }
      return motivo
    }
  })

  if (!motivo) return

  showLoading('Desbloqueando RFC...')
  try {
    const response = await execute(
      'sp_bloqueorfc_desbloquear',
      'licencias',
      [
        { nombre: 'p_rfc', valor: bloqueo.rfc, tipo: 'string' },
        { nombre: 'p_id_tramite', valor: bloqueo.id_tramite, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'public'
    )

    // Primero ocultar el loading
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        // Luego mostrar el mensaje de éxito
        await Swal.fire({
          icon: 'success',
          title: 'RFC Desbloqueado',
          text: resultado.message,
          confirmButtonColor: '#9363CD',
          timer: 2000
        })

        // NO recargar automáticamente
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#9363CD'
        })
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'No se pudo desbloquear el RFC')
  }
}

const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    cargarBloqueos()
  }
}

const cambiarTamañoPagina = () => {
  currentPage.value = 1
  cargarBloqueos()
}

const limpiarFormulario = () => {
  idTramiteBuscar.value = null
  tramiteInfo.value = null
  nuevoBloqueo.value = {
    observacion: ''
  }
}

const formatNumber = (value) => {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
}

const formatDateTime = (datetime) => {
  if (!datetime) return 'N/A'
  const d = new Date(datetime)
  return d.toLocaleString('es-MX')
}

// NO cargar automáticamente al montar
onMounted(() => {
  // No cargar automáticamente, solo cargar cuando el usuario presione "Buscar"
})
</script>

<style scoped>
.info-tramite-box {
  background: #ffffff;
  border: 1px solid var(--slate-200);
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
}

.char-counter {
  font-size: 0.75rem;
  color: var(--slate-500);
  text-align: right;
  margin-top: 0.25rem;
}
</style>
