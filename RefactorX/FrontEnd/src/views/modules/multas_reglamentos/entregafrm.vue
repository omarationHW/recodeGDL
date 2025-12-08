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

      <!-- Results table -->
      <div v-if="resultado" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" />
            Resultado de la Operación
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Campo</th>
                  <th>Valor</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>Estado</strong></td>
                  <td>
                    <span :class="'badge badge-' + (resultado.success ? 'success' : 'danger')">
                      {{ resultado.success ? 'Exitoso' : 'Error' }}
                    </span>
                  </td>
                </tr>
                <tr>
                  <td><strong>Mensaje</strong></td>
                  <td>{{ resultado.message }}</td>
                </tr>
                <tr v-if="resultado.folio">
                  <td><strong>Folio</strong></td>
                  <td><code>{{ resultado.folio }}</code></td>
                </tr>
                <tr v-if="resultado.ejecutor">
                  <td><strong>Ejecutor</strong></td>
                  <td>{{ resultado.ejecutor }}</td>
                </tr>
                <tr v-if="resultado.fecha_entrega">
                  <td><strong>Fecha de Entrega</strong></td>
                  <td>{{ resultado.fecha_entrega }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
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
const resultado = ref(null)

async function guardar() {
  resultado.value = null // Limpiar resultado anterior

  try {
    const params = [
      { nombre: 'datos', tipo: 'string', valor: jsonPayload.value }
    ]
    const data = await execute(OP, BASE_DB, params)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}

    // Mostrar resultado en tabla
    resultado.value = {
      success: result.success || false,
      message: result.message || 'Error al procesar la entrega',
      folio: result.folio || null,
      ejecutor: result.ejecutor || null,
      fecha_entrega: result.fecha_entrega || null
    }

    // Limpiar el formulario si fue exitoso
    if (result.success) {
      jsonPayload.value = ''
    }
  } catch (e) {
    console.error('Error al guardar:', e)
    resultado.value = {
      success: false,
      message: 'Error al guardar los datos: ' + (e.message || 'Error desconocido'),
      folio: null,
      ejecutor: null,
      fecha_entrega: null
    }
  }
}
</script>
