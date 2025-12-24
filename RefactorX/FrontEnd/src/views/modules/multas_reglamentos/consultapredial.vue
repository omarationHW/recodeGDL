<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="house" /></div>
      <div class="module-view-info">
        <h1>Consulta Predial</h1>
        <p>Consulta información de propiedades por clave catastral</p>
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
              <label class="municipal-form-label">Clave Catastral</label>
              <input
                class="municipal-form-control"
                v-model="filters.cvecat"
                placeholder="Ej: D65I3950016"
                @keyup.enter="filters.cvecat.trim() && consultar()"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cvecat.trim()"
              @click="consultar"
            >
              <font-awesome-icon icon="search" v-if="!loading"/>
              <font-awesome-icon icon="spinner" spin v-if="loading"/>
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="data">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Información del Predio</h5>
        </div>
        <div class="municipal-card-body">
          <div class="predial-content">
            <div class="predial-section">
              <h6 class="predial-section-title">Identificación</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Clave Catastral:</label>
                  <span class="predial-value highlight">{{ data.cvecatnva }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Cuenta:</label>
                  <span class="predial-value">{{ data.cvecuenta }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Vigente:</label>
                  <span class="predial-value" :class="data.vigente === 'V' ? 'badge-activo' : 'badge-inactivo'">
                    {{ data.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Tipo:</label>
                  <span class="predial-value">{{ data.urbano_rustico === 'U' ? 'Urbano' : 'Rústico' }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section">
              <h6 class="predial-section-title">Información Fiscal</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Valor Fiscal:</label>
                  <span class="predial-value currency">${{ formatCurrency(data.val_fiscal) }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Saldo:</label>
                  <span class="predial-value currency" :class="parseFloat(data.saldo) > 0 ? 'text-danger' : 'text-success'">
                    ${{ formatCurrency(data.saldo) }}
                  </span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Año Adeudo:</label>
                  <span class="predial-value">{{ data.axoadeudo || 'Sin adeudo' }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Exenta:</label>
                  <span class="predial-value">{{ data.exenta && data.exenta.trim() ? 'Sí' : 'No' }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section">
              <h6 class="predial-section-title">Dimensiones</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Área Terreno:</label>
                  <span class="predial-value">{{ data.area_terreno }} m²</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Área Construcción:</label>
                  <span class="predial-value">{{ data.area_construccion }} m²</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Área Total:</label>
                  <span class="predial-value highlight">{{ (parseInt(data.area_terreno || 0) + parseInt(data.area_construccion || 0)) }} m²</span>
                </div>
                <div class="predial-item" v-if="data.tipo_predio && data.tipo_predio.trim()">
                  <label class="predial-label">Tipo Predio:</label>
                  <span class="predial-value">{{ data.tipo_predio }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section" v-if="data.bloqueado && data.bloqueado.trim()">
              <h6 class="predial-section-title">Estado</h6>
              <div class="predial-alert">
                <font-awesome-icon icon="exclamation-triangle" />
                Predio Bloqueado
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-else-if="!loading">
        <div class="municipal-card-body">
          <p class="text-muted text-center">
            <font-awesome-icon icon="info-circle" />
            Sin datos. Ingresa una clave catastral y presiona Buscar.
          </p>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'consultapredial'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Consulta Predial'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'consultapredial'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Consulta Predial'"
      @close="showDocumentacion = false"
    />

  </div>
</template>
<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_CONSULTAPREDIAL'

const filters = ref({ cvecat: '' })
const data = ref(null)

async function consultar() {
  const params = [
    { nombre: 'p_cvecat', tipo: 'string', valor: String(filters.value.cvecat || '') }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP, BASE_DB, params, '', null, 'publico')
    console.log('Respuesta completa:', response)

    // Extraer datos con fallbacks
    const responseData = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(responseData?.result) ? responseData.result :
                 Array.isArray(responseData?.rows) ? responseData.rows :
                 Array.isArray(responseData) ? responseData : []

    console.log('Datos extraídos:', arr.length, arr)
    data.value = arr.length > 0 ? arr[0] : null
  } catch (e) {
    console.error('Error al consultar predio:', e)
    data.value = null
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { cvecat: '' }
  data.value = null
}

function formatCurrency(value) {
  if (!value) return '0.00'
  return parseFloat(value).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>


