<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-upload" /></div>
      <div class="module-view-info">
        <h1>Carga Estado/Externos</h1>
        <p>Insertar datos, afectar remesa y bitácora</p>
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
        <button class="btn-municipal-secondary" :disabled="loadingIns" @click="insertar">
          <font-awesome-icon icon="plus" /> Insertar
        </button>
        <button class="btn-municipal-secondary" :disabled="loadingAfect" @click="afectar">
          <font-awesome-icon icon="bolt" /> Afectar
        </button>
        <button class="btn-municipal-primary" :disabled="loadingBit" @click="bitacora">
          <font-awesome-icon icon="bookmark" /> Bitácora
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Mpio</label><input type="number" class="municipal-form-control" v-model.number="mpio" /></div>
            <div class="form-group"><label class="municipal-form-label">Tipo Act</label><input class="municipal-form-control" v-model="tipoact" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fec Pago</label><input type="date" class="municipal-form-control" v-model="fecpago" /></div>
            <div class="form-group"><label class="municipal-form-label">Importe</label><input type="number" class="municipal-form-control" v-model.number="importe" step="0.01" /></div>
            <div class="form-group"><label class="municipal-form-label">Fec Alta</label><input type="date" class="municipal-form-control" v-model="fecalta" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Remesa</label><input class="municipal-form-control" v-model="remesa" /></div>
            <div class="form-group"><label class="municipal-form-label">Fec Remesa</label><input type="date" class="municipal-form-control" v-model="fecharemesa" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Bitacora: Inicio</label><input type="date" class="municipal-form-control" v-model="bit_ini" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: Fin</label><input type="date" class="municipal-form-control" v-model="bit_fin" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: Fecha</label><input type="date" class="municipal-form-control" v-model="bit_fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: #Remesa</label><input type="number" class="municipal-form-control" v-model.number="bit_numrem" /></div>
            <div class="form-group"><label class="municipal-form-label">Bitacora: #Reg</label><input type="number" class="municipal-form-control" v-model.number="bit_cantreg" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'CargaEdoExPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Carga Estado/Externos'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const mpio = ref(0)
const tipoact = ref('')
const folio = ref(0)
const placa = ref('')
const fecpago = ref('')
const importe = ref(0)
const fecalta = ref('')
const remesa = ref('')
const fecharemesa = ref('')
const bit_ini = ref('')
const bit_fin = ref('')
const bit_fecha = ref('')
const bit_numrem = ref(0)
const bit_cantreg = ref(0)
const message = ref('')
const loadingIns = ref(false)
const loadingAfect = ref(false)
const loadingBit = ref(false)

async function insertar() {
  if (!folio.value || !placa.value.trim()) {
    showToast('warning', 'Folio y Placa son requeridos')
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Inserción',
    html: `¿Insertar registro con folio <strong>${folio.value}</strong> y placa <strong>${placa.value}</strong>?`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, insertar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Insertando...', 'Guardando datos')
  loadingIns.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_mpio', valor: mpio.value || 0, tipo: 'integer' },
      { nombre: 'p_tipoact', valor: tipoact.value || '', tipo: 'string' },
      { nombre: 'p_folio', valor: folio.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value.toUpperCase(), tipo: 'string' },
      { nombre: 'p_fecpago', valor: fecpago.value || null, tipo: 'date' },
      { nombre: 'p_importe', valor: importe.value || 0, tipo: 'numeric' },
      { nombre: 'p_fecalta', valor: fecalta.value || null, tipo: 'date' },
      { nombre: 'p_remesa', valor: remesa.value || '', tipo: 'string' },
      { nombre: 'p_fecremesa', valor: fecharemesa.value || null, tipo: 'date' }
    ]
    const resp = await execute('sp_insert_ta14_datos_edo', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    loadingIns.value = false
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Insertado',
        text: data?.message || 'Registro insertado correctamente',
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      message.value = 'Insertado correctamente'
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'Error al insertar'
      })
      message.value = data?.message || 'Error al insertar'
    }
  } catch (e) {
    hideLoading()
    loadingIns.value = false
    await nextTick()
    handleApiError(e)
  }
}

async function afectar() {
  if (!bit_fecha.value) {
    showToast('warning', 'La fecha de bitácora es requerida')
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Afectación',
    text: `¿Afectar remesa con fecha ${bit_fecha.value}?`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, afectar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Afectando...', 'Procesando remesa')
  loadingAfect.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_fecha', valor: bit_fecha.value, tipo: 'date' }
    ]
    const resp = await execute('sp_afec_esta01', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    loadingAfect.value = false
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Afectado',
        text: data?.message || 'Remesa afectada correctamente',
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      message.value = 'Afectado correctamente'
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'Error al afectar'
      })
      message.value = data?.message || 'Error al afectar'
    }
  } catch (e) {
    hideLoading()
    loadingAfect.value = false
    await nextTick()
    handleApiError(e)
  }
}

async function bitacora() {
  if (!bit_ini.value || !bit_fin.value || !bit_fecha.value) {
    showToast('warning', 'Las fechas de bitácora son requeridas')
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Bitácora',
    html: `<p>¿Registrar en bitácora?</p>
     <ul class="swal-list-left">
       <li><strong>Inicio:</strong> ${bit_ini.value}</li>
       <li><strong>Fin:</strong> ${bit_fin.value}</li>
       <li><strong>Remesa:</strong> ${bit_numrem.value}</li>
     </ul>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, registrar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Registrando...', 'Guardando en bitácora')
  loadingBit.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_fecha_inicio', valor: bit_ini.value, tipo: 'date' },
      { nombre: 'p_fecha_fin', valor: bit_fin.value, tipo: 'date' },
      { nombre: 'p_fecha', valor: bit_fecha.value, tipo: 'date' },
      { nombre: 'p_num_rem', valor: bit_numrem.value || 0, tipo: 'integer' },
      { nombre: 'p_cant_reg', valor: bit_cantreg.value || 0, tipo: 'integer' }
    ]
    const resp = await execute('sp_insert_ta14_bitacora', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    hideLoading()
    loadingBit.value = false
    await nextTick()

    if (data?.success === true) {
      await Swal.fire({
        icon: 'success',
        title: 'Registrado',
        text: data?.message || 'Bitácora registrada correctamente',
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      message.value = 'Registrado en bitácora'
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: data?.message || 'Error al registrar'
      })
      message.value = data?.message || 'Error al registrar'
    }
  } catch (e) {
    hideLoading()
    loadingBit.value = false
    await nextTick()
    handleApiError(e)
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

