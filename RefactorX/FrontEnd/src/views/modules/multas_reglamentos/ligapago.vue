<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="link" />
      </div>
      <div class="module-view-info">
        <h1>Liga Pago</h1>
        <p>Generación de liga de pago</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
            <div v-if="datosCuenta" class="info-cuenta mb-3">
              <p><strong>Cuenta:</strong> {{ datosCuenta.cuenta }}</p>
              <p><strong>Requerimientos:</strong> {{ datosCuenta.total_requerimientos }}</p>
              <p><strong>Total Adeudo:</strong> ${{ formatMoney(datosCuenta.total_adeudo) }}</p>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'ligapago'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Liga Pago'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'ligapago'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Liga Pago'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_LIGAPAGO'
const SCHEMA = 'publico'

const filters = ref({ cuenta: '' })
const ligaGenerada = ref('')
const datosCuenta = ref(null)
const errorMessage = ref('')
const successMessage = ref('')

async function generar() {
  if (!filters.value.cuenta) {
    return
  }

  // Limpiar mensajes previos
  errorMessage.value = ''
  successMessage.value = ''
  ligaGenerada.value = ''
  datosCuenta.value = null

  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]

  try {
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)

    if (data?.result && Array.isArray(data.result) && data.result.length > 0) {
      const resultado = data.result[0]

      if (resultado.liga) {
        ligaGenerada.value = resultado.liga
        datosCuenta.value = {
          cuenta: resultado.cuenta,
          total_adeudo: resultado.total_adeudo,
          total_requerimientos: resultado.total_requerimientos,
          mensaje: resultado.mensaje
        }
      } else {
        errorMessage.value = resultado.mensaje || 'No se pudo generar la liga de pago'
      }
    }
  } catch (e) {
    console.error('Error generando liga:', e)
    errorMessage.value = e?.message || 'Error al generar la liga de pago'
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

