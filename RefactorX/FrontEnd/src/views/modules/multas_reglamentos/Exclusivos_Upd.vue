<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="id-badge" />
      </div>
      <div class="module-view-info">
        <h1>Exclusivos Update</h1>
        <p>Actualización de exclusivos</p>
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
                placeholder='{"id": 123, "campo": "valor", "accion": "actualizar"}'
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="aplicar"
            >
              <font-awesome-icon icon="check" /> Aplicar
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

const BASE_DB = 'multas_reglamentos'
const OP_UPD = 'RECAUDADORA_EXCLUSIVOS_UPD'

const { loading, execute } = useApi()
const jsonPayload = ref('')

async function aplicar() {
  try {
    const params = [
      { nombre: 'datos', tipo: 'string', valor: jsonPayload.value }
    ]
    const data = await execute(OP_UPD, BASE_DB, params)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}

    if (result.success) {
      alert(`✅ ${result.message}\n\nRegistros procesados: ${result.registros_procesados || 0}`)
      jsonPayload.value = ''
    } else {
      alert(`❌ ${result.message || 'Error al procesar la actualización'}`)
    }
  } catch (e) {
    console.error('Error al aplicar:', e)
    alert('❌ Error al aplicar cambios: ' + (e.message || 'Error desconocido'))
  }
}
</script>
