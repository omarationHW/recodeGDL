<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-signs" />
      </div>
      <div class="module-view-info">
        <h1>Selección de Calles</h1>
        <p>Padrón de Licencias - Selector avanzado de calles con autocompletado</p>
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

    <!-- Búsqueda avanzada -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search-location" />
          Búsqueda Avanzada de Calles
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Buscar Calle</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="searchQuery"
              placeholder="Escriba el nombre de la calle..."
              @input="onSearchInput"
              @keyup.enter="searchCalles"
            >
            <!-- Autocompletado -->
            <div v-if="suggestions.length > 0" class="autocomplete-dropdown">
              <div
                v-for="suggestion in suggestions"
                :key="suggestion.codigo"
                class="autocomplete-item"
                @click="selectFromSuggestion(suggestion)"
              >
                <div class="suggestion-main">
                  <font-awesome-icon icon="road" class="text-primary" />
                  <strong>{{ suggestion.nombre?.trim() }}</strong>
                  <span class="badge-secondary">{{ suggestion.tipo?.trim() }}</span>
                </div>
                <div class="suggestion-info">
                  <small class="text-muted">{{ suggestion.colonia?.trim() }} - CP: {{ suggestion.cp }}</small>
                </div>
              </div>
            </div>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Calle Entre 1</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.entre1"
              placeholder="Calle cruce 1"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Calle Entre 2</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.entre2"
              placeholder="Calle cruce 2"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchCalles"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSearch"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Calle seleccionada -->
    <div v-if="selectedCalle" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" class="text-success" />
          Calle Seleccionada
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="selected-calle-card">
          <div class="selected-info">
            <div class="info-row">
              <span class="info-label">Código:</span>
              <span class="info-value"><code>{{ selectedCalle.codigo }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Nombre:</span>
              <span class="info-value"><strong>{{ selectedCalle.nombre?.trim() }}</strong></span>
            </div>
            <div class="info-row">
              <span class="info-label">Tipo:</span>
              <span class="info-value">
                <span class="badge-purple">{{ selectedCalle.tipo?.trim() }}</span>
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">Colonia:</span>
              <span class="info-value">{{ selectedCalle.colonia?.trim() || 'N/A' }}</span>
            </div>
            <div class="info-row" v-if="selectedCalle.cp">
              <span class="info-label">CP:</span>
              <span class="info-value"><code>{{ selectedCalle.cp }}</code></span>
            </div>
          </div>
          <div class="selected-actions">
            <button
              class="btn-municipal-primary"
              @click="confirmSelection"
            >
              <font-awesome-icon icon="check" />
              Confirmar Selección
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearSelection"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información de cruces -->
    <div v-if="selectedCalle && (filters.entre1 || filters.entre2)" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="exchange-alt" />
          Información de Cruces
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="cruces-info">
          <div class="cruce-item" v-if="filters.entre1">
            <font-awesome-icon icon="arrow-right" class="text-primary" />
            <span><strong>Entre:</strong> {{ filters.entre1 }}</span>
          </div>
          <div class="cruce-item" v-if="filters.entre2">
            <font-awesome-icon icon="arrow-left" class="text-primary" />
            <span><strong>Y:</strong> {{ filters.entre2 }}</span>
          </div>
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
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="calles.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="search-location" size="3x" />
          </div>
          <h4>Búsqueda de Calles</h4>
          <p>Utilice el buscador para encontrar calles. Puede buscar por nombre o aplicar filtros adicionales.</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="calles.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron calles con los criterios especificados</p>
        </div>

        <!-- Tabla con resultados -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Código</th>
                <th>Nombre</th>
                <th>Tipo</th>
                <th>Colonia</th>
                <th>CP</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="calle in calles"
                :key="calle.codigo"
                @click="selectedRow = calle"
                :class="{ 'table-row-selected': selectedRow === calle }"
                class="row-hover"
              >
                <td>
                  <span class="badge-secondary">{{ calle.codigo }}</span>
                </td>
                <td><strong class="text-primary">{{ calle.nombre?.trim() }}</strong></td>
                <td>
                  <span class="badge-purple">{{ calle.tipo?.trim() || 'N/A' }}</span>
                </td>
                <td>
                  <small class="text-muted">{{ calle.colonia?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <code class="text-info">{{ calle.cp || 'N/A' }}</code>
                </td>
                <td>
                  <button
                    class="btn-municipal-primary btn-sm"
                    @click.stop="selectCalle(calle)"
                    title="Seleccionar calle"
                  >
                    <font-awesome-icon icon="hand-pointer" />
                    Seleccionar
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
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
      :componentName="'frmselcalle'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Selección de Calles'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
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
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Emits
const emit = defineEmits(['calleSelected', 'calleConfirmed'])

// Estado
const calles = ref([])
const selectedCalle = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
const searchQuery = ref('')
const suggestions = ref([])
let searchTimeout = null

// Filtros
const filters = ref({
  entre1: '',
  entre2: ''
})

// Métodos
const onSearchInput = () => {
  // Debounce para autocompletado
  if (searchTimeout) {
    clearTimeout(searchTimeout)
  }

  if (searchQuery.value.length >= 3) {
    searchTimeout = setTimeout(() => {
      loadSuggestions()
    }, 500)
  } else {
    suggestions.value = []
  }
}

const loadSuggestions = async () => {
  try {
    const response = await execute(
      'sp_frmselcalle_get_calles',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: searchQuery.value, tipo: 'string' },
        { nombre: 'p_limit', valor: 10, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      suggestions.value = response.result
    }
  } catch {
    suggestions.value = []
  }
}

const selectFromSuggestion = (suggestion) => {
  selectedCalle.value = suggestion
  searchQuery.value = suggestion.nombre?.trim()
  suggestions.value = []
  showToast('info', `Calle "${suggestion.nombre?.trim()}" seleccionada`)
  emit('calleSelected', suggestion)
}

const searchCalles = async () => {
  if (!searchQuery.value && !filters.value.entre1 && !filters.value.entre2) {
    await Swal.fire({
      icon: 'warning',
      title: 'Criterios de búsqueda',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Buscando calles...', 'Procesando solicitud')
  hasSearched.value = true
  selectedRow.value = null
  suggestions.value = []

  try {
    const response = await execute(
      'sp_frmselcalle_get_calles',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: searchQuery.value || null, tipo: 'string' },
        { nombre: 'p_limit', valor: 100, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      calles.value = response.result
      if (calles.value.length === 0) {
        showToast('info', 'No se encontraron calles con los criterios especificados')
      } else {
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
    hideLoading()
  }
}

const selectCalle = async (calle) => {
  // Obtener detalles completos por ID
  try {
    showLoading('Obteniendo detalles de la calle...', 'Procesando solicitud')

    const response = await execute(
      'sp_frmselcalle_get_calle_by_ids',
      'padron_licencias',
      [
        { nombre: 'p_codigo', valor: calle.codigo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      selectedCalle.value = response.result[0]
      searchQuery.value = selectedCalle.value.nombre?.trim()
      showToast('success', `Calle "${selectedCalle.value.nombre?.trim()}" seleccionada`)
      emit('calleSelected', selectedCalle.value)
    } else {
      selectedCalle.value = calle
      searchQuery.value = calle.nombre?.trim()
      showToast('success', `Calle "${calle.nombre?.trim()}" seleccionada`)
      emit('calleSelected', calle)
    }
  } catch (error) {
    handleApiError(error)
    selectedCalle.value = calle
    searchQuery.value = calle.nombre?.trim()
  } finally {
    hideLoading()
  }
}

const confirmSelection = async () => {
  if (!selectedCalle.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Selección requerida',
      text: 'Por favor seleccione una calle antes de confirmar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const cruceInfo = []
  if (filters.value.entre1) cruceInfo.push(`<li><strong>Entre:</strong> ${filters.value.entre1}</li>`)
  if (filters.value.entre2) cruceInfo.push(`<li><strong>Y:</strong> ${filters.value.entre2}</li>`)

  const result = await Swal.fire({
    title: 'Confirmar selección de calle',
    html: `
      <div class="swal-selection-content">
        <p class="swal-confirmation-text">¿Desea confirmar la siguiente selección?</p>
        <ul class="swal-list">
          <li><strong>Calle:</strong> ${selectedCalle.value.nombre?.trim()}</li>
          <li><strong>Tipo:</strong> ${selectedCalle.value.tipo?.trim()}</li>
          <li><strong>Colonia:</strong> ${selectedCalle.value.colonia?.trim() || 'N/A'}</li>
          ${cruceInfo.length > 0 ? '<br><strong>Cruces:</strong>' : ''}
          ${cruceInfo.join('')}
        </ul>
      </div>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, confirmar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    const selectionData = {
      calle: selectedCalle.value,
      entre1: filters.value.entre1,
      entre2: filters.value.entre2
    }

    emit('calleConfirmed', selectionData)

    await Swal.fire({
      icon: 'success',
      title: 'Calle confirmada',
      text: `La calle "${selectedCalle.value.nombre?.trim()}" ha sido confirmada`,
      confirmButtonColor: '#ea8215',
      timer: 2000
    })

    showToast('success', 'Selección confirmada exitosamente')
  }
}

const clearSelection = () => {
  selectedCalle.value = null
  searchQuery.value = ''
  suggestions.value = []
  showToast('info', 'Selección cancelada')
}

const clearSearch = () => {
  searchQuery.value = ''
  filters.value = {
    entre1: '',
    entre2: ''
  }
  suggestions.value = []
  selectedCalle.value = null
  calles.value = []
  hasSearched.value = false
  selectedRow.value = null
  showToast('info', 'Búsqueda limpiada')
}

// Lifecycle
onMounted(() => {
  // No cargar nada automáticamente
})
</script>

