<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Dependencias</h1>
        <p>Padrón de Licencias - Asignación de Dependencias a Inspecciones</p></div>
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
            <label class="municipal-form-label">Número de Trámite</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.tramite"
              placeholder="Ingrese número de trámite"
              @keyup.enter="searchTramite"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchTramite"
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

    <!-- Información del trámite -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Información del Trámite
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-item">
            <span class="label">Trámite:</span>
            <span class="value"><strong>{{ tramiteInfo.tramite }}</strong></span>
          </div>
          <div class="detail-item">
            <span class="label">Contribuyente:</span>
            <span class="value">{{ tramiteInfo.contribuyente || 'N/A' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">Giro:</span>
            <span class="value">{{ tramiteInfo.giro || 'N/A' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">Domicilio:</span>
            <span class="value">{{ tramiteInfo.domicilio || 'N/A' }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Catálogo de dependencias -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="building" />
          Catálogo de Dependencias
        </h5>
        <button
          class="btn-municipal-primary btn-sm"
          @click="openAddInspeccionModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Agregar Inspección
        </button>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 50px">Sel.</th>
                <th>Clave</th>
                <th>Dependencia</th>
                <th>Descripción</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dep in dependencias" :key="dep.clave" class="row-hover">
                <td class="text-center">
                  <input
                    type="checkbox"
                    :value="dep.clave"
                    v-model="selectedDependencias"
                  >
                </td>
                <td><code class="text-primary">{{ dep.clave }}</code></td>
                <td><strong>{{ dep.nombre?.trim() || 'N/A' }}</strong></td>
                <td>{{ dep.descripcion?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="dep.activo ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="dep.activo ? 'check-circle' : 'times-circle'" />
                    {{ dep.activo ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
              </tr>
              <tr v-if="dependencias.length === 0">
                <td colspan="5" class="text-center text-muted">
                  <font-awesome-icon icon="folder-open" size="2x" class="empty-icon" />
                  <p>No hay dependencias disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="button-group" v-if="selectedDependencias.length > 0">
          <button
            class="btn-municipal-primary"
            @click="confirmAddDependencias"
            :disabled="loading"
          >
            <font-awesome-icon icon="plus" />
            Asignar Dependencias Seleccionadas ({{ selectedDependencias.length }})
          </button>
        </div>
      </div>
    </div>

    <!-- Inspecciones asignadas -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="clipboard-list" />
          Inspecciones Asignadas
          <span class="badge-info" v-if="inspecciones.length > 0">{{ inspecciones.length }} inspecciones</span>
        </h5>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Dependencia</th>
                <th>Fecha Asignación</th>
                <th>Fecha Programada</th>
                <th>Estado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="insp in inspecciones" :key="insp.id" class="row-hover">
                <td><code class="text-primary">{{ insp.id }}</code></td>
                <td><strong>{{ insp.dependencia?.trim() || 'N/A' }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(insp.fecha_asignacion) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar-check" />
                    {{ formatDate(insp.fecha_programada) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getInspeccionBadgeClass(insp.estatus)">
                    {{ insp.estatus?.trim() || 'Pendiente' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-secondary btn-sm"
                      @click="confirmDeleteInspeccion(insp)"
                      title="Eliminar inspección"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="inspecciones.length === 0">
                <td colspan="6" class="text-center text-muted">
                  <font-awesome-icon icon="clipboard" size="2x" class="empty-icon" />
                  <p>No hay inspecciones asignadas para este trámite</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Historial de inspecciones -->
    <div class="municipal-card" v-if="tramiteInfo">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Inspecciones
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="loadInspeccionesMemoria"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Dependencia</th>
                <th>Fecha</th>
                <th>Resultado</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(memoria, index) in inspeccionesMemoria" :key="index" class="row-hover">
                <td><strong>{{ memoria.dependencia?.trim() || 'N/A' }}</strong></td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(memoria.fecha) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getResultadoBadgeClass(memoria.resultado)">
                    {{ memoria.resultado?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>{{ memoria.observaciones?.trim() || 'Sin observaciones' }}</td>
              </tr>
              <tr v-if="inspeccionesMemoria.length === 0">
                <td colspan="4" class="text-center text-muted">
                  <font-awesome-icon icon="folder-open" size="2x" class="empty-icon" />
                  <p>No hay historial de inspecciones</p>
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
        <p>Cargando información...</p>
      </div>
    </div>

    <!-- Modal para agregar inspección -->
    <Modal
      :show="showAddInspeccionModal"
      title="Agregar Nueva Inspección"
      size="lg"
      @close="showAddInspeccionModal = false"
      @confirm="addInspeccion"
      :loading="addingInspeccion"
      confirmText="Agregar Inspección"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="addInspeccion">
        <div class="form-group full-width">
          <label class="municipal-form-label">Dependencia: <span class="required">*</span></label>
          <select class="municipal-form-control" v-model="newInspeccion.dependencia" required>
            <option value="">Seleccionar dependencia...</option>
            <option v-for="dep in dependencias" :key="dep.clave" :value="dep.clave">
              {{ dep.nombre?.trim() }}
            </option>
          </select>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Fecha Programada: <span class="required">*</span></label>
          <input
            type="date"
            class="municipal-form-control"
            v-model="newInspeccion.fecha_programada"
            required
          >
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="newInspeccion.observaciones"
            rows="3"
            placeholder="Observaciones adicionales..."
          ></textarea>
        </div>
      </form>
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
      :componentName="'dependenciasfrm'"
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
const tramiteInfo = ref(null)
const dependencias = ref([])
const inspecciones = ref([])
const inspeccionesMemoria = ref([])
const selectedDependencias = ref([])
const showAddInspeccionModal = ref(false)
const addingInspeccion = ref(false)

// Filtros
const filters = ref({
  tramite: ''
})

// Formulario
const newInspeccion = ref({
  dependencia: '',
  fecha_programada: '',
  observaciones: ''
})

// Métodos
const searchTramite = async () => {
  if (!filters.value.tramite) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un número de trámite',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando información del trámite...')

  try {
    // Obtener información del trámite
    const tramiteResponse = await execute(
      'dependencias_sp_get_tramite_info',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (tramiteResponse && tramiteResponse.result && tramiteResponse.result.length > 0) {
      tramiteInfo.value = tramiteResponse.result[0]
      await loadDependencias()
      await loadInspecciones()
      await loadInspeccionesMemoria()
      showToast('success', 'Información del trámite cargada correctamente')
    } else {
      tramiteInfo.value = null
      dependencias.value = []
      inspecciones.value = []
      inspeccionesMemoria.value = []
      await Swal.fire({
        icon: 'error',
        title: 'Trámite no encontrado',
        text: 'No se encontró información para el trámite especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    tramiteInfo.value = null
    dependencias.value = []
    inspecciones.value = []
    inspeccionesMemoria.value = []
  } finally {
    setLoading(false)
  }
}

const loadDependencias = async () => {
  try {
    const response = await execute(
      'dependencias_sp_get_dependencias',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      dependencias.value = response.result
    } else {
      dependencias.value = []
    }
  } catch (error) {
    handleApiError(error)
    dependencias.value = []
  }
}

const loadInspecciones = async () => {
  if (!filters.value.tramite) return

  try {
    const response = await execute(
      'dependencias_sp_get_inspecciones',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      inspecciones.value = response.result
    } else {
      inspecciones.value = []
    }
  } catch (error) {
    handleApiError(error)
    inspecciones.value = []
  }
}

const loadInspeccionesMemoria = async () => {
  if (!filters.value.tramite) return

  setLoading(true, 'Cargando historial...')

  try {
    const response = await execute(
      'dependencias_sp_get_inspecciones_memoria',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      inspeccionesMemoria.value = response.result
      showToast('success', 'Historial cargado correctamente')
    } else {
      inspeccionesMemoria.value = []
    }
  } catch (error) {
    handleApiError(error)
    inspeccionesMemoria.value = []
  } finally {
    setLoading(false)
  }
}

const confirmAddDependencias = async () => {
  if (selectedDependencias.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Ninguna dependencia seleccionada',
      text: 'Por favor seleccione al menos una dependencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const result = await Swal.fire({
    title: '¿Asignar dependencias?',
    text: `Se asignarán ${selectedDependencias.value.length} dependencia(s) a este trámite`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, asignar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await addDependenciasToInspeccion()
  }
}

const addDependenciasToInspeccion = async () => {
  setLoading(true, 'Asignando dependencias...')

  try {
    for (const claveDep of selectedDependencias.value) {
      await execute(
        'dependencias_sp_add_dependencia_inspeccion',
        'padron_licencias',
        [
          { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' },
          { nombre: 'p_clave_dependencia', valor: claveDep, tipo: 'string' }
        ],
        'guadalajara'
      )
    }

    selectedDependencias.value = []
    await loadInspecciones()

    await Swal.fire({
      icon: 'success',
      title: 'Dependencias asignadas',
      text: 'Las dependencias han sido asignadas correctamente',
      confirmButtonColor: '#ea8215',
      timer: 2000
    })

    showToast('success', 'Dependencias asignadas exitosamente')
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const openAddInspeccionModal = () => {
  newInspeccion.value = {
    dependencia: '',
    fecha_programada: '',
    observaciones: ''
  }
  showAddInspeccionModal.value = true
}

const addInspeccion = async () => {
  if (!newInspeccion.value.dependencia || !newInspeccion.value.fecha_programada) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar nueva inspección?',
    text: 'Se agregará una nueva inspección para este trámite',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, agregar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  addingInspeccion.value = true

  try {
    const response = await execute(
      'dependencias_sp_add_inspeccion',
      'padron_licencias',
      [
        { nombre: 'p_tramite', valor: filters.value.tramite, tipo: 'string' },
        { nombre: 'p_clave_dependencia', valor: newInspeccion.value.dependencia, tipo: 'string' },
        { nombre: 'p_fecha_programada', valor: newInspeccion.value.fecha_programada, tipo: 'date' },
        { nombre: 'p_observaciones', valor: newInspeccion.value.observaciones || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      showAddInspeccionModal.value = false
      await loadInspecciones()

      await Swal.fire({
        icon: 'success',
        title: 'Inspección agregada',
        text: 'La inspección ha sido agregada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Inspección agregada exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al agregar inspección',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    addingInspeccion.value = false
  }
}

const confirmDeleteInspeccion = async (inspeccion) => {
  const result = await Swal.fire({
    title: '¿Eliminar inspección?',
    text: `¿Está seguro de eliminar la inspección de "${inspeccion.dependencia?.trim()}"?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await deleteInspeccion(inspeccion)
  }
}

const deleteInspeccion = async (inspeccion) => {
  setLoading(true, 'Eliminando inspección...')

  try {
    const response = await execute(
      'dependencias_sp_delete_inspeccion',
      'padron_licencias',
      [
        { nombre: 'p_id_inspeccion', valor: inspeccion.id, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await loadInspecciones()

      await Swal.fire({
        icon: 'success',
        title: 'Inspección eliminada',
        text: 'La inspección ha sido eliminada correctamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Inspección eliminada exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const clearFilters = () => {
  filters.value = {
    tramite: ''
  }
  tramiteInfo.value = null
  dependencias.value = []
  inspecciones.value = []
  inspeccionesMemoria.value = []
  selectedDependencias.value = []
}

// Utilidades
const getInspeccionBadgeClass = (estatus) => {
  const classes = {
    'Pendiente': 'badge-warning',
    'En Proceso': 'badge-info',
    'Completada': 'badge-success',
    'Cancelada': 'badge-danger'
  }
  return classes[estatus] || 'badge-secondary'
}

const getResultadoBadgeClass = (resultado) => {
  const classes = {
    'Aprobado': 'badge-success',
    'Rechazado': 'badge-danger',
    'Pendiente': 'badge-warning'
  }
  return classes[resultado] || 'badge-secondary'
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
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  // Componente listo
})

onBeforeUnmount(() => {
  showAddInspeccionModal.value = false
})
</script>
