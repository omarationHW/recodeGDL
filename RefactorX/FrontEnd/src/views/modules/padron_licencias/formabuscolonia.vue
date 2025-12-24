<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Colonias</h1>
        <p>Padrón de Licencias - Formulario auxiliar para búsqueda y selección de colonias</p>
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
            <label class="municipal-form-label">Nombre de la Colonia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Ingrese el nombre de la colonia"
              @keyup.enter="searchColonias"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Código Postal</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cp"
              placeholder="CP"
              maxlength="5"
              @keyup.enter="searchColonias"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchColonias"
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
          <button
            class="btn-municipal-secondary"
            @click="loadColonias"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
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
          <span class="badge-purple" v-if="colonias.length > 0">
            {{ colonias.length }} colonias
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="colonias.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="map-marked-alt" size="3x" />
          </div>
          <h4>Búsqueda de Colonias</h4>
          <p>Ingresa los criterios de búsqueda para encontrar colonias</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="colonias.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron colonias con los criterios especificados</p>
        </div>

        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Colonia/Asentamiento</th>
                <th>Código Postal</th>
                <th>Tipo Asentamiento</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(colonia, idx) in colonias"
                :key="idx"
                @click="selectedRow = colonia"
                :class="{ 'table-row-selected': selectedRow === colonia }"
                class="row-hover"
              >
                <td>
                  <strong class="text-primary">{{ colonia.colonia?.trim() }}</strong>
                </td>
                <td>
                  <code class="text-info">
                    {{ colonia.d_codigopostal || 'N/A' }}
                  </code>
                </td>
                <td>
                  <span class="badge-purple">
                    {{ colonia.d_tipo_asenta?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="selectColonia(colonia)"
                      title="Seleccionar colonia"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewColonia(colonia)"
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
      </div>
    </div>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de la Colonia: ${selectedColonia?.colonia}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedColonia" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marked-alt" />
              Información de la Colonia
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Colonia:</td>
                <td><strong>{{ selectedColonia.colonia?.trim() }}</strong></td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td>
                  <code class="text-info">
                    {{ selectedColonia.d_codigopostal || 'N/A' }}
                  </code>
                </td>
              </tr>
              <tr>
                <td class="label">Tipo de Asentamiento:</td>
                <td>
                  <span class="badge-purple">
                    {{ selectedColonia.d_tipo_asenta?.trim() || 'N/A' }}
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
          <button class="btn-municipal-primary" @click="selectColonia(selectedColonia); showViewModal = false">
            <font-awesome-icon icon="check" />
            Seleccionar Colonia
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

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'formabuscolonia'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Búsqueda de Colonias'"
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
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'
import { appConfig } from '@/config/app.config'

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

// Emits para cuando se usa como componente auxiliar
const emit = defineEmits(['coloniaSelected'])

// Estado
const colonias = ref([])
const selectedColonia = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
const showViewModal = ref(false)
const showFilters = ref(true)

// Filtros
const filters = ref({
  nombre: '',
  cp: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const loadColonias = async () => {
  showLoading('Cargando catálogo de colonias...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_listar_colonias',
      'padron_licencias',
      [
        { nombre: 'p_c_mnpio', valor: appConfig.municipioId, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      colonias.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${colonias.value.length} colonias`)
    } else {
      colonias.value = []
      showToast('error', 'Error al cargar colonias')
    }
  } catch (error) {
    handleApiError(error)
    colonias.value = []
  } finally {
    hideLoading()
  }
}

const searchColonias = async () => {
  if (!filters.value.nombre && !filters.value.cp) {
    await Swal.fire({
      icon: 'warning',
      title: 'Criterios de búsqueda',
      text: 'Por favor ingrese al menos un criterio de búsqueda (nombre o código postal)',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  showLoading('Buscando colonias...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    // Construir el filtro de búsqueda combinado
    const searchTerm = filters.value.nombre || filters.value.cp

    const response = await execute(
      'sp_buscar_colonias',
      'padron_licencias',
      [
        { nombre: 'p_c_mnpio', valor: appConfig.municipioId, tipo: 'integer' },
        { nombre: 'p_filtro', valor: searchTerm || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      colonias.value = response.result

      if (colonias.value.length === 0) {
        showToast('info', 'No se encontraron colonias con los criterios especificados')
      } else {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${colonias.value.length} colonias`)
      }
    } else {
      colonias.value = []
      showToast('error', 'Error al buscar colonias')
    }
  } catch (error) {
    handleApiError(error)
    colonias.value = []
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    nombre: '',
    cp: ''
  }
  colonias.value = []
  hasSearched.value = false
  selectedRow.value = null
}

const selectColonia = async (colonia) => {
  // Primero obtener los detalles completos de la colonia seleccionada
  try {
    showLoading('Obteniendo detalles de la colonia...')

    const response = await execute(
      'sp_obtener_colonia_seleccionada',
      'padron_licencias',
      [
        { nombre: 'p_c_mnpio', valor: appConfig.municipioId, tipo: 'integer' },
        { nombre: 'p_colonia', valor: colonia.colonia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const coloniaCompleta = response.result[0]

      const result = await Swal.fire({
        title: 'Confirmar selección',
        html: `
          <div class="swal-selection-content">
            <p class="swal-selection-text">¿Desea seleccionar esta colonia?</p>
            <ul class="swal-selection-list">
              <li><strong>Colonia:</strong> ${coloniaCompleta.colonia?.trim()}</li>
              <li><strong>CP:</strong> ${coloniaCompleta.d_codigopostal || 'N/A'}</li>
              <li><strong>Tipo:</strong> ${coloniaCompleta.d_tipo_asenta?.trim() || 'N/A'}</li>
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
        selectedColonia.value = coloniaCompleta
        emit('coloniaSelected', coloniaCompleta)
        showToast('success', `Colonia "${coloniaCompleta.colonia?.trim()}" seleccionada`)

        await Swal.fire({
          icon: 'success',
          title: 'Colonia seleccionada',
          text: `Se ha seleccionado la colonia "${coloniaCompleta.colonia?.trim()}"`,
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
      }
    } else {
      showToast('error', 'No se pudieron obtener los detalles de la colonia')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const viewColonia = (colonia) => {
  selectedColonia.value = colonia
  showViewModal.value = true
}

// Lifecycle
onMounted(() => {
  // No cargar automáticamente, esperar que el usuario haga búsqueda
  // loadColonias()
})
</script>
