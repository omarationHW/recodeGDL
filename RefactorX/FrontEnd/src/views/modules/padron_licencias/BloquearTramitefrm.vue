<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Bloquear/Desbloquear Trámite</h1>
        <p>Padrón de Licencias - Gestión de bloqueos de trámites</p>
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
                    :disabled="!searchTramite"
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
              Bloquear Trámite
            </h6>
            <form @submit.prevent="confirmarBloqueo">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Observaciones *:</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="bloqueoForm.observa"
                    maxlength="80"
                    placeholder="Ingrese las observaciones del bloqueo"
                    required
                  />
                  <small class="form-text text-muted">
                    {{ bloqueoForm.observa.length }}/80 caracteres
                  </small>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
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
            <h6 class="section-title header-with-badge">
              <span>
                <font-awesome-icon icon="history" />
                Historial de Bloqueos
              </span>
              <span class="badge badge-purple">{{ bloqueos.length }}</span>
            </h6>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Estado</th>
                    <th>Realizó</th>
                    <th>Fecha</th>
                    <th>Motivo</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(bloqueo, index) in bloqueos"
                    :key="index"
                    @click="selectedRow = bloqueo"
                    :class="{ 'table-row-selected': selectedRow === bloqueo }"
                    class="row-hover"
                  >
                    <td>
                      <span :class="bloqueo.bloqueado === 1 ? 'badge-danger' : 'badge-success'" class="badge">
                        <font-awesome-icon :icon="bloqueo.bloqueado === 1 ? 'lock' : 'unlock'" />
                        {{ bloqueo.estado }}
                      </span>
                    </td>
                    <td><code>{{ bloqueo.capturista }}</code></td>
                    <td>
                      <small class="text-muted">
                        <font-awesome-icon icon="calendar" />
                        {{ formatDate(bloqueo.fecha_mov) }}
                      </small>
                    </td>
                    <td>{{ bloqueo.observa || '-' }}</td>
                    <td>
                      <button
                        v-if="bloqueo.vigente === 'V' && bloqueo.bloqueado === 1"
                        class="btn-municipal-success btn-sm"
                        @click.stop="confirmarDesbloqueo(bloqueo)"
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
        :componentName="'BloquearTramitefrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Bloquear/Desbloquear Trámite'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

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

// Estado
const searchTramite = ref(null)
const tramiteData = ref(null)
const bloqueos = ref([])
const giroDescripcion = ref('')
const selectedRow = ref(null)
const hasSearched = ref(false)

const bloqueoForm = ref({
  observa: ''
})

// Computed
const hasBloqueosActivos = computed(() => {
  return bloqueos.value.some(b => b.vigente === 'V' && b.bloqueado === 1)
})

// Métodos
const buscarTramite = async () => {
  if (!searchTramite.value) return

  const startTime = Date.now()
  showLoading('Buscando trámite...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const response = await execute(
      'sp_bloqueartramite_get_tramite',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()
    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      tramiteData.value = response.result[0]
      await Promise.all([cargarBloqueos(), cargarGiroDescripcion()])
      showToast('success', `Trámite encontrado (${duration}s)`, 3000, 'bottom-right')
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
    hideLoading()
    handleApiError(error)
    tramiteData.value = null
    bloqueos.value = []
    giroDescripcion.value = ''
  }
}

const cargarBloqueos = async () => {
  try {
    const response = await execute(
      'sp_bloqueartramite_get_bloqueos',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result) {
      bloqueos.value = response.result
    }
  } catch (error) {
    bloqueos.value = []
    handleApiError(error, 'No se pudieron cargar los bloqueos')
  }
}

const cargarGiroDescripcion = async () => {
  if (!tramiteData.value?.giro) return

  try {
    const response = await execute(
      'sp_bloqueartramite_get_giro',
      'padron_licencias',
      [
        { nombre: 'p_giro', valor: tramiteData.value.giro, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      giroDescripcion.value = response.result[0].descripcion
    }
  } catch (error) {
    giroDescripcion.value = tramiteData.value.giro
    handleApiError(error, 'No se pudo cargar la descripción del giro')
  }
}

const confirmarBloqueo = async () => {
  if (!bloqueoForm.value.observa.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Debe ingresar las observaciones',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación (igual que en Delphi: inputbox)
  const confirm = await Swal.fire({
    icon: 'warning',
    title: 'Bloqueando trámite...',
    html: `
      <p>¿Está seguro de bloquear el trámite <strong>#${tramiteData.value.id_tramite}</strong>?</p>
      <p><strong>Observaciones:</strong> ${bloqueoForm.value.observa}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Bloqueando trámite...', 'Registrando bloqueo')
  try {
    const response = await execute(
      'sp_bloqueartramite_bloquear',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: searchTramite.value, tipo: 'integer' },
        { nombre: 'p_tipo', valor: '', tipo: 'string' },
        { nombre: 'p_motivo', valor: bloqueoForm.value.observa, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Trámite bloqueado',
        text: 'El bloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      bloqueoForm.value = { observa: '' }
      await cargarBloqueos()
      showToast('success', 'Trámite bloqueado exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo bloquear el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const confirmarDesbloqueo = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Desbloquear trámite',
    html: `
      <p>Ingrese el motivo del desbloqueo:</p>
      <p><strong>Motivo bloqueo:</strong> ${bloqueo.observa || 'Sin motivo'}</p>
    `,
    input: 'textarea',
    inputPlaceholder: 'Observaciones...',
    inputAttributes: {
      'aria-label': 'Observaciones del desbloqueo',
      rows: 3
    },
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Desbloquear',
    cancelButtonText: 'Cancelar',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar las observaciones'
      }
    }
  })

  if (!motivo) return

  showLoading('Desbloqueando trámite...', 'Procesando desbloqueo')
  try {
    const response = await execute(
      'sp_bloqueartramite_desbloquear',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: bloqueo.id_tramite, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Trámite desbloqueado',
        text: 'El desbloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      await cargarBloqueos()
      showToast('success', 'Trámite desbloqueado exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo desbloquear el trámite',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const limpiarFormulario = () => {
  searchTramite.value = null
  tramiteData.value = null
  bloqueos.value = []
  giroDescripcion.value = ''
  bloqueoForm.value = { observa: '' }
  hasSearched.value = false
  selectedRow.value = null
}

const getEstadoBadgeClass = (estatus) => {
  const classes = {
    'A': 'badge-success',
    'P': 'badge-warning',
    'C': 'badge-danger',
    'T': 'badge-purple'
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
