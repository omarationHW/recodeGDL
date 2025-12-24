<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="screwdriver-wrench" />
      </div>
      <div class="module-view-info">
        <h1>Modificar Bien</h1>
        <p>Estacionamiento Exclusivo - Modificación de bienes embargables</p>
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
      <!-- Formulario de Modificación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario de Modificación
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Bien (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="10"
                v-model="jsonPayload"
                placeholder='{"id":"123","tipo":"inmueble","descripcion":"..."}'
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" />
              Guardar Cambios
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
        :componentName="'Modificar_bien'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Modificar Bien'"
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

// Constantes
const BASE_DB = 'estacionamiento_exclusivo'
const OP_MODIFICAR = 'sp_modificar_bien'

// Estado
const form = ref({ folio: null, modulo: null, recaudadora: null })
const jsonPayload = ref('')
const selectedRow = ref(null)
const hasSearched = ref(false)

// Métodos
const guardar = async () => {
  if (!jsonPayload.value) {
    showToast('error', 'Debe ingresar datos JSON del bien')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Confirmar modificación?',
    text: 'Se modificará el bien con los datos JSON proporcionados',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, modificar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Guardando cambios...', 'Modificando bien')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(OP_MODIFICAR, BASE_DB, [
      { name: 'datos', type: 'C', value: jsonPayload.value }
    ])

    let arr = {}
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }

    const mensaje = arr?.result || arr?.mensaje || 'Bien modificado'
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    toast.value.duration = durationText

    await Swal.fire({
      title: '¡Éxito!',
      text: `${mensaje} (${durationText})`,
      icon: 'success',
      confirmButtonText: 'OK'
    })

    showToast('success', mensaje)
    limpiar()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = { folio: null, modulo: null, recaudadora: null }
  jsonPayload.value = ''
  hasSearched.value = false
  selectedRow.value = null
}
</script>

