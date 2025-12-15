<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda SCIAN</h1>
        <p>Padrón de Licencias - Búsqueda de Códigos SCIAN</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="scianes.length > 0"
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
              type="text"
              class="municipal-form-control"
              v-model="filters.codigo"
              placeholder="Buscar por código"
              @keyup.enter="searchScian"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="searchScian"
            />
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchScian"
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
          <span class="badge-purple" v-if="scianes.length > 0">
            {{ scianes.length }} registros
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
                <th>Código</th>
                <th>Descripción</th>
                <th>Tipo</th>
                <th>Microgenerador</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="scian in scianes" :key="scian.codigo_scian" class="clickable-row" @click="viewScian(scian)">
                <td><strong class="text-primary"><code>{{ scian.codigo_scian }}</code></strong></td>
                <td>{{ scian.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span :class="getTipoBadgeClass(scian.tipo)">
                    {{ getTipoLabel(scian.tipo) }}
                  </span>
                </td>
                <td>
                  <span v-if="scian.es_microgenerador === 'S'" class="badge-success">
                    <font-awesome-icon icon="check" /> Sí
                  </span>
                  <span v-else class="badge-secondary">
                    <font-awesome-icon icon="times" /> No
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewScian(scian)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="selectScian(scian)"
                      title="Seleccionar código SCIAN"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="scianes.length === 0 && !loading">
                <td colspan="5" class="text-center text-muted empty-state">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron códigos SCIAN. Use los filtros para buscar.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Panel de SCIAN seleccionado -->
    <div class="municipal-card" v-if="scianSeleccionado">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" class="text-success" />
          Código SCIAN Seleccionado
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="selected-item-panel">
          <div class="selected-item-info">
            <div class="info-row">
              <span class="info-label">Código:</span>
              <span class="info-value"><code>{{ scianSeleccionado.codigo_scian }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Descripción:</span>
              <span class="info-value">{{ scianSeleccionado.descripcion?.trim() }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Tipo:</span>
              <span class="info-value">
                <span :class="getTipoBadgeClass(scianSeleccionado.tipo)">
                  {{ getTipoLabel(scianSeleccionado.tipo) }}
                </span>
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">Microgenerador:</span>
              <span class="info-value">
                <span v-if="scianSeleccionado.es_microgenerador === 'S'" class="badge-success">
                  <font-awesome-icon icon="check" /> Sí
                </span>
                <span v-else class="badge-secondary">
                  <font-awesome-icon icon="times" /> No
                </span>
              </span>
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
    <div v-if="loading && scianes.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Buscando códigos SCIAN...</p>
      </div>
    </div>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles del Código SCIAN: ${selectedScian?.codigo_scian}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedScian" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información del Código SCIAN
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Código:</td>
                <td><code>{{ selectedScian.codigo_scian }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedScian.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span :class="getTipoBadgeClass(selectedScian.tipo)">
                    {{ getTipoLabel(selectedScian.tipo) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Microgenerador:</td>
                <td>
                  <span v-if="selectedScian.es_microgenerador === 'S'" class="badge-success">
                    <font-awesome-icon icon="check" /> Sí
                  </span>
                  <span v-else class="badge-secondary">
                    <font-awesome-icon icon="times" /> No
                  </span>
                </td>
              </tr>
              <tr v-if="selectedScian.es_microgenerador === 'S'">
                <td class="label">Categorías Microgenerador:</td>
                <td>
                  <div class="badge-group">
                    <span v-if="selectedScian.microgenerador_a === 'S'" class="badge-purple">A</span>
                    <span v-if="selectedScian.microgenerador_b === 'S'" class="badge-purple">B</span>
                    <span v-if="selectedScian.microgenerador_c === 'S'" class="badge-purple">C</span>
                    <span v-if="selectedScian.microgenerador_d === 'S'" class="badge-purple">D</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span :class="selectedScian.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ selectedScian.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
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
          <button class="btn-municipal-primary" @click="selectScian(selectedScian); showViewModal = false">
            <font-awesome-icon icon="check" />
            Seleccionar Código SCIAN
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
      :componentName="'BusquedaScianFrm'"
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
const scianes = ref([])
const scianSeleccionado = ref(null)
const selectedScian = ref(null)
const showViewModal = ref(false)
const showFilters = ref(true)

// Filtros
const filters = ref({
  codigo: '',
  descripcion: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const searchScian = async () => {
  // Validar que al menos un criterio esté lleno
  if (!filters.value.codigo && !filters.value.descripcion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando códigos SCIAN...')

  // Medir tiempo de ejecución
  const startTime = performance.now()

  try {
    // Combinar código y descripción en un solo parámetro de búsqueda
    const searchTerm = filters.value.codigo || filters.value.descripcion

    const response = await execute(
      'catalogo_scian_busqueda',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: searchTerm, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2) // Convertir a segundos

    if (response && response.result) {
      scianes.value = response.result

      // Formatear mensaje de duración
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      if (scianes.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${scianes.value.length} códigos SCIAN`)
      } else {
        showToast('info', 'No se encontraron códigos SCIAN con los criterios especificados')
      }
    } else {
      scianes.value = []
      showToast('error', 'Error al buscar códigos SCIAN')
    }
  } catch (error) {
    handleApiError(error)
    scianes.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    codigo: '',
    descripcion: ''
  }
  scianes.value = []
  scianSeleccionado.value = null
  showToast('info', 'Filtros limpiados')
}

const viewScian = (scian) => {
  selectedScian.value = scian
  showViewModal.value = true
}

const selectScian = async (scian) => {
  scianSeleccionado.value = scian

  await Swal.fire({
    icon: 'success',
    title: 'Código SCIAN Seleccionado',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">Ha seleccionado el siguiente código SCIAN:</p>
        <ul class="swal-selection-list">
          <li><strong>Código:</strong> ${scian.codigo_scian}</li>
          <li><strong>Descripción:</strong> ${scian.descripcion?.trim()}</li>
          <li><strong>Tipo:</strong> ${getTipoLabel(scian.tipo)}</li>
        </ul>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    timer: 3000
  })

  showToast('success', 'Código SCIAN seleccionado correctamente')
}

const clearSelection = () => {
  scianSeleccionado.value = null
  showToast('info', 'Selección limpiada')
}

// Utilidades
const getTipoBadgeClass = (tipo) => {
  const classes = {
    'S': 'badge-primary',  // Sector
    'R': 'badge-purple',   // Rama
    'C': 'badge-success',  // Clase
    'A': 'badge-warning',  // Actividad
    'E': 'badge-secondary' // Específica
  }
  return classes[tipo] || 'badge-secondary'
}

const getTipoLabel = (tipo) => {
  const labels = {
    'S': 'Sector',
    'R': 'Rama',
    'C': 'Clase',
    'A': 'Actividad',
    'E': 'Específica'
  }
  return labels[tipo] || 'N/A'
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
