<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda General</h1>
        <p>Padrón de Licencias - Búsqueda Multicritero</p>
      </div>
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

    <!-- Pestañas de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <ul class="nav nav-tabs municipal-tabs">
          <li class="nav-item">
            <button
              class="nav-link"
              :class="{ active: activeTab === 'owner' }"
              @click="changeTab('owner')"
            >
              <font-awesome-icon icon="user" />
              Por Propietario
            </button>
          </li>
          <li class="nav-item">
            <button
              class="nav-link"
              :class="{ active: activeTab === 'location' }"
              @click="changeTab('location')"
            >
              <font-awesome-icon icon="map-marker-alt" />
              Por Ubicación
            </button>
          </li>
          <li class="nav-item">
            <button
              class="nav-link"
              :class="{ active: activeTab === 'account' }"
              @click="changeTab('account')"
            >
              <font-awesome-icon icon="file-invoice" />
              Por Cuenta
            </button>
          </li>
          <li class="nav-item">
            <button
              class="nav-link"
              :class="{ active: activeTab === 'rfc' }"
              @click="changeTab('rfc')"
            >
              <font-awesome-icon icon="id-card" />
              Por RFC
            </button>
          </li>
          <li class="nav-item">
            <button
              class="nav-link"
              :class="{ active: activeTab === 'cadastral' }"
              @click="changeTab('cadastral')"
            >
              <font-awesome-icon icon="key" />
              Por Clave Catastral
            </button>
          </li>
        </ul>
      </div>
    </div>

    <!-- Formulario de búsqueda por Propietario -->
    <div class="municipal-card" v-if="activeTab === 'owner'">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="user" />
          Búsqueda por Propietario
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre del Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.owner.nombre"
              placeholder="Ingrese nombre del propietario"
              @keyup.enter="searchByOwner"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Apellido Paterno</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.owner.apellido_paterno"
              placeholder="Apellido paterno"
              @keyup.enter="searchByOwner"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Apellido Materno</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.owner.apellido_materno"
              placeholder="Apellido materno"
              @keyup.enter="searchByOwner"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByOwner"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearOwnerFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda por Ubicación -->
    <div class="municipal-card" v-if="activeTab === 'location'">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="map-marker-alt" />
          Búsqueda por Ubicación
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Calle</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.location.calle"
              placeholder="Nombre de la calle"
              @keyup.enter="searchByLocation"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Número</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.location.numero"
              placeholder="Número"
              @keyup.enter="searchByLocation"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Colonia</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.location.colonia"
              placeholder="Colonia"
              @keyup.enter="searchByLocation"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByLocation"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearLocationFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda por Cuenta -->
    <div class="municipal-card" v-if="activeTab === 'account'">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-invoice" />
          Búsqueda por Cuenta
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Cuenta</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.account.cuenta"
              placeholder="Ingrese número de cuenta"
              @keyup.enter="searchByAccount"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByAccount"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearAccountFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda por RFC -->
    <div class="municipal-card" v-if="activeTab === 'rfc'">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="id-card" />
          Búsqueda por RFC
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc.rfc"
              placeholder="Ingrese RFC"
              maxlength="13"
              @keyup.enter="searchByRfc"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByRfc"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearRfcFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Formulario de búsqueda por Clave Catastral -->
    <div class="municipal-card" v-if="activeTab === 'cadastral'">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="key" />
          Búsqueda por Clave Catastral
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave Catastral</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cadastral.clave"
              placeholder="Ingrese clave catastral"
              @keyup.enter="searchByCadastral"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByCadastral"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearCadastralFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados unificada -->
    <div class="municipal-card" v-if="resultados.length > 0 || hasSearched">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
        </h5>
        <div class="header-actions">
          <span class="badge-purple" v-if="resultados.length > 0">{{ resultados.length }} registros</span>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Cuenta</th>
                <th>RFC</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(resultado, index) in resultados" :key="index" class="clickable-row">
                <td><strong class="text-primary">{{ resultado.id || 'N/A' }}</strong></td>
                <td>{{ resultado.propietario?.trim() || 'N/A' }}</td>
                <td>
                  <small class="text-muted">
                    {{ resultado.direccion?.trim() || 'N/A' }}
                  </small>
                </td>
                <td><code>{{ resultado.cuenta?.trim() || 'N/A' }}</code></td>
                <td><code class="text-muted">{{ resultado.rfc?.trim() || 'N/A' }}</code></td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewDetalle(resultado)"
                      title="Ver detalles completos"
                    >
                      <font-awesome-icon icon="eye" />
                      Ver Detalle
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="resultados.length === 0 && !loading && hasSearched">
                <td colspan="6" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron resultados con los criterios especificados</p>
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

    <!-- Modal de detalle completo -->
    <Modal
      :show="showDetailModal"
      :title="`Detalle Completo - ${selectedResultado?.propietario}`"
      size="xl"
      @close="showDetailModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="detailData" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Información del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID:</td>
                <td><code>{{ detailData.id || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ detailData.propietario?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code class="text-muted">{{ detailData.rfc?.trim() || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Información de Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Dirección:</td>
                <td>{{ detailData.direccion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ detailData.colonia?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Clave Catastral:</td>
                <td><code>{{ detailData.clave_catastral?.trim() || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="file-invoice" />
              Información Fiscal
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Cuenta:</td>
                <td><code>{{ detailData.cuenta?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="detailData.activo ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="detailData.activo ? 'check-circle' : 'times-circle'" />
                    {{ detailData.activo ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showDetailModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
      <div v-else class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando detalles...</p>
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
      :componentName="'busque'"
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
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Estado
const activeTab = ref('owner')
const resultados = ref([])
const selectedResultado = ref(null)
const detailData = ref(null)
const showDetailModal = ref(false)
const hasSearched = ref(false)

// Filtros
const filters = ref({
  owner: {
    nombre: '',
    apellido_paterno: '',
    apellido_materno: ''
  },
  location: {
    calle: '',
    numero: '',
    colonia: ''
  },
  account: {
    cuenta: ''
  },
  rfc: {
    rfc: ''
  },
  cadastral: {
    clave: ''
  }
})

// Métodos de navegación
const changeTab = (tab) => {
  activeTab.value = tab
  resultados.value = []
  hasSearched.value = false
}

// Búsqueda por Propietario
const searchByOwner = async () => {
  if (!filters.value.owner.nombre && !filters.value.owner.apellido_paterno && !filters.value.owner.apellido_materno) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por propietario...')
  hasSearched.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_search_by_owner',
      'padron_licencias',
      [
        { nombre: 'p_nombre', valor: filters.value.owner.nombre || null, tipo: 'string' },
        { nombre: 'p_apellido_paterno', valor: filters.value.owner.apellido_paterno || null, tipo: 'string' },
        { nombre: 'p_apellido_materno', valor: filters.value.owner.apellido_materno || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      resultados.value = response.result
      if (resultados.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${resultados.value.length} resultados`)
      } else {
        showToast('info', 'No se encontraron resultados')
      }
    } else {
      resultados.value = []
      showToast('error', 'Error al buscar')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const clearOwnerFilters = () => {
  filters.value.owner = {
    nombre: '',
    apellido_paterno: '',
    apellido_materno: ''
  }
  resultados.value = []
  hasSearched.value = false
}

// Búsqueda por Ubicación
const searchByLocation = async () => {
  if (!filters.value.location.calle && !filters.value.location.numero && !filters.value.location.colonia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese al menos un criterio de búsqueda',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por ubicación...')
  hasSearched.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_search_by_location',
      'padron_licencias',
      [
        { nombre: 'p_calle', valor: filters.value.location.calle || null, tipo: 'string' },
        { nombre: 'p_numero', valor: filters.value.location.numero || null, tipo: 'string' },
        { nombre: 'p_colonia', valor: filters.value.location.colonia || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      resultados.value = response.result
      if (resultados.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${resultados.value.length} resultados`)
      } else {
        showToast('info', 'No se encontraron resultados')
      }
    } else {
      resultados.value = []
      showToast('error', 'Error al buscar')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const clearLocationFilters = () => {
  filters.value.location = {
    calle: '',
    numero: '',
    colonia: ''
  }
  resultados.value = []
  hasSearched.value = false
}

// Búsqueda por Cuenta
const searchByAccount = async () => {
  if (!filters.value.account.cuenta) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese un número de cuenta',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por cuenta...')
  hasSearched.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_search_by_account',
      'padron_licencias',
      [
        { nombre: 'p_cuenta', valor: filters.value.account.cuenta, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      resultados.value = response.result
      if (resultados.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${resultados.value.length} resultados`)
      } else {
        showToast('info', 'No se encontraron resultados')
      }
    } else {
      resultados.value = []
      showToast('error', 'Error al buscar')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const clearAccountFilters = () => {
  filters.value.account = {
    cuenta: ''
  }
  resultados.value = []
  hasSearched.value = false
}

// Búsqueda por RFC
const searchByRfc = async () => {
  if (!filters.value.rfc.rfc) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese un RFC',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por RFC...')
  hasSearched.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_search_by_rfc',
      'padron_licencias',
      [
        { nombre: 'p_rfc', valor: filters.value.rfc.rfc.toUpperCase(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      resultados.value = response.result
      if (resultados.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${resultados.value.length} resultados`)
      } else {
        showToast('info', 'No se encontraron resultados')
      }
    } else {
      resultados.value = []
      showToast('error', 'Error al buscar')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const clearRfcFilters = () => {
  filters.value.rfc = {
    rfc: ''
  }
  resultados.value = []
  hasSearched.value = false
}

// Búsqueda por Clave Catastral
const searchByCadastral = async () => {
  if (!filters.value.cadastral.clave) {
    await Swal.fire({
      icon: 'warning',
      title: 'Búsqueda requerida',
      text: 'Por favor ingrese una clave catastral',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por clave catastral...')
  hasSearched.value = true

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_search_by_cadastral_key',
      'padron_licencias',
      [
        { nombre: 'p_clave_catastral', valor: filters.value.cadastral.clave, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      resultados.value = response.result
      if (resultados.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${resultados.value.length} resultados`)
      } else {
        showToast('info', 'No se encontraron resultados')
      }
    } else {
      resultados.value = []
      showToast('error', 'Error al buscar')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const clearCadastralFilters = () => {
  filters.value.cadastral = {
    clave: ''
  }
  resultados.value = []
  hasSearched.value = false
}

// Ver detalle completo
const viewDetalle = async (resultado) => {
  selectedResultado.value = resultado
  showDetailModal.value = true
  detailData.value = null

  setLoading(true, 'Cargando detalles...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_busque_get_detail',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: resultado.id, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result[0]) {
      detailData.value = response.result[0]
      toast.value.duration = durationText
      showToast('success', 'Detalles cargados')
    } else {
      showToast('error', 'Error al cargar detalles')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  showDetailModal.value = false
})
</script>
