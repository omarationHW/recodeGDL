<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Extractos (Reporte)</h1>
        <p>Generación de extractos de cuenta</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="generar"
                placeholder="Ej: 12345"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading || !filters.cuenta" @click="generar">
              <font-awesome-icon icon="print" /> Generar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="extracto && !loading">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="receipt" /> Extracto de Cuenta</h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="extracto.success">
            <div class="info-grid">
              <div class="info-item">
                <strong>Cuenta:</strong> {{ extracto.cuenta }}
              </div>
              <div class="info-item">
                <strong>Clave Catastral:</strong> {{ extracto.clave_catastral }}
              </div>
              <div class="info-item">
                <strong>Total Adeudo:</strong> ${{ extracto.total_adeudo }}
              </div>
              <div class="info-item">
                <strong>Fecha:</strong> {{ extracto.fecha_extracto }}
              </div>
            </div>
            <div class="mt-3">
              <p>{{ extracto.message }}</p>
            </div>
          </div>
          <div v-else class="alert alert-warning">
            {{ extracto.message }}
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Generando...</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_REP = 'RECAUDADORA_EXTRACTOS_RPT'

const { loading, execute } = useApi()
const filters = ref({ cuenta: '' })
const extracto = ref(null)

async function generar() {
  if (!filters.value.cuenta) {
    alert('Por favor ingrese una cuenta')
    return
  }

  try {
    const params = [
      { nombre: 'clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta) }
    ]
    const data = await execute(OP_REP, BASE_DB, params)

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}
    extracto.value = result

    if (!result.success) {
      alert(`⚠️ ${result.message || 'No se encontró información para esta cuenta'}`)
    }
  } catch (e) {
    console.error('Error al generar extracto:', e)
    alert('❌ Error al generar extracto: ' + (e.message || 'Error desconocido'))
    extracto.value = null
  }
}
</script>

<style scoped>
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.info-item {
  padding: 0.5rem;
  background: #f8f9fa;
  border-radius: 4px;
}

.mt-3 {
  margin-top: 1rem;
}
</style>
