<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map-location-dot" /></div>
      <div class="module-view-info">
        <h1>Metrometers — Datos y Mapa</h1>
        <p>Buscar por Año y Folio</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="folio" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card" v-if="row">
        <div class="municipal-card-header"><h5>Información</h5></div>
        <div class="municipal-card-body">
          <table class="detail-table">
            <tr><td class="label">Dirección</td><td>{{ row.direccion }}</td></tr>
            <tr><td class="label">Marca/Modelo</td><td>{{ row.marca }} / {{ row.modelo }}</td></tr>
            <tr><td class="label">Lat/Lon</td><td>{{ row.poslat }}, {{ row.poslong }}</td></tr>
            <tr><td class="label">Motivo</td><td>{{ row.motivo }}</td></tr>
          </table>
        </div>
      </div>
      <div class="municipal-card" v-if="mapUrl">
        <div class="municipal-card-header"><h5>Mapa</h5></div>
        <div class="municipal-card-body">
          <img :src="mapUrl" alt="mapa" class="img-responsive img-bordered" />
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - MetrometersPublicos"
    >
      <h3>Metrometers Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'MetrometersPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const loading = ref(false)

const axo = ref(new Date().getFullYear())
const folio = ref(0)
const row = ref(null)
const mapUrl = ref('')

async function buscar() {
  if (!folio.value) {
    showToast('warning', 'Ingrese el número de folio')
    return
  }

  showLoading('Buscando...', 'Consultando metrometer')
  loading.value = true
  row.value = null
  mapUrl.value = ''
  try {
    const params = [
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folio.value, tipo: 'integer' }
    ]

    // Ejecutar ambas consultas en paralelo
    const [resp, resp2] = await Promise.all([
      execute('sp_get_metrometer_by_axo_folio', BASE_DB, params, '', null, SCHEMA),
      execute('sp_get_metrometers_map_url', BASE_DB, params, '', null, SCHEMA)
    ])

    const data1 = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data1) ? data1[0] : data1
    row.value = r || null

    const data2 = resp2?.result || resp2?.data?.result || resp2?.data || []
    const m = Array.isArray(data2) ? data2[0] : data2
    mapUrl.value = m?.map_url || ''

    if (row.value) {
      showToast('success', `Folio ${folio.value} - ${row.value.direccion || 'Sin dirección'}`)
    } else {
      showToast('info', 'No se encontró el metrometer especificado')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

