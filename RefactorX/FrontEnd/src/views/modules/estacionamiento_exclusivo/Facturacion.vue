<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Facturación</h1>
        <p>Estacionamiento Exclusivo - Emisión de facturas por expediente</p>
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
      <!-- Formulario de Facturación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario de Facturación
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
                placeholder="Módulo"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.recaudadora"
                placeholder="Recaudadora"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio Desde</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folioDesde"
                placeholder="0"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio Hasta</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folioHasta"
                placeholder="999999"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!form.modulo || !form.recaudadora"
              @click="emitir"
            >
              <font-awesome-icon icon="file-invoice" />
              Emitir Factura
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
        :componentName="'Facturacion'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Facturación'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
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
const OP_LIST = 'sp_facturacion_list'

// Estado
const selectedRow = ref(null)
const hasSearched = ref(false)
const form = ref({
  modulo: 1,
  recaudadora: 1,
  folioDesde: 0,
  folioHasta: 999999
})

// Métodos
const emitir = async () => {
  if (!form.value.modulo || !form.value.recaudadora) {
    showToast('warning', 'Debe completar módulo y recaudadora')
    return
  }

  const confirm = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar emisión de factura?',
    text: `Módulo: ${form.value.modulo}, Recaudadora: ${form.value.recaudadora}, Folios: ${form.value.folioDesde} a ${form.value.folioHasta}`,
    showCancelButton: true,
    confirmButtonText: 'Sí, emitir',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#198754'
  })

  if (!confirm.isConfirmed) return

  showLoading('Emitiendo factura...', 'Procesando información')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const response = await execute(OP_LIST, BASE_DB, [
      { name: 'p_modulo', type: 'I', value: Number(form.value.modulo || 1) },
      { name: 'p_rec', type: 'I', value: Number(form.value.recaudadora || 1) },
      { name: 'p_fol1', type: 'I', value: Number(form.value.folioDesde || 0) },
      { name: 'p_fol2', type: 'I', value: Number(form.value.folioHasta || 999999) }
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

    toast.value.duration = durationText

    await Swal.fire({
      icon: 'success',
      title: 'Factura emitida',
      html: `<b>${data.length} registros encontrados</b><br>Procesado en ${durationText}`,
      timer: 2000
    })

    showToast('success', `Factura emitida correctamente - ${data.length} registros`)
    limpiar()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = {
    modulo: 1,
    recaudadora: 1,
    folioDesde: 0,
    folioHasta: 999999
  }
  hasSearched.value = false
  selectedRow.value = null
}
</script>

