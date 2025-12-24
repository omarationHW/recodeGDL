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
                <tr v-if="resultado.registros_procesados !== null">
                  <td><strong>Registros Procesados</strong></td>
                  <td><code>{{ resultado.registros_procesados }}</code></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'Exclusivos_Upd'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Exclusivos Update'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'Exclusivos_Upd'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Exclusivos Update'"
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
const OP_UPD = 'RECAUDADORA_EXCLUSIVOS_UPD'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const jsonPayload = ref('')
const resultado = ref(null)

async function aplicar() {
  resultado.value = null // Limpiar resultado anterior

  try {
    const params = [
      { nombre: 'datos', tipo: 'string', valor: jsonPayload.value }
    ]
    const data = await execute(OP_UPD, BASE_DB, params, '', null, 'publico')

    // Extraer el resultado del SP
    const result = data?.result?.[0] || data?.[0] || {}

    // Mostrar resultado en tabla
    resultado.value = {
      success: result.success || false,
      message: result.message || 'Error al procesar la actualización',
      registros_procesados: result.registros_procesados !== undefined ? result.registros_procesados : null
    }

    // Limpiar el formulario si fue exitoso
    if (result.success) {
      jsonPayload.value = ''
    }
  } catch (e) {
    console.error('Error al aplicar:', e)
    resultado.value = {
      success: false,
      message: 'Error al aplicar cambios: ' + (e.message || 'Error desconocido'),
      registros_procesados: null
    }
  }
}
</script>
