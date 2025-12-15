<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="lock" />
      </div>
      <div class="module-view-info">
        <h1>Bloqueo de Domicilios</h1>
        <p>Gestión de bloqueos y desbloqueos de licencias, anuncios y trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="abrirModalNuevo"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus-circle" />
          Nuevo Bloqueo
        </button>
        <button
          class="btn-municipal-primary"
          @click="cargarBloqueos"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Stats -->
      <div class="stats-grid stats-grid-3" v-if="totalRecords > 0">
        <div class="stat-card stat-primary">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="lock" />
            </div>
            <h3 class="stat-number">{{ formatNumber(totalRecords) }}</h3>
            <p class="stat-label">Total Bloqueos</p>
          </div>
        </div>
        <div class="stat-card stat-warning">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.vigentes) }}</h3>
            <p class="stat-label">Vigentes</p>
          </div>
        </div>
        <div class="stat-card stat-danger">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="lock" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.bloqueados) }}</h3>
            <p class="stat-label">Bloqueados</p>
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
        <div class="municipal-card-body" v-show="showFilters">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo:</label>
              <select class="municipal-form-control" v-model="filtros.tipo">
                <option value="">Todos</option>
                <option value="Licencia">Licencia</option>
                <option value="Anuncio">Anuncio</option>
                <option value="Tramite">Trámite</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estado:</label>
              <select class="municipal-form-control" v-model="filtros.estado">
                <option value="">Todos</option>
                <option value="bloqueado">Bloqueado</option>
                <option value="desbloqueado">Desbloqueado</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia:</label>
              <select class="municipal-form-control" v-model="filtros.vigente">
                <option value="">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
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

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Bloqueos
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
                  <th>Tipo</th>
                  <th>Número</th>
                  <th>Estado</th>
                  <th>Vigente</th>
                  <th>Fecha</th>
                  <th>Capturista</th>
                  <th>Observaciones</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="bloqueo in bloqueos" :key="`${bloqueo.tipo_registro}-${bloqueo.numero_registro}`" class="clickable-row">
                  <td>
                    <span class="badge" :class="{
                      'badge-primary': bloqueo.tipo_registro === 'Licencia',
                      'badge-purple': bloqueo.tipo_registro === 'Anuncio',
                      'badge-warning': bloqueo.tipo_registro === 'Tramite'
                    }">
                      {{ bloqueo.tipo_registro }}
                    </span>
                  </td>
                  <td><strong>{{ bloqueo.numero_registro }}</strong></td>
                  <td>
                    <span class="badge" :class="bloqueo.bloqueado === 1 ? 'badge-danger' : 'badge-success'">
                      {{ bloqueo.bloqueado === 1 ? 'Bloqueado' : 'Desbloqueado' }}
                    </span>
                  </td>
                  <td>
                    <span class="badge" :class="bloqueo.vigente === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ bloqueo.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>{{ formatDate(bloqueo.fecha_mov) }}</td>
                  <td>{{ bloqueo.capturista?.trim() || '-' }}</td>
                  <td class="small">{{ bloqueo.observa?.trim() || '-' }}</td>
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
                        v-if="bloqueo.vigente === 'V'"
                        class="btn-action btn-primary"
                        @click="editarBloqueo(bloqueo)"
                        :disabled="loading"
                        title="Editar bloqueo"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="bloqueo.vigente === 'V'"
                        class="btn-action btn-danger"
                        @click="confirmarCancelacion(bloqueo)"
                        :disabled="loading"
                        title="Cancelar bloqueo"
                      >
                        <font-awesome-icon icon="times" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="bloqueos.length === 0">
                  <td colspan="8" class="empty-state">
                    <div class="empty-state-content">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p class="empty-state-text">No se encontraron bloqueos</p>
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
    <!-- /module-view-content -->

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

  <!-- Modal Nuevo Bloqueo -->
  <Modal
    :show="mostrarModalNuevo"
    @close="cerrarModalNuevo"
    size="md"
  >
    <template #header>
      <h5 class="modal-title">
        <font-awesome-icon icon="plus-circle" class="me-2" />
        Registrar Nuevo Bloqueo
      </h5>
    </template>

    <form @submit.prevent="guardarNuevoBloqueo">
      <div class="form-group">
        <label class="municipal-form-label required">Tipo de Registro:</label>
        <select
          class="municipal-form-control"
          v-model="nuevoBloqueo.tipo"
          required
        >
          <option value="">Seleccionar...</option>
          <option value="Licencia">Licencia</option>
          <option value="Anuncio">Anuncio</option>
          <option value="Tramite">Trámite</option>
        </select>
      </div>
      <div class="form-group">
        <label class="municipal-form-label required">Número de {{ nuevoBloqueo.tipo || 'Registro' }}:</label>
        <input
          type="number"
          class="municipal-form-control"
          v-model.number="nuevoBloqueo.idRegistro"
          :placeholder="'Ingrese número de ' + (nuevoBloqueo.tipo || 'registro')"
          required
        />
      </div>
      <div class="form-group">
        <label class="municipal-form-label required">Observaciones:</label>
        <textarea
          class="municipal-form-control"
          v-model="nuevoBloqueo.observaciones"
          placeholder="Motivo del bloqueo"
          rows="3"
          required
        ></textarea>
      </div>
    </form>

    <template #footer>
      <button
        type="button"
        class="btn-municipal-secondary"
        @click="cerrarModalNuevo"
        :disabled="guardando"
      >
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button
        type="button"
        class="btn-municipal-danger"
        @click="guardarNuevoBloqueo"
        :disabled="guardando"
      >
        <font-awesome-icon icon="lock" />
        {{ guardando ? 'Registrando...' : 'Registrar Bloqueo' }}
      </button>
    </template>
  </Modal>

  <!-- Modal Detalle Bloqueo -->
  <Modal
    :show="mostrarModalDetalle"
    @close="cerrarModalDetalle"
    size="lg"
  >
    <template #header>
      <h5 class="modal-title">
        <font-awesome-icon icon="eye" class="me-2 text-info" />
        Detalle del Bloqueo - {{ bloqueoSeleccionado?.tipo_registro }} #{{ bloqueoSeleccionado?.numero_registro }}
      </h5>
    </template>

    <div v-if="bloqueoSeleccionado" class="modal-body-detail">
      <!-- Resumen superior con badges -->
      <div class="detail-summary-bar">
        <div class="summary-item">
          <span class="summary-label">Tipo</span>
          <span class="badge" :class="{
            'badge-primary-modern': bloqueoSeleccionado.tipo_registro === 'Licencia',
            'badge-purple-modern': bloqueoSeleccionado.tipo_registro === 'Anuncio',
            'badge-warning-modern': bloqueoSeleccionado.tipo_registro === 'Tramite'
          }">
            {{ bloqueoSeleccionado.tipo_registro }}
          </span>
        </div>
        <div class="summary-item">
          <span class="summary-label">Estado Bloqueo</span>
          <span class="badge" :class="bloqueoSeleccionado.bloqueado === 1 ? 'badge-danger' : 'badge-success'">
            {{ bloqueoSeleccionado.bloqueado === 1 ? 'Bloqueado' : 'Desbloqueado' }}
          </span>
        </div>
        <div class="summary-item">
          <span class="summary-label">Vigencia</span>
          <span class="badge" :class="bloqueoSeleccionado.vigente === 'V' ? 'badge-success' : 'badge-secondary'">
            {{ bloqueoSeleccionado.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
          </span>
        </div>
      </div>

      <!-- Grid de detalles -->
      <div class="details-grid">
        <!-- Información General -->
        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="info-circle" class="me-2" />
            Información General
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Tipo de Registro:</td>
              <td>
                <span class="badge" :class="{
                  'badge-primary': bloqueoSeleccionado.tipo_registro === 'Licencia',
                  'badge-purple': bloqueoSeleccionado.tipo_registro === 'Anuncio',
                  'badge-warning': bloqueoSeleccionado.tipo_registro === 'Tramite'
                }">
                  {{ bloqueoSeleccionado.tipo_registro }}
                </span>
              </td>
            </tr>
            <tr>
              <td class="label">Número de Registro:</td>
              <td><strong class="text-primary">{{ bloqueoSeleccionado.numero_registro }}</strong></td>
            </tr>
            <tr>
              <td class="label">Estado del Bloqueo:</td>
              <td>
                <span class="badge" :class="bloqueoSeleccionado.bloqueado === 1 ? 'badge-danger' : 'badge-success'">
                  <font-awesome-icon :icon="bloqueoSeleccionado.bloqueado === 1 ? 'lock' : 'lock-open'" class="me-1" />
                  {{ bloqueoSeleccionado.bloqueado === 1 ? 'Bloqueado' : 'Desbloqueado' }}
                </span>
              </td>
            </tr>
            <tr>
              <td class="label">Vigencia:</td>
              <td>
                <span class="badge" :class="bloqueoSeleccionado.vigente === 'V' ? 'badge-success' : 'badge-secondary'">
                  {{ bloqueoSeleccionado.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                </span>
              </td>
            </tr>
          </table>
        </div>

        <!-- Datos de Registro -->
        <div class="detail-section">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="calendar-alt" class="me-2" />
            Datos de Registro
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Fecha de Movimiento:</td>
              <td>
                <font-awesome-icon icon="clock" class="me-1 text-muted" />
                {{ formatDate(bloqueoSeleccionado.fecha_mov) }}
              </td>
            </tr>
            <tr>
              <td class="label">Capturista:</td>
              <td>
                <font-awesome-icon icon="user" class="me-1 text-muted" />
                {{ bloqueoSeleccionado.capturista?.trim() || 'N/A' }}
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
          {{ bloqueoSeleccionado.observa?.trim() || 'Sin observaciones registradas' }}
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
        v-if="bloqueoSeleccionado?.vigente === 'V'"
        type="button"
        class="btn-municipal-primary"
        @click="editarBloqueo(bloqueoSeleccionado); cerrarModalDetalle()"
      >
        <font-awesome-icon icon="edit" />
        Editar
      </button>
    </template>
  </Modal>

  <!-- Modal Editar Bloqueo -->
  <Modal
    :show="mostrarModalEditar"
    @close="cerrarModalEditar"
    size="md"
  >
    <template #header>
      <h5 class="modal-title">
        <font-awesome-icon icon="edit" class="me-2" />
        Editar Bloqueo
      </h5>
    </template>

    <div v-if="bloqueoEditar">
      <form @submit.prevent="guardarEdicion">
        <div class="form-group">
          <label class="municipal-form-label">Tipo de Registro:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="bloqueoEditar.tipo_registro"
            disabled
          />
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Número de Registro:</label>
          <input
            type="text"
            class="municipal-form-control"
            :value="bloqueoEditar.numero_registro"
            disabled
          />
        </div>
        <div class="form-group">
          <label class="municipal-form-label">Estado del Bloqueo:</label>
          <select
            class="municipal-form-control"
            v-model="bloqueoEditar.bloqueado"
          >
            <option :value="1">Bloqueado</option>
            <option :value="0">Desbloqueado</option>
          </select>
        </div>
        <div class="form-group">
          <label class="municipal-form-label required">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="bloqueoEditar.observa"
            placeholder="Observaciones del bloqueo"
            rows="3"
            required
          ></textarea>
        </div>
      </form>
    </div>

    <template #footer>
      <button
        type="button"
        class="btn-municipal-secondary"
        @click="cerrarModalEditar"
        :disabled="guardando"
      >
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button
        type="button"
        class="btn-municipal-primary"
        @click="guardarEdicion"
        :disabled="guardando"
      >
        <font-awesome-icon icon="save" />
        {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
      </button>
    </template>
  </Modal>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'bloqueoDomiciliosfrm'"
    :moduleName="'padron_licencias'"
    @close="closeDocumentation"
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

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const bloqueos = ref([])
const loading = ref(false)
const guardando = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)
const showFilters = ref(false)
const mostrarModalNuevo = ref(false)
const mostrarModalDetalle = ref(false)
const mostrarModalEditar = ref(false)
const bloqueoSeleccionado = ref(null)
const bloqueoEditar = ref(null)

const stats = ref({
  vigentes: 0,
  bloqueados: 0
})

const nuevoBloqueo = ref({
  tipo: '',
  idRegistro: null,
  observaciones: ''
})

const filtros = ref({
  tipo: '',
  estado: '',
  vigente: 'V'
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

const abrirModalNuevo = () => {
  nuevoBloqueo.value = {
    tipo: '',
    idRegistro: null,
    observaciones: ''
  }
  mostrarModalNuevo.value = true
}

const cerrarModalNuevo = () => {
  mostrarModalNuevo.value = false
  nuevoBloqueo.value = {
    tipo: '',
    idRegistro: null,
    observaciones: ''
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

const editarBloqueo = (bloqueo) => {
  bloqueoEditar.value = { ...bloqueo }
  mostrarModalEditar.value = true
}

const cerrarModalEditar = () => {
  mostrarModalEditar.value = false
  bloqueoEditar.value = null
}

const guardarEdicion = async () => {
  if (!bloqueoEditar.value.observa || !bloqueoEditar.value.observa.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor ingrese las observaciones',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  const result = await Swal.fire({
    title: 'Confirmar Cambios',
    text: '¿Está seguro de guardar los cambios realizados?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  guardando.value = true
  showLoading('Guardando cambios...')

  try {
    const response = await execute(
      'sp_bloqueodomicilios_update',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: bloqueoEditar.value.tipo_registro, tipo: 'string' },
        { nombre: 'p_id_registro', valor: bloqueoEditar.value.numero_registro, tipo: 'integer' },
        { nombre: 'p_bloqueado', valor: bloqueoEditar.value.bloqueado, tipo: 'integer' },
        { nombre: 'p_observa', valor: bloqueoEditar.value.observa, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    // Primero ocultar el loading
    guardando.value = false
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        // Luego mostrar el mensaje de éxito
        await Swal.fire({
          icon: 'success',
          title: 'Cambios Guardados',
          text: resultado.message,
          confirmButtonColor: '#9363CD',
          timer: 2000
        })

        cerrarModalEditar()
        // NO recargar la consulta automáticamente
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
    guardando.value = false
    hideLoading()
    handleApiError(error, 'No se pudo actualizar el bloqueo')
  }
}

const cargarBloqueos = async () => {
  showLoading('Cargando bloqueos...')
  showFilters.value = false
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_bloqueodomicilios_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
        { nombre: 'p_tipo', valor: filtros.value.tipo || null, tipo: 'string' },
        { nombre: 'p_estado', valor: filtros.value.estado || null, tipo: 'string' },
        { nombre: 'p_vigente', valor: filtros.value.vigente || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
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
      calcularEstadisticas()

      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast(`${formatNumber(totalRecords.value)} bloqueos cargados`, 'success', `(${timeMessage})`)
    }
  } catch (error) {
    handleApiError(error, 'No se pudieron cargar los bloqueos')
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
    tipo: '',
    estado: '',
    vigente: 'V'
  }
  currentPage.value = 1
  cargarBloqueos()
}

const guardarNuevoBloqueo = async () => {
  if (!nuevoBloqueo.value.tipo || !nuevoBloqueo.value.idRegistro || !nuevoBloqueo.value.observaciones) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos Requeridos',
      text: 'Por favor complete todos los campos',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  // Confirmación antes de registrar
  const result = await Swal.fire({
    title: '¿Registrar Bloqueo?',
    html: `
      <p>¿Está seguro de registrar el bloqueo para:</p>
      <p><strong>${nuevoBloqueo.value.tipo} #${nuevoBloqueo.value.idRegistro}</strong>?</p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  guardando.value = true
  showLoading('Registrando bloqueo...')

  try {
    const response = await execute(
      'sp_bloqueodomicilios_create',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: nuevoBloqueo.value.tipo, tipo: 'string' },
        { nombre: 'p_id_registro', valor: nuevoBloqueo.value.idRegistro, tipo: 'integer' },
        { nombre: 'p_observa', valor: nuevoBloqueo.value.observaciones, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    // Primero ocultar el loading
    guardando.value = false
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

        cerrarModalNuevo()
        // NO recargar la consulta automáticamente
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
    guardando.value = false
    hideLoading()
    handleApiError(error, 'No se pudo registrar el bloqueo')
  }
}

const confirmarCancelacion = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Cancelar Bloqueo',
    html: `
      <p>¿Está seguro de cancelar el bloqueo de <strong>${bloqueo.tipo_registro} #${bloqueo.numero_registro}</strong>?</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo de la cancelación..." rows="3"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    preConfirm: () => {
      const motivo = document.getElementById('swal-motivo').value
      if (!motivo || !motivo.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo de la cancelación')
      }
      return motivo
    }
  })

  if (!motivo) return

  showLoading('Cancelando bloqueo...')

  try {
    const response = await execute(
      'sp_bloqueodomicilios_cancel',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: bloqueo.tipo_registro, tipo: 'string' },
        { nombre: 'p_id_registro', valor: bloqueo.numero_registro, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    // Primero ocultar el loading
    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        // Luego mostrar el mensaje de éxito
        await Swal.fire({
          icon: 'success',
          title: 'Cancelado',
          text: resultado.message,
          confirmButtonColor: '#9363CD',
          timer: 2000
        })

        // NO recargar la consulta automáticamente
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
    handleApiError(error, 'No se pudo cancelar el bloqueo')
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

const calcularEstadisticas = () => {
  let vigentes = 0
  let bloqueados = 0

  bloqueos.value.forEach(b => {
    if (b.vigente === 'V') vigentes++
    if (b.bloqueado === 1) bloqueados++
  })

  stats.value = { vigentes, bloqueados }
}

// Utilidades
const formatNumber = (value) => {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX')
}

// Lifecycle
onMounted(() => {
  // No cargar automáticamente, solo cargar cuando el usuario presione "Actualizar" o "Buscar"
})
</script>
