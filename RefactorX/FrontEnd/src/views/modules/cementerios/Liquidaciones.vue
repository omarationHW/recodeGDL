<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-title-section">
        <font-awesome-icon icon="file-invoice-dollar module-icon" />
        <div>
          <h1 class="module-view-info">Liquidaciones de Cementerios</h1>
          <p class="module-subtitle">Cálculo de liquidaciones de cuotas de mantenimiento</p>
        </div>
      </div>
      <div class="module-actions">
        <button @click="showHelp = true" class="btn-icon" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
        </button>
      </div>
    </div>

    <div class="module-content">
      <!-- Formulario de Cálculo -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <font-awesome-icon icon="calculator" />
          Datos para Liquidación
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
          <font-awesome-icon icon="list" />
          Detalle de Liquidación
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
                <tr v-for="item in resultados" :key="item.axo_cuota">
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
              @click="imprimirLiquidacion"
              class="btn-municipal-primary"
            >
              <font-awesome-icon icon="print" />
              Imprimir
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="showHelp"
      title="Liquidaciones de Cementerios"
      @close="showHelp = false"
    >
      <div class="help-content">
        <h3>Descripción</h3>
        <p>
          Este módulo permite calcular liquidaciones de cuotas de mantenimiento para espacios
          en cementerios municipales.
        </p>

        <h3>Instrucciones de Uso</h3>
        <ol>
          <li>Seleccione el cementerio</li>
          <li>Ingrese los metros cuadrados del espacio</li>
          <li>Seleccione el tipo de espacio (Fosa, Urna, Gaveta u Otros)</li>
          <li>Indique el rango de años para la liquidación</li>
          <li>Si es un espacio nuevo, marque la casilla "Nuevo" (no aplicará recargos)</li>
          <li>Haga clic en "Calcular Liquidación"</li>
          <li>Revise el detalle año por año y los totales calculados</li>
          <li>Use el botón "Imprimir" para generar el reporte</li>
        </ol>

        <h3>Notas Importantes</h3>
        <ul>
          <li>Para años anteriores a 2008, el cálculo usa el multiplicador de metros</li>
          <li>A partir de 2008, se usa un multiplicador estándar de 1</li>
          <li>Los recargos se calculan según el porcentaje vigente del mes actual</li>
          <li>Si marca "Nuevo", no se aplicarán recargos y los años se ajustarán al año actual</li>
        </ul>

        <h3>Campos Requeridos</h3>
        <ul>
          <li><strong>Cementerio:</strong> Cementerio municipal</li>
          <li><strong>Metros:</strong> Metros cuadrados del espacio</li>
          <li><strong>Tipo de Espacio:</strong> Fosa, Urna, Gaveta u Otros</li>
          <li><strong>Año Desde/Hasta:</strong> Rango de años para el cálculo</li>
        </ul>
      </div>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Liquidaciones'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showSuccess, showError, showWarning } = useToast()

// Estado
const showHelp = ref(false)
const cementerios = ref([])
const resultados = ref([])
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
    const response = await execute(
      'sp_cem_listar_cementerios',
      'cementerios',
      {},
      '',
      null,
      'comun'
    )

    if (response && response.result) {
      cementerios.value = response.result
    }
  } catch (error) {
    showError('Error al cargar la lista de cementerios')
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
    showWarning('Por favor complete todos los campos requeridos')
    return
  }

  try {
    const response = await execute(
      'sp_cem_calcular_liquidacion',
      'cementerios',
      {
        p_cementerio: formData.value.cementerio,
        p_tipo_espacio: formData.value.tipoEspacio,
        p_metros: formData.value.metros,
        p_axo_desde: formData.value.axoDesde,
        p_axo_hasta: formData.value.axoHasta,
        p_es_nuevo: formData.value.esNuevo ? 1 : 0,
        p_mes_actual: currentMonth
      },
      '',
      null,
      'comun'
    )

    if (response && response.resultado === 'S' && response.result && response.result.length > 0) {
      resultados.value = response.result
      calcularTotales()
      showSuccess('Liquidación calculada exitosamente')
    } else if (response && response.resultado === 'E') {
      showError(response.mensaje || 'No se encontraron cuotas para el rango especificado')
      resultados.value = []
      resetTotales()
    } else {
      showWarning('No se encontraron datos para los parámetros especificados')
      resultados.value = []
      resetTotales()
    }
  } catch (error) {
    showError('Error al calcular la liquidación')
    resultados.value = []
    resetTotales()
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
  resetTotales()
}

// Imprimir liquidación
const imprimirLiquidacion = () => {
  if (resultados.value.length === 0) {
    showWarning('No hay datos para imprimir')
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

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
