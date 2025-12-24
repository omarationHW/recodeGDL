<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga Masiva de Adeudos</h1>
        <p>Aseo Contratado - Generación automática de adeudos por ejercicio fiscal</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Configuración de Carga</h5>
        </div>
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Advertencia:</strong> Esta operación generará adeudos mensuales para todos los contratos vigentes del ejercicio seleccionado.
            El proceso puede tardar varios minutos dependiendo de la cantidad de contratos.
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Ejercicio Fiscal</label>
              <input type="number" v-model="ejercicio" class="municipal-form-control"
                :placeholder="currentYear" :min="currentYear - 5" :max="currentYear + 1" required />
              <small class="form-text">Ingrese el año para el cual desea generar los adeudos</small>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Opciones Adicionales</label>
              <div class="form-check">
                <input type="checkbox" v-model="generarRecargos" class="form-check-input" id="chkRecargos" />
                <label class="form-check-label" for="chkRecargos">
                  Generar recargos automáticamente
                </label>
              </div>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="ejecutarCarga" :disabled="loading || !ejercicio">
              <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" />
              {{ loading ? 'Procesando...' : 'Ejecutar Carga Masiva' }}
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario" :disabled="loading">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado de la carga -->
      <div v-if="resultado" class="municipal-card mt-3">
        <div class="municipal-card-header" :class="resultado.success ? 'bg-success' : 'bg-danger'">
          <h5 class="text-white">
            <font-awesome-icon :icon="resultado.success ? 'check-circle' : 'exclamation-circle'" />
            {{ resultado.success ? 'Carga Completada' : 'Error en Carga' }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <p><strong>{{ resultado.message }}</strong></p>
          <div v-if="resultado.success" class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">Contratos Procesados</label>
              <p class="detail-value">{{ resultado.contratos_procesados }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Adeudos Generados</label>
              <p class="detail-value">{{ resultado.adeudos_generados }}</p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Tiempo de Proceso</label>
              <p class="detail-value">{{ tiempoProceso }} segundos</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Historial de cargas -->
      <div v-if="historial.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="history" /> Historial de Cargas Recientes</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Ejercicio</th>
                  <th>Contratos</th>
                  <th>Adeudos</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, idx) in historial" :key="idx">
                  <td>{{ formatDate(item.fecha) }}</td>
                  <td>{{ item.ejercicio }}</td>
                  <td>{{ item.contratos_procesados }}</td>
                  <td>{{ item.adeudos_generados }}</td>
                  <td>
                    <span :class="['badge', item.success ? 'badge-success' : 'badge-danger']">
                      {{ item.success ? 'Exitoso' : 'Error' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Carga Masiva">
      <h3>Carga Masiva de Adeudos</h3>
      <p>Este módulo permite generar automáticamente los adeudos mensuales para todos los contratos vigentes de un ejercicio fiscal.</p>

      <h4>Proceso:</h4>
      <ol>
        <li>Seleccione el ejercicio fiscal (año)</li>
        <li>Opcionalmente, active la generación automática de recargos</li>
        <li>Ejecute la carga masiva</li>
        <li>El sistema generará 12 adeudos mensuales por cada contrato vigente</li>
        <li>Se calculará el importe según las unidades y costos configurados</li>
      </ol>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>Solo se procesan contratos con status "Vigente" (V) o "Nuevo" (N)</li>
        <li>Si ya existen adeudos para un periodo, se omiten (no duplica)</li>
        <li>El proceso puede tardar varios minutos con muchos contratos</li>
        <li>Se recomienda ejecutar al inicio de cada ejercicio fiscal</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const currentYear = new Date().getFullYear()
const ejercicio = ref(currentYear)
const generarRecargos = ref(false)
const resultado = ref(null)
const tiempoProceso = ref(0)
const historial = ref([])

const ejecutarCarga = async () => {
  if (!ejercicio.value) {
    showToast('Debe ingresar un ejercicio fiscal', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: '¿Ejecutar Carga Masiva?',
    html: `<p>Se generarán adeudos para el ejercicio <strong>${ejercicio.value}</strong></p>
           <p class="text-warning">Esta operación puede tardar varios minutos.</p>
           <p>¿Desea continuar?</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#004085',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, ejecutar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  loading.value = true
  resultado.value = null
  const startTime = Date.now()

  try {
    const response = await execute('SP_ASEO_ADEUDOS_CARGA_MASIVA', 'aseo_contratado', {
      p_ejercicio: ejercicio.value,
      p_usuario_id: 1
    })

    tiempoProceso.value = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.data && response.data[0]) {
      resultado.value = response.data[0]

      // Agregar al historial
      historial.value.unshift({
        fecha: new Date(),
        ejercicio: ejercicio.value,
        ...resultado.value
      })

      if (resultado.value.success) {
        showToast('Carga masiva completada exitosamente', 'success')

        // Si se solicitó generar recargos
        if (generarRecargos.value) {
          await generarRecargosAutomaticos()
        }
      } else {
        showToast(resultado.value.message, 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al ejecutar la carga masiva', 'error')
    resultado.value = {
      success: false,
      message: error.message || 'Error desconocido',
      contratos_procesados: 0,
      adeudos_generados: 0
    }
  } finally {
    loading.value = false
  }
}

const generarRecargosAutomaticos = async () => {
  try {
    const response = await execute('SP_ASEO_ADEUDOS_GENERAR_RECARGOS', 'aseo_contratado', {
      p_ejercicio: ejercicio.value,
      p_mes_hasta: new Date().getMonth() + 1,
      p_usuario_id: 1
    })

    if (response && response.data && response.data[0] && response.data[0].success) {
      showToast(`Recargos generados: ${response.data[0].recargos_generados}`, 'info')
    }
  } catch (error) {
    console.error('Error generando recargos:', error)
  }
}

const limpiarFormulario = () => {
  ejercicio.value = currentYear
  generarRecargos.value = false
  resultado.value = null
}

const formatDate = (date) => {
  return new Date(date).toLocaleString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  // Inicialización
})
</script>
