<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Impresión Nueva</h1>
        <p>Generación de impresión de documentos</p>
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
          <h5>Datos de Impresión</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave de Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="imprimir"
              />
              <small class="form-text">Ingrese la clave de cuenta para generar la impresión</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta"
              @click="imprimir"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'print'" :spin="loading"/>
              {{ loading ? 'Procesando...' : 'Generar Impresión' }}
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
              <strong>{{ result[0].mensaje || 'Impresión generada exitosamente' }}</strong>

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

              <!-- Detalles de la Impresión -->
              <div class="result-details" v-if="result[0].folio_impresion">
                <h6><font-awesome-icon icon="file-pdf"/> Información de la Impresión</h6>

                <div class="detail-grid">
                  <div class="detail-item">
                    <span class="detail-label">Folio:</span>
                    <span class="detail-value">{{ result[0].folio_impresion }}</span>
                  </div>

                  <div class="detail-item">
                    <span class="detail-label">Clave de Cuenta:</span>
                    <span class="detail-value">{{ result[0].clave_cuenta || filters.cuenta }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].fecha_generacion">
                    <span class="detail-label">Fecha de Generación:</span>
                    <span class="detail-value">{{ formatDate(result[0].fecha_generacion) }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].tipo_documento">
                    <span class="detail-label">Tipo de Documento:</span>
                    <span class="detail-value">{{ result[0].tipo_documento }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].numero_paginas">
                    <span class="detail-label">Número de Páginas:</span>
                    <span class="detail-value">{{ result[0].numero_paginas }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].formato">
                    <span class="detail-label">Formato:</span>
                    <span class="detail-value">{{ result[0].formato }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].estado">
                    <span class="detail-label">Estado:</span>
                    <span class="detail-value">
                      <span class="badge-success">{{ result[0].estado }}</span>
                    </span>
                  </div>

                  <div class="detail-item" v-if="result[0].periodo">
                    <span class="detail-label">Periodo:</span>
                    <span class="detail-value">{{ result[0].periodo }}</span>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].contribuyente">
                  <h6><font-awesome-icon icon="user"/> Información del Contribuyente</h6>
                  <div class="detail-grid">
                    <div class="detail-item">
                      <span class="detail-label">Contribuyente:</span>
                      <span class="detail-value">{{ result[0].contribuyente }}</span>
                    </div>

                    <div class="detail-item" v-if="result[0].monto_total !== null && result[0].monto_total !== undefined">
                      <span class="detail-label">Monto Total:</span>
                      <span class="detail-value">{{ formatCurrency(result[0].monto_total) }}</span>
                    </div>
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
      :component-name="'ImpresionNva'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Impresión Nueva'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'ImpresionNva'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Impresión Nueva'"
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
const OP = 'RECAUDADORA_IMPRESIONNVA'
const SCHEMA = 'publico'

const filters = ref({ cuenta: '' })
const result = ref(null)

async function imprimir() {
  const params = [
    {
      nombre: 'p_datos',
      tipo: 'string',
      valor: JSON.stringify({
        clave_cuenta: filters.value.cuenta
      })
    }
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
  const date = new Date(dateStr + 'T00:00:00')
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
    const titulo = 'Impresión Nueva'
    const subtitulo = `Folio: ${datos.folio_impresion || 'N/A'}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave de Cuenta',
        valor: datos.clave_cuenta || filters.value.cuenta || 'N/A'
      },
      {
        concepto: 'Folio Impresión',
        valor: datos.folio_impresion || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Tipo de Documento',
        valor: datos.tipo_documento || 'N/A'
      },
      {
        concepto: 'Número de Páginas',
        valor: datos.numero_paginas || 'N/A'
      },
      {
        concepto: 'Formato',
        valor: datos.formato || 'N/A'
      },
      {
        concepto: 'Estado',
        valor: datos.estado || 'N/A'
      },
      {
        concepto: 'Periodo',
        valor: datos.periodo || 'N/A'
      },
      {
        concepto: 'Contribuyente',
        valor: datos.contribuyente || 'N/A'
      },
      {
        concepto: 'Monto Total',
        valor: formatCurrency(datos.monto_total || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: new Date().getFullYear(),
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
    const titulo = 'Impresión Nueva'
    const subtitulo = `Folio: ${datos.folio_impresion || 'N/A'}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave de Cuenta',
        valor: datos.clave_cuenta || filters.value.cuenta || 'N/A'
      },
      {
        concepto: 'Folio Impresión',
        valor: datos.folio_impresion || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Tipo de Documento',
        valor: datos.tipo_documento || 'N/A'
      },
      {
        concepto: 'Número de Páginas',
        valor: datos.numero_paginas || 'N/A'
      },
      {
        concepto: 'Formato',
        valor: datos.formato || 'N/A'
      },
      {
        concepto: 'Estado',
        valor: datos.estado || 'N/A'
      },
      {
        concepto: 'Periodo',
        valor: datos.periodo || 'N/A'
      },
      {
        concepto: 'Contribuyente',
        valor: datos.contribuyente || 'N/A'
      },
      {
        concepto: 'Monto Total',
        valor: formatCurrency(datos.monto_total || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: new Date().getFullYear(),
      columnas: [
        { key: 'concepto', header: 'Concepto', type: 'text' },
        { key: 'valor', header: 'Valor', type: 'text' }
      ]
    }

    descargarReporteTabular(datosReporte, opciones)
    const nombreArchivo = `impresion_nueva_${datos.clave_cuenta || filters.value.cuenta}_${datos.folio_impresion || 'NA'}.pdf`
    console.log(`✅ Reporte descargado exitosamente: ${nombreArchivo}`)
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
  }
}
</script>

