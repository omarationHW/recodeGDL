<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Estado de Cuenta - Licencias y Anuncios</h1>
        <p>Multas y Reglamentos - Consulta de Estado de Cuenta para Licencias y Anuncios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-success" @click="imprimir" :disabled="loading || !datosGenerales">
          <font-awesome-icon icon="print" /> Imprimir
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
            <font-awesome-icon icon="filter" /> Busqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Cuenta</label>
              <div class="radio-group">
                <label class="radio-option">
                  <input type="radio" v-model="filters.tipo" value="L" />
                  <span>Licencia</span>
                </label>
                <label class="radio-option">
                  <input type="radio" v-model="filters.tipo" value="A" />
                  <span>Anuncio</span>
                </label>
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Numero de {{ filters.tipo === 'L' ? 'Licencia' : 'Anuncio' }}</label>
              <input type="number" class="municipal-form-control" v-model="filters.numero" placeholder="Ingrese numero" @keyup.enter="buscar" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12 text-end">
              <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
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
          <h5><font-awesome-icon icon="id-card" /> Datos Generales</h5>
        </div>

        <div class="municipal-card-body">
          <div v-if="!searchPerformed" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="inbox" class="empty-state-icon" />
              <p class="empty-state-text">Seleccione tipo e ingrese el numero</p>
            </div>
          </div>

          <div v-else-if="!datosGenerales" class="empty-state">
            <div class="empty-state-content">
              <font-awesome-icon icon="search" class="empty-state-icon" />
              <p class="empty-state-text">{{ filters.tipo === 'L' ? 'Licencia' : 'Anuncio' }} sin costo de Derechos</p>
            </div>
          </div>

          <div v-else>
            <div class="details-grid mb-4">
              <div class="detail-section">
                <h6 class="section-title">
                  <font-awesome-icon :icon="filters.tipo === 'L' ? 'store' : 'ad'" />
                  {{ filters.tipo === 'L' ? 'Datos de la Licencia' : 'Datos del Anuncio' }}
                </h6>
                <table class="detail-table">
                  <tr><td class="label">{{ filters.tipo === 'L' ? 'Licencia' : 'Anuncio' }}:</td><td><strong class="text-primary">{{ datosGenerales.numero }}</strong></td></tr>
                  <tr><td class="label">Propietario:</td><td>{{ datosGenerales.propietario || 'N/A' }}</td></tr>
                  <tr><td class="label">Ubicacion:</td><td>{{ datosGenerales.ubicacion || 'N/A' }}</td></tr>
                  <tr><td class="label">Giro:</td><td>{{ datosGenerales.giro || 'N/A' }}</td></tr>
                </table>
              </div>
              <div class="detail-section">
                <h6 class="section-title"><font-awesome-icon icon="calendar-check" /> Periodo</h6>
                <table class="detail-table">
                  <tr><td class="label">Periodo Min:</td><td>{{ datosGenerales.min || 'N/A' }}</td></tr>
                  <tr><td class="label">Periodo Max:</td><td>{{ datosGenerales.max || 'N/A' }}</td></tr>
                  <tr><td class="label">Recaudadora:</td><td>{{ datosGenerales.recaud || 'N/A' }}</td></tr>
                  <tr><td class="label">Zona:</td><td>{{ datosGenerales.zona || 'N/A' }}</td></tr>
                </table>
              </div>
            </div>

            <div class="tabs-container mb-4">
              <div class="tab-buttons">
                <button class="tab-button" :class="{ active: activeTab === 'adeudos' }" @click="activeTab = 'adeudos'">
                  <font-awesome-icon icon="money-bill" /> Adeudos por Año
                </button>
                <button class="tab-button" :class="{ active: activeTab === 'conceptos' }" @click="activeTab = 'conceptos'">
                  <font-awesome-icon icon="list" /> Conceptos
                </button>
              </div>

              <div class="tab-content">
                <div v-if="activeTab === 'adeudos'" class="table-responsive">
                  <table class="municipal-table">
                    <thead>
                      <tr>
                        <th>Año</th>
                        <th>Concepto</th>
                        <th class="text-end">Formas</th>
                        <th class="text-end">Derechos</th>
                        <th class="text-end">Desc. Derechos</th>
                        <th class="text-end">Recargos</th>
                        <th class="text-end">Desc. Recargos</th>
                        <th class="text-end">Gastos</th>
                        <th class="text-end">Multas</th>
                        <th class="text-end">Saldo</th>
                        <th>Bloq</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="adeudo in adeudosAnio" :key="adeudo.axo + '-' + adeudo.concepto">
                        <td>{{ adeudo.axo }}</td>
                        <td>{{ adeudo.concepto }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.formas) }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.derechos) }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.desc_derechos) }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.recargos) }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.desc_recargos) }}</td>
                        <td class="text-end">{{ formatCurrency(adeudo.gastos) }}</td>
                        <td class="text-end text-danger">{{ formatCurrency(adeudo.multas) }}</td>
                        <td class="text-end"><strong>{{ formatCurrency(adeudo.saldo) }}</strong></td>
                        <td>{{ adeudo.bloq || '-' }}</td>
                      </tr>
                    </tbody>
                    <tfoot v-if="adeudosAnio.length > 0">
                      <tr>
                        <td colspan="9" class="text-end"><strong>Total Saldo:</strong></td>
                        <td class="text-end"><strong>{{ formatCurrency(totalSaldo) }}</strong></td>
                        <td></td>
                      </tr>
                    </tfoot>
                  </table>
                </div>

                <div v-if="activeTab === 'conceptos'" class="table-responsive">
                  <table class="municipal-table">
                    <thead>
                      <tr>
                        <th>Grupo</th>
                        <th>Cuenta</th>
                        <th>Obligacion</th>
                        <th>Concepto</th>
                        <th class="text-end">Importe</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(concepto, idx) in conceptos" :key="idx">
                        <td>{{ concepto.grupo }}</td>
                        <td>{{ concepto.cuenta }}</td>
                        <td>{{ concepto.obliga }}</td>
                        <td>{{ concepto.concepto }}</td>
                        <td class="text-end"><strong>{{ formatCurrency(concepto.importe) }}</strong></td>
                      </tr>
                    </tbody>
                    <tfoot v-if="conceptos.length > 0">
                      <tr>
                        <td colspan="4" class="text-end"><strong>Total:</strong></td>
                        <td class="text-end"><strong>{{ formatCurrency(totalConceptos) }}</strong></td>
                      </tr>
                    </tfoot>
                  </table>
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

    <DocumentationModal :show="showDocModal" :componentName="'EdoCtaLicencias'" :moduleName="'multas_reglamentos'"
      :docType="docType" :title="'Estado de Cuenta Licencias'" @close="showDocModal = false" />
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
const searchPerformed = ref(false)
const datosGenerales = ref(null)
const adeudosAnio = ref([])
const conceptos = ref([])
const activeTab = ref('adeudos')
const showDocModal = ref(false)
const docType = ref('ayuda')

const filters = ref({ tipo: 'L', numero: '' })

const toggleFilters = () => { showFilters.value = !showFilters.value }
const abrirAyuda = () => { docType.value = 'ayuda'; showDocModal.value = true }
const abrirDocumentacion = () => { docType.value = 'documentacion'; showDocModal.value = true }

const totalSaldo = computed(() => {
  return adeudosAnio.value.reduce((sum, a) => sum + (parseFloat(a.saldo) || 0), 0)
})

const totalConceptos = computed(() => {
  return conceptos.value.reduce((sum, c) => sum + (parseFloat(c.importe) || 0), 0)
})

const buscar = async () => {
  if (!filters.value.numero) {
    showToast('warning', `Debe ingresar el numero de ${filters.value.tipo === 'L' ? 'licencia' : 'anuncio'}`)
    return
  }

  showLoading('Consultando estado de cuenta...', 'Cargando informacion')
  searchPerformed.value = true
  activeTab.value = 'adeudos'

  try {
    // Buscar datos generales
    const spBusca = filters.value.tipo === 'L' ? 'sp_edoctalic_busca_licencia' : 'sp_edoctalic_busca_anuncio'
    const paramName = filters.value.tipo === 'L' ? 'p_licencia' : 'p_anuncio'

    const response = await execute(spBusca, 'multas_reglamentos',
      [{ nombre: paramName, valor: parseInt(filters.value.numero), tipo: 'integer' }],
      'guadalajara', null, 'publico')

    if (!response?.result?.[0]) {
      datosGenerales.value = null
      adeudosAnio.value = []
      conceptos.value = []
      showToast('info', `${filters.value.tipo === 'L' ? 'Licencia' : 'Anuncio'} sin costo de Derechos`)
      return
    }

    datosGenerales.value = response.result[0]

    // Cargar adeudos por año
    const adeudosResp = await execute('sp_edoctalic_adeudos', 'multas_reglamentos',
      [
        { nombre: 'p_id', valor: datosGenerales.value.id, tipo: 'integer' },
        { nombre: 'p_tipo', valor: filters.value.tipo, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    adeudosAnio.value = adeudosResp?.result || []

    // Cargar conceptos
    const conceptosResp = await execute('sp_edoctalic_conceptos', 'multas_reglamentos',
      [
        { nombre: 'p_id', valor: datosGenerales.value.id, tipo: 'integer' },
        { nombre: 'p_tipo', valor: filters.value.tipo, tipo: 'string' }
      ],
      'guadalajara', null, 'publico')

    conceptos.value = conceptosResp?.result || []

    showToast('success', 'Estado de cuenta cargado')
  } catch (error) {
    handleApiError(error, 'Error al consultar estado de cuenta')
    datosGenerales.value = null
    adeudosAnio.value = []
    conceptos.value = []
  } finally {
    hideLoading()
  }
}

const imprimir = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Imprimir Estado de Cuenta',
    text: `Se generara el estado de cuenta para ${filters.value.tipo === 'L' ? 'Licencia' : 'Anuncio'} ${datosGenerales.value.numero}`,
    confirmButtonColor: '#ea8215'
  })

  // Aqui iria la logica de impresion/generacion PDF
  showToast('success', 'Documento generado correctamente')
}

const limpiar = () => {
  filters.value = { tipo: 'L', numero: '' }
  datosGenerales.value = null
  adeudosAnio.value = []
  conceptos.value = []
  searchPerformed.value = false
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}
</script>
