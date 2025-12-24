<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Requerimiento (Formulario)</h1>
        <p>Captura y actualización</p>
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
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="form.clave_cuenta"
                placeholder="Ingrese la cuenta"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.folio"
                placeholder="Número de folio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="form.ejercicio"
                placeholder="Año del ejercicio"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="guardar"
            >
              <font-awesome-icon icon="save" /> Guardar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <MunicipalModal
      :show="modal.show"
      :title="modal.title"
      :message="modal.message"
      :type="modal.type"
      @close="closeModal"
      @confirm="closeModal"
    />

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'ReqFrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Requerimiento (Formulario)'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'ReqFrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Requerimiento (Formulario)'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import MunicipalModal from '@/components/MunicipalModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)

const BASE_DB = 'multas_reglamentos'
const OP_SAVE = 'RECAUDADORA_REQ_FRM_SAVE'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const form = ref({
  clave_cuenta: '',
  folio: null,
  ejercicio: new Date().getFullYear()
})

const modal = ref({
  show: false,
  title: '',
  message: '',
  type: 'success'
})

function showModal(title, message, type = 'success') {
  modal.value = {
    show: true,
    title,
    message,
    type
  }
}

function closeModal() {
  modal.value.show = false
}

async function guardar() {
  if (!form.value.clave_cuenta || !form.value.folio) {
    showModal(
      'Campos requeridos',
      'Por favor complete los campos Cuenta y Folio',
      'warning'
    )
    return
  }

  const params = [
    { nombre: 'p_registro', tipo: 'string', valor: JSON.stringify(form.value) }
  ]

  try {
    const data = await execute(OP_SAVE, BASE_DB, params)

    if (data?.result && Array.isArray(data.result) && data.result.length > 0) {
      const result = data.result[0]

      if (result.success) {
        showModal(
          'Operación exitosa',
          `${result.mensaje}\n\nID del requerimiento: ${result.cvereq}`,
          'success'
        )

        // Limpiar formulario
        form.value = {
          clave_cuenta: '',
          folio: null,
          ejercicio: new Date().getFullYear()
        }
      } else {
        showModal(
          'Error',
          result.mensaje || 'No se pudo guardar el requerimiento',
          'error'
        )
      }
    }
  } catch (e) {
    console.error('Error guardando requerimiento:', e)
    showModal(
      'Error',
      'Ocurrió un error al guardar el requerimiento. Por favor intente nuevamente.',
      'error'
    )
  }
}
</script>

