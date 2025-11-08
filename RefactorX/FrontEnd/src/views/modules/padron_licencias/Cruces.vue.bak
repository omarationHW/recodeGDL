<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marker-alt" />
      </div>
      <div class="module-view-info">
        <h1>Localizar Cruces de Calles</h1>
        <p>Padrón de Licencias - Búsqueda y Selección de Cruces</p></div>
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
          @click="confirmSelection"
          :disabled="!calle1Selected || !calle2Selected || loading"
        >
          <font-awesome-icon icon="check" />
          Confirmar Selección
        </button>
        <button
          class="btn-municipal-secondary"
          @click="clearSelection"
          :disabled="loading"
        >
          <font-awesome-icon icon="times" />
          Limpiar
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Información de selección actual -->
    <div class="municipal-card" v-if="calle1Selected || calle2Selected">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Selección Actual
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="selection-info">
          <div class="selection-item">
            <strong>Calle 1:</strong>
            <span v-if="calle1Selected" class="badge-success">
              <font-awesome-icon icon="check-circle" />
              {{ calle1Selected.calle }}
            </span>
            <span v-else class="text-muted">No seleccionada</span>
          </div>
          <div class="selection-item">
            <strong>Calle 2:</strong>
            <span v-if="calle2Selected" class="badge-success">
              <font-awesome-icon icon="check-circle" />
              {{ calle2Selected.calle }}
            </span>
            <span v-else class="text-muted">No seleccionada</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda de Calles -->
    <div class="row">
      <!-- Columna Izquierda: Calle 1 -->
      <div class="col-md-6">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="road" />
              Seleccionar Calle 1
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-group">
              <label class="municipal-form-label">Buscar Calle 1</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchCalle1"
                @input="searchCalles1"
                placeholder="Escriba el nombre de la calle..."
              >
            </div>

            <div class="calles-results" v-if="calles1.length > 0">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Clave</th>
                      <th>Nombre de Calle</th>
                      <th>Seleccionar</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="calle in calles1"
                      :key="calle.clave"
                      class="row-hover"
                      :class="{ 'selected-row': calle1Selected?.clave === calle.clave }"
                      @click="selectCalle1(calle)"
                      style="cursor: pointer;"
                    >
                      <td><code>{{ calle.clave }}</code></td>
                      <td><strong>{{ calle.calle }}</strong></td>
                      <td>
                        <button
                          class="btn-municipal-info btn-sm"
                          @click.stop="selectCalle1(calle)"
                        >
                          <font-awesome-icon
                            :icon="calle1Selected?.clave === calle.clave ? 'check-circle' : 'circle'"
                          />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div v-else-if="searchCalle1 && !loading" class="text-center text-muted">
              <p>
                <font-awesome-icon icon="search" />
                No se encontraron calles con ese criterio
              </p>
            </div>

            <div v-else class="text-center text-muted">
              <p>
                <font-awesome-icon icon="info-circle" />
                Escriba para buscar calles
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Columna Derecha: Calle 2 -->
      <div class="col-md-6">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="road" />
              Seleccionar Calle 2
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-group">
              <label class="municipal-form-label">Buscar Calle 2</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchCalle2"
                @input="searchCalles2"
                placeholder="Escriba el nombre de la calle..."
              >
            </div>

            <div class="calles-results" v-if="calles2.length > 0">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Clave</th>
                      <th>Nombre de Calle</th>
                      <th>Seleccionar</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="calle in calles2"
                      :key="calle.clave"
                      class="row-hover"
                      :class="{ 'selected-row': calle2Selected?.clave === calle.clave }"
                      @click="selectCalle2(calle)"
                      style="cursor: pointer;"
                    >
                      <td><code>{{ calle.clave }}</code></td>
                      <td><strong>{{ calle.calle }}</strong></td>
                      <td>
                        <button
                          class="btn-municipal-info btn-sm"
                          @click.stop="selectCalle2(calle)"
                        >
                          <font-awesome-icon
                            :icon="calle2Selected?.clave === calle.clave ? 'check-circle' : 'circle'"
                          />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <div v-else-if="searchCalle2 && !loading" class="text-center text-muted">
              <p>
                <font-awesome-icon icon="search" />
                No se encontraron calles con ese criterio
              </p>
            </div>

            <div v-else class="text-center text-muted">
              <p>
                <font-awesome-icon icon="info-circle" />
                Escriba para buscar calles
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultado del Cruce -->
    <div class="municipal-card" v-if="cruceLocalizado">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="map-marked-alt" />
          Información del Cruce
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="cruce-details">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Datos del Cruce
              </h6>
              <table class="detail-table">
                <tr v-for="(value, key) in cruceLocalizado" :key="key">
                  <td class="label">{{ formatKey(key) }}:</td>
                  <td>{{ value || 'N/A' }}</td>
                </tr>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Buscando calles...</p>
      </div>
    </div>

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
      :componentName="'Cruces'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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
const searchCalle1 = ref('')
const searchCalle2 = ref('')
const calles1 = ref([])
const calles2 = ref([])
const calle1Selected = ref(null)
const calle2Selected = ref(null)
const cruceLocalizado = ref(null)

// Debounce para búsquedas
let searchTimeout1 = null
let searchTimeout2 = null

// Métodos
const searchCalles1 = () => {
  if (searchTimeout1) {
    clearTimeout(searchTimeout1)
  }

  if (!searchCalle1.value || searchCalle1.value.length < 2) {
    calles1.value = []
    return
  }

  searchTimeout1 = setTimeout(async () => {
    setLoading(true, 'Buscando calle 1...')

    try {
      const response = await execute(
        'SP_CRUCES_SEARCH_CALLE1',
        'padron_licencias',
        [
          { nombre: 'p_busqueda', valor: searchCalle1.value, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        calles1.value = response.result
      } else {
        calles1.value = []
      }
    } catch (error) {
      handleApiError(error)
      calles1.value = []
    } finally {
      setLoading(false)
    }
  }, 500)
}

const searchCalles2 = () => {
  if (searchTimeout2) {
    clearTimeout(searchTimeout2)
  }

  if (!searchCalle2.value || searchCalle2.value.length < 2) {
    calles2.value = []
    return
  }

  searchTimeout2 = setTimeout(async () => {
    setLoading(true, 'Buscando calle 2...')

    try {
      const response = await execute(
        'SP_CRUCES_SEARCH_CALLE2',
        'padron_licencias',
        [
          { nombre: 'p_busqueda', valor: searchCalle2.value, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        calles2.value = response.result
      } else {
        calles2.value = []
      }
    } catch (error) {
      handleApiError(error)
      calles2.value = []
    } finally {
      setLoading(false)
    }
  }, 500)
}

const selectCalle1 = (calle) => {
  calle1Selected.value = calle
  showToast('success', `Calle 1 seleccionada: ${calle.calle}`)

  // Si ambas calles están seleccionadas, localizar el cruce automáticamente
  if (calle2Selected.value) {
    localizarCruce()
  }
}

const selectCalle2 = (calle) => {
  calle2Selected.value = calle
  showToast('success', `Calle 2 seleccionada: ${calle.calle}`)

  // Si ambas calles están seleccionadas, localizar el cruce automáticamente
  if (calle1Selected.value) {
    localizarCruce()
  }
}

const localizarCruce = async () => {
  if (!calle1Selected.value || !calle2Selected.value) {
    return
  }

  setLoading(true, 'Localizando cruce...')

  try {
    const response = await execute(
      'SP_CRUCES_LOCALIZA_CALLE',
      'padron_licencias',
      [
        { nombre: 'p_clave_calle1', valor: calle1Selected.value.clave, tipo: 'string' },
        { nombre: 'p_clave_calle2', valor: calle2Selected.value.clave, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      cruceLocalizado.value = response.result[0]
      showToast('success', 'Cruce localizado exitosamente')
    } else {
      cruceLocalizado.value = null
      await Swal.fire({
        icon: 'warning',
        title: 'Cruce no encontrado',
        text: 'No se encontró información del cruce de estas calles',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    cruceLocalizado.value = null
  } finally {
    setLoading(false)
  }
}

const confirmSelection = async () => {
  if (!calle1Selected.value || !calle2Selected.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Selección incompleta',
      text: 'Por favor seleccione ambas calles',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  await Swal.fire({
    icon: 'success',
    title: '¡Selección confirmada!',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Cruce seleccionado:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Calle 1:</strong> ${calle1Selected.value.calle}</li>
          <li style="margin: 5px 0;"><strong>Calle 2:</strong> ${calle2Selected.value.calle}</li>
        </ul>
      </div>
    `,
    confirmButtonColor: '#ea8215',
    timer: 3000
  })

  showToast('success', 'Selección confirmada correctamente')
}

const clearSelection = () => {
  searchCalle1.value = ''
  searchCalle2.value = ''
  calles1.value = []
  calles2.value = []
  calle1Selected.value = null
  calle2Selected.value = null
  cruceLocalizado.value = null
  showToast('info', 'Selección limpiada')
}

const formatKey = (key) => {
  // Convierte nombres de campos como "clave_calle" a "Clave Calle"
  return key
    .split('_')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

// Lifecycle
onBeforeUnmount(() => {
  if (searchTimeout1) {
    clearTimeout(searchTimeout1)
  }
  if (searchTimeout2) {
    clearTimeout(searchTimeout2)
  }
})
</script>

<style scoped>
.row {
  display: flex;
  margin: 0 -15px;
}

.col-md-6 {
  flex: 0 0 50%;
  max-width: 50%;
  padding: 0 15px;
  margin-bottom: 20px;
}

.calles-results {
  margin-top: 15px;
  max-height: 400px;
  overflow-y: auto;
}

.selected-row {
  background-color: #e6f3ff !important;
  border-left: 4px solid #ea8215;
}

.selection-info {
  display: flex;
  gap: 30px;
  flex-wrap: wrap;
}

.selection-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.selection-item strong {
  font-weight: 600;
  color: #333;
}

.cruce-details {
  padding: 10px 0;
}

.details-grid {
  display: grid;
  gap: 20px;
}

.detail-section {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #333;
  border-bottom: 2px solid #ea8215;
  padding-bottom: 8px;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table tr {
  border-bottom: 1px solid #e0e0e0;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 10px 0;
}

.detail-table td.label {
  font-weight: 600;
  color: #666;
  width: 35%;
}
</style>
