<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bills" />
      </div>
      <div class="module-view-info">
        <h1>Pagos Múltiples</h1>
        <p>Aplicar múltiples pagos en lote</p>
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
        <div class="municipal-card-header">
          <h5>Registros a Procesar</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-info mb-3">
            <p><strong>Formato JSON esperado:</strong></p>
            <pre class="json-example">
[
  {
    "cuenta": "123456",
    "folio": "789",
    "importe": 1500.00
  },
  {
    "cuenta": "654321",
    "folio": "790",
    "importe": 2000.00
  }
]</pre>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Registros (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="12"
                v-model="jsonPayload"
                placeholder='Ingresa el JSON con los registros a procesar...'
              ></textarea>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="pagar"
            >
              <font-awesome-icon icon="money-bills" /> Aplicar Pagos
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="resultado">
        <div class="municipal-card-header">
          <h5>Resultado</h5>
        </div>
        <div class="municipal-card-body">
          <div :class="resultado.success ? 'alert alert-success' : 'alert alert-danger'">
            <p><strong>{{ resultado.mensaje }}</strong></p>
            <div v-if="resultado.procesados > 0">
              <p>Registros procesados: {{ resultado.procesados }}</p>
              <p v-if="resultado.errores > 0">Registros con error: {{ resultado.errores }}</p>
            </div>
            <div v-if="resultado.detalles && resultado.detalles.length > 0" class="mt-3">
              <p><strong>Detalles:</strong></p>
              <ul>
                <li v-for="(detalle, index) in resultado.detalles" :key="index" :class="detalle.status === 'error' ? 'text-danger' : 'text-success'">
                  <strong>Cuenta:</strong> {{ detalle.cuenta }},
                  <strong>Folio:</strong> {{ detalle.folio }}
                  <span v-if="detalle.importe"> - <strong>Importe:</strong> ${{ formatMoney(detalle.importe) }}</span>
                  <br>
                  <span class="detalle-mensaje">{{ detalle.mensaje }}</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'pagosmultfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Pagos Múltiples'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'pagosmultfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Pagos Múltiples'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_PAGOSMULTFRM'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const jsonPayload = ref('')
const resultado = ref(null)

async function pagar() {
  if (!jsonPayload.value) {
    return
  }

  // Validar que sea JSON válido
  try {
    JSON.parse(jsonPayload.value)
  } catch (e) {
    alert('Error: El formato JSON no es válido. Por favor verifica la sintaxis.')
    return
  }

  const params = [
    { nombre: 'p_registros', tipo: 'string', valor: jsonPayload.value }
  ]

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)

    if (data?.result && Array.isArray(data.result) && data.result.length > 0) {
      const res = data.result[0]

      // Parsear detalles si vienen como string JSON
      let detalles = res.detalles || []
      if (typeof detalles === 'string') {
        try {
          detalles = JSON.parse(detalles)
        } catch (e) {
          console.error('Error parseando detalles:', e)
          detalles = []
        }
      }

      resultado.value = {
        success: res.success || false,
        mensaje: res.mensaje || 'Operación completada',
        procesados: res.procesados || 0,
        errores: res.errores || 0,
        detalles: detalles
      }
    } else {
      resultado.value = {
        success: true,
        mensaje: 'Operación completada',
        procesados: 0,
        errores: 0,
        detalles: []
      }
    }
  } catch (e) {
    console.error('Error aplicando pagos:', e)
    resultado.value = {
      success: false,
      mensaje: 'Error al procesar los pagos: ' + (e.message || 'Error desconocido'),
      procesados: 0,
      errores: 0,
      detalles: []
    }
  } finally {
    hideLoading()
  }
}

function formatMoney(value) {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
}
</script>

