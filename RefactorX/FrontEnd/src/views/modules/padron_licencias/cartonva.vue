<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Cartografía Catastral</h1>
        <p>Padrón de Licencias - Consulta de Información Catastral y Cartográfica</p></div>
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
            <label class="municipal-form-label">Clave de Cuenta</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cveCuenta"
              placeholder="Ingrese clave de cuenta"
              @keyup.enter="searchByAccount"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave Catastral</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.cveCatNva"
              placeholder="Clave catastral nueva"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Subpredio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.subpredio"
              placeholder="Subpredio"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchByAccount"
            :disabled="loading || !filters.cveCuenta"
          >
            <font-awesome-icon icon="search" />
            Buscar por Cuenta
          </button>
          <button
            class="btn-municipal-primary"
            @click="searchByCatastral"
            :disabled="loading || !filters.cveCatNva"
          >
            <font-awesome-icon icon="map" />
            Buscar por Catastral
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

    <!-- Información de cuenta -->
    <div class="municipal-card" v-if="cuentaInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-invoice" />
          Información de Cuenta
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <table class="detail-table">
              <tr>
                <td class="label">Cuenta:</td>
                <td><strong>{{ cuentaInfo.cvecuenta }}</strong></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ cuentaInfo.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ cuentaInfo.domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ cuentaInfo.colonia || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Información catastral -->
    <div class="municipal-card" v-if="convcta && convcta.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="map-marker-alt" />
          Información Catastral
          <span class="badge-purple" v-if="convcta.length > 0">{{ convcta.length }} registros</span>
        </h5>
      </div>

      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Clave Catastral</th>
                <th>Subpredio</th>
                <th>Superficie</th>
                <th>Valor Catastral</th>
                <th>Tipo</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in convcta" :key="index" class="clickable-row">
                <td><code>{{ item.cvecatnva || 'N/A' }}</code></td>
                <td>{{ item.subpredio || '-' }}</td>
                <td>{{ item.superficie ? `${item.superficie} m²` : 'N/A' }}</td>
                <td>{{ formatCurrency(item.valorcatastral) }}</td>
                <td>
                  <span class="badge-purple">{{ item.tipopropiedad || 'N/A' }}</span>
                </td>
                <td>
                  <button
                    class="btn-municipal-info btn-sm"
                    @click="viewCartografia(item)"
                    title="Ver cartografía"
                  >
                    <font-awesome-icon icon="map" />
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Información cartográfica -->
    <div class="municipal-card" v-if="cartografiaInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="globe" />
          Información Cartográfica
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <table class="detail-table">
              <tr>
                <td class="label">Coordenadas:</td>
                <td>{{ cartografiaInfo.coordenadas || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>{{ cartografiaInfo.zona || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Manzana:</td>
                <td>{{ cartografiaInfo.manzana || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Lote:</td>
                <td>{{ cartografiaInfo.lote || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Consultando información catastral...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'cartonva'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'


import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

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
const cuentaInfo = ref(null)
const convcta = ref([])
const cartografiaInfo = ref(null)

// Filtros
const filters = ref({
  cveCuenta: '',
  cveCatNva: '',
  subpredio: ''
})

// Métodos de búsqueda
const searchByAccount = async () => {
  if (!filters.value.cveCuenta) {
    showToast('warning', 'Ingrese una clave de cuenta')
    return
  }

  setLoading(true, 'Buscando información...')
  const startTime = performance.now()

  try {
    const responseCuenta = await execute(
      'sp_get_cuenta_by_cvecuenta',
      'padron_licencias',
      [
        { nombre: 'p_cvecuenta', valor: filters.value.cveCuenta, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (responseCuenta && responseCuenta.result && responseCuenta.result.length > 0) {
      cuentaInfo.value = responseCuenta.result[0]

      const responseConvcta = await execute(
        'sp_get_convcta_by_cvecuenta',
        'padron_licencias',
        [
          { nombre: 'p_cvecuenta', valor: filters.value.cveCuenta, tipo: 'string' }
        ],
        'guadalajara',
      null,
      'publico'
      )

      if (responseConvcta && responseConvcta.result) {
        convcta.value = responseConvcta.result
      }

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      toast.value.duration = durationText
      showToast('success', 'Información de cuenta encontrada')
    } else {
      cuentaInfo.value = null
      convcta.value = []
      showToast('warning', 'No se encontró información para esta cuenta')
    }
  } catch (error) {
    handleApiError(error)
    cuentaInfo.value = null
    convcta.value = []
  } finally {
    setLoading(false)
  }
}

const searchByCatastral = async () => {
  if (!filters.value.cveCatNva) {
    showToast('warning', 'Ingrese una clave catastral')
    return
  }

  setLoading(true, 'Buscando información catastral...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_convcta_by_cvecatnva_subpredio',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: filters.value.cveCatNva, tipo: 'string' },
        { nombre: 'p_subpredio', valor: filters.value.subpredio || '', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      convcta.value = response.result

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1
        ? `${((endTime - startTime)).toFixed(0)}ms`
        : `${duration}s`

      toast.value.duration = durationText
      showToast('success', `Se encontraron ${response.result.length} registros`)

      // Si hay cuenta asociada, buscar su info
      if (response.result[0].cvecuenta) {
        filters.value.cveCuenta = response.result[0].cvecuenta
        await searchByAccount()
      }
    } else {
      convcta.value = []
      cuentaInfo.value = null
      showToast('warning', 'No se encontró información para esta clave catastral')
    }
  } catch (error) {
    handleApiError(error)
    convcta.value = []
  } finally {
    setLoading(false)
  }
}

const viewCartografia = async (item) => {
  setLoading(true, 'Cargando información cartográfica...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_cartografia_predial',
      'padron_licencias',
      [
        { nombre: 'p_cvecatnva', valor: item.cvecatnva, tipo: 'string' }
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

    if (response && response.result && response.result.length > 0) {
      cartografiaInfo.value = response.result[0]
      toast.value.duration = durationText
      showToast('success', 'Información cartográfica cargada')
    } else {
      cartografiaInfo.value = null
      showToast('info', 'No hay información cartográfica disponible')
    }
  } catch (error) {
    handleApiError(error)
    cartografiaInfo.value = null
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    cveCuenta: '',
    cveCatNva: '',
    subpredio: ''
  }
  cuentaInfo.value = null
  convcta.value = []
  cartografiaInfo.value = null
}

// Utilidades
const formatCurrency = (value) => {
  if (!value) return 'N/A'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}
</script>
