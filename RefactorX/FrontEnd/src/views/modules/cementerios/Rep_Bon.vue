<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percentage" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Oficios de Bonificación</h1>
        <p>Cementerios - Reporte de bonificaciones por recaudadora</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Filtros - LÓGICA PASCAL: Rep_Bon.pas líneas 127-163 -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="filter" />
        Parámetros del Reporte
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <!-- Recaudadora: Parámetro principal según Pascal -->
          <div class="form-group">
            <label class="form-label required">Recaudadora (1-9)</label>
            <input
              v-model.number="filtros.recaudadora"
              type="number"
              class="municipal-form-control"
              min="1"
              max="9"
              placeholder="Ingrese número de recaudadora"
            />
          </div>
          <!-- Tipo de Reporte: RadioButtons del Pascal (sRadioButton1, sRadioButton2) -->
          <div class="form-group">
            <label class="form-label required">Tipo de Reporte</label>
            <div class="radio-group">
              <label class="radio-option">
                <input type="radio" v-model="filtros.tipo" value="pendientes" />
                <span>Pendientes (con importe resto > 0)</span>
              </label>
              <label class="radio-option">
                <input type="radio" v-model="filtros.tipo" value="todos" />
                <span>Todos los Oficios</span>
              </label>
            </div>
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
        Información de Recaudadora
      </div>
      <div class="municipal-card-body">
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Recaudadora:</span>
            <span class="info-value">{{ infoRecaudadora.recing }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Nombre:</span>
            <span class="info-value">{{ infoRecaudadora.nomre }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">Título:</span>
            <span class="info-value">{{ infoRecaudadora.titulo }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados - Tabla según campos del Pascal dfm -->
    <div v-if="bonificaciones.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        {{ tituloReporte }} ({{ bonificaciones.length }} registros)
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Control Bon</th>
                <th>Oficio</th>
                <th>Año</th>
                <th>Folio</th>
                <th>Cementerio</th>
                <th>Ubicación</th>
                <th>Fecha Oficio</th>
                <th>Imp. Bonificar</th>
                <th>Imp. Bonificado</th>
                <th>Imp. Resto</th>
                <th>Usuario</th>
                <th>Fecha Mov</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="bon in bonificaciones" :key="bon.control_bon">
                <td>{{ bon.control_bon }}</td>
                <td>{{ bon.oficio }}</td>
                <td>{{ bon.axo }}</td>
                <td>{{ bon.control_rcm }}</td>
                <td>{{ bon.cementerio }}</td>
                <td>{{ formatearUbicacion(bon) }}</td>
                <td>{{ formatearFecha(bon.fecha_ofic) }}</td>
                <td class="text-end">${{ formatearMoneda(bon.importe_bonificar) }}</td>
                <td class="text-end">${{ formatearMoneda(bon.importe_bonificado) }}</td>
                <td class="text-end" :class="{ 'text-danger fw-bold': parseFloat(bon.importe_resto) > 0 }">
                  ${{ formatearMoneda(bon.importe_resto) }}
                </td>
                <td>{{ bon.nombre || bon.usuario }}</td>
                <td>{{ formatearFecha(bon.fecha_mov) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="totals-row">
                <td colspan="7"><strong>TOTALES:</strong></td>
                <td class="text-end"><strong>${{ formatearMoneda(totalBonificar) }}</strong></td>
                <td class="text-end"><strong>${{ formatearMoneda(totalBonificado) }}</strong></td>
                <td class="text-end"><strong>${{ formatearMoneda(totalResto) }}</strong></td>
                <td colspan="2"></td>
              </tr>
            </tfoot>
          </table>
        </div>

        <!-- Acciones -->
        <div class="form-actions mt-3">
          <button
            @click="imprimirReporte"
            class="btn-municipal-primary"
          >
            <font-awesome-icon icon="print" />
            Imprimir
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No existen Registros para la recaudadora especificada
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
      :componentName="'Rep_Bon'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
/*
 * RECODIFICACIÓN EXACTA DEL PASCAL: Rep_Bon.pas
 *
 * LÓGICA ORIGINAL (líneas 127-163):
 * - Filtro por RECAUDADORA (1-9) - campo 'doble' en ta_13_bonifrcm
 * - RadioButton1: Pendientes (importe_resto > 0)
 * - RadioButton2: Todos los oficios
 * - Query: SELECT a.*, (SELECT nombre FROM ta_12_passwords WHERE id_usuario=a.usuario) nombre
 *          FROM ta_13_bonifrcm a WHERE doble=:rec AND importe_resto>0 (o sin filtro importe)
 *
 * Tabla: ta_13_bonifrcm (cementerio.public)
 * Tabla auxiliar: ta_12_nombrerec (para info recaudadora)
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
  recaudadora: null, // Número de recaudadora 1-9 (campo doble)
  tipo: 'pendientes' // 'pendientes' o 'todos' (RadioButtons Pascal)
})

const bonificaciones = ref([])
const infoRecaudadora = ref(null)
const busquedaRealizada = ref(false)

// Título dinámico según Pascal ppDetailBand1BeforePrint
const tituloReporte = computed(() => {
  if (!infoRecaudadora.value) return 'Reporte de Oficios de Bonificación'
  return `REPORTE DE OFICIOS DE BONIFICACION DE LA RECAUDADORA ${infoRecaudadora.value.recing}`
})

// Totales calculados
const totalBonificar = computed(() =>
  bonificaciones.value.reduce((sum, b) => sum + parseFloat(b.importe_bonificar || 0), 0)
)
const totalBonificado = computed(() =>
  bonificaciones.value.reduce((sum, b) => sum + parseFloat(b.importe_bonificado || 0), 0)
)
const totalResto = computed(() =>
  bonificaciones.value.reduce((sum, b) => sum + parseFloat(b.importe_resto || 0), 0)
)

// Generar reporte - LÓGICA PASCAL FlatButton1Click líneas 127-163
const generarReporte = async () => {
  // Validación según Pascal: if (StrToInt(recaudadora.Text)>0) and (StrToInt(recaudadora.Text)<=9)
  if (!filtros.recaudadora || filtros.recaudadora < 1 || filtros.recaudadora > 9) {
    showToast('warning', 'Error en la Recaudadora. Debe ser un número entre 1 y 9')
    return
  }

  try {
    showLoading()

    // Primero obtener info de la recaudadora (Qryrec del Pascal)
    await cargarInfoRecaudadora()

    // Llamar SP con parámetros según lógica Pascal
    const params = [
      { nombre: 'p_recaudadora', valor: filtros.recaudadora, tipo: 'integer' },
      { nombre: 'p_tipo', valor: filtros.tipo, tipo: 'varchar' }
    ]

    const response = await execute(
      'sp_rep_bon_listar',
      'cementerio',
      params,
      '',
      null,
      'public'
    )

    if(response?.result?.length >0)
  {
    bonificaciones.value = response.result || []
    busquedaRealizada.value = true
  }
    
    // Mensaje según Pascal: if QryFolio.RecordCount>0 then... else ShowMessage('No existen Registros')
    if (bonificaciones.value.length > 0) {
      showToast('success', `Se encontraron ${bonificaciones.value.length} registro(s)`)
    } else {
      showToast('info', 'No existen Registros')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    showToast('error', 'Error al generar reporte')
  } finally {
    hideLoading()
  }
}

// Cargar info recaudadora - Qryrec del Pascal
const cargarInfoRecaudadora = async () => {
  try {
    const params = [
      { nombre: 'p_rec', valor: filtros.recaudadora, tipo: 'smallint' }
    ]

    const response = await execute(
      'sp_rep_bon_info_recaudadora',
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
    // No es crítico, continuamos sin la info
  }
}

// Formatear ubicación según campos del Pascal dfm
const formatearUbicacion = (bon) => {
  const partes = []
  if (bon.clase) partes.push(`Cl:${bon.clase}${bon.clase_alfa || ''}`)
  if (bon.seccion) partes.push(`Sec:${bon.seccion}${bon.seccion_alfa || ''}`)
  if (bon.linea) partes.push(`Lin:${bon.linea}${bon.linea_alfa || ''}`)
  if (bon.fosa) partes.push(`Fosa:${bon.fosa}${bon.fosa_alfa || ''}`)
  return partes.join(' ')
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  return new Date(fecha).toLocaleDateString('es-MX')
}

const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

// Imprimir reporte
const imprimirReporte = () => {
  if (bonificaciones.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const ventanaImpresion = window.open('', '_blank')

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Reporte de Oficios de Bonificación</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          font-size: 11px;
        }
        .header {
          text-align: center;
          margin-bottom: 20px;
        }
        .header h1 {
          margin: 0;
          font-size: 16px;
        }
        .header p {
          margin: 5px 0;
          font-size: 13px;
        }
        .info {
          margin: 20px 0;
          padding: 10px;
          background-color: #f5f5f5;
          border: 1px solid #ddd;
        }
        .info-row {
          margin: 5px 0;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
        }
        th, td {
          border: 1px solid #000;
          padding: 6px;
          text-align: left;
        }
        th {
          background-color: #f0f0f0;
          font-weight: bold;
          font-size: 10px;
        }
        .text-end {
          text-align: right;
        }
        .text-center {
          text-align: center;
        }
        .totals-row {
          font-weight: bold;
          background-color: #f9f9f9;
        }
        .text-danger {
          color: #dc3545;
        }
        @media print {
          button {
            display: none;
          }
          body {
            margin: 10px;
          }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>REPORTE DE OFICIOS DE BONIFICACIÓN</h1>
        <p>${tituloReporte.value}</p>
      </div>

      <div class="info">
        <div class="info-row"><strong>Recaudadora:</strong> ${infoRecaudadora.value?.recing || filtros.recaudadora}</div>
        <div class="info-row"><strong>Nombre:</strong> ${infoRecaudadora.value?.nomre || 'N/A'}</div>
        <div class="info-row"><strong>Título:</strong> ${infoRecaudadora.value?.titulo || 'N/A'}</div>
        <div class="info-row"><strong>Tipo de Reporte:</strong> ${filtros.tipo === 'pendientes' ? 'Pendientes (con importe resto > 0)' : 'Todos los Oficios'}</div>
        <div class="info-row"><strong>Total de Registros:</strong> ${bonificaciones.value.length}</div>
        <div class="info-row"><strong>Fecha de Impresión:</strong> ${new Date().toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' })}</div>
      </div>

      <table>
        <thead>
          <tr>
            <th>Control Bon</th>
            <th>Oficio</th>
            <th>Año</th>
            <th>Folio</th>
            <th>Cem</th>
            <th>Ubicación</th>
            <th>Fecha Oficio</th>
            <th class="text-end">Imp. Bonificar</th>
            <th class="text-end">Imp. Bonificado</th>
            <th class="text-end">Imp. Resto</th>
            <th>Usuario</th>
            <th>Fecha Mov</th>
          </tr>
        </thead>
        <tbody>
          ${bonificaciones.value.map(bon => `
            <tr>
              <td class="text-center">${bon.control_bon}</td>
              <td>${bon.oficio || ''}</td>
              <td class="text-center">${bon.axo || ''}</td>
              <td class="text-center">${bon.control_rcm || ''}</td>
              <td class="text-center">${bon.cementerio || ''}</td>
              <td>${formatearUbicacion(bon)}</td>
              <td class="text-center">${formatearFecha(bon.fecha_ofic)}</td>
              <td class="text-end">$${formatearMoneda(bon.importe_bonificar)}</td>
              <td class="text-end">$${formatearMoneda(bon.importe_bonificado)}</td>
              <td class="text-end ${parseFloat(bon.importe_resto) > 0 ? 'text-danger' : ''}">$${formatearMoneda(bon.importe_resto)}</td>
              <td>${bon.nombre || bon.usuario || ''}</td>
              <td class="text-center">${formatearFecha(bon.fecha_mov)}</td>
            </tr>
          `).join('')}
        </tbody>
        <tfoot>
          <tr class="totals-row">
            <td colspan="7" class="text-end"><strong>TOTALES:</strong></td>
            <td class="text-end"><strong>$${formatearMoneda(totalBonificar.value)}</strong></td>
            <td class="text-end"><strong>$${formatearMoneda(totalBonificado.value)}</strong></td>
            <td class="text-end"><strong>$${formatearMoneda(totalResto.value)}</strong></td>
            <td colspan="2"></td>
          </tr>
        </tfoot>
      </table>

      <${'script'}>
        window.onload = function() {
          window.print();
        };
      </${'script'}>
    </body>
    </html>
  `

  ventanaImpresion.document.write(html)
  ventanaImpresion.document.close()
}

onMounted(() => {
  // Valor por defecto según Pascal: recaudadora vacía hasta que el usuario ingrese
})
</script>
