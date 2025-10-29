<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="sliders" /></div>
      <div class="module-view-info">
        <h1>Modificación Masiva</h1>
        <p>Actualización de múltiples registros</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">JSON de cambios</label>
              <textarea class="municipal-form-control" rows="8" v-model="jsonPayload" placeholder='[{"clave_cuenta":"..."}, ...]'></textarea>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="aplicar"><font-awesome-icon icon="check" /> Aplicar</button>
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
const OP_UPDATE = 'RECAUDADORA_MODIF_MASIVA' // TODO confirmar

const { loading, execute } = useApi()

const jsonPayload = ref('')

async function aplicar() {
  try {
    const params = [ { name: 'datos', type: 'C', value: jsonPayload.value } ]
    await execute(OP_UPDATE, BASE_DB, params)
  } catch (e) {}
}
</script>

