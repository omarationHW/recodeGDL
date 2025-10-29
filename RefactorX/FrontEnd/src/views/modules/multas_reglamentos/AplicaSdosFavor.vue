<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="balance-scale" />
      </div>
      <div class="module-view-info">
        <h1>Aplicación de Saldos a Favor</h1>
        <p>Gestión de saldos a favor mediante procedimientos almacenados</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" placeholder="Clave de cuenta" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.folio" :disabled="loading" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
              <font-awesome-icon icon="search" /> Consultar
            </button>
            <button class="btn-municipal-secondary" :disabled="loading || registros.length === 0" @click="aplicar">
              <font-awesome-icon icon="check" /> Aplicar saldo
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Folio</th>
                  <th>Ejercicio</th>
                  <th>Saldo</th>
                  <th>Aplicable</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in registros" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.ejercicio }}</td>
                  <td class="text-end">{{ formatCurrency(r.saldo) }}</td>
                  <td>
                    <span class="badge" :class="r.aplicable ? 'badge-success' : 'badge-secondary'">
                      {{ r.aplicable ? 'Sí' : 'No' }}
                    </span>
                  </td>
                </tr>
                <tr v-if="registros.length === 0">
                  <td colspan="5" class="text-center text-muted">Sin registros</td>
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

const BASE_DB = 'INFORMIX' // TODO confirmar
const OP_CONSULTA_SALDOS = 'RECAUDADORA_CONSULTA_SDOS_FAVOR' // TODO confirmar
const OP_APLICA_SALDOS = 'RECAUDADORA_APLICA_SDOS_FAVOR' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear(), folio: null })
const registros = ref([])

async function consultar() {
  registros.value = []
  const params = [
    { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') },
    { name: 'ejercicio', type: 'I', value: Number(filters.value.ejercicio || 0) },
    { name: 'folio', type: 'I', value: Number(filters.value.folio || 0) }
  ]
  try {
    const data = await execute(OP_CONSULTA_SALDOS, BASE_DB, params)
    registros.value = Array.isArray(data) ? data : []
  } catch (e) {}
}

async function aplicar() {
  if (registros.value.length === 0) return
  const params = [
    { name: 'registros', type: 'C', value: JSON.stringify(registros.value) }
  ]
  try {
    await execute(OP_APLICA_SALDOS, BASE_DB, params)
    await consultar()
  } catch (e) {}
}

function formatCurrency(v) {
  const n = Number(v || 0)
  return n.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}
</script>

