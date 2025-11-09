<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Responsivas de Licencias</h1>
        <p>Padrón de Licencias - Gestión de Responsivas y Supervisiones</p></div>
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
          :disabled="loading || !licenciaData"
        >
          <font-awesome-icon icon="plus" />
          Nueva Responsiva
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Selector de Tipo -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Documento:</label>
            <select class="municipal-form-control" v-model="tipoDocumento" @change="loadResponsivas">
              <option value="R">Responsivas</option>
              <option value="S">Supervisiones</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda de Licencia -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Licencia
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia: <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="searchForm.licencia"
              placeholder="Ingrese número de licencia"
              @keyup.enter="searchLicencia"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencia"
            :disabled="loading || !searchForm.licencia"
          >
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearSearch"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Información de Licencia -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="id-card" />
          Información de Licencia: {{ licenciaData.licencia }}
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Datos Generales
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Licencia:</td>
                <td><strong>{{ licenciaData.id_licencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">Número:</td>
                <td><code>{{ licenciaData.licencia }}</code></td>
              </tr>
              <tr>
                <td class="label">Recaudación:</td>
                <td><span class="badge-purple">{{ licenciaData.recaud }}</span></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ licenciaData.propietarionvo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Actividad:</td>
                <td>{{ licenciaData.actividad || 'N/A' }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Dirección:</td>
                <td>{{ formatUbicacion() }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ licenciaData.colonia_ubic || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td>{{ licenciaData.cp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Descripción:</td>
                <td>{{ licenciaData.descripcion || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Búsqueda por Folio -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar por Folio
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Año:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="folioSearch.axo"
              placeholder="Ej: 2025"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Folio:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="folioSearch.folio"
              placeholder="Número de folio"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-info"
            @click="searchByFolio"
            :disabled="loading || !folioSearch.axo || !folioSearch.folio"
          >
            <font-awesome-icon icon="search" />
            Buscar por Folio
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de Responsivas -->
    <div class="municipal-card" v-if="licenciaData">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          {{ tipoDocumento === 'R' ? 'Responsivas' : 'Supervisiones' }} Registradas
          <span class="badge-purple" v-if="responsivas.length > 0">{{ responsivas.length }} registros</span>
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="loadResponsivas"
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
                <th>Año</th>
                <th>Folio</th>
                <th>Licencia</th>
                <th>Tipo</th>
                <th>Observación</th>
                <th>Estado</th>
                <th>Fecha Captura</th>
                <th>Capturista</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="responsiva in responsivas" :key="`${responsiva.axo}-${responsiva.folio}`" class="clickable-row">
                <td><strong>{{ responsiva.axo }}</strong></td>
                <td><code>{{ responsiva.folio }}</code></td>
                <td><span class="badge-purple">{{ responsiva.licencia }}</span></td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(responsiva.tipo)">
                    {{ responsiva.tipo === 'R' ? 'Responsiva' : 'Supervisión' }}
                  </span>
                </td>
                <td>{{ responsiva.observacion?.substring(0, 50) || 'N/A' }}{{ responsiva.observacion?.length > 50 ? '...' : '' }}</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(responsiva.vigente)">
                    <font-awesome-icon :icon="getEstadoIcon(responsiva.vigente)" />
                    {{ responsiva.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(responsiva.feccap) }}
                  </small>
                </td>
                <td>{{ responsiva.capturista || 'N/A' }}</td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="viewResponsiva(responsiva)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      v-if="responsiva.vigente === 'V'"
                      class="btn-municipal-danger btn-sm"
                      @click="confirmCancelResponsiva(responsiva)"
                      title="Cancelar"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="responsivas.length === 0 && !loading">
                <td colspan="9" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No se encontraron {{ tipoDocumento === 'R' ? 'responsivas' : 'supervisiones' }} para esta licencia</p>
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
        <p>Procesando información...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      :title="`Nueva ${tipoDocumento === 'R' ? 'Responsiva' : 'Supervisión'}`"
      size="lg"
      @close="showCreateModal = false"
      @confirm="createResponsiva"
      :loading="creatingResponsiva"
      confirmText="Crear"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="createResponsiva">
        <div class="alert alert-info">
          <font-awesome-icon icon="info-circle" />
          Se creará una {{ tipoDocumento === 'R' ? 'responsiva' : 'supervisión' }} para la licencia: <strong>{{ licenciaData?.licencia }}</strong>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones:</label>
          <textarea
            class="municipal-form-control"
            v-model="newResponsiva.observacion"
            rows="4"
            placeholder="Ingrese observaciones (opcional)"
          ></textarea>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de ${selectedResponsiva?.tipo === 'R' ? 'Responsiva' : 'Supervisión'}: ${selectedResponsiva?.folio}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedResponsiva" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="file-contract" />
              Información del Documento
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Año:</td>
                <td><strong>{{ selectedResponsiva.axo }}</strong></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td><code>{{ selectedResponsiva.folio }}</code></td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>
                  <span class="badge" :class="getTipoBadgeClass(selectedResponsiva.tipo)">
                    {{ selectedResponsiva.tipo === 'R' ? 'Responsiva' : 'Supervisión' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Estado:</td>
                <td>
                  <span class="badge" :class="getEstadoBadgeClass(selectedResponsiva.vigente)">
                    <font-awesome-icon :icon="getEstadoIcon(selectedResponsiva.vigente)" />
                    {{ selectedResponsiva.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Datos de Captura
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Licencia:</td>
                <td>{{ selectedResponsiva.id_licencia }}</td>
              </tr>
              <tr>
                <td class="label">Licencia:</td>
                <td><span class="badge-purple">{{ selectedResponsiva.licencia }}</span></td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="clock" class="text-info" />
                  {{ formatDate(selectedResponsiva.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturista:</td>
                <td>{{ selectedResponsiva.capturista || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="detail-section">
          <h6 class="section-title">
            <font-awesome-icon icon="comment" />
            Observaciones
          </h6>
          <p class="observation-text">{{ selectedResponsiva.observacion || 'Sin observaciones' }}</p>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button
            v-if="selectedResponsiva.vigente === 'V'"
            class="btn-municipal-danger"
            @click="confirmCancelResponsiva(selectedResponsiva); showViewModal = false"
          >
            <font-awesome-icon icon="ban" />
            Cancelar {{ selectedResponsiva.tipo === 'R' ? 'Responsiva' : 'Supervisión' }}
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
      :componentName="'Responsivafrm'"
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
const tipoDocumento = ref('R')
const searchForm = ref({
  licencia: null
})

const folioSearch = ref({
  axo: null,
  folio: null
})

const licenciaData = ref(null)
const responsivas = ref([])
const selectedResponsiva = ref(null)
const showCreateModal = ref(false)
const showViewModal = ref(false)
const creatingResponsiva = ref(false)

const newResponsiva = ref({
  observacion: ''
})

// Métodos
const searchLicencia = async () => {
  if (!searchForm.value.licencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese el número de licencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando licencia...')
  const startTime = performance.now()

  try {
    const response = await execute(
      'buscar_licencia_responsiva',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: searchForm.value.licencia, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]
      await loadResponsivas()
      showToast('success', 'Licencia encontrada correctamente')
      toast.value.duration = durationText
    } else {
      licenciaData.value = null
      responsivas.value = []
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No se encontró la licencia especificada',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    licenciaData.value = null
    responsivas.value = []
  } finally {
    setLoading(false)
  }
}

const loadResponsivas = async () => {
  if (!licenciaData.value) return

  setLoading(true, 'Cargando responsivas...')

  try {
    const response = await execute(
      'buscar_responsiva_licencia',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: licenciaData.value.licencia, tipo: 'integer' },
        { nombre: 'p_tipo', valor: tipoDocumento.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      responsivas.value = response.result
      showToast('success', `${response.result.length} ${tipoDocumento.value === 'R' ? 'responsivas' : 'supervisiones'} encontradas`)
    } else {
      responsivas.value = []
    }
  } catch (error) {
    handleApiError(error)
    responsivas.value = []
  } finally {
    setLoading(false)
  }
}

const searchByFolio = async () => {
  if (!folioSearch.value.axo || !folioSearch.value.folio) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor ingrese año y folio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando por folio...')

  try {
    const response = await execute(
      'buscar_responsiva_folio',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: folioSearch.value.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: folioSearch.value.folio, tipo: 'integer' },
        { nombre: 'p_tipo', valor: tipoDocumento.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      viewResponsiva(response.result[0])
      showToast('success', 'Documento encontrado')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No se encontró el documento con el folio especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const openCreateModal = () => {
  newResponsiva.value = {
    observacion: ''
  }
  showCreateModal.value = true
}

const createResponsiva = async () => {
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: `¿Crear ${tipoDocumento.value === 'R' ? 'responsiva' : 'supervisión'}?`,
    text: `Se creará una nueva ${tipoDocumento.value === 'R' ? 'responsiva' : 'supervisión'} para la licencia ${licenciaData.value.licencia}`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  creatingResponsiva.value = true
  const startTime = performance.now()

  try {
    const usuario = localStorage.getItem('usuario') || 'sistema'
    const response = await execute(
      'crear_responsiva',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_tipo', valor: tipoDocumento.value, tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' },
        { nombre: 'p_observacion', valor: newResponsiva.value.observacion || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      showCreateModal.value = false
      await loadResponsivas()

      await Swal.fire({
        icon: 'success',
        title: `${tipoDocumento.value === 'R' ? 'Responsiva' : 'Supervisión'} creada`,
        text: `Se ha creado exitosamente`,
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `${tipoDocumento.value === 'R' ? 'Responsiva' : 'Supervisión'} creada exitosamente`)
      toast.value.duration = durationText
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingResponsiva.value = false
  }
}

const viewResponsiva = (responsiva) => {
  selectedResponsiva.value = responsiva
  showViewModal.value = true
}

const confirmCancelResponsiva = async (responsiva) => {
  const { value: motivo } = await Swal.fire({
    title: `¿Cancelar ${responsiva.tipo === 'R' ? 'responsiva' : 'supervisión'}?`,
    text: 'Ingrese el motivo de cancelación:',
    input: 'textarea',
    inputPlaceholder: 'Motivo de cancelación...',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar un motivo de cancelación'
      }
    }
  })

  if (motivo) {
    await cancelResponsiva(responsiva, motivo)
  }
}

const cancelResponsiva = async (responsiva, motivo) => {
  setLoading(true, 'Cancelando...')

  try {
    const response = await execute(
      'cancelar_responsiva',
      'padron_licencias',
      [
        { nombre: 'p_axo', valor: responsiva.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: responsiva.folio, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      await loadResponsivas()

      await Swal.fire({
        icon: 'success',
        title: `${responsiva.tipo === 'R' ? 'Responsiva' : 'Supervisión'} cancelada`,
        text: 'El documento ha sido cancelado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Documento cancelado exitosamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const clearSearch = () => {
  searchForm.value = {
    licencia: null
  }
  folioSearch.value = {
    axo: null,
    folio: null
  }
  licenciaData.value = null
  responsivas.value = []
  showToast('info', 'Búsqueda limpiada')
}

// Utilidades
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

const formatUbicacion = () => {
  if (!licenciaData.value) return 'N/A'

  const partes = []
  if (licenciaData.value.ubicacion) partes.push(licenciaData.value.ubicacion)
  if (licenciaData.value.numext_ubic) partes.push(`#${licenciaData.value.numext_ubic}`)
  if (licenciaData.value.letraext_ubic) partes.push(licenciaData.value.letraext_ubic)
  if (licenciaData.value.numint_ubic) partes.push(`Int. ${licenciaData.value.numint_ubic}`)
  if (licenciaData.value.letraint_ubic) partes.push(licenciaData.value.letraint_ubic)

  return partes.length > 0 ? partes.join(' ') : 'N/A'
}

const getTipoBadgeClass = (tipo) => {
  return tipo === 'R' ? 'badge-primary' : 'badge-info'
}

const getEstadoBadgeClass = (vigente) => {
  return vigente === 'V' ? 'badge-success' : 'badge-danger'
}

const getEstadoIcon = (vigente) => {
  return vigente === 'V' ? 'check-circle' : 'times-circle'
}
</script>

