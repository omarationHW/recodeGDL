<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Locales</h1>
        <p>Otras Obligaciones - Rastro - Dar de baja contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número:</label>
              <input
                type="text"
                v-model="formData.numero"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="10"
                @keyup.enter="handleBuscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra:</label>
              <input
                type="text"
                v-model="formData.letra"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="5"
                @keyup.enter="handleBuscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary" @click="handleBuscar">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Local -->
      <div class="municipal-card" v-if="datosLocal.id_datos">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
          <div class="button-group ms-auto">
            <button class="btn-municipal-success" @click="imprimirReporte">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <span class="badge" :class="datosLocal.statusregistro === 'VIGENTE' ? 'badge-success' : 'badge-danger'">
              {{ datosLocal.statusregistro }}
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Control:</strong>
              <span>{{ controlBuscado }}</span>
            </div>
            <div class="info-item">
              <strong>Concesionario:</strong>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>Ubicación:</strong>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>Superficie:</strong>
              <span>{{ datosLocal.superficie }} m²</span>
            </div>
            <div class="info-item">
              <strong>Sector:</strong>
              <span>{{ datosLocal.sector }}</span>
            </div>
            <div class="info-item">
              <strong>Zona:</strong>
              <span>{{ datosLocal.zona }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos -->
      <div class="municipal-card" v-if="datosLocal.id_datos && datosLocal.statusregistro === 'VIGENTE'">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="exclamation-triangle" /> Resumen de Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" v-if="adeudos.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Período</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudos" :key="index">
                  <td>{{ formatPeriodo(adeudo.periodo) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.recargo) }}</td>
                  <td class="text-right">{{ formatCurrency(parseFloat(adeudo.importe || 0) + parseFloat(adeudo.recargo || 0)) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td class="text-right"><strong>Total:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalImportes) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalGeneral) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div v-else class="text-center text-muted p-3">
            <font-awesome-icon icon="check-circle" size="2x" class="text-success mb-2" />
            <p>No hay adeudos pendientes</p>
          </div>
        </div>
      </div>

      <!-- Formulario de Baja -->
      <div class="municipal-card" v-if="datosLocal.id_datos && datosLocal.statusregistro === 'VIGENTE'">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Datos de Baja</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año de Baja:</label>
              <input type="number" v-model.number="formData.anioBaja" class="municipal-form-control" :min="2000" :max="2099" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes de Baja:</label>
              <select v-model.number="formData.mesBaja" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>
          <div class="button-group mt-3">
            <button class="btn-municipal-danger" @click="handleDarBaja">
              <font-awesome-icon icon="times-circle" /> Dar de Baja
            </button>
            <button class="btn-municipal-secondary" @click="handleCancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Alerta para no vigentes -->
      <div class="municipal-card" v-if="datosLocal.id_datos && datosLocal.statusregistro !== 'VIGENTE'">
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" class="me-2" />
            Este local está en SUSPENSIÓN o CANCELADO, no se puede dar de baja
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentacion -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'RBaja'"
      :moduleName="'otras_obligaciones'"
      :docType="docType"
      :title="'Baja de Locales'"
      @close="showDocModal = false"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'otras_obligaciones'
const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

// Documentacion y Ayuda
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

const datosLocal = ref({})
const adeudos = ref([])
const controlBuscado = ref('')

const formData = reactive({
  numero: '',
  letra: '',
  anioBaja: new Date().getFullYear(),
  mesBaja: new Date().getMonth() + 1
})

const meses = [
  { value: 1, label: '01-Enero' },
  { value: 2, label: '02-Febrero' },
  { value: 3, label: '03-Marzo' },
  { value: 4, label: '04-Abril' },
  { value: 5, label: '05-Mayo' },
  { value: 6, label: '06-Junio' },
  { value: 7, label: '07-Julio' },
  { value: 8, label: '08-Agosto' },
  { value: 9, label: '09-Septiembre' },
  { value: 10, label: '10-Octubre' },
  { value: 11, label: '11-Noviembre' },
  { value: 12, label: '12-Diciembre' }
]

const totalImportes = computed(() => adeudos.value.reduce((sum, a) => sum + (parseFloat(a.importe) || 0), 0))
const totalRecargos = computed(() => adeudos.value.reduce((sum, a) => sum + (parseFloat(a.recargo) || 0), 0))
const totalGeneral = computed(() => totalImportes.value + totalRecargos.value)

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatPeriodo = (periodo) => {
  if (!periodo) return '-'
  try {
    const date = new Date(periodo)
    return `${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()}`
  } catch {
    return periodo
  }
}

const loadAdeudos = async () => {
  if (!datosLocal.value.id_datos) {
    adeudos.value = []
    return
  }

  try {
    const response = await execute(
      'sp_rbaja_listar_adeudos',
      BASE_DB,
      [{ nombre: 'p_id_34_datos', valor: datosLocal.value.id_datos, tipo: 'integer' }],
      'guadalajara'
    )
    adeudos.value = response?.result || []
  } catch {
    adeudos.value = []
  }
}

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  showLoading('Buscando local...')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`
    controlBuscado.value = control

    const response = await execute(
      'sp_otras_oblig_buscar_cont',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (!response || !response.result || response.result.length === 0 || response.result[0].status === -1) {
      hideLoading()
      showToast('warning', 'No se encontró el local especificado')
      datosLocal.value = {}
      return
    }

    datosLocal.value = response.result[0]

    if (datosLocal.value.statusregistro !== 'VIGENTE') {
      hideLoading()
      await Swal.fire({
        icon: 'warning',
        title: 'Registro no vigente',
        text: 'Este local está en SUSPENSIÓN o CANCELADO, no se puede dar de baja',
        confirmButtonColor: '#ea8215'
      })
    } else {
      await loadAdeudos()
      hideLoading()
      showToast('success', 'Local encontrado')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    datosLocal.value = {}
  }
}

const handleDarBaja = async () => {
  if (!formData.anioBaja || !formData.mesBaja) {
    showToast('warning', 'Debe especificar el año y mes de baja')
    return
  }

  if (datosLocal.value.statusregistro !== 'VIGENTE') {
    showToast('error', 'Solo se pueden dar de baja registros VIGENTES')
    return
  }

  showLoading('Verificando adeudos...')

  try {
    const periodo = `${formData.anioBaja}-${String(formData.mesBaja).padStart(2, '0')}`
    const verificarResponse = await execute(
      'sp_rbaja_verificar_adeudos_post',
      BASE_DB,
      [
        { nombre: 'p_id_34_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
        { nombre: 'p_periodo', valor: periodo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (verificarResponse?.result?.length > 0) {
      hideLoading()
      await Swal.fire({
        icon: 'error',
        title: 'Adeudos pendientes',
        text: 'No es posible dar de baja. Tiene adeudos vigentes o posteriores al periodo indicado',
        confirmButtonColor: '#ea8215'
      })
      return
    }

    hideLoading()

    const result = await Swal.fire({
      icon: 'warning',
      title: '¿Confirmar baja?',
      html: `
        <p><strong>Control:</strong> ${controlBuscado.value}</p>
        <p><strong>Concesionario:</strong> ${datosLocal.value.concesionario}</p>
        <p><strong>Fecha de baja:</strong> ${formData.mesBaja}/${formData.anioBaja}</p>
        <p class="text-danger"><strong>Esta acción no se puede revertir.</strong></p>
      `,
      showCancelButton: true,
      confirmButtonColor: '#dc3545',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, dar de baja',
      cancelButtonText: 'Cancelar'
    })

    if (result.isConfirmed) {
      showLoading('Procesando baja...')

      const response = await execute(
        'sp_rbaja_cancelar_local',
        BASE_DB,
        [
          { nombre: 'p_id_34_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
          { nombre: 'p_axo_fin', valor: formData.anioBaja, tipo: 'integer' },
          { nombre: 'p_mes_fin', valor: formData.mesBaja, tipo: 'integer' }
        ],
        'guadalajara'
      )

      hideLoading()

      if (response?.result?.[0]?.codigo === 0) {
        await Swal.fire({
          icon: 'success',
          title: 'Baja aplicada',
          text: response.result[0].mensaje || 'Se ejecutó correctamente la baja del Local/Concesión',
          confirmButtonColor: '#ea8215'
        })
        handleCancelar()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: response?.result?.[0]?.mensaje || 'Error al dar de baja',
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const handleCancelar = () => {
  datosLocal.value = {}
  adeudos.value = []
  controlBuscado.value = ''
  formData.numero = ''
  formData.letra = ''
  formData.anioBaja = new Date().getFullYear()
  formData.mesBaja = new Date().getMonth() + 1
}

const imprimirReporte = () => {
  if (!datosLocal.value.id_datos) {
    showToast('warning', 'Debe buscar un local primero')
    return
  }

  if (adeudos.value.length > 0) {
    const columns = [
      { header: 'Período', key: 'periodo', type: 'string' },
      { header: 'Importe', key: 'importe', type: 'currency' },
      { header: 'Recargos', key: 'recargo', type: 'currency' }
    ]

    exportToPdf(adeudos.value, columns, {
      title: 'Reporte de Baja - Adeudos',
      subtitle: `Control: ${controlBuscado.value} - ${datosLocal.value.concesionario}`,
      orientation: 'portrait'
    })
  } else {
    const columns = [
      { header: 'Campo', key: 'campo', type: 'string' },
      { header: 'Valor', key: 'valor', type: 'string' }
    ]
    const data = [
      { campo: 'Control', valor: controlBuscado.value },
      { campo: 'Concesionario', valor: datosLocal.value.concesionario },
      { campo: 'Ubicación', valor: datosLocal.value.ubicacion },
      { campo: 'Superficie', valor: `${datosLocal.value.superficie} m²` },
      { campo: 'Status', valor: datosLocal.value.statusregistro },
      { campo: 'Adeudos', valor: 'SIN ADEUDOS PENDIENTES' }
    ]

    exportToPdf(data, columns, {
      title: 'Consulta de Baja',
      subtitle: `Control: ${controlBuscado.value}`,
      orientation: 'portrait'
    })
  }
}

const goBack = () => router.push('/otras-obligaciones/menu')
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
