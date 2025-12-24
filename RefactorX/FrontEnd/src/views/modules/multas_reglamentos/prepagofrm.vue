<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="wallet" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Prepagos</h1>
        <p>Búsqueda de pagos por cuenta, folio o clave de pago</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar por Cuenta, Folio o Clave de Pago</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda"
                @keyup.enter="consultar"
                placeholder="Ej: 260676, 6334905, 13578982..."
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading || !busqueda.trim()" @click="consultar">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Consultando...</span>
              <span v-else>Buscar Pagos</span>
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="pagos.length > 0">
        <div class="municipal-card-header">
          <h5>Pagos Encontrados - {{ pagos.length }} registro(s)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cve Pago</th>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Fecha</th>
                  <th class="text-right">Importe</th>
                  <th>Caja</th>
                  <th>Cajero</th>
                  <th class="text-center">Cancelado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, idx) in pagos" :key="idx" class="row-hover">
                  <td class="font-weight-bold">{{ pago.cvepago }}</td>
                  <td>{{ pago.cvecuenta }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ formatDate(pago.fecha_pago) }}</td>
                  <td class="text-right">${{ formatMoney(pago.importe) }}</td>
                  <td>{{ pago.caja }}</td>
                  <td>{{ pago.cajero }}</td>
                  <td class="text-center">
                    <span class="badge" :class="pago.cancelado === 'Sí' ? 'badge-danger' : 'badge-success'">
                      {{ pago.cancelado }}
                    </span>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4" class="font-weight-bold text-right">TOTAL:</td>
                  <td class="text-right font-weight-bold">${{ formatMoney(totalImporte) }}</td>
                  <td colspan="3"></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Información adicional -->
          <div class="info-summary">
            <div class="info-item">
              <strong>Total de pagos:</strong> {{ pagos.length }}
            </div>
            <div class="info-item">
              <strong>Suma total:</strong> ${{ formatMoney(totalImporte) }}
            </div>
            <div class="info-item" v-if="pagos.length >= 100">
              <span class="badge badge-warning">
                <font-awesome-icon icon="exclamation-triangle" />
                Resultados limitados a 100 registros
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div class="municipal-card" v-else-if="searched && pagos.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">
            <font-awesome-icon icon="search" size="3x" class="mb-3" />
            <br />
            No se encontraron pagos para: <strong>{{ busqueda }}</strong>
          </p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'prepagofrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Consulta de Prepagos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'prepagofrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Consulta de Prepagos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP_SEARCH = 'RECAUDADORA_PREPAGOFRM'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const busqueda = ref('')
const pagos = ref([])
const searched = ref(false)

// Total importe computed
const totalImporte = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + Number(pago.importe || 0), 0)
})

async function consultar() {
  searched.value = false
  pagos.value = []

  if (!busqueda.value.trim()) {
    return
  }

  const params = [
    { nombre: 'p_busqueda', tipo: 'string', valor: busqueda.value.trim() }
  ]

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP_SEARCH, BASE_DB, params, '', null, SCHEMA)

    // Extraer los datos de la respuesta
    let rows = []
    if (data?.result) {
      rows = data.result
    } else if (data?.rows) {
      rows = data.rows
    } else if (Array.isArray(data)) {
      rows = data
    }

    pagos.value = rows
    searched.value = true
  } catch (e) {
    console.error('Error al consultar pagos:', e)
    pagos.value = []
    searched.value = true
  } finally {
    hideLoading()
  }
}

function limpiar() {
  busqueda.value = ''
  pagos.value = []
  searched.value = false
}

function formatMoney(value) {
  if (!value) return '0.00'
  return Number(value).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function formatDate(value) {
  if (!value) return ''
  const date = new Date(value)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}
</script>

