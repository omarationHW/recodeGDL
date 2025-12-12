<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Liga de Requisitos a Giros</h1>
        <p>Padrón de Licencias - Asignación de Requisitos a Giros de Licencia</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Selector de Giro -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="sitemap" />
          Seleccionar Giro
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Giro de Licencia: <span class="required">*</span></label>
            <select
              class="municipal-form-control"
              v-model="selectedGiroId"
              @change="onGiroSelected"
            >
              <option value="">Seleccione un giro...</option>
              <option
                v-for="giro in giros"
                :key="giro.id_giro"
                :value="giro.id_giro"
              >
                {{ giro.id_giro }} - {{ giro.descripcion }}
              </option>
            </select>
          </div>
        </div>

        <!-- Información del giro seleccionado -->
        <div v-if="selectedGiro" class="info-box info-primary">
          <h6>
            <font-awesome-icon icon="info-circle" />
            Información del Giro Seleccionado
          </h6>
          <div class="info-grid">
            <div class="info-item">
              <strong>ID Giro:</strong>
              <span>{{ selectedGiro.id_giro }}</span>
            </div>
            <div class="info-item">
              <strong>Descripción:</strong>
              <span>{{ selectedGiro.descripcion }}</span>
            </div>
            <div class="info-item">
              <strong>Clasificación:</strong>
              <span class="badge badge-light-secondary">{{ selectedGiro.clasificacion || 'N/A' }}</span>
            </div>
            <div class="info-item">
              <strong>Tipo:</strong>
              <span class="badge badge-light-info">{{ selectedGiro.tipo || 'N/A' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel de Gestión de Requisitos (Doble Columna) -->
    <div class="municipal-card" v-if="selectedGiroId">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="tasks" />
          Gestión de Requisitos - {{ selectedGiro?.descripcion }}
        </h5>
      </div>
      <div class="municipal-card-body">
        <!-- Filtros de búsqueda -->
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Buscar en Disponibles</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filterDisponibles"
              placeholder="Filtrar requisitos disponibles..."
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Buscar en Asignados</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filterAsignados"
              placeholder="Filtrar requisitos asignados..."
            >
          </div>
        </div>

        <div class="row mt-4">
          <!-- Columna Izquierda: Requisitos Disponibles -->
          <div class="col-md-6">
            <div class="requisitos-panel">
              <div class="panel-header">
                <h6>
                  <font-awesome-icon icon="list" />
                  Requisitos Disponibles
                  <span class="badge-purple">{{ filteredRequisitosDisponibles.length }}</span>
                </h6>
                <button
                  class="btn-municipal-primary btn-sm"
                  @click="addSelectedRequisitos"
                  :disabled="selectedDisponibles.length === 0 || loading"
                >
                  <font-awesome-icon icon="arrow-right" />
                  Agregar ({{ selectedDisponibles.length }})
                </button>
              </div>
              <div class="panel-body">
                <div class="requisitos-list">
                  <div
                    v-for="requisito in filteredRequisitosDisponibles"
                    :key="requisito.req"
                    class="requisito-item"
                  >
                    <label class="checkbox-label">
                      <input
                        type="checkbox"
                        :value="requisito.req"
                        v-model="selectedDisponibles"
                      />
                      <span class="requisito-info">
                        <strong>{{ requisito.req }}</strong>
                        <small class="text-muted">{{ requisito.descripcion }}</small>
                      </span>
                    </label>
                  </div>
                  <div v-if="filteredRequisitosDisponibles.length === 0" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>No hay requisitos disponibles</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Columna Derecha: Requisitos Asignados al Giro -->
          <div class="col-md-6">
            <div class="requisitos-panel">
              <div class="panel-header">
                <h6>
                  <font-awesome-icon icon="check-circle" />
                  Requisitos Asignados
                  <span class="badge-purple">{{ filteredRequisitosAsignados.length }}</span>
                </h6>
                <button
                  class="btn-municipal-danger btn-sm"
                  @click="removeSelectedRequisitos"
                  :disabled="selectedAsignados.length === 0 || loading"
                >
                  <font-awesome-icon icon="arrow-left" />
                  Quitar ({{ selectedAsignados.length }})
                </button>
              </div>
              <div class="panel-body">
                <div class="requisitos-list">
                  <div
                    v-for="requisito in filteredRequisitosAsignados"
                    :key="requisito.req"
                    class="requisito-item requisito-asignado"
                  >
                    <label class="checkbox-label">
                      <input
                        type="checkbox"
                        :value="requisito.req"
                        v-model="selectedAsignados"
                      />
                      <span class="requisito-info">
                        <strong>{{ requisito.req }}</strong>
                        <small class="text-muted">{{ requisito.descripcion }}</small>
                      </span>
                    </label>
                  </div>
                  <div v-if="filteredRequisitosAsignados.length === 0" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay requisitos asignados a este giro</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de acción -->
        <div class="button-group mt-4">
          <button
            class="btn-municipal-secondary"
            @click="selectAllDisponibles"
            :disabled="loading || filteredRequisitosDisponibles.length === 0"
          >
            <font-awesome-icon icon="check-square" />
            Seleccionar Todos Disponibles
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSelections"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar Selección
          </button>
          <button
            class="btn-municipal-secondary"
            @click="selectAllAsignados"
            :disabled="loading || filteredRequisitosAsignados.length === 0"
          >
            <font-awesome-icon icon="check-square" />
            Seleccionar Todos Asignados
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
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
      :componentName="'LigaRequisitos'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const loading = ref(false)

// Estado
const giros = ref([])
const selectedGiroId = ref('')
const selectedGiro = ref(null)
const requisitosDisponibles = ref([])
const requisitosAsignados = ref([])
const selectedDisponibles = ref([])
const selectedAsignados = ref([])
const filterDisponibles = ref('')
const filterAsignados = ref('')

// Computed
const filteredRequisitosDisponibles = computed(() => {
  if (!filterDisponibles.value) return requisitosDisponibles.value

  const filter = filterDisponibles.value.toLowerCase()
  return requisitosDisponibles.value.filter(req =>
    req.req.toString().includes(filter) ||
    req.descripcion.toLowerCase().includes(filter)
  )
})

const filteredRequisitosAsignados = computed(() => {
  if (!filterAsignados.value) return requisitosAsignados.value

  const filter = filterAsignados.value.toLowerCase()
  return requisitosAsignados.value.filter(req =>
    req.req.toString().includes(filter) ||
    req.descripcion.toLowerCase().includes(filter)
  )
})

// Métodos
const loadGiros = async () => {
  const startTime = Date.now()
  showLoading('Cargando giros...')
  loading.value = true

  try {
    const response = await execute(
      'sp_ligarequisitos_giros',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      giros.value = response.result
      const duration = ((Date.now() - startTime) / 1000).toFixed(2)
      showToast('success', `${giros.value.length} giros cargados (${duration}s)`, 3000, 'bottom-right')
    } else {
      giros.value = []
      showToast('error', 'Error al cargar giros', 3000, 'bottom-right')
    }
  } catch (error) {
    handleApiError(error)
    giros.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const onGiroSelected = () => {
  if (selectedGiroId.value) {
    selectedGiro.value = giros.value.find(g => g.id_giro === parseInt(selectedGiroId.value))
    loadRequisitosGiro()
  } else {
    selectedGiro.value = null
    requisitosDisponibles.value = []
    requisitosAsignados.value = []
  }
  clearSelections()
}

const loadRequisitosGiro = async () => {
  const startTime = Date.now()
  showLoading('Cargando requisitos...')
  loading.value = true

  try {
    // Cargar requisitos disponibles
    const disponiblesResponse = await execute(
      'sp_ligarequisitos_available',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: parseInt(selectedGiroId.value), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    // Cargar requisitos asignados
    const asignadosResponse = await execute(
      'sp_ligarequisitos_list',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: parseInt(selectedGiroId.value), tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (disponiblesResponse && disponiblesResponse.result) {
      requisitosDisponibles.value = disponiblesResponse.result
    } else {
      requisitosDisponibles.value = []
    }

    if (asignadosResponse && asignadosResponse.result) {
      requisitosAsignados.value = asignadosResponse.result
    } else {
      requisitosAsignados.value = []
    }

    const duration = ((Date.now() - startTime) / 1000).toFixed(2)
    const totalDisponibles = requisitosDisponibles.value.length
    const totalAsignados = requisitosAsignados.value.length
    showToast('success', `Requisitos cargados: ${totalDisponibles} disponibles, ${totalAsignados} asignados (${duration}s)`, 3000, 'bottom-right')
  } catch (error) {
    handleApiError(error)
    requisitosDisponibles.value = []
    requisitosAsignados.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const addSelectedRequisitos = async () => {
  if (selectedDisponibles.value.length === 0) {
    hideLoading()
    await Swal.fire({
      icon: 'warning',
      title: 'Selección requerida',
      text: 'Por favor seleccione al menos un requisito para agregar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  hideLoading()
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Agregar requisitos seleccionados?',
    text: `Se agregarán ${selectedDisponibles.value.length} requisito(s) al giro`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, agregar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = Date.now()
  showLoading('Agregando requisitos...')
  loading.value = true

  try {
    let successCount = 0
    let errorCount = 0

    for (const reqId of selectedDisponibles.value) {
      try {
        const response = await execute(
          'sp_ligarequisitos_add',
          'padron_licencias',
          [
            { nombre: 'p_id_giro', valor: parseInt(selectedGiroId.value), tipo: 'integer' },
            { nombre: 'p_req', valor: reqId, tipo: 'integer' }
          ],
          'guadalajara',
          null,
          'publico'
        )

        if (response && response.result) {
          successCount++
        } else {
          errorCount++
        }
      } catch (error) {
        errorCount++
      }
    }

    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (successCount > 0) {
      hideLoading()
      await Swal.fire({
        icon: 'success',
        title: 'Requisitos agregados',
        text: `Se agregaron ${successCount} requisito(s) exitosamente${errorCount > 0 ? `. ${errorCount} fallaron.` : ''}`,
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `${successCount} requisito(s) agregado(s) (${duration}s)`, 3000, 'bottom-right')
      loadRequisitosGiro()
      selectedDisponibles.value = []
    } else {
      hideLoading()
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo agregar ningún requisito',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const removeSelectedRequisitos = async () => {
  if (selectedAsignados.value.length === 0) {
    hideLoading()
    await Swal.fire({
      icon: 'warning',
      title: 'Selección requerida',
      text: 'Por favor seleccione al menos un requisito para quitar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  hideLoading()
  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: '¿Quitar requisitos seleccionados?',
    text: `Se quitarán ${selectedAsignados.value.length} requisito(s) del giro`,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, quitar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = Date.now()
  showLoading('Quitando requisitos...')
  loading.value = true

  try {
    let successCount = 0
    let errorCount = 0

    for (const reqId of selectedAsignados.value) {
      try {
        const response = await execute(
          'sp_ligarequisitos_remove',
          'padron_licencias',
          [
            { nombre: 'p_id_giro', valor: parseInt(selectedGiroId.value), tipo: 'integer' },
            { nombre: 'p_req', valor: reqId, tipo: 'integer' }
          ],
          'guadalajara',
          null,
          'publico'
        )

        if (response && response.result) {
          successCount++
        } else {
          errorCount++
        }
      } catch (error) {
        errorCount++
      }
    }

    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (successCount > 0) {
      hideLoading()
      await Swal.fire({
        icon: 'success',
        title: 'Requisitos quitados',
        text: `Se quitaron ${successCount} requisito(s) exitosamente${errorCount > 0 ? `. ${errorCount} fallaron.` : ''}`,
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `${successCount} requisito(s) quitado(s) (${duration}s)`, 3000, 'bottom-right')
      loadRequisitosGiro()
      selectedAsignados.value = []
    } else {
      hideLoading()
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo quitar ningún requisito',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const selectAllDisponibles = () => {
  selectedDisponibles.value = filteredRequisitosDisponibles.value.map(r => r.req)
}

const selectAllAsignados = () => {
  selectedAsignados.value = filteredRequisitosAsignados.value.map(r => r.req)
}

const clearSelections = () => {
  selectedDisponibles.value = []
  selectedAsignados.value = []
}

// Lifecycle
onMounted(() => {
  loadGiros()
})

// Watch para limpiar filtros cuando cambia el giro
watch(selectedGiroId, () => {
  filterDisponibles.value = ''
  filterAsignados.value = ''
})
</script>

<style scoped>
.info-box {
  margin-top: 1.5rem;
  padding: 1.5rem;
  border-radius: 8px;
  border: 2px solid;
}

.info-primary {
  background-color: #cfe2ff;
  border-color: #0d6efd;
}

.info-box h6 {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  font-weight: bold;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item strong {
  font-size: 0.9rem;
  color: #666;
}

.info-item span {
  font-size: 1rem;
}

.row {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.col-md-6 {
  flex: 1;
  min-width: 300px;
}

.requisitos-panel {
  border: 2px solid #dee2e6;
  border-radius: 8px;
  height: 500px;
  display: flex;
  flex-direction: column;
}

.panel-header {
  background-color: #f8f9fa;
  padding: 1rem;
  border-bottom: 2px solid #dee2e6;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h6 {
  margin: 0;
  font-size: 1rem;
  font-weight: bold;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.panel-body {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
}

.requisitos-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.requisito-item {
  padding: 0.75rem;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  background-color: #fff;
  transition: all 0.2s;
}

.requisito-item:hover {
  background-color: #f8f9fa;
  border-color: #adb5bd;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.requisito-asignado {
  background-color: #d4edda;
  border-color: #28a745;
}

.requisito-asignado:hover {
  background-color: #c3e6cb;
}

.checkbox-label {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  cursor: pointer;
  margin: 0;
}

.checkbox-label input[type="checkbox"] {
  margin-top: 0.25rem;
  width: 18px;
  height: 18px;
  cursor: pointer;
  flex-shrink: 0;
}

.requisito-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.requisito-info strong {
  font-size: 0.95rem;
  color: #495057;
}

.requisito-info small {
  font-size: 0.85rem;
  line-height: 1.3;
}

.empty-icon {
  color: #dee2e6;
  margin-bottom: 0.5rem;
}
</style>
