<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="retweet" />
      </div>
      <div class="module-view-info">
        <h1>Reasignación de Ejecutores</h1>
        <p>Estacionamiento Exclusivo - Reasignar expedientes a diferentes ejecutores</p>
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
      <!-- Formulario de Reasignación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Formulario de Reasignación
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio Desde</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folio_desde"
                placeholder="Folio inicial"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio Hasta</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folio_hasta"
                placeholder="Folio final"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ejecutor</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.ejecutor"
                placeholder="Clave de ejecutor"
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
              :disabled="!folioDesdeComputed || !folioHastaComputed || !ejecutorComputed"
              @click="reasignar"
            >
              <font-awesome-icon icon="save" />
              Reasignar
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
        :componentName="'Reasignacion'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Reasignación de Ejecutores'"
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

// Constantes
const BASE_DB = 'estacionamiento_exclusivo'
const OP_REASIGNAR = 'sp_reasignar_folio'

// Estado
const form = ref({
  folio_desde: null,
  folio_hasta: null,
  ejecutor: null,
  recaudadora: null
})
const selectedRow = ref(null)
const hasSearched = ref(false)

// Computed
const folioDesdeComputed = computed(() => form.value.folio_desde ?? null)
const folioHastaComputed = computed(() => form.value.folio_hasta ?? null)
const ejecutorComputed = computed(() => form.value.ejecutor ?? null)

// Métodos
const reasignar = async () => {
  if (!folioDesdeComputed.value || !ejecutorComputed.value) {
    showToast('error', 'Debe completar folio y ejecutor')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Confirmar reasignación?',
    text: `Reasignar folio ${folioDesdeComputed.value} al ejecutor ${ejecutorComputed.value}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, reasignar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Reasignando folio...', 'Procesando cambio')
  hasSearched.value = true
  selectedRow.value = null
  const startTime = performance.now()

  try {
    const fechaActual = new Date().toISOString().split('T')[0]
    const response = await execute(OP_REASIGNAR, BASE_DB, [
      { name: 'p_id_control', type: 'I', value: Number(folioDesdeComputed.value) },
      { name: 'p_nuevo_ejecutor', type: 'I', value: Number(ejecutorComputed.value) },
      { name: 'p_fecha_entrega2', type: 'D', value: fechaActual },
      { name: 'p_usuario', type: 'I', value: 1 },
      { name: 'p_fecha_actualiz', type: 'D', value: fechaActual }
    ])

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    const mensaje = typeof response === 'string'
      ? response
      : (response?.result || response?.data || 'Reasignación exitosa')

    toast.value.duration = durationText
    showToast('success', mensaje)

    await Swal.fire({
      title: '¡Éxito!',
      text: `${mensaje} (${durationText})`,
      icon: 'success',
      confirmButtonText: 'OK'
    })

    limpiar()
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiar = () => {
  form.value = {
    folio_desde: null,
    folio_hasta: null,
    ejecutor: null,
    recaudadora: null
  }
  selectedRow.value = null
  hasSearched.value = false
}
</script>
