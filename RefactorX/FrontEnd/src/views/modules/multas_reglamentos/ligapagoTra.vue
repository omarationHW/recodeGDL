<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="link" />
      </div>
      <div class="module-view-info">
        <h1>Liga Pago Trámite</h1>
        <p>Generación de liga de pago por trámite</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Trámite</label>
              <input
                class="municipal-form-control"
                v-model="filters.tramite"
                @keyup.enter="generar"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="generar"
            >
              <font-awesome-icon icon="link" /> Generar
            </button>
          </div>
        </div>
      </div>

      <!-- Error Message -->
      <div class="municipal-card" v-if="errorMessage">
        <div class="municipal-card-body">
          <div class="alert-danger">
            <font-awesome-icon icon="times-circle"/>
            <strong>{{ errorMessage }}</strong>
          </div>
        </div>
      </div>

      <!-- Success Message -->
      <div class="municipal-card" v-if="successMessage">
        <div class="municipal-card-body">
          <div class="alert-success">
            <font-awesome-icon icon="check-circle"/>
            <strong>{{ successMessage }}</strong>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="ligaGenerada">
        <div class="municipal-card-header">
          <h5>Liga de Pago Generada</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <div v-if="datosTramite" class="info-tramite mb-3">
              <p><strong>Trámite:</strong> {{ datosTramite.tramite }}</p>
              <p v-if="datosTramite.descripcion"><strong>Descripción:</strong> {{ datosTramite.descripcion }}</p>
              <p v-if="datosTramite.total_importe"><strong>Total:</strong> ${{ formatMoney(datosTramite.total_importe) }}</p>
            </div>
            <p><strong>Liga de Pago:</strong></p>
            <p class="liga-url">{{ ligaGenerada }}</p>
            <button class="btn-municipal-secondary mt-2" @click="copiarLiga">
              <font-awesome-icon icon="copy" /> Copiar Liga
            </button>
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

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_LIGAPAGOTRA'
const { loading, execute } = useApi()

const filters = ref({ tramite: '' })
const ligaGenerada = ref('')
const datosTramite = ref(null)
const errorMessage = ref('')
const successMessage = ref('')

async function generar() {
  if (!filters.value.tramite) {
    return
  }

  // Limpiar mensajes previos
  errorMessage.value = ''
  successMessage.value = ''
  ligaGenerada.value = ''
  datosTramite.value = null

  const params = [
    { nombre: 'p_tramite', tipo: 'string', valor: String(filters.value.tramite || '') }
  ]

  try {
    const data = await execute(OP, BASE_DB, params)

    if (data?.result && Array.isArray(data.result) && data.result.length > 0) {
      const resultado = data.result[0]

      if (resultado.liga) {
        ligaGenerada.value = resultado.liga
        datosTramite.value = {
          tramite: resultado.tramite,
          descripcion: resultado.descripcion,
          total_importe: resultado.total_importe,
          mensaje: resultado.mensaje
        }
      } else {
        errorMessage.value = resultado.mensaje || 'No se pudo generar la liga de pago'
      }
    } else {
      errorMessage.value = 'No se encontraron datos para el trámite solicitado'
    }
  } catch (e) {
    console.error('Error generando liga:', e)
    const errorMsg = e?.message || ''
    // Si el error es de tipo SQL o de validación, mostrar mensaje amigable
    if (errorMsg.includes('invalid input syntax') || errorMsg.includes('SQLSTATE') || errorMsg.includes('ERROR:')) {
      errorMessage.value = 'No se encontraron datos para el trámite solicitado'
    } else {
      errorMessage.value = errorMsg || 'Error al generar la liga de pago'
    }
  }
}

function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

function copiarLiga() {
  if (ligaGenerada.value) {
    navigator.clipboard.writeText(ligaGenerada.value)
    successMessage.value = 'Liga copiada al portapapeles'
    // Limpiar mensaje después de 3 segundos
    setTimeout(() => {
      successMessage.value = ''
    }, 3000)
  }
}
</script>

<style scoped>
.info-tramite {
  border-bottom: 1px solid #dee2e6;
  padding-bottom: 1rem;
}

.info-tramite p {
  margin: 0.5rem 0;
}

.liga-url {
  word-break: break-all;
  background: #f8f9fa;
  padding: 10px;
  border-radius: 4px;
  font-family: monospace;
  margin: 1rem 0;
}

.mt-2 {
  margin-top: 0.5rem;
}

.mb-3 {
  margin-bottom: 1rem;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 16px;
  color: #721c24;
}

.alert-danger svg {
  margin-right: 8px;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  border-radius: 8px;
  padding: 16px;
  color: #155724;
}

.alert-success svg {
  margin-right: 8px;
}
</style>
