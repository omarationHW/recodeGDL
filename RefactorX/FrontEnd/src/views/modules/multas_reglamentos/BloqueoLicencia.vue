<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="lock" />
      </div>
      <div class="module-view-info">
        <h1>Bloqueo de Licencias</h1>
        <p>Multas y Reglamentos - Bloqueo/Desbloqueo de Licencias para Requerimiento</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Busqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Numero de Licencia</label>
              <input type="number" class="municipal-form-control" v-model="filters.licencia"
                placeholder="Ingrese numero de licencia" @keyup.enter="buscar" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Resultado</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="licenciaData">
              Licencia: {{ licenciaData.licencia }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Ingrese un numero de licencia para buscar</p>
            </div>
          </div>

          <div v-else-if="!licenciaData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro la licencia especificada</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="id-card" /> Datos de la Licencia</h6>
                <table class="detail-table">
                  <tr><td class="label">Licencia:</td><td><strong class="text-primary">{{ licenciaData.licencia }}</strong></td></tr>
                  <tr><td class="label">Propietario:</td><td>{{ licenciaData.propietario || 'N/A' }}</td></tr>
                  <tr><td class="label">Giro:</td><td>{{ licenciaData.giro || 'N/A' }}</td></tr>
                  <tr><td class="label">Ubicacion:</td><td>{{ licenciaData.ubicacion || 'N/A' }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="lock" /> Estado de Bloqueo</h6>
                <table class="detail-table">
                  <tr>
                    <td class="label">Estado:</td>
                    <td>
                      <span class="badge" :class="licenciaData.bloqueado ? 'badge-danger' : 'badge-success'">
                        <font-awesome-icon :icon="licenciaData.bloqueado ? 'lock' : 'lock-open'" />
                        {{ licenciaData.bloqueado ? 'Bloqueado' : 'Desbloqueado' }}
                      </span>
                    </td>
                  </tr>
                  <tr v-if="licenciaData.fecha_bloqueo"><td class="label">Fecha Bloqueo:</td><td>{{ formatDate(licenciaData.fecha_bloqueo) }}</td></tr>
                  <tr v-if="licenciaData.observaciones"><td class="label">Observaciones:</td><td>{{ licenciaData.observaciones }}</td></tr>
                </table>
              </div>
            </div>

            <div class="button-group">
              <button v-if="!licenciaData.bloqueado" class="btn-municipal-danger" @click="abrirModalBloqueo" :disabled="loading">
                <font-awesome-icon icon="lock" /> Bloquear Licencia
              </button>
              <button v-else class="btn-municipal-success" @click="confirmarDesbloqueo" :disabled="loading">
                <font-awesome-icon icon="lock-open" /> Desbloquear Licencia
              </button>
              <button class="btn-municipal-info" @click="generarReporte" :disabled="loading">
                <font-awesome-icon icon="file-pdf" /> Generar Reporte
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <Modal :show="showModalBloqueo" size="lg" @close="cerrarModalBloqueo" :showDefaultFooter="false">
      <template #header>
        <h5 class="modal-title"><font-awesome-icon icon="lock" class="me-2" /> Bloquear Licencia</h5>
      </template>

      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Observaciones <span class="required">*</span></label>
          <textarea class="municipal-form-control" v-model="formBloqueo.observaciones"
            placeholder="Ingrese las observaciones del bloqueo" rows="4"></textarea>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="cerrarModalBloqueo">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button class="btn-municipal-danger" @click="bloquearLicencia" :disabled="loading">
          <font-awesome-icon icon="lock" /> Confirmar Bloqueo
        </button>
      </div>
    </Modal>

    <DocumentationModal :show="showDocModal" :componentName="'BloqueoLicencia'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Bloqueo de Licencias'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const licenciaData = ref(null)
const showModalBloqueo = ref(false)
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ licencia: '' })
const formBloqueo = ref({ observaciones: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }

const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const buscar = async () => {
  if (!filters.value.licencia) {
    showToast('warning', 'Debe ingresar el numero de licencia')
    return
  }

  showLoading('Buscando licencia...', 'Consultando base de datos')
  searchPerformed.value = true

  try {
    const response = await execute('sp_bloqueolic_consulta', 'multas_reglamentos',
      [{ nombre: 'p_licencia', valor: parseInt(filters.value.licencia), tipo: 'integer' }],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      licenciaData.value = response.result[0]
      showToast('success', 'Licencia encontrada')
    } else {
      licenciaData.value = null
      showToast('info', 'No se encontro la licencia')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar licencia')
    licenciaData.value = null
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  filters.value = { licencia: '' }
  licenciaData.value = null
  searchPerformed.value = false
}

const abrirModalBloqueo = () => {
  formBloqueo.value = { observaciones: '' }
  showModalBloqueo.value = true
}

const cerrarModalBloqueo = () => { showModalBloqueo.value = false }

const bloquearLicencia = async () => {
  if (!formBloqueo.value.observaciones.trim()) {
    await Swal.fire({ icon: 'warning', title: 'Campo requerido', text: 'Debe ingresar las observaciones', confirmButtonColor: '#ea8215' })
    return
  }

  const confirm = await Swal.fire({
    icon: 'warning', title: 'Confirmar bloqueo',
    html: `<p>Esta seguro de bloquear la licencia <strong>${licenciaData.value.licencia}</strong>?</p>`,
    showCancelButton: true, confirmButtonColor: '#dc3545', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, bloquear', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Bloqueando licencia...', 'Por favor espere')

  try {
    const response = await execute('sp_bloqueolic_bloquear', 'multas_reglamentos',
      [
        { nombre: 'p_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_observaciones', valor: formBloqueo.value.observaciones, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      cerrarModalBloqueo()
      await Swal.fire({ icon: 'success', title: 'Licencia bloqueada', text: 'La licencia ha sido bloqueada exitosamente', confirmButtonColor: '#ea8215', timer: 2000 })
      buscar()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: response?.result?.[0]?.message || 'No se pudo bloquear', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al bloquear licencia')
  }
}

const confirmarDesbloqueo = async () => {
  const confirm = await Swal.fire({
    icon: 'question', title: 'Confirmar desbloqueo',
    html: `<p>Esta seguro de desbloquear la licencia <strong>${licenciaData.value.licencia}</strong>?</p>`,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, desbloquear', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Desbloqueando licencia...', 'Por favor espere')

  try {
    const response = await execute('sp_bloqueolic_desbloquear', 'multas_reglamentos',
      [
        { nombre: 'p_licencia', valor: licenciaData.value.id_licencia, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({ icon: 'success', title: 'Licencia desbloqueada', text: 'La licencia ha sido desbloqueada exitosamente', confirmButtonColor: '#ea8215', timer: 2000 })
      buscar()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: response?.result?.[0]?.message || 'No se pudo desbloquear', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al desbloquear licencia')
  }
}

const generarReporte = () => { showToast('info', 'Funcion de reporte en desarrollo') }

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch { return 'N/A' }
}

onMounted(() => { showFilters.value = true })
</script>
