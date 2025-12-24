<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marker-alt" />
      </div>
      <div class="module-view-info">
        <h1>Localizar Cruces de Calles</h1>
        <p>Padrón de Licencias - Búsqueda y Selección de Cruces</p></div>
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
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="confirmSelection"
          :disabled="!calle1Selected || !calle2Selected"
        >
          <font-awesome-icon icon="check" />
          Confirmar Selección
        </button>
        <button
          class="btn-municipal-secondary"
          @click="clearSelection"
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
                      @click="selectCalle1(calle)"
                      :class="{ 'table-row-selected': calle1Selected?.clave === calle.clave }"
                      class="row-hover"
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

            <div v-else-if="searchCalle1" class="text-center text-muted">
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
                      @click="selectCalle2(calle)"
                      :class="{ 'table-row-selected': calle2Selected?.clave === calle.clave }"
                      class="row-hover"
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

            <div v-else-if="searchCalle2" class="text-center text-muted">
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
      :componentName="'Cruces'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Localizar Cruces de Calles'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onBeforeUnmount } from 'vue'
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
    showLoading('Buscando calle 1...')
    const startTime = performance.now()

    try {
      const response = await execute(
        'sp_cruces_search_calle1',
        'padron_licencias',
        [
          { nombre: 'p_busqueda', valor: searchCalle1.value, tipo: 'string' }
        ],
        'guadalajara'
      )

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

      if (response && response.result) {
        calles1.value = response.result
        toast.value.duration = durationText
      } else {
        calles1.value = []
      }
    } catch (error) {
      handleApiError(error)
      calles1.value = []
    } finally {
      hideLoading()
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
    showLoading('Buscando calle 2...')
    const startTime = performance.now()

    try {
      const response = await execute(
        'sp_cruces_search_calle2',
        'padron_licencias',
        [
          { nombre: 'p_busqueda', valor: searchCalle2.value, tipo: 'string' }
        ],
        'guadalajara'
      )

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

      if (response && response.result) {
        calles2.value = response.result
        toast.value.duration = durationText
      } else {
        calles2.value = []
      }
    } catch (error) {
      handleApiError(error)
      calles2.value = []
    } finally {
      hideLoading()
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

  showLoading('Localizando cruce...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_cruces_localiza_calle',
      'padron_licencias',
      [
        { nombre: 'p_clave_calle1', valor: calle1Selected.value.clave, tipo: 'string' },
        { nombre: 'p_clave_calle2', valor: calle2Selected.value.clave, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      cruceLocalizado.value = response.result[0]
      toast.value.duration = durationText
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
    hideLoading()
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
      <div class="swal-selection-content">
        <p class="swal-confirmation-text">Cruce seleccionado:</p>
        <ul class="swal-selection-list">
          <li><strong>Calle 1:</strong> ${calle1Selected.value.calle}</li>
          <li><strong>Calle 2:</strong> ${calle2Selected.value.calle}</li>
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

