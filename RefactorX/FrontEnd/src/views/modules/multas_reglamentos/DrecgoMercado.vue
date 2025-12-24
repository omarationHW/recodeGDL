<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Descuento Recargos - Mercados</h1>
        <p>Multas y Reglamentos - Aplicacion de Descuentos a Recargos de Locales de Mercados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscarLocal" :disabled="loading">
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
              <select class="municipal-form-control" v-model="filters.mercado" @change="cargarSecciones">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_merc" :value="merc.num_merc">
                  {{ merc.num_merc }} - {{ merc.nombre }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Seccion</label>
              <select class="municipal-form-control" v-model="filters.seccion">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.secc" :value="sec.secc">
                  {{ sec.secc }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Numero de Local</label>
              <input type="number" class="municipal-form-control" v-model="filters.local" placeholder="Numero de local" @keyup.enter="buscarLocal" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="filters.letra" placeholder="Letra" maxlength="2" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="filters.bloque" placeholder="Bloque" maxlength="5" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscarLocal" :disabled="loading">
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
          <h5><font-awesome-icon icon="building" /> Datos del Local</h5>
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
              <p class="empty-state-text">{{ errorMessage || 'Local no encontrado o sin adeudos vencidos' }}</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="store-alt" /> Datos del Local</h6>
                <table class="detail-table">
                  <tr><td class="label">Local:</td><td><strong class="text-primary">{{ localData.local }}{{ localData.letra || '' }}</strong></td></tr>
                  <tr><td class="label">Bloque:</td><td>{{ localData.bloque || 'N/A' }}</td></tr>
                  <tr><td class="label">Nombre:</td><td>{{ localData.nombre || 'N/A' }}</td></tr>
                  <tr><td class="label">Estado:</td><td>
                    <span class="badge" :class="localData.vigencia === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ localData.vigencia === 'V' ? 'Vigente' : 'Baja' }}
                    </span>
                  </td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="calendar-alt" /> Periodo de Adeudo</h6>
                <table class="detail-table">
                  <tr><td class="label">Periodo Minimo:</td><td>{{ localData.minimo || 'N/A' }}</td></tr>
                  <tr><td class="label">Periodo Maximo:</td><td>{{ localData.maximo || 'N/A' }}</td></tr>
                  <tr><td class="label">Bloqueo:</td><td>
                    <span class="badge" :class="localData.bloqueo === 1 ? 'badge-warning' : 'badge-success'">
                      {{ localData.bloqueo === 1 ? 'Conveniado' : 'Sin bloqueo' }}
                    </span>
                  </td></tr>
                </table>
              </div>
            </div>

            <div v-if="descuentoExistente && descuentoExistente.vigencia === 'V'" class="alert alert-info mb-4">
              <font-awesome-icon icon="info-circle" class="me-2" />
              <strong>Descuento vigente:</strong> {{ descuentoExistente.porc }}%
              (Del {{ descuentoExistente.axo_ini }}/{{ descuentoExistente.mes_ini }} al {{ descuentoExistente.axo_fin }}/{{ descuentoExistente.mes_fin }})
            </div>

            <div v-if="localData.bloqueo !== 1 && !localData.minimo" class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Este local no tiene adeudos pendientes
            </div>

            <div v-else-if="localData.bloqueo === 1" class="alert alert-warning">
              <font-awesome-icon icon="exclamation-triangle" class="me-2" />
              Este local esta conveniado, no se puede aplicar descuento
            </div>

            <div v-else-if="!descuentoExistente || descuentoExistente.vigencia !== 'V'" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="percent" /> Aplicar Descuento de Recargos</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Periodo Inicial</label>
                    <input type="text" class="municipal-form-control" :value="localData.minimo" disabled />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Periodo Final (YYYY-MM)</label>
                    <input type="text" class="municipal-form-control" v-model="descuento.periodoFin" placeholder="Ej: 2024-12" maxlength="7" />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Porcentaje</label>
                    <input type="number" class="municipal-form-control" v-model="descuento.porcentaje" min="1" max="100" placeholder="%" />
                  </div>
                </div>

                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Funcionario que Autoriza</label>
                    <select class="municipal-form-control" v-model="descuento.funcionario">
                      <option value="">Seleccione...</option>
                      <option v-for="func in funcionarios" :key="func.cveautoriza" :value="func.cveautoriza">
                        {{ func.nombre }} (Max: {{ func.porcentajetope }}%)
                      </option>
                    </select>
                  </div>
                </div>

                <div class="button-group mt-4">
                  <button class="btn-municipal-success" @click="aplicarDescuento"
                    :disabled="loading || !descuento.funcionario || !descuento.porcentaje || !descuento.periodoFin">
                    <font-awesome-icon icon="check" /> Aplicar Descuento
                  </button>
                </div>
              </div>
            </div>

            <div v-if="descuentoExistente && descuentoExistente.vigencia === 'V'" class="municipal-card mt-4">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="edit" /> Modificar Descuento Existente</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Nuevo Porcentaje</label>
                    <input type="number" class="municipal-form-control" v-model="descuento.porcentaje" min="1" max="100" />
                  </div>
                </div>
                <div class="button-group mt-4">
                  <button class="btn-municipal-warning" @click="modificarDescuento" :disabled="loading">
                    <font-awesome-icon icon="save" /> Actualizar Descuento
                  </button>
                </div>
              </div>
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

    <DocumentationModal :show="showDocModal" :componentName="'DrecgoMercado'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Recargos Mercados'" @close="showDocModal = false" />
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
const descuentoExistente = ref(null)
const errorMessage = ref('')
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
    recaudadoras.value = response?.result || []
  } catch (error) { console.error('Error cargando recaudadoras:', error) }
}

const cargarMercados = async () => {
  if (!filters.value.recaudadora) { mercados.value = []; return }
  try {
    const response = await execute('sp_get_mercados', 'multas_reglamentos',
      [{ nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' }],
      'guadalajara', null, 'publico')
    mercados.value = response?.result || []
  } catch (error) { console.error('Error cargando mercados:', error) }
}

const cargarSecciones = async () => {
  if (!filters.value.mercado) { secciones.value = []; return }
  try {
    const response = await execute('sp_get_secciones', 'multas_reglamentos',
      [{ nombre: 'p_num_merc', valor: parseInt(filters.value.mercado), tipo: 'integer' }],
      'guadalajara', null, 'publico')
    secciones.value = response?.result || []
  } catch (error) { console.error('Error cargando secciones:', error) }
}

const cargarFuncionarios = async () => {
  try {
    const response = await execute('sp_get_funcionarios_descrecargo', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    funcionarios.value = response?.result || []
  } catch (error) { console.error('Error cargando funcionarios:', error) }
}

const verificarCampana = async () => {
  try {
    const response = await execute('sp_verifica_campana_descuento', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    if (!response?.result?.[0]) {
      await Swal.fire({ icon: 'warning', title: 'Sin Campana', text: 'No existe campana de descuento autorizada', confirmButtonColor: '#ea8215' })
      return false
    }
    return true
  } catch { return false }
}

const buscarLocal = async () => {
  if (!filters.value.recaudadora || !filters.value.mercado || !filters.value.seccion || !filters.value.local) {
    showToast('warning', 'Debe seleccionar recaudadora, mercado, seccion y numero de local')
    return
  }

  const campaniaOk = await verificarCampana()
  if (!campaniaOk) return

  showLoading('Buscando local...', 'Consultando base de datos')
  searchPerformed.value = true
  errorMessage.value = ''
  descuento.value = { periodoFin: '', porcentaje: 0, funcionario: '' }

  try {
    const response = await execute('sp_drecgomercado_busca', 'multas_reglamentos',
      [
        { nombre: 'p_recaud', valor: parseInt(filters.value.recaudadora), tipo: 'integer' },
        { nombre: 'p_mercado', valor: parseInt(filters.value.mercado), tipo: 'integer' },
        { nombre: 'p_seccion', valor: filters.value.seccion, tipo: 'string' },
        { nombre: 'p_local', valor: parseInt(filters.value.local), tipo: 'integer' },
        { nombre: 'p_letra', valor: filters.value.letra || null, tipo: 'string' },
        { nombre: 'p_bloque', valor: filters.value.bloque || null, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      localData.value = response.result[0]
      descuento.value.periodoFin = localData.value.maximo || ''

      // Buscar descuento existente
      const descResp = await execute('sp_drecgomercado_descuento', 'multas_reglamentos',
        [{ nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' }],
        'guadalajara', null, 'publico')

      descuentoExistente.value = descResp?.result?.[0] || null
      showToast('success', 'Local encontrado')
    } else {
      localData.value = null
      errorMessage.value = 'Local no existe, esta dado de baja o sin adeudo vencido'
      showToast('info', errorMessage.value)
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
    await Swal.fire({ icon: 'warning', title: 'Porcentaje excedido', text: `Maximo permitido: ${funcSelec.porcentajetope}%`, confirmButtonColor: '#ea8215' })
    return
  }

  // Validar formato periodo
  if (!/^\d{4}-\d{2}$/.test(descuento.value.periodoFin)) {
    showToast('warning', 'Formato de periodo incorrecto. Use YYYY-MM')
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
    const [axoFin, mesFin] = descuento.value.periodoFin.split('-')
    const [axoIni, mesIni] = localData.value.minimo.split('-')

    const response = await execute('sp_drecgomercado_aplica', 'multas_reglamentos',
      [
        { nombre: 'p_id_local', valor: localData.value.id_local, tipo: 'integer' },
        { nombre: 'p_axo_ini', valor: parseInt(axoIni), tipo: 'integer' },
        { nombre: 'p_mes_ini', valor: parseInt(mesIni), tipo: 'integer' },
        { nombre: 'p_axo_fin', valor: parseInt(axoFin), tipo: 'integer' },
        { nombre: 'p_mes_fin', valor: parseInt(mesFin), tipo: 'integer' },
        { nombre: 'p_porcentaje', valor: descuento.value.porcentaje, tipo: 'integer' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    hideLoading()

    if (response?.result?.[0]?.control) {
      await Swal.fire({ icon: 'success', title: 'Descuento aplicado', text: `Folio: ${response.result[0].control}`, confirmButtonColor: '#ea8215' })
      buscarLocal()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo aplicar el descuento', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const modificarDescuento = async () => {
  // Similar a aplicar pero con opcion 2
  showToast('info', 'Funcion de modificacion en desarrollo')
}

const limpiar = () => {
  filters.value = { recaudadora: '', mercado: '', seccion: '', local: '', letra: '', bloque: '' }
  localData.value = null
  descuentoExistente.value = null
  searchPerformed.value = false
  mercados.value = []
  secciones.value = []
}

onMounted(() => {
  cargarRecaudadoras()
  cargarFuncionarios()
})
</script>
