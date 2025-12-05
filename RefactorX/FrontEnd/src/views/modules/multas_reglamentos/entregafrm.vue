<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="truck-ramp-box" />
      </div>
      <div class="module-view-info">
        <h1>Entrega</h1>
        <p>Registro de entrega</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Datos (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="8"
                v-model="jsonPayload"
                placeholder='{"campo": "valor"}'
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" /> Guardar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_ENTREGAFRM'

const jsonPayload = ref('')

async function guardar() {
  try {
    const params = [
      { nombre: 'datos', tipo: 'string', valor: jsonPayload.value }
    ]
    const data = await execute(OP, BASE_DB, params)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}

    if (result.success) {
      alert(`✅ ${result.message}\n\nFolio: ${result.folio}\nEjecutor: ${result.ejecutor}\nFecha: ${result.fecha_entrega}`)
      jsonPayload.value = ''
    } else {
      alert(`❌ ${result.message || 'Error al procesar la entrega'}`)
    }
  } catch (e) {
    console.error('Error al guardar:', e)
    alert('❌ Error al guardar los datos: ' + (e.message || 'Error desconocido'))
  }
}
</script>
