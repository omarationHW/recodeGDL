<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="keyboard" />
      </div>
      <div class="module-view-info">
        <h1>Captura de Diferencias Prediales</h1>
        <p>Registro de diferencias en formato JSON</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Datos de la Diferencia</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">
                Datos en formato JSON
                <small style="color: #666; display: block; margin-top: 4px;">
                  Campos requeridos: axo (año), cvecuenta, monto. Opcional: status (default: "A")
                </small>
              </label>
              <textarea
                class="municipal-form-control"
                rows="10"
                v-model="jsonPayload"
                placeholder='Ejemplo:
{
  "axo": 2024,
  "cvecuenta": 123456,
  "monto": 1500.50,
  "status": "A"
}'
                style="font-family: monospace;"
              ></textarea>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" /> Guardar Diferencia
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
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
          <div :class="['alert', resultado.success ? 'alert-success' : 'alert-error']">
            <p><strong>{{ resultado.message }}</strong></p>
            <div v-if="resultado.success && resultado.data">
              <hr/>
              <p><strong>ID Generado:</strong> {{ resultado.data.id_insertado }}</p>
              <p><strong>Año:</strong> {{ resultado.data.axo }}</p>
              <p><strong>Cve Cuenta:</strong> {{ resultado.data.cvecuenta }}</p>
              <p><strong>Monto:</strong> ${{ resultado.data.monto }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'CapturaDif'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Captura de Diferencias Prediales'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'CapturaDif'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Captura de Diferencias Prediales'"
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
const OP_SAVE = 'RECAUDADORA_CAPTURA_DIF'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const jsonPayload = ref('')
const resultado = ref(null)

async function guardar() {
  const params = [
    { nombre: 'p_datos', valor: jsonPayload.value, tipo: 'string' }
  ]

  showLoading('Guardando diferencia...', 'Por favor espere')
  try {
    const data = await execute(OP_SAVE, BASE_DB, params, '', null, 'publico')

    // El SP devuelve un array con un solo registro
    const row = Array.isArray(data?.result) && data.result.length > 0
      ? data.result[0]
      : null

    if (row) {
      resultado.value = {
        success: row.success,
        message: row.message,
        data: row.success ? row : null
      }

      // Si fue exitoso, limpiar el formulario
      if (row.success) {
        jsonPayload.value = ''
      }
    } else {
      resultado.value = {
        success: false,
        message: 'No se recibió respuesta del servidor'
      }
    }
  } catch (e) {
    resultado.value = {
      success: false,
      message: e.message || 'Error al guardar la diferencia'
    }
  } finally {
    hideLoading()
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
}
</script>
