<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Cementerios a Cobrar</h1>
        <p>Cementerios - Reporte de recargos por mes</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Filtros - LÓGICA PASCAL: Rep_a_Cobrar.pas líneas 111-119 -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Parámetros del Reporte
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <!-- Mes: Parámetro principal según Pascal (FlatComboBox1) -->
          <div class="form-group">
            <label class="form-label required">Mes</label>
            <select v-model.number="filtros.mes" class="municipal-form-control">
              <option v-for="m in meses" :key="m.valor" :value="m.valor">
                {{ m.nombre }}
              </option>
            </select>
          </div>
          <!-- Info adicional del año actual -->
          <div class="form-group">
            <label class="form-label">Año Actual</label>
            <input
              :value="anioActual"
              type="text"
              class="municipal-form-control"
              readonly
              disabled
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click="generarReporte" class="btn-municipal-primary">
            <font-awesome-icon icon="file-pdf" />
            Generar Reporte
          </button>
        </div>
      </div>
    </div>

    <!-- Info Recaudadora -->
    <div v-if="infoRecaudadora" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="building" />
        Información de Zona
      </div>
      <div class="municipal-card-body">
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Zona:</span>
            <span class="info-value">{{ infoRecaudadora.d_zona }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Recaudadora:</span>
            <span class="info-value">{{ infoRecaudadora.recaudadora }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados - Tabla según Pascal: agrupado por metraje con mantenimiento y recargos -->
    <div v-if="registros.length > 0" class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          {{ tituloReporte }}
        </h5>
        <div class="header-right">
          <span class="badge-purple">
            {{ formatNumber(totalRecords) }} registros
          </span>
        </div>
      </div>
      <div class="municipal-card-body table-container">
        <!-- Tabla agrupada por metraje según Pascal -->
        <div v-for="(grupo, idx) in registrosAgrupadosPaginados" :key="idx" class="mb-4">
          <h5 class="text-primary fw-bold mb-2">{{ grupo.metros }} MTS. 1 ERA. CLASE</h5>
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Años</th>
                  <th class="text-end">Mantenimiento</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="reg in grupo.registros" :key="reg.ano">
                  <td>{{ reg.ano }}-{{ anioActual }}</td>
                  <td class="text-end">${{ formatearMoneda(reg.mantenimiento) }}</td>
                  <td class="text-end">${{ formatearMoneda(reg.recargos) }}</td>
                  <td class="text-end fw-bold">${{ formatearMoneda(parseFloat(reg.mantenimiento) + parseFloat(reg.recargos)) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Controles de Paginación -->
        <div v-if="registros.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="itemsPerPage"
              @change="changePageSize($event.target.value)"
              style="width: auto; display: inline-block;"
            >
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(1)"
              :disabled="currentPage === 1"
              title="Primera página"
            >
              <font-awesome-icon icon="angle-double-left" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1"
              title="Página anterior"
            >
              <font-awesome-icon icon="angle-left" />
            </button>

            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages"
              title="Página siguiente"
            >
              <font-awesome-icon icon="angle-right" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(totalPages)"
              :disabled="currentPage === totalPages"
              title="Última página"
            >
              <font-awesome-icon icon="angle-double-right" />
            </button>
          </div>
        </div>

        <!-- Resumen Total -->
        <div class="summary-grid mt-3">
          <div class="summary-card">
            <span class="summary-label">Total Mantenimiento:</span>
            <span class="summary-value">${{ formatearMoneda(totalMantenimiento) }}</span>
          </div>
          <div class="summary-card">
            <span class="summary-label">Total Recargos:</span>
            <span class="summary-value">${{ formatearMoneda(totalRecargos) }}</span>
          </div>
          <div class="summary-card">
            <span class="summary-label">Gran Total:</span>
            <span class="summary-value text-primary fw-bold">${{ formatearMoneda(totalMantenimiento + totalRecargos) }}</span>
          </div>
        </div>

        <!-- Acciones -->
        <div class="form-actions mt-3" style="position: relative; z-index: 1000;">
          <button
            @click="imprimirReporte"
            class="btn-municipal-primary"
            style="position: relative; z-index: 1001; pointer-events: auto; cursor: pointer;"
            type="button"
          >
            <font-awesome-icon icon="print" />
            Imprimir
          </button>
         
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No hay datos para el mes especificado
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Rep_a_Cobrar'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
/*
 * RECODIFICACIÓN EXACTA DEL PASCAL: Rep_a_Cobrar.pas
 *
 * LÓGICA ORIGINAL (líneas 103-147):
 * - FormShow: Carga info recaudadora del usuario (QryREC con id_rec del usuario)
 * - FlatButton1Click: Ejecuta StoredProc1 (spd_13_liquidacion) con par_mes
 * - ppGroupHeaderBand1BeforePrint: Muestra "X MTS. 1 ERA. CLASE" agrupando por metraje
 * - ppReport1BeforePrint: Título "Recargos del mes de [MES]-[AÑO]"
 *
 * StoredProc: spd_13_liquidacion(par_mes)
 * Retorna: expression (metros), expression_1 (año), expression_2 (mantenimiento), expression_3 (recargos)
 *
 * Tablas: ta_13_rcmcuotas, ta_13_datosrcm, ta_12_recaudadoras, ta_13_recargosrcm
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado del formulario - SEGÚN PASCAL
const filtros = reactive({
  mes: new Date().getMonth() + 1 // Mes actual por defecto (1-12)
})

const registros = ref([])
const infoRecaudadora = ref(null)
const busquedaRealizada = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Año actual según Pascal DecodeDate(date,taxo,tmes,tdia)
const anioActual = new Date().getFullYear()

// Lista de meses para el ComboBox (FlatComboBox1 del Pascal)
const meses = [
  { valor: 1, nombre: 'Enero' },
  { valor: 2, nombre: 'Febrero' },
  { valor: 3, nombre: 'Marzo' },
  { valor: 4, nombre: 'Abril' },
  { valor: 5, nombre: 'Mayo' },
  { valor: 6, nombre: 'Junio' },
  { valor: 7, nombre: 'Julio' },
  { valor: 8, nombre: 'Agosto' },
  { valor: 9, nombre: 'Septiembre' },
  { valor: 10, nombre: 'Octubre' },
  { valor: 11, nombre: 'Noviembre' },
  { valor: 12, nombre: 'Diciembre' }
]

// Título según Pascal ppReport1BeforePrint
const tituloReporte = computed(() => {
  const mesNombre = meses.find(m => m.valor === filtros.mes)?.nombre || ''
  return `RECARGOS DEL MES DE ${mesNombre.toUpperCase()}-${anioActual}`
})

// Agrupar registros por metros (como en Pascal ppGroupHeaderBand1BeforePrint)
const registrosAgrupados = computed(() => {
  const grupos = {}
  registros.value.forEach(reg => {
    const metros = reg.metros || reg.expression || 0
    if (!grupos[metros]) {
      grupos[metros] = { metros, registros: [] }
    }
    grupos[metros].registros.push(reg)
  })
  return Object.values(grupos).sort((a, b) => a.metros - b.metros)
})

// Totales calculados
const totalMantenimiento = computed(() =>
  registros.value.reduce((sum, r) => sum + parseFloat(r.mantenimiento || r.expression_2 || 0), 0)
)
const totalRecargos = computed(() =>
  registros.value.reduce((sum, r) => sum + parseFloat(r.recargos || r.expression_3 || 0), 0)
)

// Paginación - Computed
const totalRecords = computed(() => registros.value.length)

const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedRegistros = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return registros.value.slice(start, end)
})

const registrosAgrupadosPaginados = computed(() => {
  const grupos = {}
  paginatedRegistros.value.forEach(reg => {
    const metros = reg.metros || reg.expression || 0
    if (!grupos[metros]) {
      grupos[metros] = { metros, registros: [] }
    }
    grupos[metros].registros.push(reg)
  })
  return Object.values(grupos).sort((a, b) => a.metros - b.metros)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Generar reporte - LÓGICA PASCAL FlatButton1Click líneas 111-119
const generarReporte = async () => {
  if (!filtros.mes || filtros.mes < 1 || filtros.mes > 12) {
    showToast('warning', 'Debe seleccionar un mes válido')
    return
  }

  try {
    showLoading()

    // Primero cargar info de recaudadora (FormShow del Pascal)
    await cargarInfoRecaudadora()

    // Llamar SP con parámetro mes según lógica Pascal
    // Pascal usa: StoredProc1.ParamByName('par_mes').AsSmallInt:=StrToInt(FlatComboBox1.Text)
    const params = [
      { nombre: 'par_mes', valor: filtros.mes, tipo: 'integer' },
      { nombre: 'par_id_rec', valor: infoRecaudadora.value?.id_rec || 1, tipo: 'integer' }
    ]

    const response = await execute(
      'sp_rep_a_cobrar',
      'cementerio',
      params,
      'padron_licencias',
      null,
      'public'
    )
    if(response?.result?.length >0)
    {
      registros.value = response.result || []
      busquedaRealizada.value = true
      currentPage.value = 1 // Reset paginación al cargar nuevos datos
    }

    // Según Pascal: if StoredProc1.RecordCount>0 then ppReport1.Print
    if (registros.value.length > 0) {
      showToast('success', `Se encontraron ${registros.value.length} registro(s)`)
    } else {
      showToast('info', 'No hay datos para el mes especificado')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    showToast('error', 'Error al generar reporte')
  } finally {
    hideLoading()
  }
}

// Cargar info recaudadora - FormShow del Pascal
// Query: SELECT a.*,b.*,upper(c.zona) d_zona FROM TA_12_nombrerec a,ta_12_recaudadoras b,ta_12_zonas c
//        WHERE a.RECing=:REC and a.recing=b.id_rec and b.id_zona=c.id_zona
const cargarInfoRecaudadora = async () => {
  try {
    // Por ahora usamos id_rec=1 como default, en producción debería venir del usuario logueado
    const params = [
      { nombre: 'p_id_rec', valor: 1, tipo: 'smallint' }
    ]

    const response = await execute(
      'sp_rep_a_cobrar_info_recaudadora',
      'cementerio',
      params,
      '',
      null,
      'public'
    )

    if (response && response.length > 0) {
      infoRecaudadora.value = response[0]
    }
  } catch (error) {
    console.error('Error al cargar info recaudadora:', error)
    // Usar valores por defecto
    infoRecaudadora.value = { id_rec: 1, d_zona: 'ZONA CENTRO' }
  }
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

// Imprimir reporte
const imprimirReporte = () => {
  console.log('imprimirReporte llamada, registros:', registros.value.length)

  if (registros.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const mesNombre = meses.find(m => m.valor === filtros.mes)?.nombre || ''

  console.log('Abriendo ventana de impresión...')
  const ventanaImpresion = window.open('', '_blank')

  if (!ventanaImpresion) {
    showToast('error', 'No se pudo abrir la ventana de impresión. Verifique que no esté bloqueando ventanas emergentes.')
    return
  }

  // Función helper para formatear moneda en el HTML
  const formatearMonedaHTML = (valor) => {
    if (!valor) return '0.00'
    return parseFloat(valor).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Reporte de Cementerios a Cobrar</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          font-size: 12px;
        }
        .header {
          text-align: center;
          margin-bottom: 20px;
        }
        .header h1 {
          margin: 0;
          font-size: 18px;
        }
        .header p {
          margin: 5px 0;
          font-size: 14px;
        }
        .info {
          margin: 20px 0;
        }
        .info-row {
          margin: 5px 0;
        }
        .grupo-metros {
          margin: 30px 0;
        }
        .grupo-titulo {
          font-size: 14px;
          font-weight: bold;
          color: #1e3a8a;
          margin-bottom: 10px;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 10px 0;
        }
        th, td {
          border: 1px solid #000;
          padding: 8px;
          text-align: left;
        }
        th {
          background-color: #f0f0f0;
          font-weight: bold;
        }
        .text-end {
          text-align: right;
        }
        .totals-section {
          margin-top: 30px;
          border-top: 2px solid #000;
          padding-top: 15px;
        }
        .totals-row {
          display: flex;
          justify-content: space-between;
          margin: 5px 0;
          font-size: 14px;
        }
        .totals-label {
          font-weight: bold;
        }
        .totals-value {
          font-weight: bold;
        }
        .gran-total {
          font-size: 16px;
          color: #1e3a8a;
        }
        @media print {
          button {
            display: none;
          }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>REPORTE DE CEMENTERIOS A COBRAR</h1>
        <p>${tituloReporte.value}</p>
      </div>

      <div class="info">
        <div class="info-row"><strong>Zona:</strong> ${infoRecaudadora.value?.d_zona || 'N/A'}</div>
        <div class="info-row"><strong>Recaudadora:</strong> ${infoRecaudadora.value?.recaudadora || 'N/A'}</div>
        <div class="info-row"><strong>Mes:</strong> ${mesNombre}</div>
        <div class="info-row"><strong>Año:</strong> ${anioActual}</div>
        <div class="info-row"><strong>Fecha de Impresión:</strong> ${new Date().toLocaleDateString()}</div>
      </div>

      ${registrosAgrupados.value.map(grupo => `
        <div class="grupo-metros">
          <div class="grupo-titulo">${grupo.metros} MTS. 1 ERA. CLASE</div>
          <table>
            <thead>
              <tr>
                <th>Años</th>
                <th class="text-end">Mantenimiento</th>
                <th class="text-end">Recargos</th>
                <th class="text-end">Total</th>
              </tr>
            </thead>
            <tbody>
              ${grupo.registros.map(reg => `
                <tr>
                  <td>${reg.ano || reg.expression_1}-${anioActual}</td>
                  <td class="text-end">$${formatearMonedaHTML(reg.mantenimiento || reg.expression_2)}</td>
                  <td class="text-end">$${formatearMonedaHTML(reg.recargos || reg.expression_3)}</td>
                  <td class="text-end">$${formatearMonedaHTML(parseFloat(reg.mantenimiento || reg.expression_2 || 0) + parseFloat(reg.recargos || reg.expression_3 || 0))}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `).join('')}

      <div class="totals-section">
        <div class="totals-row">
          <span class="totals-label">Total Mantenimiento:</span>
          <span class="totals-value">$${formatearMonedaHTML(totalMantenimiento.value)}</span>
        </div>
        <div class="totals-row">
          <span class="totals-label">Total Recargos:</span>
          <span class="totals-value">$${formatearMonedaHTML(totalRecargos.value)}</span>
        </div>
        <div class="totals-row gran-total">
          <span class="totals-label">GRAN TOTAL:</span>
          <span class="totals-value">$${formatearMonedaHTML(totalMantenimiento.value + totalRecargos.value)}</span>
        </div>
      </div>

      <${'script'}>
        window.onload = function() {
          window.print();
        };
      </${'script'}>
    </body>
    </html>
  `

  console.log('Escribiendo HTML en ventana de impresión...')
  ventanaImpresion.document.write(html)
  ventanaImpresion.document.close()
  console.log('Impresión completada')
}

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

onMounted(() => {
  // FormShow del Pascal: cargar info recaudadora al iniciar
  cargarInfoRecaudadora()
})
</script>
