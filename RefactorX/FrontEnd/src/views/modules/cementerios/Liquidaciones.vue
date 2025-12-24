<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Liquidaciones de Cementerios</h1>
        <p>Cementerios - Cálculo de liquidaciones de cuotas de mantenimiento</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de Cálculo -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calculator" />
            Datos para Liquidación
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-three">
            <!-- Cementerio -->
            <div class="form-group">
              <label for="cementerio" class="form-label required">Cementerio</label>
              <select
                id="cementerio"
                v-model="formData.cementerio"
                class="municipal-form-control"
              >
                <option value="">Seleccione...</option>
                <option
                  v-for="cem in cementerios"
                  :key="cem.cementerio"
                  :value="cem.cementerio"
                >
                  {{ cem.nombre }}
                </option>
              </select>
            </div>

            <!-- Metros -->
            <div class="form-group">
              <label for="metros" class="form-label required">Metros</label>
              <input
                id="metros"
                v-model.number="formData.metros"
                type="number"
                step="0.01"
                min="0"
                class="municipal-form-control"
                placeholder="0.00"
              />
            </div>

            <!-- Checkbox Nuevo -->
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="checkbox-group">
                <label class="checkbox-label">
                  <input
                    v-model="formData.esNuevo"
                    type="checkbox"
                    @change="onNuevoChange"
                  />
                  <span>Nuevo (sin recargos)</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Tipo de Espacio -->
          <div class="form-group">
            <label class="form-label required">Tipo de Espacio</label>
            <div class="radio-group-horizontal">
              <label class="radio-label">
                <input
                  v-model="formData.tipoEspacio"
                  type="radio"
                  :value="1"
                />
                <span>Fosa</span>
              </label>
              <label class="radio-label">
                <input
                  v-model="formData.tipoEspacio"
                  type="radio"
                  :value="2"
                />
                <span>Urna</span>
              </label>
              <label class="radio-label">
                <input
                  v-model="formData.tipoEspacio"
                  type="radio"
                  :value="3"
                />
                <span>Gaveta</span>
              </label>
              <label class="radio-label">
                <input
                  v-model="formData.tipoEspacio"
                  type="radio"
                  :value="4"
                />
                <span>Otros</span>
              </label>
            </div>
          </div>

          <!-- Rango de Años -->
          <div class="form-grid-two">
            <div class="form-group">
              <label for="axoDesde" class="form-label required">Año Desde</label>
              <input
                id="axoDesde"
                v-model.number="formData.axoDesde"
                type="number"
                min="1990"
                :max="currentYear"
                class="municipal-form-control"
              />
            </div>

            <div class="form-group">
              <label for="axoHasta" class="form-label required">Año Hasta</label>
              <input
                id="axoHasta"
                v-model.number="formData.axoHasta"
                type="number"
                min="1990"
                :max="currentYear"
                class="municipal-form-control"
              />
            </div>
          </div>

          <!-- Botón Calcular -->
          <div class="form-actions">
            <button
              @click="calcularLiquidacion"
              class="btn-municipal-primary"
              :disabled="!formValid"
            >
              <font-awesome-icon icon="calculator" />
              Calcular Liquidación
            </button>
            <button
              @click="limpiarFormulario"
              class="btn-municipal-secondary"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="resultados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Detalle de Liquidación
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Tabla de Resultados -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th class="text-right">Mantenimiento</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="item in resultados"
                  :key="item.axo_cuota"
                  @click="selectedRow = item"
                  :class="{ 'table-row-selected': selectedRow === item }"
                  class="row-hover"
                >
                  <td>{{ item.axo_cuota }}</td>
                  <td class="text-right">{{ formatCurrency(item.manten) }}</td>
                  <td class="text-right">{{ formatCurrency(item.recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(item.total) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td><strong>TOTALES</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.manten) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.recargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.total) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Acciones -->
          <div class="form-actions mt-3">
            <button
              @click.stop="imprimirLiquidacion"
              class="btn-municipal-primary"
            >
              <font-awesome-icon icon="print" />
              Imprimir
            </button>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Liquidaciones'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Liquidaciones de Cementerios'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
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

// Documentación y Ayuda
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

// Estado
const cementerios = ref([])
const resultados = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
const currentYear = new Date().getFullYear()
const currentMonth = new Date().getMonth() + 1

// Formulario
const formData = ref({
  cementerio: '',
  tipoEspacio: 1,
  metros: null,
  axoDesde: currentYear - 6,
  axoHasta: currentYear,
  esNuevo: false
})

// Totales
const totales = ref({
  manten: 0,
  recargos: 0,
  total: 0
})

// Validación del formulario
const formValid = computed(() => {
  return (
    formData.value.cementerio &&
    formData.value.metros > 0 &&
    formData.value.axoDesde > 0 &&
    formData.value.axoHasta > 0 &&
    formData.value.axoDesde <= formData.value.axoHasta
  )
})

// Cargar cementerios
const cargarCementerios = async () => {
  try {
    // Usar SP: sp_get_cementerios_list
    // Base: cementerio.public (según 24_SP_CEMENTERIOS_LIQUIDACIONES_LISTAR_CEMENTERIOS.sql)
    const response = await execute(
      'sp_get_cementerios_list',
      'cementerio',
      [],
      '',
      null,
      'public'
    )

    /* TODO FUTURO: Query SQL original (comentado - ahora usa SP)
    SELECT cementerio, nombre, domicilio
    FROM cementerio.public.tc_13_cementerios
    ORDER BY cementerio
    */

    if (response && response.result) {
      cementerios.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
    showToast('error', 'Error al cargar la lista de cementerios')
  }
}

// Evento al cambiar checkbox "Nuevo"
const onNuevoChange = () => {
  if (formData.value.esNuevo) {
    // Si es nuevo, ajustar años al año actual
    formData.value.axoDesde = currentYear
    formData.value.axoHasta = currentYear
  } else {
    // Restaurar rango por defecto
    formData.value.axoDesde = currentYear - 6
    formData.value.axoHasta = currentYear
  }
}

// Calcular liquidación
const calcularLiquidacion = async () => {
  if (!formValid.value) {
    showToast('warning', 'Por favor complete todos los campos requeridos')
    return
  }

  showLoading('Calculando liquidación...', 'Procesando cuotas de mantenimiento')
  hasSearched.value = true
  selectedRow.value = null
  try {
    /* TODO FUTURO: Query SQL original Pascal (Liquidaciones.pas líneas 126-158)
    -- LÓGICA CRÍTICA: UNION de 2 queries diferentes según año 2008
    -- Query 1 (años < 2008): SELECT axo_cuota, TRUNC((cuota*metros),2) manten, recargos...
    --   FROM ta_13_rcmcuotas WHERE cementerio=cem AND axo_cuota>=desde AND axo_cuota<2008
    -- UNION ALL
    -- Query 2 (años >= 2008): SELECT axo_cuota, TRUNC((cuota*1),2) manten, recargos...
    --   FROM ta_13_rcmcuotas WHERE cementerio=cem AND axo_cuota BETWEEN 2008 AND hasta
    -- IMPORTANTE: Años < 2008 usan metros reales, años >= 2008 usan multiplicador 1
    */

    // Usar SP CORREGIDO: sp_liquidaciones_calcular
    // Archivo: 11_SP_CEMENTERIOS_LIQUIDACIONES_EXACTO_all_procedures_CORREGIDO.sql
    // Base: cementerio.public (según postgreok.csv)
    // NOTA: SP ahora implementa lógica EXACTA del Pascal con UNION de 2 queries

    // Mapear tipo de espacio a letra
    let tipoLetra = 'F'
    switch(formData.value.tipoEspacio) {
      case 1: tipoLetra = 'F'; break // Fosa
      case 2: tipoLetra = 'U'; break // Urna
      case 3: tipoLetra = 'G'; break // Gaveta
      case 4: tipoLetra = 'O'; break // Otros
    }

    const response = await execute(
      'sp_liquidaciones_calcular',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: formData.value.cementerio, tipo: 'string' },
        { nombre: 'p_anio_desde', valor: formData.value.axoDesde, tipo: 'integer' },
        { nombre: 'p_anio_hasta', valor: formData.value.axoHasta, tipo: 'integer' },
        { nombre: 'p_metros', valor: formData.value.metros, tipo: 'numeric' },
        { nombre: 'p_tipo', valor: tipoLetra, tipo: 'string' },
        { nombre: 'p_nuevo', valor: formData.value.esNuevo ? 1 : 0, tipo: 'integer' },
        { nombre: 'p_mes', valor: currentMonth, tipo: 'integer' }
      ],
      'function',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      // Agregar campo total a cada resultado
      resultados.value = response.result.map(item => ({
        ...item,
        total: parseFloat(item.manten || 0) + parseFloat(item.recargos || 0)
      }))
      calcularTotales()
      showToast('success', 'Liquidación calculada exitosamente')
    } else {
      showToast('warning', 'No se encontraron cuotas para el rango especificado')
      resultados.value = []
      resetTotales()
    }
  } catch (error) {
    console.error('Error al calcular liquidación:', error)
    showToast('error', 'Error al calcular la liquidación')
    resultados.value = []
    resetTotales()
  } finally {
    hideLoading()
  }
}

// Calcular totales
const calcularTotales = () => {
  totales.value = {
    manten: resultados.value.reduce((sum, item) => sum + item.manten, 0),
    recargos: resultados.value.reduce((sum, item) => sum + item.recargos, 0),
    total: resultados.value.reduce((sum, item) => sum + item.total, 0)
  }
}

// Reset totales
const resetTotales = () => {
  totales.value = { manten: 0, recargos: 0, total: 0 }
}

// Limpiar formulario
const limpiarFormulario = () => {
  formData.value = {
    cementerio: '',
    tipoEspacio: 1,
    metros: null,
    axoDesde: currentYear - 6,
    axoHasta: currentYear,
    esNuevo: false
  }
  resultados.value = []
  hasSearched.value = false
  selectedRow.value = null
  resetTotales()
}

// Imprimir liquidación
const imprimirLiquidacion = () => {
  if (resultados.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const cementerioSelec = cementerios.value.find(c => c.cementerio === formData.value.cementerio)
  const tipoEspacioLabel = ['', 'Fosa', 'Urna', 'Gaveta', 'Otros'][formData.value.tipoEspacio]

  const ventanaImpresion = window.open('', '_blank')

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <title>Liquidación de Cementerios</title>
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
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
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
        .text-right {
          text-align: right;
        }
        .totals-row {
          font-weight: bold;
          background-color: #f9f9f9;
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
        <h1>LIQUIDACIÓN DE CUOTAS DE MANTENIMIENTO</h1>
        <p>CEMENTERIOS MUNICIPALES</p>
      </div>

      <div class="info">
        <div class="info-row"><strong>Cementerio:</strong> ${cementerioSelec ? cementerioSelec.nombre : ''}</div>
        <div class="info-row"><strong>Tipo de Espacio:</strong> ${tipoEspacioLabel}</div>
        <div class="info-row"><strong>Metros:</strong> ${formData.value.metros}</div>
        <div class="info-row"><strong>Período:</strong> ${formData.value.axoDesde} - ${formData.value.axoHasta}</div>
        <div class="info-row"><strong>Nuevo (sin recargos):</strong> ${formData.value.esNuevo ? 'Sí' : 'No'}</div>
        <div class="info-row"><strong>Fecha:</strong> ${new Date().toLocaleDateString()}</div>
      </div>

      <table>
        <thead class="municipal-table-header">
          <tr>
            <th>Año</th>
            <th class="text-right">Mantenimiento</th>
            <th class="text-right">Recargos</th>
            <th class="text-right">Total</th>
          </tr>
        </thead>
        <tbody>
          ${resultados.value.map(item => `
            <tr>
              <td>${item.axo_cuota}</td>
              <td class="text-right">${formatCurrency(item.manten)}</td>
              <td class="text-right">${formatCurrency(item.recargos)}</td>
              <td class="text-right">${formatCurrency(item.total)}</td>
            </tr>
          `).join('')}
        </tbody>
        <tfoot>
          <tr class="totals-row">
            <td>TOTALES</td>
            <td class="text-right">${formatCurrency(totales.value.manten)}</td>
            <td class="text-right">${formatCurrency(totales.value.recargos)}</td>
            <td class="text-right">${formatCurrency(totales.value.total)}</td>
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

// Formatear moneda
const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value)
}

// Inicialización
onMounted(() => {
  cargarCementerios()
})
</script>
