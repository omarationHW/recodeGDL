<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Imprime Descuentos</h1>
        <p>Generación e impresión de reportes de descuentos</p>
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
              <label class="municipal-form-label">Clave de Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                placeholder="Ej: CTA-001-2025"
                @keyup.enter="generar"
              />
              <small class="form-text">Ingrese la clave de cuenta</small>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año (Ejercicio)</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="2025"
                @keyup.enter="generar"
              />
              <small class="form-text">Año del ejercicio fiscal</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta || !filters.ejercicio"
              @click="generar"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'print'" :spin="loading"/>
              {{ loading ? 'Procesando...' : 'Generar Reporte' }}
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
              <strong>{{ result[0].mensaje || 'Reporte generado exitosamente' }}</strong>

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

              <!-- Detalles del Reporte -->
              <div class="result-details" v-if="result[0].folio_reporte">
                <h6><font-awesome-icon icon="file-alt"/> Información del Reporte</h6>

                <div class="detail-grid">
                  <div class="detail-item">
                    <span class="detail-label">Folio del Reporte:</span>
                    <span class="detail-value">{{ result[0].folio_reporte }}</span>
                  </div>

                  <div class="detail-item">
                    <span class="detail-label">Clave de Cuenta:</span>
                    <span class="detail-value">{{ filters.cuenta }}</span>
                  </div>

                  <div class="detail-item">
                    <span class="detail-label">Ejercicio:</span>
                    <span class="detail-value">{{ filters.ejercicio }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].fecha_generacion">
                    <span class="detail-label">Fecha de Generación:</span>
                    <span class="detail-value">{{ formatDate(result[0].fecha_generacion) }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].total_descuentos !== null">
                    <span class="detail-label">Total de Descuentos:</span>
                    <span class="detail-value">{{ result[0].total_descuentos }}</span>
                  </div>

                  <div class="detail-item" v-if="result[0].porcentaje_promedio !== null">
                    <span class="detail-label">Porcentaje Promedio:</span>
                    <span class="detail-value">{{ result[0].porcentaje_promedio }}%</span>
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].monto_total !== null && result[0].monto_total !== undefined">
                  <h6><font-awesome-icon icon="dollar-sign"/> Monto Total de Descuentos</h6>
                  <div class="monto-destacado">
                    {{ formatCurrency(result[0].monto_total) }}
                  </div>
                </div>

                <div class="detail-section" v-if="result[0].detalles_descuentos">
                  <h6><font-awesome-icon icon="list"/> Detalles de Descuentos</h6>
                  <pre class="detalles-text">{{ result[0].detalles_descuentos }}</pre>
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
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { usePdfGenerator } from '@/composables/usePdfGenerator'

const BASE_DB = 'multas_reglamentos'
const OP_REPORTE = 'RECAUDADORA_IMPRIME_DESCTOS'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()

const filters = ref({
  cuenta: '',
  ejercicio: new Date().getFullYear()
})
const result = ref(null)

async function generar() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: Number(filters.value.ejercicio || 0) }
  ]
  try {
    const response = await execute(OP_REPORTE, BASE_DB, params, '', null, SCHEMA)
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
    const titulo = 'Reporte de Descuentos'
    const subtitulo = `Cuenta: ${filters.value.cuenta} - Ejercicio: ${filters.value.ejercicio}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave de Cuenta',
        valor: filters.value.cuenta || 'N/A'
      },
      {
        concepto: 'Folio del Reporte',
        valor: datos.folio_reporte || 'N/A'
      },
      {
        concepto: 'Ejercicio',
        valor: filters.value.ejercicio || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Total de Descuentos',
        valor: datos.total_descuentos || '0'
      },
      {
        concepto: 'Porcentaje Promedio',
        valor: datos.porcentaje_promedio ? `${datos.porcentaje_promedio}%` : 'N/A'
      },
      {
        concepto: 'Monto Total',
        valor: formatCurrency(datos.monto_total || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: filters.value.ejercicio || new Date().getFullYear(),
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
    const titulo = 'Reporte de Descuentos'
    const subtitulo = `Cuenta: ${filters.value.cuenta} - Ejercicio: ${filters.value.ejercicio}`

    // Preparar datos para el reporte tabular
    const datosReporte = [
      {
        concepto: 'Clave de Cuenta',
        valor: filters.value.cuenta || 'N/A'
      },
      {
        concepto: 'Folio del Reporte',
        valor: datos.folio_reporte || 'N/A'
      },
      {
        concepto: 'Ejercicio',
        valor: filters.value.ejercicio || 'N/A'
      },
      {
        concepto: 'Fecha de Generación',
        valor: datos.fecha_generacion ? formatDate(datos.fecha_generacion) : 'N/A'
      },
      {
        concepto: 'Total de Descuentos',
        valor: datos.total_descuentos || '0'
      },
      {
        concepto: 'Porcentaje Promedio',
        valor: datos.porcentaje_promedio ? `${datos.porcentaje_promedio}%` : 'N/A'
      },
      {
        concepto: 'Monto Total',
        valor: formatCurrency(datos.monto_total || 0)
      }
    ]

    const opciones = {
      titulo: titulo,
      subtitulo: subtitulo,
      ejercicio: filters.value.ejercicio || new Date().getFullYear(),
      columnas: [
        { key: 'concepto', header: 'Concepto', type: 'text' },
        { key: 'valor', header: 'Valor', type: 'text' }
      ]
    }

    descargarReporteTabular(datosReporte, opciones)
    const nombreArchivo = `descuentos_${filters.value.cuenta}_${filters.value.ejercicio}.pdf`
    console.log(`✅ Reporte descargado exitosamente: ${nombreArchivo}`)
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
  }
}
</script>

<style scoped>
.form-text {
  color: #6c757d;
  font-size: 0.85rem;
  margin-top: 4px;
  display: block;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 8px;
  padding: 16px;
  color: #155724;
}

.alert-success svg {
  margin-right: 8px;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 16px;
  color: #721c24;
}

.alert-danger svg {
  margin-right: 8px;
}

.result-details {
  margin-top: 16px;
}

.result-details h6 {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 12px;
  color: #155724;
  display: flex;
  align-items: center;
  gap: 8px;
}

.detail-section {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #c3e6cb;
}

.detail-section:first-child {
  margin-top: 0;
  padding-top: 0;
  border-top: none;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 12px;
  margin-bottom: 8px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-label {
  font-size: 0.85rem;
  font-weight: 500;
  color: #155724;
  opacity: 0.8;
}

.detail-value {
  font-size: 0.95rem;
  font-weight: 600;
  color: #155724;
}

.monto-destacado {
  font-size: 2rem;
  font-weight: 700;
  color: #155724;
  text-align: center;
  padding: 16px;
  background: rgba(212, 237, 218, 0.3);
  border-radius: 8px;
  margin-top: 8px;
}

.detalles-text {
  margin: 8px 0 0 0;
  padding: 12px;
  background: rgba(212, 237, 218, 0.3);
  border-radius: 6px;
  font-size: 0.85rem;
  color: #155724;
  line-height: 1.6;
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: 'Courier New', monospace;
}

.result-box {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  padding: 16px;
}

.result-box pre {
  margin: 0;
  font-family: 'Courier New', monospace;
  font-size: 0.85rem;
  white-space: pre-wrap;
  word-wrap: break-word;
}

/* Botones de reporte */
.report-actions {
  display: flex;
  gap: 10px;
  margin-top: 20px;
  padding: 15px;
  background: rgba(212, 237, 218, 0.3);
  border-radius: 8px;
  border: 1px solid #c3e6cb;
}

.btn-report {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-report:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn-preview {
  background: linear-gradient(135deg, #28a745 0%, #20963d 100%);
  color: white;
}

.btn-preview:hover {
  background: linear-gradient(135deg, #218838 0%, #1c7430 100%);
}

.btn-download {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
}

.btn-download:hover {
  background: linear-gradient(135deg, #0069d9 0%, #004085 100%);
}

.btn-report svg {
  font-size: 1rem;
}

@media (max-width: 768px) {
  .report-actions {
    flex-direction: column;
  }

  .btn-report {
    width: 100%;
    justify-content: center;
  }
}
</style>
