<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="signature" />
      </div>
      <div class="module-view-info">
        <h1>Firma Electrónica</h1>
        <p>Estacionamiento Exclusivo - Firma electrónica de documentos</p>
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
      <!-- Formulario de Firma -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario de Firma
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Módulo</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.modulo"
                placeholder="1"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="form.fecha"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!form.modulo || !form.fecha"
              @click="firmar"
            >
              <font-awesome-icon icon="pen-nib" />
              Listar Folios
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
            >
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
        :componentName="'FirmaElectronica'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Firma Electrónica'"
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
const OP_LISTAR = 'sp_firmaelectronica_listar_folios'

// Estado
const form = ref({ modulo: 1, fecha: '' })
const selectedRow = ref(null)
const hasSearched = ref(false)

// Métodos
const firmar = async () => {
  if (!form.value.modulo || !form.value.fecha) {
    showToast('error', 'Debe completar módulo y fecha')
    return
  }
  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Listar folios para firma electrónica?',
    text: `Módulo: ${form.value.modulo}, Fecha: ${form.value.fecha}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, listar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })
  if (!confirm.isConfirmed) return

  showLoading('Listando folios...', 'Procesando firma electrónica')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(OP_LISTAR, BASE_DB, [
      { name: 'pmod', type: 'I', value: Number(form.value.modulo || 1) },
      { name: 'pfec', type: 'D', value: String(form.value.fecha || '') }
    ])
    let data = []
    if (response && response.data) {
      data = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      data = Array.isArray(response.result) ? response.result : []
    }

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    await Swal.fire({
      icon: 'success',
      title: 'Folios listados',
      html: `<b>${data.length} folios encontrados</b><br>Procesado en ${durationText}`,
      timer: 2000
    })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = { modulo: 1, fecha: '' }
  hasSearched.value = false
  selectedRow.value = null
}
</script>
