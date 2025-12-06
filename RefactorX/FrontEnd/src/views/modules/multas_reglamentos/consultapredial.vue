<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="house" /></div>
      <div class="module-view-info">
        <h1>Consulta Predial</h1>
        <p>Consulta información de propiedades por clave catastral</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave Catastral</label>
              <input class="municipal-form-control" v-model="filters.cvecat" placeholder="Ej: D65I3950016" @keyup.enter="consultar"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="data">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Información del Predio</h5>
        </div>
        <div class="municipal-card-body">
          <div class="predial-content">
            <div class="predial-section">
              <h6 class="predial-section-title">Identificación</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Clave Catastral:</label>
                  <span class="predial-value highlight">{{ data.cvecatnva }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Cuenta:</label>
                  <span class="predial-value">{{ data.cvecuenta }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Vigente:</label>
                  <span class="predial-value" :class="data.vigente === 'V' ? 'badge-activo' : 'badge-inactivo'">
                    {{ data.vigente === 'V' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Tipo:</label>
                  <span class="predial-value">{{ data.urbano_rustico === 'U' ? 'Urbano' : 'Rústico' }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section">
              <h6 class="predial-section-title">Información Fiscal</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Valor Fiscal:</label>
                  <span class="predial-value currency">${{ formatCurrency(data.val_fiscal) }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Saldo:</label>
                  <span class="predial-value currency" :class="parseFloat(data.saldo) > 0 ? 'text-danger' : 'text-success'">
                    ${{ formatCurrency(data.saldo) }}
                  </span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Año Adeudo:</label>
                  <span class="predial-value">{{ data.axoadeudo || 'Sin adeudo' }}</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Exenta:</label>
                  <span class="predial-value">{{ data.exenta && data.exenta.trim() ? 'Sí' : 'No' }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section">
              <h6 class="predial-section-title">Dimensiones</h6>
              <div class="predial-grid">
                <div class="predial-item">
                  <label class="predial-label">Área Terreno:</label>
                  <span class="predial-value">{{ data.area_terreno }} m²</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Área Construcción:</label>
                  <span class="predial-value">{{ data.area_construccion }} m²</span>
                </div>
                <div class="predial-item">
                  <label class="predial-label">Área Total:</label>
                  <span class="predial-value highlight">{{ (parseInt(data.area_terreno || 0) + parseInt(data.area_construccion || 0)) }} m²</span>
                </div>
                <div class="predial-item" v-if="data.tipo_predio && data.tipo_predio.trim()">
                  <label class="predial-label">Tipo Predio:</label>
                  <span class="predial-value">{{ data.tipo_predio }}</span>
                </div>
              </div>
            </div>

            <div class="predial-section" v-if="data.bloqueado && data.bloqueado.trim()">
              <h6 class="predial-section-title">Estado</h6>
              <div class="predial-alert">
                <font-awesome-icon icon="exclamation-triangle" />
                Predio Bloqueado
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-else-if="!loading">
        <div class="municipal-card-body">
          <p class="text-muted text-center">
            <font-awesome-icon icon="info-circle" />
            Sin datos. Ingresa una clave catastral y presiona Buscar.
          </p>
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
const OP = 'RECAUDADORA_CONSULTAPREDIAL'
const SCHEMA = 'multas_reglamentos'

const filters = ref({ cvecat: '' })
const data = ref(null)

async function consultar() {
  try {
    const result = await execute(OP, BASE_DB, [
      { nombre: 'p_cvecat', tipo: 'string', valor: String(filters.value.cvecat || '') }
    ], '', null, SCHEMA)
    data.value = Array.isArray(result?.result) ? result.result[0] :
                  Array.isArray(result?.rows) ? result.rows[0] :
                  Array.isArray(result) ? result[0] : result
  } catch (e) {
    data.value = null
  }
}

function formatCurrency(value) {
  if (!value) return '0.00'
  return parseFloat(value).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
</script>

<style scoped>
.predial-content {
  padding: 0.5rem 0;
}

.predial-section {
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.predial-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.predial-section-title {
  color: #2c5282;
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #3b82f6;
}

.predial-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 0.75rem;
}

.predial-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.predial-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.predial-value {
  font-size: 0.95rem;
  color: #1e293b;
  font-weight: 500;
  padding: 0.4rem 0.6rem;
  background-color: #f8fafc;
  border-radius: 4px;
  border-left: 3px solid #cbd5e1;
}

.predial-value.highlight {
  background-color: #eff6ff;
  border-left-color: #3b82f6;
  color: #1e40af;
  font-weight: 600;
}

.predial-value.currency {
  font-family: 'Courier New', monospace;
  font-weight: 600;
  font-size: 1rem;
}

.badge-activo {
  background-color: #10b981;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: 600;
  text-align: center;
  border-left: none;
}

.badge-inactivo {
  background-color: #ef4444;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 4px;
  font-weight: 600;
  text-align: center;
  border-left: none;
}

.text-danger {
  color: #dc2626 !important;
  font-weight: 700;
}

.text-success {
  color: #059669 !important;
}

.predial-alert {
  background-color: #fef3c7;
  border-left: 4px solid #f59e0b;
  padding: 1rem;
  border-radius: 4px;
  color: #92400e;
  font-size: 0.95rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

@media (max-width: 768px) {
  .predial-grid {
    grid-template-columns: 1fr;
  }
}
</style>

