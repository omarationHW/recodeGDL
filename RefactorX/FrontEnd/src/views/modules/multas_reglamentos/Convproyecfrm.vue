<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calculator" /></div>
      <div class="module-view-info">
        <h1>Proyeccion de Convenios</h1>
        <p>Multas y Reglamentos - Proyeccion de Parcialidades para Convenios de Pago</p>
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
            <font-awesome-icon icon="filter" /> Busqueda de Cuenta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <input type="number" class="municipal-form-control" v-model="filters.recaudadora" placeholder="Recaudadora" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Urbano/Rustico</label>
              <input type="text" class="municipal-form-control" v-model="filters.urbrus" placeholder="U/R" maxlength="1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input type="number" class="municipal-form-control" v-model="filters.cuenta" placeholder="Numero de cuenta" @keyup.enter="buscar" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar Cuenta
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-if="cuentaData" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="user" /> Datos de la Cuenta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <table class="detail-table">
                <tr><td class="label">Cuenta:</td><td><strong class="text-primary">{{ cuentaData.recaud }}-{{ cuentaData.urbrus }}-{{ cuentaData.cuenta }}</strong></td></tr>
                <tr><td class="label">Propietario:</td><td>{{ cuentaData.propietario || 'N/A' }}</td></tr>
                <tr><td class="label">Direccion:</td><td>{{ cuentaData.direccion || 'N/A' }}</td></tr>
              </table>
            </div>
            <div class="detail-section">
              <table class="detail-table">
                <tr><td class="label">Saldo Total:</td><td class="text-end"><strong class="text-danger">{{ formatCurrency(cuentaData.saldo_total) }}</strong></td></tr>
                <tr><td class="label">Adeudo Principal:</td><td class="text-end">{{ formatCurrency(cuentaData.adeudo_principal) }}</td></tr>
                <tr><td class="label">Recargos:</td><td class="text-end">{{ formatCurrency(cuentaData.recargos) }}</td></tr>
              </table>
            </div>
          </div>
        </div>
      </div>

      <div v-if="cuentaData" class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calculator" /> Proyeccion de Parcialidades</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row mb-4">
            <div class="form-group">
              <label class="municipal-form-label">Numero de Parcialidades</label>
              <input type="number" class="municipal-form-control" v-model="proyeccion.numParcialidades" min="1" max="48" @change="calcularProyeccion" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Primera Parcialidad</label>
              <input type="date" class="municipal-form-control" v-model="proyeccion.fechaInicio" @change="calcularProyeccion" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Enganche (%)</label>
              <input type="number" class="municipal-form-control" v-model="proyeccion.enganche" min="0" max="100" @change="calcularProyeccion" />
            </div>
          </div>

          <div v-if="parcialidades.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>No.</th>
                  <th>Fecha Vencimiento</th>
                  <th>Importe</th>
                  <th>Saldo Restante</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="proyeccion.enganche > 0" class="table-row-highlight">
                  <td><strong>Enganche</strong></td>
                  <td>{{ formatDate(new Date().toISOString()) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(montoEnganche) }}</strong></td>
                  <td class="text-end">{{ formatCurrency(saldoDespuesEnganche) }}</td>
                </tr>
                <tr v-for="(parc, index) in parcialidades" :key="index" class="row-hover">
                  <td>{{ index + 1 }}</td>
                  <td>{{ formatDate(parc.fecha) }}</td>
                  <td class="text-end">{{ formatCurrency(parc.importe) }}</td>
                  <td class="text-end">{{ formatCurrency(parc.saldoRestante) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-footer-total">
                  <td colspan="2"><strong>TOTAL</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(cuentaData?.saldo_total) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div class="button-group mt-4">
            <button class="btn-municipal-success" @click="generarConvenio" :disabled="loading || parcialidades.length === 0">
              <font-awesome-icon icon="file-contract" /> Generar Convenio
            </button>
            <button class="btn-municipal-info" @click="imprimirProyeccion" :disabled="parcialidades.length === 0">
              <font-awesome-icon icon="print" /> Imprimir Proyeccion
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'Convproyecfrm'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Proyeccion de Convenios'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const cuentaData = ref(null)
const parcialidades = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const today = new Date().toISOString().split('T')[0]
const filters = ref({ recaudadora: '', urbrus: '', cuenta: '' })
const proyeccion = ref({ numParcialidades: 12, fechaInicio: today, enganche: 0 })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const montoEnganche = computed(() => {
  if (!cuentaData.value || proyeccion.value.enganche <= 0) return 0
  return cuentaData.value.saldo_total * (proyeccion.value.enganche / 100)
})

const saldoDespuesEnganche = computed(() => {
  if (!cuentaData.value) return 0
  return cuentaData.value.saldo_total - montoEnganche.value
})

const buscar = async () => {
  if (!filters.value.recaudadora || !filters.value.cuenta) {
    showToast('warning', 'Debe ingresar recaudadora y cuenta')
    return
  }

  showLoading('Buscando cuenta...', 'Consultando base de datos')

  try {
    const response = await execute('sp_convproyec_consulta_cuenta', 'multas_reglamentos',
      [
        { nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' },
        { nombre: 'p_urbrus', valor: filters.value.urbrus.toUpperCase() || 'U', tipo: 'string' },
        { nombre: 'p_cuenta', valor: parseInt(filters.value.cuenta), tipo: 'integer' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      cuentaData.value = response.result[0]
      showToast('success', 'Cuenta encontrada')
      calcularProyeccion()
    } else {
      cuentaData.value = null
      parcialidades.value = []
      showToast('info', 'No se encontro la cuenta')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar cuenta')
    cuentaData.value = null
  } finally {
    hideLoading()
  }
}

const calcularProyeccion = () => {
  if (!cuentaData.value || proyeccion.value.numParcialidades <= 0) {
    parcialidades.value = []
    return
  }

  const saldoAFinanciar = saldoDespuesEnganche.value
  const importeParcialidad = saldoAFinanciar / proyeccion.value.numParcialidades
  const fechaInicio = new Date(proyeccion.value.fechaInicio)

  parcialidades.value = []
  let saldoRestante = saldoAFinanciar

  for (let i = 0; i < proyeccion.value.numParcialidades; i++) {
    const fechaVenc = new Date(fechaInicio)
    fechaVenc.setMonth(fechaVenc.getMonth() + i)
    saldoRestante -= importeParcialidad

    parcialidades.value.push({
      numero: i + 1,
      fecha: fechaVenc.toISOString(),
      importe: importeParcialidad,
      saldoRestante: Math.max(0, saldoRestante)
    })
  }
}

const limpiar = () => {
  filters.value = { recaudadora: '', urbrus: '', cuenta: '' }
  cuentaData.value = null
  parcialidades.value = []
  proyeccion.value = { numParcialidades: 12, fechaInicio: today, enganche: 0 }
}

const generarConvenio = async () => {
  const confirm = await Swal.fire({
    icon: 'question', title: 'Generar Convenio',
    text: 'Esta seguro de generar el convenio con estas parcialidades?',
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, generar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showToast('info', 'Funcion en desarrollo')
}

const imprimirProyeccion = () => { showToast('info', 'Funcion de impresion en desarrollo') }

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    return new Date(dateString).toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch { return 'N/A' }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}
</script>
