<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="signature" />
      </div>
      <div class="module-view-info">
        <h1>Firma Electrónica</h1>
        <p>Gestión de firmas electrónicas</p>
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
                placeholder='{"folio": "12345", "usuario": "admin", "tipo": "recaudadora", "datos_firma": "..."}'
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="firmar"
            >
              <font-awesome-icon icon="signature" /> Firmar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="resultado && !loading">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-signature" /> Resultado de Firma</h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="resultado.success" class="alert alert-success">
            <strong>✅ {{ resultado.message }}</strong>
            <div class="mt-2" v-if="resultado.folio">
              <p><strong>Folio:</strong> {{ resultado.folio }}</p>
              <p><strong>Fecha:</strong> {{ resultado.fecha_firma }}</p>
              <p><strong>Usuario:</strong> {{ resultado.usuario }}</p>
            </div>
          </div>
          <div v-else class="alert alert-warning">
            <strong>⚠️ {{ resultado.message }}</strong>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Procesando...</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_SIGN = 'RECAUDADORA_FIRMA_ELECTRONICA'

const { loading, execute } = useApi()
const jsonPayload = ref('')
const resultado = ref(null)

async function firmar() {
  if (!jsonPayload.value) {
    alert('Por favor ingrese los datos JSON')
    return
  }

  try {
    const params = [
      { nombre: 'datos', tipo: 'string', valor: jsonPayload.value }
    ]
    const data = await execute(OP_SIGN, BASE_DB, params)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}
    resultado.value = result

    if (result.success) {
      alert(`✅ ${result.message}\n\nFolio: ${result.folio || 'N/A'}\nFecha: ${result.fecha_firma || 'N/A'}`)
    } else {
      alert(`⚠️ ${result.message || 'Error al procesar la firma'}`)
    }
  } catch (e) {
    console.error('Error al firmar:', e)
    alert('❌ Error al procesar firma: ' + (e.message || 'Error desconocido'))
    resultado.value = null
  }
}
</script>

<style scoped>
.alert {
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-warning {
  background-color: #fff3cd;
  border: 1px solid #ffeaa7;
  color: #856404;
}

.mt-2 {
  margin-top: 0.5rem;
}
</style>


