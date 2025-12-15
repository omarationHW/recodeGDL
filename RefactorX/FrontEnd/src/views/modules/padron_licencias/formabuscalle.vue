<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="road" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Calles</h1>
        <p>Padrón de Licencias - Formulario auxiliar para búsqueda y selección de calles</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="calles.length > 0"
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
            <label class="municipal-form-label">Nombre de la Calle</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Ingrese el nombre de la calle"
              @keyup.enter="searchCalles"
            />
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchCalles"
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
          <button
            class="btn-municipal-secondary"
            @click="loadCalles"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Listar Todas
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
          <span class="badge-purple" v-if="calles.length > 0">
            {{ calles.length }} calles
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
                <th>Nombre de la Calle</th>
                <th>Población</th>
                <th>Vialidad</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="calle in calles" :key="calle.cvecalle" class="clickable-row" @click="viewCalle(calle)">
                <td>
                  <span class="badge-secondary">
                    {{ calle.cvecalle }}
                  </span>
                </td>
                <td><strong class="text-primary">{{ calle.calle?.trim() }}</strong></td>
                <td>
                  <span class="badge-purple">
                    {{ calle.cvepoblacion || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ calle.desvial || 'N/A' }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewCalle(calle)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="selectCalle(calle)"
                      title="Seleccionar calle"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="calles.length === 0 && !loading">
                <td colspan="5" class="text-center text-muted empty-state">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron calles. Use los filtros para buscar o cargue el catálogo completo.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de la Calle: ${selectedCalle?.calle}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedCalle" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="road" />
              Información de la Calle
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Código:</td>
                <td><code>{{ selectedCalle.cvecalle }}</code></td>
              </tr>
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedCalle.calle?.trim() }}</strong></td>
              </tr>
              <tr>
                <td class="label">Población:</td>
                <td>
                  <span class="badge-purple">
                    {{ selectedCalle.cvepoblacion || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Vialidad:</td>
                <td>{{ selectedCalle.desvial || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Vigencia:</td>
                <td>
                  <span :class="selectedCalle.cvevig === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ selectedCalle.cvevig === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
              </tr>
              <tr v-if="selectedCalle.capturista">
                <td class="label">Capturista:</td>
                <td>{{ selectedCalle.capturista }}</td>
              </tr>
              <tr v-if="selectedCalle.feccap">
                <td class="label">Fecha Captura:</td>
                <td>{{ formatDate(selectedCalle.feccap) }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="selectCalle(selectedCalle); showViewModal = false">
            <font-awesome-icon icon="check" />
            Seleccionar Calle
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
      :componentName="'formabuscalle'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
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
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Emits para cuando se usa como componente auxiliar
const emit = defineEmits(['calleSelected'])

// Estado
const calles = ref([])
const selectedCalle = ref(null)
const showViewModal = ref(false)
const showFilters = ref(true)

// Filtros
const filters = ref({
  nombre: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const loadCalles = async () => {
  setLoading(true, 'Cargando catálogo de calles...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_listar_calles',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      calles.value = response.result

      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      toast.value.duration = durationText
      showToast('success', `Se cargaron ${calles.value.length} calles`)
    } else {
      calles.value = []
      showToast('error', 'Error al cargar calles')
    }
  } catch (error) {
    handleApiError(error)
    calles.value = []
  } finally {
    setLoading(false)
  }
}

const searchCalles = async () => {
  if (!filters.value.nombre) {
    await Swal.fire({
      icon: 'warning',
      title: 'Criterio de búsqueda',
      text: 'Por favor ingrese un nombre de calle para buscar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando calles...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_buscar_calles',
      'padron_licencias',
      [
        { nombre: 'filtro', valor: filters.value.nombre, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      calles.value = response.result

      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      if (calles.value.length === 0) {
        showToast('info', 'No se encontraron calles con los criterios especificados')
      } else {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${calles.value.length} calles`)
      }
    } else {
      calles.value = []
      showToast('error', 'Error al buscar calles')
    }
  } catch (error) {
    handleApiError(error)
    calles.value = []
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    nombre: ''
  }
  calles.value = []
  showToast('info', 'Filtros limpiados')
}

const selectCalle = async (calle) => {
  const result = await Swal.fire({
    title: 'Confirmar selección',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">¿Desea seleccionar esta calle?</p>
        <ul class="swal-selection-list">
          <li><strong>Código:</strong> ${calle.cvecalle}</li>
          <li><strong>Nombre:</strong> ${calle.calle?.trim()}</li>
          <li><strong>Población:</strong> ${calle.cvepoblacion || 'N/A'}</li>
        </ul>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, seleccionar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    selectedCalle.value = calle
    emit('calleSelected', calle)
    showToast('success', `Calle "${calle.calle?.trim()}" seleccionada`)

    await Swal.fire({
      icon: 'success',
      title: 'Calle seleccionada',
      text: `Se ha seleccionado la calle "${calle.calle?.trim()}"`,
      confirmButtonColor: '#ea8215',
      timer: 2000
    })
  }
}

const viewCalle = (calle) => {
  selectedCalle.value = calle
  showViewModal.value = true
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch {
    return 'N/A'
  }
}

// Lifecycle
onMounted(() => {
  // NO cargar automáticamente - esperar acción del usuario
})
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
