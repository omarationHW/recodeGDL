<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Bloquear/Desbloquear Trámite</h1>
        <p>Padrón de Licencias - Gestión de bloqueos de trámites</p></div>
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
      <!-- Búsqueda de Trámite -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Trámite
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">ID del Trámite:</label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="searchTramite"
                    placeholder="Ingrese ID del trámite"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="loading || !searchTramite"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Trámite -->
      <div class="municipal-card" v-if="tramiteData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-invoice" />
            Información del Trámite #{{ tramiteData.id_tramite }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Datos del Trámite
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">ID Trámite:</td>
                  <td><strong>{{ tramiteData.id_tramite }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Licencia:</td>
                  <td><code>{{ tramiteData.licencia }}</code></td>
                </tr>
                <tr>
                  <td class="label">Tipo:</td>
                  <td>{{ tramiteData.tipo_tramite }}</td>
                </tr>
                <tr>
                  <td class="label">Giro:</td>
                  <td>{{ giroDescripcion || 'Cargando...' }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha:</td>
                  <td>{{ formatDate(tramiteData.fecha) }}</td>
                </tr>
                <tr>
                  <td class="label">Estado:</td>
                  <td>
                    <span :class="getEstadoBadgeClass(tramiteData.estatus)" class="badge">
                      {{ getEstadoText(tramiteData.estatus) }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Información Adicional
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Solicitante:</td>
                  <td>{{ tramiteData.solicitante || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">RFC:</td>
                  <td><code>{{ tramiteData.rfc || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>{{ tramiteData.domicilio || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Usuario Captura:</td>
                  <td><code>{{ tramiteData.usuario_captura }}</code></td>
                </tr>
                <tr>
                  <td class="label">Observaciones:</td>
                  <td>{{ tramiteData.observaciones || 'Sin observaciones' }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Formulario de Bloqueo -->
          <div class="mt-4" v-if="!hasBloqueosActivos">
            <h6 class="section-title">
              <font-awesome-icon icon="lock" />
              Registrar Bloqueo
            </h6>
            <form @submit.prevent="confirmarBloqueo">
              <div class="form-row">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Tipo de Bloqueo *:</label>
                  <select
                    class="municipal-form-control"
                    v-model="bloqueoForm.tipo"
                    required
                  >
                    <option value="">Seleccione un tipo...</option>
                    <option value="ADMINISTRATIVO">Administrativo</option>
                    <option value="JURIDICO">Jurídico</option>
                    <option value="FISCAL">Fiscal</option>
                    <option value="TECNICO">Técnico</option>
                    <option value="DOCUMENTACION">Documentación incompleta</option>
                  </select>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Motivo del bloqueo *:</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bloqueoForm.motivo"
                    rows="3"
                    placeholder="Ingrese el motivo del bloqueo"
                    required
                  ></textarea>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                    :disabled="loading"
                  >
                    <font-awesome-icon icon="lock" /> Bloquear Trámite
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="limpiarFormulario"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>

          <!-- Historial de Bloqueos -->
          <div class="mt-4" v-if="bloqueos.length > 0">
            <h6 class="section-title">
              <font-awesome-icon icon="history" />
              Historial de Bloqueos ({{ bloqueos.length }})
            </h6>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Tipo</th>
                    <th>Motivo Bloqueo</th>
                    <th>Fecha Bloqueo</th>
                    <th>Usuario Bloqueo</th>
                    <th>Motivo Desbloqueo</th>
                    <th>Fecha Desbloqueo</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="bloqueo in bloqueos" :key="bloqueo.id_bloqueo" class="row-hover">
                    <td>
                      <span class="badge-warning">
                        {{ bloqueo.tipo }}
                      </span>
                    </td>
                    <td>{{ bloqueo.motivo_bloqueo }}</td>
                    <td>
                      <small class="text-muted">
                        <font-awesome-icon icon="calendar" />
                        {{ formatDate(bloqueo.fecha_bloqueo) }}
                      </small>
                    </td>
                    <td><code>{{ bloqueo.usuario_bloqueo }}</code></td>
                    <td>{{ bloqueo.motivo_desbloqueo || '-' }}</td>
                    <td>
                      <small class="text-muted">
                        {{ formatDate(bloqueo.fecha_desbloqueo) }}
                      </small>
                    </td>
                    <td>
                      <span :class="bloqueo.activo ? 'badge-danger' : 'badge-success'" class="badge">
                        <font-awesome-icon :icon="bloqueo.activo ? 'lock' : 'unlock'" />
                        {{ bloqueo.activo ? 'Bloqueado' : 'Desbloqueado' }}
                      </span>
                    </td>
                    <td>
                      <button
                        v-if="bloqueo.activo"
                        class="btn-municipal-success btn-sm"
                        @click="confirmarDesbloqueo(bloqueo)"
                        title="Desbloquear"
                      >
                        <font-awesome-icon icon="unlock" /> Desbloquear
                      </button>
                      <span v-else class="text-muted">-</span>
                    </td>
                  </tr>
                </tbody>
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
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'BloquearTramitefrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
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
  loadingMessage,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchTramite = ref(null)
const tramiteData = ref(null)
const bloqueos = ref([])
const giroDescripcion = ref('')

const bloqueoForm = ref({
  tipo: '',
  motivo: ''
})

// Computed
const hasBloqueosActivos = computed(() => {
  return bloqueos.value.some(b => b.activo)
})

// Métodos
const buscarTramite = async () => {
  if (!searchTramite.value) return

  setLoading(true, 'Buscando trámite...')
  try {
    const response = await execute(
      'GET_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]
      await Promise.all([cargarBloqueos(), cargarGiroDescripcion()])
      showToast('success', 'Trámite encontrado')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      tramiteData.value = null
      bloqueos.value = []
      giroDescripcion.value = ''
    }
  } catch (error) {
    handleApiError(error)
    tramiteData.value = null
    bloqueos.value = []
    giroDescripcion.value = ''
  } finally {
    setLoading(false)
  }
}

const cargarBloqueos = async () => {
  try {
    const response = await execute(
      'GET_BLOQUEOS',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      bloqueos.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar bloqueos:', error)
    bloqueos.value = []
  }
}

const cargarGiroDescripcion = async () => {
  if (!tramiteData.value?.giro) return

  try {
    const response = await execute(
      'GET_GIRO_DESCRIPCION',
      'padron_licencias',
      [
        { nombre: 'p_giro', valor: tramiteData.value.giro, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      giroDescripcion.value = response.result[0].descripcion
    }
  } catch (error) {
    console.error('Error al cargar descripción del giro:', error)
    giroDescripcion.value = tramiteData.value.giro
  }
}

const confirmarBloqueo = async () => {
  if (!bloqueoForm.value.tipo || !bloqueoForm.value.motivo.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Debe completar todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Primera confirmación
  const firstConfirm = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear trámite?',
    html: `
      <p>¿Está seguro de bloquear el trámite <strong>#${tramiteData.value.id_tramite}</strong>?</p>
      <p><strong>Tipo:</strong> ${bloqueoForm.value.tipo}</p>
      <p><strong>Motivo:</strong> ${bloqueoForm.value.motivo}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Continuar',
    cancelButtonText: 'Cancelar'
  })

  if (!firstConfirm.isConfirmed) return

  // Segunda confirmación
  const secondConfirm = await Swal.fire({
    icon: 'question',
    title: 'Confirmación final',
    html: `
      <p class="text-danger"><strong>Esta acción bloqueará el trámite</strong></p>
      <p>¿Desea continuar?</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!secondConfirm.isConfirmed) return

  setLoading(true, 'Bloqueando trámite...')
  try {
    const response = await execute(
      'SP_BLOQUEAR_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' },
        { nombre: 'p_tipo', valor: bloqueoForm.value.tipo, tipo: 'string' },
        { nombre: 'p_motivo', valor: bloqueoForm.value.motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Trámite bloqueado',
        text: 'El bloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      bloqueoForm.value = { tipo: '', motivo: '' }
      await cargarBloqueos()
      showToast('success', 'Trámite bloqueado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo bloquear el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const confirmarDesbloqueo = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Desbloquear trámite',
    html: `
      <p>Ingrese el motivo del desbloqueo:</p>
      <p><strong>Bloqueo:</strong> ${bloqueo.tipo} - ${bloqueo.motivo_bloqueo}</p>
    `,
    input: 'textarea',
    inputPlaceholder: 'Motivo del desbloqueo...',
    inputAttributes: {
      'aria-label': 'Motivo del desbloqueo',
      rows: 3
    },
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Desbloquear',
    cancelButtonText: 'Cancelar',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar el motivo del desbloqueo'
      }
    }
  })

  if (!motivo) return

  setLoading(true, 'Desbloqueando trámite...')
  try {
    const response = await execute(
      'SP_DESBLOQUEAR_TRAMITE',
      'padron_licencias',
      [
        { nombre: 'p_id_bloqueo', valor: bloqueo.id_bloqueo, tipo: 'integer' },
        { nombre: 'p_motivo_desbloqueo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Trámite desbloqueado',
        text: 'El desbloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      await cargarBloqueos()
      showToast('success', 'Trámite desbloqueado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo desbloquear el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const limpiarFormulario = () => {
  searchTramite.value = null
  tramiteData.value = null
  bloqueos.value = []
  giroDescripcion.value = ''
  bloqueoForm.value = { tipo: '', motivo: '' }
}

const getEstadoBadgeClass = (estatus) => {
  const classes = {
    'A': 'badge-success',
    'P': 'badge-warning',
    'C': 'badge-danger',
    'T': 'badge-info'
  }
  return classes[estatus] || 'badge-secondary'
}

const getEstadoText = (estatus) => {
  const estados = {
    'A': 'Activo',
    'P': 'Pendiente',
    'C': 'Cancelado',
    'T': 'Terminado'
  }
  return estados[estatus] || 'Desconocido'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}
</script>
