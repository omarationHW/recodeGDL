<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Agenda de Visitas</h1>
        <p>Padrón de Licencias - Gestión de Agenda de Visitas de Inspección</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="exportarReporte"
          :disabled="loading || visitas.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Exportar PDF
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Dependencia <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="filters.id_dependencia">
              <option value="">Seleccione una dependencia...</option>
              <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">
                {{ dep.descripcion }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Inicio <span class="required">*</span></label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaini"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Fin <span class="required">*</span></label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechafin"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchVisitas"
            :disabled="loading || !filters.id_dependencia || !filters.fechaini || !filters.fechafin"
          >
            <font-awesome-icon icon="search" />
            Buscar Visitas
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadVisitas"
            :disabled="loading || !filters.id_dependencia || !filters.fechaini || !filters.fechafin"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Agenda de Visitas Programadas
          <span class="badge-info" v-if="visitas.length > 0">{{ visitas.length }} visitas</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Fecha</th>
                <th>Día</th>
                <th>Turno</th>
                <th>Hora</th>
                <th>Zona/Subzona</th>
                <th>ID Trámite</th>
                <th>Propietario</th>
                <th>Domicilio</th>
                <th>Actividad</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(visita, index) in visitas" :key="index" class="row-hover">
                <td>
                  <strong class="text-primary">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(visita.fecha) }}
                  </strong>
                </td>
                <td>
                  <span class="badge-info">{{ visita.dia_letras || 'N/A' }}</span>
                </td>
                <td>
                  <span class="badge" :class="getTurnoBadgeClass(visita.turno)">
                    {{ visita.turno || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="clock" />
                    {{ visita.hora || 'N/A' }}
                  </small>
                </td>
                <td>
                  <div class="zona-info">
                    <span class="badge-secondary">Z: {{ visita.zona || 'N/A' }}</span>
                    <span class="badge-secondary">SZ: {{ visita.subzona || 'N/A' }}</span>
                  </div>
                </td>
                <td>
                  <code class="text-muted">{{ visita.id_tramite }}</code>
                </td>
                <td>{{ visita.propietarionvo?.trim() || visita.propietario?.trim() || 'N/A' }}</td>
                <td>
                  <small class="domicilio-text">{{ visita.domcompleto?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <small>{{ visita.actividad?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewVisita(visita)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="verTramite(visita.id_tramite)"
                      title="Ver trámite"
                    >
                      <font-awesome-icon icon="file-alt" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="visitas.length === 0 && !loading">
                <td colspan="10" class="text-center text-muted">
                  <font-awesome-icon icon="calendar-times" size="2x" class="empty-icon" />
                  <p>No hay visitas agendadas para los criterios seleccionados</p>
                  <p><small>Seleccione una dependencia y rango de fechas, luego presione Buscar</small></p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && visitas.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando agenda de visitas...</p>
      </div>
    </div>

    <!-- Modal de visualización de visita -->
    <Modal
      :show="showViewModal"
      :title="`Detalle de Visita - Trámite ${selectedVisita?.id_tramite}`"
      size="xl"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedVisita" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-check" />
              Información de la Visita
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-primary" />
                  <strong>{{ formatDate(selectedVisita.fecha) }}</strong>
                </td>
              </tr>
              <tr>
                <td class="label">Día:</td>
                <td>{{ selectedVisita.dia_letras || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Turno:</td>
                <td>
                  <span class="badge" :class="getTurnoBadgeClass(selectedVisita.turno)">
                    {{ selectedVisita.turno || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Hora:</td>
                <td>
                  <font-awesome-icon icon="clock" class="text-info" />
                  {{ selectedVisita.hora || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>
                  <span class="badge-secondary">{{ selectedVisita.zona || 'N/A' }}</span>
                </td>
              </tr>
              <tr>
                <td class="label">Subzona:</td>
                <td>
                  <span class="badge-secondary">{{ selectedVisita.subzona || 'N/A' }}</span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Información del Propietario y Trámite
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Trámite:</td>
                <td><code>{{ selectedVisita.id_tramite }}</code></td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedVisita.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td><strong>{{ selectedVisita.propietarionvo?.trim() || selectedVisita.propietario?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label" colspan="2">Domicilio Completo:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedVisita.domcompleto?.trim() || 'N/A' }}
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label" colspan="2">Actividad:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedVisita.actividad?.trim() || 'N/A' }}
                  </div>
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="verTramite(selectedVisita.id_tramite)">
            <font-awesome-icon icon="file-alt" />
            Ver Trámite Completo
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notification -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Agendavisitasfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const visitas = ref([])
const dependencias = ref([])
const selectedVisita = ref(null)
const showViewModal = ref(false)

// Filtros
const filters = ref({
  id_dependencia: '',
  fechaini: '',
  fechafin: ''
})

// Métodos
const loadDependencias = async () => {
  try {
    const response = await execute(
      'SP_GET_DEPENDENCIAS',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      dependencias.value = response.result
    } else {
      dependencias.value = []
    }
  } catch (error) {
    handleApiError(error)
    dependencias.value = []
  }
}

const loadVisitas = async () => {
  if (!filters.value.id_dependencia || !filters.value.fechaini || !filters.value.fechafin) {
    showToast('warning', 'Por favor complete todos los filtros requeridos')
    return
  }

  setLoading(true, 'Cargando agenda de visitas...')

  try {
    const response = await execute(
      'SP_GET_AGENDA_VISITAS',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(filters.value.id_dependencia), tipo: 'integer' },
        { nombre: 'p_fechaini', valor: filters.value.fechaini, tipo: 'string' },
        { nombre: 'p_fechafin', valor: filters.value.fechafin, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      visitas.value = response.result
      showToast('success', `Se encontraron ${visitas.value.length} visitas agendadas`)
    } else {
      visitas.value = []
      showToast('info', 'No se encontraron visitas en el rango seleccionado')
    }
  } catch (error) {
    handleApiError(error)
    visitas.value = []
  } finally {
    setLoading(false)
  }
}

const searchVisitas = () => {
  loadVisitas()
}

const clearFilters = () => {
  filters.value = {
    id_dependencia: '',
    fechaini: '',
    fechafin: ''
  }
  visitas.value = []
}

const viewVisita = (visita) => {
  selectedVisita.value = visita
  showViewModal.value = true
}

const verTramite = async (id_tramite) => {
  await Swal.fire({
    icon: 'info',
    title: 'Ver Trámite',
    text: `Funcionalidad para ver detalles del trámite ${id_tramite}`,
    confirmButtonColor: '#ea8215'
  })
}

const exportarReporte = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Exportar a PDF',
    text: 'Funcionalidad de exportación en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
const getTurnoBadgeClass = (turno) => {
  const classes = {
    'MATUTINO': 'badge-success',
    'VESPERTINO': 'badge-warning',
    'COMPLETO': 'badge-primary'
  }
  return classes[turno?.toUpperCase()] || 'badge-secondary'
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

// Lifecycle
onMounted(() => {
  loadDependencias()

  // Establecer fechas por defecto (semana actual)
  const today = new Date()
  const nextWeek = new Date(today)
  nextWeek.setDate(nextWeek.getDate() + 7)

  filters.value.fechaini = today.toISOString().split('T')[0]
  filters.value.fechafin = nextWeek.toISOString().split('T')[0]
})

onBeforeUnmount(() => {
  showViewModal.value = false
})
</script>

<style scoped>
.zona-info {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.domicilio-text {
  display: block;
  max-width: 250px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.observaciones-box {
  padding: 10px;
  background-color: #f8f9fa;
  border-radius: 4px;
  border: 1px solid #dee2e6;
  min-height: 40px;
  white-space: pre-wrap;
}

.details-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  .details-grid {
    grid-template-columns: 1fr;
  }
}
</style>
