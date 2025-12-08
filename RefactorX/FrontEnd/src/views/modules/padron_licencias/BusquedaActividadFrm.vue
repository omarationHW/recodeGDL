<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Actividades</h1>
        <p>Padrón de Licencias - Búsqueda de Actividades Comerciales</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="actividades.length > 0"
          class="btn-municipal-secondary"
          @click="clearFilters"
          title="Limpiar filtros y resultados"
        >
          <font-awesome-icon icon="eraser" />
          Limpiar
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

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header clickable-header" @click="toggleFilters">
        <h5>
          <font-awesome-icon icon="filter" />
          Criterios de Búsqueda
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
        </h5>
      </div>
      <div class="municipal-card-body" v-show="showFilters">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Código SCIAN</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.scian"
              placeholder="Código SCIAN"
              @keyup.enter="searchActividades"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="searchActividades"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Giro</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id_giro"
              placeholder="Buscar por ID"
              @keyup.enter="searchActividades"
            />
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchActividades"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
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
          Resultados de Búsqueda
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="actividades.length > 0">
            {{ actividades.length }} registros
          </span>
          <div v-if="loading" class="spinner-border spinner-sm" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID Giro</th>
                <th>Código SCIAN</th>
                <th>Descripción</th>
                <th>Vigente</th>
                <th>Año</th>
                <th>Costo</th>
                <th>Refrendo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="actividad in actividades" :key="actividad.id_giro" class="clickable-row" @click="viewActividad(actividad)">
                <td><strong class="text-primary">{{ actividad.id_giro }}</strong></td>
                <td>
                  <span class="badge-secondary">
                    {{ actividad.cod_giro || 'N/A' }}
                  </span>
                </td>
                <td>{{ actividad.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span :class="actividad.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ actividad.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td>{{ actividad.axo || 'N/A' }}</td>
                <td>{{ formatCurrency(actividad.costo) }}</td>
                <td>{{ formatCurrency(actividad.refrendo) }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewActividad(actividad)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="selectActividad(actividad)"
                      title="Seleccionar actividad"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="actividades.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted empty-state">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron actividades. Use los filtros para buscar.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Panel de actividad seleccionada -->
    <div class="municipal-card" v-if="actividadSeleccionada">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" class="text-success" />
          Actividad Seleccionada
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="selected-item-panel">
          <div class="selected-item-info">
            <div class="info-row">
              <span class="info-label">ID Giro:</span>
              <span class="info-value"><code>{{ actividadSeleccionada.id_giro }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Código SCIAN:</span>
              <span class="info-value">
                <span class="badge-secondary">{{ actividadSeleccionada.cod_giro }}</span>
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">Descripción:</span>
              <span class="info-value">{{ actividadSeleccionada.descripcion?.trim() }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Costo:</span>
              <span class="info-value">{{ formatCurrency(actividadSeleccionada.costo) }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Refrendo:</span>
              <span class="info-value">{{ formatCurrency(actividadSeleccionada.refrendo) }}</span>
            </div>
          </div>
          <div class="selected-item-actions">
            <button
              class="btn-municipal-secondary"
              @click="clearSelection"
            >
              <font-awesome-icon icon="times" />
              Limpiar Selección
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && actividades.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Buscando actividades...</p>
      </div>
    </div>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Actividad: ${selectedActividad?.descripcion}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedActividad" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información de la Actividad
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Giro:</td>
                <td><code>{{ selectedActividad.id_giro }}</code></td>
              </tr>
              <tr>
                <td class="label">Código SCIAN:</td>
                <td>
                  <span class="badge-secondary">
                    {{ selectedActividad.cod_giro || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedActividad.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span :class="selectedActividad.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ selectedActividad.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Año:</td>
                <td>{{ selectedActividad.axo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Costo:</td>
                <td><strong>{{ formatCurrency(selectedActividad.costo) }}</strong></td>
              </tr>
              <tr>
                <td class="label">Refrendo:</td>
                <td><strong>{{ formatCurrency(selectedActividad.refrendo) }}</strong></td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="selectActividad(selectedActividad); showViewModal = false">
            <font-awesome-icon icon="check" />
            Seleccionar Actividad
          </button>
        </div>
      </div>
    </Modal>

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
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'BusquedaActividadFrm'"
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
const actividades = ref([])
const actividadSeleccionada = ref(null)
const selectedActividad = ref(null)
const showViewModal = ref(false)
const showFilters = ref(true)

// Filtros
const filters = ref({
  scian: '',
  descripcion: '',
  id_giro: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const searchActividades = async () => {
  // Validar que al menos un criterio esté lleno
  if (!filters.value.scian && !filters.value.descripcion && !filters.value.id_giro) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando actividades...')

  // Medir tiempo de ejecución
  const startTime = performance.now()

  try {
    let response

    // Si busca por ID, usar buscar_actividad_por_id
    if (filters.value.id_giro) {
      response = await execute(
        'buscar_actividad_por_id',
        'padron_licencias',
        [
          { nombre: 'p_id_giro', valor: parseInt(filters.value.id_giro), tipo: 'integer' }
        ],
        'guadalajara'
      )
    }
    // Si busca por SCIAN (con o sin descripción), usar buscar_actividades
    else if (filters.value.scian) {
      const parametros = [
        { nombre: 'p_scian', valor: parseInt(filters.value.scian), tipo: 'integer' }
      ]

      // Agregar descripción si existe
      if (filters.value.descripcion) {
        parametros.push({
          nombre: 'p_descripcion',
          valor: filters.value.descripcion,
          tipo: 'string'
        })
      }

      response = await execute(
        'buscar_actividades',
        'padron_licencias',
        parametros,
        'guadalajara'
      )
    }
    // Si solo busca por descripción, mostrar advertencia
    else {
      await Swal.fire({
        icon: 'info',
        title: 'Criterio insuficiente',
        text: 'Para buscar por descripción, debe proporcionar también un código SCIAN',
        confirmButtonColor: '#ea8215'
      })
      setLoading(false)
      return
    }

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2) // Convertir a segundos

    if (response && response.result) {
      actividades.value = response.result

      // Formatear mensaje de duración
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      if (actividades.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${actividades.value.length} actividades`)
      } else {
        showToast('info', 'No se encontraron actividades con los criterios especificados')
      }
    } else {
      actividades.value = []
      showToast('error', 'Error al buscar actividades')
    }
  } catch (error) {
    handleApiError(error)
    actividades.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    scian: '',
    descripcion: '',
    id_giro: ''
  }
  actividades.value = []
  actividadSeleccionada.value = null
  showToast('info', 'Filtros limpiados')
}

const viewActividad = (actividad) => {
  selectedActividad.value = actividad
  showViewModal.value = true
}

const selectActividad = async (actividad) => {
  actividadSeleccionada.value = actividad

  await Swal.fire({
    icon: 'success',
    title: 'Actividad Seleccionada',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">Ha seleccionado la siguiente actividad:</p>
        <ul class="swal-selection-list">
          <li><strong>ID Giro:</strong> ${actividad.id_giro}</li>
          <li><strong>Código SCIAN:</strong> ${actividad.cod_giro}</li>
          <li><strong>Descripción:</strong> ${actividad.descripcion?.trim()}</li>
          <li><strong>Costo:</strong> ${formatCurrency(actividad.costo)}</li>
          <li><strong>Refrendo:</strong> ${formatCurrency(actividad.refrendo)}</li>
        </ul>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    timer: 4000
  })

  showToast('success', 'Actividad seleccionada correctamente')
}

const clearSelection = () => {
  actividadSeleccionada.value = null
  showToast('info', 'Selección limpiada')
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return 'N/A'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch {
    return 'N/A'
  }
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  showViewModal.value = false
})
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
