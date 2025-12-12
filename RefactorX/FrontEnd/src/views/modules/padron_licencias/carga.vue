<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Predios</h1>
        <p>Padrón de Licencias - Sistema de Carga y Edición de Información Predial</p>
      </div>
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
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Predio
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave Catastral</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.claveCatastral"
              placeholder="Ingrese clave catastral"
              @keyup.enter="searchPredios"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Cuenta</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cuenta"
              placeholder="Número de cuenta"
              @keyup.enter="searchPredios"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchPredios"
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
          <span class="badge-purple" v-if="predios.length > 0">{{ predios.length }} registros</span>
        </h5>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Clave Catastral</th>
                <th>Cuenta</th>
                <th>Propietario</th>
                <th>Domicilio</th>
                <th>Superficie</th>
                <th>Valor</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="predio in predios" :key="predio.id" class="clickable-row">
                <td><code class="text-primary">{{ predio.clavecatastral }}</code></td>
                <td>{{ predio.cuenta || 'N/A' }}</td>
                <td>{{ predio.propietario || 'N/A' }}</td>
                <td><small>{{ predio.domicilio || 'N/A' }}</small></td>
                <td>{{ predio.superficie ? `${predio.superficie} m²` : 'N/A' }}</td>
                <td>{{ formatCurrency(predio.valor) }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewPredio(predio)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editPredio(predio)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmDeletePredio(predio)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="predios.length === 0">
                <td colspan="7" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron predios con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && predios.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando información de predios...</p>
      </div>
    </div>

    <!-- Modal de visualización con tabs -->
    <Modal
      :show="showViewModal"
      :title="`Predio: ${selectedPredio?.clavecatastral}`"
      size="xl"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedPredio" class="predio-details">
        <!-- Tabs Navigation -->
        <ul class="nav nav-tabs">
          <li class="nav-item">
            <a
              class="nav-link"
              :class="{ active: activeTab === 'general' }"
              @click="activeTab = 'general'"
            >
              <font-awesome-icon icon="info-circle" />
              Datos Generales
            </a>
          </li>
          <li class="nav-item">
            <a
              class="nav-link"
              :class="{ active: activeTab === 'construcciones' }"
              @click="activeTab = 'construcciones'"
            >
              <font-awesome-icon icon="building" />
              Construcciones
            </a>
          </li>
          <li class="nav-item">
            <a
              class="nav-link"
              :class="{ active: activeTab === 'avaluo' }"
              @click="activeTab = 'avaluo'"
            >
              <font-awesome-icon icon="dollar-sign" />
              Avalúo
            </a>
          </li>
          <li class="nav-item">
            <a
              class="nav-link"
              :class="{ active: activeTab === 'cartografia' }"
              @click="activeTab = 'cartografia'"
            >
              <font-awesome-icon icon="map" />
              Cartografía
            </a>
          </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content">
          <!-- Datos Generales -->
          <div v-show="activeTab === 'general'" class="tab-pane">
            <div class="details-grid">
              <div class="detail-section">
                <table class="detail-table">
                  <tr>
                    <td class="label">Clave Catastral:</td>
                    <td><code>{{ selectedPredio.clavecatastral }}</code></td>
                  </tr>
                  <tr>
                    <td class="label">Cuenta:</td>
                    <td>{{ selectedPredio.cuenta || 'N/A' }}</td>
                  </tr>
                  <tr>
                    <td class="label">Propietario:</td>
                    <td>{{ selectedPredio.propietario || 'N/A' }}</td>
                  </tr>
                  <tr>
                    <td class="label">Domicilio:</td>
                    <td>{{ selectedPredio.domicilio || 'N/A' }}</td>
                  </tr>
                  <tr>
                    <td class="label">Superficie:</td>
                    <td>{{ selectedPredio.superficie ? `${selectedPredio.superficie} m²` : 'N/A' }}</td>
                  </tr>
                  <tr>
                    <td class="label">Valor Catastral:</td>
                    <td>{{ formatCurrency(selectedPredio.valor) }}</td>
                  </tr>
                </table>
              </div>
            </div>
          </div>

          <!-- Construcciones -->
          <div v-show="activeTab === 'construcciones'" class="tab-pane">
            <div v-if="construccionesData && construccionesData.length > 0">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Tipo</th>
                    <th>Superficie</th>
                    <th>Valor</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(construccion, idx) in construccionesData" :key="idx">
                    <td>{{ construccion.tipo || 'N/A' }}</td>
                    <td>{{ construccion.superficie ? `${construccion.superficie} m²` : 'N/A' }}</td>
                    <td>{{ formatCurrency(construccion.valor) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <p v-else class="text-muted text-center">No hay construcciones registradas</p>
          </div>

          <!-- Avalúo -->
          <div v-show="activeTab === 'avaluo'" class="tab-pane">
            <div v-if="avaluoData">
              <table class="detail-table">
                <tr>
                  <td class="label">Valor Terreno:</td>
                  <td>{{ formatCurrency(avaluoData.valorterreno) }}</td>
                </tr>
                <tr>
                  <td class="label">Valor Construcción:</td>
                  <td>{{ formatCurrency(avaluoData.valorconstruccion) }}</td>
                </tr>
                <tr>
                  <td class="label">Valor Total:</td>
                  <td><strong>{{ formatCurrency(avaluoData.valortotal) }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Fecha Avalúo:</td>
                  <td>{{ formatDate(avaluoData.fechaavaluo) }}</td>
                </tr>
              </table>
            </div>
            <p v-else class="text-muted text-center">No hay información de avalúo disponible</p>
          </div>

          <!-- Cartografía -->
          <div v-show="activeTab === 'cartografia'" class="tab-pane">
            <div v-if="cartografiaData">
              <table class="detail-table">
                <tr>
                  <td class="label">Coordenadas:</td>
                  <td>{{ cartografiaData.coordenadas || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Zona:</td>
                  <td>{{ cartografiaData.zona || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Manzana:</td>
                  <td>{{ cartografiaData.manzana || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Lote:</td>
                  <td>{{ cartografiaData.lote || 'N/A' }}</td>
                </tr>
              </table>
            </div>
            <p v-else class="text-muted text-center">No hay información cartográfica disponible</p>
          </div>
        </div>

        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </Modal>

    <!-- Toast Notifications -->
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
      :componentName="'carga'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'


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
const predios = ref([])
const selectedPredio = ref(null)
const showViewModal = ref(false)
const activeTab = ref('general')
const construccionesData = ref([])
const avaluoData = ref(null)
const cartografiaData = ref(null)

// Filtros
const filters = ref({
  claveCatastral: '',
  cuenta: '',
  propietario: ''
})

// Métodos
const searchPredios = async () => {
  setLoading(true, 'Buscando predios...')

  try {
    const response = await execute(
      'CARGA_SEARCH_PREDIO',
      'padron_licencias',
      [
        { nombre: 'p_clavecatastral', valor: filters.value.claveCatastral || null, tipo: 'string' },
        { nombre: 'p_cuenta', valor: filters.value.cuenta || null, tipo: 'string' },
        { nombre: 'p_propietario', valor: filters.value.propietario || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      predios.value = response.result
      showToast('success', `Se encontraron ${response.result.length} predios`)
    } else {
      predios.value = []
      showToast('warning', 'No se encontraron predios')
    }
  } catch (error) {
    handleApiError(error)
    predios.value = []
  } finally {
    setLoading(false)
  }
}

const viewPredio = async (predio) => {
  selectedPredio.value = predio
  activeTab.value = 'general'
  showViewModal.value = true

  // Cargar información adicional
  await loadPredioDetails(predio.clavecatastral)
}

const loadPredioDetails = async (claveCatastral) => {
  setLoading(true, 'Cargando detalles...')

  try {
    // Cargar construcciones
    const constResponse = await execute(
      'GET_CONSTRUCCIONES',
      'padron_licencias',
      [{ nombre: 'p_clavecatastral', valor: claveCatastral, tipo: 'string' }],
      'guadalajara',
      null,
      'publico'
    )
    construccionesData.value = constResponse?.result || []

    // Cargar avalúo
    const avaluoResponse = await execute(
      'GET_AVALUO',
      'padron_licencias',
      [{ nombre: 'p_clavecatastral', valor: claveCatastral, tipo: 'string' }],
      'guadalajara',
      null,
      'publico'
    )
    avaluoData.value = avaluoResponse?.result?.[0] || null

    // Cargar cartografía
    const cartoResponse = await execute(
      'GET_CARTOGRAFIA_PREDIAL',
      'padron_licencias',
      [{ nombre: 'p_clavecatastral', valor: claveCatastral, tipo: 'string' }],
      'guadalajara',
      null,
      'publico'
    )
    cartografiaData.value = cartoResponse?.result?.[0] || null
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const editPredio = (predio) => {
  showToast('info', 'Función de edición en desarrollo')
}

const confirmDeletePredio = async (predio) => {
  const result = await Swal.fire({
    title: '¿Eliminar predio?',
    text: `¿Está seguro de eliminar el predio ${predio.clavecatastral}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deletePredio(predio)
  }
}

const deletePredio = async (predio) => {
  setLoading(true, 'Eliminando predio...')

  try {
    const response = await execute(
      'CARGA_DELETE_PREDIO',
      'padron_licencias',
      [{ nombre: 'p_clavecatastral', valor: predio.clavecatastral, tipo: 'string' }],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result?.[0]?.success) {
      showToast('success', 'Predio eliminado exitosamente')
      await searchPredios()
    } else {
      showToast('error', 'Error al eliminar el predio')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const openCreateModal = () => {
  showToast('info', 'Función de creación en desarrollo')
}

const clearFilters = () => {
  filters.value = {
    claveCatastral: '',
    cuenta: '',
    propietario: ''
  }
  predios.value = []
}

// Utilidades
const formatCurrency = (value) => {
  if (!value) return 'N/A'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
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
  } catch {
    return 'Fecha inválida'
  }
}
</script>

<style scoped>
.nav-tabs {
  display: flex;
  list-style: none;
  padding: 0;
  margin: 0 0 20px 0;
  border-bottom: 2px solid #dee2e6;
}

.nav-item {
  margin-right: 5px;
}

.nav-link {
  display: block;
  padding: 10px 20px;
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-bottom: none;
  cursor: pointer;
  text-decoration: none;
  color: #495057;
  border-radius: 5px 5px 0 0;
}

.nav-link:hover {
  background: #e9ecef;
}

.nav-link.active {
  background: white;
  color: #ea8215;
  border-color: #dee2e6;
  font-weight: 600;
}

.tab-content {
  padding: 20px;
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 0 5px 5px 5px;
  min-height: 300px;
}

.tab-pane {
  animation: fadeIn 0.3s;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
</style>
