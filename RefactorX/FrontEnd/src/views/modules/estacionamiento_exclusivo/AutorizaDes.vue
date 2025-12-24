<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="badge-check" />
      </div>
      <div class="module-view-info">
        <h1>Autoriza Descuentos</h1>
        <p>Autorización de descuentos por expediente</p>
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
      <!-- Formulario de autorización -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario de Autorización
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folio"
                placeholder="Número de folio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">% Descuento</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.porcentaje"
                placeholder="0-100"
                min="0"
                max="100"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Módulo</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.modulo"
                placeholder="28=Exclusivos, 24=Públicos"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.recaudadora"
                placeholder="ID Recaudadora (default: 1)"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!folioComputed || !porcentajeComputed"
              @click="autorizar"
            >
              <font-awesome-icon icon="check" />
              Autorizar Descuento
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
        :componentName="'AutorizaDes'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Autoriza Descuentos'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref, computed } from 'vue'
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

const BASE_DB = 'estacionamiento_exclusivo'
const OP_AUTORIZAR = 'sp_autorizades_alta'

// Estado
const selectedRow = ref(null)
const hasSearched = ref(false)

const form = ref({ folio: null, recaudadora: null, modulo: null, porcentaje: null, cveaut: null })

const folioComputed = computed(() => form.value.folio ?? null)
const porcentajeComputed = computed(() => form.value.porcentaje ?? null)

const autorizar = async () => {
  if (!folioComputed.value || !porcentajeComputed.value) {
    showToast('error', 'Debe completar folio y porcentaje')
    return
  }
  if (porcentajeComputed.value < 0 || porcentajeComputed.value > 100) {
    showToast('error', 'Porcentaje debe estar entre 0 y 100')
    return
  }
  const confirmResult = await Swal.fire({
    title: '¿Confirmar autorización?',
    text: `Autorizar ${porcentajeComputed.value}% de descuento para folio ${folioComputed.value}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, autorizar',
    cancelButtonText: 'Cancelar'
  })
  if (!confirmResult.isConfirmed) return

  showLoading('Autorizando descuento...', 'Procesando solicitud')
  hasSearched.value = true
  selectedRow.value = null
  const t0 = performance.now()
  try {
    const fechaActual = new Date().toISOString().split('T')[0]
    const response = await execute(OP_AUTORIZAR, BASE_DB, [
      { name: 'p_id_control', type: 'I', value: Number(folioComputed.value) },
      { name: 'p_id_rec', type: 'I', value: Number(form.value.recaudadora || 1) },
      { name: 'p_cveaut', type: 'I', value: Number(form.value.cveaut || 1) },
      { name: 'p_porcentaje', type: 'I', value: Number(porcentajeComputed.value) },
      { name: 'p_fecha_alta', type: 'D', value: fechaActual },
      { name: 'p_usuario_id', type: 'I', value: 1 }
    ])
    let arr = {}
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data[0] || {} : response.data
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result[0] || {} : response.result
    }
    const mensaje = arr?.ok ? arr?.msg : (arr?.msg || 'Descuento autorizado')
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`

    toast.value.duration = txt
    await Swal.fire({ title: '¡Éxito!', text: `${mensaje} (${txt})`, icon: 'success', confirmButtonText: 'OK' })
    limpiar()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = { folio: null, recaudadora: null, modulo: null, porcentaje: null, cveaut: null }
  hasSearched.value = false
  selectedRow.value = null
}
</script>

