<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Descuento Multas - Mercados</h1>
        <p>Multas y Reglamentos - Descuento de Multas para Locales de Mercados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
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
            <font-awesome-icon icon="filter" /> Busqueda de Local
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <select class="municipal-form-control" v-model="filters.recaudadora" @change="cargarMercados">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.recaud" :value="rec.recaud">
                  {{ rec.recaud }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select class="municipal-form-control" v-model="filters.mercado" @change="cargarSecciones" :disabled="!filters.recaudadora">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_merc" :value="merc.num_merc">
                  {{ merc.nombre }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Seccion</label>
              <select class="municipal-form-control" v-model="filters.seccion" :disabled="!filters.mercado">
                <option value="">Seleccione...</option>
                <option v-for="secc in secciones" :key="secc.secc" :value="secc.secc">
                  {{ secc.secc }} - {{ secc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Local</label>
              <input type="number" class="municipal-form-control" v-model="filters.local" placeholder="Numero de local" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="filters.letra" placeholder="Letra" maxlength="2" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="filters.bloque" placeholder="Bloque" maxlength="2" @keyup.enter="buscar" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar Local
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="store-alt" /> Datos del Local</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione mercado y local para buscar</p>
            </div>
          </div>

          <div v-else-if="!localData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">No se encontro el local o no tiene adeudos</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="store" /> Informacion del Local</h6>
                <table class="detail-table">
                  <tr><td class="label">Local:</td><td><strong class="text-primary">{{ localData.local }}{{ localData.letra || '' }}</strong></td></tr>
                  <tr><td class="label">Locatario:</td><td>{{ localData.nombre || 'N/A' }}</td></tr>
                  <tr><td class="label">Mercado:</td><td>{{ localData.mercado_nombre || 'N/A' }}</td></tr>
                  <tr><td class="label">Seccion:</td><td>{{ localData.seccion }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="dollar-sign" /> Adeudos</h6>
                <table class="detail-table">
                  <tr><td class="label">Periodo Minimo:</td><td>{{ localData.minimo }}</td></tr>
                  <tr><td class="label">Periodo Maximo:</td><td>{{ localData.maximo }}</td></tr>
                  <tr><td class="label">Multas:</td><td class="text-end"><strong class="text-danger">{{ formatCurrency(localData.multas) }}</strong></td></tr>
                </table>
              </div>
            </div>

            <div v-if="localData.multas > 0 && !localData.bloqueo" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="percent" /> Aplicar Descuento</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Periodo Final</label>
                    <input type="text" class="municipal-form-control" v-model="descuento.periodoFin" placeholder="AAAA-MM" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Porcentaje</label>
                    <input type="number" class="municipal-form-control" v-model="descuento.porcentaje" min="0" max="100" placeholder="%" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Funcionario</label>
                    <select class="municipal-form-control" v-model="descuento.funcionario">
                      <option value="">Seleccione...</option>
                      <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">
                        {{ func.nombre }} (Max: {{ func.porcentajetope }}%)
                      </option>
                    </select>
                  </div>
                </div>

                <div class="button-group mt-4">
                  <button class="btn-municipal-success" @click="aplicarDescuento" :disabled="loading || !descuento.funcionario">
                    <font-awesome-icon icon="check" /> Aplicar Descuento
                  </button>
                </div>
              </div>
            </div>

            <div v-else-if="localData.bloqueo" class="alert alert-warning">
              <font-awesome-icon icon="lock" class="me-2" />
              Este local tiene un convenio vigente y no puede recibir descuentos
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <DocumentationModal :show="showDocModal" :componentName="'DescMultaMercados'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Multas Mercados'" @close="showDocModal = false" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { loading, toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showFilters = ref(true)
const searchPerformed = ref(false)
const localData = ref(null)
const recaudadoras = ref([])
const mercados = ref([])
const secciones = ref([])
const funcionarios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ recaudadora: '', mercado: '', seccion: '', local: '', letra: '', bloque: '' })
const descuento = ref({ periodoFin: '', porcentaje: 0, funcionario: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const cargarRecaudadoras = async () => {
  try {
    const response = await execute('sp_get_recaudadoras', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (response?.result) recaudadoras.value = response.result
  } catch (error) { console.error('Error cargando recaudadoras:', error) }
}

const cargarMercados = async () => {
  mercados.value = []
  secciones.value = []
  filters.value.mercado = ''
  filters.value.seccion = ''

  if (!filters.value.recaudadora) return

  try {
    const response = await execute('sp_get_mercados_por_recaud', 'multas_reglamentos',
      [{ nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' }],
      'guadalajara', null, 'publico')
    if (response?.result) mercados.value = response.result
  } catch (error) { console.error('Error cargando mercados:', error) }
}

const cargarSecciones = async () => {
  secciones.value = []
  filters.value.seccion = ''

  if (!filters.value.mercado) return

  try {
    const response = await execute('sp_get_secciones_mercado', 'multas_reglamentos',
      [{ nombre: 'p_num_merc', valor: parseInt(filters.value.mercado), tipo: 'integer' }],
      'guadalajara', null, 'publico')
    if (response?.result) secciones.value = response.result
  } catch (error) { console.error('Error cargando secciones:', error) }
}

const cargarFuncionarios = async () => {
  try {
    const response = await execute('sp_get_funcionarios_autoriza', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (response?.result) funcionarios.value = response.result
  } catch (error) { console.error('Error cargando funcionarios:', error) }
}

const buscar = async () => {
  if (!filters.value.recaudadora || !filters.value.mercado || !filters.value.local) {
    showToast('warning', 'Debe seleccionar recaudadora, mercado e ingresar local')
    return
  }

  showLoading('Buscando local...', 'Consultando base de datos')
  searchPerformed.value = true
  descuento.value = { periodoFin: '', porcentaje: 0, funcionario: '' }

  try {
    const response = await execute('sp_descmultamerc_consulta', 'multas_reglamentos',
      [
        { nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' },
        { nombre: 'p_mercado', valor: parseInt(filters.value.mercado), tipo: 'integer' },
        { nombre: 'p_seccion', valor: filters.value.seccion || null, tipo: 'string' },
        { nombre: 'p_local', valor: parseInt(filters.value.local), tipo: 'integer' },
        { nombre: 'p_letra', valor: filters.value.letra || null, tipo: 'string' },
        { nombre: 'p_bloque', valor: filters.value.bloque || null, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      localData.value = response.result[0]
      if (localData.value.maximo) {
        descuento.value.periodoFin = localData.value.maximo
      }
      showToast('success', 'Local encontrado')
    } else {
      localData.value = null
      showToast('info', 'No se encontro el local o no tiene adeudos')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar local')
    localData.value = null
  } finally {
    hideLoading()
  }
}

const aplicarDescuento = async () => {
  const funcSelec = funcionarios.value.find(f => f.cveautoriza === descuento.value.funcionario)

  if (funcSelec && descuento.value.porcentaje > funcSelec.porcentajetope) {
    await Swal.fire({
      icon: 'warning', title: 'Porcentaje excedido',
      text: `El porcentaje maximo permitido es ${funcSelec.porcentajetope}%`,
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirm = await Swal.fire({
    icon: 'question', title: 'Confirmar Descuento',
    html: `<p>Se aplicara descuento del <strong>${descuento.value.porcentaje}%</strong> al local <strong>${localData.value.local}</strong></p>`,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, aplicar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Aplicando descuento...', 'Por favor espere')

  try {
    const response = await execute('sp_descmultamerc_aplicar', 'multas_reglamentos',
      [
        { nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' },
        { nombre: 'p_periodo_fin', valor: descuento.value.periodoFin, tipo: 'string' },
        { nombre: 'p_porcentaje', valor: descuento.value.porcentaje, tipo: 'integer' },
        { nombre: 'p_funcionario', valor: descuento.value.funcionario, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.success) {
      await Swal.fire({
        icon: 'success', title: 'Descuento aplicado',
        text: `Folio: ${response.result[0].folio || 'N/A'}`,
        confirmButtonColor: '#ea8215'
      })
      buscar()
    } else {
      await Swal.fire({
        icon: 'error', title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo aplicar',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const limpiar = () => {
  filters.value = { recaudadora: '', mercado: '', seccion: '', local: '', letra: '', bloque: '' }
  mercados.value = []
  secciones.value = []
  localData.value = null
  searchPerformed.value = false
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

onMounted(() => {
  cargarRecaudadoras()
  cargarFuncionarios()
})
</script>
