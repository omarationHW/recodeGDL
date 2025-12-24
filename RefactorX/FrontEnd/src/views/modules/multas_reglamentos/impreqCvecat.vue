<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Impresión Req por Cvecat</h1>
        <p>Generar requerimiento por clave catastral</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Datos de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave Catastral</label>
              <input
                class="municipal-form-control"
                v-model="filters.cvecat"
                placeholder="Ej: 123456789012345"
                @keyup.enter="imprimir"
              />
              <small class="form-text">Ingrese la clave catastral del predio</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cvecat"
              @click="imprimir"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'print'" :spin="loading"/>
              {{ loading ? 'Procesando...' : 'Generar Requerimiento' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado -->
      <div class="municipal-card" v-if="result">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-pdf"/> Resultado</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Error genérico -->
          <div v-if="result.error" class="alert-danger">
            <font-awesome-icon icon="times-circle"/>
            <strong>Error:</strong> {{ result.error }}
          </div>

          <!-- Resultado del SP -->
          <div v-else-if="Array.isArray(result) && result.length > 0">
            <!-- Error de validación del SP -->
            <div v-if="result[0].status === 'error'" class="alert-danger">
              <font-awesome-icon icon="times-circle"/>
              <strong>{{ result[0].mensaje }}</strong>
            </div>
            <!-- Éxito -->
            <div v-else class="alert-success">
              <font-awesome-icon icon="check-circle"/>
              <strong>{{ result[0].mensaje || 'Requerimiento generado exitosamente' }}</strong>

              <!-- Botones de reporte -->
              <div class="report-actions">
                <button class="btn-report btn-preview" @click="verReporte">
                  <font-awesome-icon icon="eye" />
                  <span>Ver Reporte</span>
                </button>
                <button class="btn-report btn-download" @click="descargarReporte">
                  <font-awesome-icon icon="download" />
                  <span>Descargar Reporte</span>
                </button>
              </div>

              <!-- Detalles del Requerimiento -->
              <div class="result-details" v-if="result[0].folio_requerimiento">
                <h6><font-awesome-icon icon="file-alt"/> Información del Requerimiento</h6>

                <div class="detail-grid">
                  <div class="detail-item">
                    <span class="detail-label">Folio:</span>
                    <span class="detail-value">{{ result[0].folio_requerimiento }}</span>
                  </div>

                  <div class="detail-item">
                    <span class="detail-label">Clave Catastral:</span>
                    <span class="detail-value">{{ result[0].clave_catastral || filters.cvecat }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].fecha_generacion">
                    <span class="detail-label">Fecha de Generación:</span>
                    <span class="detail-value">{{ formatDate(result[0].fecha_generacion) }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].ejercicio">
                    <span class="detail-label">Ejercicio:</span>
                    <span class="detail-value">{{ result[0].ejercicio }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].tipo_requerimiento">
                    <span class="detail-label">Tipo:</span>
                    <span class="detail-value">{{ result[0].tipo_requerimiento }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].periodo">
                    <span class="detail-label">Periodo:</span>
                    <span class="detail-value">{{ result[0].periodo }}</span>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].propietario">
                  <h6><font-awesome-icon icon="user"/> Información del Contribuyente</h6>
                  <div class="detail-grid">
                    <div class="detail-item">
                      <span class="detail-label">Propietario:</span>
                      <span class="detail-value">{{ result[0].propietario }}</span>
                    </div>

                    <div class="detail-item" v-if="result[0].direccion">
                      <span class="detail-label">Dirección:</span>
                      <span class="detail-value">{{ result[0].direccion }}</span>
                    </div>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].monto_adeudo !== null && result[0].monto_adeudo !== undefined">
                  <h6><font-awesome-icon icon="dollar-sign"/> Monto a Pagar</h6>
                  <div class="monto-destacado">
                    {{ formatCurrency(result[0].monto_adeudo) }}
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].observaciones">
                  <h6><font-awesome-icon icon="info-circle"/> Observaciones</h6>
                  <p class="observaciones-text">{{ result[0].observaciones }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Resultado genérico -->
          <div v-else class="result-box">
            <pre>{{ JSON.stringify(result, null, 2) }}</pre>
          </div>
        </div>
      </div>
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'impreqCvecat'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Impresión Req por Cvecat'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'impreqCvecat'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Impresión Req por Cvecat'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfGenerator } from '@/composables/usePdfGenerator'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_IMPREQCVECAT'
const SCHEMA = 'publico'

const filters = ref({ cvecat: '' })
const result = ref(null)

async function imprimir() {
  const params = [
    { nombre: 'p_clave_catastral', tipo: 'string', valor: String(filters.value.cvecat || '') }
  ]
  try {
    const response = await execute(OP, BASE_DB, params, '', null, SCHEMA)
    if (response?.result) {
      result.value = response.result
    } else {
      result.value = response
    }
  } catch (e) {
    result.value = { error: e?.message || 'Error desconocido' }
  }
}

function formatCurrency(value) {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr + 'T00:00:00') // Evitar problemas de zona horaria
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

function verReporte() {
  console.log('📄 Generando vista previa del reporte')
  try {
    if (!result.value || !Array.isArray(result.value) || result.value.length === 0) {
      console.error('No hay datos para generar el reporte')
      return
    }

    const datos = result.value[0]
    const titulo = 'Requerimiento por Clave Catastral'
    const subtitulo = `Folio: ${datos.folio_requerimiento || 'N/A'}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave Catastral',
        valor: datos.clave_catastral || filters.value.cvecat || 'N/A'
      },
      {
        concepto: 'Folio Requerimiento',
        valor: datos.folio_requerimiento || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Ejercicio',
        valor: datos.ejercicio || 'N/A'
      },
      {
        concepto: 'Tipo',
        valor: datos.tipo_requerimiento || 'N/A'
      },
      {
        concepto: 'Periodo',
        valor: datos.periodo || 'N/A'
      },
      {
        concepto: 'Propietario',
        valor: datos.propietario || 'N/A'
      },
      {
        concepto: 'Dirección',
        valor: datos.direccion || 'N/A'
      },
      {
        concepto: 'Monto Adeudo',
        valor: formatCurrency(datos.monto_adeudo || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: datos.ejercicio || new Date().getFullYear(),
      columnas: [
        { key: 'concepto', header: 'Concepto', type: 'text' },
        { key: 'valor', header: 'Valor', type: 'text' }
      ]
    }

    verReporteTabular(datosReporte, opciones)
    console.log('✅ Vista previa generada exitosamente')
  } catch (e) {
    console.error('❌ Error al generar vista previa:', e)
  }
}

function descargarReporte() {
  console.log('⬇️ Descargando reporte PDF')
  try {
    if (!result.value || !Array.isArray(result.value) || result.value.length === 0) {
      console.error('No hay datos para descargar el reporte')
      return
    }

    const datos = result.value[0]
    const titulo = 'Requerimiento por Clave Catastral'
    const subtitulo = `Folio: ${datos.folio_requerimiento || 'N/A'}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave Catastral',
        valor: datos.clave_catastral || filters.value.cvecat || 'N/A'
      },
      {
        concepto: 'Folio Requerimiento',
        valor: datos.folio_requerimiento || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Ejercicio',
        valor: datos.ejercicio || 'N/A'
      },
      {
        concepto: 'Tipo',
        valor: datos.tipo_requerimiento || 'N/A'
      },
      {
        concepto: 'Periodo',
        valor: datos.periodo || 'N/A'
      },
      {
        concepto: 'Propietario',
        valor: datos.propietario || 'N/A'
      },
      {
        concepto: 'Dirección',
        valor: datos.direccion || 'N/A'
      },
      {
        concepto: 'Monto Adeudo',
        valor: formatCurrency(datos.monto_adeudo || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: datos.ejercicio || new Date().getFullYear(),
      columnas: [
        { key: 'concepto', header: 'Concepto', type: 'text' },
        { key: 'valor', header: 'Valor', type: 'text' }
      ]
    }

    descargarReporteTabular(datosReporte, opciones)
    const nombreArchivo = `requerimiento_${datos.clave_catastral || filters.value.cvecat}_${datos.folio_requerimiento || 'NA'}.pdf`
    console.log(`✅ Reporte descargado exitosamente: ${nombreArchivo}`)
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
  }
}
</script>

