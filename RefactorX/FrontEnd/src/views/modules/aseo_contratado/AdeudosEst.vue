<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Estatus de Adeudos</h1>
        <p>Aseo Contratado - Análisis estadístico del estado de adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Parámetros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio Fiscal</label>
              <input
                type="number"
                v-model.number="filtros.ejercicio"
                class="municipal-form-control"
                :placeholder="new Date().getFullYear().toString()"
                min="2000"
                :max="new Date().getFullYear() + 1"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="filtros.tipo_aseo" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="C">Comercial</option>
                <option value="R">Residencial</option>
                <option value="I">Industrial</option>
                <option value="M">Mixto</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Status Contrato</label>
              <select v-model="filtros.status_contrato" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="N">Activos</option>
                <option value="B">Inactivos</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Agrupar Por</label>
              <select v-model="filtros.agrupar_por" class="municipal-form-control">
                <option value="tipo_aseo">Tipo de Aseo</option>
                <option value="empresa">Empresa</option>
                <option value="zona">Zona</option>
                <option value="mes">Mes</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mostrar</label>
              <select v-model="filtros.mostrar" class="municipal-form-control">
                <option value="todos">Todos los Contratos</option>
                <option value="con_adeudos">Solo con Adeudos</option>
                <option value="sin_adeudos">Solo sin Adeudos</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="consultarEstatus" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'chart-bar'" :spin="loading" /> Consultar Estatus
            </button>
            <button class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button v-if="consultaRealizada" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Exportar Excel
            </button>
          </div>
        </div>
      </div>

      <div v-if="consultaRealizada" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-pie" /> Resumen General</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="file-contract" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Contratos</p>
                <p class="summary-value">{{ resumenGeneral.total_contratos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-success"><font-awesome-icon icon="check-circle" /></div>
              <div class="summary-info">
                <p class="summary-label">Contratos al Corriente</p>
                <p class="summary-value">{{ resumenGeneral.contratos_al_corriente }}</p>
              </div>
            </div>
            <div class="summary-card highlight-danger">
              <div class="summary-icon bg-danger"><font-awesome-icon icon="exclamation-triangle" /></div>
              <div class="summary-info">
                <p class="summary-label">Contratos con Adeudos</p>
                <p class="summary-value">{{ resumenGeneral.contratos_con_adeudos }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="calendar-xmark" /></div>
              <div class="summary-info">
                <p class="summary-label">Total Periodos Adeudados</p>
                <p class="summary-value">{{ resumenGeneral.total_periodos_adeudados }}</p>
              </div>
            </div>
            <div class="summary-card highlight-money">
              <div class="summary-icon bg-info"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="summary-info">
                <p class="summary-label">Monto Total Adeudado</p>
                <p class="summary-value">{{ formatCurrency(resumenGeneral.monto_total_adeudado) }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-secondary"><font-awesome-icon icon="percent" /></div>
              <div class="summary-info">
                <p class="summary-label">% Morosidad</p>
                <p class="summary-value">{{ resumenGeneral.porcentaje_morosidad }}%</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="consultaRealizada && datosAgrupados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Estadísticas por {{ getLabelAgrupacion() }}</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>{{ getLabelAgrupacion() }}</th>
                  <th class="text-center">Total Contratos</th>
                  <th class="text-center">Con Adeudos</th>
                  <th class="text-center">Al Corriente</th>
                  <th class="text-center">Periodos Adeudados</th>
                  <th class="text-right">Monto Adeudado</th>
                  <th class="text-center">% Morosidad</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="grupo in datosAgrupados" :key="grupo.grupo">
                  <td><strong>{{ grupo.grupo }}</strong></td>
                  <td class="text-center">{{ grupo.total_contratos }}</td>
                  <td class="text-center">
                    <span class="badge badge-danger">{{ grupo.con_adeudos }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-success">{{ grupo.al_corriente }}</span>
                  </td>
                  <td class="text-center">{{ grupo.periodos_adeudados }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(grupo.monto_adeudado) }}</strong></td>
                  <td class="text-center">
                    <span class="badge" :class="getMorosidadClass(grupo.porcentaje_morosidad)">
                      {{ grupo.porcentaje_morosidad }}%
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td><strong>TOTALES:</strong></td>
                  <td class="text-center"><strong>{{ resumenGeneral.total_contratos }}</strong></td>
                  <td class="text-center"><strong>{{ resumenGeneral.contratos_con_adeudos }}</strong></td>
                  <td class="text-center"><strong>{{ resumenGeneral.contratos_al_corriente }}</strong></td>
                  <td class="text-center"><strong>{{ resumenGeneral.total_periodos_adeudados }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(resumenGeneral.monto_total_adeudado) }}</strong></td>
                  <td class="text-center"><strong>{{ resumenGeneral.porcentaje_morosidad }}%</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-if="consultaRealizada && detalleContratos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Detalle de Contratos ({{ detalleContratos.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Tipo Aseo</th>
                  <th class="text-center">Status</th>
                  <th class="text-center">Periodos Adeudados</th>
                  <th class="text-right">Monto Adeudado</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="contrato in detalleContratos" :key="contrato.num_contrato">
                  <td><strong>{{ contrato.num_contrato }}</strong></td>
                  <td>{{ contrato.empresa }}</td>
                  <td>
                    <span class="badge" :class="getTipoAseoClass(contrato.tipo_aseo)">
                      {{ formatTipoAseo(contrato.tipo_aseo) }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="contrato.status_contrato === 'N' ? 'badge-success' : 'badge-danger'">
                      {{ contrato.status_contrato === 'N' ? 'ACTIVO' : 'INACTIVO' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span v-if="contrato.periodos_adeudados > 0" class="badge badge-warning">
                      {{ contrato.periodos_adeudados }}
                    </span>
                    <span v-else class="badge badge-success">0</span>
                  </td>
                  <td class="text-right">
                    <strong :class="contrato.monto_adeudado > 0 ? 'text-danger' : 'text-success'">
                      {{ formatCurrency(contrato.monto_adeudado) }}
                    </strong>
                  </td>
                  <td class="text-center">
                    <button class="btn-action btn-info" @click="verDetalle(contrato)" title="Ver Detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Consulta de Estatus">
      <h3>Consulta de Estatus de Adeudos</h3>
      <p>Esta herramienta permite analizar el estado de los adeudos de manera estadística y agrupada.</p>

      <h4>Parámetros de Consulta:</h4>
      <ul>
        <li><strong>Ejercicio Fiscal:</strong> Año a consultar (por defecto el año actual)</li>
        <li><strong>Tipo de Aseo:</strong> Filtrar por tipo específico o todos</li>
        <li><strong>Status Contrato:</strong> Solo activos, inactivos o todos</li>
        <li><strong>Agrupar Por:</strong> Organizar resultados por tipo de aseo, empresa, zona o mes</li>
        <li><strong>Mostrar:</strong> Todos los contratos, solo con adeudos o solo al corriente</li>
      </ul>

      <h4>Información Mostrada:</h4>
      <ul>
        <li><strong>Resumen General:</strong> Totales globales de contratos, adeudos y morosidad</li>
        <li><strong>Estadísticas Agrupadas:</strong> Desglose según la agrupación seleccionada</li>
        <li><strong>Detalle de Contratos:</strong> Lista completa con datos individuales</li>
      </ul>

      <h4>Indicadores:</h4>
      <ul>
        <li><strong>% Morosidad:</strong> Porcentaje de contratos con adeudos sobre el total</li>
        <li><strong>Verde:</strong> Morosidad menor a 20%</li>
        <li><strong>Amarillo:</strong> Morosidad entre 20% y 50%</li>
        <li><strong>Rojo:</strong> Morosidad mayor a 50%</li>
      </ul>

      <h4>Exportación:</h4>
      <p>Los resultados pueden exportarse a Excel para análisis adicional.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const consultaRealizada = ref(false)
const detalleContratos = ref([])

const filtros = ref({
  ejercicio: new Date().getFullYear(),
  tipo_aseo: '',
  status_contrato: '',
  agrupar_por: 'tipo_aseo',
  mostrar: 'todos'
})

const resumenGeneral = computed(() => {
  const total = detalleContratos.value.length
  const con_adeudos = detalleContratos.value.filter(c => c.periodos_adeudados > 0).length
  const al_corriente = total - con_adeudos
  const total_periodos = detalleContratos.value.reduce((sum, c) => sum + parseInt(c.periodos_adeudados || 0), 0)
  const monto_total = detalleContratos.value.reduce((sum, c) => sum + parseFloat(c.monto_adeudado || 0), 0)
  const porcentaje = total > 0 ? ((con_adeudos / total) * 100).toFixed(1) : 0

  return {
    total_contratos: total,
    contratos_con_adeudos: con_adeudos,
    contratos_al_corriente: al_corriente,
    total_periodos_adeudados: total_periodos,
    monto_total_adeudado: monto_total,
    porcentaje_morosidad: porcentaje
  }
})

const datosAgrupados = computed(() => {
  const grupos = {}

  detalleContratos.value.forEach(contrato => {
    let clave = ''

    switch (filtros.value.agrupar_por) {
      case 'tipo_aseo':
        clave = formatTipoAseo(contrato.tipo_aseo)
        break
      case 'empresa':
        clave = contrato.empresa
        break
      case 'zona':
        clave = contrato.zona || 'Sin Zona'
        break
      case 'mes':
        clave = contrato.mes_adeudo || 'N/A'
        break
      default:
        clave = 'Sin Clasificar'
    }

    if (!grupos[clave]) {
      grupos[clave] = {
        grupo: clave,
        total_contratos: 0,
        con_adeudos: 0,
        al_corriente: 0,
        periodos_adeudados: 0,
        monto_adeudado: 0
      }
    }

    grupos[clave].total_contratos++
    if (contrato.periodos_adeudados > 0) {
      grupos[clave].con_adeudos++
    } else {
      grupos[clave].al_corriente++
    }
    grupos[clave].periodos_adeudados += parseInt(contrato.periodos_adeudados || 0)
    grupos[clave].monto_adeudado += parseFloat(contrato.monto_adeudado || 0)
  })

  // Calcular porcentaje de morosidad por grupo
  return Object.values(grupos).map(g => ({
    ...g,
    porcentaje_morosidad: g.total_contratos > 0 ? ((g.con_adeudos / g.total_contratos) * 100).toFixed(1) : 0
  }))
})

const consultarEstatus = async () => {
  loading.value = true
  try {
    // 1. Obtener todos los contratos según filtros
    const parVigencia = filtros.value.status_contrato === 'N' ? 'V' :
                        filtros.value.status_contrato === 'B' ? 'B' : 'T'

    const responseContratos = await execute('sp16_contratos', 'aseo_contratado', {
      parTipo: filtros.value.tipo_aseo || 'T',
      parVigencia: parVigencia
    })

    let contratos = responseContratos && responseContratos.data ? responseContratos.data : []

    // 2. Para cada contrato, obtener sus adeudos
    const detallePromises = contratos.map(async (contrato) => {
      try {
        const responseAdeudos = await execute('SP_ASEO_ADEUDOS_ESTADO_CUENTA', 'aseo_contratado', {
          p_control_contrato: contrato.control_contrato,
          p_status_vigencia: 'D',
          p_fecha_hasta: null
        })

        const adeudos = responseAdeudos && responseAdeudos.data ? responseAdeudos.data : []

        // Filtrar por ejercicio si está especificado
        const adeudosFiltrados = filtros.value.ejercicio ?
          adeudos.filter(a => a.periodo && a.periodo.startsWith(filtros.value.ejercicio.toString())) :
          adeudos

        return {
          ...contrato,
          periodos_adeudados: adeudosFiltrados.length,
          monto_adeudado: adeudosFiltrados.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
        }
      } catch (error) {
        return {
          ...contrato,
          periodos_adeudados: 0,
          monto_adeudado: 0
        }
      }
    })

    let resultado = await Promise.all(detallePromises)

    // 3. Aplicar filtro de mostrar
    if (filtros.value.mostrar === 'con_adeudos') {
      resultado = resultado.filter(c => c.periodos_adeudados > 0)
    } else if (filtros.value.mostrar === 'sin_adeudos') {
      resultado = resultado.filter(c => c.periodos_adeudados === 0)
    }

    detalleContratos.value = resultado
    consultaRealizada.value = true
    showToast(`Consulta realizada: ${resultado.length} contratos procesados`, 'success')
  } catch (error) {
    showToast('Error al consultar estatus', 'error')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const limpiar = () => {
  filtros.value = {
    ejercicio: new Date().getFullYear(),
    tipo_aseo: '',
    status_contrato: '',
    agrupar_por: 'tipo_aseo',
    mostrar: 'todos'
  }
  detalleContratos.value = []
  consultaRealizada.value = false
}

const verDetalle = (contrato) => {
  showToast(`Detalle del contrato ${contrato.num_contrato} - Funcionalidad en desarrollo`, 'info')
}

const exportarExcel = () => {
  showToast('Exportación a Excel en desarrollo', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatTipoAseo = (tipo) => {
  const tipos = {
    'C': 'COMERCIAL',
    'R': 'RESIDENCIAL',
    'I': 'INDUSTRIAL',
    'M': 'MIXTO'
  }
  return tipos[tipo] || tipo
}

const getTipoAseoClass = (tipo) => {
  const classes = {
    'C': 'badge-primary',
    'R': 'badge-success',
    'I': 'badge-warning',
    'M': 'badge-info'
  }
  return classes[tipo] || 'badge-secondary'
}

const getMorosidadClass = (porcentaje) => {
  const p = parseFloat(porcentaje)
  if (p < 20) return 'badge-success'
  if (p < 50) return 'badge-warning'
  return 'badge-danger'
}

const getLabelAgrupacion = () => {
  const labels = {
    'tipo_aseo': 'Tipo de Aseo',
    'empresa': 'Empresa',
    'zona': 'Zona',
    'mes': 'Mes'
  }
  return labels[filtros.value.agrupar_por] || 'Grupo'
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

