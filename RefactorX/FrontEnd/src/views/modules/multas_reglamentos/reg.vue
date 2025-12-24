<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file" />
      </div>
      <div class="module-view-info">
        <h1>Registro</h1>
        <p>Registrar información en el sistema</p>
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
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Registro (JSON)</label>
              <textarea
                class="municipal-form-control"
                rows="8"
                v-model="jsonPayload"
                placeholder='{"campo1": "valor1", "campo2": "valor2"}'
              ></textarea>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !jsonPayload"
              @click="guardar"
            >
              <font-awesome-icon icon="save" v-if="!loading" />
              <span v-if="loading">Guardando...</span>
              <span v-else>Guardar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>Éxito:</strong> {{ success }}
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultado && resultado.length > 0">
        <div class="municipal-card-header">
          <h5>✅ Resultados</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="(value, key) in resultado[0]" :key="key">
                    {{ key }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultado" :key="idx" class="row-hover">
                  <td v-for="(value, key) in row" :key="key">
                    {{ value }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'reg'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Registro'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'reg'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Registro'"
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
const OP = 'RECAUDADORA_REG'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const jsonPayload = ref('')
const resultado = ref(null)
const success = ref(null)
const error = ref(null)

async function guardar() {
  error.value = null
  success.value = null
  resultado.value = null

  try {
    // Validar JSON
    let jsonData
    try {
      jsonData = JSON.parse(jsonPayload.value)
    } catch (e) {
      error.value = 'El JSON no es válido: ' + e.message
      return
    }

    showLoading('Consultando...', 'Por favor espere')
    console.log('🔍 Ejecutando SP:', OP)
    console.log('🔍 Datos:', jsonData)

    // Enviar parámetros en el formato correcto
    const params = [
      {
        nombre: 'p_registro',
        valor: jsonPayload.value,
        tipo: 'string'
      }
    ]

    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)

    console.log('✅ Resultado:', data)

    // Procesar respuesta
    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    resultado.value = arr
    success.value = 'Registro guardado exitosamente'

  } catch (e) {
    error.value = e.message || 'Error al guardar el registro'
    console.error('❌ Error:', e)
  } finally {
    hideLoading()
  }
}

function limpiar() {
  jsonPayload.value = ''
  resultado.value = null
  success.value = null
  error.value = null
}
</script>

