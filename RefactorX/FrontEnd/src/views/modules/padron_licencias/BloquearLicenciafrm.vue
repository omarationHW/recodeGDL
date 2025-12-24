<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="lock" />
      </div>
      <div class="module-view-info">
        <h1>Bloquear/Desbloquear Licencia</h1>
        <p>Padrón de Licencias - Gestión de bloqueos de licencias comerciales</p>
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
      <!-- Búsqueda de Licencia -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Licencia
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarLicencia">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Número de Licencia:</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="searchLicencia"
                    placeholder="Ingrese número de licencia"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="!searchLicencia"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información de la Licencia -->
      <div class="municipal-card" v-if="licenciaData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="file-contract" />
            Información de la Licencia #{{ licenciaData.licencia }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="id-card" />
                Datos Generales
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Licencia:</td>
                  <td><strong>{{ licenciaData.licencia }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ licenciaData.propietario }}</td>
                </tr>
                <tr>
                  <td class="label">RFC:</td>
                  <td><code>{{ licenciaData.rfc || 'N/A' }}</code></td>
                </tr>
                <tr>
                  <td class="label">Actividad:</td>
                  <td>{{ licenciaData.actividad }}</td>
                </tr>
                <tr>
                  <td class="label">Ubicación:</td>
                  <td>{{ licenciaData.ubicacion }}</td>
                </tr>
                <tr>
                  <td class="label">Estado:</td>
                  <td>
                    <span :class="licenciaData.vigente === 'V' ? 'badge-success' : 'badge-danger'" class="badge">
                      <font-awesome-icon :icon="licenciaData.vigente === 'V' ? 'check-circle' : 'times-circle'" />
                      {{ licenciaData.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                    </span>
                  </td>
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
                    <option value="1">BLOQUEADA</option>
                    <option value="2">ESTADO 1</option>
                    <option value="3">CABARET</option>
                    <option value="4">SUSPENSION</option>
                    <option value="5">RESPONSIVA</option>
                    <option value="7">DESGLOSAR LIC</option>
                    <option value="8">PARA REFRENDO</option>
                    <option value="9">SOLVENTACION</option>
                    <option value="10">INACTIVAS SIN PAGO</option>
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
                    maxlength="500"
                    placeholder="Ingrese el motivo del bloqueo"
                    required
                  ></textarea>
                  <small class="form-text text-muted">
                    {{ bloqueoForm.motivo.length }}/500 caracteres
                  </small>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                  >
                    <font-awesome-icon icon="lock" /> Bloquear Licencia
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

          <!-- Lista de Bloqueos Activos -->
          <div class="mt-4" v-if="bloqueos.length > 0">
            <div class="section-title header-with-badge">
              <h6>
                <font-awesome-icon icon="list" />
                Historial de Bloqueos
              </h6>
              <div class="header-right">
                <span class="badge-purple" v-if="bloqueos.length > 0">
                  {{ bloqueos.length }} registros
                </span>
              </div>
            </div>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Tipo</th>
                    <th>Observaciones</th>
                    <th>Fecha</th>
                    <th>Realizó</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(bloqueo, index) in bloqueos"
                    :key="'bloqueo-' + index"
                    @click="selectedRow = bloqueo"
                    :class="{ 'table-row-selected': selectedRow === bloqueo }"
                    class="row-hover"
                  >
                    <td>
                      <span class="badge-warning">
                        {{ bloqueo.tipo_bloqueo_desc || 'BLOQUEADA' }}
                      </span>
                    </td>
                    <td>{{ bloqueo.observa || '-' }}</td>
                    <td>
                      <small class="text-muted">
                        <font-awesome-icon icon="calendar" />
                        {{ formatDate(bloqueo.fecha_mov) }}
                      </small>
                    </td>
                    <td><code>{{ bloqueo.capturista || '-' }}</code></td>
                    <td>
                      <span :class="esBloqueoActivo(bloqueo) ? 'badge-danger' : 'badge-success'" class="badge">
                        <font-awesome-icon :icon="esBloqueoActivo(bloqueo) ? 'lock' : 'unlock'" />
                        {{ esBloqueoActivo(bloqueo) ? 'Bloqueado' : 'Desbloqueado' }}
                      </span>
                    </td>
                    <td>
                      <button
                        v-if="esBloqueoActivo(bloqueo)"
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
        :componentName="'BloquearLicenciafrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Bloquear/Desbloquear Licencia'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchLicencia = ref('')
const licenciaData = ref(null)
const bloqueos = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)

const bloqueoForm = ref({
  tipo: '',
  motivo: ''
})

// Computed - Basado en Delphi: vigente='V' y bloqueado > 0
const hasBloqueosActivos = computed(() => {
  return bloqueos.value.some(b => b.vigente === 'V' && b.bloqueado > 0)
})

// Helper para determinar si un bloqueo está activo (Delphi: vigente='V' y bloqueado > 0)
const esBloqueoActivo = (bloqueo) => {
  return bloqueo.vigente === 'V' && bloqueo.bloqueado > 0
}

// Métodos
const buscarLicencia = async () => {
  if (!searchLicencia.value) return

  const startTime = Date.now()
  showLoading('Buscando licencia...')
  hasSearched.value = true
  selectedRow.value = null

  try {
    const response = await execute(
      'sp_bloquearlicencia_get_licencia',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: searchLicencia.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    hideLoading()
    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      licenciaData.value = response.result[0]
      await cargarBloqueos()
      showToast('success', `Licencia encontrada (${duration}s)`, 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrada',
        text: 'La licencia no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      licenciaData.value = null
      bloqueos.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    licenciaData.value = null
    bloqueos.value = []
  }
}

const cargarBloqueos = async () => {
  try {
    const response = await execute(
      'sp_bloquearlicencia_get_bloqueos',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchLicencia.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      bloqueos.value = response.result
    }
  } catch (error) {
    bloqueos.value = []
    handleApiError(error, 'No se pudieron cargar los bloqueos')
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

  // Confirmación
  const confirm = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear licencia?',
    html: `
      <p>¿Está seguro de bloquear la licencia <strong>#${licenciaData.value.licencia}</strong>?</p>
      <p><strong>Propietario:</strong> ${licenciaData.value.propietario}</p>
      <p><strong>Tipo:</strong> ${bloqueoForm.value.tipo}</p>
      <p><strong>Motivo:</strong> ${bloqueoForm.value.motivo}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Bloqueando licencia...')
  try {
    const response = await execute(
      'sp_bloquearlicencia_bloquear',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchLicencia.value, tipo: 'integer' },
        { nombre: 'p_tipo_bloqueo', valor: parseInt(bloqueoForm.value.tipo), tipo: 'integer' },
        { nombre: 'p_observa', valor: bloqueoForm.value.motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Licencia bloqueada',
        text: 'El bloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      bloqueoForm.value = { tipo: '', motivo: '' }
      await cargarBloqueos()
      showToast('success', 'Licencia bloqueada exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo bloquear la licencia',
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
    title: 'Desbloquear licencia',
    html: `
      <p>Ingrese el motivo del desbloqueo:</p>
      <p><strong>Bloqueo:</strong> ${bloqueo.tipo_bloqueo_desc || 'BLOQUEADA'} - ${bloqueo.observa || ''}</p>
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

  showLoading('Desbloqueando licencia...')
  try {
    // Basado en Delphi: desbloquea por id_licencia, no por id_bloqueo individual
    const response = await execute(
      'sp_bloquearlicencia_desbloquear',
      'padron_licencias',
      [
        { nombre: 'p_id_licencia', valor: searchLicencia.value, tipo: 'integer' },
        { nombre: 'p_observa', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Licencia desbloqueada',
        text: 'El desbloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      await cargarBloqueos()
      showToast('success', 'Licencia desbloqueada exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo desbloquear la licencia',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const limpiarFormulario = () => {
  searchLicencia.value = ''
  licenciaData.value = null
  bloqueos.value = []
  bloqueoForm.value = { tipo: '', motivo: '' }
  hasSearched.value = false
  selectedRow.value = null
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
