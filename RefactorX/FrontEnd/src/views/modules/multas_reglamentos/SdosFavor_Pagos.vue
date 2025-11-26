<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="receipt" /></div>
      <div class="module-view-info">
        <h1>Pagos de Saldos a Favor</h1>
        <p>Consulta de pagos</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" @keyup.enter="reload"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Pagos</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Ejercicio</th>
                  <th>Imp. Inconform</th>
                  <th>Imp. Pago</th>
                  <th>Saldo Favor</th>
                  <th>Fecha Pago</th>
                  <th>Solicitante</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="r.id_pago_favor" class="row-hover">
                  <td>{{ r.id_pago_favor }}</td>
                  <td>{{ r.cvecuenta }}</td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>${{ formatMoney(r.imp_inconform) }}</td>
                  <td>${{ formatMoney(r.imp_pago) }}</td>
                  <td>${{ formatMoney(r.saldo_favor) }}</td>
                  <td>{{ r.fecha_pago || 'N/A' }}</td>
                  <td>{{ r.solicitante || 'N/A' }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="9" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_SDOSFAVOR_PAGOS'
const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])

function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]

  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    rows.value = Array.isArray(data?.result) ? data.result : []
  } catch (e) {
    console.error('Error cargando pagos:', e)
    rows.value = []
  }
}
</script>

