<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="print" /></div>
      <div class="module-view-info">
        <h1>Imprime Descuentos</h1>
        <p>Generación e impresión de reportes</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input class="municipal-form-control" v-model="filters.cuenta" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="print" /> Generar</button>
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
const OP_REPORTE = 'RECAUDADORA_IMPRIME_DESCTOS' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ cuenta: '', ejercicio: new Date().getFullYear() })

async function generar() {
  const params = [
    { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') },
    { name: 'ejercicio', type: 'I', value: Number(filters.value.ejercicio || 0) }
  ]
  try {
    await execute(OP_REPORTE, BASE_DB, params)
    // El backend debería devolver un archivo o token de descarga
  } catch (e) {}
}
</script>

