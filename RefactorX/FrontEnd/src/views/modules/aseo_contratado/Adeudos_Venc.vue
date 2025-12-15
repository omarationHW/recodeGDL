<template>
  <div class="module-view">
    <!-- Header del modulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-xmark" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Vencidos</h1>
        <p>Aseo Contratado - Estado de cuenta con adeudos vencidos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="limpiarFormulario" title="Limpiar">
          <font-awesome-icon icon="eraser" />
          Limpiar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Panel de Busqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header municipal-header-primary">
        <h6 class="mb-0">
          <font-awesome-icon icon="search" class="me-2" />
          Busqueda de Contrato
        </h6>
      </div>
      <div class="municipal-card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="municipal-form-label">Numero de Contrato</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filtros.num_contrato"
              @keypress.enter="buscarContrato"
              placeholder="Ej: 1234"
              min="1"
            />
          </div>
          <div class="col-md-4">
            <label class="municipal-form-label">Tipo de Aseo</label>
            <select class="municipal-form-control" v-model="filtros.ctrol_aseo">
              <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                {{ tipo.ctrol_aseo }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Vigencia</label>
            <select class="municipal-form-control" v-model="filtros.tipo_vigencia">
              <option value="0">Periodos Vencidos</option>
              <option value="1">Hasta Periodo Posterior</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarContrato">
              <font-awesome-icon icon="search" class="me-1" />
              Buscar
            </button>
          </div>
        </div>

        <!-- Periodo Posterior (visible solo cuando tipo_vigencia = 1) -->
        <div class="row g-3 mt-2" v-if="filtros.tipo_vigencia === '1'">
          <div class="col-md-3">
            <label class="municipal-form-label">Ejercicio Posterior</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filtros.ejercicio_posterior"
              :min="ejercicioActual"
              placeholder="2025"
            />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Mes Posterior</label>
            <select class="municipal-form-control" v-model="filtros.mes_posterior">
              <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                {{ mes.label }}
              </option>
            </select>
          </div>
          <div class="col-md-6">
            <div class="alert alert-info mb-0 mt-4">
              <font-awesome-icon icon="info-circle" class="me-2" />
              El mes posterior debe ser mayor al mes actual
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Datos del Contrato (visible despues de buscar) -->
    <div v-if="contrato" class="mt-4">
      <div class="municipal-card">
        <div class="municipal-card-header municipal-header-info">
          <h6 class="mb-0">
            <font-awesome-icon icon="file-contract" class="me-2" />
            Datos del Contrato #{{ contrato.num_contrato }}
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tbody>
                  <tr>
                    <td class="fw-bold" width="40%">Empresa:</td>
                    <td>{{ contrato.nom_emp }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Tipo Empresa:</td>
                    <td>{{ contrato.tipo_emp }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Representante:</td>
                    <td>{{ contrato.representante || 'N/A' }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Domicilio:</td>
                    <td>{{ contrato.domicilio }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Sector:</td>
                    <td>{{ contrato.sector }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="col-md-6">
              <table class="table table-sm table-borderless">
                <tbody>
                  <tr>
                    <td class="fw-bold" width="40%">Tipo Aseo:</td>
                    <td>{{ contrato.tipo_aseo }} - {{ contrato.desc_aseo }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Recoleccion:</td>
                    <td>{{ contrato.cve_recolec }} - {{ contrato.desc_recolec }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Cantidad:</td>
                    <td>{{ contrato.cantidad_recolec }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Zona:</td>
                    <td>{{ contrato.zona }}-{{ contrato.sub_zona }} {{ contrato.nom_zona }}</td>
                  </tr>
                  <tr>
                    <td class="fw-bold">Status:</td>
                    <td>
                      <span class="badge" :class="getStatusClass(contrato.status_vigencia)">
                        {{ getStatusLabel(contrato.status_vigencia) }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- Detalle de Adeudos Vencidos -->
      <div class="municipal-card mt-4" v-if="adeudos.length > 0">
        <div class="municipal-card-header municipal-header-danger">
          <h6 class="mb-0">
            <font-awesome-icon icon="list" class="me-2" />
            Detalle de Adeudos Vencidos
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Periodo</th>
                  <th>Operacion</th>
                  <th>Descripcion</th>
                  <th class="text-center">Cantidad</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total Periodo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudos" :key="index"
                    :class="{ 'table-warning': adeudo.cam === 'B' || adeudo.cam === 'D' }">
                  <td>{{ adeudo.aso_mes_pago }}</td>
                  <td>{{ adeudo.ctrol_operacion }}</td>
                  <td>{{ adeudo.descripcion }}</td>
                  <td class="text-center">{{ adeudo.exedencias || contrato.cantidad_recolec }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.importe) }}</td>
                  <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(adeudo.total_periodo) }}</td>
                </tr>
              </tbody>
              <tfoot class="table-secondary">
                <tr>
                  <td colspan="4" class="text-end fw-bold">Subtotal Cuota Normal:</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.cuota_normal) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.recargos_cn) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.total_cn) }}</td>
                </tr>
                <tr>
                  <td colspan="4" class="text-end fw-bold">Subtotal Exedencias:</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.exedencias) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.recargos_exe) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.total_exe) }}</td>
                </tr>
                <tr class="table-dark">
                  <td colspan="4" class="text-end fw-bold">TOTAL PERIODOS:</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.total_importe) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.total_recargos) }}</td>
                  <td class="text-end fw-bold">${{ formatCurrency(totales.total_periodos) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Requerimientos/Apremios -->
      <div class="municipal-card mt-4" v-if="apremios">
        <div class="municipal-card-header municipal-header-warning">
          <h6 class="mb-0">
            <font-awesome-icon icon="gavel" class="me-2" />
            Requerimientos / Apremios
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-4">
              <div class="text-center p-3 bg-light rounded">
                <h6 class="text-muted">No. Requerimientos</h6>
                <h3>{{ apremios.no_requerimientos }}</h3>
              </div>
            </div>
            <div class="col-md-4">
              <div class="text-center p-3 bg-light rounded">
                <h6 class="text-muted">Importe Multas</h6>
                <h3 class="text-danger">${{ formatCurrency(apremios.total_multas) }}</h3>
              </div>
            </div>
            <div class="col-md-4">
              <div class="text-center p-3 bg-light rounded">
                <h6 class="text-muted">Importe Gastos</h6>
                <h3 class="text-warning">${{ formatCurrency(apremios.total_gastos) }}</h3>
              </div>
            </div>
          </div>
          <div class="row mt-3" v-if="apremios.folios_requerimientos">
            <div class="col-12">
              <p class="mb-1"><strong>Folios:</strong> {{ apremios.folios_requerimientos }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Resumen Total a Pagar -->
      <div class="municipal-card mt-4">
        <div class="municipal-card-header municipal-header-success">
          <h6 class="mb-0">
            <font-awesome-icon icon="calculator" class="me-2" />
            Resumen Total a Pagar
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-8">
              <table class="table table-borderless">
                <tbody>
                  <tr>
                    <td>Total Periodos (Adeudos + Recargos):</td>
                    <td class="text-end fw-bold">${{ formatCurrency(totales.total_periodos) }}</td>
                  </tr>
                  <tr>
                    <td>Total Requerimientos (Multas + Gastos):</td>
                    <td class="text-end fw-bold">${{ formatCurrency(totalRequerimientos) }}</td>
                  </tr>
                  <tr class="table-success">
                    <td class="fs-5 fw-bold">TOTAL A PAGAR:</td>
                    <td class="text-end fs-4 fw-bold text-success">${{ formatCurrency(totalPagar) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="col-md-4 text-center">
              <button class="btn-municipal-success btn-lg w-100" @click="imprimirReporte">
                <font-awesome-icon icon="print" class="me-2" />
                Imprimir Estado de Cuenta
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Sin Adeudos -->
    <div v-else-if="buscado && !contrato" class="alert alert-warning mt-4">
      <font-awesome-icon icon="exclamation-triangle" class="me-2" />
      No existen CONTRATOS CON ESTOS DATOS o ESTA CANCELADO, intentalo de nuevo
    </div>

    <div v-else-if="contrato && adeudos.length === 0" class="alert alert-info mt-4">
      <font-awesome-icon icon="info-circle" class="me-2" />
      No existen ADEUDOS de este contrato. Intenta con otro.
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Adeudos Vencidos - Ayuda">
      <h6>Descripcion</h6>
      <p>Modulo para consultar el estado de cuenta con adeudos vencidos de un contrato de aseo contratado.</p>
      <h6>Como usar</h6>
      <ol>
        <li>Ingrese el numero de contrato</li>
        <li>Seleccione el tipo de aseo</li>
        <li>Opcionalmente seleccione "Hasta Periodo Posterior" para incluir adeudos futuros</li>
        <li>Presione "Buscar"</li>
      </ol>
      <h6>Tipos de Vigencia</h6>
      <ul>
        <li><strong>Periodos Vencidos:</strong> Solo muestra adeudos con fecha vencida</li>
        <li><strong>Hasta Periodo Posterior:</strong> Incluye adeudos hasta el periodo especificado</li>
      </ul>
      <h6>Calculo de Recargos</h6>
      <p>Los recargos se calculan automaticamente segun la tabla ta_16_recargos, considerando el dia limite del mes actual.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Estado
const mostrarAyuda = ref(false)
const buscado = ref(false)
const tiposAseo = ref([])
const contrato = ref(null)
const adeudos = ref([])
const apremios = ref(null)
const diaLimite = ref(15)

// Filtros
const filtros = ref({
  num_contrato: null,
  ctrol_aseo: 1,
  tipo_vigencia: '0',  // 0 = Vencidos, 1 = Periodo Posterior
  ejercicio_posterior: new Date().getFullYear(),
  mes_posterior: (new Date().getMonth() + 1).toString().padStart(2, '0')
})

// Computed
const ejercicioActual = computed(() => new Date().getFullYear())
const mesActual = computed(() => new Date().getMonth() + 1)

const meses = computed(() => [
  { value: '01', label: '01 - Enero' },
  { value: '02', label: '02 - Febrero' },
  { value: '03', label: '03 - Marzo' },
  { value: '04', label: '04 - Abril' },
  { value: '05', label: '05 - Mayo' },
  { value: '06', label: '06 - Junio' },
  { value: '07', label: '07 - Julio' },
  { value: '08', label: '08 - Agosto' },
  { value: '09', label: '09 - Septiembre' },
  { value: '10', label: '10 - Octubre' },
  { value: '11', label: '11 - Noviembre' },
  { value: '12', label: '12 - Diciembre' }
])

const totales = computed(() => {
  let cuota_normal = 0
  let recargos_cn = 0
  let exedencias = 0
  let recargos_exe = 0

  adeudos.value.forEach(a => {
    if (a.ctrol_operacion === 6) {
      cuota_normal += parseFloat(a.importe || 0)
      recargos_cn += parseFloat(a.recargos || 0)
    } else {
      exedencias += parseFloat(a.importe || 0)
      recargos_exe += parseFloat(a.recargos || 0)
    }
  })

  return {
    cuota_normal,
    recargos_cn,
    total_cn: cuota_normal + recargos_cn,
    exedencias,
    recargos_exe,
    total_exe: exedencias + recargos_exe,
    total_importe: cuota_normal + exedencias,
    total_recargos: recargos_cn + recargos_exe,
    total_periodos: cuota_normal + recargos_cn + exedencias + recargos_exe
  }
})

const totalRequerimientos = computed(() => {
  if (!apremios.value) return 0
  return parseFloat(apremios.value.total_multas || 0) + parseFloat(apremios.value.total_gastos || 0)
})

const totalPagar = computed(() => {
  return totales.value.total_periodos + totalRequerimientos.value
})

// Watch para validar mes posterior
watch(() => filtros.value.mes_posterior, (newVal) => {
  if (filtros.value.tipo_vigencia === '1') {
    const mesPosterior = parseInt(newVal)
    if (filtros.value.ejercicio_posterior === ejercicioActual.value && mesPosterior < mesActual.value) {
      showToast('El mes debe ser mayor al mes actual', 'warning')
      filtros.value.mes_posterior = mesActual.value.toString().padStart(2, '0')
    }
  }
})

// Metodos
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      tiposAseo.value = data
      if (data.length > 0) {
        filtros.value.ctrol_aseo = data[0].ctrol_aseo
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

const buscarContrato = async () => {
  if (!filtros.value.num_contrato || filtros.value.num_contrato <= 0) {
    showToast('Ingrese un numero de contrato valido', 'warning')
    return
  }

  showLoading()
  buscado.value = true
  contrato.value = null
  adeudos.value = []
  apremios.value = null

  try {
    // 1. Obtener dia limite del mes actual
    const mesActualNum = new Date().getMonth() + 1
    const diaLimiteData = await execute('sp_aseo_get_dia_limite', BASE_DB, [
      { nombre: 'p_mes', valor: mesActualNum, tipo: 'integer' }
    ], '', null, SCHEMA)

    if (diaLimiteData && diaLimiteData.length > 0) {
      diaLimite.value = diaLimiteData[0].dia || 15
    }

    // 2. Buscar contrato completo
    const contratoData = await execute('sp_aseo_buscar_contrato_completo', BASE_DB, [
      { nombre: 'p_num_contrato', valor: filtros.value.num_contrato, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: filtros.value.ctrol_aseo, tipo: 'integer' }
    ], '', null, SCHEMA)

    if (!contratoData || contratoData.length === 0) {
      hideLoading()
      Swal.fire({
        icon: 'warning',
        title: 'Contrato no encontrado',
        text: 'No existen CONTRATOS CON ESTOS DATOS o ESTA CANCELADO, intentalo de nuevo'
      })
      return
    }

    contrato.value = contratoData[0]

    // 3. Buscar adeudos vencidos
    const periodoPost = filtros.value.tipo_vigencia === '1'
      ? `${filtros.value.ejercicio_posterior}-${filtros.value.mes_posterior}`
      : null
    const incluirPost = filtros.value.tipo_vigencia === '1' ? 1 : 0

    const adeudosData = await execute('sp_aseo_adeudos_vencidos_contrato', BASE_DB, [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_dia_limite', valor: diaLimite.value, tipo: 'integer' },
      { nombre: 'p_periodo_posterior', valor: periodoPost, tipo: 'string' },
      { nombre: 'p_incluir_posteriores', valor: incluirPost, tipo: 'integer' }
    ], '', null, SCHEMA)

    if (!adeudosData || adeudosData.length === 0) {
      hideLoading()
      Swal.fire({
        icon: 'info',
        title: 'Sin adeudos',
        text: 'No existen ADEUDOS de este contrato, Intenta con otro'
      })
      return
    }

    // 4. Calcular recargos para cada adeudo
    for (const adeudo of adeudosData) {
      // Solo calcular recargos para periodos vencidos (A y C)
      if (adeudo.cam === 'A' || adeudo.cam === 'C') {
        try {
          const recargosData = await execute('sp_aseo_calcular_recargos', BASE_DB, [
            { nombre: 'p_aso_mes_pago', valor: adeudo.aso_mes_pago, tipo: 'string' },
            { nombre: 'p_importe', valor: adeudo.importe, tipo: 'numeric' },
            { nombre: 'p_ctrol_operacion', valor: adeudo.ctrol_operacion, tipo: 'integer' },
            { nombre: 'p_dia_limite', valor: diaLimite.value, tipo: 'integer' }
          ], '', null, SCHEMA)

          adeudo.recargos = recargosData || 0
        } catch {
          adeudo.recargos = 0
        }
      } else {
        adeudo.recargos = 0  // Periodos posteriores no tienen recargos
      }
      adeudo.total_periodo = parseFloat(adeudo.importe || 0) + parseFloat(adeudo.recargos || 0)
    }

    adeudos.value = adeudosData

    // 5. Buscar apremios/requerimientos
    const apremiosData = await execute('sp_aseo_buscar_apremios_contrato', BASE_DB, [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' }
    ], '', null, SCHEMA)

    if (apremiosData && apremiosData.length > 0) {
      apremios.value = apremiosData[0]
    }

    hideLoading()
    showToast(`${adeudos.value.length} adeudo(s) encontrado(s)`, 'success')

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  }
}

const limpiarFormulario = () => {
  buscado.value = false
  contrato.value = null
  adeudos.value = []
  apremios.value = null
  filtros.value.num_contrato = null
  filtros.value.tipo_vigencia = '0'
}

const imprimirReporte = () => {
  // Generar reporte para impresion
  const printContent = generarHTMLReporte()
  const printWindow = window.open('', '_blank')
  printWindow.document.write(printContent)
  printWindow.document.close()
  printWindow.print()
}

const generarHTMLReporte = () => {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Estado de Cuenta - Contrato ${contrato.value.num_contrato}</title>
      <style>
        body { font-family: Arial, sans-serif; font-size: 12px; margin: 20px; }
        h1 { text-align: center; font-size: 16px; }
        h2 { font-size: 14px; margin-top: 20px; border-bottom: 1px solid #000; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #ccc; padding: 5px; text-align: left; }
        th { background-color: #f0f0f0; }
        .text-end { text-align: right; }
        .text-center { text-align: center; }
        .fw-bold { font-weight: bold; }
        .total-row { background-color: #e0e0e0; font-weight: bold; }
        .info-section { margin: 10px 0; }
        .info-section td { border: none; padding: 2px 10px; }
      </style>
    </head>
    <body>
      <h1>ESTADO DE CUENTA - ASEO CONTRATADO</h1>
      <h2>Datos del Contrato</h2>
      <table class="info-section">
        <tr><td><strong>Contrato:</strong></td><td>${contrato.value.num_contrato}</td><td><strong>Tipo Aseo:</strong></td><td>${contrato.value.tipo_aseo} - ${contrato.value.desc_aseo}</td></tr>
        <tr><td><strong>Empresa:</strong></td><td>${contrato.value.nom_emp}</td><td><strong>Representante:</strong></td><td>${contrato.value.representante || 'N/A'}</td></tr>
        <tr><td><strong>Domicilio:</strong></td><td colspan="3">${contrato.value.domicilio}</td></tr>
        <tr><td><strong>Zona:</strong></td><td>${contrato.value.zona}-${contrato.value.sub_zona} ${contrato.value.nom_zona}</td><td><strong>Sector:</strong></td><td>${contrato.value.sector}</td></tr>
      </table>

      <h2>Detalle de Adeudos</h2>
      <table>
        <thead>
          <tr><th>Periodo</th><th>Operacion</th><th>Descripcion</th><th class="text-center">Cant</th><th class="text-end">Importe</th><th class="text-end">Recargos</th><th class="text-end">Total</th></tr>
        </thead>
        <tbody>
          ${adeudos.value.map(a => `
            <tr>
              <td>${a.aso_mes_pago}</td>
              <td>${a.ctrol_operacion}</td>
              <td>${a.descripcion}</td>
              <td class="text-center">${a.exedencias || contrato.value.cantidad_recolec}</td>
              <td class="text-end">$${formatCurrency(a.importe)}</td>
              <td class="text-end">$${formatCurrency(a.recargos)}</td>
              <td class="text-end">$${formatCurrency(a.total_periodo)}</td>
            </tr>
          `).join('')}
          <tr class="total-row">
            <td colspan="4" class="text-end">TOTAL PERIODOS:</td>
            <td class="text-end">$${formatCurrency(totales.value.total_importe)}</td>
            <td class="text-end">$${formatCurrency(totales.value.total_recargos)}</td>
            <td class="text-end">$${formatCurrency(totales.value.total_periodos)}</td>
          </tr>
        </tbody>
      </table>

      ${apremios.value && apremios.value.no_requerimientos > 0 ? `
        <h2>Requerimientos</h2>
        <table class="info-section">
          <tr><td><strong>No. Requerimientos:</strong></td><td>${apremios.value.no_requerimientos}</td></tr>
          <tr><td><strong>Folios:</strong></td><td>${apremios.value.folios_requerimientos}</td></tr>
          <tr><td><strong>Importe Multas:</strong></td><td>$${formatCurrency(apremios.value.total_multas)}</td></tr>
          <tr><td><strong>Importe Gastos:</strong></td><td>$${formatCurrency(apremios.value.total_gastos)}</td></tr>
          <tr><td><strong>Total Requerimientos:</strong></td><td>$${formatCurrency(totalRequerimientos.value)}</td></tr>
        </table>
      ` : ''}

      <h2>Total a Pagar</h2>
      <table>
        <tr><td>Total Periodos:</td><td class="text-end fw-bold">$${formatCurrency(totales.value.total_periodos)}</td></tr>
        <tr><td>Total Requerimientos:</td><td class="text-end fw-bold">$${formatCurrency(totalRequerimientos.value)}</td></tr>
        <tr class="total-row"><td>TOTAL A PAGAR:</td><td class="text-end">$${formatCurrency(totalPagar.value)}</td></tr>
      </table>

      <p style="margin-top: 30px; font-size: 10px;">Fecha de impresion: ${new Date().toLocaleString('es-MX')}</p>
    </body>
    </html>
  `
}

const getStatusClass = (status) => {
  const classes = {
    'V': 'bg-success',
    'C': 'bg-danger',
    'S': 'bg-warning',
    'N': 'bg-info'
  }
  return classes[status] || 'bg-secondary'
}

const getStatusLabel = (status) => {
  const labels = {
    'V': 'Vigente',
    'C': 'Cancelado',
    'S': 'Suspendido',
    'N': 'Conveniado'
  }
  return labels[status] || status
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

// Inicializacion
onMounted(async () => {
  await cargarTiposAseo()
})
</script>
