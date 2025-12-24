<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="broom" /></div>
      <div class="module-view-info">
        <h1>Descuento Recargos - Aseo</h1>
        <p>Multas y Reglamentos - Aplicacion de Descuentos a Recargos de Contratos de Aseo</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscarContrato" :disabled="loading">
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
            <font-awesome-icon icon="filter" /> Busqueda de Contrato
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Contrato</label>
              <select class="municipal-form-control" v-model="filters.tipo">
                <option value="">Seleccione...</option>
                <option v-for="tipo in tiposContrato" :key="tipo.cve" :value="tipo.cve">
                  {{ tipo.descripicion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Numero de Contrato</label>
              <input type="number" class="municipal-form-control" v-model="filters.contrato" placeholder="Numero de contrato" @keyup.enter="buscarContrato" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscarContrato" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar Contrato
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
          <h5><font-awesome-icon icon="file-contract" /> Datos del Contrato</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione tipo e ingrese numero de contrato</p>
            </div>
          </div>

          <div v-else-if="!contratoData" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">Contrato de Aseo Cancelado o sin Adeudos</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="file-contract" /> Datos del Contrato</h6>
                <table class="detail-table">
                  <tr><td class="label">Contrato:</td><td><strong class="text-primary">{{ contratoData.num_contrato }}</strong></td></tr>
                  <tr><td class="label">Tipo:</td><td>{{ getTipoNombre(contratoData.cve) }}</td></tr>
                  <tr><td class="label">Nombre:</td><td>{{ contratoData.nombre || 'N/A' }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="calendar-alt" /> Periodo de Adeudo</h6>
                <table class="detail-table">
                  <tr><td class="label">Periodo Minimo:</td><td>{{ contratoData.minimo || 'N/A' }}</td></tr>
                  <tr><td class="label">Periodo Maximo:</td><td>{{ contratoData.maximo || 'N/A' }}</td></tr>
                </table>
              </div>
            </div>

            <div v-if="descuentoExistente && descuentoExistente.vigencia === 'V'" class="alert alert-info mb-4">
              <font-awesome-icon icon="info-circle" class="me-2" />
              <strong>Descuento vigente:</strong> {{ descuentoExistente.porc }}%
              (Del {{ descuentoExistente.axo_ini }}/{{ descuentoExistente.mes_ini }} al {{ descuentoExistente.axo_fin }}/{{ descuentoExistente.mes_fin }})
            </div>

            <div v-if="!contratoData.minimo" class="alert alert-success">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Este contrato no tiene adeudos pendientes
            </div>

            <div v-else-if="!descuentoExistente || descuentoExistente.vigencia !== 'V'" class="municipal-card">
              <div class="municipal-card-header">
                <h5><font-awesome-icon icon="percent" /> Aplicar Descuento de Recargos</h5>
              </div>
              <div class="municipal-card-body">
                <div class="form-row">
                  <div class="form-group">
                    <label class="municipal-form-label">Periodo Inicial</label>
                    <input type="text" class="municipal-form-control" :value="contratoData.minimo" disabled />
                  </div>
                  <div class="form-group">
                    <label class="municipal-form-label">Periodo Final</label>
                    <input type="text" class="municipal-form-control" :value="contratoData.maximo" disabled />
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
                    :disabled="loading || !descuento.funcionario || !descuento.porcentaje">
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

    <DocumentationModal :show="showDocModal" :componentName="'drecgoAseo'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Descuento Recargos Aseo'" @close="showDocModal = false" />
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
const contratoData = ref(null)
const descuentoExistente = ref(null)
const tiposContrato = ref([])
const funcionarios = ref([])
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ tipo: '', contrato: '' })
const descuento = ref({ porcentaje: 0, funcionario: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const getTipoNombre = (cve) => {
  const tipo = tiposContrato.value.find(t => t.cve === cve)
  return tipo?.descripicion || cve
}

const cargarTiposContrato = async () => {
  try {
    const response = await execute('sp_get_tipos_contrato_aseo', 'multas_reglamentos', [], 'guadalajara', null, 'publico')
    tiposContrato.value = response?.result || []
  } catch (error) { console.error('Error cargando tipos:', error) }
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

const buscarContrato = async () => {
  if (!filters.value.tipo || !filters.value.contrato) {
    showToast('warning', 'Debe seleccionar tipo e ingresar numero de contrato')
    return
  }

  const campaniaOk = await verificarCampana()
  if (!campaniaOk) return

  showLoading('Buscando contrato...', 'Consultando base de datos')
  searchPerformed.value = true
  descuento.value = { porcentaje: 0, funcionario: '' }

  try {
    const response = await execute('sp_drecgoaseo_busca', 'multas_reglamentos',
      [
        { nombre: 'p_tipo', valor: parseInt(filters.value.tipo), tipo: 'integer' },
        { nombre: 'p_contrato', valor: parseInt(filters.value.contrato), tipo: 'integer' }
      ],
      'guadalajara', null, 'publico')

    if (response?.result?.[0]) {
      contratoData.value = response.result[0]

      // Buscar descuento existente
      const descResp = await execute('sp_drecgoaseo_descuento', 'multas_reglamentos',
        [{ nombre: 'p_id_contrato', valor: contratoData.value.id_contrato, tipo: 'integer' }],
        'guadalajara', null, 'publico')

      descuentoExistente.value = descResp?.result?.[0] || null
      showToast('success', 'Contrato encontrado')
    } else {
      contratoData.value = null
      showToast('info', 'Contrato de Aseo Cancelado o sin Adeudos')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar contrato')
    contratoData.value = null
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

  const confirm = await Swal.fire({
    icon: 'question', title: 'Confirmar Descuento',
    html: `<p>Se aplicara descuento del <strong>${descuento.value.porcentaje}%</strong> al contrato <strong>${contratoData.value.num_contrato}</strong></p>`,
    showCancelButton: true, confirmButtonColor: '#28a745', cancelButtonColor: '#6c757d',
    confirmButtonText: 'Si, aplicar', cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Aplicando descuento...', 'Por favor espere')

  try {
    const [axoIni, mesIni] = contratoData.value.minimo.split('-')
    const [axoFin, mesFin] = contratoData.value.maximo.split('-')

    const response = await execute('sp_drecgoaseo_aplica', 'multas_reglamentos',
      [
        { nombre: 'p_id_contrato', valor: contratoData.value.id_contrato, tipo: 'integer' },
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
      buscarContrato()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo aplicar el descuento', confirmButtonColor: '#ea8215' })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al aplicar descuento')
  }
}

const modificarDescuento = async () => {
  showToast('info', 'Funcion de modificacion en desarrollo')
}

const limpiar = () => {
  filters.value = { tipo: '', contrato: '' }
  contratoData.value = null
  descuentoExistente.value = null
  searchPerformed.value = false
}

onMounted(() => {
  cargarTiposContrato()
  cargarFuncionarios()
})
</script>
