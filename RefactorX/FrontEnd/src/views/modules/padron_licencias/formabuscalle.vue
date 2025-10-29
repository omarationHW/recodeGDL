<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="road" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Calles</h1>
        <p>Padrón de Licencias - Formulario auxiliar para búsqueda y selección de calles</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre de la Calle</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.nombre"
              placeholder="Ingrese el nombre de la calle"
              @keyup.enter="searchCalles"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Código</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.codigo"
              placeholder="Código de calle"
              @keyup.enter="searchCalles"
            >
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
          Resultados de Búsqueda
          <span class="badge-info" v-if="calles.length > 0">{{ calles.length }} calles</span>
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
                <th>Código</th>
                <th>Nombre de la Calle</th>
                <th>Tipo</th>
                <th>Colonia</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="calle in calles" :key="calle.codigo" class="row-hover">
                <td>
                  <span class="badge-secondary">
                    {{ calle.codigo }}
                  </span>
                </td>
                <td><strong class="text-primary">{{ calle.nombre?.trim() }}</strong></td>
                <td>
                  <span class="badge-info">
                    {{ calle.tipo?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ calle.colonia?.trim() || 'N/A' }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="selectCalle(calle)"
                      title="Seleccionar calle"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewCalle(calle)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="calles.length === 0 && !loading">
                <td colspan="5" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron calles con los criterios especificados</p>
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
      :title="`Detalles de la Calle: ${selectedCalle?.nombre}`"
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
                <td><code>{{ selectedCalle.codigo }}</code></td>
              </tr>
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedCalle.nombre?.trim() }}</strong></td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge-info">
                    {{ selectedCalle.tipo?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedCalle.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CP:</td>
                <td>{{ selectedCalle.cp || 'N/A' }}</td>
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

// Filtros
const filters = ref({
  nombre: '',
  codigo: ''
})

// Métodos
const loadCalles = async () => {
  setLoading(true, 'Cargando catálogo de calles...')

  try {
    const response = await execute(
      'formabuscalle_sp_listar_calles',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      calles.value = response.result
      showToast('success', 'Calles cargadas correctamente')
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
  if (!filters.value.nombre && !filters.value.codigo) {
    await Swal.fire({
      icon: 'warning',
      title: 'Criterios de búsqueda',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando calles...')

  try {
    const response = await execute(
      'formabuscalle_sp_buscar_calles',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: filters.value.nombre || null, tipo: 'string' },
        { nombre: 'p_codigo', valor: filters.value.codigo || null, tipo: 'string' }
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
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    nombre: '',
    codigo: ''
  }
  loadCalles()
}

const selectCalle = async (calle) => {
  const result = await Swal.fire({
    title: 'Confirmar selección',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">¿Desea seleccionar esta calle?</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Código:</strong> ${calle.codigo}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${calle.nombre?.trim()}</li>
          <li style="margin: 5px 0;"><strong>Tipo:</strong> ${calle.tipo?.trim() || 'N/A'}</li>
          <li style="margin: 5px 0;"><strong>Colonia:</strong> ${calle.colonia?.trim() || 'N/A'}</li>
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
    showToast('success', `Calle "${calle.nombre?.trim()}" seleccionada`)

    await Swal.fire({
      icon: 'success',
      title: 'Calle seleccionada',
      text: `Se ha seleccionado la calle "${calle.nombre?.trim()}"`,
      confirmButtonColor: '#ea8215',
      timer: 2000
    })
  }
}

const viewCalle = (calle) => {
  selectedCalle.value = calle
  showViewModal.value = true
}

// Lifecycle
onMounted(() => {
  loadCalles()
})
</script>
