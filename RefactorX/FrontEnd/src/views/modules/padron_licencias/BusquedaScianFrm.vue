<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda SCIAN</h1>
        <p>Padrón de Licencias - Búsqueda de Códigos SCIAN</p></div>
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
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="filter" />
          Criterios de Búsqueda
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Código SCIAN</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.codigo"
              placeholder="Buscar por código"
              @keyup.enter="searchScian"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="searchScian"
            >
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
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
          <span class="badge-info" v-if="scianes.length > 0">{{ scianes.length }} registros</span>
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
                <th>Descripción</th>
                <th>Nivel</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="scian in scianes" :key="scian.codigo" class="row-hover">
                <td><strong class="text-primary"><code>{{ scian.codigo }}</code></strong></td>
                <td>{{ scian.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getNivelBadgeClass(scian.nivel)">
                    <font-awesome-icon icon="layer-group" />
                    Nivel {{ scian.nivel || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewScian(scian)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="selectScian(scian)"
                      title="Seleccionar código SCIAN"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="scianes.length === 0 && !loading">
                <td colspan="4" class="text-center text-muted">
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
              <span class="info-value"><code>{{ scianSeleccionado.codigo }}</code></span>
            </div>
            <div class="info-row">
              <span class="info-label">Descripción:</span>
              <span class="info-value">{{ scianSeleccionado.descripcion?.trim() }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Nivel:</span>
              <span class="info-value">
                <span class="badge" :class="getNivelBadgeClass(scianSeleccionado.nivel)">
                  <font-awesome-icon icon="layer-group" />
                  Nivel {{ scianSeleccionado.nivel }}
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
      :title="`Detalles del Código SCIAN: ${selectedScian?.codigo}`"
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
                <td><code>{{ selectedScian.codigo }}</code></td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ selectedScian.descripcion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Nivel:</td>
                <td>
                  <span class="badge" :class="getNivelBadgeClass(selectedScian.nivel)">
                    <font-awesome-icon icon="layer-group" />
                    Nivel {{ selectedScian.nivel || 'N/A' }}
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
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
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

// Filtros
const filters = ref({
  codigo: '',
  descripcion: ''
})

// Métodos
const searchScian = async () => {
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

  try {
    // Si hay código, buscar por código específico, sino buscar por descripción
    const operacion = filters.value.codigo ? 'CATALOGO_SCIAN_GET_BY_ID' : 'CATALOGO_SCIAN_BUSQUEDA'
    const parametros = []

    if (filters.value.codigo) {
      parametros.push({ nombre: 'p_codigo', valor: filters.value.codigo, tipo: 'string' })
    }
    if (filters.value.descripcion) {
      parametros.push({ nombre: 'p_descripcion', valor: filters.value.descripcion, tipo: 'string' })
    }

    const response = await execute(
      operacion,
      'padron_licencias',
      parametros,
      'guadalajara'
    )

    if (response && response.result) {
      scianes.value = response.result
      if (scianes.value.length > 0) {
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
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Ha seleccionado el siguiente código SCIAN:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Código:</strong> ${scian.codigo}</li>
          <li style="margin: 5px 0;"><strong>Descripción:</strong> ${scian.descripcion?.trim()}</li>
          <li style="margin: 5px 0;"><strong>Nivel:</strong> ${scian.nivel}</li>
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
const getNivelBadgeClass = (nivel) => {
  const classes = {
    1: 'badge-primary',
    2: 'badge-info',
    3: 'badge-success',
    4: 'badge-warning',
    5: 'badge-secondary'
  }
  return classes[nivel] || 'badge-secondary'
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  showViewModal.value = false
})
</script>
