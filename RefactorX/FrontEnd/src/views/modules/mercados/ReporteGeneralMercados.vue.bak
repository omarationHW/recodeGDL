<template>
  <div class="module-view">
    <!-- HEADER -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte General de Mercados</h1>
        <p>Mercados - Estad�sticas y reportes generales del sistema</p>
      </div>
      <button class="btn-help-icon" @click="mostrarAyuda" type="button">
        <font-awesome-icon icon="question-circle" /> Ayuda
      </button>
    </div>

    <!-- ACCIONES -->
    <div class="municipal-card">
      <div >
        <div class="form-row">
          <button
            type="button"
            class="btn-municipal-primary"
            @click="cargarDatos"
            :disabled="cargando"
          >
            <font-awesome-icon icon="sync-alt" /> Actualizar Datos
          </button>

          <button
            type="button"
            class="btn-municipal-success"
            @click="exportarExcel"
            :disabled="cargando"
          >
            <font-awesome-icon icon="file-excel" /> Exportar Todo
          </button>

          <button
            type="button"
            class="btn-municipal-secondary"
            @click="imprimir"
            :disabled="cargando"
          >
            <font-awesome-icon icon="print" /> Imprimir
          </button>
        </div>
      </div>
    </div>

    <!-- ESTAD�STICAS GENERALES -->
    <div v-if="estadisticasGenerales" class="municipal-card">
      <div class="municipal-card-header">
        <h5><font-awesome-icon icon="chart-pie" /> Estad�sticas Generales del Sistema</h5>
      </div>

      <div class="stats-dashboard">
        <div class="stat-item stat-primary">
          <div class="stat-value">{{ estadisticasGenerales.total_recaudadoras }}</div>
          <div class="stat-label">Recaudadoras</div>
          <div class="stat-sublabel">Activas</div>
        </div>

        <div class="stat-item stat-info">
          <div class="stat-value">{{ estadisticasGenerales.total_mercados }}</div>
          <div class="stat-label">Mercados</div>
          <div class="stat-sublabel">Registrados</div>
        </div>

        <div class="stat-item stat-success">
          <div class="stat-value">{{ estadisticasGenerales.locales_vigentes }}</div>
          <div class="stat-label">Locales Vigentes</div>
          <div class="stat-sublabel">{{ estadisticasGenerales.total_locales }} totales</div>
        </div>

        <div class="stat-item stat-warning">
          <div class="stat-value">{{ estadisticasGenerales.servicios_energia }}</div>
          <div class="stat-label">Servicios Energ�a</div>
          <div class="stat-sublabel">Registrados</div>
        </div>

        <div class="stat-item stat-danger">
          <div class="stat-value">{{ formatArea(estadisticasGenerales.area_total_metros) }}</div>
          <div class="stat-label">�rea Total</div>
          <div class="stat-sublabel">Metros cuadrados</div>
        </div>

        <div class="stat-item stat-secondary">
          <div class="stat-value">{{ estadisticasGenerales.total_giros }}</div>
          <div class="stat-label">Giros</div>
          <div class="stat-sublabel">{{ estadisticasGenerales.total_zonas }} zonas</div>
        </div>
      </div>
    </div>

    <!-- TABS PARA REPORTES DETALLADOS -->
    <div class="municipal-card">
      <div class="module-view">
        <div class="tabs-header">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            :class="['tab-button', { 'active': tabActivo === tab.id }]"
            @click="tabActivo = tab.id"
            type="button"
          >
            <font-awesome-icon :icon="tab.icon" /> {{ tab.label }}
          </button>
        </div>

        <div class="tabs-content">
          <!-- TAB: Por Recaudadora -->
          <div v-if="tabActivo === 'recaudadora'" class="tab-panel">
            <h3 class="panel-title">Reporte por Recaudadora</h3>
            <div class="municipal-table">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Oficina</th>
                    <th>Recaudadora</th>
                    <th class="text-center">Mercados</th>
                    <th class="text-center">Locales</th>
                    <th class="text-center">Vigentes</th>
                    <th class="text-center">Energ�a</th>
                    <th class="text-end">�rea Total (m�)</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in reportePorRecaudadora" :key="item.oficina">
                    <td>{{ item.oficina }}</td>
                    <td>{{ item.recaudadora }}</td>
                    <td class="text-center">{{ item.total_mercados }}</td>
                    <td class="text-center">{{ item.total_locales }}</td>
                    <td class="text-center">{{ item.locales_vigentes }}</td>
                    <td class="text-center">{{ item.servicios_energia }}</td>
                    <td class="text-end">{{ formatArea(item.area_total) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
        </div>

          <!-- TAB: Por Zona -->
          <div v-if="tabActivo === 'zona'" class="tab-panel">
            <h3 class="panel-title">Reporte por Zona Geogr�fica</h3>
            <div class="municipal-table">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>ID Zona</th>
                    <th>Descripci�n</th>
                    <th class="text-center">Mercados</th>
                    <th class="text-center">Locales</th>
                    <th class="text-end">�rea Total (m�)</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="item in reportePorZona" :key="item.id_zona">
                    <td>{{ item.id_zona }}</td>
                    <td>{{ item.descripcion }}</td>
                    <td class="text-center">{{ item.total_mercados }}</td>
                    <td class="text-center">{{ item.total_locales }}</td>
                    <td class="text-end">{{ formatArea(item.area_total) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const cargando = ref(false)
const tabActivo = ref('recaudadora')
const estadisticasGenerales = ref(null)
const reportePorRecaudadora = ref([])
const reportePorZona = ref([])

// Tabs
const tabs = [
  { id: 'recaudadora', label: 'Por Recaudadora', icon: 'building' },
  { id: 'zona', label: 'Por Zona', icon: 'map-marked-alt' }
]

// Cargar datos al montar
onMounted(() => {
  cargarDatos()
})

// Cargar datos
async function cargarDatos() {
  try {
    cargando.value = true

    // Cargar estad�sticas generales
    const responseGeneral = await execute('SP_MERCADOS_ESTADISTICAS_GENERALES', 'mercados', {})
    if (responseGeneral && responseGeneral.length > 0) {
      estadisticasGenerales.value = responseGeneral[0]
    }

    // Cargar reporte por recaudadora
    const responseRecaudadora = await execute('SP_MERCADOS_REPORTE_POR_RECAUDADORA', 'mercados', {})
    reportePorRecaudadora.value = responseRecaudadora || []

    // Cargar reporte por zona
    const responseZona = await execute('SP_MERCADOS_REPORTE_POR_ZONA', 'mercados', {})
    reportePorZona.value = responseZona || []

    showToast('Datos cargados correctamente', 'success')

  } catch (error) {
    handleError(error)
  } finally {
    cargando.value = false
  }
}

// Formatear �rea
function formatArea(valor) {
  if (!valor && valor !== 0) return '0.00'
  return parseFloat(valor).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

// Exportar a Excel
function exportarExcel() {
  try {
    const wb = XLSX.utils.book_new()

    // Hoja 1: Estad�sticas Generales
    if (estadisticasGenerales.value) {
      const datosGenerales = [
        ['ESTAD�STICAS GENERALES DEL SISTEMA DE MERCADOS'],
        [''],
        ['Concepto', 'Valor'],
        ['Total Recaudadoras', estadisticasGenerales.value.total_recaudadoras],
        ['Total Mercados', estadisticasGenerales.value.total_mercados],
        ['Total Locales', estadisticasGenerales.value.total_locales],
        ['Locales Vigentes', estadisticasGenerales.value.locales_vigentes],
        ['Locales de Baja', estadisticasGenerales.value.locales_baja],
        ['Total Secciones', estadisticasGenerales.value.total_secciones],
        ['Total Giros', estadisticasGenerales.value.total_giros],
        ['Total Zonas', estadisticasGenerales.value.total_zonas],
        ['Servicios de Energ�a', estadisticasGenerales.value.servicios_energia],
        ['�rea Total (m�)', estadisticasGenerales.value.area_total_metros]
      ]
      const wsGeneral = XLSX.utils.aoa_to_sheet(datosGenerales)
      XLSX.utils.book_append_sheet(wb, wsGeneral, 'Estad�sticas Generales')
    }

    // Hoja 2: Por Recaudadora
    if (reportePorRecaudadora.value.length > 0) {
      const datosRecaudadora = reportePorRecaudadora.value.map(item => ({
        'Oficina': item.oficina,
        'Recaudadora': item.recaudadora,
        'Mercados': item.total_mercados,
        'Locales': item.total_locales,
        'Vigentes': item.locales_vigentes,
        'Servicios Energ�a': item.servicios_energia,
        '�rea Total (m�)': item.area_total
      }))
      const wsRecaudadora = XLSX.utils.json_to_sheet(datosRecaudadora)
      XLSX.utils.book_append_sheet(wb, wsRecaudadora, 'Por Recaudadora')
    }

    // Hoja 3: Por Zona
    if (reportePorZona.value.length > 0) {
      const datosZona = reportePorZona.value.map(item => ({
        'ID Zona': item.id_zona,
        'Descripci�n': item.descripcion,
        'Mercados': item.total_mercados,
        'Locales': item.total_locales,
        '�rea Total (m�)': item.area_total
      }))
      const wsZona = XLSX.utils.json_to_sheet(datosZona)
      XLSX.utils.book_append_sheet(wb, wsZona, 'Por Zona')
    }

    const nombreArchivo = `Reporte_General_Mercados_${new Date().toISOString().split('T')[0]}.xlsx`
    XLSX.writeFile(wb, nombreArchivo)
    showToast('Archivo Excel generado correctamente', 'success')
  } catch (error) {
    handleError(error)
  }
}

// Imprimir
function imprimir() {
  window.print()
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Reporte General de Mercados',
    html: `
      <div class="help-content" style="text-align: left;">
        <h3>Descripci�n</h3>
        <p>Este m�dulo presenta estad�sticas generales y reportes consolidados del sistema de mercados.</p>

        <h3>Estad�sticas Generales</h3>
        <p>Muestra indicadores clave del sistema:</p>
        <ul>
          <li><strong>Recaudadoras:</strong> Total de oficinas activas</li>
          <li><strong>Mercados:</strong> Total de mercados registrados</li>
          <li><strong>Locales Vigentes:</strong> Locales activos del total</li>
          <li><strong>Servicios Energ�a:</strong> Servicios de energ�a el�ctrica registrados</li>
          <li><strong>�rea Total:</strong> Suma de las �reas de todos los locales vigentes</li>
          <li><strong>Giros y Zonas:</strong> Cat�logos activos</li>
        </ul>

        <h3>Reporte por Recaudadora</h3>
        <p>Informaci�n detallada de cada oficina recaudadora:</p>
        <ul>
          <li>Cantidad de mercados administrados</li>
          <li>Total de locales bajo su responsabilidad</li>
          <li>Locales vigentes vs totales</li>
          <li>Servicios de energ�a registrados</li>
          <li>�rea total ocupada</li>
        </ul>

        <h3>Reporte por Zona Geogr�fica</h3>
        <p>Distribuci�n de mercados y locales por zona:</p>
        <ul>
          <li>Mercados por zona</li>
          <li>Locales por zona</li>
          <li>�rea total por zona</li>
        </ul>

        <h3>Funcionalidades</h3>
        <ul>
          <li><strong>Actualizar Datos:</strong> Recarga todas las estad�sticas</li>
          <li><strong>Exportar Todo:</strong> Genera archivo Excel con todas las hojas</li>
          <li><strong>Imprimir:</strong> Imprime el reporte completo</li>
        </ul>

        <h3>Uso del Reporte</h3>
        <ul>
          <li>Toma de decisiones administrativas</li>
          <li>Planificaci�n y asignaci�n de recursos</li>
          <li>An�lisis de distribuci�n geogr�fica</li>
          <li>Identificaci�n de �reas de oportunidad</li>
          <li>Informes para autoridades</li>
        </ul>

        <h3>Notas Importantes</h3>
        <ul>
          <li>Los datos se actualizan en tiempo real desde la base de datos</li>
          <li>El archivo Excel contiene m�ltiples hojas con informaci�n detallada</li>
          <li>Las estad�sticas reflejan solo elementos vigentes/activos</li>
        </ul>
      </div>
    `,
    icon: 'info',
    width: 800,
    confirmButtonText: 'Entendido'
  })
}
</script>


