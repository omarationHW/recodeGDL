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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_SEARCH = 'RECAUDADORA_PREPAGOFRM'
const { loading, execute } = useApi()

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
    const data = await execute(OP_SEARCH, BASE_DB, params)

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

<style scoped>
.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.text-muted {
  color: #6c757d;
}

.font-weight-bold {
  font-weight: 600;
}

.mb-3 {
  margin-bottom: 1rem;
}

/* Badges */
.badge {
  display: inline-block;
  padding: 0.25em 0.6em;
  font-size: 0.875em;
  font-weight: 600;
  line-height: 1;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0.25rem;
}

.badge-success {
  background-color: #28a745;
}

.badge-danger {
  background-color: #dc3545;
}

.badge-warning {
  background-color: #ffc107;
  color: #212529;
}

/* Footer de tabla */
.municipal-table-footer tr {
  background-color: #f8f9fa;
  font-weight: 600;
  border-top: 2px solid #dee2e6;
}

/* Botón secundario */
.btn-municipal-secondary {
  padding: 0.5rem 1rem;
  border: 1px solid #6c757d;
  background-color: #fff;
  color: #6c757d;
  border-radius: 0.25rem;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #6c757d;
  color: #fff;
}

.btn-municipal-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

/* Resumen de información */
.info-summary {
  display: flex;
  gap: 2rem;
  margin-top: 1.5rem;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 0.25rem;
  border: 1px solid #dee2e6;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

/* Responsive para móviles */
@media (max-width: 768px) {
  .municipal-table {
    font-size: 0.875rem;
  }

  .municipal-table th,
  .municipal-table td {
    padding: 0.5rem;
  }

  .info-summary {
    flex-direction: column;
    gap: 0.5rem;
  }

  .button-group {
    flex-direction: column;
  }

  .button-group button {
    width: 100%;
  }
}
</style>
