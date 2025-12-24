<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div>
      <div class="module-view-info">
        <h1>Contrarecibos</h1>
        <p>Alta/Modificación/Baja y suma por fecha</p>
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

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="sumar"><font-awesome-icon icon="calculator" /> Sumar por fecha</button>
        <button class="btn-municipal-primary" :disabled="loading" @click="guardar"><font-awesome-icon icon="save" /> Guardar</button>
        <button class="btn-municipal-secondary" :disabled="loading" @click="eliminar"><font-awesome-icon icon="trash" /> Eliminar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Ejercicio</label><input type="number" class="municipal-form-control" v-model.number="form.ejercicio" /></div>
            <div class="form-group"><label class="municipal-form-label">Procedencia</label><input type="number" class="municipal-form-control" v-model.number="form.procedencia" /></div>
            <div class="form-group"><label class="municipal-form-label">Contrarecibo</label><input type="number" class="municipal-form-control" v-model.number="form.crbo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.feccrbo" /></div>
            <div class="form-group"><label class="municipal-form-label">Importe</label><input type="number" class="municipal-form-control" v-model.number="form.importe" step="0.01" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Concepto</label><input class="municipal-form-control" v-model="form.concepto" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Proveedor</label><input type="number" class="municipal-form-control" v-model.number="form.proveedor" /></div>
            <div class="form-group"><label class="municipal-form-label"># Doctos</label><input type="number" class="municipal-form-control" v-model.number="form.doctos" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Ingreso</label><input type="date" class="municipal-form-control" v-model="form.fecingre" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Venc.</label><input type="date" class="municipal-form-control" v-model="form.fecvenci" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Forma Pago</label><input class="municipal-form-control" v-model="form.formapago" maxlength="1" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Notas</label><input class="municipal-form-control" v-model="form.notas" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Param (1=Alta,2=Mod,3=Baja)</label><input type="number" class="municipal-form-control" v-model.number="form.param" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Suma por Fecha Ingreso</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="sumFecha" /></div>
          </div>
          <p class="text-muted">Total: <strong>{{ sumTotal }}</strong></p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ContrarecibosPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Contrarecibos'"
      @close="showDocModal = false"
    />

  </div>
</template>

<script setup>
import { reactive, ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const form = reactive({
  ejercicio: new Date().getFullYear(),
  procedencia: 0,
  crbo: 0,
  feccrbo: '',
  diasven: 0,
  importe: 0,
  concepto: '',
  proveedor: 0,
  doctos: 0,
  fecingre: '',
  fecvenci: '',
  feccodi: '',
  fecveri: '',
  fecprog: '',
  fecaja: '',
  feccancel: '',
  cvecheq: '',
  benef: '',
  formapago: '',
  notas: '',
  param: 1,
  num_ctrol_cheque: 0,
  clave_movimiento: '',
  benef_cheque: ''
})
const message = ref('')
const sumFecha = ref('')
const sumTotal = ref('$0.00')

function formatMonto(m) {
  if (!m && m !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(m)
}

function limpiarFormulario() {
  form.crbo = 0
  form.feccrbo = ''
  form.importe = 0
  form.concepto = ''
  form.proveedor = 0
  form.doctos = 0
  form.fecingre = ''
  form.fecvenci = ''
  form.formapago = ''
  form.notas = ''
  form.param = 1
  message.value = ''
}

async function guardar() {
  if (!form.crbo || !form.ejercicio) {
    showToast('warning', 'Ejercicio y Contrarecibo son requeridos')
    return
  }

  const operacion = form.param === 1 ? 'Alta' : form.param === 2 ? 'Modificación' : 'Baja'

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: `Confirmar ${operacion}`,
    html: `
      <p>¿${operacion} del contrarecibo?</p>
      <ul class="swal-list-left">
        <li><strong>Ejercicio:</strong> ${form.ejercicio}</li>
        <li><strong>Contrarecibo:</strong> ${form.crbo}</li>
        <li><strong>Importe:</strong> ${formatMonto(form.importe)}</li>
        <li><strong>Concepto:</strong> ${form.concepto || 'N/A'}</li>
      </ul>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: `Sí, ${operacion.toLowerCase()}`,
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Procesando...', `Ejecutando ${operacion.toLowerCase()}`)
  message.value = ''
  try {
    const params = [
      { nombre: 'p_ejercicio', valor: form.ejercicio, tipo: 'integer' },
      { nombre: 'p_procedencia', valor: form.procedencia, tipo: 'integer' },
      { nombre: 'p_crbo', valor: form.crbo, tipo: 'integer' },
      { nombre: 'p_feccrbo', valor: form.feccrbo || null, tipo: 'date' },
      { nombre: 'p_diasven', valor: form.diasven, tipo: 'integer' },
      { nombre: 'p_importe', valor: form.importe, tipo: 'numeric' },
      { nombre: 'p_concepto', valor: form.concepto || '', tipo: 'string' },
      { nombre: 'p_proveedor', valor: form.proveedor, tipo: 'integer' },
      { nombre: 'p_doctos', valor: form.doctos, tipo: 'integer' },
      { nombre: 'p_fecingre', valor: form.fecingre || null, tipo: 'date' },
      { nombre: 'p_fecvenci', valor: form.fecvenci || null, tipo: 'date' },
      { nombre: 'p_feccodi', valor: form.feccodi || null, tipo: 'date' },
      { nombre: 'p_fecveri', valor: form.fecveri || null, tipo: 'date' },
      { nombre: 'p_fecprog', valor: form.fecprog || null, tipo: 'date' },
      { nombre: 'p_fecaja', valor: form.fecaja || null, tipo: 'date' },
      { nombre: 'p_feccancel', valor: form.feccancel || null, tipo: 'date' },
      { nombre: 'p_cvecheq', valor: form.cvecheq || '', tipo: 'string' },
      { nombre: 'p_benef', valor: form.benef || '', tipo: 'string' },
      { nombre: 'p_formapago', valor: form.formapago || '', tipo: 'string' },
      { nombre: 'p_notas', valor: form.notas || '', tipo: 'string' },
      { nombre: 'p_param', valor: form.param, tipo: 'integer' },
      { nombre: 'p_num_ctrol_cheque', valor: form.num_ctrol_cheque, tipo: 'integer' },
      { nombre: 'p_clave_movimiento', valor: form.clave_movimiento || '', tipo: 'string' },
      { nombre: 'p_benef_cheque', valor: form.benef_cheque || '', tipo: 'string' }
    ]
    const resp = await execute('spd_crbo_abc', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    await nextTick()

    if (resp?.success !== false) {
      message.value = `${operacion} completada`
      await Swal.fire({
        icon: 'success',
        title: `${operacion} Exitosa`,
        text: data?.result || data?.message || `Contrarecibo ${form.crbo} procesado correctamente`,
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
    } else {
      message.value = data?.message || 'Error en operación'
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo completar la operación'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

async function eliminar() {
  if (!form.crbo || !form.ejercicio) {
    showToast('warning', 'Ejercicio y Contrarecibo son requeridos para eliminar')
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: 'Confirmar Eliminación',
    html: `
      <p>¿Está seguro de eliminar el contrarecibo?</p>
      <ul class="swal-list-left">
        <li><strong>Ejercicio:</strong> ${form.ejercicio}</li>
        <li><strong>Contrarecibo:</strong> ${form.crbo}</li>
      </ul>
      <p class="text-danger"><strong>Esta acción no se puede deshacer.</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  form.param = 3

  showLoading('Eliminando...', 'Procesando baja de contrarecibo')
  message.value = ''
  try {
    const params = [
      { nombre: 'p_ejercicio', valor: form.ejercicio, tipo: 'integer' },
      { nombre: 'p_procedencia', valor: form.procedencia, tipo: 'integer' },
      { nombre: 'p_crbo', valor: form.crbo, tipo: 'integer' },
      { nombre: 'p_feccrbo', valor: form.feccrbo || null, tipo: 'date' },
      { nombre: 'p_diasven', valor: form.diasven, tipo: 'integer' },
      { nombre: 'p_importe', valor: form.importe, tipo: 'numeric' },
      { nombre: 'p_concepto', valor: form.concepto || '', tipo: 'string' },
      { nombre: 'p_proveedor', valor: form.proveedor, tipo: 'integer' },
      { nombre: 'p_doctos', valor: form.doctos, tipo: 'integer' },
      { nombre: 'p_fecingre', valor: form.fecingre || null, tipo: 'date' },
      { nombre: 'p_fecvenci', valor: form.fecvenci || null, tipo: 'date' },
      { nombre: 'p_feccodi', valor: form.feccodi || null, tipo: 'date' },
      { nombre: 'p_fecveri', valor: form.fecveri || null, tipo: 'date' },
      { nombre: 'p_fecprog', valor: form.fecprog || null, tipo: 'date' },
      { nombre: 'p_fecaja', valor: form.fecaja || null, tipo: 'date' },
      { nombre: 'p_feccancel', valor: form.feccancel || null, tipo: 'date' },
      { nombre: 'p_cvecheq', valor: form.cvecheq || '', tipo: 'string' },
      { nombre: 'p_benef', valor: form.benef || '', tipo: 'string' },
      { nombre: 'p_formapago', valor: form.formapago || '', tipo: 'string' },
      { nombre: 'p_notas', valor: form.notas || '', tipo: 'string' },
      { nombre: 'p_param', valor: 3, tipo: 'integer' },
      { nombre: 'p_num_ctrol_cheque', valor: form.num_ctrol_cheque, tipo: 'integer' },
      { nombre: 'p_clave_movimiento', valor: form.clave_movimiento || '', tipo: 'string' },
      { nombre: 'p_benef_cheque', valor: form.benef_cheque || '', tipo: 'string' }
    ]
    const resp = await execute('spd_crbo_abc', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    await nextTick()

    if (resp?.success !== false) {
      message.value = 'Eliminación completada'
      await Swal.fire({
        icon: 'success',
        title: 'Eliminado',
        text: data?.result || data?.message || `Contrarecibo ${form.crbo} eliminado correctamente`,
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
      limpiarFormulario()
    } else {
      message.value = data?.message || 'Error al eliminar'
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'No se pudo eliminar el contrarecibo'
      })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

async function sumar() {
  if (!sumFecha.value) {
    showToast('warning', 'Seleccione una fecha para sumar')
    return
  }

  showLoading('Calculando...', 'Sumando contrarecibos')
  try {
    const resp = await execute('sum_contrarecibos_by_date', BASE_DB, [
      { nombre: 'p_fecha', valor: sumFecha.value, tipo: 'date' }
    ], '', null, SCHEMA)

    // El SP devuelve un numeric directamente
    const data = resp?.result || resp?.data?.result || resp?.data || 0
    let val = 0

    if (Array.isArray(data)) {
      // Si es array, tomar el primer valor
      const first = data[0]
      val = typeof first === 'object' ? (first?.sum_contrarecibos_by_date || Object.values(first)[0] || 0) : first
    } else if (typeof data === 'object') {
      val = data?.sum_contrarecibos_by_date || Object.values(data)[0] || 0
    } else {
      val = data
    }

    sumTotal.value = formatMonto(parseFloat(val) || 0)
    showToast('success', `Total calculado: ${sumTotal.value}`)
  } catch (e) {
    handleApiError(e)
    sumTotal.value = formatMonto(0)
  } finally {
    hideLoading()
  }
}

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

</script>

