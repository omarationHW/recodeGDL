<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Agenda de Visitas</h1>
        <p>Padrón de Licencias - Gestión de Agenda de Visitas de Inspección</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="exportarReporte"
          :disabled="visitas.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Exportar PDF
        </button>
        <button
          class="btn-municipal-primary"
          @click="loadVisitas"
          :disabled="!filters.id_dependencia || !filters.fechaini || !filters.fechafin"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          type="button"
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

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
            :disabled="!filters.id_dependencia || !filters.fechaini || !filters.fechafin"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
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
          Agenda de Visitas Programadas
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="visitas.length > 0">{{ formatNumber(visitas.length) }} visitas</span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 10%;">
                  <font-awesome-icon icon="calendar" class="me-1" />
                  Fecha
                </th>
                <th style="width: 8%;">
                  <font-awesome-icon icon="calendar-day" class="me-1" />
                  Día
                </th>
                <th style="width: 8%; text-align: center;">
                  <font-awesome-icon icon="sun" class="me-1" />
                  Turno
                </th>
                <th style="width: 7%; text-align: center;">
                  <font-awesome-icon icon="clock" class="me-1" />
                  Hora
                </th>
                <th style="width: 8%; text-align: center;">
                  <font-awesome-icon icon="map-marker-alt" class="me-1" />
                  Zona
                </th>
                <th style="width: 8%; text-align: center;">
                  <font-awesome-icon icon="file-alt" class="me-1" />
                  Trámite
                </th>
                <th style="width: 15%;">
                  <font-awesome-icon icon="user" class="me-1" />
                  Propietario
                </th>
                <th style="width: 20%;">
                  <font-awesome-icon icon="map-marked-alt" class="me-1" />
                  Domicilio
                </th>
                <th style="width: 16%;">
                  <font-awesome-icon icon="briefcase" class="me-1" />
                  Actividad
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(visita, index) in visitas" :key="index" class="clickable-row" @click="viewVisita(visita)">
                <td>
                  <div class="giro-name">
                    <font-awesome-icon icon="calendar-check" class="giro-icon text-primary" />
                    <span class="giro-text">{{ formatDate(visita.fecha) }}</span>
                  </div>
                </td>
                <td>
                  <span class="badge badge-light-info">{{ visita.dia_letras || 'N/A' }}</span>
                </td>
                <td style="text-align: center;">
                  <span class="badge" :class="getTurnoBadgeClass(visita.turno)">
                    {{ visita.turno || 'N/A' }}
                  </span>
                </td>
                <td style="text-align: center;">
                  <span class="text-muted">{{ visita.hora || 'N/A' }}</span>
                </td>
                <td style="text-align: center;">
                  <div class="zona-info">
                    <span class="badge badge-secondary">Z: {{ visita.zona || 'N/A' }}</span>
                    <span class="badge badge-secondary">SZ: {{ visita.subzona || 'N/A' }}</span>
                  </div>
                </td>
                <td style="text-align: center;">
                  <code class="text-primary">{{ visita.id_tramite }}</code>
                </td>
                <td>
                  <div class="giro-name">
                    <font-awesome-icon icon="user-circle" class="giro-icon" />
                    <span class="giro-text">{{ visita.propietarionvo?.trim() || visita.propietario?.trim() || 'N/A' }}</span>
                  </div>
                </td>
                <td>
                  <span class="domicilio-text">{{ visita.domcompleto?.trim() || 'N/A' }}</span>
                </td>
                <td>
                  <span class="giro-text">{{ visita.actividad?.trim() || 'N/A' }}</span>
                </td>
              </tr>
              <tr v-if="visitas.length === 0">
                <td colspan="9" class="text-center">
                  <div class="empty-state-content">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="calendar-times" />
                    </div>
                    <p class="empty-state-text">No hay visitas agendadas</p>
                    <p class="empty-state-hint">Seleccione una dependencia y rango de fechas, luego presione Buscar</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
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
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
      </div>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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
const visitas = ref([])
const dependencias = ref([])
const selectedVisita = ref(null)
const showViewModal = ref(false)
const showFilters = ref(true)

// Filtros
const filters = ref({
  id_dependencia: '',
  fechaini: '',
  fechafin: ''
})

// Toggle filtros
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Métodos
const loadDependencias = async () => {
  try {
    const response = await execute(
      'SP_GET_DEPENDENCIAS',
      'padron_licencias',
      [],
      '',
      null,
      'publico'
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

  showLoading('Cargando agenda de visitas...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'SP_GET_AGENDA_VISITAS',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: parseInt(filters.value.id_dependencia), tipo: 'integer' },
        { nombre: 'p_fechaini', valor: filters.value.fechaini, tipo: 'string' },
        { nombre: 'p_fechafin', valor: filters.value.fechafin, tipo: 'string' }
      ],
      '',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = endTime - startTime

    if (response && response.result) {
      visitas.value = response.result
      const durationText = duration < 1000 ? `${Math.round(duration)}ms` : `${(duration / 1000).toFixed(2)}s`
      showToast('success', `Se encontraron ${formatNumber(visitas.value.length)} visitas agendadas`, durationText)
    } else {
      visitas.value = []
      showToast('info', 'No se encontraron visitas en el rango seleccionado')
    }
  } catch (error) {
    handleApiError(error)
    visitas.value = []
  } finally {
    hideLoading()
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
const formatNumber = (num) => {
  if (num === null || num === undefined) return '0'
  return new Intl.NumberFormat('es-MX').format(num)
}

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
/* Estilos específicos del componente - Los estilos globales están en municipal-theme.css */
</style>
