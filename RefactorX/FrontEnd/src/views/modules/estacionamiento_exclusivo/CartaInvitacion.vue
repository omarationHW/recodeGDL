<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="envelope" />
      </div>
      <div class="module-view-info">
        <h1>Carta Invitación</h1>
        <p>Estacionamiento Exclusivo - Generación de cartas de invitación</p>
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
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                class="municipal-form-control"
                v-model="form.expediente"
                placeholder="Número de folio"
                @keyup.enter="generar"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!form.expediente"
              @click="generar"
            >
              <font-awesome-icon icon="file-pdf" />
              Generar Carta
            </button>
            <button class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
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
        :componentName="'CartaInvitacion'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Carta Invitación'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

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

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'sp_carta_invitacion'

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
const form = ref({ expediente: '' })
const selectedRow = ref(null)
const hasSearched = ref(false)

// Métodos
const generar = async () => {
  if (!form.value.expediente) {
    showToast('error', 'Debe ingresar expediente')
    return
  }

  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Generar carta de invitación?',
    text: `Folio: ${form.value.expediente}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, generar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })

  if (!confirm.isConfirmed) return

  showLoading('Generando carta...', 'Procesando documento')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_folio', type: 'C', value: String(form.value.expediente || '') }
    ])

    let data = {}
    if (response && response.data) {
      data = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      data = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    await Swal.fire({
      icon: 'success',
      title: 'Carta generada',
      html: `<b>Folio:</b> ${data.folio || 'N/A'}<br><b>Nombre:</b> ${data.nombre || 'N/A'}<br><b>Importe:</b> ${data.importe || 0}<br>Procesado en ${durationText}`,
      timer: 3000
    })

    toast.value.duration = durationText
    showToast('success', 'Carta de invitación generada correctamente')
    limpiar()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = { expediente: '' }
  hasSearched.value = false
  selectedRow.value = null
}
</script>
