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
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_GEN = 'RECAUDADORA_CARTA_INVITACION'

const { loading, execute } = useApi()

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

  try {
    const data = await execute(OP_GEN, BASE_DB, params)
    const arr = Array.isArray(data?.result) ? data.result : []

    if (arr.length > 0) {
      if (arr[0].success) {
        rows.value = arr
        mensaje.value = arr[0].message
      } else {
        rows.value = []
        mensaje.value = arr[0].message
      }
    } else {
      rows.value = []
      mensaje.value = 'No se encontraron resultados'
    }
  } catch (e) {
    rows.value = []
    mensaje.value = e.message || 'Error al consultar cartas'
  }
}
</script>

<style scoped>
.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
  padding: 1rem;
  border-radius: 4px;
  margin-top: 1rem;
}
</style>

