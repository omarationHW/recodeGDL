<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Aplicacion de Multas Normal</h1>
        <p>Aseo Contratado - Configuracion de Requerimientos para Cobro</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Configuracion Actual -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Aplicacion Normal de Requerimientos para Cobro</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos actuales (solo lectura) -->
          <div class="form-row">
            <div class="form-group col-md-8">
              <label class="municipal-form-label">Descripcion</label>
              <input
                type="text"
                :value="configActual.descripcion"
                class="municipal-form-control"
                readonly
              />
            </div>
            <div class="form-group col-md-2">
              <label class="municipal-form-label">Aplica</label>
              <input
                type="text"
                :value="configActual.aplica"
                class="municipal-form-control text-center"
                readonly
              />
            </div>
            <div class="form-group col-md-2">
              <label class="municipal-form-label">%</label>
              <input
                type="text"
                :value="configActual.porc"
                class="municipal-form-control text-center"
                readonly
              />
            </div>
          </div>

          <!-- Selector de Aplicacion -->
          <div class="form-row mt-4">
            <div class="form-group col-md-8">
              <label class="municipal-form-label">Aplicacion de Requerimiento Normal</label>
              <div class="municipal-radio-group">
                <label class="municipal-radio-option">
                  <input
                    type="radio"
                    v-model="opcionAplica"
                    value="S"
                    name="aplicacion"
                  />
                  <span class="municipal-radio-label">SI</span>
                </label>
                <label class="municipal-radio-option">
                  <input
                    type="radio"
                    v-model="opcionAplica"
                    value="N"
                    name="aplicacion"
                  />
                  <span class="municipal-radio-label">NO</span>
                </label>
              </div>
            </div>
            <div class="form-group col-md-4">
              <label class="municipal-form-label">Porcentaje (si NO aplica)</label>
              <div class="municipal-input-group">
                <input
                  type="number"
                  v-model.number="porcentaje"
                  class="municipal-form-control text-center"
                  min="0"
                  max="99"
                  :disabled="opcionAplica === 'S'"
                />
                <span class="municipal-input-group-text">%</span>
              </div>
            </div>
          </div>

          <!-- Info -->
          <div class="municipal-alert municipal-alert-info mt-3" v-if="opcionAplica === 'S'">
            <font-awesome-icon icon="info-circle" />
            Se aplicara la multa de forma <strong>normal</strong> (sin porcentaje adicional).
          </div>
          <div class="municipal-alert municipal-alert-warning mt-3" v-else>
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>NO</strong> se aplicara la multa normal. Se aplicara un porcentaje de <strong>{{ porcentaje }}%</strong>.
            <span v-if="porcentaje <= 0" class="text-danger">
              <br>Debe ingresar un porcentaje mayor a 0.
            </span>
          </div>
        </div>
      </div>

      <!-- Botones de Accion -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="guardarCambios"
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="save" /> CAMBIOS
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cancelar"
            >
              <font-awesome-icon icon="times" /> SALIR
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Aplicacion de Multas Normal"
      componentName="AplicaMultas"
    >
      <h3>Aplicacion Normal de Requerimientos</h3>
      <p>Este modulo permite configurar como se aplican los requerimientos de cobro (multas) en el sistema de aseo contratado.</p>

      <h4>Opciones:</h4>
      <ul>
        <li><strong>SI:</strong> La aplicacion de requerimiento es normal, sin porcentaje adicional. El porcentaje se establece en 0.</li>
        <li><strong>NO:</strong> No se aplica el requerimiento normal. Debe especificar un porcentaje de aplicacion (1-99%).</li>
      </ul>

      <h4>Campos:</h4>
      <ul>
        <li><strong>Descripcion:</strong> Texto descriptivo de la configuracion (solo lectura)</li>
        <li><strong>Aplica:</strong> S=Si aplica normal, N=No aplica normal</li>
        <li><strong>%:</strong> Porcentaje de aplicacion cuando Aplica=N</li>
      </ul>

      <h4>Uso:</h4>
      <ol>
        <li>Seleccione SI o NO segun el tipo de aplicacion deseada</li>
        <li>Si selecciona NO, ingrese el porcentaje</li>
        <li>Presione CAMBIOS para guardar</li>
      </ol>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const router = useRouter()

// Estado
const showDocumentation = ref(false)

// Configuracion actual (solo lectura)
const configActual = ref({
  descripcion: '',
  aplica: '',
  porc: 0
})

// Valores editables
const opcionAplica = ref('S')
const porcentaje = ref(0)

// Validacion
const isFormValid = computed(() => {
  if (opcionAplica.value === 'S') {
    return true
  }
  // Si es NO, debe tener porcentaje > 0
  return porcentaje.value > 0
})

// Cargar configuracion actual
const cargarConfiguracion = async () => {
  showLoading()
  try {
    const data = await execute('sp_aseo_get_config_aplicareq', BASE_DB, [], '', null, SCHEMA)
    if (data && data.length > 0) {
      configActual.value = {
        descripcion: data[0].descripcion || '',
        aplica: data[0].aplica || 'S',
        porc: data[0].porc || 0
      }
      // Establecer valores editables
      opcionAplica.value = configActual.value.aplica
      porcentaje.value = configActual.value.porc || 0
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar configuracion')
  } finally {
    hideLoading()
  }
}

// Guardar cambios
const guardarCambios = async () => {
  // Validacion adicional
  if (opcionAplica.value === 'N' && porcentaje.value <= 0) {
    showToast('Falta el porcentaje de Aplicacion de Multa', 'warning')
    return
  }

  showLoading()
  try {
    const params = [
      { nombre: 'p_aplica', valor: opcionAplica.value, tipo: 'string' },
      { nombre: 'p_porc', valor: opcionAplica.value === 'S' ? 0 : porcentaje.value, tipo: 'integer' }
    ]

    const data = await execute('sp_aseo_update_config_aplicareq', BASE_DB, params, '', null, SCHEMA)

    hideLoading()

    if (data && data.length > 0) {
      if (data[0].success) {
        await Swal.fire({
          title: 'Actualizado',
          text: data[0].mensaje,
          icon: 'success'
        })
        // Recargar configuracion
        await cargarConfiguracion()
      } else {
        showToast(data[0].mensaje || 'Error al actualizar', 'error')
      }
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al guardar cambios')
  }
}

// Salir
const cancelar = () => {
  router.push('/aseo-contratado')
}

// Inicializar
onMounted(() => {
  cargarConfiguracion()
})
</script>
