<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Cancelación de Multas</h1>
        <p>canc.vue</p>
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
            <div class="form-group">
              <label class="municipal-form-label">Folio (Número de Acta)</label>
              <input
                class="municipal-form-control"
                v-model.number="form.folio"
                type="number"
                placeholder="Ej: 12345"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año (Ejercicio)</label>
              <input
                class="municipal-form-control"
                v-model.number="form.ejercicio"
                type="number"
                placeholder="Ej: 2024"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-danger"
              :disabled="loading || !form.folio"
              @click="cancelar"
            >
              <font-awesome-icon icon="ban"/> Cancelar Multa
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="resultado">
        <div class="municipal-card-header">
          <h5>Resultado de la Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div :class="['alert', resultado.success ? 'alert-success' : 'alert-error']">
            <p><strong>{{ resultado.message }}</strong></p>
            <div v-if="resultado.success && resultado.data">
              <hr/>
              <p><strong>ID Multa:</strong> {{ resultado.data.id_multa }}</p>
              <p><strong>Folio:</strong> {{ resultado.data.num_acta }}</p>
              <p><strong>Ejercicio:</strong> {{ resultado.data.axo_acta }}</p>
              <p><strong>Contribuyente:</strong> {{ resultado.data.contribuyente }}</p>
              <p><strong>Total:</strong> ${{ resultado.data.total }}</p>
              <p><strong>Fecha de Cancelación:</strong> {{ resultado.data.fecha_cancelacion }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'canc'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Cancelación de Multas'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'canc'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Cancelación de Multas'"
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
const OP_CANCEL = 'RECAUDADORA_CANC'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const form = ref({
  folio: null,
  ejercicio: new Date().getFullYear()
})

const resultado = ref(null)

async function cancelar() {
  const params = [
    { nombre: 'p_folio', valor: Number(form.value.folio || 0), tipo: 'integer' },
    { nombre: 'p_ejercicio', valor: Number(form.value.ejercicio || 0), tipo: 'integer' }
  ]

  showLoading('Cancelando multa...', 'Por favor espere')
  try {
    const data = await execute(OP_CANCEL, BASE_DB, params, '', null, 'publico')

    // El SP devuelve un array con un solo registro
    const row = Array.isArray(data?.result) && data.result.length > 0
      ? data.result[0]
      : null

    if (row) {
      resultado.value = {
        success: row.success,
        message: row.message,
        data: row.success ? {
          id_multa: row.multa_id,
          num_acta: row.multa_num_acta,
          axo_acta: row.multa_axo_acta,
          contribuyente: row.multa_contribuyente,
          total: row.multa_total,
          fecha_cancelacion: row.multa_fecha_cancelacion
        } : null
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
      message: e.message || 'Error al cancelar la multa'
    }
  } finally {
    hideLoading()
  }
}
</script>
