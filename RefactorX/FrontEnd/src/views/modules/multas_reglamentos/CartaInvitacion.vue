<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="envelope" />
      </div>
      <div class="module-view-info">
        <h1>Cartas de Invitación Predial</h1>
        <p>Consulta de cartas de invitación por cuenta</p>
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
              <label class="municipal-form-label">Cuenta (Cve Cuenta)</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                placeholder="Ej: 120912"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio (Año)</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="Ej: 2024 (0 = todos)"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta"
              @click="generar"
            >
              <font-awesome-icon icon="search" /> Consultar Cartas
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>Cartas Encontradas ({{ rows.length }})</h5>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Cve Cuenta</th>
                  <th>Clave Catastral</th>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th>Total</th>
                  <th>Impuesto</th>
                  <th>Periodo</th>
                  <th>Fecha Emisión</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td>{{ r.foliocarta }}</td>
                  <td>{{ r.cvecuenta }}</td>
                  <td>{{ r.cvecatnva }}</td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ r.calle }} {{ r.exterior }}, {{ r.colonia }}</td>
                  <td>${{ r.total }}</td>
                  <td>${{ r.impuesto }}</td>
                  <td>{{ r.axoini }} - {{ r.axofin }}</td>
                  <td>{{ r.fecemi }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-else-if="mensaje">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <p><strong>{{ mensaje }}</strong></p>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'CartaInvitacion'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Cartas de Invitación Predial'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'CartaInvitacion'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Cartas de Invitación Predial'"
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


const BASE_DB = 'multas_reglamentos'
const OP_GEN = 'RECAUDADORA_CARTA_INVITACION'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  cuenta: '',
  ejercicio: new Date().getFullYear()
})

const rows = ref([])
const mensaje = ref('')

async function generar() {
  const params = [
    { nombre: 'p_clave_cuenta', valor: String(filters.value.cuenta || ''), tipo: 'string' },
    { nombre: 'p_ejercicio', valor: Number(filters.value.ejercicio || 0), tipo: 'integer' }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_GEN, BASE_DB, params, '', null, 'publico')

    // Extraer datos de la estructura correcta
    const data = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(data?.result) ? data.result : []

    if (arr.length > 0) {
      rows.value = arr
      mensaje.value = ''
    } else {
      rows.value = []
      mensaje.value = 'No se encontraron cartas de invitación para esta cuenta'
    }
  } catch (e) {
    rows.value = []
    mensaje.value = e.message || 'Error al consultar cartas'
  } finally {
    hideLoading()
  }
}
</script>
