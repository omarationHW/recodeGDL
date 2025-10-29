<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Zonas de Licencias</h1>
        <p>Padrón de Licencias - Gestión de Zonas y Asignación de Licencias</p></div>
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

    <!-- Tabs -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="tabs-container">
          <div class="tabs-header">
            <button
              class="tab-button"
              :class="{ active: activeTab === 'zonas' }"
              @click="activeTab = 'zonas'"
            >
              <font-awesome-icon icon="map" />
              Zonas
            </button>
            <button
              class="tab-button"
              :class="{ active: activeTab === 'subzonas' }"
              @click="activeTab = 'subzonas'"
            >
              <font-awesome-icon icon="map-pin" />
              Subzonas
            </button>
            <button
              class="tab-button"
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
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="map" />
                    Catálogo de Zonas
                    <span class="badge-info" v-if="zonas.length > 0">{{ zonas.length }} zonas</span>
                  </h5>
                  <button
                    class="btn-municipal-secondary"
                    @click="loadZonas"
                    :disabled="loading"
                  >
                    <font-awesome-icon icon="sync-alt" />
                    Actualizar
                  </button>
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
                        <tr v-for="zona in zonas" :key="zona.id" class="row-hover">
                          <td><strong class="text-primary">{{ zona.id }}</strong></td>
                          <td>{{ zona.nombre?.trim() || 'N/A' }}</td>
                          <td>{{ zona.recaudadora?.trim() || 'N/A' }}</td>
                          <td>{{ zona.descripcion?.trim() || 'N/A' }}</td>
                        </tr>
                        <tr v-if="zonas.length === 0 && !loading">
                          <td colspan="4" class="text-center text-muted">
                            <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                            <p>No hay zonas registradas</p>
                          </td>
                        </tr>
                      </tbody>
                    </table>
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

                  <div v-if="selectedZonaForSubzonas" class="table-responsive" style="margin-top: 20px;">
                    <table class="municipal-table">
                      <thead class="municipal-table-header">
                        <tr>
                          <th>ID</th>
                          <th>Nombre</th>
                          <th>Descripción</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="subzona in subzonas" :key="subzona.id" class="row-hover">
                          <td><strong class="text-primary">{{ subzona.id }}</strong></td>
                          <td>{{ subzona.nombre?.trim() || 'N/A' }}</td>
                          <td>{{ subzona.descripcion?.trim() || 'N/A' }}</td>
                        </tr>
                        <tr v-if="subzonas.length === 0 && !loading">
                          <td colspan="3" class="text-center text-muted">
                            <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                            <p>No hay subzonas para esta zona</p>
                          </td>
                        </tr>
                      </tbody>
                    </table>
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
                        class="btn-municipal-primary"
                        @click="buscarLicencia"
                        :disabled="loading || !asignacion.numeroLicencia"
                        style="margin-top: 24px;"
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
                  <div v-if="licenciaEncontrada" style="margin-top: 20px;">
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
                        :disabled="loading || !asignacion.zonaId"
                      >
                        <font-awesome-icon icon="save" />
                        Guardar Asignación
                      </button>
                      <button
                        class="btn-municipal-secondary"
                        @click="limpiarAsignacion"
                        :disabled="loading"
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
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
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
      :componentName="'ZonaLicencia'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
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
  loadingMessage,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const activeTab = ref('zonas')
const zonas = ref([])
const subzonas = ref([])
const subzonasAsignacion = ref([])
const selectedZonaForSubzonas = ref('')
const licenciaEncontrada = ref(null)

// Formulario de asignación
const asignacion = ref({
  numeroLicencia: '',
  zonaId: '',
  subzonaId: ''
})

// Métodos
const loadZonas = async () => {
  setLoading(true, 'Cargando zonas...')

  try {
    const response = await execute(
      'ZonaLicencia_sp_get_zonas',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      zonas.value = response.result
      showToast('success', 'Zonas cargadas correctamente')
    } else {
      zonas.value = []
      showToast('error', 'Error al cargar zonas')
    }
  } catch (error) {
    handleApiError(error)
    zonas.value = []
  } finally {
    setLoading(false)
  }
}

const loadSubzonas = async () => {
  if (!selectedZonaForSubzonas.value) {
    subzonas.value = []
    return
  }

  setLoading(true, 'Cargando subzonas...')

  try {
    const response = await execute(
      'ZonaLicencia_sp_get_subzonas',
      'padron_licencias',
      [
        { nombre: 'p_zona_id', valor: selectedZonaForSubzonas.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      subzonas.value = response.result
      showToast('success', 'Subzonas cargadas correctamente')
    } else {
      subzonas.value = []
    }
  } catch (error) {
    handleApiError(error)
    subzonas.value = []
  } finally {
    setLoading(false)
  }
}

const onZonaChange = async () => {
  asignacion.value.subzonaId = ''

  if (!asignacion.value.zonaId) {
    subzonasAsignacion.value = []
    return
  }

  setLoading(true, 'Cargando subzonas...')

  try {
    const response = await execute(
      'ZonaLicencia_sp_get_subzonas',
      'padron_licencias',
      [
        { nombre: 'p_zona_id', valor: asignacion.value.zonaId, tipo: 'integer' }
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
    setLoading(false)
  }
}

const buscarLicencia = async () => {
  if (!asignacion.value.numeroLicencia) {
    return
  }

  setLoading(true, 'Buscando licencia...')

  try {
    const response = await execute(
      'ZonaLicencia_sp_get_licencia',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: asignacion.value.numeroLicencia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      licenciaEncontrada.value = response.result[0]

      // Si ya tiene zona asignada, cargar datos
      if (licenciaEncontrada.value.zona_id) {
        asignacion.value.zonaId = licenciaEncontrada.value.zona_id
        await onZonaChange()
        if (licenciaEncontrada.value.subzona_id) {
          asignacion.value.subzonaId = licenciaEncontrada.value.subzona_id
        }
      }

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
    setLoading(false)
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

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar asignación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se asignará la licencia a la zona seleccionada:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Licencia:</strong> ${licenciaEncontrada.value.numero}</li>
          <li style="margin: 5px 0;"><strong>Zona:</strong> ${zonas.value.find(z => z.id === asignacion.value.zonaId)?.nombre || 'N/A'}</li>
          ${asignacion.value.subzonaId ? `<li style="margin: 5px 0;"><strong>Subzona:</strong> ${subzonasAsignacion.value.find(s => s.id === asignacion.value.subzonaId)?.nombre || 'N/A'}</li>` : ''}
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

  setLoading(true, 'Guardando asignación...')

  try {
    const response = await execute(
      'ZonaLicencia_sp_save_licencias_zona',
      'padron_licencias',
      [
        { nombre: 'p_numero_licencia', valor: licenciaEncontrada.value.numero, tipo: 'string' },
        { nombre: 'p_zona_id', valor: asignacion.value.zonaId, tipo: 'integer' },
        { nombre: 'p_subzona_id', valor: asignacion.value.subzonaId || null, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Asignación guardada!',
        text: 'La licencia ha sido asignada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Asignación guardada exitosamente')
      limpiarAsignacion()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo guardar la asignación',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
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
}

// Lifecycle
onMounted(async () => {
  await loadZonas()
})
</script>

<style scoped>
.tabs-container {
  width: 100%;
}

.tabs-header {
  display: flex;
  gap: 10px;
  border-bottom: 2px solid #ddd;
  margin-bottom: 20px;
}

.tab-button {
  padding: 12px 24px;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: #666;
  transition: all 0.3s;
}

.tab-button:hover {
  color: #ea8215;
  background: #f8f9fa;
}

.tab-button.active {
  color: #ea8215;
  border-bottom-color: #ea8215;
  background: #fff;
}

.tab-panel {
  animation: fadeIn 0.3s;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.info-panel {
  background: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 20px;
  margin-top: 20px;
}

.info-panel h6 {
  margin: 0 0 15px 0;
  color: #333;
  font-size: 16px;
  font-weight: 600;
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
  padding: 10px 15px;
}

.detail-table td.label {
  font-weight: 600;
  color: #666;
  width: 150px;
}
</style>
