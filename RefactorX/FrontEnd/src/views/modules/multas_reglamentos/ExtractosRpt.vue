<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Extractos (Reporte)</h1>
        <p>Generación de extractos de cuenta</p>
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
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="generar"
                placeholder="Ej: 12345"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading || !filters.cuenta" @click="generar">
              <font-awesome-icon icon="print" /> Generar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="extracto && !loading">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="receipt" /> Extracto de Cuenta</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Botones de reporte -->
          <div class="report-actions" v-if="extracto.success">
            <button class="btn-report btn-preview" @click="verReporte">
              <font-awesome-icon icon="eye" />
              <span>Ver Reporte</span>
            </button>
            <button class="btn-report btn-download" @click="descargarReporte">
              <font-awesome-icon icon="download" />
              <span>Descargar Reporte</span>
            </button>
          </div>

          <div v-if="extracto.success">
            <div class="info-grid">
              <div class="info-item">
                <strong>Cuenta:</strong> {{ extracto.cuenta }}
              </div>
              <div class="info-item">
                <strong>Clave Catastral:</strong> {{ extracto.clave_catastral }}
              </div>
              <div class="info-item">
                <strong>Contribuyente:</strong> {{ extracto.contribuyente }}
              </div>
              <div class="info-item">
                <strong>Domicilio:</strong> {{ extracto.domicilio }}
              </div>
              <div class="info-item">
                <strong>Cantidad de Multas:</strong> {{ extracto.cantidad_multas }}
              </div>
              <div class="info-item">
                <strong>Total Adeudo:</strong> ${{ Number(extracto.total_adeudo).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
              </div>
              <div class="info-item">
                <strong>Fecha Extracto:</strong> {{ extracto.fecha_extracto }}
              </div>
            </div>
            <div class="mt-3">
              <p class="success-message">{{ extracto.message }}</p>
            </div>
          </div>
          <div v-else class="alert alert-warning">
            {{ extracto.message }}
          </div>
        </div>
      </div>
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'ExtractosRpt'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Extractos (Reporte)'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'ExtractosRpt'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Extractos (Reporte)'"
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


const BASE_DB = 'multas_reglamentos'
const OP_REP = 'RECAUDADORA_EXTRACTOS_RPT'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()
const filters = ref({ cuenta: '' })
const extracto = ref(null)

async function generar() {
  if (!filters.value.cuenta) {
    alert('Por favor ingrese una cuenta')
    return
  }

  try {
    const params = [
      { nombre: 'clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta) }
    ]
    const data = await execute(OP_REP, BASE_DB, params, '', null, SCHEMA)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}
    extracto.value = result

    if (!result.success) {
      alert(`⚠️ ${result.message || 'No se encontró información para esta cuenta'}`)
    }
  } catch (e) {
    console.error('Error al generar extracto:', e)
    alert('❌ Error al generar extracto: ' + (e.message || 'Error desconocido'))
    extracto.value = null
  }
}

function verReporte() {
  if (!extracto.value || !extracto.value.success) {
    alert('⚠️ No hay datos de extracto para generar el reporte')
    return
  }

  try {
    // Crear un array con una sola fila que contiene los datos del extracto
    const datos = [{
      cuenta: extracto.value.cuenta,
      clave_catastral: extracto.value.clave_catastral,
      contribuyente: extracto.value.contribuyente,
      domicilio: extracto.value.domicilio,
      cantidad_multas: extracto.value.cantidad_multas,
      total_adeudo: extracto.value.total_adeudo
    }]

    const opciones = {
      titulo: 'Extracto de Cuenta',
      subtitulo: `Extracto generado el ${extracto.value.fecha_extracto}`,
      ejercicio: extracto.value.fecha_extracto,
      columnas: [
        { key: 'cuenta', header: 'Cuenta', type: 'text' },
        { key: 'clave_catastral', header: 'Clave Catastral', type: 'text' },
        { key: 'contribuyente', header: 'Contribuyente', type: 'text' },
        { key: 'domicilio', header: 'Domicilio', type: 'text' },
        { key: 'cantidad_multas', header: 'Cant. Multas', type: 'number' },
        { key: 'total_adeudo', header: 'Total Adeudo', type: 'currency' }
      ]
    }

    verReporteTabular(datos, opciones)
    console.log('✅ Vista previa del extracto generada exitosamente')
  } catch (e) {
    console.error('❌ Error al generar vista previa:', e)
    alert('❌ Error al generar vista previa: ' + (e.message || 'Error desconocido'))
  }
}

function descargarReporte() {
  if (!extracto.value || !extracto.value.success) {
    alert('⚠️ No hay datos de extracto para descargar el reporte')
    return
  }

  try {
    // Crear un array con una sola fila que contiene los datos del extracto
    const datos = [{
      cuenta: extracto.value.cuenta,
      clave_catastral: extracto.value.clave_catastral,
      contribuyente: extracto.value.contribuyente,
      domicilio: extracto.value.domicilio,
      cantidad_multas: extracto.value.cantidad_multas,
      total_adeudo: extracto.value.total_adeudo
    }]

    const opciones = {
      titulo: 'Extracto de Cuenta',
      subtitulo: `Extracto generado el ${extracto.value.fecha_extracto}`,
      ejercicio: extracto.value.fecha_extracto,
      columnas: [
        { key: 'cuenta', header: 'Cuenta', type: 'text' },
        { key: 'clave_catastral', header: 'Clave Catastral', type: 'text' },
        { key: 'contribuyente', header: 'Contribuyente', type: 'text' },
        { key: 'domicilio', header: 'Domicilio', type: 'text' },
        { key: 'cantidad_multas', header: 'Cant. Multas', type: 'number' },
        { key: 'total_adeudo', header: 'Total Adeudo', type: 'currency' }
      ]
    }

    descargarReporteTabular(datos, opciones)
    console.log('✅ Extracto descargado exitosamente')
  } catch (e) {
    console.error('❌ Error al descargar extracto:', e)
    alert('❌ Error al descargar extracto: ' + (e.message || 'Error desconocido'))
  }
}
</script>

