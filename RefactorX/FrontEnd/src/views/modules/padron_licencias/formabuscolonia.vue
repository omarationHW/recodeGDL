<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Colonias</h1>
        <p>Padrón de Licencias - Formulario auxiliar para búsqueda y selección de colonias</p></div>
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
          <div class="form-group">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filters.zona">
              <option value="">Todas las zonas</option>
              <option value="NORTE">Norte</option>
              <option value="SUR">Sur</option>
              <option value="ESTE">Este</option>
              <option value="OESTE">Oeste</option>
              <option value="CENTRO">Centro</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchColonias"
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
            @click="loadColonias"
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
          <span class="badge-info" v-if="colonias.length > 0">{{ colonias.length }} colonias</span>
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
                <th>Nombre de la Colonia</th>
                <th>Código Postal</th>
                <th>Zona</th>
                <th>Municipio</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="colonia in colonias" :key="colonia.codigo" class="row-hover">
                <td>
                  <span class="badge-secondary">
                    {{ colonia.codigo }}
                  </span>
                </td>
                <td><strong class="text-primary">{{ colonia.nombre?.trim() }}</strong></td>
                <td>
                  <code class="text-info">
                    {{ colonia.cp || 'N/A' }}
                  </code>
                </td>
                <td>
                  <span class="badge-info">
                    <font-awesome-icon icon="map-marker-alt" />
                    {{ colonia.zona?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    {{ colonia.municipio?.trim() || 'N/A' }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="selectColonia(colonia)"
                      title="Seleccionar colonia"
                    >
                      <font-awesome-icon icon="check" />
                      Seleccionar
                    </button>
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewColonia(colonia)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="colonias.length === 0 && !loading">
                <td colspan="6" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron colonias con los criterios especificados</p>
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
      :title="`Detalles de la Colonia: ${selectedColonia?.nombre}`"
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
                <td class="label">Código:</td>
                <td><code>{{ selectedColonia.codigo }}</code></td>
              </tr>
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedColonia.nombre?.trim() }}</strong></td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td>
                  <code class="text-info">
                    {{ selectedColonia.cp || 'N/A' }}
                  </code>
                </td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>
                  <span class="badge-info">
                    <font-awesome-icon icon="map-marker-alt" />
                    {{ selectedColonia.zona?.trim() || 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Municipio:</td>
                <td>{{ selectedColonia.municipio?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Localidad:</td>
                <td>{{ selectedColonia.localidad?.trim() || 'N/A' }}</td>
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
      :componentName="'formabuscolonia'"
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
const emit = defineEmits(['coloniaSelected'])

// Estado
const colonias = ref([])
const selectedColonia = ref(null)
const showViewModal = ref(false)

// Filtros
const filters = ref({
  nombre: '',
  cp: '',
  zona: ''
})

// Métodos
const loadColonias = async () => {
  setLoading(true, 'Cargando catálogo de colonias...')

  try {
    const response = await execute(
      'formabuscolonia_sp_listar_colonias',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      colonias.value = response.result
      showToast('success', 'Colonias cargadas correctamente')
    } else {
      colonias.value = []
      showToast('error', 'Error al cargar colonias')
    }
  } catch (error) {
    handleApiError(error)
    colonias.value = []
  } finally {
    setLoading(false)
  }
}

const searchColonias = async () => {
  if (!filters.value.nombre && !filters.value.cp && !filters.value.zona) {
    await Swal.fire({
      icon: 'warning',
      title: 'Criterios de búsqueda',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando colonias...')

  try {
    const response = await execute(
      'formabuscolonia_sp_buscar_colonias',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: filters.value.nombre || null, tipo: 'string' },
        { nombre: 'p_cp', valor: filters.value.cp || null, tipo: 'string' },
        { nombre: 'p_zona', valor: filters.value.zona || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      colonias.value = response.result
      if (colonias.value.length === 0) {
        showToast('info', 'No se encontraron colonias con los criterios especificados')
      } else {
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
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    nombre: '',
    cp: '',
    zona: ''
  }
  loadColonias()
}

const selectColonia = async (colonia) => {
  // Primero obtener los detalles completos de la colonia seleccionada
  try {
    setLoading(true, 'Obteniendo detalles de la colonia...')

    const response = await execute(
      'formabuscolonia_sp_obtener_colonia_seleccionada',
      'padron_licencias',
      [
        { nombre: 'p_codigo', valor: colonia.codigo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const coloniaCompleta = response.result[0]

      const result = await Swal.fire({
        title: 'Confirmar selección',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p style="margin-bottom: 10px;">¿Desea seleccionar esta colonia?</p>
            <ul style="list-style: none; padding: 0;">
              <li style="margin: 5px 0;"><strong>Código:</strong> ${coloniaCompleta.codigo}</li>
              <li style="margin: 5px 0;"><strong>Nombre:</strong> ${coloniaCompleta.nombre?.trim()}</li>
              <li style="margin: 5px 0;"><strong>CP:</strong> ${coloniaCompleta.cp || 'N/A'}</li>
              <li style="margin: 5px 0;"><strong>Zona:</strong> ${coloniaCompleta.zona?.trim() || 'N/A'}</li>
              <li style="margin: 5px 0;"><strong>Municipio:</strong> ${coloniaCompleta.municipio?.trim() || 'N/A'}</li>
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
        showToast('success', `Colonia "${coloniaCompleta.nombre?.trim()}" seleccionada`)

        await Swal.fire({
          icon: 'success',
          title: 'Colonia seleccionada',
          text: `Se ha seleccionado la colonia "${coloniaCompleta.nombre?.trim()}"`,
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
    setLoading(false)
  }
}

const viewColonia = (colonia) => {
  selectedColonia.value = colonia
  showViewModal.value = true
}

// Lifecycle
onMounted(() => {
  loadColonias()
})
</script>
