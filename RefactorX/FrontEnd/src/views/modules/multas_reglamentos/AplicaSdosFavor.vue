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
            <button class="btn-municipal-primary" :disabled="loading || !isConsultarEnabled" @click="consultar">
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
          <h5>
            <font-awesome-icon icon="list" /> Resultados
            <span v-if="registros.length > 0" class="badge-info">{{ registros.length }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center text-muted" style="padding: 2rem;">
            <div class="spinner-border" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-2">Consultando saldos a favor...</p>
          </div>
          <div v-else-if="registros.length === 0 && hasSearched" class="text-center text-muted" style="padding: 2rem;">
            <font-awesome-icon icon="inbox" size="3x" style="opacity: 0.3; margin-bottom: 1rem;" />
            <h5>No se encontraron saldos a favor</h5>
            <p>Intenta con otros parámetros de búsqueda o verifica que los datos existan en la base de datos.</p>
            <p class="text-muted"><small>Tip: Puedes buscar sin especificar cuenta para ver todos los registros</small></p>
          </div>
          <div v-else-if="!hasSearched" class="text-center text-muted" style="padding: 2rem;">
            <font-awesome-icon icon="search" size="3x" style="opacity: 0.3; margin-bottom: 1rem;" />
            <h5>Inicia una búsqueda</h5>
            <p>Ingresa los parámetros y haz clic en "Consultar" para buscar saldos a favor</p>
          </div>
          <div v-else class="table-responsive">
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
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos' // TODO confirmar
const OP_CONSULTA_SALDOS = 'RECAUDADORA_CONSULTA_SDOS_FAVOR' // TODO confirmar
const OP_APLICA_SALDOS = 'RECAUDADORA_APLICA_SDOS_FAVOR' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: null, folio: null })
const registros = ref([])
const hasSearched = ref(false)

// Computed: habilitar botón Consultar si al menos uno de los campos tiene datos
const isConsultarEnabled = computed(() => {
  const tieneCuenta = filters.value.cuenta && filters.value.cuenta.trim() !== ''
  const tieneEjercicio = filters.value.ejercicio !== null && filters.value.ejercicio !== ''
  const tieneFolio = filters.value.folio !== null && filters.value.folio !== ''

  // Habilitar si al menos uno tiene datos
  return tieneCuenta || tieneEjercicio || tieneFolio
})

async function consultar() {
  registros.value = []
  hasSearched.value = true

  // Preparar parámetros: enviar null si están vacíos
  const params = [
    {
      nombre: 'p_clave_cuenta',
      tipo: 'string',
      valor: filters.value.cuenta && filters.value.cuenta.trim() !== '' ? String(filters.value.cuenta) : null
    },
    {
      nombre: 'p_ejercicio',
      tipo: 'integer',
      valor: filters.value.ejercicio !== null && filters.value.ejercicio !== '' ? Number(filters.value.ejercicio) : null
    },
    {
      nombre: 'p_folio',
      tipo: 'integer',
      valor: filters.value.folio !== null && filters.value.folio !== '' ? Number(filters.value.folio) : null
    }
  ]

  console.log('Parámetros enviados:', params)

  try {
    const data = await execute(OP_CONSULTA_SALDOS, BASE_DB, params)
    console.log('Respuesta del SP:', data)
    // La respuesta viene en data.result debido a la estructura del GenericController
    registros.value = Array.isArray(data?.result) ? data.result : (Array.isArray(data) ? data : [])
    console.log('Registros procesados:', registros.value.length, 'registros')
  } catch (e) {
    console.error('Error en consulta:', e)
  }
}

async function aplicar() {
  if (registros.value.length === 0) return
  const params = [
    { nombre: 'p_registros', tipo: 'string', valor: JSON.stringify(registros.value) }
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

