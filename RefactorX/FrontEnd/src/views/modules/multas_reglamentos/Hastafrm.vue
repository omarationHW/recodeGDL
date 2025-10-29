<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-days" /></div>
      <div class="module-view-info">
        <h1>Hasta Formulario</h1>
        <p>Parámetros de operación por fecha</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Desde</label>
              <input type="date" class="municipal-form-control" v-model="filters.desde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Hasta</label>
              <input type="date" class="municipal-form-control" v-model="filters.hasta" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="ejecutar"><font-awesome-icon icon="check" /> Ejecutar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'INFORMIX'
const OP_EJEC = 'RECAUDADORA_HASTAFRM' // TODO confirmar

const { loading, execute } = useApi()

const filters = ref({ desde: '', hasta: '' })

async function ejecutar() {
  const params = [
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') }
  ]
  try {
    await execute(OP_EJEC, BASE_DB, params)
  } catch (e) {}
}
</script>

