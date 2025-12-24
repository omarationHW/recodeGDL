<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Zonas de Licencias</h1>
        <p>Padrón de Licencias - Gestión de Zonas y Asignación de Licencias</p>
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

    <!-- Selección de Recaudadora -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="building" />
          Selección de Recaudadora
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Recaudadora: <span class="required">*</span></label>
            <select class="municipal-form-control" v-model="selectedRecaudadora" @change="onRecaudadoraChange">
              <option value="">-- Seleccione una recaudadora --</option>
              <option v-for="rec in recaudadoras" :key="rec.recaud" :value="rec.recaud">
                {{ rec.descripcion }}
              </option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="municipal-card" v-if="selectedRecaudadora">
      <div class="municipal-card-body">
        <div class="municipal-tabs">
          <button
            class="municipal-tab"
            :class="{ active: activeTab === 'zonas' }"
            @click="activeTab = 'zonas'"
          >
            <font-awesome-icon icon="map" />
            Zonas
          </button>
          <button
            class="municipal-tab"
            :class="{ active: activeTab === 'subzonas' }"
            @click="activeTab = 'subzonas'"
          >
            <font-awesome-icon icon="map-pin" />
            Subzonas
          </button>
          <button
            class="municipal-tab"
            :class="{ active: activeTab === 'asignacion' }"
            @click="activeTab = 'asignacion'"
          >
            <font-awesome-icon icon="link" />
            Asignación
          </button>
        </div>

          <div class="tabs-content">
            <!-- Tab Zonas -->
            <div v-if="activeTab === 'zonas'" class="tab-panel">
              <div class="municipal-card">
                <div class="municipal-card-header header-with-badge">
                  <h5>
                    <font-awesome-icon icon="map" />
                    Catálogo de Zonas
                  </h5>
                  <div class="header-right">
                    <span class="badge-purple" v-if="zonas.length > 0">{{ zonas.length }} zonas</span>
                    <button
                      class="btn-municipal-secondary"
                      @click="loadZonas"
                    >
                      <font-awesome-icon icon="sync-alt" />
                      Actualizar
                    </button>
                  </div>
                </div>
                <div class="municipal-card-body">
                  <div class="table-responsive">
                    <table class="municipal-table">
                      <thead class="municipal-table-header">
                        <tr>
                          <th>ID</th>
                          <th>Nombre</th>
                          <th>Recaudadora</th>
                          <th>Descripción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr
                          v-for="zona in zonas"
                          :key="zona.cvezona"
                          @click="selectedRow = zona"
                          :class="{ 'table-row-selected': selectedRow === zona }"
                          class="row-hover"
                        >
                          <td><strong class="text-primary">{{ zona.cvezona }}</strong></td>
                          <td>{{ zona.zona?.trim() || 'N/A' }}</td>
                          <td>{{ selectedRecaudadora }}</td>
                          <td>{{ zona.descripcion?.trim() || 'N/A' }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <!-- Empty State -->
                  <div v-if="zonas.length === 0 && hasSearched" class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="inbox" size="3x" />
                    </div>
                    <h4>Sin resultados</h4>
                    <p>No se encontraron zonas registradas</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Tab Subzonas -->
            <div v-if="activeTab === 'subzonas'" class="tab-panel">
              <div class="municipal-card">
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="map-pin" />
                    Catálogo de Subzonas
                  </h5>
                </div>
                <div class="municipal-card-body">
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Seleccionar Zona:</label>
                      <select class="municipal-form-control" v-model="selectedZonaForSubzonas" @change="loadSubzonas">
                        <option value="">-- Seleccione una zona --</option>
                        <option v-for="zona in zonas" :key="zona.id" :value="zona.id">
                          {{ zona.nombre }}
                        </option>
                      </select>
                    </div>
                  </div>

                  <div v-if="selectedZonaForSubzonas" class="table-responsive mt-4">
                    <table class="municipal-table">
                      <thead class="municipal-table-header">
                        <tr>
                          <th>ID</th>
                          <th>Nombre</th>
                          <th>Descripción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr
                          v-for="subzona in subzonas"
                          :key="subzona.cvesubzona"
                          @click="selectedRow = subzona"
                          :class="{ 'table-row-selected': selectedRow === subzona }"
                          class="row-hover"
                        >
                          <td><strong class="text-primary">{{ subzona.cvesubzona }}</strong></td>
                          <td>{{ subzona.descsubzon?.trim() || 'N/A' }}</td>
                          <td>{{ subzona.descripcion?.trim() || 'N/A' }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  <!-- Empty State -->
                  <div v-if="subzonas.length === 0 && hasSearched" class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="inbox" size="3x" />
                    </div>
                    <h4>Sin resultados</h4>
                    <p>No hay subzonas para esta zona</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Tab Asignación -->
            <div v-if="activeTab === 'asignacion'" class="tab-panel">
              <div class="municipal-card">
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="link" />
                    Asignar Licencias a Zonas
                  </h5>
                </div>
                <div class="municipal-card-body">
                  <!-- Búsqueda de Licencia -->
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Número de Licencia: <span class="required">*</span></label>
                      <input
                        type="text"
                        class="municipal-form-control"
                        v-model="asignacion.numeroLicencia"
                        placeholder="Ingrese número de licencia"
                        @blur="buscarLicencia"
                      >
                    </div>
                    <div class="form-group">
                      <button
                        class="btn-municipal-primary mt-label-offset"
                        @click="buscarLicencia"
                        :disabled="!asignacion.numeroLicencia"
                      >
                        <font-awesome-icon icon="search" />
                        Buscar
                      </button>
                    </div>
                  </div>

                  <!-- Información de Licencia -->
                  <div v-if="licenciaEncontrada" class="info-panel">
                    <h6>
                      <font-awesome-icon icon="id-card" />
                      Información de la Licencia
                    </h6>
                    <table class="detail-table">
                      <tr>
                        <td class="label">Número:</td>
                        <td><strong>{{ licenciaEncontrada.numero }}</strong></td>
                      </tr>
                      <tr>
                        <td class="label">Propietario:</td>
                        <td>{{ licenciaEncontrada.propietario || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <td class="label">Giro:</td>
                        <td>{{ licenciaEncontrada.giro || 'N/A' }}</td>
                      </tr>
                      <tr>
                        <td class="label">Dirección:</td>
                        <td>{{ licenciaEncontrada.direccion || 'N/A' }}</td>
                      </tr>
                    </table>
                  </div>

                  <!-- Asignación de Zona y Subzona -->
                  <div v-if="licenciaEncontrada" class="mt-4">
                    <div class="form-row">
                      <div class="form-group">
                        <label class="municipal-form-label">Zona: <span class="required">*</span></label>
                        <select class="municipal-form-control" v-model="asignacion.zonaId" @change="onZonaChange">
                          <option value="">-- Seleccione una zona --</option>
                          <option v-for="zona in zonas" :key="zona.id" :value="zona.id">
                            {{ zona.nombre }}
                          </option>
                        </select>
                      </div>
                      <div class="form-group">
                        <label class="municipal-form-label">Subzona:</label>
                        <select
                          class="municipal-form-control"
                          v-model="asignacion.subzonaId"
                          :disabled="!asignacion.zonaId"
                        >
                          <option value="">-- Seleccione una subzona --</option>
                          <option v-for="subzona in subzonasAsignacion" :key="subzona.id" :value="subzona.id">
                            {{ subzona.nombre }}
                          </option>
                        </select>
                      </div>
                    </div>

                    <div class="button-group">
                      <button
                        class="btn-municipal-primary"
                        @click="guardarAsignacion"
                        :disabled="!asignacion.zonaId"
                      >
                        <font-awesome-icon icon="save" />
                        Guardar Asignación
                      </button>
                      <button
                        class="btn-municipal-secondary"
                        @click="limpiarAsignacion"
                      >
                        <font-awesome-icon icon="times" />
                        Limpiar
                      </button>
                    </div>
                  </div>
                </div>
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
      :componentName="'ZonaLicencia'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Zonas de Licencias'"
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

// Estado
const activeTab = ref('zonas')
const recaudadoras = ref([])
const selectedRecaudadora = ref('')
const zonas = ref([])
const subzonas = ref([])
const subzonasAsignacion = ref([])
const selectedZonaForSubzonas = ref('')
const licenciaEncontrada = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Formulario de asignación
const asignacion = ref({
  numeroLicencia: '',
  zonaId: '',
  subzonaId: ''
})

// Métodos
const loadRecaudadoras = async () => {
  showLoading('Cargando recaudadoras...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_recaudadoras',
      'padron_licencias',
      [],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      recaudadoras.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${recaudadoras.value.length} recaudadoras`)
    } else {
      recaudadoras.value = []
      showToast('error', 'Error al cargar recaudadoras')
    }
  } catch (error) {
    handleApiError(error)
    recaudadoras.value = []
  } finally {
    hideLoading()
  }
}

const onRecaudadoraChange = async () => {
  // Limpiar datos al cambiar recaudadora
  zonas.value = []
  subzonas.value = []
  subzonasAsignacion.value = []
  selectedZonaForSubzonas.value = ''
  limpiarAsignacion()

  if (selectedRecaudadora.value) {
    await loadZonas()
  }
}

const loadZonas = async () => {
  if (!selectedRecaudadora.value) {
    return
  }

  showLoading('Cargando zonas...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_zonas',
      'padron_licencias',
      [
        { nombre: 'p_recaud', valor: selectedRecaudadora.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      zonas.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${zonas.value.length} zonas`)
    } else {
      zonas.value = []
      showToast('error', 'Error al cargar zonas')
    }
  } catch (error) {
    handleApiError(error)
    zonas.value = []
  } finally {
    hideLoading()
  }
}

const loadSubzonas = async () => {
  if (!selectedZonaForSubzonas.value) {
    subzonas.value = []
    return
  }

  showLoading('Cargando subzonas...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_subzonas',
      'padron_licencias',
      [
        { nombre: 'p_cvezona', valor: selectedZonaForSubzonas.value, tipo: 'integer' },
        { nombre: 'p_recaud', valor: selectedRecaudadora.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result) {
      subzonas.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se cargaron ${subzonas.value.length} subzonas`)
    } else {
      subzonas.value = []
    }
  } catch (error) {
    handleApiError(error)
    subzonas.value = []
  } finally {
    hideLoading()
  }
}

const onZonaChange = async () => {
  asignacion.value.subzonaId = ''

  if (!asignacion.value.zonaId) {
    subzonasAsignacion.value = []
    return
  }

  showLoading('Cargando subzonas...')

  try {
    const response = await execute(
      'sp_get_subzonas',
      'padron_licencias',
      [
        { nombre: 'p_cvezona', valor: asignacion.value.zonaId, tipo: 'integer' },
        { nombre: 'p_recaud', valor: selectedRecaudadora.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      subzonasAsignacion.value = response.result
    } else {
      subzonasAsignacion.value = []
    }
  } catch (error) {
    handleApiError(error)
    subzonasAsignacion.value = []
  } finally {
    hideLoading()
  }
}

const buscarLicencia = async () => {
  if (!asignacion.value.numeroLicencia) {
    return
  }

  showLoading('Buscando licencia...')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_get_licencia',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: parseInt(asignacion.value.numeroLicencia), tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      licenciaEncontrada.value = response.result[0]

      // Si ya tiene zona asignada, cargar datos
      if (licenciaEncontrada.value.zona) {
        asignacion.value.zonaId = licenciaEncontrada.value.zona
        await onZonaChange()
        if (licenciaEncontrada.value.subzona) {
          asignacion.value.subzonaId = licenciaEncontrada.value.subzona
        }
      }

      toast.value.duration = durationText
      showToast('success', 'Licencia encontrada')
    } else {
      licenciaEncontrada.value = null
      await Swal.fire({
        icon: 'warning',
        title: 'Licencia no encontrada',
        text: 'No se encontró la licencia con ese número',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licenciaEncontrada.value = null
  } finally {
    hideLoading()
  }
}

const guardarAsignacion = async () => {
  if (!licenciaEncontrada.value || !asignacion.value.zonaId) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Por favor seleccione una zona',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const zonaSeleccionada = zonas.value.find(z => z.cvezona === asignacion.value.zonaId)
  const subzonaSeleccionada = subzonasAsignacion.value.find(s => s.cvesubzona === asignacion.value.subzonaId)

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar asignación?',
    html: `
      <div class="swal-selection-content">
        <p class="swal-selection-text">Se asignará la licencia a la zona seleccionada:</p>
        <ul class="swal-selection-list">
          <li><strong>Licencia:</strong> ${licenciaEncontrada.value.licencia}</li>
          <li><strong>Zona:</strong> ${zonaSeleccionada?.zona || 'N/A'}</li>
          ${subzonaSeleccionada ? `<li><strong>Subzona:</strong> ${subzonaSeleccionada.descsubzon}</li>` : ''}
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading('Guardando asignación...')

  const startTime = performance.now()

  try {
    // Get usuario from localStorage or session
    const usuario = localStorage.getItem('usuario') || 'sistema'

    const response = await execute(
      'sp_save_licencias_zona',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: licenciaEncontrada.value.licencia, tipo: 'integer' },
        { nombre: 'p_zona', valor: asignacion.value.zonaId, tipo: 'integer' },
        { nombre: 'p_subzona', valor: asignacion.value.subzonaId || null, tipo: 'integer' },
        { nombre: 'p_recaud', valor: selectedRecaudadora.value, tipo: 'integer' },
        { nombre: 'p_capturista', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    // SP returns VOID, so just check for no error
    await Swal.fire({
      icon: 'success',
      title: '¡Asignación guardada!',
      text: 'La licencia ha sido asignada exitosamente',
      confirmButtonColor: '#ea8215',
      timer: 2000
    })

    toast.value.duration = durationText
    showToast('success', 'Asignación guardada exitosamente')
    limpiarAsignacion()
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error al guardar',
      text: 'No se pudo guardar la asignación',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    hideLoading()
  }
}

const limpiarAsignacion = () => {
  asignacion.value = {
    numeroLicencia: '',
    zonaId: '',
    subzonaId: ''
  }
  licenciaEncontrada.value = null
  subzonasAsignacion.value = []
  hasSearched.value = false
  selectedRow.value = null
}

// Lifecycle
onMounted(async () => {
  await loadRecaudadoras()
})
</script>

<!-- NO inline styles - All styles in municipal-theme.css -->
